{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu d'Othello - Strategie et retournement de pions
}

Program Othello;

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
 CELL_SIZE = 45;
 BOARD_X = 80;
 BOARD_Y = 60;
 DISC_RADIUS = 18;

Type
 TPlayer = (pEmpty, pBlack, pWhite);
 TGameState = (gsPlaying, gsBlackWins, gsWhiteWins, gsDraw, gsQuit);
 TDifficulty = (diffEasy, diffMedium, diffHard);

 TBoard=Array[0..BOARD_SIZE-1, 0..BOARD_SIZE-1] of TPlayer;

 TMove=Record
  row,col:Integer;
  score:Integer;
 End;

 TGame=Record
  board:TBoard;
  currentPlayer:TPlayer;
  gameState:TGameState;
  selectedRow,selectedCol:Integer;
  needRedraw:Boolean;
  blackScore,whiteScore: Integer;
  difficulty:TDifficulty;
  gameMode:Integer; { 1=vs Computer, 2=vs Human }
  moveCount:Integer;
  lastMove:TMove;
  showHints:Boolean;
 End;

Var
 Game:TGame;

{ DÇclarations forward }
Procedure InitializeGame; Forward;

Function GetPlayerColor(player:TPlayer):Integer;Begin
 Case player of
  pBlack: GetPlayerColor := 0;
  pWhite: GetPlayerColor := 15;
  else GetPlayerColor := 7;
 End;
End;

Function GetPlayerName(player:TPlayer):String;Begin
 Case player of
  pBlack: GetPlayerName := 'Noir';
  pWhite: GetPlayerName := 'Blanc';
  else GetPlayerName := 'Vide';
 End;
End;

Function GetDifficultyName(diff:TDifficulty):String;Begin
 Case diff of
  diffEasy: GetDifficultyName := 'Facile';
  diffMedium: GetDifficultyName := 'Moyen';
  diffHard: GetDifficultyName := 'Difficile';
 End;
End;

Function OpponentPlayer(player:TPlayer):TPlayer;Begin
 If player=pBlack Then OpponentPlayer:=pWhite
                  Else OpponentPlayer:=pBlack;
End;

Procedure ClearBoard;
Var
 row,col:Integer;
Begin
 For row:=0 to BOARD_SIZE-1 do For col := 0 to BOARD_SIZE-1 do
  Game.board[row, col] := pEmpty;
End;

Procedure SetupInitialPosition;Begin
 ClearBoard;
  { Position initiale d'Othello }
 Game.board[3, 3] := pWhite;
 Game.board[3, 4] := pBlack;
 Game.board[4, 3] := pBlack;
 Game.board[4, 4] := pWhite;
 Game.moveCount := 0;
 Game.lastMove.row := -1;
 Game.lastMove.col := -1;
End;

Function IsValidPosition(row,col:Integer):Boolean;Begin
 IsValidPosition := (row >= 0) and (row < BOARD_SIZE) and
                   (col >= 0) and (col < BOARD_SIZE);
End;

Function CountFlipsInDirection(row,col,deltaRow,deltaCol:Integer;player:TPlayer):Integer;
Var
 r,c,count:Integer;
 opponent:TPlayer;
Begin
 CountFlipsInDirection:=0;
 opponent:=OpponentPlayer(player);
 r:=row+deltaRow;
 c:=col+deltaCol;
 count:=0;
  { Compter les pions adverses dans cette direction }
 While IsValidPosition(r,c)and(Game.board[r,c]=opponent) do Begin
  Inc(count);
  r:=r+deltaRow;
  c:=c+deltaCol;
 End;
  { VÇrifier si on trouve un pion de notre couleur Ö la fin }
 If IsValidPosition(r,c)and(Game.board[r,c]=player)and(count>0)Then
  CountFlipsInDirection:=count;
End;

Function IsValidMove(row,col:Integer;player:TPlayer):Boolean;
Var
 deltaRow,deltaCol:Integer;
Begin
 IsValidMove:=False;
 { La case doit àtre vide }
 If Game.board[row, col]<>pEmpty Then Exit;
  { VÇrifier toutes les directions }
 For deltaRow:=-1 to 1 do For deltaCol:=-1 to 1 do
   If (deltaRow<>0)or(deltaCol<>0)Then
    If CountFlipsInDirection(row,col,deltaRow,deltaCol,player)>0 Then Begin
     IsValidMove := True;
     Exit;
    End;
End;

Function CountTotalFlips(row,col:Integer;player:TPlayer):Integer;
Var
 deltaRow,deltaCol,total:Integer;
Begin
 total:=0;
 For deltaRow := -1 to 1 do
  For deltaCol := -1 to 1 do
   If (deltaRow <> 0) or (deltaCol <> 0) Then
    total := total + CountFlipsInDirection(row, col, deltaRow, deltaCol, player);
 CountTotalFlips := total;
End;

Procedure FlipDiscs(row,col:Integer;player:TPlayer);
Var
 deltaRow,deltaCol,flipCount,i:Integer;
 r,c:Integer;
Begin
 { VÇrifier toutes les directions }
 For deltaRow := -1 to 1 do
  For deltaCol := -1 to 1 do
   If (deltaRow <> 0) or (deltaCol <> 0) Then
   Begin
    flipCount := CountFlipsInDirection(row, col, deltaRow, deltaCol, player);
    If flipCount>0 Then Begin
     { Retourner les pions dans cette direction }
     r:=row+deltaRow;
     c:=col+deltaCol;
     For i := 1 to flipCount do Begin
      Game.board[r,c]:=player;
      r:=r+deltaRow;
      c:=c+deltaCol;
     End;
    End;
   End;
End;

Function MakeMove(row,col:Integer;player:TPlayer):Boolean;Begin
 MakeMove:=False;
 If IsValidMove(row,col,player)Then Begin
  Game.board[row,col]:=player;
  FlipDiscs(row,col,player);
  Game.lastMove.row:=row;
  Game.lastMove.col:=col;
  Inc(Game.moveCount);
  MakeMove:=True;
 End;
End;

Function HasValidMoves(player:TPlayer):Boolean;
Var
 row,col:Integer;
Begin
 HasValidMoves:=False;
 For row := 0 to BOARD_SIZE-1 do For col := 0 to BOARD_SIZE-1 do
  If IsValidMove(row,col,player) Then Begin
   HasValidMoves := True;
   Exit;
  End;
End;

Procedure CountScore;
Var
 row,col:Integer;
Begin
 Game.blackScore := 0;
 Game.whiteScore := 0;
 For row := 0 to BOARD_SIZE-1 do For col := 0 to BOARD_SIZE-1 do
  Case Game.board[row, col] of
   pBlack: Inc(Game.blackScore);
   pWhite: Inc(Game.whiteScore);
  End;
End;

Procedure CheckGameEnd;Begin
 CountScore;
 If not HasValidMoves(Game.currentPlayer)Then Begin
  Game.currentPlayer:=OpponentPlayer(Game.currentPlayer);
  If not HasValidMoves(Game.currentPlayer)Then Begin
   { Aucun joueur ne peut jouer - fin de partie }
   If Game.blackScore > Game.whiteScore Then Game.gameState:=gsBlackWins Else
   If Game.whiteScore > Game.blackScore Then Game.gameState:=gsWhiteWins
                                        Else Game.gameState:=gsDraw;
  End;
 End;
End;

Function EvaluateBoard(player:TPlayer):Integer;
Var
 row,col,score,corners,edges,mobility:Integer;
 opponent:TPlayer;
Begin
 score:=0;
 corners:=0;
 edges:=0;
 mobility:=0;
 opponent:=OpponentPlayer(player);
 For row := 0 to BOARD_SIZE-1 do
  For col := 0 to BOARD_SIZE-1 do Begin
   If Game.board[row, col] = player Then Begin
    Inc(score);
     { Bonus Çnorme pour les coins }
    If((row=0)or(row=BOARD_SIZE-1))and((col=0)or(col=BOARD_SIZE-1))Then
     Inc(corners,30);
     { Bonus pour les bords }
    If(row=0)or(row=BOARD_SIZE-1)or(col=0)or(col=BOARD_SIZE-1)Then
     Inc(edges,5);
   End
    Else
   If Game.board[row,col]=opponent Then Begin
    Dec(score);
     { Malus pour les coins adverses }
    If ((row = 0) or (row = BOARD_SIZE-1)) and
       ((col = 0) or (col = BOARD_SIZE-1)) Then
     Dec(corners, 30);
   End;
    { Compter la mobilitÇ }
   If IsValidMove(row,col,player)Then Inc(mobility, 2);
  End;
 EvaluateBoard:=score+corners+edges+mobility;
End;

Procedure GetBestMove(player:TPlayer;depth:Integer;Var bestMove:TMove);
Var
 row,col,score,bestScore,flips:Integer;
 tempBoard:TBoard;
 i,j:Integer;
Begin
 bestMove.row:=-1;
 bestMove.col:=-1;
 bestMove.score:=-10000;
 bestScore:=-10000;
  { Sauvegarder le plateau }
 For i := 0 to BOARD_SIZE-1 do For j := 0 to BOARD_SIZE-1 do
   tempBoard[i, j] := Game.board[i, j];
 For row := 0 to BOARD_SIZE-1 do For col := 0 to BOARD_SIZE-1 do
  If IsValidMove(row, col, player) Then Begin
    { Simuler le coup }
   Game.board[row, col] := player;
   FlipDiscs(row, col, player);
   score := EvaluateBoard(player);
    { Bonus pour le nombre de pions retournÇs }
   flips := CountTotalFlips(row, col, player);
   score := score + flips * 2;
    { Bonus selon la difficultÇ }
   Case Game.difficulty of
    diffEasy: score := score + Random(10) - 5;
    diffMedium: score := score + Random(6) - 3;
    diffHard: ; { Pas de random pour le niveau difficile }
   End;
   If score>bestScore Then Begin
    bestScore:=score;
    bestMove.row:=row;
    bestMove.col:=col;
    bestMove.score:=score;
   End;
    { Restaurer le plateau }
   For i := 0 to BOARD_SIZE-1 do For j := 0 to BOARD_SIZE-1 do
    Game.board[i, j] := tempBoard[i, j];
   End;
End;

Procedure ComputerMove;
Var
 move:TMove;
Begin
 If(Game.gameMode=1)and(Game.currentPlayer=pWhite)and(Game.gameState=gsPlaying)Then Begin
  Delay(800); { DÇlai pour la rÇflexion }
  GetBestMove(pWhite,1,move);
  If(move.row>=0)and(move.col>=0)Then Begin
   MakeMove(move.row,move.col,pWhite);
   Game.currentPlayer:=pBlack;
   Game.needRedraw:=True;
   CheckGameEnd;
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
     #72: Begin { Fläche haut }
      If Game.selectedRow>0 Then Begin
       Dec(Game.selectedRow);
       Game.needRedraw:=True;
      End;
     End;
     #80: Begin { Fläche bas }
      If Game.selectedRow<BOARD_SIZE-1 Then Begin
       Inc(Game.selectedRow);
       Game.needRedraw:=True;
      End;
     End;
     #75: Begin { Fläche gauche }
      If Game.selectedCol>0 Then Begin
       Dec(Game.selectedCol);
       Game.needRedraw:=True;
      End;
     End;
     #77:Begin { Fläche droite }
      If Game.selectedCol<BOARD_SIZE-1 Then Begin
       Inc(Game.selectedCol);
       Game.needRedraw:=True;
      End;
     End;
    End;
   End;
   #13,' ':Begin { EntrÇe ou Espace }
    If (Game.gameState = gsPlaying) and
       ((Game.gameMode = 2) or (Game.currentPlayer = pBlack)) Then Begin
     If MakeMove(Game.selectedRow, Game.selectedCol, Game.currentPlayer)Then Begin
      Game.currentPlayer:=OpponentPlayer(Game.currentPlayer);
      Game.needRedraw:=True;
      CheckGameEnd;
     End;
    End;
   End;
   'h','H':Begin { Activer/d√©sactiver les indices }
    Game.showHints:=Not Game.showHints;
    Game.needRedraw:=True;
   End;
   'p','P':Begin { Passer le tour }
    If Game.gameState=gsPlaying Then Begin
     Game.currentPlayer:=OpponentPlayer(Game.currentPlayer);
     Game.needRedraw:=True;
     CheckGameEnd;
    End;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   'm', 'M':Begin { Changer mode }
    If Game.gameMode=1 Then Game.gameMode:=2
                       Else Game.gameMode:=1;
    InitializeGame;
   End;
   'd','D':Begin { Changer difficultÇ }
    If Game.difficulty=diffEasy Then Game.difficulty:=diffMedium Else
    If Game.difficulty=diffMedium Then Game.difficulty := diffHard
     Else
    Game.difficulty:=diffEasy;
    Game.needRedraw:=True;
   End;
   #27:Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure DrawDisc(x,y:Integer;player:TPlayer;selected,lastMove:Boolean);Begin
  { Marquer la sÇlection }
 If(selected)Then Begin
  SetColor(14);
  Circle(x, y, DISC_RADIUS + 3);
  SetLineStyle(0, 0, 3);
  Circle(x, y, DISC_RADIUS + 4);
  SetLineStyle(0, 0, 1);
 End;
  { Marquer le dernier coup }
 If lastMove Then Begin
  SetColor(12);
  Circle(x, y, DISC_RADIUS + 2);
 End;
 Case player of
  pBlack: Begin
   SetColor(0);
   SetFillStyle(1, 0);
   FillEllipse(x, y, DISC_RADIUS, DISC_RADIUS);
   SetColor(8);
   Circle(x, y, DISC_RADIUS);
   { Reflet }
   SetColor(8);
   FillEllipse(x - 5, y - 5, 3, 3);
  End;
  pWhite: Begin
   SetColor(15);
   SetFillStyle(1, 15);
   FillEllipse(x, y, DISC_RADIUS, DISC_RADIUS);
   SetColor(0);
   Circle(x, y, DISC_RADIUS);
   { Ombre }
   SetColor(7);
   FillEllipse(x + 3, y + 3, 2, 2);
  End;
 End;
End;

Procedure DrawBoard;
Var
 row, col, x, y: Integer;
 validMove, isLastMove: Boolean;
 flips: Integer;
 flipStr: String;
Begin
  { Dessiner le fond du plateau }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(BOARD_X - 5, BOARD_Y - 5,
     BOARD_X + BOARD_SIZE * CELL_SIZE + 5,
     BOARD_Y + BOARD_SIZE * CELL_SIZE + 5);
  { Dessiner le contour }
 SetColor(0);
 SetLineStyle(0, 0, 2);
 Rectangle(BOARD_X - 5, BOARD_Y - 5,
           BOARD_X + BOARD_SIZE * CELL_SIZE + 5,
           BOARD_Y + BOARD_SIZE * CELL_SIZE + 5);
 SetLineStyle(0, 0, 1);
 For row:=0 to BOARD_SIZE-1 do
  For col:=0 to BOARD_SIZE-1 do Begin
   x:=BOARD_X + col * CELL_SIZE;
   y:=BOARD_Y + row * CELL_SIZE;
    { Dessiner la case }
   SetColor(0);
   Rectangle(x, y, x + CELL_SIZE, y + CELL_SIZE);
    { Marquer les coups valides }
   validMove := IsValidMove(row, col, Game.currentPlayer);
   If validMove and (Game.gameState = gsPlaying) Then Begin
    If Game.showHints Then Begin
     SetColor(14);
     SetFillStyle(11, 14);
     Bar(x + 2, y + 2, x + CELL_SIZE - 2, y + CELL_SIZE - 2);
      { Afficher le nombre de pions retourn√©s }
     flips := CountTotalFlips(row, col, Game.currentPlayer);
     If flips>0 Then Begin
      Str(flips, flipStr);
      SetColor(0);
      SetTextStyle(0, 0, 1);
      OutTextXY(x + CELL_SIZE div 2 - 3, y + CELL_SIZE div 2 - 4, flipStr);
     End;
    End
    Else
    Begin
     SetColor(6);
     SetFillStyle(1, 6);
     FillEllipse(x + CELL_SIZE div 2, y + CELL_SIZE div 2, 3, 3);
    End;
   End;
    { Dessiner le pion }
   If Game.board[row, col] <> pEmpty Then Begin
    isLastMove := (row = Game.lastMove.row) and (col = Game.lastMove.col);
    DrawDisc(x + CELL_SIZE div 2, y + CELL_SIZE div 2,
             Game.board[row, col],
             (row = Game.selectedRow) and (col = Game.selectedCol),
             isLastMove);
   End
    Else
   If (row = Game.selectedRow)and(col = Game.selectedCol)Then Begin
    SetColor(15);
    SetLineStyle(0, 0, 2);
    Rectangle(x + 5, y + 5, x + CELL_SIZE - 5, y + CELL_SIZE - 5);
    SetLineStyle(0, 0, 1);
   End;
  End;
End;

Procedure DrawGameInfo;
Var
 modeStr,scoreStr,diffStr:String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 If Game.gameMode=1 Then modeStr:='vs IA ('+GetDifficultyName(Game.difficulty)+')'
                    Else modeStr:='2 Joueurs';
 OutTextXY(450, 60, 'OTHELLO');
 OutTextXY(450, 80, 'Mode: ' + modeStr);
 Str(Game.blackScore, scoreStr);
 SetColor(0);
 SetFillStyle(1, 0);
 FillEllipse(435, 105, 8, 8);
 SetColor(15);
 OutTextXY(450, 100, 'Noir: ' + scoreStr);
 Str(Game.whiteScore, scoreStr);
 SetColor(15);
 SetFillStyle(1, 15);
 FillEllipse(435, 125, 8, 8);
 SetColor(0);
 Circle(435, 125, 8);
 SetColor(15);
 OutTextXY(450, 120, 'Blanc: ' + scoreStr);
 Str(Game.moveCount, scoreStr);
 OutTextXY(450, 140, 'Coups: ' + scoreStr);
 If Game.gameState=gsPlaying Then Begin
  SetColor(GetPlayerColor(Game.currentPlayer));
  If Game.currentPlayer=pBlack Then Begin
   SetFillStyle(1, 0);
   FillEllipse(435, 165, 8, 8);
  End
   Else
  Begin
   SetFillStyle(1, 15);
   FillEllipse(435, 165, 8, 8);
   SetColor(0);
   Circle(435, 165, 8);
  End;
  SetColor(15);
  OutTextXY(450, 160, 'Tour: ' + GetPlayerName(Game.currentPlayer));
 End
 Else
  OutTextXY(450, 160, 'Partie terminee');
 If Game.showHints Then Begin
  SetColor(14);
  OutTextXY(450, 180, 'Indices: ON');
 End
 Else
 Begin
  SetColor(7);
  OutTextXY(450, 180, 'Indices: OFF');
 End;
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(450, 220, 'Regles:');
 OutTextXY(450, 240, '- Encadrez les pions');
 OutTextXY(450, 255, '  adverses');
 OutTextXY(450, 270, '- Plus de pions = victoire');

 OutTextXY(450, 300, 'Commandes:');
 OutTextXY(450, 320, 'Fleches: Curseur');
 OutTextXY(450, 335, 'ENTREE: Jouer');
 OutTextXY(450, 350, 'H: Indices on/off');
 OutTextXY(450, 365, 'P: Passer tour');
 OutTextXY(450, 380, 'N: Nouvelle partie');
 OutTextXY(450, 395, 'M: Changer mode');
 OutTextXY(450, 410, 'D: Difficulte');
 OutTextXY(450, 425, 'ESC: Quitter');
End;

Procedure DrawGameStatus;Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 Case Game.gameState of
  gsPlaying:Begin
   If not HasValidMoves(Game.currentPlayer) Then Begin
    SetColor(12);
    SetTextStyle(0, 0, 1);
    OutTextXY(80, 430, 'Aucun coup possible! Appuyez P pour passer');
   End;
  End;
  gsBlackWins:Begin
   OutTextXY(80, 430, 'NOIR GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(80, 450, 'N: Nouvelle partie');
  End;
  gsWhiteWins:Begin
   OutTextXY(80, 430, 'BLANC GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(80, 450, 'N: Nouvelle partie');
  End;
  gsDraw:Begin
   OutTextXY(80, 430, 'MATCH NUL!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(80, 450, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
   { Fond }
  SetColor(1);
  SetFillStyle(1, 1);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 3);
  OutTextXY(80, 20, 'OTHELLO');
  DrawBoard;
  DrawGameInfo;
  DrawInstructions;
  DrawGameStatus;
  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;Begin
 SetColor(1);
 SetFillStyle(1, 1);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 60, 'OTHELLO');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de strategie ou le but est d''avoir le plus de pions');
 OutTextXY(50, 140, 'de votre couleur a la fin de la partie.');
 OutTextXY(50, 170, 'Regles:');
 OutTextXY(50, 190, '- Placez un pion pour encadrer des pions adverses');
 OutTextXY(50, 210, '- Tous les pions encadres sont retournes');
 OutTextXY(50, 230, '- Vous devez retourner au moins un pion');
 OutTextXY(50, 250, '- Si aucun coup possible, vous passez votre tour');
 OutTextXY(50, 280, 'Commandes:');
 OutTextXY(50, 300, 'Fleches: Deplacer le curseur sur le plateau');
 OutTextXY(50, 320, 'ENTREE/ESPACE: Placer un pion a la position selectionnee');
 OutTextXY(50, 340, 'H: Afficher/masquer les indices de coups');
 OutTextXY(50, 360, 'P: Passer votre tour (si aucun coup possible)');
 OutTextXY(50, 390, 'Modes: 1=vs IA, 2=2 joueurs, D=difficulte, ESC=Quitter');
 Repeat
  If KeyPressed Then Begin
   Case ReadKey of
    '1': Begin
     Game.gameMode := 1;
     Exit;
    End;
    '2': Begin
     Game.gameMode := 2;
     Exit;
    End;
    'd', 'D': Begin
     If Game.difficulty = diffEasy Then
      Game.difficulty := diffMedium
     Else If Game.difficulty = diffMedium Then
      Game.difficulty := diffHard
     Else
      Game.difficulty := diffEasy;
     SetColor(14);
     OutTextXY(50, 420, 'Difficulte: ' + GetDifficultyName(Game.difficulty));
    End;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;Begin
 SetupInitialPosition;
 Game.currentPlayer:=pBlack;
 Game.gameState:=gsPlaying;
 Game.selectedRow:=3;
 Game.selectedCol:=3;
 Game.needRedraw:=True;
 Game.showHints:=False;
 CountScore;
End;

Procedure GameLoop;Begin
 While Game.gameState <> gsQuit do Begin
  HandleInput;
  ComputerMove;
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
 Game.difficulty:=diffMedium;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.