{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)

  Clone du jeu d'arcade BurgerTime (Data East, 1982). Le joueur
  Peter Pepper parcourt un labyrinthe de plateformes et d'echelles
  pour faire tomber les ingredients de hamburger sur les assiettes.
  Inspire du portage IsaacValdivia/burgertime.

  Touches :
   - Fleches : deplacement (haut/bas sur les echelles)
   - Espace  : poivre (etourdit les ennemis)
   - Echap   : quitter

  Pour gagner : faire tomber les 16 ingredients sur les 4 assiettes.
  Marcher sur les 4 segments d'un ingredient le fait chuter d'un etage.
  Un ingredient qui tombe ecrase les ennemis qu'il traverse.
}

Program BurgerTime;

{$R-}

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Const
 GW = 20;
 GH = 14;
 TW = 32;
 TH = 32;
 HUDH = 32;
 SCR_W = GW*TW;
 SCR_H = GH*TH+HUDH;

 NSTACKS = 4;
 NLAYERS = 4;
 INGW    = 4;
 N_INGS  = NSTACKS*NLAYERS;

 MAX_ENEMIES = 5;
 PEPPER_FRAMES = 60;
 INVULN_FRAMES = 90;

 ING_BUN_TOP = 0;
 ING_LETTUCE = 1;
 ING_PATTY   = 2;
 ING_BUN_BOT = 3;

 EN_HOTDOG = 0;
 EN_EGG    = 1;
 EN_PICKLE = 2;

 PLATE_ROW = 13;

 Level: Array[0..GH-1] of String[GW] = (
  '....................',
  '====================',
  '..H....H....H....H..',
  '..H....H....H....H..',
  '====================',
  '..H....H....H....H..',
  '..H....H....H....H..',
  '====================',
  '..H....H....H....H..',
  '..H....H....H....H..',
  '====================',
  '..H....H....H....H..',
  '..H....H....H....H..',
  '===================='
 );

Type
 TIngredient = Record
  Active:Boolean;
  Stack:Byte;
  Layer:Byte;
  Col:Integer;
  YPx:Integer;
  Stomp:Array[0..3]of Byte;
  Falling:Boolean;
  OnPlate:Boolean;
  Riders:Byte;
  ExtraDrop:Byte;
 End;

 TEnemy = Record
  Active:Boolean;
  EType:Byte;
  X,Y:Integer;
  DX,DY:ShortInt;
  Stunned:Integer;
  Squashed:Boolean;
 End;

Var
 Score,HiScore:LongInt;
 Lives,Peppers:Integer;
 GameOver,Quit,LevelWon:Boolean;
 PlayerX,PlayerY:Integer;
 PDir:ShortInt;
 PAnim:Integer;
 PInvuln:Integer;
 PepperActive:Integer;
 PepperX,PepperY:Integer;
 PepperDir:ShortInt;
 Ingredients:Array[1..N_INGS]of TIngredient;
 Enemies:Array[1..MAX_ENEMIES]of TEnemy;
 EnemySpawnTimer:Integer;
 EnemiesKilled:Integer;
 Frame:LongInt;

 { Pour double buffering / dirty rectangles }
 FirstRender:Boolean;
 PrevPlayerX,PrevPlayerY:Integer;
 PrevPlayerInvulnHide:Boolean;
 PrevEnemyActive:Array[1..MAX_ENEMIES]of Boolean;
 PrevEnemyX,PrevEnemyY:Array[1..MAX_ENEMIES]of Integer;
 PrevPepperActive:Boolean;
 PrevPepperX,PrevPepperY:Integer;
 PrevIngYPx:Array[1..N_INGS]of Integer;
 PrevIngStomp:Array[1..N_INGS,0..3]of Byte;
 PrevScore,PrevHi:LongInt;
 PrevLives,PrevPeppers:Integer;

{ ===================== UTILS ===================== }

Function IntToStr(V:LongInt):String;
Var S:String[12];
Begin
 Str(V,S);
 IntToStr:=S;
End;

Function PadStr(V:LongInt;W:Integer):String;
Var S:String[12];
Begin
 Str(V,S);
 While Length(S)<W do S:='0'+S;
 PadStr:=S;
End;

Procedure ClrKbd;Begin
 While KeyPressed do ReadKey;
End;

Function At(R,C:Integer):Char;
Begin
 If(R<0)Or(R>=GH)Or(C<0)Or(C>=GW)Then At:='.'
 Else At:=Level[R][C+1];
End;

Function IsPlatform(R,C:Integer):Boolean;
Begin
 IsPlatform:=At(R,C)='=';
End;

Function IsLadder(R,C:Integer):Boolean;
Begin
 IsLadder:=At(R,C)='H';
End;

Function PlatformY(R:Integer):Integer;
Begin
 PlatformY:=R*TH+HUDH;
End;

Function ColX(C:Integer):Integer;
Begin
 ColX:=C*TW;
End;

Function FeetRow(Y:Integer):Integer;
Begin
 FeetRow:=(Y-HUDH) Div TH;
End;

Function FeetCol(X:Integer):Integer;
Begin
 FeetCol:=X Div TW;
End;

{ ===================== INIT GFX ===================== }

Procedure InitScreen;
Var Driver,Mode,Err:Integer;
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
End;

{ ===================== DRAWING ===================== }

Procedure DrawTilePlatform(X,Y:Integer);
Begin
 SetFillStyle(SolidFill,Brown);
 Bar(X,Y,X+TW-1,Y+5);
 SetColor(Yellow);
 Line(X,Y,X+TW-1,Y);
 SetColor(LightGray);
 Line(X,Y+5,X+TW-1,Y+5);
End;

Procedure DrawTileLadder(X,Y:Integer);
Var I:Integer;
Begin
 SetColor(LightGray);
 Line(X+TW Div 2-7,Y,X+TW Div 2-7,Y+TH-1);
 Line(X+TW Div 2+7,Y,X+TW Div 2+7,Y+TH-1);
 For I:=0 to 4 do
  Line(X+TW Div 2-7,Y+I*7+2,X+TW Div 2+7,Y+I*7+2);
End;

Procedure DrawLevel;
Var R,C,X,Y:Integer;
Begin
 SetFillStyle(SolidFill,Black);
 Bar(0,HUDH,SCR_W-1,SCR_H-1);
 For R:=0 to GH-1 do
  For C:=0 to GW-1 do Begin
   X:=ColX(C); Y:=PlatformY(R);
   Case At(R,C) of
    '=':DrawTilePlatform(X,Y);
    'H':DrawTileLadder(X,Y);
   End;
  End;
 { Assiettes au pied de chaque pile }
 For C:=0 to NSTACKS-1 do Begin
  X:=ColX(2+C*5)-4;
  Y:=PlatformY(PLATE_ROW)+6;
  SetFillStyle(SolidFill,White);
  Bar(X,Y,X+INGW*TW+8,Y+10);
  SetColor(LightGray);
  Rectangle(X,Y,X+INGW*TW+8,Y+10);
 End;
End;

Procedure DrawIngredientPiece(X,Y:Integer;IType:Byte;Seg:Byte);
Var Col1,Col2:Integer;
Begin
 Case IType of
  ING_BUN_TOP:Begin Col1:=Brown; Col2:=Yellow; End;
  ING_LETTUCE:Begin Col1:=LightGreen; Col2:=Green; End;
  ING_PATTY  :Begin Col1:=Red; Col2:=Brown; End;
  ING_BUN_BOT:Begin Col1:=Brown; Col2:=Yellow; End;
 Else Col1:=White; Col2:=LightGray;
 End;
 SetFillStyle(SolidFill,Col1);
 Case IType of
  ING_BUN_TOP:Begin
   Bar(X,Y+8,X+TW-1,Y+TH-4);
   Bar(X+2,Y+5,X+TW-3,Y+8);
   PutPixel(X+6,Y+10,Yellow);
   PutPixel(X+14,Y+8,Yellow);
   PutPixel(X+22,Y+11,Yellow);
   SetColor(Col2);
   Line(X,Y+TH-4,X+TW-1,Y+TH-4);
  End;
  ING_LETTUCE:Begin
   { Corps principal en vert clair }
   Bar(X,Y+8,X+TW-1,Y+TH-5);
   { Bord superieur ondule (feuilles frisees) }
   SetFillStyle(SolidFill,LightGreen);
   { 4 bosses arrondies sur le dessus }
   Bar(X+1,Y+5,X+5,Y+8);
   PutPixel(X,Y+7,LightGreen); PutPixel(X+6,Y+7,LightGreen);
   Bar(X+9,Y+4,X+13,Y+8);
   PutPixel(X+8,Y+6,LightGreen); PutPixel(X+14,Y+6,LightGreen);
   Bar(X+17,Y+5,X+21,Y+8);
   PutPixel(X+16,Y+7,LightGreen); PutPixel(X+22,Y+7,LightGreen);
   Bar(X+25,Y+4,X+29,Y+8);
   PutPixel(X+24,Y+6,LightGreen); PutPixel(X+30,Y+6,LightGreen);
   { Veines/nervures vert fonce a l'interieur }
   SetColor(Green);
   Line(X+3,Y+10,X+5,Y+13);
   Line(X+11,Y+9,X+13,Y+13);
   Line(X+19,Y+10,X+21,Y+13);
   Line(X+27,Y+9,X+29,Y+13);
   { Reflets vert plus clair pour relief }
   PutPixel(X+2,Y+9,LightGreen);
   PutPixel(X+10,Y+8,LightGreen);
   PutPixel(X+18,Y+9,LightGreen);
   PutPixel(X+26,Y+8,LightGreen);
   { Bordure inferieure : bord ondule aussi }
   SetColor(Green);
   Line(X,Y+TH-5,X+TW-1,Y+TH-5);
   PutPixel(X+4,Y+TH-4,Green);
   PutPixel(X+12,Y+TH-4,Green);
   PutPixel(X+20,Y+TH-4,Green);
   PutPixel(X+28,Y+TH-4,Green);
  End;
  ING_PATTY:Begin
   Bar(X,Y+8,X+TW-1,Y+TH-6);
   SetColor(Brown);
   Rectangle(X,Y+8,X+TW-1,Y+TH-6);
   PutPixel(X+8,Y+12,Yellow);
   PutPixel(X+20,Y+14,Yellow);
  End;
  ING_BUN_BOT:Begin
   Bar(X,Y+6,X+TW-1,Y+TH-4);
   SetColor(Col2);
   Line(X,Y+6,X+TW-1,Y+6);
   Line(X,Y+TH-4,X+TW-1,Y+TH-4);
  End;
 End;
 If Seg=1 Then Begin
  SetColor(Black);
  Line(X,Y+4,X+TW-1,Y+4);
 End;
End;

Procedure DrawIngredient(I:Integer);
Var Sg,X,Y,YOff:Integer;
Begin
 With Ingredients[I] do
  If Active Then
   For Sg:=0 to 3 do Begin
    X:=ColX(Col+Sg);
    YOff:=0;
    If(Stomp[Sg]=1)And(Not Falling)Then YOff:=4;
    Y:=YPx+YOff;
    DrawIngredientPiece(X,Y,Layer,Stomp[Sg]);
   End;
End;

Procedure DrawPlayer;
Var BodyX,FeetY,Step:Integer;
Begin
 If(PInvuln>0)And((PInvuln And 4)<>0)Then Exit;
 BodyX:=PlayerX;
 FeetY:=PlayerY;
 Step:=(PAnim Shr 2)And 1;
 SetFillStyle(SolidFill,White);
 Bar(BodyX-7,FeetY-26,BodyX+7,FeetY-22);
 SetColor(White);
 FillEllipse(BodyX,FeetY-28,8,4);
 SetColor(Yellow);
 SetFillStyle(SolidFill,Yellow);
 FillEllipse(BodyX,FeetY-19,5,4);
 PutPixel(BodyX-2,FeetY-20,Black);
 PutPixel(BodyX+2,FeetY-20,Black);
 SetFillStyle(SolidFill,White);
 Bar(BodyX-6,FeetY-15,BodyX+6,FeetY-7);
 SetFillStyle(SolidFill,Blue);
 Bar(BodyX-6,FeetY-7,BodyX+6,FeetY-2);
 SetColor(Yellow);
 If PDir>0 Then Begin
  Line(BodyX+6,FeetY-13,BodyX+9,FeetY-10);
  Line(BodyX-6,FeetY-13,BodyX-8,FeetY-10);
 End Else Begin
  Line(BodyX-6,FeetY-13,BodyX-9,FeetY-10);
  Line(BodyX+6,FeetY-13,BodyX+8,FeetY-10);
 End;
 SetColor(Black);
 If Step=0 Then Begin
  Line(BodyX-3,FeetY-2,BodyX-5,FeetY);
  Line(BodyX+3,FeetY-2,BodyX+3,FeetY);
 End Else Begin
  Line(BodyX-3,FeetY-2,BodyX-3,FeetY);
  Line(BodyX+3,FeetY-2,BodyX+5,FeetY);
 End;
End;

Procedure DrawEnemy(I:Integer);
Var X,Y:Integer;
Begin
 With Enemies[I] do Begin
  If Not Active Then Exit;
  X:=Enemies[I].X;
  Y:=Enemies[I].Y;
  If Stunned>0 Then Begin
   SetColor(Yellow);
   PutPixel(X-7,Y-22,Yellow);
   PutPixel(X+7,Y-22,Yellow);
   PutPixel(X,Y-26,White);
  End;
  Case EType of
   EN_HOTDOG:Begin
    SetFillStyle(SolidFill,Red);
    Bar(X-10,Y-18,X+10,Y-6);
    SetColor(Brown);
    Rectangle(X-10,Y-18,X+10,Y-6);
    Line(X-7,Y-6,X-7,Y);
    Line(X-2,Y-6,X-2,Y);
    Line(X+3,Y-6,X+3,Y);
    Line(X+8,Y-6,X+8,Y);
    PutPixel(X-5,Y-15,White);
    PutPixel(X+5,Y-15,White);
   End;
   EN_EGG:Begin
    SetColor(White);
    SetFillStyle(SolidFill,White);
    FillEllipse(X,Y-12,10,9);
    SetColor(Yellow);
    SetFillStyle(SolidFill,Yellow);
    FillEllipse(X,Y-12,5,4);
    SetColor(Brown);
    Line(X-5,Y-3,X-5,Y);
    Line(X+5,Y-3,X+5,Y);
    PutPixel(X-3,Y-14,Black);
    PutPixel(X+3,Y-14,Black);
   End;
   EN_PICKLE:Begin
    SetColor(Green);
    SetFillStyle(SolidFill,Green);
    FillEllipse(X,Y-12,10,9);
    SetColor(LightGreen);
    Line(X-6,Y-14,X+6,Y-14);
    Line(X-6,Y-10,X+6,Y-10);
    SetColor(Brown);
    Line(X-5,Y-3,X-5,Y);
    Line(X+5,Y-3,X+5,Y);
    PutPixel(X-3,Y-13,White);
    PutPixel(X+3,Y-13,White);
   End;
  End;
 End;
End;

Procedure DrawPepper;
Var I:Integer;
Begin
 If PepperActive<=0 Then Exit;
 For I:=0 to 7 do
  PutPixel(PepperX+Random(20)-10,PepperY+Random(16)-8,White);
 For I:=0 to 5 do
  PutPixel(PepperX+Random(24)-12,PepperY+Random(16)-8,LightGray);
End;

Procedure DrawHUD;
Var I:Integer;
Begin
 SetFillStyle(SolidFill,Black);
 Bar(0,0,SCR_W-1,HUDH-1);
 SetColor(White);
 OutTextXY(8,8,'1UP');
 SetColor(LightRed);
 OutTextXY(8,18,PadStr(Score,6));
 SetColor(White);
 OutTextXY(SCR_W Div 2-30,8,'HI');
 SetColor(LightRed);
 OutTextXY(SCR_W Div 2-30,18,PadStr(HiScore,6));
 SetColor(White);
 OutTextXY(SCR_W-180,8,'POIVRE');
 OutTextXY(SCR_W-180,18,IntToStr(Peppers));
 OutTextXY(SCR_W-100,8,'VIES');
 SetFillStyle(SolidFill,Yellow);
 For I:=1 to Lives do
  Bar(SCR_W-100+I*14,18,SCR_W-100+I*14+10,26);
End;

{ ===================== INGREDIENTS ===================== }

Procedure InitIngredients;
Var S,L,Idx:Integer;
Begin
 Idx:=0;
 For S:=0 to NSTACKS-1 do
  For L:=0 to NLAYERS-1 do Begin
   Inc(Idx);
   With Ingredients[Idx] do Begin
    Active:=True;
    Stack:=S;
    Layer:=L;
    Col:=2+S*5-1;
    If Col<0 Then Col:=0;
    If Col+INGW>GW Then Col:=GW-INGW;
    Stomp[0]:=0; Stomp[1]:=0; Stomp[2]:=0; Stomp[3]:=0;
    Falling:=False;
    OnPlate:=False;
    Riders:=0;
    ExtraDrop:=0;
    YPx:=PlatformY(1+L*3)-(TH-4);
   End;
  End;
End;

Function IngredientStackedYAt(R,Col,ExceptIdx:Integer):Integer;
Var I,TopY,Best,RefY,DY:Integer;
Begin
 RefY:=PlatformY(R)-(TH-4);
 Best:=RefY;
 For I:=1 to N_INGS do
  If(I<>ExceptIdx)And Ingredients[I].Active And Ingredients[I].OnPlate Then
   If(Col>=Ingredients[I].Col)And(Col<Ingredients[I].Col+INGW)Then Begin
    { K doit etre pose sur cette plateforme : YPx <= RefY (pas plus    }
    { bas que le niveau plateforme) ET pas plus haut qu'une pile de    }
    { NLAYERS ingredients au-dessus de RefY. Ca exclut les OnPlate des }
    { plateformes superieures (qui feraient remonter le calcul).       }
    DY:=RefY-Ingredients[I].YPx;
    If(DY>=0)And(DY<=NLAYERS*(TH-4))Then Begin
     TopY:=Ingredients[I].YPx-(TH-4);
     If TopY<Best Then Best:=TopY;
    End;
   End;
 IngredientStackedYAt:=Best;
End;

Procedure CheckAndStartFalling(I:Integer);
Var AllStomped:Boolean;Sg:Integer;
Begin
 With Ingredients[I] do Begin
  If Falling Then Exit;
  AllStomped:=True;
  For Sg:=0 to 3 do If Stomp[Sg]=0 Then AllStomped:=False;
  If AllStomped Then Begin
   Falling:=True;
   OnPlate:=False;
   ExtraDrop:=Riders;
   Riders:=0;
   Inc(Score,50);
  End;
 End;
End;

Procedure UpdateFallingIngredients;
Var I,J,K,Sg,R:Integer;StopY:Integer;
    Ex,Ey:Integer;NextR:Integer;
    PushedSomething:Boolean;
Begin
 For I:=1 to N_INGS do
  With Ingredients[I] do
   If Active And Falling Then Begin
    Inc(YPx,4);
    NextR:=PLATE_ROW;
    For J:=0 to GH-1 do
     If IsPlatform(J,Col+1)And(PlatformY(J)>YPx+TH-8)Then Begin
      NextR:=J;
      Break;
     End;
    R:=NextR;
    StopY:=IngredientStackedYAt(R,Col+1,I);
    If YPx>=StopY Then Begin
     { Avant de poser, verifier s'il y a un autre ingredient    }
     { (deja pose ou non) sur la plateforme cible. Si oui, le   }
     { faire tomber aussi - cascade BurgerTime.                  }
     PushedSomething:=False;
     For K:=1 to N_INGS do
      If(K<>I)And Ingredients[K].Active And(Not Ingredients[K].Falling)And
        (Ingredients[K].Col=Col)And(R<PLATE_ROW)And
        (Abs(Ingredients[K].YPx-(PlatformY(R)-(TH-4)))<TH)Then Begin
       For Sg:=0 to 3 do Ingredients[K].Stomp[Sg]:=1;
       Ingredients[K].Falling:=True;
       Ingredients[K].OnPlate:=False;
       Ingredients[K].ExtraDrop:=0;
       PushedSomething:=True;
      End;
     If PushedSomething Then Begin
      { On a pousse - on continue de tomber }
      YPx:=PlatformY(R)-(TH-4);
     End Else Begin
      YPx:=StopY;
      If(ExtraDrop>0)And(R<PLATE_ROW)Then Begin
       Dec(ExtraDrop);
       Inc(YPx,4);
      End Else Begin
       Falling:=False;
       OnPlate:=True;
       For Sg:=0 to 3 do Stomp[Sg]:=0;
       Inc(Score,100);
      End;
     End;
    End;
    For J:=1 to MAX_ENEMIES do
     If Enemies[J].Active And(Not Enemies[J].Squashed)Then Begin
      Ex:=Enemies[J].X;
      Ey:=Enemies[J].Y;
      If(Ex>=ColX(Col))And(Ex<ColX(Col+INGW))And
        (Ey>=YPx)And(Ey<=YPx+TH+4)Then Begin
       Enemies[J].Squashed:=True;
       Enemies[J].Active:=False;
       Inc(EnemiesKilled);
       Inc(Score,500);
       Inc(Riders);
      End;
     End;
   End;
End;

Procedure StompCheck;
Var I,Sg,Ix,Iy:Integer;
Begin
 For I:=1 to N_INGS do
  With Ingredients[I] do
   If Active And(Not Falling)Then Begin
    { Un ingredient pose sur une plateforme intermediaire (pas sur }
    { l'assiette du sol) peut etre re-stomp pour le faire retomber }
    { vers le bas - c'est ainsi qu'on construit le hamburger.       }
    If OnPlate And(YPx>=PlatformY(PLATE_ROW)-(TH-4)-2)Then Continue;
    Iy:=YPx;
    If(PlayerY>=Iy)And(PlayerY<=Iy+TH+2)Then Begin
     For Sg:=0 to 3 do Begin
      Ix:=ColX(Col+Sg);
      If(PlayerX>=Ix)And(PlayerX<Ix+TW)Then
       If Stomp[Sg]=0 Then Begin
        Stomp[Sg]:=1;
        Inc(Score,10);
       End;
     End;
     CheckAndStartFalling(I);
    End;
   End;
End;

Function AllIngredientsOnPlate:Boolean;
Var I,FloorY:Integer;OK:Boolean;
Begin
 OK:=True;
 FloorY:=PlatformY(PLATE_ROW)-(TH-4);
 For I:=1 to N_INGS do
  If Ingredients[I].Active Then
   If(Not Ingredients[I].OnPlate)Or(Ingredients[I].YPx<FloorY-TH)Then OK:=False;
 AllIngredientsOnPlate:=OK;
End;

{ ===================== ENEMIES ===================== }

Procedure SpawnEnemy;
Var I,Slot:Integer;
Begin
 Slot:=0;
 For I:=1 to MAX_ENEMIES do
  If(Slot=0)And(Not Enemies[I].Active)Then Slot:=I;
 If Slot=0 Then Exit;
 With Enemies[Slot] do Begin
  Active:=True;
  EType:=Random(3);
  Squashed:=False;
  Stunned:=0;
  If Random(2)=0 Then Begin
   X:=ColX(0)+TW Div 2;
   DX:=1;
  End Else Begin
   X:=ColX(GW-1)+TW Div 2;
   DX:=-1;
  End;
  Y:=PlatformY(1);
  DY:=0;
 End;
End;

Procedure UpdateEnemies;
Var I,R,C:Integer;DistX,DistY:Integer;
Begin
 For I:=1 to MAX_ENEMIES do
  With Enemies[I] do
   If Active Then Begin
    If Stunned>0 Then Begin
     Dec(Stunned);
     Continue;
    End;
    R:=FeetRow(Y);
    C:=FeetCol(X);
    DistX:=PlayerX-X;
    DistY:=PlayerY-Y;
    If(Y=PlatformY(R))And IsPlatform(R,C)Then Begin
     If(DistY<-TH Div 2)And IsLadder(R-1,C)And((X-ColX(C)-TW Div 2)>=-2)And((X-ColX(C)-TW Div 2)<=2)Then Begin
      DY:=-1; DX:=0;
     End
     Else If(DistY>TH Div 2)And IsLadder(R,C)And(R<GH-1)And((X-ColX(C)-TW Div 2)>=-2)And((X-ColX(C)-TW Div 2)<=2)Then Begin
      DY:=1; DX:=0;
     End
     Else Begin
      DY:=0;
      If(DistY<-TH Div 2)And(Random(20)<8)Then Begin
       { se diriger vers la plus proche echelle montante }
       If IsLadder(R-1,C-1)Or IsLadder(R-1,C-2)Or IsLadder(R-1,C-3)Then DX:=-1
       Else If IsLadder(R-1,C+1)Or IsLadder(R-1,C+2)Or IsLadder(R-1,C+3)Then DX:=1;
      End
      Else If(DistY>TH Div 2)And(Random(20)<8)Then Begin
       If IsLadder(R,C-1)Or IsLadder(R,C-2)Or IsLadder(R,C-3)Then DX:=-1
       Else If IsLadder(R,C+1)Or IsLadder(R,C+2)Or IsLadder(R,C+3)Then DX:=1;
      End
      Else Begin
       If DistX>2 Then DX:=1
       Else If DistX<-2 Then DX:=-1
       Else DX:=0;
      End;
     End;
    End
    Else Begin
     If DY=0 Then Begin
      If DistY<0 Then DY:=-1 Else DY:=1;
     End;
    End;
    If DY<>0 Then Begin
     Inc(Y,DY);
     If((Y-HUDH) Mod TH)=0 Then Begin
      R:=FeetRow(Y);
      If IsPlatform(R,C)Then Begin
       DY:=0;
       Y:=PlatformY(R);
      End;
     End;
     If(DY=-1)And(Y<=PlatformY(0))Then Begin
      Y:=PlatformY(1); DY:=0;
     End;
    End
    Else If DX<>0 Then Begin
     If(C+DX>=0)And(C+DX<GW)And IsPlatform(R,C+DX)Then
      Inc(X,DX)
     Else
      DX:=-DX;
     If X<8 Then Begin X:=8; DX:=1; End;
     If X>SCR_W-8 Then Begin X:=SCR_W-8; DX:=-1; End;
    End;
   End;
End;

{ ===================== PLAYER ===================== }

Procedure InitPlayer;
Begin
 PlayerX:=ColX(0)+TW Div 2;
 PlayerY:=PlatformY(13);
 PDir:=1;
 PAnim:=0;
 PepperActive:=0;
End;

Procedure FirePepper;
Begin
 If(Peppers<=0)Or(PepperActive>0)Then Exit;
 Dec(Peppers);
 PepperActive:=12;
 PepperX:=PlayerX+PDir*16;
 PepperY:=PlayerY-12;
 PepperDir:=PDir;
End;

Procedure UpdatePepper;
Var I:Integer;
Begin
 If PepperActive<=0 Then Exit;
 Dec(PepperActive);
 For I:=1 to MAX_ENEMIES do
  If Enemies[I].Active And(Enemies[I].Stunned<=0)Then
   If(Abs(Enemies[I].X-PepperX)<18)And(Abs(Enemies[I].Y-PepperY-10)<20)Then Begin
    Enemies[I].Stunned:=PEPPER_FRAMES;
    Inc(Score,100);
   End;
End;

Procedure HandlePlayerInput;
Var Ch,Ch2:Char;R,C,DC,LC:Integer;OnPlat:Boolean;DidMove:Boolean;
Begin
 DidMove:=False;
 R:=FeetRow(PlayerY);
 C:=FeetCol(PlayerX);
 OnPlat:=(PlayerY=PlatformY(R))And IsPlatform(R,C);
 While KeyPressed do Begin
  Ch:=ReadKey;
  If Ch=#0 Then Begin
   Ch2:=ReadKey;
   Case Ch2 of
    #75:Begin
     If OnPlat And IsPlatform(R,C-1)Then Begin
      Dec(PlayerX,2); PDir:=-1; DidMove:=True;
     End
     Else If(Not OnPlat)And IsLadder(R,C)And(PlayerX>ColX(C)+TW Div 2)Then Begin
      Dec(PlayerX,2); PDir:=-1; DidMove:=True;
     End;
    End;
    #77:Begin
     If OnPlat And IsPlatform(R,C+1)Then Begin
      Inc(PlayerX,2); PDir:=1; DidMove:=True;
     End
     Else If(Not OnPlat)And IsLadder(R,C)And(PlayerX<ColX(C)+TW Div 2)Then Begin
      Inc(PlayerX,2); PDir:=1; DidMove:=True;
     End;
    End;
    #72:Begin { haut }
     If OnPlat Then Begin
      { Chercher l'echelle dans la colonne actuelle ou voisines }
      LC:=-99;
      For DC:=0 to 2 do Begin
       If IsLadder(R-1,C-DC)Then Begin LC:=C-DC; Break; End;
       If(DC>0)And IsLadder(R-1,C+DC)Then Begin LC:=C+DC; Break; End;
      End;
      If LC<>-99 Then Begin
       PlayerX:=ColX(LC)+TW Div 2;
       Dec(PlayerY,2); DidMove:=True;
      End;
     End
     Else If(Not OnPlat)And(IsLadder(R,C)Or IsLadder(R+1,C))And(PlayerY>PlatformY(0))Then Begin
      Dec(PlayerY,2); DidMove:=True;
     End;
    End;
    #80:Begin { bas }
     If OnPlat And(R<GH-1)Then Begin
      LC:=-99;
      For DC:=0 to 2 do Begin
       If IsLadder(R+1,C-DC)Then Begin LC:=C-DC; Break; End;
       If(DC>0)And IsLadder(R+1,C+DC)Then Begin LC:=C+DC; Break; End;
      End;
      If LC<>-99 Then Begin
       PlayerX:=ColX(LC)+TW Div 2;
       Inc(PlayerY,2); DidMove:=True;
      End;
     End
     Else If(Not OnPlat)And(IsLadder(R,C)Or IsLadder(R-1,C)Or IsLadder(R+1,C))Then Begin
      Inc(PlayerY,2); DidMove:=True;
     End;
    End;
   End;
  End
  Else Case Ch of
   #27:Quit:=True;
   #32:FirePepper;
   'p','P':FirePepper;
  End;
 End;
 If DidMove Then Inc(PAnim);
 If PlayerX<8 Then PlayerX:=8;
 If PlayerX>SCR_W-8 Then PlayerX:=SCR_W-8;
End;

Procedure CheckPlayerEnemyCollide;
Var I:Integer;
Begin
 If PInvuln>0 Then Exit;
 For I:=1 to MAX_ENEMIES do
  If Enemies[I].Active And(Not Enemies[I].Squashed)Then
   If(Abs(Enemies[I].X-PlayerX)<14)And(Abs(Enemies[I].Y-PlayerY)<22)Then Begin
    Dec(Lives);
    InitPlayer;
    PInvuln:=INVULN_FRAMES;
    If Lives<=0 Then GameOver:=True;
    Exit;
   End;
End;

{ ===================== GAME LOOP ===================== }

Procedure InitGame;
Var I:Integer;
Begin
 Score:=0;
 Lives:=3;
 Peppers:=5;
 GameOver:=False;
 LevelWon:=False;
 EnemySpawnTimer:=0;
 EnemiesKilled:=0;
 Frame:=0;
 PInvuln:=0;
 InitIngredients;
 For I:=1 to MAX_ENEMIES do Enemies[I].Active:=False;
 InitPlayer;
 FirstRender:=True;
End;

Procedure RestoreBackground(X1,Y1,X2,Y2:Integer);
Var R,C,I,Sg,X,Y,PX,PY:Integer;
Begin
 If X1<0 Then X1:=0; If Y1<HUDH Then Y1:=HUDH;
 If X2>=SCR_W Then X2:=SCR_W-1; If Y2>=SCR_H Then Y2:=SCR_H-1;
 If(X1>=X2)Or(Y1>=Y2)Then Exit;
 SetFillStyle(SolidFill,Black);
 Bar(X1,Y1,X2,Y2);
 { Tiles concernees }
 For R:=(Y1-HUDH) Div TH-1 to (Y2-HUDH) Div TH+1 do
  For C:=X1 Div TW-1 to X2 Div TW+1 do
   If(R>=0)And(R<GH)And(C>=0)And(C<GW)Then Begin
    X:=ColX(C); Y:=PlatformY(R);
    If(X+TW-1>=X1)And(X<=X2)And(Y+TH-1>=Y1)And(Y<=Y2)Then
     Case At(R,C) of
      '=':DrawTilePlatform(X,Y);
      'H':DrawTileLadder(X,Y);
     End;
   End;
 { Assiettes }
 For C:=0 to NSTACKS-1 do Begin
  X:=ColX(2+C*5)-4;
  Y:=PlatformY(PLATE_ROW)+6;
  If(X+INGW*TW+8>=X1)And(X<=X2)And(Y+10>=Y1)And(Y<=Y2)Then Begin
   SetFillStyle(SolidFill,White);
   Bar(X,Y,X+INGW*TW+8,Y+10);
   SetColor(LightGray);
   Rectangle(X,Y,X+INGW*TW+8,Y+10);
  End;
 End;
 { Ingredients qui chevauchent }
 For I:=1 to N_INGS do
  With Ingredients[I] do
   If Active Then Begin
    PX:=ColX(Col); PY:=YPx;
    If(PX+INGW*TW>=X1)And(PX<=X2)And(PY+TH>=Y1)And(PY<=Y2)Then
     For Sg:=0 to 3 do Begin
      X:=ColX(Col+Sg);
      DrawIngredientPiece(X,PY+(Ord((Stomp[Sg]=1)And(Not Falling))*4),Layer,Stomp[Sg]);
     End;
   End;
End;

Procedure RenderFrame;
Var I,Sg:Integer;IngChanged:Boolean;
    PlayerHidden:Boolean;
Begin
 If FirstRender Then Begin
  SetFillStyle(SolidFill,Black);
  Bar(0,0,SCR_W-1,SCR_H-1);
  DrawHUD;
  DrawLevel;
  For I:=1 to N_INGS do DrawIngredient(I);
  For I:=1 to MAX_ENEMIES do DrawEnemy(I);
  DrawPlayer;
  DrawPepper;
  FirstRender:=False;
 End Else Begin
  { Effacer joueur a l'ancienne position }
  RestoreBackground(PrevPlayerX-12,PrevPlayerY-32,PrevPlayerX+12,PrevPlayerY+2);
  { Effacer ennemis a leurs anciennes positions }
  For I:=1 to MAX_ENEMIES do
   If PrevEnemyActive[I]Then
    RestoreBackground(PrevEnemyX[I]-14,PrevEnemyY[I]-22,PrevEnemyX[I]+14,PrevEnemyY[I]+2);
  { Effacer poivre }
  If PrevPepperActive Then
   RestoreBackground(PrevPepperX-14,PrevPepperY-12,PrevPepperX+14,PrevPepperY+10);
  { Ingredients qui ont change }
  For I:=1 to N_INGS do
   If Ingredients[I].Active Then Begin
    IngChanged:=Ingredients[I].YPx<>PrevIngYPx[I];
    If Not IngChanged Then
     For Sg:=0 to 3 do
      If Ingredients[I].Stomp[Sg]<>PrevIngStomp[I,Sg]Then IngChanged:=True;
    If IngChanged Then Begin
     { Effacer la zone englobant ancienne et nouvelle position }
     RestoreBackground(ColX(Ingredients[I].Col)-2,
       PrevIngYPx[I]-2,ColX(Ingredients[I].Col+INGW)+2,
       PrevIngYPx[I]+TH+8);
     RestoreBackground(ColX(Ingredients[I].Col)-2,
       Ingredients[I].YPx-2,ColX(Ingredients[I].Col+INGW)+2,
       Ingredients[I].YPx+TH+8);
    End;
   End;
  { HUD si change }
  If(Score<>PrevScore)Or(HiScore<>PrevHi)Or(Lives<>PrevLives)Or(Peppers<>PrevPeppers)Then
   DrawHUD;
  { Sprites aux nouvelles positions }
  For I:=1 to MAX_ENEMIES do DrawEnemy(I);
  PlayerHidden:=(PInvuln>0)And((PInvuln And 4)<>0);
  If Not PlayerHidden Then DrawPlayer;
  DrawPepper;
 End;
 { Sauver etat }
 PrevPlayerX:=PlayerX;
 PrevPlayerY:=PlayerY;
 PrevPlayerInvulnHide:=(PInvuln>0)And((PInvuln And 4)<>0);
 For I:=1 to MAX_ENEMIES do Begin
  PrevEnemyActive[I]:=Enemies[I].Active;
  PrevEnemyX[I]:=Enemies[I].X;
  PrevEnemyY[I]:=Enemies[I].Y;
 End;
 PrevPepperActive:=PepperActive>0;
 PrevPepperX:=PepperX;
 PrevPepperY:=PepperY;
 For I:=1 to N_INGS do Begin
  PrevIngYPx[I]:=Ingredients[I].YPx;
  For Sg:=0 to 3 do PrevIngStomp[I,Sg]:=Ingredients[I].Stomp[Sg];
 End;
 PrevScore:=Score; PrevHi:=HiScore;
 PrevLives:=Lives; PrevPeppers:=Peppers;
End;

Procedure ShowMessage(Const M:String;Col:Integer);
Var Ch:Char;
Begin
 SetFillStyle(SolidFill,Black);
 Bar(SCR_W Div 2-150,SCR_H Div 2-30,SCR_W Div 2+150,SCR_H Div 2+30);
 SetColor(Col);
 Rectangle(SCR_W Div 2-150,SCR_H Div 2-30,SCR_W Div 2+150,SCR_H Div 2+30);
 SetTextStyle(DefaultFont,HorizDir,2);
 OutTextXY(SCR_W Div 2-Length(M)*8,SCR_H Div 2-8,M);
 SetTextStyle(DefaultFont,HorizDir,1);
 ClrKbd;
 Ch:=ReadKey;
 If Ch=#0 Then Ch:=ReadKey;
 If Ch=#27 Then Quit:=True;
End;

Procedure ShowTitle;
Var Ch:Char;
Begin
 SetFillStyle(SolidFill,Black);
 Bar(0,0,SCR_W-1,SCR_H-1);
 SetColor(Yellow);
 SetTextStyle(DefaultFont,HorizDir,4);
 OutTextXY(SCR_W Div 2-200,80,'BURGER  TIME');
 SetTextStyle(DefaultFont,HorizDir,1);
 SetColor(LightRed);
 OutTextXY(SCR_W Div 2-160,160,'Clone de Burger Time');
 SetColor(White);
 OutTextXY(SCR_W Div 2-130,210,'Fleches  : Deplacer / Echelles');
 OutTextXY(SCR_W Div 2-130,225,'Espace   : Lancer du poivre');
 OutTextXY(SCR_W Div 2-130,240,'Echap    : Quitter');
 SetColor(LightGreen);
 OutTextXY(SCR_W Div 2-180,290,'Marchez sur les 4 segments d''un');
 OutTextXY(SCR_W Div 2-180,305,'ingredient pour le faire tomber !');
 OutTextXY(SCR_W Div 2-180,335,'Faites tomber les 16 ingredients');
 OutTextXY(SCR_W Div 2-180,350,'sur les 4 assiettes pour gagner.');
 SetColor(Yellow);
 OutTextXY(SCR_W Div 2-130,400,'Appuyez sur une touche...');
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
   HandlePlayerInput;
   If Quit Then Break;
   StompCheck;
   UpdateFallingIngredients;
   UpdatePepper;
   Inc(EnemySpawnTimer);
   If(EnemySpawnTimer>=120)And(EnemiesKilled<8)Then Begin
    SpawnEnemy;
    EnemySpawnTimer:=0;
   End;
   UpdateEnemies;
   CheckPlayerEnemyCollide;
   If PInvuln>0 Then Dec(PInvuln);
   RenderFrame;
   If AllIngredientsOnPlate Then LevelWon:=True;
   Delay(20);
  Until GameOver Or LevelWon Or Quit;
  If Score>HiScore Then HiScore:=Score;
  If GameOver Then ShowMessage('GAME OVER',LightRed)
  Else If LevelWon Then ShowMessage('NIVEAU REUSSI !',LightGreen);
 End;
 CloseGraph;
END.
