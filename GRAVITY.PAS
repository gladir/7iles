{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu Gravity - Contr√¥lez la gravit√© pour atteindre l'objectif
}

Program Gravity;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 LEVEL_WIDTH = 65;
 LEVEL_HEIGHT = 22;
 CELL_SIZE = 8;
 PLAYER_WIDTH = 5;
 PLAYER_HEIGHT = 3;

 MAX_LEVELS = 5;
 MAX_VELOCITY = 8;
 GRAVITY_FREQ = 2;
 SLIDE_FREQ = 4;

Type
 TDirection = (dirNone, dirUp, dirDown, dirLeft, dirRight);
 TGameState = (gsPlaying, gsDied, gsWon, gsComplete);
 TPlayerState = (psNeutral, psSliding, psSquash);

 TLevel=Array[0..LEVEL_HEIGHT-1,0..LEVEL_WIDTH-1] of Char;

 TPlayer=Record
  x,y:Integer;
  velX,velY:Integer;
  state:TPlayerState;
  slideDir:TDirection;
  squashDir:TDirection;
 End;

 TGame=Record
  level:Integer;
  currentLevel:TLevel;
  player:TPlayer;
  gravity:TDirection;
  gameState:TGameState;
  gravityCounter:Integer;
  slideCounter:Integer;
  needRedraw:Boolean;
 End;

Var
 Game:TGame;
 Levels:Array[0..MAX_LEVELS-1] of TLevel;

Procedure InitializeLevels;
Var
 i, j: Integer;
Begin
  { Niveau 1 - Simple introduction }
 FillChar(Levels[0], SizeOf(TLevel), ' ');
  { Bordures }
 FillChar(Levels[0][0], LEVEL_WIDTH, #219);
 FillChar(Levels[0][LEVEL_HEIGHT-1], LEVEL_WIDTH, #219);
  { Bordures verticales }
 For i:=0 to LEVEL_HEIGHT-1 do Begin
  Levels[0][i][0] := #219;
  Levels[0][i][LEVEL_WIDTH-1] := #219;
 End;
  { Position de dÇpart - Niveau 1: En bas Ö gauche }
 Levels[0][18][6] := '@';
 Levels[0][18][7] := '@';
 Levels[0][18][8] := '@';
 Levels[0][18][9] := '@';
 Levels[0][18][10] := '@';
 Levels[0][17][6] := '@';
 Levels[0][17][7] := '@';
 Levels[0][17][8] := '@';
 Levels[0][17][9] := '@';
 Levels[0][17][10] := '@';
 Levels[0][16][6] := '@';
 Levels[0][16][7] := '@';
 Levels[0][16][8] := '@';
 Levels[0][16][9] := '@';
 Levels[0][16][10] := '@';

 { Objectif }
 Levels[0][5][55] := #7; { Balle }
  { Niveau 2 - Avec obstacles }
 FillChar(Levels[1], SizeOf(TLevel), ' ');
  { Bordures }
 FillChar(Levels[1][0], LEVEL_WIDTH, #219);
 FillChar(Levels[1][LEVEL_HEIGHT-1], LEVEL_WIDTH, #219);
 For i:=0 to LEVEL_HEIGHT-1 do Begin
  Levels[1][i][0] := #219;
  Levels[1][i][LEVEL_WIDTH-1] := #219;
 End;
 { Plateforme centrale }
 For i:=20 to 40 do Levels[1][10][i] := #219;
  { Obstacles suppl√©mentaires }
 For i:=5 to 8 do Levels[1][i][15] := #219;
 For i:=14 to 17 do Levels[1][i][45] := #219;
  { Position de dÇpart - Niveau 2: Au milieu Ö gauche }
 Levels[1][12][6]:='@';
 Levels[1][12][7]:='@';
 Levels[1][12][8]:='@';
 Levels[1][12][9]:='@';
 Levels[1][12][10]:='@';
 Levels[1][11][6]:='@';
 Levels[1][11][7]:='@';
 Levels[1][11][8]:='@';
 Levels[1][11][9]:='@';
 Levels[1][11][10]:='@';
 Levels[1][10][6]:='@';
 Levels[1][10][7]:='@';
 Levels[1][10][8]:='@';
 Levels[1][10][9]:='@';
 Levels[1][10][10]:='@';
  { Objectif }
 Levels[1][3][55] := #7;
  { Niveau 3 - Avec piäges }
 FillChar(Levels[2], SizeOf(TLevel), ' ');
  { Bordures }
 FillChar(Levels[2][0],LEVEL_WIDTH,#219);
 FillChar(Levels[2][LEVEL_HEIGHT-1],LEVEL_WIDTH,#219);
 For i:=0 to LEVEL_HEIGHT-1 do Begin
  Levels[2][i][0]:=#219;
  Levels[2][i][LEVEL_WIDTH-1]:=#219;
 End;
 { Piäges }
 For i:=30 to 35 do Levels[2][15][i] := 'X';
 For i:=10 to 15 do Levels[2][8][i] := 'X';
  { Obstacles pour rendre plus difficile }
 For i:=20 to 30 do Levels[2][12][i] := #219;
 For i:=40 to 50 do Levels[2][10][i] := #219;
  { Position de dÇpart - Niveau 3: En haut Ö droite }
 Levels[2][5][58] := '@';
 Levels[2][5][59] := '@';
 Levels[2][5][60] := '@';
 Levels[2][5][61] := '@';
 Levels[2][5][62] := '@';
 Levels[2][4][58] := '@';
 Levels[2][4][59] := '@';
 Levels[2][4][60] := '@';
 Levels[2][4][61] := '@';
 Levels[2][4][62] := '@';
 Levels[2][3][58] := '@';
 Levels[2][3][59] := '@';
 Levels[2][3][60] := '@';
 Levels[2][3][61] := '@';
 Levels[2][3][62] := '@';
  { Objectif }
 Levels[2][18][5] := #7;
  { Niveau 4 - Avec murs commutables }
 FillChar(Levels[3], SizeOf(TLevel), ' ');
  { Bordures }
 FillChar(Levels[3][0], LEVEL_WIDTH, #219);
 FillChar(Levels[3][LEVEL_HEIGHT-1], LEVEL_WIDTH, #219);
 For i:=0 to LEVEL_HEIGHT-1 do Begin
  Levels[3][i][0] := #219;
  Levels[3][i][LEVEL_WIDTH-1] := #219;
 End;
  { Murs commutables }
 For i:=8 to 12 do Levels[3][i][30] := '#';
 For i:=14 to 18 do Levels[3][i][40] := '#';
 { Espaces commutables }
 For i:=25 to 35 do Levels[3][10][i] := '~';
 For i:=15 to 25 do Levels[3][6][i] := '~';
  { Quelques piäges }
 Levels[3][15][20]:='X';
 Levels[3][15][21]:='X';
 Levels[3][15][50]:='X';
 Levels[3][15][51]:='X';
  { Position de dÇpart - Niveau 4: Au centre }
 Levels[3][12][32]:='@';
 Levels[3][12][33]:='@';
 Levels[3][12][34]:='@';
 Levels[3][12][35]:='@';
 Levels[3][12][36]:='@';
 Levels[3][11][32]:='@';
 Levels[3][11][33]:='@';
 Levels[3][11][34]:='@';
 Levels[3][11][35]:='@';
 Levels[3][11][36]:='@';
 Levels[3][10][32]:='@';
 Levels[3][10][33]:='@';
 Levels[3][10][34]:='@';
 Levels[3][10][35]:='@';
 Levels[3][10][36]:='@';
  { Objectif }
 Levels[3][3][45] := #7;
  { Niveau 5 - Complexe }
 FillChar(Levels[4], SizeOf(TLevel), ' ');
  { Bordures }
 FillChar(Levels[4][0], LEVEL_WIDTH, #219);
 FillChar(Levels[4][LEVEL_HEIGHT-1], LEVEL_WIDTH, #219);
 For i:=0 to LEVEL_HEIGHT-1 do Begin
  Levels[4][i][0] := #219;
  Levels[4][i][LEVEL_WIDTH-1] := #219;
 End;
  { Labyrinthe }
 For i:=15 to 25 do Levels[4][8][i]:=#219;
 For i:=35 to 45 do Levels[4][8][i]:=#219;
 For i:=8 to 12 do Levels[4][i][25]:=#219;
 For i:=14 to 18 do Levels[4][i][35] := #219;
  { Murs commutables dans le labyrinthe }
 For i := 50 to 55 do Levels[4][10][i] := '#';
 For i := 12 to 16 do Levels[4][i][50] := '~';
  { Piäges }
 For i:=28 to 32 do Levels[4][15][i] := 'X';
 For i:=40 to 42 do Levels[4][6][i] := 'X';
 { Position de dÇpart - Niveau 5: En bas au centre }
 Levels[4][19][32]:='@';
 Levels[4][19][33]:='@';
 Levels[4][19][34]:='@';
 Levels[4][19][35]:='@';
 Levels[4][19][36]:='@';
 Levels[4][18][32]:='@';
 Levels[4][18][33]:='@';
 Levels[4][18][34]:='@';
 Levels[4][18][35]:='@';
 Levels[4][18][36]:='@';
 Levels[4][17][32]:='@';
 Levels[4][17][33]:='@';
 Levels[4][17][34]:='@';
 Levels[4][17][35]:='@';
 Levels[4][17][36]:='@';
  { Objectif }
 Levels[4][5][50] := #7;
End;

Procedure GetStartingPosition(Var p:TPlayer);
Var
 i,j:Integer;
Begin
 For i:=0 to LEVEL_HEIGHT-1 do For j:=0 to LEVEL_WIDTH-1 do If Game.currentLevel[i][j]='@'Then Begin
  p.x := j + 2;
  p.y := i + 1;
  p.velX := 0;
  p.velY := 0;
  p.state := psNeutral;
  p.slideDir := dirNone;
  p.squashDir := dirNone;
  Exit;
 End;
End;

Function IsWall(x,y:Integer):Boolean;
Var
 c:Char;
Begin
 If(x<0)or(x>=LEVEL_WIDTH)or(y < 0) or (y >= LEVEL_HEIGHT)Then Begin
  IsWall:=True;
  Exit;
 End;
 c:=Game.currentLevel[y][x];
 IsWall:=(c = #219)or(c='#');
End;

Function WallUp:Boolean;Begin
 WallUp:=IsWall(Game.player.x-2, Game.player.y-2) or
         IsWall(Game.player.x-1, Game.player.y-2) or
         IsWall(Game.player.x, Game.player.y-2) or
         IsWall(Game.player.x+1, Game.player.y-2) or
         IsWall(Game.player.x+2, Game.player.y-2);
End;

Function WallDown:Boolean;Begin
 WallDown:=IsWall(Game.player.x-2, Game.player.y+2) or
           IsWall(Game.player.x-1, Game.player.y+2) or
           IsWall(Game.player.x, Game.player.y+2) or
           IsWall(Game.player.x+1, Game.player.y+2) or
           IsWall(Game.player.x+2, Game.player.y+2);
End;

Function WallLeft:Boolean;Begin
 WallLeft:=IsWall(Game.player.x-3, Game.player.y-1) or
           IsWall(Game.player.x-3, Game.player.y) or
           IsWall(Game.player.x-3, Game.player.y+1);
End;

Function WallRight:Boolean;Begin
 WallRight:=IsWall(Game.player.x+3, Game.player.y-1) or IsWall(Game.player.x+3, Game.player.y)or
            IsWall(Game.player.x+3, Game.player.y+1);
End;

Procedure CheckCollisions;
Var
 i,j:Integer;
 c:Char;
Begin
 { VÇrifier les piäges dans toute la zone du joueur }
 For i := -1 to 1 do For j := -2 to 2 do Begin
   { VÇrifier que nous sommes dans les limites du niveau }
  If(Game.player.y + i>=0)and(Game.player.y + i < LEVEL_HEIGHT)and
    (Game.player.x + j>=0)and(Game.player.x + j < LEVEL_WIDTH)Then Begin
   c:=Game.currentLevel[Game.player.y + i][Game.player.x + j];
   Case c of
    'X': Game.gameState := gsDied;
   End;
  End;
 End;
  { VÇrifier l'objectif dans toute la zone du joueur }
 For i:=-1 to 1 do For j := -2 to 2 do Begin
   { VÇrifier que nous sommes dans les limites du niveau }
  If(Game.player.y + i >= 0)and(Game.player.y + i<LEVEL_HEIGHT)and
    (Game.player.x + j >= 0)and(Game.player.x + j<LEVEL_WIDTH)Then Begin
   c:=Game.currentLevel[Game.player.y + i][Game.player.x + j];
   If c=#7 Then Game.gameState:=gsWon;
  End;
 End;
End;

Procedure ToggleWalls;
Var
 i,j:Integer;
Begin
 For i:=0 to LEVEL_HEIGHT-1 do For j := 0 to LEVEL_WIDTH-1 do Case Game.currentLevel[i][j] of
  '#': Game.currentLevel[i][j] := '~';
  '~': Game.currentLevel[i][j] := '#';
 End;
End;

Procedure UpdatePlayer;
Var
 u,d,l,r:Integer;
 oldState:TPlayerState;
 canSlideUp,canSlideDown,canSlideLeft,canSlideRight:Boolean;
Begin
 oldState:=Game.player.state;
 Game.player.state:=psNeutral;
 { Appliquer la gravitÇ }
 Inc(Game.gravityCounter);
 If Game.gravityCounter>=GRAVITY_FREQ Then Begin
  Case Game.gravity of
   dirUp:Dec(Game.player.velY);
   dirDown:Inc(Game.player.velY);
   dirLeft:Dec(Game.player.velX);
   dirRight:Inc(Game.player.velX);
  End;
  Game.gravityCounter := 0;
 End;
 { Limiter la vÇlocitÇ }
 If Game.player.velX>MAX_VELOCITY Then Game.player.velX := MAX_VELOCITY;
 If Game.player.velX<-MAX_VELOCITY Then Game.player.velX := -MAX_VELOCITY;
 If Game.player.velY>MAX_VELOCITY Then Game.player.velY := MAX_VELOCITY;
 If Game.player.velY<-MAX_VELOCITY Then Game.player.velY := -MAX_VELOCITY;

 { Calculer le mouvement }
 If Game.player.velY<0 Then u := -Game.player.velY
                       Else u:=0;
 If Game.player.velY>0 Then d := Game.player.velY
                       Else d:=0;
 If Game.player.velX<0 Then l := -Game.player.velX
                       Else l:=0;
 If Game.player.velX>0 Then r := Game.player.velX
                       Else r:=0;
 { PrÇcalculer les conditions de glissement }
 canSlideUp:=(Game.player.velY < 0) and (((Game.gravity = dirLeft) and WallLeft) or
             ((Game.gravity = dirRight) and WallRight));
 canSlideDown:=(Game.player.velY > 0) and (((Game.gravity = dirLeft) and WallLeft) or
               ((Game.gravity = dirRight) and WallRight));
 canSlideLeft:=(Game.player.velX < 0) and (((Game.gravity = dirUp) and WallUp) or
               ((Game.gravity = dirDown) and WallDown));
 canSlideRight:=(Game.player.velX > 0) and (((Game.gravity = dirUp) and WallUp) or
                ((Game.gravity = dirDown) and WallDown));
 { GÇrer le glissement }
 If canSlideUp Then Begin
  Game.player.state:=psSliding;
  Game.player.slideDir:=dirUp;
  Inc(Game.slideCounter);
  If Game.slideCounter>=SLIDE_FREQ Then Begin
   Inc(Game.player.velY);
   Game.slideCounter := 0;
  End;
 End
  Else
 If canSlideDown Then Begin
  Game.player.state:=psSliding;
  Game.player.slideDir:=dirDown;
  Inc(Game.slideCounter);
  If Game.slideCounter>=SLIDE_FREQ Then Begin
   Dec(Game.player.velY);
   Game.slideCounter := 0;
  End;
 End
  Else
 If canSlideLeft Then Begin
  Game.player.state:=psSliding;
  Game.player.slideDir:=dirLeft;
  Inc(Game.slideCounter);
  If Game.slideCounter>=SLIDE_FREQ Then Begin
   Inc(Game.player.velX);
   Game.slideCounter := 0;
  End;
 End
  Else
 If canSlideRight Then Begin
  Game.player.state:=psSliding;
  Game.player.slideDir:=dirRight;
  Inc(Game.slideCounter);
  If Game.slideCounter>=SLIDE_FREQ Then Begin
   Dec(Game.player.velX);
   Game.slideCounter := 0;
  End;
 End
  Else
 Game.slideCounter := 0;
  { Appliquer le mouvement }
 While ((u > 0) or (d > 0) or (l > 0) or (r > 0))and(Game.gameState = gsPlaying) do Begin
  If u>0 Then Begin
   If WallUp Then Begin
    If u>1 Then Begin
     Game.player.state:=psSquash;
     Game.player.squashDir:=dirUp;
    End;
    Game.player.velY:=0;
    u:=0;
   End
    Else
   Begin
    Dec(Game.player.y);
    Dec(u);
   End;
  End;
  If d>0 Then Begin
   If WallDown Then Begin
    If d > 1 Then Begin
     Game.player.state:=psSquash;
     Game.player.squashDir:=dirDown;
    End;
    Game.player.velY:=0;
    d:=0;
   End
    Else
   Begin
    Inc(Game.player.y);
    Dec(d);
   End;
  End;
  If l>0 Then Begin
   If WallLeft Then Begin
    If l>1 Then Begin
     Game.player.state := psSquash;
     Game.player.squashDir := dirLeft;
    End;
    Game.player.velX:=0;
    l:=0;
   End
    Else
   Begin
    Dec(Game.player.x);
    Dec(l);
   End;
  End;
  If r>0 Then Begin
   If WallRight Then Begin
    If r>1 Then Begin
     Game.player.state:=psSquash;
     Game.player.squashDir:=dirRight;
    End;
    Game.player.velX:=0;
    r:=0;
   End
   Else
   Begin
    Inc(Game.player.x);
    Dec(r);
   End;
  End;
  CheckCollisions;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If(KeyPressed)Then Begin
  key:=ReadKey;
  Case key of
   #0:Begin
    key:=ReadKey;
    Case key of
     #72: If Game.gravity<>dirUp Then Begin { Fläche haut }
      Game.gravity:=dirUp;
      Game.gravityCounter:=GRAVITY_FREQ;
     End;
     #80:If Game.gravity<>dirDown Then Begin { Fläche bas }
      Game.gravity:=dirDown;
      Game.gravityCounter:=GRAVITY_FREQ;
     End;
     #75:If Game.gravity<>dirLeft Then Begin { Fläche gauche }
      Game.gravity:=dirLeft;
      Game.gravityCounter:=GRAVITY_FREQ;
     End;
     #77:If Game.gravity<>dirRight Then Begin { Fläche droite }
      Game.gravity := dirRight;
      Game.gravityCounter := GRAVITY_FREQ;
     End;
    End;
   End;
   'w','W':If Game.gravity<>dirUp Then Begin
    Game.gravity:=dirUp;
    Game.gravityCounter:=GRAVITY_FREQ;
   End;
   's','S':If Game.gravity<>dirDown Then Begin
    Game.gravity:=dirDown;
    Game.gravityCounter:=GRAVITY_FREQ;
   End;
   'a','A':If Game.gravity<>dirLeft Then Begin
    Game.gravity:=dirLeft;
    Game.gravityCounter:=GRAVITY_FREQ;
   End;
   'd','D':If Game.gravity<>dirRight Then Begin
    Game.gravity:=dirRight;
    Game.gravityCounter:=GRAVITY_FREQ;
   End;
   ' ':ToggleWalls;
   #27:Game.gameState:=gsComplete; { ESC }
  End;
  Game.needRedraw:=True;
 End;
End;

Procedure DrawCell(x,y:Integer;c:Char);
Var
 px,py:Integer;
Begin
 px:=x*CELL_SIZE+10;
 py:=y*CELL_SIZE+10;
 Case c of
  #219: Begin { Mur }
   SetColor(7);
   SetFillStyle(1, 7);
   Bar(px, py, px + CELL_SIZE - 1, py + CELL_SIZE - 1);
  End;
  '#': Begin { Mur commutable }
   SetColor(8);
   SetFillStyle(1, 8);
   Bar(px, py, px + CELL_SIZE - 1, py + CELL_SIZE - 1);
  End;
  '~': Begin { Espace commutable }
   SetColor(1);
   SetFillStyle(1, 1);
   Bar(px, py, px + CELL_SIZE - 1, py + CELL_SIZE - 1);
  End;
  'X': Begin { Piäge }
   SetColor(4);
   SetFillStyle(1, 4);
   Bar(px, py, px + CELL_SIZE - 1, py + CELL_SIZE - 1);
  End;
  #7: Begin { Objectif }
   SetColor(14);
   SetFillStyle(1, 14);
   FillEllipse(px + CELL_SIZE div 2, py + CELL_SIZE div 2, CELL_SIZE div 2, CELL_SIZE div 2);
  End;
  Else Begin { Espace libre }
   SetColor(0);
   SetFillStyle(1, 0);
   Bar(px, py, px + CELL_SIZE - 1, py + CELL_SIZE - 1);
  End;
 End;
End;

Procedure DrawPlayer;
Var
 px,py:Integer;
 color:Integer;
Begin
 px:=(Game.player.x-2)*CELL_SIZE+10;
 py:=(Game.player.y-1)*CELL_SIZE+10;
 Case Game.player.state of
  psSliding: color := 11;
  psSquash: color := 12;
  Else color := 10;
 End;
 SetColor(color);
 SetFillStyle(1,color);
 Bar(px,py,px+PLAYER_WIDTH*CELL_SIZE-1,py+PLAYER_HEIGHT*CELL_SIZE-1);
 SetColor(0);
 Rectangle(px, py, px + PLAYER_WIDTH * CELL_SIZE - 1, py + PLAYER_HEIGHT * CELL_SIZE - 1);
End;

Procedure DrawLevel;
Var
 i,j:Integer;
 c:Char;
Begin
 For i:=0 to LEVEL_HEIGHT-1 do For j:=0 to LEVEL_WIDTH-1 do Begin
  c:=Game.currentLevel[i][j];
  If c='@'Then c:=' ';
   { Ne pas dessiner par-dessus le joueur }
  If Not((Game.player.x - 2 <= j) and (Game.player.x + 2 >= j)and
         (Game.player.y - 1 <= i) and (Game.player.y + 1 >= i))Then DrawCell(j,i,c);
 End;
End;

Procedure DrawUI;
Var
 s:String;
 gravityChar:Char;
Begin
 SetColor(15);
 SetTextStyle(0,0,1);
 Str(Game.level+1,s);
 OutTextXY(10, LEVEL_HEIGHT*CELL_SIZE+20,'Niveau: ' + s);
 Case Game.gravity of
  dirNone: gravityChar := 'O';
  dirUp: gravityChar := '^';
  dirDown: gravityChar := 'v';
  dirLeft: gravityChar := '<';
  dirRight: gravityChar := '>';
 End;
 OutTextXY(150, LEVEL_HEIGHT * CELL_SIZE + 20, 'GravitÇ: ' + gravityChar);
 OutTextXY(10, LEVEL_HEIGHT * CELL_SIZE + 35, 'Fläches/W A S D: Changer gravitÇ');
 OutTextXY(10, LEVEL_HEIGHT * CELL_SIZE + 50, 'Espace: Basculer murs');
 OutTextXY(10, LEVEL_HEIGHT * CELL_SIZE + 65, 'ESC: Quitter');
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  { Fond noir }
  SetColor(0);
  SetFillStyle(1,0);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  DrawLevel;
  DrawPlayer;
  DrawUI;
  Game.needRedraw:=False;
 End;
End;

Procedure ShowInstructions;Begin
 SetColor(0);
 SetFillStyle(1,0);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0,0,2);
 OutTextXY(SCREEN_WIDTH div 2-80,50,'GRAVITY');
 SetTextStyle(0,0,1);
 OutTextXY(50, 120, 'Atteignez l''objectif ('+#7+') en contrìlant la gravitÇ.');
 OutTextXY(50, 140, 'Utilisez les fläches ou WASD pour changer la direction.');
 OutTextXY(50, 160, 'êvitez les piäges (X) qui vous tueront.');
 OutTextXY(50, 180, 'Appuyez sur ESPACE pour basculer les murs (#) et espaces (~).');
 OutTextXY(50, 200, 'Le joueur peut glisser le long des murs selon la gravitÇ.');
 OutTextXY(50, 250, 'Appuyez sur ENTRêE pour commencer...');
 OutTextXY(50, 270, 'ESC pour quitter Ö tout moment.');
 Repeat
  If KeyPressed Then Begin
   Case ReadKey of
    #13: Exit;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;
Begin
 Game.level := 0;
 Game.currentLevel := Levels[Game.level];
 GetStartingPosition(Game.player);
 Game.gravity := dirNone;
 Game.gameState := gsPlaying;
 Game.gravityCounter := 0;
 Game.slideCounter := 0;
 Game.needRedraw := True;
End;

Procedure NextLevel;
Begin
 Inc(Game.level);
 If Game.level >= MAX_LEVELS Then
  Game.gameState := gsComplete
 Else
 Begin
  Game.currentLevel := Levels[Game.level];
  GetStartingPosition(Game.player);
  Game.gravity := dirNone;
  Game.gameState := gsPlaying;
  Game.gravityCounter := 0;
  Game.slideCounter := 0;
  Game.needRedraw := True;
 End;
End;

Procedure RestartLevel;Begin
 Game.currentLevel:=Levels[Game.level];
 GetStartingPosition(Game.player);
 Game.gravity:=dirNone;
 Game.gameState:=gsPlaying;
 Game.gravityCounter:=0;
 Game.slideCounter:=0;
 Game.needRedraw:=True;
End;

Procedure GameLoop;
Var
 key:Char;
Begin
 While Game.gameState<>gsComplete do Begin
  Case Game.gameState of
   gsPlaying: Begin
    HandleInput;
    UpdatePlayer;
    Render;
   End;
   gsDied: Begin
    SetColor(12);
    SetTextStyle(0, 0, 2);
    OutTextXY(SCREEN_WIDTH div 2 - 80, SCREEN_HEIGHT div 2, 'VOUS ETES MORT!');
    SetTextStyle(0, 0, 1);
    OutTextXY(SCREEN_WIDTH div 2 - 100, SCREEN_HEIGHT div 2 + 30, 'Appuyez sur ENTRêE pour recommencer');
    Repeat
     If KeyPressed Then Begin
      key:=ReadKey;
      Case key of
       #13: Begin
        RestartLevel;
        Break;
       End;
       #27: Begin
        Game.gameState:=gsComplete;
        Break;
       End;
      End;
     End;
     Delay(50);
    Until False;
   End;
   gsWon:Begin
    SetColor(10);
    SetTextStyle(0, 0, 2);
    OutTextXY(SCREEN_WIDTH div 2 - 80, SCREEN_HEIGHT div 2, 'NIVEAU TERMINê!');
    SetTextStyle(0, 0, 1);
    OutTextXY(SCREEN_WIDTH div 2 - 100, SCREEN_HEIGHT div 2 + 30, 'Appuyez sur ENTRêE pour continuer');
    Repeat
     If KeyPressed Then Begin
      key:=ReadKey;
      Case key of
       #13: Begin
        NextLevel;
        Break;
       End;
       #27:Begin
        Game.gameState:=gsComplete;
        Break;
       End;
      End;
     End;
     Delay(50);
    Until False;
   End;
  End;
  Delay(50);
 End;
End;

Procedure InitializeGraphics;
Var
 Driver,Mode:Integer;
 ErrCode:Integer;
Begin
 {$IFDEF FPC}
  Driver := VGA;
  Mode := VGAHi;
 {$ELSE}
  Driver := Detect;
  Mode := VGAHi;
 {$ENDIF}
 InitGraph(Driver, Mode, '');
 ErrCode := GraphResult;
 If ErrCode <> grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
 SetLineStyle(0, 0, 1);
End;

BEGIN
 InitializeGraphics;
 InitializeLevels;
 ShowInstructions;
 InitializeGame;
  { Affichage final si tous les niveaux sont terminÇs }
 If Game.level>=MAX_LEVELS Then Begin
  SetColor(14);
  SetTextStyle(0, 0, 2);
  OutTextXY(SCREEN_WIDTH div 2 - 120, SCREEN_HEIGHT div 2, 'FêLICITATIONS!');
  SetTextStyle(0, 0, 1);
  OutTextXY(SCREEN_WIDTH div 2 - 150, SCREEN_HEIGHT div 2 + 30, 'Vous avez terminÇ tous les niveaux!');
  OutTextXY(SCREEN_WIDTH div 2 - 100, SCREEN_HEIGHT div 2 + 50, 'Appuyez sur une touche pour quitter');
  ReadKey;
 End
  Else
 GameLoop;
 CloseGraph;
END.