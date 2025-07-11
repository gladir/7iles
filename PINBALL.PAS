{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de PinBall - Flipper avec physique simplifiée
}

Program PinBall;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 TABLE_WIDTH = 400;
 TABLE_HEIGHT = 460;
 TABLE_X = 120;
 TABLE_Y = 10;
 BALL_RADIUS = 4;
 GRAVITY = 0.15;
 FRICTION = 0.98;
 BOUNCE_FACTOR = 0.7;
 MAX_SPEED = 60;
 FLIPPER_LENGTH = 40;
 FLIPPER_SPEED = 8;
 MAX_BUMPERS = 8;
 MAX_TARGETS = 6;
 MAX_DIAGONAL_BLOCKS = 2;
 LAUNCH_POWER = 15;

Type
 TGameState = (gsPlaying, gsGameOver, gsLaunching, gsQuit);
 
 TBall = Record
  x, y: Real;
  vx, vy: Real;
  active: Boolean;
  launched: Boolean;
 End;
 
 TFlipper = Record
  x, y: Real;
  angle: Real;
  targetAngle: Real;
  active: Boolean;
  isLeft: Boolean;
 End;
 
 TBumper = Record
  x, y: Integer;
  active: Boolean;
  hitCount: Integer;
 End;
 
 TTarget = Record
  x, y: Integer;
  active: Boolean;
  hit: Boolean;
 End;
 
 TDiagonalBlock = Record
  x, y: Integer;
  width, height: Integer;
  active: Boolean;
  angle: Real; { Angle de la diagonale en degrés }
 End;
 
 TGame = Record
  ball: TBall;
  leftFlipper: TFlipper;
  rightFlipper: TFlipper;
  bumpers: Array[0..MAX_BUMPERS-1] of TBumper;
  targets: Array[0..MAX_TARGETS-1] of TTarget;
  diagonalBlocks: Array[0..MAX_DIAGONAL_BLOCKS-1] of TDiagonalBlock;
  gameState: TGameState;
  score: LongInt;
  ballsLeft: Integer;
  launchPower: Integer;
  needRedraw: Boolean;
  lastAction: String;
  combo: Integer;
  bonusMultiplier: Integer;
 End;

Var
 Game: TGame;

{ Déclarations forward }
Procedure InitializeGame; Forward;

Function IntToStr(value: LongInt): String;
Var
 s: String;
Begin
 Str(value, s);
 IntToStr := s;
End;

Function Distance(x1, y1, x2, y2: Real): Real;
Begin
 Distance := Sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
End;

Procedure InitializeBall;
Begin
 Game.ball.x := TABLE_X + TABLE_WIDTH - 30;
 Game.ball.y := TABLE_Y + TABLE_HEIGHT - 50;
 Game.ball.vx := 0;
 Game.ball.vy := 0;
 Game.ball.active := True;
 Game.ball.launched := False;
End;

Procedure InitializeFlippers;
Begin
 { Flipper gauche }
 Game.leftFlipper.x := TABLE_X + 120;
 Game.leftFlipper.y := TABLE_Y + TABLE_HEIGHT - 80;
 Game.leftFlipper.angle := 30;
 Game.leftFlipper.targetAngle := 30;
 Game.leftFlipper.active := True;
 Game.leftFlipper.isLeft := True;
 
 { Flipper droit }
 Game.rightFlipper.x := TABLE_X + 280;
 Game.rightFlipper.y := TABLE_Y + TABLE_HEIGHT - 80;
 Game.rightFlipper.angle := -30;
 Game.rightFlipper.targetAngle := -30;
 Game.rightFlipper.active := True;
 Game.rightFlipper.isLeft := False;
End;

Procedure InitializeBumpers;
Var
 i: Integer;
Begin
 { Bumpers disposés en triangle }
 Game.bumpers[0].x := TABLE_X + 150;
 Game.bumpers[0].y := TABLE_Y + 120;
 Game.bumpers[0].active := True;
 Game.bumpers[0].hitCount := 0;
 
 Game.bumpers[1].x := TABLE_X + 250;
 Game.bumpers[1].y := TABLE_Y + 120;
 Game.bumpers[1].active := True;
 Game.bumpers[1].hitCount := 0;
 
 Game.bumpers[2].x := TABLE_X + 200;
 Game.bumpers[2].y := TABLE_Y + 180;
 Game.bumpers[2].active := True;
 Game.bumpers[2].hitCount := 0;
 
 { Bumpers latéraux }
 Game.bumpers[3].x := TABLE_X + 60;
 Game.bumpers[3].y := TABLE_Y + 200;
 Game.bumpers[3].active := True;
 Game.bumpers[3].hitCount := 0;
 
 Game.bumpers[4].x := TABLE_X + 340;
 Game.bumpers[4].y := TABLE_Y + 200;
 Game.bumpers[4].active := True;
 Game.bumpers[4].hitCount := 0;
 
 { Bumpers supplémentaires }
 For i := 5 to MAX_BUMPERS-1 do
 Begin
  Game.bumpers[i].x := TABLE_X + 100 + (i-5) * 60;
  Game.bumpers[i].y := TABLE_Y + 280;
  Game.bumpers[i].active := True;
  Game.bumpers[i].hitCount := 0;
 End;
End;

Procedure InitializeTargets;
Var
 i: Integer;
Begin
 For i := 0 to MAX_TARGETS-1 do
 Begin
  Game.targets[i].x := TABLE_X + 50 + i * 50;
  Game.targets[i].y := TABLE_Y + 60;
  Game.targets[i].active := True;
  Game.targets[i].hit := False;
 End;
End;

Procedure InitializeDiagonalBlocks;
Begin
 { Bloc diagonal dans le coin supérieur droit }
 Game.diagonalBlocks[0].x := TABLE_X + TABLE_WIDTH - 60;
 Game.diagonalBlocks[0].y := TABLE_Y + 40;
 Game.diagonalBlocks[0].width := 50;
 Game.diagonalBlocks[0].height := 20;
 Game.diagonalBlocks[0].active := True;
 Game.diagonalBlocks[0].angle := 45; { 45 degrés pour rediriger vers la gauche }
 
 { Bloc diagonal supplémentaire dans le coin supérieur gauche }
 Game.diagonalBlocks[1].x := TABLE_X + 10;
 Game.diagonalBlocks[1].y := TABLE_Y + 40;
 Game.diagonalBlocks[1].width := 50;
 Game.diagonalBlocks[1].height := 20;
 Game.diagonalBlocks[1].active := True;
 Game.diagonalBlocks[1].angle := -45; { -45 degrés pour rediriger vers la droite }
End;

Function CheckBallBounds: Boolean;
Begin
 CheckBallBounds := False;
 
 { Vérifier si la balle sort par le bas }
 If Game.ball.y > TABLE_Y + TABLE_HEIGHT Then
 Begin
  CheckBallBounds := True;
  Dec(Game.ballsLeft);
  If Game.ballsLeft <= 0 Then
   Game.gameState := gsGameOver
  Else
  Begin
   InitializeBall;
   Game.gameState := gsLaunching;
   Game.launchPower := 1;
   Game.lastAction := 'Balle perdue! Balles restantes: ' + IntToStr(Game.ballsLeft);
  End;
  Exit;
 End;
 
 { Rebonds sur les bords }
 If Game.ball.x < TABLE_X + BALL_RADIUS Then
 Begin
  Game.ball.x := TABLE_X + BALL_RADIUS;
  Game.ball.vx := -Game.ball.vx * BOUNCE_FACTOR;
 End;
 
 If Game.ball.x > TABLE_X + TABLE_WIDTH - BALL_RADIUS Then
 Begin
  Game.ball.x := TABLE_X + TABLE_WIDTH - BALL_RADIUS;
  Game.ball.vx := -Game.ball.vx * BOUNCE_FACTOR;
 End;
 
 If Game.ball.y < TABLE_Y + BALL_RADIUS Then
 Begin
  Game.ball.y := TABLE_Y + BALL_RADIUS;
  Game.ball.vy := -Game.ball.vy * BOUNCE_FACTOR;
 End;
End;

Function CheckFlipperCollision(var flipper: TFlipper): Boolean;
Var
 dx, dy, dist: Real;
 flipperEndX, flipperEndY: Real;
 radians: Real;
Begin
 CheckFlipperCollision := False;
 
 radians := flipper.angle * Pi / 180;
 flipperEndX := flipper.x + Cos(radians) * FLIPPER_LENGTH;
 flipperEndY := flipper.y + Sin(radians) * FLIPPER_LENGTH;
 
 { Distance du point au segment }
 dx := Game.ball.x - flipper.x;
 dy := Game.ball.y - flipper.y;
 dist := Sqrt(dx*dx + dy*dy);
 
 If dist < BALL_RADIUS + 8 Then
 Begin
  CheckFlipperCollision := True;
  
  { Calculer la direction de rebond }
  If dist > 0 Then
  Begin
   dx := dx / dist;
   dy := dy / dist;
   
   { Séparer la balle du flipper }
   Game.ball.x := flipper.x + dx * (BALL_RADIUS + 8);
   Game.ball.y := flipper.y + dy * (BALL_RADIUS + 8);
   
   { Appliquer la force du flipper }
   If flipper.active Then
   Begin
    Game.ball.vx := dx * FLIPPER_SPEED;
    Game.ball.vy := dy * FLIPPER_SPEED - 2; { Effet vers le haut }
    
    { Limiter la vitesse }
    If Abs(Game.ball.vx) > MAX_SPEED Then
     Game.ball.vx := Game.ball.vx / Abs(Game.ball.vx) * MAX_SPEED;
    If Abs(Game.ball.vy) > MAX_SPEED Then
     Game.ball.vy := Game.ball.vy / Abs(Game.ball.vy) * MAX_SPEED;
   End;
  End;
 End;
End;

Function CheckBumperCollision(var bumper: TBumper): Boolean;
Var
 dx, dy, dist: Real;
Begin
 CheckBumperCollision := False;
 
 If not bumper.active Then Exit;
 
 dx := Game.ball.x - bumper.x;
 dy := Game.ball.y - bumper.y;
 dist := Sqrt(dx*dx + dy*dy);
 
 If dist < BALL_RADIUS + 15 Then
 Begin
  CheckBumperCollision := True;
  Inc(bumper.hitCount);
  
  { Calculer la direction de rebond }
  If dist > 0 Then
  Begin
   dx := dx / dist;
   dy := dy / dist;
   
   { Séparer la balle du bumper }
   Game.ball.x := bumper.x + dx * (BALL_RADIUS + 15);
   Game.ball.y := bumper.y + dy * (BALL_RADIUS + 15);
   
   { Appliquer la force de rebond }
   Game.ball.vx := dx * 6;
   Game.ball.vy := dy * 6;
   
   { Bonus de score }
   Inc(Game.score, 100 * Game.bonusMultiplier);
   Inc(Game.combo);
   If Game.combo > 3 Then
    Game.bonusMultiplier := 2
   Else
    Game.bonusMultiplier := 1;
   
   Game.lastAction := 'Bumper! +' + IntToStr(100 * Game.bonusMultiplier) + ' points';
  End;
 End;
End;

Function CheckTargetCollision(var target: TTarget): Boolean;
Var
 dx, dy, dist: Real;
 i: Integer;
 allHit: Boolean;
Begin
 CheckTargetCollision := False;
 
 If (not target.active) or target.hit Then Exit;
 
 dx := Game.ball.x - target.x;
 dy := Game.ball.y - target.y;
 dist := Sqrt(dx*dx + dy*dy);
 
 If dist < BALL_RADIUS + 10 Then
 Begin
  CheckTargetCollision := True;
  target.hit := True;
  
  { Bonus de score }
  Inc(Game.score, 500 * Game.bonusMultiplier);
  Inc(Game.combo);
  If Game.combo > 3 Then
   Game.bonusMultiplier := 2
  Else
   Game.bonusMultiplier := 1;
  
  Game.lastAction := 'Target! +' + IntToStr(500 * Game.bonusMultiplier) + ' points';
  
  { Vérifier si tous les targets sont touchés }
  allHit := True;
  For i := 0 to MAX_TARGETS-1 do
   If Game.targets[i].active and not Game.targets[i].hit Then
    allHit := False;
  
  If allHit Then
  Begin
   Inc(Game.score, 5000);
   Game.lastAction := 'BONUS COMPLET! +5000 points';
   { Réinitialiser les targets }
   For i := 0 to MAX_TARGETS-1 do
    Game.targets[i].hit := False;
  End;
 End;
End;

Function CheckDiagonalBlockCollision(var block: TDiagonalBlock): Boolean;
Var
 dx, dy: Real;
 ballInBlock: Boolean;
 newVx, newVy: Real;
 radians: Real;
Begin
 CheckDiagonalBlockCollision := False;
 
 If not block.active Then Exit;
 
 { Vérifier si la balle est dans la zone du bloc }
 ballInBlock := (Game.ball.x >= block.x - BALL_RADIUS) and 
                (Game.ball.x <= block.x + block.width + BALL_RADIUS) and
                (Game.ball.y >= block.y - BALL_RADIUS) and 
                (Game.ball.y <= block.y + block.height + BALL_RADIUS);
 
 If ballInBlock Then
 Begin
  CheckDiagonalBlockCollision := True;
  
  { Calculer l'angle de rebond basé sur l'angle du bloc }
  radians := block.angle * Pi / 180;
  
  { Refléter la vitesse selon l'angle du bloc diagonal }
  If block.angle > 0 Then
  Begin
   { Bloc diagonal descendant vers la droite - rebond vers la gauche }
   newVx := -Abs(Game.ball.vx) - Game.ball.vy * 0.5;
   newVy := -Game.ball.vy * 0.8;
  End
  Else
  Begin
   { Bloc diagonal descendant vers la gauche - rebond vers la droite }
   newVx := Abs(Game.ball.vx) + Game.ball.vy * 0.5;
   newVy := -Game.ball.vy * 0.8;
  End;
  
  { Appliquer la nouvelle vitesse }
  Game.ball.vx := newVx;
  Game.ball.vy := newVy;
  
  { Séparer la balle du bloc }
  If Game.ball.x < block.x + block.width / 2 Then
   Game.ball.x := block.x - BALL_RADIUS - 1
  Else
   Game.ball.x := block.x + block.width + BALL_RADIUS + 1;
  
  { Bonus de score }
  Inc(Game.score, 50 * Game.bonusMultiplier);
  Game.lastAction := 'Rebond diagonal! +' + IntToStr(50 * Game.bonusMultiplier) + ' points';
 End;
End;

Procedure UpdateBall;
Var
 i: Integer;
Begin
 If not Game.ball.active Then Exit;
 
 { Réinitialiser le combo si la balle est lente }
 If (Abs(Game.ball.vx) < 1) and (Abs(Game.ball.vy) < 1) Then
 Begin
  Game.combo := 0;
  Game.bonusMultiplier := 1;
 End;
 
 { Appliquer la gravité }
 Game.ball.vy := Game.ball.vy + GRAVITY;
 
 { Appliquer la friction }
 Game.ball.vx := Game.ball.vx * FRICTION;
 Game.ball.vy := Game.ball.vy * FRICTION;
 
 { Limiter la vitesse }
 If Abs(Game.ball.vx) > MAX_SPEED Then
  Game.ball.vx := Game.ball.vx / Abs(Game.ball.vx) * MAX_SPEED;
 If Abs(Game.ball.vy) > MAX_SPEED Then
  Game.ball.vy := Game.ball.vy / Abs(Game.ball.vy) * MAX_SPEED;
 
 { Mettre à jour la position }
 Game.ball.x := Game.ball.x + Game.ball.vx;
 Game.ball.y := Game.ball.y + Game.ball.vy;
 
 { Vérifier les collisions }
 CheckBallBounds;
 CheckFlipperCollision(Game.leftFlipper);
 CheckFlipperCollision(Game.rightFlipper);
 
 { Vérifier les collisions avec les bumpers }
 For i := 0 to MAX_BUMPERS-1 do
  CheckBumperCollision(Game.bumpers[i]);
 
 { Vérifier les collisions avec les targets }
 For i := 0 to MAX_TARGETS-1 do
  CheckTargetCollision(Game.targets[i]);
 
 { Vérifier les collisions avec les blocs diagonaux }
 For i := 0 to MAX_DIAGONAL_BLOCKS-1 do
  CheckDiagonalBlockCollision(Game.diagonalBlocks[i]);
End;

Procedure UpdateFlippers;
Begin
 { Mettre à jour l'angle des flippers }
 If Game.leftFlipper.angle < Game.leftFlipper.targetAngle Then
 Begin
  Game.leftFlipper.angle := Game.leftFlipper.angle + 5;
  If Game.leftFlipper.angle > Game.leftFlipper.targetAngle Then
   Game.leftFlipper.angle := Game.leftFlipper.targetAngle;
 End
 Else If Game.leftFlipper.angle > Game.leftFlipper.targetAngle Then
 Begin
  Game.leftFlipper.angle := Game.leftFlipper.angle - 5;
  If Game.leftFlipper.angle < Game.leftFlipper.targetAngle Then
   Game.leftFlipper.angle := Game.leftFlipper.targetAngle;
 End;
 
 If Game.rightFlipper.angle < Game.rightFlipper.targetAngle Then
 Begin
  Game.rightFlipper.angle := Game.rightFlipper.angle + 5;
  If Game.rightFlipper.angle > Game.rightFlipper.targetAngle Then
   Game.rightFlipper.angle := Game.rightFlipper.targetAngle;
 End
 Else If Game.rightFlipper.angle > Game.rightFlipper.targetAngle Then
 Begin
  Game.rightFlipper.angle := Game.rightFlipper.angle - 5;
  If Game.rightFlipper.angle < Game.rightFlipper.targetAngle Then
   Game.rightFlipper.angle := Game.rightFlipper.targetAngle;
 End;
End;

Procedure LaunchBall;
Begin
 If Game.gameState = gsLaunching Then
 Begin
  Game.ball.vx := 0;
  Game.ball.vy := -Game.launchPower * 50; { Multiplié par 50 pour force maximale }
  Game.ball.launched := True;
  Game.gameState := gsPlaying;
  Game.lastAction := 'Balle lancée! Force: ' + IntToStr(Game.launchPower);
 End;
End;

Procedure DrawTable;
Begin
 { Fond de la table }
 SetColor(1);
 SetFillStyle(1, 1);
 Bar(TABLE_X, TABLE_Y, TABLE_X + TABLE_WIDTH, TABLE_Y + TABLE_HEIGHT);
 
 { Contour de la table }
 SetColor(15);
 SetLineStyle(0, 0, 2);
 Rectangle(TABLE_X, TABLE_Y, TABLE_X + TABLE_WIDTH, TABLE_Y + TABLE_HEIGHT);
 
 { Canal de lancement }
 SetColor(8);
 SetFillStyle(1, 8);
 Bar(TABLE_X + TABLE_WIDTH - 40, TABLE_Y + TABLE_HEIGHT - 100, 
     TABLE_X + TABLE_WIDTH, TABLE_Y + TABLE_HEIGHT);
 
 { Lignes de guidage }
 SetColor(7);
 SetLineStyle(0, 0, 1);
 Line(TABLE_X + 50, TABLE_Y + 50, TABLE_X + TABLE_WIDTH - 50, TABLE_Y + 50);
 Line(TABLE_X + 50, TABLE_Y + 250, TABLE_X + TABLE_WIDTH - 50, TABLE_Y + 250);
End;

Procedure DrawBall;
Begin
 If Game.ball.active Then
 Begin
  SetColor(14);
  SetFillStyle(1, 14);
  Circle(Round(Game.ball.x), Round(Game.ball.y), BALL_RADIUS);
  FloodFill(Round(Game.ball.x), Round(Game.ball.y), 14);
  
  { Contour }
  SetColor(15);
  Circle(Round(Game.ball.x), Round(Game.ball.y), BALL_RADIUS);
 End;
End;

Procedure DrawFlipper(flipper: TFlipper);
Var
 endX, endY: Real;
 radians: Real;
Begin
 If flipper.active Then
 Begin
  radians := flipper.angle * Pi / 180;
  endX := flipper.x + Cos(radians) * FLIPPER_LENGTH;
  endY := flipper.y + Sin(radians) * FLIPPER_LENGTH;
  
  SetColor(15);
  SetLineStyle(0, 0, 4);
  Line(Round(flipper.x), Round(flipper.y), Round(endX), Round(endY));
  
  { Base du flipper }
  SetColor(12);
  SetFillStyle(1, 12);
  Circle(Round(flipper.x), Round(flipper.y), 6);
  FloodFill(Round(flipper.x), Round(flipper.y), 12);
 End;
End;

Procedure DrawBumpers;
Var
 i: Integer;
Begin
 For i := 0 to MAX_BUMPERS-1 do
 Begin
  If Game.bumpers[i].active Then
  Begin
   If Game.bumpers[i].hitCount > 0 Then
    SetColor(12 + (Game.bumpers[i].hitCount mod 4))
   Else
    SetColor(10);
   
   SetFillStyle(1, GetColor);
   Circle(Game.bumpers[i].x, Game.bumpers[i].y, 15);
   FloodFill(Game.bumpers[i].x, Game.bumpers[i].y, GetColor);
   
   { Contour }
   SetColor(15);
   Circle(Game.bumpers[i].x, Game.bumpers[i].y, 15);
  End;
 End;
End;

Procedure DrawTargets;
Var
 i: Integer;
Begin
 For i := 0 to MAX_TARGETS-1 do
 Begin
  If Game.targets[i].active Then
  Begin
   If Game.targets[i].hit Then
    SetColor(8)
   Else
    SetColor(13);
   
   SetFillStyle(1, GetColor);
   Circle(Game.targets[i].x, Game.targets[i].y, 10);
   FloodFill(Game.targets[i].x, Game.targets[i].y, GetColor);
   
   { Contour }
   SetColor(15);
   Circle(Game.targets[i].x, Game.targets[i].y, 10);
  End;
 End;
End;

Procedure DrawDiagonalBlocks;
Var
 i: Integer;
Begin
 For i := 0 to MAX_DIAGONAL_BLOCKS-1 do
 Begin
  If Game.diagonalBlocks[i].active Then
  Begin
   SetColor(9);
   SetFillStyle(1, 9);
   
   { Dessiner le bloc diagonal }
   If Game.diagonalBlocks[i].angle > 0 Then
   Begin
    { Bloc diagonal descendant vers la droite (\) }
    Line(Game.diagonalBlocks[i].x, Game.diagonalBlocks[i].y,
         Game.diagonalBlocks[i].x + Game.diagonalBlocks[i].width,
         Game.diagonalBlocks[i].y + Game.diagonalBlocks[i].height);
   End
   Else
   Begin
    { Bloc diagonal descendant vers la gauche (/) }
    Line(Game.diagonalBlocks[i].x + Game.diagonalBlocks[i].width, Game.diagonalBlocks[i].y,
         Game.diagonalBlocks[i].x,
         Game.diagonalBlocks[i].y + Game.diagonalBlocks[i].height);
   End;
   
   { Contour du bloc }
   SetColor(15);
   SetLineStyle(0, 0, 3);
   Rectangle(Game.diagonalBlocks[i].x, Game.diagonalBlocks[i].y,
            Game.diagonalBlocks[i].x + Game.diagonalBlocks[i].width,
            Game.diagonalBlocks[i].y + Game.diagonalBlocks[i].height);
   SetLineStyle(0, 0, 1);
  End;
 End;
End;

Procedure DrawLaunchMeter;
Begin
 If Game.gameState = gsLaunching Then
 Begin
  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(TABLE_X + TABLE_WIDTH + 10, TABLE_Y + TABLE_HEIGHT - 80, 'LANCEMENT');
  
  { Indicateur de puissance }
  SetColor(14);
  SetFillStyle(1, 14);
  Bar(TABLE_X + TABLE_WIDTH + 10, TABLE_Y + TABLE_HEIGHT - 60, 
      TABLE_X + TABLE_WIDTH + 10 + Game.launchPower * 3, TABLE_Y + TABLE_HEIGHT - 50);
  
  { Cadre }
  SetColor(15);
  Rectangle(TABLE_X + TABLE_WIDTH + 10, TABLE_Y + TABLE_HEIGHT - 60, 
           TABLE_X + TABLE_WIDTH + 10 + LAUNCH_POWER * 3, TABLE_Y + TABLE_HEIGHT - 50);
 End;
End;

Procedure DrawGameInfo;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 2);
 OutTextXY(10, 20, 'PINBALL');
 
 SetTextStyle(0, 0, 1);
 OutTextXY(10, 50, 'Score: ' + IntToStr(Game.score));
 OutTextXY(10, 70, 'Balles: ' + IntToStr(Game.ballsLeft));
 
 If Game.combo > 0 Then
 Begin
  SetColor(14);
  OutTextXY(10, 90, 'Combo: ' + IntToStr(Game.combo));
  OutTextXY(10, 110, 'Bonus: x' + IntToStr(Game.bonusMultiplier));
 End;
 
 SetColor(15);
 OutTextXY(10, 140, 'Commandes:');
 OutTextXY(10, 160, 'A/Z: Flipper gauche');
 OutTextXY(10, 180, 'P/M: Flipper droit');
 OutTextXY(10, 200, 'ESPACE: Lancer');
 OutTextXY(10, 220, 'N: Nouvelle partie');
 OutTextXY(10, 240, 'ESC: Quitter');
 
 If Game.lastAction <> '' Then
 Begin
  SetColor(11);
  OutTextXY(10, 280, Game.lastAction);
 End;
End;

Procedure DrawGameStatus;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 
 Case Game.gameState of
  gsGameOver: Begin
   OutTextXY(200, 200, 'PARTIE TERMINEE');
   OutTextXY(200, 230, 'Score final: ' + IntToStr(Game.score));
   OutTextXY(200, 260, 'Appuyez sur N pour rejouer');
  End;
 End;
End;

Procedure HandleInput;
Var
 key: Char;
Begin
 If KeyPressed Then
 Begin
  key := ReadKey;
  Case key of
   'a', 'A', 'z', 'Z': Begin { Flipper gauche }
    If Game.gameState = gsPlaying Then
    Begin
     Game.leftFlipper.targetAngle := -30;
     Game.leftFlipper.active := True;
    End;
   End;
   'p', 'P', 'm', 'M': Begin { Flipper droit }
    If Game.gameState = gsPlaying Then
    Begin
     Game.rightFlipper.targetAngle := 30;
     Game.rightFlipper.active := True;
    End;
   End;
   ' ': Begin { Espace - Lancer }
    If Game.gameState = gsLaunching Then
     LaunchBall;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   #0: Begin
    key := ReadKey;
    Case key of
     #72: Begin { Flèche haut }
      If Game.gameState = gsLaunching Then
      Begin
       Inc(Game.launchPower);
       If Game.launchPower > LAUNCH_POWER Then
        Game.launchPower := LAUNCH_POWER;
       Game.needRedraw := True;
      End;
     End;
     #80: Begin { Flèche bas }
      If Game.gameState = gsLaunching Then
      Begin
       Dec(Game.launchPower);
       If Game.launchPower < 1 Then
        Game.launchPower := 1;
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
 
 { Relâcher les flippers }
 If not KeyPressed Then
 Begin
  Game.leftFlipper.targetAngle := 30;
  Game.rightFlipper.targetAngle := -30;
 End;
End;

Procedure ProcessGame;
Begin
 If Game.gameState = gsPlaying Then
 Begin
  UpdateBall;
  UpdateFlippers;
  Game.needRedraw := True;
 End;
End;

Procedure Render;
Begin
 If Game.needRedraw Then
 Begin
  { Fond }
  SetColor(0);
  SetFillStyle(1, 0);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  
  DrawTable;
  DrawBall;
  DrawFlipper(Game.leftFlipper);
  DrawFlipper(Game.rightFlipper);
  DrawBumpers;
  DrawTargets;
  DrawDiagonalBlocks;
  DrawLaunchMeter;
  DrawGameInfo;
  DrawGameStatus;
  
  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;
Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 60, 'PINBALL');
 
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de flipper classique');
 
 OutTextXY(50, 150, 'Regles:');
 OutTextXY(50, 170, '- Utilisez les flippers pour maintenir la balle en jeu');
 OutTextXY(50, 190, '- Touchez les bumpers et targets pour marquer des points');
 OutTextXY(50, 210, '- Enchainez les hits pour des bonus de combo');
 OutTextXY(50, 230, '- Completez tous les targets pour un super bonus');
 
 OutTextXY(50, 260, 'Commandes:');
 OutTextXY(50, 280, 'A/Z: Flipper gauche');
 OutTextXY(50, 300, 'P/M: Flipper droit');
 OutTextXY(50, 320, 'ESPACE: Lancer la balle');
 OutTextXY(50, 340, 'Fleches: Ajuster puissance de lancement');
 OutTextXY(50, 360, 'N: Nouvelle partie');
 OutTextXY(50, 380, 'ESC: Quitter');
 
 OutTextXY(50, 410, 'Appuyez sur une touche pour commencer...');
 
 ReadKey;
End;

Procedure InitializeGame;
Begin
 InitializeBall;
 InitializeFlippers;
 InitializeBumpers;
 InitializeTargets;
 InitializeDiagonalBlocks;
 
 Game.gameState := gsLaunching;
 Game.score := 0;
 Game.ballsLeft := 3;
 Game.launchPower := 8;
 Game.needRedraw := True;
 Game.lastAction := 'Nouvelle partie - Lancez la balle!';
 Game.combo := 0;
 Game.bonusMultiplier := 1;
End;

Procedure GameLoop;
Begin
 While Game.gameState <> gsQuit do
 Begin
  HandleInput;
  ProcessGame;
  Render;
  Delay(50);
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
 If ErrCode <> grOk Then
 Begin
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
