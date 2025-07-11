{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Billard - 8 boules avec physique simplifi‚e
}

Program Billard;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 TABLE_WIDTH = 560;
 TABLE_HEIGHT = 320;
 TABLE_X = 40;
 TABLE_Y = 80;
 BALL_RADIUS = 8;
 POCKET_RADIUS = 15;
 MAX_BALLS = 16;
 FRICTION = 0.94;
 MIN_SPEED = 0.05;
 MAX_POWER = 30;

Type
 TBallType = (btCue, btSolid, btStripe, btEightBall);

 TBall=Record
  x,y:Real;
  vx,vy:Real;
  active:Boolean;
  ballType:TBallType;
  color:Integer;
  number:Integer;
  pocketed:Boolean;
 End;

 TPlayer=Record
  name:String;
  ballType:TBallType;
  score:Integer;
  hasAssignedType:Boolean;
 End;

 TGameState = (gsPlaying, gsAiming, gsShooting, gsGameOver, gsQuit);

 TGame=Record
  balls:Array[0..MAX_BALLS-1] of TBall;
  players:Array[1..2] of TPlayer;
  currentPlayer:Integer;
  gameState:TGameState;
  aimAngle:Real;
  power:Integer;
  cueX,cueY:Real;
  needRedraw:Boolean;
  winner:Integer;
  lastAction:String;
  movingBalls:Integer;
  firstHit:Boolean;
  validShot:Boolean;
 End;

Var
 Game:TGame;
 Pockets:Array[0..5] of Record
  x,y:Integer;
 End;

{ D‚clarations forward }
Procedure InitializeGame; Forward;

Function IntToStr(value:Integer):String;
Var
 s:String;
Begin
 Str(value,s);
 IntToStr:=s;
End;

Function FloatToStr(value:Real):String;
Var
 s:String;
Begin
 Str(value:0:1,s);
 FloatToStr:=s;
End;

Function Distance(x1,y1,x2,y2:Real):Real;Begin
 Distance:=Sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
End;

Procedure InitializePockets;Begin
 { Poches d'angle }
 Pockets[0].x := TABLE_X + 10;
 Pockets[0].y := TABLE_Y + 10;
 Pockets[1].x := TABLE_X + TABLE_WIDTH - 10;
 Pockets[1].y := TABLE_Y + 10;
 Pockets[2].x := TABLE_X + 10;
 Pockets[2].y := TABLE_Y + TABLE_HEIGHT - 10;
 Pockets[3].x := TABLE_X + TABLE_WIDTH - 10;
 Pockets[3].y := TABLE_Y + TABLE_HEIGHT - 10;
 { Poches du milieu }
 Pockets[4].x := TABLE_X;
 Pockets[4].y := TABLE_Y + TABLE_HEIGHT div 2;
 Pockets[5].x := TABLE_X + TABLE_WIDTH;
 Pockets[5].y := TABLE_Y + TABLE_HEIGHT div 2;
End;

Procedure InitializeBalls;
Var
 startX,startY:Real;
 row,col:Integer;
 ballIndex:Integer;
Begin
 { Boule blanche (cue ball) }
 Game.balls[0].x := TABLE_X + TABLE_WIDTH * 0.25;
 Game.balls[0].y := TABLE_Y + TABLE_HEIGHT div 2;
 Game.balls[0].vx := 0;
 Game.balls[0].vy := 0;
 Game.balls[0].active := True;
 Game.balls[0].ballType := btCue;
 Game.balls[0].color := 15;
 Game.balls[0].number := 0;
 Game.balls[0].pocketed := False;
  { Formation triangulaire des boules }
 startX := TABLE_X + TABLE_WIDTH * 0.75;
 startY := TABLE_Y + TABLE_HEIGHT div 2;
 ballIndex:=1;
 For row:=0 to 4 do Begin
  For col:=0 to row do Begin
   If ballIndex <= 15 Then Begin
    Game.balls[ballIndex].x := startX + row * BALL_RADIUS * 1.8;
    Game.balls[ballIndex].y := startY + (col - row/2) * BALL_RADIUS * 1.8;
    Game.balls[ballIndex].vx := 0;
    Game.balls[ballIndex].vy := 0;
    Game.balls[ballIndex].active := True;
    Game.balls[ballIndex].number := ballIndex;
    Game.balls[ballIndex].pocketed := False;
     { Assigner les types de boules }
    If ballIndex = 8 Then Begin
     Game.balls[ballIndex].ballType:=btEightBall;
     Game.balls[ballIndex].color:=0;
    End
     Else
    If ballIndex <= 7 Then Begin
     Game.balls[ballIndex].ballType := btSolid;
     Game.balls[ballIndex].color := ballIndex;
    End
     Else
    Begin
     Game.balls[ballIndex].ballType := btStripe;
     Game.balls[ballIndex].color := ballIndex - 8;
    End;
    Inc(ballIndex);
   End;
  End;
 End;
End;

Procedure InitializePlayers;Begin
 Game.players[1].name := 'Joueur 1';
 Game.players[1].ballType := btSolid;
 Game.players[1].score := 0;
 Game.players[1].hasAssignedType := False;
 Game.players[2].name := 'Joueur 2';
 Game.players[2].ballType := btStripe;
 Game.players[2].score := 0;
 Game.players[2].hasAssignedType := False;
End;

Function CheckPocket(ballIndex: Integer): Boolean;
Var
 i:Integer;
Begin
 CheckPocket:=False;
 For i:=0 to 5 do Begin
  If Distance(Game.balls[ballIndex].x, Game.balls[ballIndex].y,
             Pockets[i].x, Pockets[i].y) < POCKET_RADIUS Then Begin
   Game.balls[ballIndex].pocketed := True;
   Game.balls[ballIndex].active := False;
   CheckPocket := True;
   Exit;
  End;
 End;
End;

Function CheckBallCollision(ball1,ball2:Integer):Boolean;
Var
 dx, dy, dist: Real;
 relativeVx, relativeVy: Real;
 normalVelocity: Real;
 impulse: Real;
 totalSpeed: Real;
Begin
 CheckBallCollision:=False;
 If (not Game.balls[ball1].active) or (not Game.balls[ball2].active) Then Exit;
 dx := Game.balls[ball2].x - Game.balls[ball1].x;
 dy := Game.balls[ball2].y - Game.balls[ball1].y;
 dist := Sqrt(dx*dx + dy*dy);
 If dist<BALL_RADIUS * 2 Then Begin
  CheckBallCollision := True;
   { Collision ‚lastique avec transfert d'‚nergie r‚aliste }
  If dist > 0 Then Begin
   dx := dx / dist;
   dy := dy / dist;
   { S‚parer les boules }
   Game.balls[ball1].x := Game.balls[ball1].x - dx * 0.5;
   Game.balls[ball1].y := Game.balls[ball1].y - dy * 0.5;
   Game.balls[ball2].x := Game.balls[ball2].x + dx * 0.5;
   Game.balls[ball2].y := Game.balls[ball2].y + dy * 0.5;
    { Calculer les vitesses relatives }
   relativeVx := Game.balls[ball1].vx - Game.balls[ball2].vx;
   relativeVy := Game.balls[ball1].vy - Game.balls[ball2].vy;
    { Vitesse relative dans la direction de la normale }
   normalVelocity := relativeVx * dx + relativeVy * dy;
    { Si les boules se sÃ©parent dÃ©jÃ , pas de collision }
   If normalVelocity <= 0 Then Exit;
    { Calculer l'impulsion (transfert d'Ã©nergie) }
   totalSpeed := Sqrt(Game.balls[ball1].vx * Game.balls[ball1].vx +
                      Game.balls[ball1].vy * Game.balls[ball1].vy);
    { Coefficient de restitution pour un transfert d'‚nergie r‚aliste }
   impulse := normalVelocity * 1.6; { Coefficient ‚lev‚ pour transfert d'‚nergie }
   { Appliquer l'impulsion - la boule qui frappe perd beaucoup d'‚nergie }
   { La boule frapp‚e re‡oit la majeure partie de l'‚nergie }
   Game.balls[ball1].vx := Game.balls[ball1].vx - impulse * dx * 0.9; { Boule qui frappe perd 90% }
   Game.balls[ball1].vy := Game.balls[ball1].vy - impulse * dy * 0.9;
   Game.balls[ball2].vx := Game.balls[ball2].vx + impulse * dx * 1.5; { Boule frapp‚e re‡oit 150% }
   Game.balls[ball2].vy := Game.balls[ball2].vy + impulse * dy * 1.5;
    { Bonus d'‚nergie pour les coups puissants }
   If totalSpeed > 4 Then Begin
    { La boule frapp‚e re‡oit encore plus d'‚nergie }
    Game.balls[ball2].vx := Game.balls[ball2].vx * 1.4;
    Game.balls[ball2].vy := Game.balls[ball2].vy * 1.4;
    { La boule qui frappe ralentit encore plus }
    Game.balls[ball1].vx := Game.balls[ball1].vx * 0.3;
    Game.balls[ball1].vy := Game.balls[ball1].vy * 0.3;
   End;
  End;
 End;
End;

Procedure UpdateBalls;
Var
 i,j:Integer;
 speed:Real;
Begin
 Game.movingBalls := 0;
 For i := 0 to MAX_BALLS-1 do Begin
  If Game.balls[i].active Then Begin
    { Appliquer la friction }
   Game.balls[i].vx:=Game.balls[i].vx * FRICTION;
   Game.balls[i].vy:=Game.balls[i].vy * FRICTION;
    { Arrˆter si vitesse trop faible }
   speed := Sqrt(Game.balls[i].vx*Game.balls[i].vx + Game.balls[i].vy*Game.balls[i].vy);
   If speed<MIN_SPEED Then Begin
    Game.balls[i].vx := 0;
    Game.balls[i].vy := 0;
   End
    Else
   Inc(Game.movingBalls);
    { Mettre … jour position }
   Game.balls[i].x := Game.balls[i].x + Game.balls[i].vx;
   Game.balls[i].y := Game.balls[i].y + Game.balls[i].vy;
    { Rebond sur les bords }
   If Game.balls[i].x<TABLE_X + BALL_RADIUS Then Begin
    Game.balls[i].x := TABLE_X + BALL_RADIUS;
    Game.balls[i].vx := -Game.balls[i].vx * 0.8;
   End;
   If Game.balls[i].x > TABLE_X + TABLE_WIDTH - BALL_RADIUS Then Begin
    Game.balls[i].x := TABLE_X + TABLE_WIDTH - BALL_RADIUS;
    Game.balls[i].vx := -Game.balls[i].vx * 0.8;
   End;
   If Game.balls[i].y < TABLE_Y + BALL_RADIUS Then Begin
    Game.balls[i].y := TABLE_Y + BALL_RADIUS;
    Game.balls[i].vy := -Game.balls[i].vy * 0.8;
   End;
   If Game.balls[i].y > TABLE_Y + TABLE_HEIGHT - BALL_RADIUS Then Begin
    Game.balls[i].y := TABLE_Y + TABLE_HEIGHT - BALL_RADIUS;
    Game.balls[i].vy := -Game.balls[i].vy * 0.8;
   End;
   { V‚rifier les poches }
   If CheckPocket(i)Then Begin
    If i=0 Then Game.lastAction:='Boule blanche empochee!'
           Else Game.lastAction:='Boule '+IntToStr(Game.balls[i].number)+' empochee';
   End;
  End;
 End;
  { V‚rifier les collisions }
 For i := 0 to MAX_BALLS-2 do For j := i+1 to MAX_BALLS-1 do
  If CheckBallCollision(i,j)Then Begin
   If not Game.firstHit Then Begin
    Game.firstHit := True;
    Game.validShot := True;
   End;
  End;
End;

Function CheckGameEnd:Boolean;
Var
 i:Integer;
 solidsLeft, stripesLeft:Integer;
Begin
 CheckGameEnd:=False;
 solidsLeft:=0;
 stripesLeft:=0;
 For i:=1 to 15 do Begin
  If Game.balls[i].active Then Begin
   If Game.balls[i].ballType=btSolid Then Inc(solidsLeft) Else
   If Game.balls[i].ballType=btStripe Then Inc(stripesLeft);
  End;
 End;
  { V‚rifier si la boule 8 a ‚t‚ empoch‚e }
 If Game.balls[8].pocketed Then Begin
  CheckGameEnd:=True;
  Game.gameState:=gsGameOver;
   { D‚terminer le gagnant }
  If Game.players[Game.currentPlayer].ballType=btSolid Then Begin
   If solidsLeft=0 Then Game.winner:=Game.currentPlayer
                   Else Game.winner:=3 - Game.currentPlayer;
  End
   Else
  Begin
   If stripesLeft=0 Then Game.winner:=Game.currentPlayer
                    Else Game.winner:=3 - Game.currentPlayer;
  End;
 End;
  { V‚rifier si la boule blanche a ‚t‚ empoch‚e }
 If Game.balls[0].pocketed Then Begin
  Game.balls[0].pocketed := False;
  Game.balls[0].active := True;
  Game.balls[0].x:=TABLE_X + TABLE_WIDTH * 0.25;
  Game.balls[0].y:=TABLE_Y + TABLE_HEIGHT div 2;
  Game.balls[0].vx:=0;
  Game.balls[0].vy:=0;
  Game.currentPlayer:=3-Game.currentPlayer;
 End;
End;

Procedure Shoot;
Var
 radians:Real;
 force:Real;
Begin
 If Game.gameState=gsAiming Then Begin
  Game.gameState := gsShooting;
  Game.firstHit := False;
  Game.validShot := False;
  radians := Game.aimAngle * Pi / 180;
  force := Game.power * 3.0;
  Game.balls[0].vx := Cos(radians) * force;
  Game.balls[0].vy := Sin(radians) * force;
  Game.lastAction := 'Tir effectue - Force: ' + IntToStr(Game.power);
 End;
End;

Procedure DrawTable;
Var
 i:Integer;
Begin
  { Fond de la table }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(TABLE_X, TABLE_Y, TABLE_X + TABLE_WIDTH, TABLE_Y + TABLE_HEIGHT);
  { Contour de la table }
 SetColor(6);
 SetLineStyle(0, 0, 3);
 Rectangle(TABLE_X - 5, TABLE_Y - 5, TABLE_X + TABLE_WIDTH + 5, TABLE_Y + TABLE_HEIGHT + 5);
  { Poches }
 For i:=0 to 5 do Begin
  SetColor(0);
  SetFillStyle(1, 0);
  Circle(Pockets[i].x, Pockets[i].y, POCKET_RADIUS);
  FloodFill(Pockets[i].x, Pockets[i].y, 0);
 End;
End;

Procedure DrawBalls;
Var
 i:Integer;
Begin
 For i:=0 to MAX_BALLS-1 do Begin
  If Game.balls[i].active Then Begin
   SetColor(Game.balls[i].color);
   SetFillStyle(1, Game.balls[i].color);
   Circle(Round(Game.balls[i].x), Round(Game.balls[i].y), BALL_RADIUS);
   FloodFill(Round(Game.balls[i].x), Round(Game.balls[i].y), Game.balls[i].color);
    { Contour }
   SetColor(15);
   Circle(Round(Game.balls[i].x), Round(Game.balls[i].y), BALL_RADIUS);
    { Num‚ro sur la boule }
   If Game.balls[i].ballType<>btCue Then Begin
    SetColor(15);
    SetTextStyle(0, 0, 1);
    OutTextXY(Round(Game.balls[i].x) - 3, Round(Game.balls[i].y) - 3, IntToStr(Game.balls[i].number));
   End;
  End;
 End;
End;

Procedure DrawCue;
Var
 endX,endY:Real;
 radians:Real;
Begin
 If Game.gameState=gsAiming Then Begin
  radians := Game.aimAngle * Pi / 180;
  endX := Game.balls[0].x + Cos(radians) * (60 + Game.power * 6);
  endY := Game.balls[0].y + Sin(radians) * (60 + Game.power * 6);
  SetColor(6);
  SetLineStyle(0, 0, 3);
  Line(Round(Game.balls[0].x), Round(Game.balls[0].y), Round(endX), Round(endY));
   { Indicateur de puissance }
  SetColor(14);
  SetFillStyle(1, 14);
  Bar(10, 10, 10 + Game.power * 6, 25);
  SetColor(0);
  Rectangle(10, 10, 10 + MAX_POWER * 6, 25);
 End;
End;

Procedure DrawGameInfo;Begin
 SetColor(15);
 SetTextStyle(0, 0, 2);
 OutTextXY(250, 20, 'BILLARD - 8 BOULES');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 50, 'Joueur actuel: ' + Game.players[Game.currentPlayer].name);
 SetColor(15);
 OutTextXY(50, 420, 'Commandes:');
 OutTextXY(50, 435, 'Fleches: Viser  ESPACE: Ajuster puissance  ENTREE: Tirer');
 OutTextXY(50, 450, 'N: Nouvelle partie  ESC: Quitter');
 If Game.lastAction<>''Then Begin
  SetColor(14);
  OutTextXY(300, 50, Game.lastAction);
 End;
  { Afficher l'angle et la puissance }
 If Game.gameState=gsAiming Then Begin
  SetColor(11);
  OutTextXY(200, 420, 'Angle: ' + FloatToStr(Game.aimAngle));
  OutTextXY(200, 435, 'Puissance: ' + IntToStr(Game.power));
 End;
End;

Procedure DrawGameStatus;Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 Case Game.gameState of
  gsGameOver: Begin
   OutTextXY(200, 200, 'PARTIE TERMINEE');
   OutTextXY(200, 230, 'GAGNANT: ' + Game.players[Game.winner].name);
  End;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   #0:Begin
    key:=ReadKey;
    Case key of
     #72: Begin { FlŠche haut }
      If Game.gameState=gsAiming Then Begin
       Game.aimAngle := Game.aimAngle - 5;
       If Game.aimAngle < 0 Then Game.aimAngle := Game.aimAngle + 360;
       Game.needRedraw := True;
      End;
     End;
     #80: Begin { FlŠche bas }
      If Game.gameState = gsAiming Then Begin
       Game.aimAngle := Game.aimAngle + 5;
       If Game.aimAngle >= 360 Then Game.aimAngle := Game.aimAngle - 360;
       Game.needRedraw := True;
      End;
     End;
     #75: Begin { FlŠche gauche }
      If Game.gameState = gsAiming Then Begin
       Game.aimAngle := Game.aimAngle - 2;
       If Game.aimAngle < 0 Then Game.aimAngle := Game.aimAngle + 360;
       Game.needRedraw := True;
      End;
     End;
     #77:Begin { FlŠche droite }
      If Game.gameState = gsAiming Then Begin
       Game.aimAngle := Game.aimAngle + 2;
       If Game.aimAngle >= 360 Then Game.aimAngle := Game.aimAngle - 360;
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   ' ': Begin { Espace - Ajuster puissance }
    If Game.gameState = gsAiming Then Begin
     Inc(Game.power);
     If Game.power > MAX_POWER Then Game.power := 1;
     Game.needRedraw := True;
    End;
   End;
   #13: Begin { EntrÃ©e - Tirer }
    If Game.gameState = gsAiming Then
     Shoot;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure ProcessGame;Begin
 If Game.gameState=gsShooting Then Begin
  UpdateBalls;
  If Game.movingBalls = 0 Then Begin
   If CheckGameEnd Then Exit;
   { Changer de joueur si tir invalide }
   If not Game.validShot Then Game.currentPlayer := 3 - Game.currentPlayer;
   Game.gameState := gsAiming;
   Game.power := 5;
  End;
  Game.needRedraw := True;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
   { Fond }
  SetColor(3);
  SetFillStyle(1, 3);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  DrawTable;
  DrawBalls;
  DrawCue;
  DrawGameInfo;
  DrawGameStatus;
  Game.needRedraw:=False;
 End;
End;

Procedure ShowTitle;Begin
 SetColor(3);
 SetFillStyle(1,3);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 120, 60, 'BILLARD');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de billard a 8 boules');
 OutTextXY(50, 150, 'Regles:');
 OutTextXY(50, 170, '- Empoche toutes tes boules (pleines ou rayees) puis la boule 8');
 OutTextXY(50, 190, '- Ne pas empocher la boule blanche');
 OutTextXY(50, 210, '- Ne pas empocher la boule 8 avant tes boules');
 OutTextXY(50, 230, '- Premier tir determine le type de boules');
 OutTextXY(50, 260, 'Commandes:');
 OutTextXY(50, 280, 'Fleches: Viser la queue de billard');
 OutTextXY(50, 300, 'ESPACE: Ajuster la puissance de tir');
 OutTextXY(50, 320, 'ENTREE: Effectuer le tir');
 OutTextXY(50, 340, 'N: Nouvelle partie');
 OutTextXY(50, 360, 'ESC: Quitter');
 OutTextXY(50, 400, 'Appuyez sur une touche pour commencer...');
 ReadKey;
End;

Procedure InitializeGame;Begin
 InitializePockets;
 InitializeBalls;
 InitializePlayers;
 Game.currentPlayer := 1;
 Game.gameState := gsAiming;
 Game.aimAngle := 0;
 Game.power := 5;
 Game.needRedraw := True;
 Game.winner := 0;
 Game.lastAction := 'Nouvelle partie - Joueur 1 commence';
 Game.movingBalls := 0;
 Game.firstHit := False;
 Game.validShot := False;
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
  ProcessGame;
  Render;
  Delay(50);
 End;
End;

Procedure InitializeGraphics;
Var
 Driver,Mode:Integer;
 ErrCode:Integer;
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
 If ErrCode<>grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
 SetLineStyle(0, 0, 1);
 Randomize;
End;

BEGIN
 InitializeGraphics;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.