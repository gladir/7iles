{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Berzerk;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};


Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  MAX_ROBOTS = 8;
  PLAYER_SPEED = 4;
  SHOT_SPEED = 6;
  MAX_SHOTS = 5;
  ROBOT_SPEED = 2;
  WALL_COLOR = LightBlue;
  ROBOT_HEIGHT = 30;    { Nouvelle constante pour la hauteur des robots }
  ROBOT_WIDTH = 16;     { Nouvelle constante pour la largeur des robots }

Type
  TDirection = (dNone, dUp, dDown, dLeft, dRight);

  TPoint = Record
    X, Y: Integer;
  End;

  TShot = Record
    Active: Boolean;
    Pos: TPoint;
    Direction: TDirection;
  End;

  TRobot = Record
    Active: Boolean;
    Pos: TPoint;
    Direction: TDirection;
  End;

Var
  PlayerX, PlayerY: Integer;
  PlayerDir: TDirection;
  Score: Integer;
  Lives: Integer;
  GameOver: Boolean;
  Shots: Array[1..MAX_SHOTS] of TShot;
  Robots: Array[1..MAX_ROBOTS] of TRobot;
  RoomX, RoomY: Integer;
  I:Integer;

Function IntToStr(Value:Integer):String;
Var
 S:String[11];  { Maximum de 11 caractï¿½res pour un Integer }
Begin
 Str(Value, S);
 IntToStr := S;
End;

Procedure InitScreen;
Var
  Driver, Mode: Integer;
Begin
  {$IFDEF FPC}
    Driver := VGA;
    Mode := VGAHi;
  {$ELSE}
    Driver := Detect;
    Mode := VGAHi;
  {$ENDIF}
  InitGraph(Driver, Mode, '');
End;

Procedure DrawPlayer;
Begin
  { Corps du joueur - humain stylisÃ© }
  SetColor(Yellow);
  { TÃªte }
  Circle(PlayerX, PlayerY-8, 4);

  { Corps }
  Line(PlayerX, PlayerY-4, PlayerX, PlayerY+4);

  { Bras }
  Case PlayerDir of
    dLeft: Begin
      Line(PlayerX, PlayerY, PlayerX-6, PlayerY-4); { Bras gauche }
      Line(PlayerX, PlayerY, PlayerX-6, PlayerY+4); { Bras droit }
    End;
    dRight: Begin
      Line(PlayerX, PlayerY, PlayerX+6, PlayerY-4);
      Line(PlayerX, PlayerY, PlayerX+6, PlayerY+4);
    End;
    dUp: Begin
      Line(PlayerX-6, PlayerY, PlayerX+6, PlayerY);
    End;
    dDown: Begin
      Line(PlayerX-6, PlayerY, PlayerX+6, PlayerY);
    End;
    else Begin
      Line(PlayerX-6, PlayerY, PlayerX+6, PlayerY);
    End;
  End;

  { Jambes }
  Line(PlayerX, PlayerY+4, PlayerX-5, PlayerY+12);
  Line(PlayerX, PlayerY+4, PlayerX+5, PlayerY+12);
End;

Procedure DrawRobot(X, Y: Integer);Begin
 SetColor(LightGreen);

  { Tˆte carr‚e }
 Rectangle(X-8, Y-ROBOT_HEIGHT div 2, X+8, Y-(ROBOT_HEIGHT div 3));

  { Yeux rouges }
 SetColor(LightRed);
 PutPixel(X-4, Y-(ROBOT_HEIGHT div 2)+4, LightRed);
 PutPixel(X+4, Y-(ROBOT_HEIGHT div 2)+4, LightRed);

  { Corps rectangulaire }
 SetColor(LightGreen);
 Rectangle(X-ROBOT_WIDTH div 2, Y-(ROBOT_HEIGHT div 3),
           X+ROBOT_WIDTH div 2, Y+(ROBOT_HEIGHT div 3));

  { Bras robotiques }
 Line(X-ROBOT_WIDTH div 2, Y, X-ROBOT_WIDTH, Y-8);
 Line(X-ROBOT_WIDTH div 2, Y, X-ROBOT_WIDTH, Y+8);
 Line(X+ROBOT_WIDTH div 2, Y, X+ROBOT_WIDTH, Y-8);
 Line(X+ROBOT_WIDTH div 2, Y, X+ROBOT_WIDTH, Y+8);

  { Jambes }
  Line(X-6, Y+(ROBOT_HEIGHT div 3), X-6, Y+ROBOT_HEIGHT div 2);
  Line(X+6, Y+(ROBOT_HEIGHT div 3), X+6, Y+ROBOT_HEIGHT div 2);
End;

Procedure DrawShot(X, Y: Integer);Begin
 SetColor(Yellow);
  { Tir plus visible comme dans le jeu original }
 Line(X-2, Y, X+2, Y);
 Line(X, Y-2, X, Y+2);
End;

Procedure DrawRoom;Begin
 SetColor(WALL_COLOR);
 Rectangle(20, 20, SCREEN_WIDTH-20, SCREEN_HEIGHT-20);
 If RoomX Mod 2 = 0 Then Begin
  Line(20, SCREEN_HEIGHT div 2, 100, SCREEN_HEIGHT div 2);
  Line(SCREEN_WIDTH-100, SCREEN_HEIGHT div 2, SCREEN_WIDTH-20, SCREEN_HEIGHT div 2);
 End;
 If RoomY Mod 2 = 0 Then Begin
  Line(SCREEN_WIDTH div 2, 20, SCREEN_WIDTH div 2, 100);
  Line(SCREEN_WIDTH div 2, SCREEN_HEIGHT-100, SCREEN_WIDTH div 2, SCREEN_HEIGHT-20);
 End;
End;

Function InitGame: Boolean;
Var
 I:Integer;
Begin
 PlayerX:=SCREEN_WIDTH div 2;
 PlayerY:=SCREEN_HEIGHT div 2;
 PlayerDir := dNone;
 Score := 0;
 Lives := 3;
 GameOver := False;
 RoomX := 0;
 RoomY := 0;

 For I:=1 to MAX_SHOTS do
  Shots[I].Active := False;

 For I:=1 to MAX_ROBOTS do Begin
  Robots[I].Active := True;
  Robots[I].Pos.X := Random(SCREEN_WIDTH-100) + 50;
  Robots[I].Pos.Y := Random(SCREEN_HEIGHT-100) + 50;
 End;
 InitGame:=True;
End;

Procedure HandleInput;
Begin
  If KeyPressed Then
    Case ReadKey Of
      #0: Case ReadKey Of
        #72: Begin PlayerDir := dUp; Dec(PlayerY, PLAYER_SPEED); End;
        #80: Begin PlayerDir := dDown; Inc(PlayerY, PLAYER_SPEED); End;
        #75: Begin PlayerDir := dLeft; Dec(PlayerX, PLAYER_SPEED); End;
        #77: Begin PlayerDir := dRight; Inc(PlayerX, PLAYER_SPEED); End;
      End;
      #32: Begin { Tir }
        For I := 1 to MAX_SHOTS do
          If Not Shots[I].Active Then Begin
            Shots[I].Active := True;
            Shots[I].Pos.X := PlayerX;
            Shots[I].Pos.Y := PlayerY;
            Shots[I].Direction := PlayerDir;
            Break;
          End;
      End;
      #27: GameOver := True;
    End;
End;

Procedure UpdateGame;
Var
 I,J:Integer;
Begin
  { Mise … jour des tirs }
 For I := 1 to MAX_SHOTS do
  If Shots[I].Active Then Begin
   Case Shots[I].Direction of
    dUp:Dec(Shots[I].Pos.Y, SHOT_SPEED);
    dDown:Inc(Shots[I].Pos.Y, SHOT_SPEED);
    dLeft:Dec(Shots[I].Pos.X, SHOT_SPEED);
    dRight:Inc(Shots[I].Pos.X, SHOT_SPEED);
   End;
   If (Shots[I].Pos.X < 20) or (Shots[I].Pos.X > SCREEN_WIDTH-20) or
      (Shots[I].Pos.Y < 20) or (Shots[I].Pos.Y > SCREEN_HEIGHT-20) Then
    Shots[I].Active := False;
  End;

  { Mise … jour des robots }
 For I := 1 to MAX_ROBOTS do
  If Robots[I].Active Then Begin
   If Robots[I].Pos.X < PlayerX Then Inc(Robots[I].Pos.X, ROBOT_SPEED)
   Else If Robots[I].Pos.X > PlayerX Then Dec(Robots[I].Pos.X, ROBOT_SPEED);
   If Robots[I].Pos.Y < PlayerY Then Inc(Robots[I].Pos.Y, ROBOT_SPEED)
   Else If Robots[I].Pos.Y > PlayerY Then Dec(Robots[I].Pos.Y, ROBOT_SPEED);

    { Collision avec les tirs }
   For J := 1 to MAX_SHOTS do If Shots[J].Active Then
    If Abs(Shots[J].Pos.X - Robots[I].Pos.X) < 10 Then
     If Abs(Shots[J].Pos.Y - Robots[I].Pos.Y) < 10 Then Begin
      Robots[I].Active := False;
      Shots[J].Active := False;
      Inc(Score, 50);
     End;

     { Collision avec le joueur }
   If Abs(PlayerX - Robots[I].Pos.X) < 10 Then
    If Abs(PlayerY - Robots[I].Pos.Y) < 10 Then Begin
    Dec(Lives);
    If Lives <= 0 Then GameOver := True;
    PlayerX := SCREEN_WIDTH div 2;
    PlayerY := SCREEN_HEIGHT div 2;
   End;
 End;
End;

Procedure DrawIntroPlayer(X, Y: Integer; Dir: TDirection);Begin
 SetColor(Yellow);
 Circle(X, Y-8, 4);
 Line(X, Y-4, X, Y+4);
 Case Dir of
  dRight: Begin
   Line(X, Y, X+6, Y-4);
   Line(X, Y, X+6, Y+4);
  End;
  dLeft: Begin
   Line(X, Y, X-6, Y-4);
   Line(X, Y, X-6, Y+4);
  End;
 End;
 Line(X, Y+4, X-5, Y+12);
 Line(X, Y+4, X+5, Y+12);
End;

Procedure ShowIntroScreen;
Var
  PlayerPos, RobotPos: Integer;
  Frame, I: Integer;
  AnimDelay: Integer;
Begin
  AnimDelay := 5;
  ClearDevice;

  { Titre }
  SetTextStyle(TriplexFont, HorizDir, 6);
  SetTextJustify(CenterText, TopText);
  SetColor(LightRed);
  OutTextXY(SCREEN_WIDTH div 2, 50, 'BERZERK');

  { Instructions }
  SetTextStyle(DefaultFont, HorizDir, 1);
  SetColor(LightGreen);
  OutTextXY(SCREEN_WIDTH div 2, 280, 'Contr“les:');
  OutTextXY(SCREEN_WIDTH div 2, 300, 'Touches de flŠches: D‚placer le joueur');
  OutTextXY(SCREEN_WIDTH div 2, 320, 'Barre d''espace: Tirer');
  OutTextXY(SCREEN_WIDTH div 2, 340, 'ESC: Quitter');

  SetColor(Yellow);
  OutTextXY(SCREEN_WIDTH div 2, 400, 'Appuyez sur une touche pour commencer');

  { Animation }
  For Frame := 1 to 100 do Begin
    SetViewPort(200, 150, 440, 250, True);
    ClearViewPort;

    PlayerPos := 50 + Frame;
    RobotPos := 200 - Frame;

    DrawIntroPlayer(PlayerPos, 50, dRight);

    { Dessiner un robot }
    If Frame mod 20 < 10 Then Begin
      DrawRobot(RobotPos, 50);

      { Dessiner le tir si on est dans la bonne frame }
      If Frame mod 20 = 5 Then Begin
        SetColor(Yellow);
        For I := PlayerPos to RobotPos do Begin
          Line(I, 50, I+4, 50);
          Delay(AnimDelay);
        End;
        SetColor(Red);
        Circle(RobotPos, 50, 10);
        Circle(RobotPos, 50, 12);
        Delay(AnimDelay * 2);
   End;
  End;
  Delay(AnimDelay);
 End;
 SetViewPort(0, 0, SCREEN_WIDTH-1, SCREEN_HEIGHT-1, True);
 ReadKey;
End;

BEGIN
 InitScreen;
 ShowIntroScreen;
 If Not InitGame Then Halt(1);
 Repeat
  HandleInput;
  UpdateGame;
  ClearDevice;
  DrawRoom;
  DrawPlayer;
  For I:=1 to MAX_ROBOTS do If Robots[I].Active Then
   DrawRobot(Robots[I].Pos.X, Robots[I].Pos.Y);
  For I := 1 to MAX_SHOTS do
   If Shots[I].Active Then
    DrawShot(Shots[I].Pos.X, Shots[I].Pos.Y);
  SetColor(White);
  OutTextXY(10, 10, 'Pointage : ' + IntToStr(Score));
  OutTextXY(SCREEN_WIDTH-80, 10, 'Vies : ' + IntToStr(Lives));
  If GameOver Then
   OutTextXY(SCREEN_WIDTH div 2 - 50, SCREEN_HEIGHT div 2, 'Partie terminÃ©e!');
  Delay(50);
 Until GameOver;
 CloseGraph;
END.
