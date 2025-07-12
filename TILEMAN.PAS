{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de TileMan avec interface graphique
}

Program TileMan;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH=640;
 SCREEN_HEIGHT=480;
 GRID_SIZE=16;
 GRID_WIDTH=35;
 GRID_HEIGHT=25;
 START_X=(SCREEN_WIDTH - GRID_WIDTH * GRID_SIZE) div 2;
 START_Y=(SCREEN_HEIGHT - GRID_HEIGHT * GRID_SIZE) div 2;
 PLAYER_SIZE=8;
 INITIAL_LIVES=3;
 POINTS_PER_TILE=10;
 BONUS_THRESHOLD=75; { Pourcentage pour bonus }

Type
 TGameState=(gsMainMenu,gsPlaying,gsGameOver,gsPaused,gsQuit);
 TDirection=(dNone,dUp,dDown,dLeft,dRight);
 TTileState=(tsEmpty,tsOwned,tsTrail,tsWall);
 TGrid=Array[0..GRID_WIDTH-1, 0..GRID_HEIGHT-1] of TTileState;

 TPlayer=Record
  x,y:Integer;
  gridX,gridY:Integer;
  direction:TDirection;
  color:Integer;
  lives:Integer;
  score:LongInt;
  trailLength:Integer;
  inSafeZone:Boolean;
 End;

 TEnemy=Record
   x,y:Integer;
   gridX,gridY:Integer;
   direction:TDirection;
   color:Integer;
   speed:Integer;
   active:Boolean;
   moveCounter:Integer;
  End;

  TGame=Record
   gameState:TGameState;
   grid:TGrid;
   player:TPlayer;
   enemies:Array[0..3]of TEnemy;
   needRedraw:Boolean;
   message:String;
   messageTimer:Integer;
   level:Integer;
   percentageOwned:Real;
   targetPercentage:Real;
   gameTimer:Integer;
  End;

Var
 Game:TGame;

Function IntToStr(value:LongInt):String;
Var
 s:String;
Begin
 Str(value,s);
 IntToStr:=s;
End;

Function FloatToStr(value:Real;decimals:Integer):String;
Var
 s:String;
Begin
 Str(value:0:decimals,s);
 FloatToStr:=s;
End;

Procedure InitializeGrid;
Var
 x,y:Integer;
Begin
 For x:=0 to GRID_WIDTH-1 do For y := 0 to GRID_HEIGHT-1 do Begin
  { Cr‚er des murs sur les bords }
  If (x=0)or(x=GRID_WIDTH-1)or(y=0)or(y=GRID_HEIGHT-1)Then
   Game.grid[x,y]:=tsWall
  Else
   Game.grid[x,y]:=tsEmpty;
 End;
  { Cr‚er une zone de d‚part s‚curis‚e au centre }
 For x:=(GRID_WIDTH div 2)-2 to (GRID_WIDTH div 2)+2 do
 For y:=(GRID_HEIGHT div 2)-2 to (GRID_HEIGHT div 2)+2 do
  Game.grid[x,y]:=tsOwned;
End;

Procedure InitializePlayer;Begin
 Game.player.gridX:=GRID_WIDTH div 2;
 Game.player.gridY:=GRID_HEIGHT div 2;
 Game.player.x:=START_X+Game.player.gridX*GRID_SIZE;
 Game.player.y:=START_Y+Game.player.gridY*GRID_SIZE;
 Game.player.direction:=dNone;
 Game.player.color:=14; { Jaune }
 Game.player.lives:=INITIAL_LIVES;
 Game.player.score:=0;
 Game.player.trailLength:=0;
 Game.player.inSafeZone:=True;
End;

Procedure InitializeEnemies;
Var
 i:Integer;
Begin
 For i:=0 to 3 do Begin
  { Positionner les ennemis aux coins du terrain }
  Case i of
   0:Begin
    Game.enemies[i].gridX := 5;
    Game.enemies[i].gridY := 5;
   End;
   1:Begin
    Game.enemies[i].gridX := GRID_WIDTH - 6;
    Game.enemies[i].gridY := 5;
   End;
   2:Begin
    Game.enemies[i].gridX:=5;
    Game.enemies[i].gridY:=GRID_HEIGHT-6;
   End;
   3:Begin
    Game.enemies[i].gridX:=GRID_WIDTH-6;
    Game.enemies[i].gridY:=GRID_HEIGHT-6;
   End;
  End;
  Game.enemies[i].x:=START_X+Game.enemies[i].gridX*GRID_SIZE;
  Game.enemies[i].y:=START_Y+Game.enemies[i].gridY*GRID_SIZE;
  Game.enemies[i].direction := TDirection(Random(4)+1);
  Game.enemies[i].color:=12; { Rouge }
  Game.enemies[i].speed:=2 + Game.level;
  Game.enemies[i].active:=i < (Game.level+1);
  Game.enemies[i].moveCounter:=0;
 End;
End;

Function IsInSafeZone(gx,gy:Integer):Boolean;Begin
 If(gx>=0)and(gx<GRID_WIDTH)and(gy>=0)and(gy<GRID_HEIGHT)Then
  IsInSafeZone:=Game.grid[gx,gy]=tsOwned
 Else
  IsInSafeZone:=False;
End;

Function IsValidMove(gx,gy:Integer):Boolean;Begin
 IsValidMove:=(gx>=0)and(gx<GRID_WIDTH)and
              (gy>=0)and(gy<GRID_HEIGHT)and
              (Game.grid[gx,gy]<>tsWall);
End;

Procedure FloodFill(startX,startY:Integer;fillState:TTileState);
Var
 stack:Array[0..GRID_WIDTH * GRID_HEIGHT] of Record
  x,y:Integer;
 End;
 stackTop:Integer;
 x,y,nx,ny:Integer;
 dx,dy:Integer;
Begin
 If(startX<0)or(startX>=GRID_WIDTH)or(startY<0)or(startY>=GRID_HEIGHT)or
   (Game.grid[startX, startY] <> tsEmpty)Then Exit;
 stackTop:=0;
 stack[0].x:=startX;
 stack[0].y:=startY;
 While stackTop>=0 do Begin
  x:=stack[stackTop].x;
  y:=stack[stackTop].y;
  Dec(stackTop);
  If(x>=0)and(x<GRID_WIDTH)and(y>=0)and(y<GRID_HEIGHT)and(Game.grid[x,y]=tsEmpty)Then Begin
   Game.grid[x,y]:=fillState;
    { Ajouter les voisins … la pile }
   For dx:=-1 to 1 do For dy:=-1 to 1 do If(dx <> 0)or(dy <> 0)Then Begin
    nx := x + dx;
    ny := y + dy;
    If (nx >= 0)and(nx < GRID_WIDTH)and(ny >= 0)and(ny < GRID_HEIGHT)and
       (Game.grid[nx, ny] = tsEmpty)Then Begin
     Inc(stackTop);
     stack[stackTop].x := nx;
     stack[stackTop].y := ny;
    End;
   End;
  End;
 End;
End;

Procedure FloodFillTemp(startX,startY:Integer;fillState:TTileState;
                      Var tempGrid:TGrid);
Var
 stack:Array[0..GRID_WIDTH * GRID_HEIGHT] of Record
  x,y:Integer;
 End;
 stackTop: Integer;
 x, y, nx, ny: Integer;
 dx, dy: Integer;
Begin
  { V‚rifier les limites et s'arrˆter aux barriŠres }
 If(startX < 0)or(startX >= GRID_WIDTH)or
   (startY < 0)or(startY >= GRID_HEIGHT)or
   (tempGrid[startX, startY] <> tsEmpty)Then Exit;
 stackTop := 0;
 stack[0].x := startX;
 stack[0].y := startY;
 While stackTop>=0 do Begin
  x:=stack[stackTop].x;
  y:=stack[stackTop].y;
  Dec(stackTop);
   { V‚rifier que la case est vide et dans les limites }
  If (x >= 0) and (x < GRID_WIDTH) and(y >= 0) and (y < GRID_HEIGHT) and
     (tempGrid[x, y] = tsEmpty) Then Begin
    { Marquer cette case comme remplie }
   tempGrid[x, y] := fillState;
    { Ajouter les 4 voisins directs Ã  la pile }
   For dx := -1 to 1 do For dy := -1 to 1 do
    { Seulement les 4 directions cardinales }
    If ((dx = 0) and (dy <> 0)) or ((dx <> 0) and (dy = 0))Then Begin
     nx := x + dx;
     ny := y + dy;
      { V‚rifier que le voisin est dans les limites et vide }
     If(nx >= 0)and(nx < GRID_WIDTH)and(ny >= 0)and(ny < GRID_HEIGHT)and
       (tempGrid[nx, ny] = tsEmpty) Then Begin
      Inc(stackTop);
      If stackTop<GRID_WIDTH * GRID_HEIGHT Then Begin
       stack[stackTop].x := nx;
       stack[stackTop].y := ny;
      End;
     End;
    End;
   End;
  End;
End;

Function IsEnclosedByBlue(startX,startY:Integer):Boolean;
Var
 tempGrid:TGrid;
 i,j:Integer;
 reachedBorder:Boolean;
Begin
  { Copier la grille actuelle }
 For i := 0 to GRID_WIDTH-1 do For j := 0 to GRID_HEIGHT-1 do
  tempGrid[i, j] := Game.grid[i, j];
  { Faire un flood fill depuis cette position pour marquer toute la zone connectÃ©e }
  { Le flood fill s'arrÃªtera aux barriÃ¨res (tsOwned et tsWall) }
 FloodFillTemp(startX, startY, tsWall, tempGrid);

  { V‚rifier si le flood fill a atteint les bords de l'‚cran }
 reachedBorder:=False;
  { V‚rifier les bords horizontaux }
 For i:=0 to GRID_WIDTH-1 do Begin
  If tempGrid[i,0]=tsWall Then reachedBorder:=True;
  If tempGrid[i, GRID_HEIGHT-1]=tsWall Then reachedBorder := True;
 End;
  { V‚rifier les bords verticaux }
 For j:=0 to GRID_HEIGHT-1 do Begin
  If tempGrid[0, j]=tsWall Then reachedBorder:=True;
  If tempGrid[GRID_WIDTH-1,j]=tsWall Then reachedBorder := True;
 End;
  { Si le flood fill n'a pas atteint les bords, la zone est fermÃ©e }
 IsEnclosedByBlue:=Not reachedBorder;
End;

Procedure FloodFillCapture(startX, startY: Integer);
Var
 stack:Array[0..GRID_WIDTH * GRID_HEIGHT] of Record
  x,y:Integer;
 End;
 stackTop:Integer;
 x,y,nx,ny:Integer;
 dx,dy:Integer;
Begin
 If(startX < 0) or (startX >= GRID_WIDTH)or
   (startY < 0) or (startY >= GRID_HEIGHT)or
   (Game.grid[startX, startY] <> tsEmpty)Then Exit;
 stackTop:=0;
 stack[0].x:=startX;
 stack[0].y:=startY;
 While stackTop>=0 do Begin
  x:=stack[stackTop].x;
  y:=stack[stackTop].y;
  Dec(stackTop);
  If(x>=0)and(x<GRID_WIDTH)and
    (y>=0)and(y<GRID_HEIGHT)and
    (Game.grid[x, y] = tsEmpty)Then Begin
     { Capturer cette case }
   Game.grid[x, y] := tsOwned;
     { Ajouter les 4 voisins directs Ã  la pile }
    For dx:=-1 to 1 do For dy:=-1 to 1 do
     If ((dx = 0) and (dy <> 0)) or ((dx <> 0) and (dy = 0))Then Begin
    nx:=x+dx;
    ny:=y+dy;
    If(nx>=0)and(nx<GRID_WIDTH)and(ny >= 0) and (ny < GRID_HEIGHT) and
      (Game.grid[nx, ny]=tsEmpty)Then Begin
     Inc(stackTop);
     If stackTop<GRID_WIDTH * GRID_HEIGHT Then Begin
      stack[stackTop].x := nx;
      stack[stackTop].y := ny;
     End;
    End;
   End;
  End;
 End;
End;

Procedure ProcessCapture;
Var
 x,y:Integer;
 tilesOwned:Integer;
 captured:Boolean;
 tempGrid:TGrid;
Begin
 captured := False;
  { tape 1: Transformer tous les carr‚s cyan (trail) en bleu (owned) }
  For x:=0 to GRID_WIDTH-1 do For y:=0 to GRID_HEIGHT-1 do
   If Game.grid[x,y]=tsTrail Then Begin
    Game.grid[x,y]:=tsOwned;
    captured:=True;
   End;
  { tape 2: Copier la grille pour travailler dessus }
  For x := 0 to GRID_WIDTH-1 do For y := 0 to GRID_HEIGHT-1 do
   tempGrid[x, y] := Game.grid[x, y];

  { tape 3: Marquer toutes les zones grises connect‚es aux bords comme "ext‚rieures" }
  { Le flood fill se propage depuis les bords … travers les cases grises (tsEmpty) }
  { mais s'arrˆte quand il rencontre des carr‚s bleus (tsOwned) ou des murs (tsWall) }
  { Ainsi, seules les zones grises extÃ©rieures (non ferm‚es par des bleus) sont marqu‚es }

  { Parcourir les cases adjacentes aux bords (les bords sont des murs) }
  { Bord sup‚rieur : ligne 1 (ligne 0 = mur) }
  For x:=1 to GRID_WIDTH-2 do
    If tempGrid[x,1]=tsEmpty Then FloodFillTemp(x, 1, tsWall, tempGrid);
   { Bord inf‚rieur : ligne GRID_HEIGHT-2 (ligne GRID_HEIGHT-1 = mur) }
  For x:=1 to GRID_WIDTH-2 do
   If tempGrid[x, GRID_HEIGHT-2] = tsEmpty Then
    FloodFillTemp(x, GRID_HEIGHT-2, tsWall, tempGrid);
   { Bord gauche : colonne 1 (colonne 0 = mur) }
  For y := 1 to GRID_HEIGHT-2 do
   If tempGrid[1, y] = tsEmpty Then
    FloodFillTemp(1, y, tsWall, tempGrid);
  { Bord droit : colonne GRID_WIDTH-2 (colonne GRID_WIDTH-1 = mur) }
  For y := 1 to GRID_HEIGHT-2 do
    If tempGrid[GRID_WIDTH-2, y] = tsEmpty Then
      FloodFillTemp(GRID_WIDTH-2, y, tsWall, tempGrid);
  { tape 4: Capturer uniquement les zones grises ferm‚es (int‚rieures) }
  { Les zones grises qui n'ont pas ‚t‚ marqu‚es comme ext‚rieures sont forc‚ment }
  { des zones ferm‚es complŠtement entour‚es par des carr‚s bleus }
  For x := 0 to GRID_WIDTH-1 do
   For y := 0 to GRID_HEIGHT-1 do
    Begin
      { Si la case est grise dans la grille originale ET pas marqu‚e comme ext‚rieure }
      { alors c'est une zone ferm‚e qu'on peut capturer }
     If (Game.grid[x,y]=tsEmpty)and(tempGrid[x,y]=tsEmpty)Then Begin
      Game.grid[x,y]:=tsOwned;
      captured:=True;
     End;
    End;
  { Calculer le pourcentage de territoire possÃ©dÃ© }
 tilesOwned:=0;
 For x:=0 to GRID_WIDTH-1 do For y := 0 to GRID_HEIGHT-1 do
  If Game.grid[x, y] = tsOwned Then
   Inc(tilesOwned);
 Game.percentageOwned := (tilesOwned * 100.0) / ((GRID_WIDTH-2) * (GRID_HEIGHT-2));
  { Ajouter des points }
 Game.player.score:=Game.player.score + Game.player.trailLength * POINTS_PER_TILE;
 If captured Then Begin
  Game.message := 'Zone capturee! ' + IntToStr(Game.player.trailLength) + ' points';
  Game.messageTimer := 100;
 End;
  { V‚rifier si le niveau est termin‚ - seulement si on atteint un pourcentage ‚lev‚ }
  If Game.percentageOwned >= 75.0 Then Begin
   Game.message := 'Niveau complete! Bonus: ' + IntToStr(Round(Game.percentageOwned * 100));
   Game.player.score := Game.player.score + Round(Game.percentageOwned * 1000);
   Game.messageTimer := 100;
   Inc(Game.level);
   InitializePlayer;
   InitializeEnemies;
   Game.targetPercentage := 75.0; { Toujours 75% pour gagner }
  End;
  { R‚initialiser seulement si une capture a eu lieu }
 If captured Then Begin
  Game.player.trailLength := 0;
  Game.player.inSafeZone := True;
 End;
End;

Procedure MovePlayer;
Var
 newX,newY:Integer;
 dx,dy:Integer;
Begin
 dx := 0;
 dy := 0;
 Case Game.player.direction of
  dUp: dy := -1;
  dDown: dy := 1;
  dLeft: dx := -1;
  dRight: dx := 1;
 End;
 newX := Game.player.gridX + dx;
 newY := Game.player.gridY + dy;
 If IsValidMove(newX, newY)Then Begin
   { V‚rifier collision avec le trail }
  If Game.grid[newX, newY]=tsTrail Then Begin
    { Collision avec son propre trail }
   Game.player.lives := Game.player.lives - 1;
   Game.message := 'Collision avec votre trace!';
   Game.messageTimer := 50;
   If Game.player.lives<=0 Then Begin
    Game.gameState:=gsGameOver;
    Exit;
   End;
    { R‚initialiser le trail }
    For dx := 0 to GRID_WIDTH-1 do
     For dy := 0 to GRID_HEIGHT-1 do
      If Game.grid[dx, dy] = tsTrail Then
       Game.grid[dx, dy] := tsEmpty;
   Game.player.trailLength := 0;
   Game.player.inSafeZone := True;
   Exit;
  End;
  Game.player.gridX := newX;
  Game.player.gridY := newY;
  Game.player.x := START_X + Game.player.gridX * GRID_SIZE;
  Game.player.y := START_Y + Game.player.gridY * GRID_SIZE;
   { V‚rifier si on entre ou sort d'une zone s‚curis‚e }
  If IsInSafeZone(Game.player.gridX, Game.player.gridY)Then Begin
   If not Game.player.inSafeZone and (Game.player.trailLength > 0)Then Begin
    { Retour en zone s‚curis‚e - capturer le territoire }
    ProcessCapture;
     { ProcessCapture gŠre maintenant la r‚initialisation si n‚cessaire }
   End
    Else
   Begin
    { D‚j… dans une zone s‚curis‚e }
    Game.player.inSafeZone:=True;
   End;
  End
   Else
  Begin
    { En dehors de la zone s‚curis‚e }
   Game.player.inSafeZone:=False;
    { Cr‚er un trail }
   If Game.grid[Game.player.gridX, Game.player.gridY] = tsEmpty Then Begin
    Game.grid[Game.player.gridX, Game.player.gridY] := tsTrail;
    Inc(Game.player.trailLength);
   End;
  End;
 End;
End;

Procedure MoveEnemies;
Var
 i: Integer;
 enemy: ^TEnemy;
 newX, newY: Integer;
 dx, dy: Integer;
 possibleDirs: Array[0..3] of TDirection;
 dirCount: Integer;
 j: Integer;
Begin
 For i:=0 to 3 do Begin
  enemy := @Game.enemies[i];
  If not enemy^.active Then Continue;
  Inc(enemy^.moveCounter);
  If enemy^.moveCounter < enemy^.speed Then Continue;
  enemy^.moveCounter := 0;
   { Calculer le mouvement }
  dx := 0;
  dy := 0;
  Case enemy^.direction of
   dUp: dy := -1;
   dDown: dy := 1;
   dLeft: dx := -1;
   dRight: dx := 1;
  End;
  newX := enemy^.gridX + dx;
  newY := enemy^.gridY + dy;
   { V‚rifier si le mouvement est possible }
  If not IsValidMove(newX, newY) or (Game.grid[newX, newY] = tsOwned)Then Begin
    { Changer de direction }
   dirCount:=0;
    { Collecter les directions possibles }
   For j := 1 to 4 do Begin
    dx := 0;
    dy := 0;
    Case TDirection(j) of
     dUp: dy := -1;
     dDown: dy := 1;
     dLeft: dx := -1;
     dRight: dx := 1;
    End;
    If IsValidMove(enemy^.gridX + dx, enemy^.gridY + dy) and
        (Game.grid[enemy^.gridX + dx, enemy^.gridY + dy] <> tsOwned) Then Begin
     possibleDirs[dirCount] := TDirection(j);
     Inc(dirCount);
    End;
   End;
   If dirCount>0 Then Begin
    enemy^.direction := possibleDirs[Random(dirCount)];
     { Recalculer le mouvement }
    dx := 0;
    dy := 0;
    Case enemy^.direction of
     dUp: dy := -1;
     dDown: dy := 1;
     dLeft: dx := -1;
     dRight: dx := 1;
    End;
    newX := enemy^.gridX + dx;
    newY := enemy^.gridY + dy;
   End;
  End;
   { Effectuer le mouvement }
  If IsValidMove(newX, newY) and (Game.grid[newX, newY] <> tsOwned) Then Begin
   enemy^.gridX := newX;
   enemy^.gridY := newY;
   enemy^.x := START_X + enemy^.gridX * GRID_SIZE;
   enemy^.y := START_Y + enemy^.gridY * GRID_SIZE;
    { V‚rifier collision avec le joueur }
   If (enemy^.gridX = Game.player.gridX) and (enemy^.gridY = Game.player.gridY)Then Begin
     { Collision avec le joueur }
    Game.player.lives := Game.player.lives - 1;
    Game.message := 'Touche par un ennemi!';
    Game.messageTimer := 50;
    If Game.player.lives <= 0 Then Begin
     Game.gameState := gsGameOver;
     Exit;
    End;
     { R‚initialiser le trail }
    For dx := 0 to GRID_WIDTH-1 do
     For dy := 0 to GRID_HEIGHT-1 do
      If Game.grid[dx, dy] = tsTrail Then
       Game.grid[dx, dy] := tsEmpty;
    Game.player.trailLength := 0;
    Game.player.inSafeZone := True;
   End;
    { V‚rifier collision avec le trail }
   If Game.grid[enemy^.gridX, enemy^.gridY]=tsTrail Then Begin
     { L'ennemi touche le trail }
    Game.player.lives := Game.player.lives - 1;
    Game.message := 'Votre trace a ete coupee!';
    Game.messageTimer := 50;
    If Game.player.lives<=0 Then Begin
     Game.gameState:=gsGameOver;
     Exit;
    End;
     { R‚initialiser le trail }
    For dx := 0 to GRID_WIDTH-1 do
     For dy := 0 to GRID_HEIGHT-1 do
      If Game.grid[dx, dy] = tsTrail Then
       Game.grid[dx, dy] := tsEmpty;
    Game.player.trailLength := 0;
    Game.player.inSafeZone := True;
   End;
  End;
 End;
End;

Procedure DrawGrid;
Var
 x, y: Integer;
 screenX, screenY: Integer;
Begin
 For x := 0 to GRID_WIDTH-1 do
  For y := 0 to GRID_HEIGHT-1 do Begin
   screenX := START_X + x * GRID_SIZE;
   screenY := START_Y + y * GRID_SIZE;
   Case Game.grid[x, y] of
    tsEmpty:Begin
     SetColor(8);
     SetFillStyle(1, 8);
     Bar(screenX, screenY, screenX + GRID_SIZE-1, screenY + GRID_SIZE-1);
    End;
    tsOwned:Begin
     SetColor(9);
     SetFillStyle(1, 9);
     Bar(screenX, screenY, screenX + GRID_SIZE-1, screenY + GRID_SIZE-1);
    End;
    tsTrail:Begin
     SetColor(11);
     SetFillStyle(1, 11);
     Bar(screenX, screenY, screenX + GRID_SIZE-1, screenY + GRID_SIZE-1);
    End;
    tsWall:Begin
     SetColor(7);
     SetFillStyle(1, 7);
     Bar(screenX, screenY, screenX + GRID_SIZE-1, screenY + GRID_SIZE-1);
    End;
   End;
    { Contour de la grille }
   SetColor(15);
   Rectangle(screenX, screenY, screenX + GRID_SIZE-1, screenY + GRID_SIZE-1);
  End;
End;

Procedure DrawPlayer;Begin
 SetColor(Game.player.color);
 SetFillStyle(1, Game.player.color);
 FillEllipse(Game.player.x + GRID_SIZE div 2,
             Game.player.y + GRID_SIZE div 2,
             PLAYER_SIZE, PLAYER_SIZE);
  { Contour }
 SetColor(15);
 Circle(Game.player.x + GRID_SIZE div 2,
        Game.player.y + GRID_SIZE div 2,
        PLAYER_SIZE);
End;

Procedure DrawEnemies;
Var
 i: Integer;
Begin
 For i := 0 to 3 do Begin
  If Game.enemies[i].active Then Begin
   SetColor(Game.enemies[i].color);
   SetFillStyle(1, Game.enemies[i].color);
   FillEllipse(Game.enemies[i].x + GRID_SIZE div 2,
               Game.enemies[i].y + GRID_SIZE div 2,
               PLAYER_SIZE, PLAYER_SIZE);
    { Contour }
   SetColor(15);
   Circle(Game.enemies[i].x + GRID_SIZE div 2,
          Game.enemies[i].y + GRID_SIZE div 2,
          PLAYER_SIZE);
  End;
 End;
End;

Procedure DrawUI;Begin
  { Fond noir pour l'UI }
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, START_Y-5);
 Bar(0, START_Y + GRID_HEIGHT * GRID_SIZE + 5, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Informations du jeu }
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(10, 10, 'Score: ' + IntToStr(Game.player.score));
 OutTextXY(10, 25, 'Vies: ' + IntToStr(Game.player.lives));
 OutTextXY(150, 10, 'Niveau: ' + IntToStr(Game.level));
 OutTextXY(150, 25, 'Territoire: ' + FloatToStr(Game.percentageOwned, 1) + '%');
 OutTextXY(300, 10, 'Objectif: ' + FloatToStr(Game.targetPercentage, 0) + '%');
 OutTextXY(300, 25, 'Trace: ' + IntToStr(Game.player.trailLength));
  { Barre de progression }
 SetColor(7);
 Rectangle(450, 10, 620, 30);
 SetColor(10);
 SetFillStyle(1, 10);
 Bar(451, 11, 451 + Round((Game.percentageOwned / Game.targetPercentage) * 168), 29);
End;

Procedure DrawMessage;Begin
 If(Game.message <> '') and (Game.messageTimer > 0)Then Begin
  SetColor(14);
  SetFillStyle(1, 14);
  Bar(150, 200, 490, 230);
  SetColor(0);
  SetTextStyle(0, 0, 1);
  OutTextXY(160, 210, Game.message);
  Dec(Game.messageTimer);
  If Game.messageTimer<=0 Then Game.message := '';
 End;
End;

Procedure DrawMainMenu;Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 4);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 80, 'TILEMAN');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 150, 'Regles du jeu:');
 OutTextXY(50, 170, '- Deplacez-vous avec les fleches');
 OutTextXY(50, 190, '- Sortez de votre territoire (bleu) pour tracer');
 OutTextXY(50, 210, '- Revenez dans votre territoire pour capturer la zone');
 OutTextXY(50, 230, '- Evitez les ennemis (rouge) et votre propre trace');
 OutTextXY(50, 250, '- Capturez ' + FloatToStr(Game.targetPercentage, 0) + '% du territoire pour gagner');
 OutTextXY(50, 270, '- Vous commencez avec ' + IntToStr(INITIAL_LIVES) + ' vies');
 OutTextXY(50, 310, 'Commandes:');
 OutTextXY(50, 330, 'Fleches: Deplacer');
 OutTextXY(50, 350, 'P: Pause');
 OutTextXY(50, 370, 'ESC: Quitter');
 OutTextXY(50, 400, 'Appuyez sur ENTREE pour commencer...');
End;

Procedure DrawGameOver;Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 150, 'GAME OVER');
 SetTextStyle(0, 0, 2);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 200, 'Score final:');
 OutTextXY(SCREEN_WIDTH div 2 - 50, 230, IntToStr(Game.player.score));
 OutTextXY(SCREEN_WIDTH div 2 - 60, 270, 'Niveau: ' + IntToStr(Game.level));
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 350, 'Appuyez sur N pour une nouvelle partie ou ESC pour quitter');
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case Game.gameState of
   gsMainMenu:Begin
    If key = #13 Then Begin { Enter }
     Game.gameState := gsPlaying;
     Game.needRedraw := True;
    End
    Else If key = #27 Then { ESC }
    Game.gameState := gsQuit;
   End;
   gsPlaying:Begin
    Case key of
     #0:Begin { Touches sp‚ciales }
      key := ReadKey;
      Case key of
       #72: Game.player.direction := dUp;    { FlŠche haut }
       #80: Game.player.direction := dDown;  { FlŠche bas }
       #75: Game.player.direction := dLeft;  { FlŠche gauche }
       #77: Game.player.direction := dRight; { FlŠche droite }
      End;
     End;
     'p','P':Begin
      Game.gameState:=gsPaused;
      Game.needRedraw:=True;
     End;
     #27:Game.gameState := gsQuit; { ESC }
    End;
   End;
   gsPaused:Begin
    If (key = 'p') or (key = 'P') or (key = ' ') Then Begin
     Game.gameState := gsPlaying;
     Game.needRedraw := True;
    End
     Else
    If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
   gsGameOver:Begin
    If (key = 'n') or (key = 'N') Then Begin
      { Nouvelle partie }
     Game.level := 1;
     Game.targetPercentage := 50;
     Game.percentageOwned := 0;
     Game.message := '';
     Game.messageTimer := 0;
     InitializeGrid;
     InitializePlayer;
     InitializeEnemies;
     Game.gameState := gsPlaying;
     Game.needRedraw := True;
    End
    Else If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
  End;
 End;
End;

Procedure UpdateGame;Begin
 If Game.gameState=gsPlaying Then Begin
  MovePlayer;
  MoveEnemies;
  Inc(Game.gameTimer);
  Game.needRedraw := True;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  Case Game.gameState of
   gsMainMenu: DrawMainMenu;
   gsPlaying:Begin
    DrawGrid;
    DrawPlayer;
    DrawEnemies;
    DrawUI;
    DrawMessage;
   End;
   gsPaused:Begin
    DrawGrid;
    DrawPlayer;
    DrawEnemies;
    DrawUI;
     { Message de pause }
    SetColor(14);
    SetFillStyle(1, 14);
    Bar(200, 200, 440, 250);
    SetColor(0);
    SetTextStyle(0, 0, 2);
    OutTextXY(250, 215, 'PAUSE');
    SetTextStyle(0, 0, 1);
    OutTextXY(210, 235, 'Appuyez sur P pour continuer');
   End;
   gsGameOver: DrawGameOver;
  End;
  Game.needRedraw := False;
 End;
End;

Procedure InitializeGame;Begin
 Game.gameState := gsMainMenu;
 Game.level := 1;
 Game.targetPercentage := 75.0;
 Game.percentageOwned := 0;
 Game.message := '';
 Game.messageTimer := 0;
 Game.needRedraw := True;
 Game.gameTimer := 0;
 InitializeGrid;
 InitializePlayer;
 InitializeEnemies;
 Randomize;
End;

Procedure GameLoop;Begin
 While Game.gameState <> gsQuit do Begin
  HandleInput;
  UpdateGame;
  Render;
  Delay(100);
 End;
End;

Procedure InitializeGraphics;
Var
  Driver, Mode: Integer;
  ErrCode: Integer;
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
 InitializeGame;
 GameLoop;
 CloseGraph;
END.
