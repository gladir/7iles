{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Clone du jeu d'arcade 1942 (Capcom, 1984). Le joueur pilote un
                P-38 Lightning au-dessus du Pacifique et abat des avions ennemis
                qui descendent l'ecran.
  Touches :
   - Fleches gauche/droite/haut/bas : deplacement
   - Espace : tir
   - L : looping (esquive temporaire, 3 par vie)
   - Echap : quitter
}

Program _1942;

{$R-}

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Const
 MAX_ENEMIES   = 12;
 MAX_PSHOTS    = 8;
 MAX_ESHOTS    = 16;
 MAX_CLOUDS    = 10;
 PLAYER_SPEED  = 4;
 PSHOT_SPEED   = 7;
 ESHOT_SPEED   = 4;

 { Types d'ennemis }
 ET_FIGHTER = 0;  { petit chasseur, vol droit }
 ET_ZIGZAG  = 1;  { chasseur en zigzag }
 ET_BOMBER  = 2;  { gros bombardier (lent, plus de PV) }

Type
 TPoint = Record
  X,Y:Integer;
 End;

 TPShot = Record
  Active:Boolean;
  X,Y:Integer;
 End;

 TEShot = Record
  Active:Boolean;
  X,Y:Integer;
  DX,DY:Integer;
 End;

 TEnemy = Record
  Active:Boolean;
  EType:Byte;
  X,Y:Integer;
  HP:Byte;
  Phase:Integer;     { compteur d'animation/zigzag }
  FireDelay:Integer;
 End;

 TCloud = Record
  X,Y:Integer;
  Size:Byte;
 End;

Var
 PlayerX,PlayerY:Integer;
 Score,HiScore:LongInt;
 Lives,Loops:Integer;
 LoopTimer:Integer;       { > 0 = invuln�rable }
 GameOver,Quit:Boolean;
 ExpX,ExpY,ExpT:Integer;
 PShots:Array[1..MAX_PSHOTS]of TPShot;
 EShots:Array[1..MAX_ESHOTS]of TEShot;
 Enemies:Array[1..MAX_ENEMIES]of TEnemy;
 Clouds:Array[1..MAX_CLOUDS]of TCloud;
 Frame:LongInt;
 SpawnTimer:Integer;
 ScreenW,ScreenH:Integer;
 WaveScroll:Integer;

Function IntToStr(V:LongInt):String;
Var S:String[12];
Begin
 Str(V,S);
 IntToStr:=S;
End;

Procedure ClrKbd;Begin
 While KeyPressed do ReadKey;
End;

Procedure InitScreen;
Var
 Driver,Mode,Err:Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA; Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect; Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
 Err:=GraphResult;
 If Err<>grOk Then Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(Err));
  Halt(1);
 End;
 ScreenW:=GetMaxX;
 ScreenH:=GetMaxY;
End;

{ ----- Dessins ----- }

Procedure DrawPlayer(X,Y:Integer;Blink:Boolean);
Var Body:Integer;
Begin
 If Blink Then Body:=DarkGray Else Body:=LightGray;
 SetColor(Body);
 SetFillStyle(SolidFill,Body);
 { Fuselage }
 Bar(X-2,Y-12,X+2,Y+12);
 { Aile principale }
 Bar(X-15,Y-2,X+15,Y+3);
 { Stabilisateur arri�re }
 Bar(X-7,Y+8,X+7,Y+11);
 { Cockpit }
 SetColor(LightBlue);
 SetFillStyle(SolidFill,LightBlue);
 Bar(X-2,Y-6,X+2,Y-2);
 { Nez et h�lice }
 SetColor(Yellow);
 Line(X-4,Y-12,X+4,Y-12);
 SetColor(White);
 Line(X-6,Y-13,X+6,Y-13);
 { �toile US sur les ailes }
 SetColor(White);
 PutPixel(X-10,Y,White);
 PutPixel(X+10,Y,White);
End;

Procedure DrawFighter(X,Y:Integer);
Begin
 SetColor(LightRed);
 SetFillStyle(SolidFill,LightRed);
 { Fuselage point� vers le bas }
 Bar(X-2,Y-8,X+2,Y+10);
 Bar(X-12,Y-2,X+12,Y+2);
 Bar(X-6,Y-8,X+6,Y-4);
 { Cockpit }
 PutPixel(X,Y,Black);
 PutPixel(X-1,Y,Black);
 PutPixel(X+1,Y,Black);
 { Hinomaru }
 PutPixel(X-8,Y,White);
 PutPixel(X+8,Y,White);
End;

Procedure DrawZigZag(X,Y:Integer);
Begin
 SetColor(LightMagenta);
 SetFillStyle(SolidFill,LightMagenta);
 Bar(X-2,Y-7,X+2,Y+8);
 Bar(X-10,Y-1,X+10,Y+3);
 SetColor(Magenta);
 Line(X-10,Y+3,X-12,Y+6);
 Line(X+10,Y+3,X+12,Y+6);
 PutPixel(X,Y-7,Yellow);
End;

Procedure DrawBomber(X,Y:Integer);
Begin
 SetColor(Brown);
 SetFillStyle(SolidFill,Brown);
 Bar(X-4,Y-12,X+4,Y+14);
 Bar(X-22,Y-3,X+22,Y+4);
 Bar(X-10,Y-12,X+10,Y-6);
 Bar(X-12,Y+8,X+12,Y+12);
 SetColor(LightGray);
 Bar(X-2,Y-10,X+2,Y-6);
 PutPixel(X-15,Y,White);
 PutPixel(X+15,Y,White);
End;

Procedure DrawEnemy(I:Integer);
Begin
 With Enemies[I] do
  Case EType of
   ET_FIGHTER:DrawFighter(X,Y);
   ET_ZIGZAG :DrawZigZag(X,Y);
   ET_BOMBER :DrawBomber(X,Y);
  End;
End;

Procedure DrawPShot(X,Y:Integer);
Begin
 SetColor(Yellow);
 Line(X,Y,X,Y+5);
 PutPixel(X,Y+2,White);
End;

Procedure DrawEShot(X,Y:Integer);
Begin
 SetColor(LightCyan);
 Circle(X,Y,2);
 PutPixel(X,Y,White);
End;

Procedure DrawCloud(X,Y:Integer;Size:Byte);
Var R:Integer;
Begin
 R:=4+Size*2;
 SetColor(White);
 SetFillStyle(SolidFill,White);
 FillEllipse(X,Y,R,R Div 2);
 FillEllipse(X-R,Y+2,R Div 2,R Div 3);
 FillEllipse(X+R,Y+2,R Div 2,R Div 3);
End;

Procedure DrawExplosion(X,Y,T:Integer);
Var R:Integer;
Begin
 R:=(8-T)*3; If R<1 Then R:=1;
 SetColor(Yellow);
 Circle(X,Y,R);
 SetColor(LightRed);
 Circle(X,Y,R Div 2);
 PutPixel(X,Y,White);
End;

Procedure DrawHUD;
Var I:Integer;
Begin
 SetColor(White);
 OutTextXY(10,5,'1942');
 OutTextXY(60,5,'SCORE '+IntToStr(Score));
 OutTextXY(220,5,'HI '+IntToStr(HiScore));
 OutTextXY(360,5,'LOOPS '+IntToStr(Loops));
 OutTextXY(460,5,'VIES');
 SetFillStyle(SolidFill,LightGray);
 For I:=1 to Lives do Bar(510+I*15,5,510+I*15+10,12);
End;

{ ----- Logique ----- }

Procedure SpawnEnemy;
Var
 I:Integer;
 R:Integer;
Begin
 For I:=1 to MAX_ENEMIES do
  If Not Enemies[I].Active Then Begin
   Enemies[I].Active:=True;
   R:=Random(10);
   If R<6 Then Enemies[I].EType:=ET_FIGHTER
   Else If R<9 Then Enemies[I].EType:=ET_ZIGZAG
   Else Enemies[I].EType:=ET_BOMBER;
   Enemies[I].X:=20+Random(ScreenW-40);
   Enemies[I].Y:=-20;
   Enemies[I].Phase:=Random(360);
   Enemies[I].FireDelay:=30+Random(60);
   Case Enemies[I].EType of
    ET_FIGHTER:Enemies[I].HP:=1;
    ET_ZIGZAG :Enemies[I].HP:=1;
    ET_BOMBER :Enemies[I].HP:=4;
   End;
   Exit;
  End;
End;

Procedure FirePShot;
Var I:Integer;
Begin
 For I:=1 to MAX_PSHOTS do
  If Not PShots[I].Active Then Begin
   PShots[I].Active:=True;
   PShots[I].X:=PlayerX-6;
   PShots[I].Y:=PlayerY-14;
   { Tir double }
   If I<MAX_PSHOTS Then Begin
    PShots[I+1].Active:=True;
    PShots[I+1].X:=PlayerX+6;
    PShots[I+1].Y:=PlayerY-14;
   End;
   Exit;
  End;
End;

Procedure FireEShot(I:Integer);
Var J:Integer;DX,DY,Dist:Integer;
Begin
 For J:=1 to MAX_ESHOTS do
  If Not EShots[J].Active Then Begin
   EShots[J].Active:=True;
   EShots[J].X:=Enemies[I].X;
   EShots[J].Y:=Enemies[I].Y+10;
   { Vise approximativement le joueur }
   DX:=PlayerX-Enemies[I].X;
   DY:=PlayerY-Enemies[I].Y;
   Dist:=Abs(DX)+Abs(DY); If Dist=0 Then Dist:=1;
   EShots[J].DX:=(DX*ESHOT_SPEED) Div Dist;
   EShots[J].DY:=(DY*ESHOT_SPEED) Div Dist;
   If EShots[J].DY<1 Then EShots[J].DY:=1;
   Exit;
  End;
End;

Procedure InitClouds;
Var I:Integer;
Begin
 For I:=1 to MAX_CLOUDS do Begin
  Clouds[I].X:=Random(ScreenW);
  Clouds[I].Y:=Random(ScreenH);
  Clouds[I].Size:=Random(4);
 End;
End;

Procedure UpdateClouds;
Var I:Integer;
Begin
 For I:=1 to MAX_CLOUDS do Begin
  Inc(Clouds[I].Y,1+(Clouds[I].Size Div 2));
  If Clouds[I].Y>ScreenH+10 Then Begin
   Clouds[I].Y:=-10;
   Clouds[I].X:=Random(ScreenW);
   Clouds[I].Size:=Random(4);
  End;
 End;
End;

Procedure DrawClouds;
Var I:Integer;
Begin
 For I:=1 to MAX_CLOUDS do
  DrawCloud(Clouds[I].X,Clouds[I].Y,Clouds[I].Size);
End;

Procedure InitGame;
Var I:Integer;
Begin
 PlayerX:=ScreenW Div 2;
 PlayerY:=ScreenH-40;
 Score:=0;
 Lives:=3;
 Loops:=3;
 LoopTimer:=0;
 GameOver:=False;
 Quit:=False;
 ExpT:=0;
 Frame:=0;
 SpawnTimer:=0;
 WaveScroll:=0;
 For I:=1 to MAX_PSHOTS do PShots[I].Active:=False;
 For I:=1 to MAX_ESHOTS do EShots[I].Active:=False;
 For I:=1 to MAX_ENEMIES do Enemies[I].Active:=False;
 InitClouds;
End;

Procedure HitPlayer;
Begin
 If LoopTimer>0 Then Exit;
 ExpX:=PlayerX; ExpY:=PlayerY; ExpT:=8;
 Dec(Lives);
 LoopTimer:=60;
 If Lives<=0 Then GameOver:=True;
End;

Procedure UpdateEnemies;
Var I:Integer;
Begin
 For I:=1 to MAX_ENEMIES do
  If Enemies[I].Active Then With Enemies[I] do Begin
   Inc(Phase);
   Case EType of
    ET_FIGHTER:Inc(Y,3);
    ET_ZIGZAG :Begin
     Inc(Y,2);
     X:=X+(((Phase Mod 60)-30) Div 10);
    End;
    ET_BOMBER :Inc(Y,1);
   End;
   Dec(FireDelay);
   If(FireDelay<=0)And(Y>0)And(Y<ScreenH-60)Then Begin
    FireEShot(I);
    FireDelay:=40+Random(60);
   End;
   If(Y>ScreenH+20)Or(X<-30)Or(X>ScreenW+30)Then Active:=False;
  End;
End;

Procedure UpdatePShots;
Var I,J:Integer;Hit:Boolean;
Begin
 For I:=1 to MAX_PSHOTS do
  If PShots[I].Active Then Begin
   Dec(PShots[I].Y,PSHOT_SPEED);
   If PShots[I].Y<0 Then PShots[I].Active:=False
   Else Begin
    Hit:=False;
    For J:=1 to MAX_ENEMIES do
     If Enemies[J].Active And Not Hit Then
      If(Abs(PShots[I].X-Enemies[J].X)<14)And
        (Abs(PShots[I].Y-Enemies[J].Y)<12)Then Begin
       Dec(Enemies[J].HP);
       PShots[I].Active:=False;
       Hit:=True;
       If Enemies[J].HP=0 Then Begin
        Enemies[J].Active:=False;
        ExpX:=Enemies[J].X; ExpY:=Enemies[J].Y; ExpT:=8;
        Case Enemies[J].EType of
         ET_FIGHTER:Inc(Score,100);
         ET_ZIGZAG :Inc(Score,200);
         ET_BOMBER :Inc(Score,500);
        End;
       End;
      End;
   End;
  End;
End;

Procedure UpdateEShots;
Var I:Integer;
Begin
 For I:=1 to MAX_ESHOTS do
  If EShots[I].Active Then Begin
   Inc(EShots[I].X,EShots[I].DX);
   Inc(EShots[I].Y,EShots[I].DY);
   If(EShots[I].Y>ScreenH)Or(EShots[I].Y<0)Or
     (EShots[I].X<0)Or(EShots[I].X>ScreenW)Then EShots[I].Active:=False
   Else If(Abs(EShots[I].X-PlayerX)<10)And
          (Abs(EShots[I].Y-PlayerY)<12)Then Begin
    EShots[I].Active:=False;
    HitPlayer;
   End;
  End;
End;

Procedure CheckPlayerCollide;
Var I:Integer;
Begin
 If LoopTimer>0 Then Exit;
 For I:=1 to MAX_ENEMIES do
  If Enemies[I].Active Then
   If(Abs(Enemies[I].X-PlayerX)<16)And
     (Abs(Enemies[I].Y-PlayerY)<16)Then Begin
    Enemies[I].Active:=False;
    HitPlayer;
    Exit;
   End;
End;

Procedure DrawOcean;
Var
 Col,Row,X,Y,H:Integer;
 Cell:Word;
Begin
 SetFillStyle(SolidFill,Blue);
 Bar(0,0,ScreenW,ScreenH);
 { Vagues : petits traits clairs sur une grille pseudo-aléatoire }
 { défilant vers le bas pour donner l'illusion de mouvement.    }
 For Row:=-1 to (ScreenH Div 16)+1 do
  For Col:=0 to (ScreenW Div 24) do Begin
   { Hash déterministe (Col,Row) pour position stable. }
   Cell:=Word((Col*73+(Row+WaveScroll Div 4)*131+(Col And Row)*17) And $FFFF);
   X:=Col*24+(Cell And 15);
   Y:=Row*16+WaveScroll Mod 16+((Cell Shr 4) And 7);
   H:=(Cell Shr 7) And 3;
   Case H of
    0:Begin
     SetColor(LightBlue);
     Line(X,Y,X+4,Y);
    End;
    1:Begin
     SetColor(LightBlue);
     Line(X,Y,X+2,Y);
     Line(X+4,Y+1,X+6,Y+1);
    End;
    2:Begin
     SetColor(White);
     PutPixel(X,Y,White);
     PutPixel(X+1,Y,White);
     PutPixel(X+2,Y+1,LightBlue);
    End;
    3:Begin
     SetColor(LightBlue);
     Line(X+1,Y,X+3,Y);
     PutPixel(X+5,Y+1,LightBlue);
    End;
   End;
  End;
End;

Procedure DrawScene;
Var I:Integer;Blink:Boolean;
Begin
 DrawOcean;
 DrawClouds;
 For I:=1 to MAX_PSHOTS do
  If PShots[I].Active Then DrawPShot(PShots[I].X,PShots[I].Y);
 For I:=1 to MAX_ESHOTS do
  If EShots[I].Active Then DrawEShot(EShots[I].X,EShots[I].Y);
 For I:=1 to MAX_ENEMIES do
  If Enemies[I].Active Then DrawEnemy(I);
 If(LoopTimer<=0)Or((LoopTimer And 4)=0)Then Begin
  Blink:=LoopTimer>0;
  DrawPlayer(PlayerX,PlayerY,Blink);
 End;
 If ExpT>0 Then DrawExplosion(ExpX,ExpY,ExpT);
 DrawHUD;
End;

Procedure HandleInput;
Var Ch,Ch2:Char;
Begin
 While KeyPressed do Begin
  Ch:=ReadKey;
  If Ch=#0 Then Begin
   Ch2:=ReadKey;
   Case Ch2 of
    #75:Dec(PlayerX,PLAYER_SPEED);
    #77:Inc(PlayerX,PLAYER_SPEED);
    #72:Dec(PlayerY,PLAYER_SPEED);
    #80:Inc(PlayerY,PLAYER_SPEED);
   End;
  End
  Else Case Ch of
   #27:Quit:=True;
   #32:FirePShot;
   'l','L':If(Loops>0)And(LoopTimer<=0)Then Begin
    Dec(Loops);
    LoopTimer:=45;
   End;
  End;
 End;
 If PlayerX<15 Then PlayerX:=15;
 If PlayerX>ScreenW-15 Then PlayerX:=ScreenW-15;
 If PlayerY<30 Then PlayerY:=30;
 If PlayerY>ScreenH-15 Then PlayerY:=ScreenH-15;
End;

Procedure ShowTitle;
Var Ch:Char;
Begin
 SetFillStyle(SolidFill,Blue);
 Bar(0,0,ScreenW,ScreenH);
 SetColor(Yellow);
 SetTextStyle(DefaultFont,HorizDir,5);
 OutTextXY(ScreenW Div 2-80,80,'1942');
 SetTextStyle(DefaultFont,HorizDir,1);
 SetColor(White);
 OutTextXY(ScreenW Div 2-130,180,'Clone du jeu 1942 du jeu Capcom');
 OutTextXY(ScreenW Div 2-100,220,'Fleches  : Deplacer');
 OutTextXY(ScreenW Div 2-100,235,'Espace   : Tir');
 OutTextXY(ScreenW Div 2-100,250,'L        : Looping (esquive)');
 OutTextXY(ScreenW Div 2-100,265,'Echap    : Quitter');
 SetColor(LightGreen);
 OutTextXY(ScreenW Div 2-110,330,'Appuyez sur une touche...');
 ClrKbd;
 Ch:=ReadKey;
 If Ch=#0 Then Ch:=ReadKey;
 If Ch=#27 Then Quit:=True;
End;

Procedure ShowGameOver;
Var Ch:Char;
Begin
 SetColor(LightRed);
 SetTextStyle(DefaultFont,HorizDir,3);
 OutTextXY(ScreenW Div 2-130,ScreenH Div 2-30,'GAME OVER');
 SetTextStyle(DefaultFont,HorizDir,1);
 SetColor(White);
 OutTextXY(ScreenW Div 2-90,ScreenH Div 2+20,'Score final : '+IntToStr(Score));
 If Score>HiScore Then Begin
  HiScore:=Score;
  SetColor(Yellow);
  OutTextXY(ScreenW Div 2-90,ScreenH Div 2+40,'Nouveau record !');
 End;
 SetColor(LightGreen);
 OutTextXY(ScreenW Div 2-130,ScreenH Div 2+80,'R = rejouer, Echap = quitter');
 ClrKbd;
 Ch:=ReadKey;
 If Ch=#0 Then Ch:=ReadKey;
 If Ch=#27 Then Quit:=True;
End;

BEGIN
 Randomize;
 InitScreen;
 HiScore:=0;
 Quit:=False;
 ShowTitle;
 While Not Quit do Begin
  InitGame;
  Repeat
   Inc(Frame);
   Inc(WaveScroll);
   HandleInput;
   If Quit Then Break;
   UpdateClouds;
   UpdateEnemies;
   UpdatePShots;
   UpdateEShots;
   CheckPlayerCollide;
   If LoopTimer>0 Then Dec(LoopTimer);
   If ExpT>0 Then Dec(ExpT);
   Inc(SpawnTimer);
   If SpawnTimer>=25 Then Begin
    SpawnEnemy;
    SpawnTimer:=0;
   End;
   DrawScene;
   Delay(25);
  Until GameOver Or Quit;
  If Not Quit Then ShowGameOver;
 End;
 CloseGraph;
END.
