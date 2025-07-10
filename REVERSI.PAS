{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Reversi (Othello) - Retournez les pions adverses
}

Program Reversi;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 BOARD_SIZE = 8;
 CELL_SIZE = 40;
 BOARD_X = 50;
 BOARD_Y = 50;
 DISC_RADIUS = 15;

Type
 TPlayer = (pEmpty, pBlack, pWhite);
 TGameState = (gsPlaying, gsBlackWins, gsWhiteWins, gsDraw, gsQuit);
 TGameMode = (gmHumanVsHuman, gmHumanVsComputer);

 TBoard = Array[0..BOARD_SIZE-1, 0..BOARD_SIZE-1] of TPlayer;

 TGame = Record
  board: TBoard;
  currentPlayer: TPlayer;
  gameState: TGameState;
  gameMode: TGameMode;
  selectedRow, selectedCol: Integer;
  needRedraw: Boolean;
  blackScore, whiteScore: Integer;
  canMove: Boolean;
  passCount: Integer;
 End;

Var
 Game: TGame;

{ Déclarations forward }
Procedure InitializeGame; Forward;

Function GetPlayerColor(player: TPlayer): Integer;
Begin
 Case player of
  pBlack: GetPlayerColor := 0;
  pWhite: GetPlayerColor := 15;
  else GetPlayerColor := 8;
 End;
End;

Function GetPlayerName(player: TPlayer): String;
Begin
 Case player of
  pBlack: GetPlayerName := 'Noir';
  pWhite: GetPlayerName := 'Blanc';
  else GetPlayerName := 'Vide';
 End;
End;

Function OpponentPlayer(player: TPlayer): TPlayer;
Begin
 If player = pBlack Then
  OpponentPlayer := pWhite
 Else
  OpponentPlayer := pBlack;
End;

Procedure ClearBoard;
Var
 row, col: Integer;
Begin
 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
   Game.board[row, col] := pEmpty;
End;

Procedure SetupInitialPosition;
Begin
 ClearBoard;

 { Position initiale du Reversi }
 Game.board[3, 3] := pWhite;
 Game.board[3, 4] := pBlack;
 Game.board[4, 3] := pBlack;
 Game.board[4, 4] := pWhite;
End;

Function IsValidPosition(row, col: Integer): Boolean;
Begin
 IsValidPosition := (row >= 0) and (row < BOARD_SIZE) and
                   (col >= 0) and (col < BOARD_SIZE);
End;

Function CheckDirection(row, col, deltaRow, deltaCol: Integer; player: TPlayer): Integer;
Var
 r, c, count: Integer;
 opponent: TPlayer;
Begin
 CheckDirection := 0;
 opponent := OpponentPlayer(player);

 r := row + deltaRow;
 c := col + deltaCol;
 count := 0;

 { Compter les pions adverses dans cette direction }
 While IsValidPosition(r, c) and (Game.board[r, c] = opponent) do
 Begin
  Inc(count);
  r := r + deltaRow;
  c := c + deltaCol;
 End;

 { Vérifier si on trouve un pion de notre couleur à la fin }
 If IsValidPosition(r, c) and (Game.board[r, c] = player) and (count > 0) Then
  CheckDirection := count;
End;

Function IsValidMove(row, col: Integer; player: TPlayer): Boolean;
Var
 deltaRow, deltaCol: Integer;
Begin
 IsValidMove := False;

 { La case doit être vide }
 If Game.board[row, col] <> pEmpty Then Exit;

 { Vérifier toutes les directions }
 For deltaRow := -1 to 1 do
  For deltaCol := -1 to 1 do
   If (deltaRow <> 0) or (deltaCol <> 0) Then
    If CheckDirection(row, col, deltaRow, deltaCol, player) > 0 Then
    Begin
     IsValidMove := True;
     Exit;
    End;
End;

Procedure FlipDiscs(row, col: Integer; player: TPlayer);
Var
 deltaRow, deltaCol, flipCount, i: Integer;
 r, c: Integer;
Begin
 { Vérifier toutes les directions }
 For deltaRow := -1 to 1 do
  For deltaCol := -1 to 1 do
   If (deltaRow <> 0) or (deltaCol <> 0) Then
   Begin
    flipCount := CheckDirection(row, col, deltaRow, deltaCol, player);
    If flipCount > 0 Then
    Begin
     { Retourner les pions dans cette direction }
     r := row + deltaRow;
     c := col + deltaCol;
     For i := 1 to flipCount do
     Begin
      Game.board[r, c] := player;
      r := r + deltaRow;
      c := c + deltaCol;
     End;
    End;
   End;
End;

Function MakeMove(row, col: Integer; player: TPlayer): Boolean;
Begin
 MakeMove := False;

 If IsValidMove(row, col, player) Then
 Begin
  Game.board[row, col] := player;
  FlipDiscs(row, col, player);
  MakeMove := True;
 End;
End;

Function HasValidMoves(player: TPlayer): Boolean;
Var
 row, col: Integer;
Begin
 HasValidMoves := False;

 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
   If IsValidMove(row, col, player) Then
   Begin
    HasValidMoves := True;
    Exit;
   End;
End;

Procedure CountScore;
Var
 row, col: Integer;
Begin
 Game.blackScore := 0;
 Game.whiteScore := 0;

 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
   Case Game.board[row, col] of
    pBlack: Inc(Game.blackScore);
    pWhite: Inc(Game.whiteScore);
   End;
End;

Procedure CheckGameEnd;
Begin
 CountScore;

 If not HasValidMoves(Game.currentPlayer) Then
 Begin
  Game.currentPlayer := OpponentPlayer(Game.currentPlayer);
  Inc(Game.passCount);

  If not HasValidMoves(Game.currentPlayer) Then
  Begin
   { Aucun joueur ne peut jouer - fin de partie }
   If Game.blackScore > Game.whiteScore Then
    Game.gameState := gsBlackWins
   Else If Game.whiteScore > Game.blackScore Then
    Game.gameState := gsWhiteWins
   Else
    Game.gameState := gsDraw;
  End
  Else
   Game.passCount := 0;
 End
 Else
  Game.passCount := 0;
End;

Function EvaluatePosition(player: TPlayer): Integer;
Var
 row, col, score, corners, edges: Integer;
Begin
 score := 0;
 corners := 0;
 edges := 0;

 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
   If Game.board[row, col] = player Then
   Begin
    Inc(score);

    { Bonus pour les coins }
    If ((row = 0) or (row = BOARD_SIZE-1)) and
       ((col = 0) or (col = BOARD_SIZE-1)) Then
     Inc(corners, 25);

    { Bonus pour les bords }
    If (row = 0) or (row = BOARD_SIZE-1) or
       (col = 0) or (col = BOARD_SIZE-1) Then
     Inc(edges, 5);
   End
   Else If Game.board[row, col] = OpponentPlayer(player) Then
   Begin
    Dec(score);

    { Malus pour les coins adverses }
    If ((row = 0) or (row = BOARD_SIZE-1)) and
       ((col = 0) or (col = BOARD_SIZE-1)) Then
     Dec(corners, 25);
   End;

 EvaluatePosition := score + corners + edges;
End;

Function GetBestMove(player: TPlayer; Var bestRow, bestCol: Integer): Boolean;
Var
 row, col, score, bestScore: Integer;
 tempBoard: TBoard;
 i, j: Integer;
Begin
 GetBestMove := False;
 bestScore := -1000;
 bestRow := -1;
 bestCol := -1;

 { Sauvegarder le plateau }
 For i := 0 to BOARD_SIZE-1 do
  For j := 0 to BOARD_SIZE-1 do
   tempBoard[i, j] := Game.board[i, j];

 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
   If IsValidMove(row, col, player) Then
   Begin
    { Simuler le coup }
    Game.board[row, col] := player;
    FlipDiscs(row, col, player);

    score := EvaluatePosition(player);

    If score > bestScore Then
    Begin
     bestScore := score;
     bestRow := row;
     bestCol := col;
     GetBestMove := True;
    End;

    { Restaurer le plateau }
    For i := 0 to BOARD_SIZE-1 do
     For j := 0 to BOARD_SIZE-1 do
      Game.board[i, j] := tempBoard[i, j];
   End;
End;

Procedure ComputerMove;
Var
 row, col: Integer;
Begin
 If (Game.gameMode = gmHumanVsComputer) and (Game.currentPlayer = pWhite) and
    (Game.gameState = gsPlaying) Then
 Begin
  Delay(500);

  If GetBestMove(pWhite, row, col) Then
  Begin
   MakeMove(row, col, pWhite);
   Game.currentPlayer := pBlack;
   Game.needRedraw := True;
   CheckGameEnd;
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
   #0: Begin
    key := ReadKey;
    Case key of
     #72: Begin { Flèche haut }
      If Game.selectedRow > 0 Then
      Begin
       Dec(Game.selectedRow);
       Game.needRedraw := True;
      End;
     End;
     #80: Begin { Flèche bas }
      If Game.selectedRow < BOARD_SIZE-1 Then
      Begin
       Inc(Game.selectedRow);
       Game.needRedraw := True;
      End;
     End;
     #75: Begin { Flèche gauche }
      If Game.selectedCol > 0 Then
      Begin
       Dec(Game.selectedCol);
       Game.needRedraw := True;
      End;
     End;
     #77: Begin { Flèche droite }
      If Game.selectedCol < BOARD_SIZE-1 Then
      Begin
       Inc(Game.selectedCol);
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   #13, ' ': Begin { Entrée ou Espace }
    If (Game.gameState = gsPlaying) and
       ((Game.gameMode = gmHumanVsHuman) or (Game.currentPlayer = pBlack)) Then
    Begin
     If MakeMove(Game.selectedRow, Game.selectedCol, Game.currentPlayer) Then
     Begin
      Game.currentPlayer := OpponentPlayer(Game.currentPlayer);
      Game.needRedraw := True;
      CheckGameEnd;
     End;
    End;
   End;
   'p', 'P': Begin { Passer le tour }
    If Game.gameState = gsPlaying Then
    Begin
     Game.currentPlayer := OpponentPlayer(Game.currentPlayer);
     Game.needRedraw := True;
     CheckGameEnd;
    End;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   'm', 'M': Begin { Changer mode }
    If Game.gameMode = gmHumanVsHuman Then
     Game.gameMode := gmHumanVsComputer
    Else
     Game.gameMode := gmHumanVsHuman;
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure DrawDisc(x, y: Integer; player: TPlayer; selected: Boolean);
Begin
 If selected Then
 Begin
  SetColor(14);
  Circle(x, y, DISC_RADIUS + 2);
 End;

 Case player of
  pBlack: Begin
   SetColor(0);
   SetFillStyle(1, 0);
   FillEllipse(x, y, DISC_RADIUS, DISC_RADIUS);
   SetColor(15);
   Circle(x, y, DISC_RADIUS);
  End;
  pWhite: Begin
   SetColor(15);
   SetFillStyle(1, 15);
   FillEllipse(x, y, DISC_RADIUS, DISC_RADIUS);
   SetColor(0);
   Circle(x, y, DISC_RADIUS);
  End;
 End;
End;

Procedure DrawBoard;
Var
 row, col, x, y: Integer;
 validMove: Boolean;
Begin
 { Dessiner le plateau }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(BOARD_X - 5, BOARD_Y - 5,
     BOARD_X + BOARD_SIZE * CELL_SIZE + 5,
     BOARD_Y + BOARD_SIZE * CELL_SIZE + 5);

 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do
  Begin
   x := BOARD_X + col * CELL_SIZE;
   y := BOARD_Y + row * CELL_SIZE;

   { Dessiner la case }
   SetColor(0);
   Rectangle(x, y, x + CELL_SIZE, y + CELL_SIZE);

   { Marquer les coups valides }
   validMove := IsValidMove(row, col, Game.currentPlayer);
   If validMove and (Game.gameState = gsPlaying) Then
   Begin
    SetColor(14);
    SetFillStyle(1, 14);
    Bar(x + 2, y + 2, x + CELL_SIZE - 2, y + CELL_SIZE - 2);
   End;

   { Dessiner le pion }
   If Game.board[row, col] <> pEmpty Then
   Begin
    DrawDisc(x + CELL_SIZE div 2, y + CELL_SIZE div 2,
             Game.board[row, col],
             (row = Game.selectedRow) and (col = Game.selectedCol));
   End
   Else If (row = Game.selectedRow) and (col = Game.selectedCol) Then
   Begin
    SetColor(15);
    Rectangle(x + 5, y + 5, x + CELL_SIZE - 5, y + CELL_SIZE - 5);
   End;
  End;
End;

Procedure DrawGameInfo;
Var
 modeStr, scoreStr: String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);

 If Game.gameMode = gmHumanVsHuman Then
  modeStr := '2 Joueurs'
 Else
  modeStr := 'vs Ordinateur';

 OutTextXY(400, 50, 'Mode: ' + modeStr);

 Str(Game.blackScore, scoreStr);
 OutTextXY(400, 80, 'Noir: ' + scoreStr);

 Str(Game.whiteScore, scoreStr);
 OutTextXY(400, 100, 'Blanc: ' + scoreStr);

 If Game.gameState = gsPlaying Then
  OutTextXY(400, 130, 'Tour: ' + GetPlayerName(Game.currentPlayer))
 Else
  OutTextXY(400, 130, 'Partie terminee');

 If Game.passCount > 0 Then
  OutTextXY(400, 150, 'Joueur passe...');
End;

Procedure DrawInstructions;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(400, 200, 'REVERSI (OTHELLO)');
 OutTextXY(400, 230, 'Regles:');
 OutTextXY(400, 250, '- Encadrez les pions');
 OutTextXY(400, 270, '  adverses pour les');
 OutTextXY(400, 290, '  retourner');
 OutTextXY(400, 310, '- Plus de pions = victoire');

 OutTextXY(400, 350, 'Commandes:');
 OutTextXY(400, 370, 'Fleches: Deplacer curseur');
 OutTextXY(400, 390, 'ENTREE: Jouer');
 OutTextXY(400, 410, 'P: Passer tour');
 OutTextXY(400, 430, 'N: Nouvelle partie');
 OutTextXY(400, 450, 'M: Changer mode');
End;

Procedure DrawGameStatus;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);

 Case Game.gameState of
  gsPlaying: Begin
   If not HasValidMoves(Game.currentPlayer) Then
   Begin
    SetColor(12);
    OutTextXY(50, 400, 'Aucun coup possible!');
    SetColor(15);
    SetTextStyle(0, 0, 1);
    OutTextXY(50, 420, 'Appuyez sur P pour passer');
   End;
  End;
  gsBlackWins: Begin
   OutTextXY(50, 400, 'NOIR GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 430, 'N: Nouvelle partie');
  End;
  gsWhiteWins: Begin
   OutTextXY(50, 400, 'BLANC GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 430, 'N: Nouvelle partie');
  End;
  gsDraw: Begin
   OutTextXY(50, 400, 'MATCH NUL!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 430, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure Render;
Begin
 If Game.needRedraw Then
 Begin
  { Fond }
  SetColor(8);
  SetFillStyle(1, 8);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 2);
  OutTextXY(50, 20, 'REVERSI');

  DrawBoard;
  DrawGameInfo;
  DrawInstructions;
  DrawGameStatus;

  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;
Begin
 SetColor(8);
 SetFillStyle(1, 8);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 80, 'REVERSI');
 OutTextXY(SCREEN_WIDTH div 2 - 120, 120, '(OTHELLO)');

 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 180, 'Le but est d''avoir le plus de pions de votre couleur');
 OutTextXY(50, 200, 'a la fin de la partie.');

 OutTextXY(50, 230, 'Regles:');
 OutTextXY(50, 250, '- Placez un pion pour encadrer des pions adverses');
 OutTextXY(50, 270, '- Tous les pions encadres sont retournes');
 OutTextXY(50, 290, '- Vous devez encadrer au moins un pion');
 OutTextXY(50, 310, '- Si aucun coup possible, vous passez votre tour');

 OutTextXY(50, 350, 'Commandes:');
 OutTextXY(50, 370, 'Fleches: Deplacer le curseur');
 OutTextXY(50, 390, 'ENTREE/ESPACE: Placer un pion');
 OutTextXY(50, 410, 'P: Passer votre tour');

 OutTextXY(50, 450, 'Choisissez le mode: 1=vs IA, 2=2 joueurs, ESC=Quitter');

 Repeat
  If KeyPressed Then
  Begin
   Case ReadKey of
    '1': Begin
     Game.gameMode := gmHumanVsComputer;
     Exit;
    End;
    '2': Begin
     Game.gameMode := gmHumanVsHuman;
     Exit;
    End;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;
Begin
 SetupInitialPosition;
 Game.currentPlayer := pBlack;
 Game.gameState := gsPlaying;
 Game.selectedRow := 3;
 Game.selectedCol := 3;
 Game.needRedraw := True;
 Game.passCount := 0;
 CountScore;
End;

Procedure GameLoop;
Begin
 While Game.gameState <> gsQuit do
 Begin
  HandleInput;
  ComputerMove;
  Render;
  Delay(100);
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
