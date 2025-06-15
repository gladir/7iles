{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program PONG;

Uses {$IFDEF FPC}
      Crt,PtcCrt,PtcGraph,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  PADDLE_HEIGHT = 50;
  PADDLE_WIDTH = 10;
  BALL_SIZE = 8;
  PADDLE_SPEED = 5;
  BALL_SPEED = 4;

Var
  GraphDriver, GraphMode: Integer;
  PlayerY, ComputerY: Integer;
  BallX, BallY: Integer;
  BallDX, BallDY: Integer;
  PlayerScore, ComputerScore: Integer;
  QuitGame: Boolean;

  Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
 ErrCode:=GraphResult;
 If ErrCode=grOk Then Begin
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure InitializeGame;Begin
 PlayerY := GetMaxY Div 2;
 ComputerY := PlayerY;
 BallX := GetMaxX Div 2;
 BallY := GetMaxY Div 2;
 BallDX := BALL_SPEED;
 BallDY := BALL_SPEED;
 PlayerScore := 0;
 ComputerScore := 0;
 QuitGame := False;
End;

Procedure DrawPaddle(x,y:Integer);Begin
 Bar(x, y - PADDLE_HEIGHT Div 2, x + PADDLE_WIDTH, y + PADDLE_HEIGHT Div 2);
End;

Procedure DrawBall;Begin
 Bar(BallX - BALL_SIZE Div 2, BallY - BALL_SIZE Div 2,
     BallX + BALL_SIZE Div 2, BallY + BALL_SIZE Div 2);
End;

Procedure ShowScore;
Var
 ScoreStr:String;
Begin
 SetTextStyle(DefaultFont, HorizDir, 2);
 Str(PlayerScore, ScoreStr);
 OutTextXY(GetMaxX Div 4, 20,ScoreStr);
 Str(ComputerScore, ScoreStr);
 OutTextXY(3*GetMaxX Div 4,20,ScoreStr);
End;

Procedure MovePaddles;Begin
 If KeyPressed Then Case ReadKey Of
  #27: QuitGame:=True;
   #0:Case ReadKey Of
    #72:If PlayerY>PADDLE_HEIGHT Then Dec(PlayerY, PADDLE_SPEED);  { Haut }
    #80:If PlayerY<GetMaxY - PADDLE_HEIGHT Then Inc(PlayerY, PADDLE_SPEED);  { Down }
   End;
  End;
   { Simple AI for computer paddle }
  If BallY > ComputerY + PADDLE_HEIGHT Div 4 Then
   Inc(ComputerY, PADDLE_SPEED Div 2)
  Else If BallY < ComputerY - PADDLE_HEIGHT Div 4 Then
   Dec(ComputerY, PADDLE_SPEED Div 2);
End;

Procedure MoveBall;Begin
 BallX := BallX + BallDX;
 BallY := BallY + BallDY;
  { V‚rifie pour une collision avec le haut ou le bas }
 If(BallY <= 0)or(BallY>=GetMaxY)Then BallDY:=-BallDY;

  { V‚rifie pour une collision avec paddles }
  If(BallX <= PADDLE_WIDTH * 2)And
    (BallY >= PlayerY - PADDLE_HEIGHT Div 2)And
    (BallY <= PlayerY + PADDLE_HEIGHT Div 2)Then
     BallDX := BALL_SPEED
  Else If (BallX >= GetMaxX - PADDLE_WIDTH * 2) And
          (BallY >= ComputerY - PADDLE_HEIGHT Div 2) And
          (BallY <= ComputerY + PADDLE_HEIGHT Div 2) Then
    BallDX := -BALL_SPEED;

  { V‚rifie pour un but }
 If BallX<=0 Then Begin
  Inc(ComputerScore);
  BallX := GetMaxX Div 2;
  BallY := GetMaxY Div 2;
 End
  Else
 If BallX >= GetMaxX Then Begin
  Inc(PlayerScore);
  BallX := GetMaxX Div 2;
  BallY := GetMaxY Div 2;
 End;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 InitializeGraphics;
 InitializeGame;
 Repeat
  ClearDevice;
  DrawPaddle(10, PlayerY);
  DrawPaddle(GetMaxX-20,ComputerY);
  DrawBall;
  ShowScore;
  MovePaddles;
  MoveBall;
  Delay(20);
 Until QuitGame;
 CloseGraph;
END.