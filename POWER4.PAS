{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu Puissance 4 (Power 4) - Alignez 4 jetons pour gagner
}

Program Power4;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS,Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 BOARD_WIDTH = 7;
 BOARD_HEIGHT = 6;
 CELL_SIZE = 50;
 BOARD_X = 150;
 BOARD_Y = 100;
 TOKEN_RADIUS = 20;

Type
 TPlayer = (pNone, pHuman, pComputer);
 TGameState = (gsPlaying, gsHumanWin, gsComputerWin, gsDraw, gsQuit);

 TBoard = Array[0..BOARD_HEIGHT-1, 0..BOARD_WIDTH-1] of TPlayer;

 TGame = Record
  board: TBoard;
  currentPlayer: TPlayer;
  gameState: TGameState;
  selectedColumn: Integer;
  needRedraw: Boolean;
  gameMode: Integer; { 1=vs Computer, 2=vs Human }
  computerMoved: Boolean; { Pour éviter que l'IA joue plusieurs fois }
 End;

Var
 Game: TGame;

{ Déclarations forward }
Procedure InitializeGame; Forward;
Procedure CheckWin; Forward;

{$IFNDEF FPC}
 Function MouseDriverFound:Boolean;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=0;
  Intr($33,Regs);
  MouseDriverFound:=Regs.AX=$FFFF;
 End;

 Procedure GetMouseState(Var X,Y,Button:LongInt);
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0003;
  Intr($33,Regs);
  Button:=Regs.BX;
  X:=Regs.CX;
  Y:=Regs.DX;
 End;

 Function GetMouseButton:Word;
 Var
  X,Y,Button:LongInt;
 Begin
  GetMouseState(X,Y,Button);
  GetMouseButton:=Button;
 End;
{$ENDIF}

Function GetPlayerColor(player:TPlayer):Integer;Begin
 Case player of
  pHuman: GetPlayerColor := 4;     { Rouge }
  pComputer: GetPlayerColor := 14; { Jaune }
  Else GetPlayerColor := 8;        { Gris foncé }
 End;
End;

Function GetPlayerName(player:TPlayer):String;Begin
 Case player of
  pHuman: Begin
   If Game.gameMode = 1 Then
    GetPlayerName := 'Joueur'
   Else
    GetPlayerName := 'Joueur 1';
  End;
  pComputer: Begin
   If Game.gameMode = 1 Then
    GetPlayerName := 'Ordinateur'
   Else
    GetPlayerName := 'Joueur 2';
  End;
  Else GetPlayerName := 'Vide';
 End;
End;

Procedure ClearBoard;
Var
 row,col:Integer;
Begin
 For row:=0 to BOARD_HEIGHT-1 do For col:=0 to BOARD_WIDTH-1 do Game.board[row, col]:=pNone;
End;

Function IsColumnFull(col:Integer):Boolean;Begin
 IsColumnFull:=(Game.board[0, col]<>pNone);
End;

Function DropToken(col:Integer;player:TPlayer):Boolean;
Var
 row:Integer;
Begin
 DropToken:=False;
 If(col<0)or(col>=BOARD_WIDTH)or IsColumnFull(col)Then Exit;
  { Trouver la ligne la plus basse disponible }
 For row := BOARD_HEIGHT-1 downto 0 do Begin
  If Game.board[row,col]=pNone Then Begin
   Game.board[row, col]:=player;
   DropToken:=True;
   Exit;
  End;
 End;
End;

Function CheckLine(startRow,startCol,deltaRow,deltaCol:Integer;player:TPlayer):Boolean;
Var
 count,row,col:Integer;
Begin
 count:=0;
 row:=startRow;
 col:=startCol;
 While(row>=0)and(row<BOARD_HEIGHT)and(col>=0)and(col<BOARD_WIDTH)and
      (Game.board[row,col]=player) do Begin
  Inc(count);
  row := row + deltaRow;
  col := col + deltaCol;
 End;
 CheckLine:=(count>=4);
End;

Function HasWon(player:TPlayer):Boolean;
Var
 row,col:Integer;
Begin
 HasWon:=False;
 For row := 0 to BOARD_HEIGHT-1 do For col := 0 to BOARD_WIDTH-1 do
  If Game.board[row,col]=player Then Begin
    { Vérifier horizontal }
   If CheckLine(row,col,0,1,player)Then Begin
    HasWon := True;
    Exit;
   End;
    { Vérifier vertical }
   If CheckLine(row,col,1,0,player)Then Begin
    HasWon:=True;
    Exit;
   End;
    { Vérifier diagonal \ }
   If CheckLine(row, col, 1, 1, player) Then Begin
    HasWon:=True;
    Exit;
   End;
    { Vérifier diagonal / }
   If CheckLine(row, col, 1, -1,player)Then Begin
    HasWon := True;
    Exit;
   End;
  End;
End;

Function IsBoardFull:Boolean;
Var
 col:Integer;
Begin
 IsBoardFull:=True;
 For col:=0 to BOARD_WIDTH-1 do If not IsColumnFull(col)Then Begin
  IsBoardFull:=False;
  Exit;
 End;
End;

Procedure CheckWin;Begin
 If HasWon(pHuman)Then Game.gameState:=gsHumanWin Else
 If HasWon(pComputer)Then Game.gameState:=gsComputerWin Else
 If IsBoardFull Then Game.gameState:=gsDraw;
End;

Function EvaluateMove(col:Integer;player:TPlayer):Integer;
Var
 tempBoard:TBoard;
 row,score,i,j:Integer;
 originalBoard:TBoard;
Begin
 score:=0;

 { Sauvegarder le plateau original }
 For i := 0 to BOARD_HEIGHT-1 do
  For j := 0 to BOARD_WIDTH-1 do
   originalBoard[i,j] := Game.board[i,j];

 If IsColumnFull(col) Then Begin
  EvaluateMove:=-1000;
  Exit;
 End;

 { Simuler le coup }
 For row:=BOARD_HEIGHT-1 downto 0 do
  If Game.board[row,col]=pNone Then Begin
   Game.board[row,col]:=player;
   Break;
  End;

 { Vérifier si ce coup gagne }
 If HasWon(player) Then
  score := 1000;

 { Restaurer le plateau original }
 For i := 0 to BOARD_HEIGHT-1 do
  For j := 0 to BOARD_WIDTH-1 do
   Game.board[i,j] := originalBoard[i,j];

 { Bonus pour colonne centrale }
 If col=3 Then score:=score+10;
 If col=2 Then score:=score+5;
 If col=4 Then score:=score+5;

 EvaluateMove := score;
End;

Function GetComputerMove:Integer;
Var
 col,bestCol,score,bestScore:Integer;
Begin
 bestCol := 3; { Colonne centrale par défaut }
 bestScore := -2000;
 For col := 0 to BOARD_WIDTH-1 do Begin
  If not IsColumnFull(col) Then
  Begin
   score := EvaluateMove(col, pComputer);
   If score > bestScore Then
   Begin
    bestScore := score;
    bestCol := col;
   End;
  End;
 End;
 GetComputerMove := bestCol;
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
     #75: Begin { Flèche gauche }
      If Game.selectedColumn > 0 Then
      Begin
       Dec(Game.selectedColumn);
       Game.needRedraw := True;
      End;
     End;
     #77: Begin { Flèche droite }
      If Game.selectedColumn < BOARD_WIDTH-1 Then
      Begin
       Inc(Game.selectedColumn);
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   #13, ' ': Begin { Entrée ou Espace }
    If (Game.gameState = gsPlaying) and (Game.currentPlayer = pHuman) Then
    Begin
     If DropToken(Game.selectedColumn, pHuman) Then
     Begin
      CheckWin;
      If Game.gameState = gsPlaying Then
      Begin
       If Game.gameMode = 1 Then
       Begin
        Game.currentPlayer := pComputer;
        Game.computerMoved := False; { Permettre à l'IA de jouer }
       End
       Else
       Begin
        { Mode 2 joueurs - alterner entre joueur 1 et joueur 2 }
        If Game.currentPlayer = pHuman Then
         Game.currentPlayer := pComputer
        Else
         Game.currentPlayer := pHuman;
       End;
      End;
      Game.needRedraw := True;
     End;
    End
    Else If (Game.gameState = gsPlaying) and (Game.gameMode = 2) and (Game.currentPlayer = pComputer) Then
    Begin
     { Mode 2 joueurs - le "computer" représente le joueur 2 }
     If DropToken(Game.selectedColumn, pComputer) Then
     Begin
      CheckWin;
      If Game.gameState = gsPlaying Then
       Game.currentPlayer := pHuman;
      Game.needRedraw := True;
     End;
    End;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   'm', 'M': Begin { Changer mode }
    If Game.gameMode = 1 Then
     Game.gameMode := 2
    Else
     Game.gameMode := 1;
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure ComputerMove;
Var
 col: Integer;
Begin
 If (Game.gameState = gsPlaying) and (Game.currentPlayer = pComputer) and
    (Game.gameMode = 1) and (not Game.computerMoved) Then
 Begin
  Game.computerMoved := True;
  Delay(500); { Petit délai pour l'effet }
  col := GetComputerMove;
  If DropToken(col, pComputer) Then
  Begin
   CheckWin;
   If Game.gameState = gsPlaying Then
   Begin
    Game.currentPlayer := pHuman;
    Game.computerMoved := False; { Réinitialiser pour le prochain tour }
   End;
   Game.needRedraw := True;
  End;
 End;
End;

Procedure DrawToken(x, y: Integer; player: TPlayer);Begin
 SetColor(0);
 SetFillStyle(1, GetPlayerColor(player));
 If player <> pNone Then
 Begin
  FillEllipse(x, y, TOKEN_RADIUS, TOKEN_RADIUS);
  SetColor(15);
  Circle(x, y, TOKEN_RADIUS);
 End
 Else
 Begin
  SetColor(0);
  SetFillStyle(1, 0);
  FillEllipse(x, y, TOKEN_RADIUS, TOKEN_RADIUS);
  SetColor(8);
  Circle(x, y, TOKEN_RADIUS);
 End;
End;

Procedure DrawBoard;
Var
 row, col, x, y: Integer;
Begin
 { Dessiner le plateau }
 SetColor(1);
 SetFillStyle(1, 1);
 Bar(BOARD_X - 10, BOARD_Y - 10,
     BOARD_X + BOARD_WIDTH * CELL_SIZE + 10,
     BOARD_Y + BOARD_HEIGHT * CELL_SIZE + 10);

 { Dessiner les cases et les jetons }
 For row := 0 to BOARD_HEIGHT-1 do
  For col := 0 to BOARD_WIDTH-1 do
  Begin
   x := BOARD_X + col * CELL_SIZE + CELL_SIZE div 2;
   y := BOARD_Y + row * CELL_SIZE + CELL_SIZE div 2;

   { Dessiner la case }
   SetColor(15);
   Rectangle(BOARD_X + col * CELL_SIZE, BOARD_Y + row * CELL_SIZE,
            BOARD_X + (col + 1) * CELL_SIZE, BOARD_Y + (row + 1) * CELL_SIZE);

   { Dessiner le jeton }
   DrawToken(x, y, Game.board[row, col]);
  End;

 { Dessiner l'indicateur de colonne sélectionnée }
 If Game.gameState = gsPlaying Then Begin
  x := BOARD_X + Game.selectedColumn * CELL_SIZE + CELL_SIZE div 2;
  y := BOARD_Y - 30;

  SetColor(15);
  SetFillStyle(1, 15);
  FillEllipse(x, y, 15, 15);

  SetColor(GetPlayerColor(Game.currentPlayer));
  SetFillStyle(1, GetPlayerColor(Game.currentPlayer));
  FillEllipse(x, y, 10, 10);
 End;
End;

Procedure DrawGameInfo;
Var
 modeStr: String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 If Game.gameMode=1 Then modeStr:='vs Ordinateur'
                    Else modeStr:='2 Joueurs';
 OutTextXY(50, 50, 'Mode: ' + modeStr);
 If Game.gameState = gsPlaying Then
  OutTextXY(50, 70, 'Tour: ' + GetPlayerName(Game.currentPlayer))
 Else
  OutTextXY(50, 70, 'Partie terminee');
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 412, 'POWER 4');
 OutTextXY(150, 412, 'Fleches: Choisir colonne');
 OutTextXY(150, 424, 'Entree/Espace: Jouer');
 OutTextXY(470, 412, 'N: Nouvelle partie');
 OutTextXY(50, 440, 'M: Changer mode');
 OutTextXY(200, 440, 'ESC: Quitter');
End;

Procedure DrawGameStatus;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);

 Case Game.gameState of
  gsPlaying: Begin
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(450, 50, 'Alignez 4 jetons!');
  End;
  gsHumanWin: Begin
   If Game.gameMode = 1 Then
    OutTextXY(450, 50, 'VOUS GAGNEZ!')
   Else
    OutTextXY(450, 50, 'JOUEUR 1 GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(450, 80, 'N: Nouvelle partie');
  End;
  gsComputerWin: Begin
   If Game.gameMode = 1 Then
    OutTextXY(450, 50, 'ORDINATEUR GAGNE!')
   Else
    OutTextXY(450, 50, 'JOUEUR 2 GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(450, 80, 'N: Nouvelle partie');
  End;
  gsDraw: Begin
   OutTextXY(450, 50, 'MATCH NUL!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(450, 80, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
   { Fond }
  SetColor(2);
  SetFillStyle(1, 2);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   { Titre }
  SetColor(14);
  SetTextStyle(0, 0, 3);
  OutTextXY(50, 20, 'PUISSANCE 4');
  DrawGameInfo;
  DrawBoard;
  DrawInstructions;
  DrawGameStatus;
  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;
Begin
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(14);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 150, 100, 'PUISSANCE 4');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 200, 'Alignez 4 jetons horizontalement, verticalement');
 OutTextXY(50, 220, 'ou en diagonale pour gagner!');
 OutTextXY(50, 260, 'Regles:');
 OutTextXY(50, 280, '- Choisissez une colonne avec les fleches');
 OutTextXY(50, 300, '- Appuyez sur Entree pour lacher votre jeton');
 OutTextXY(50, 320, '- Le jeton tombe au plus bas de la colonne');
 OutTextXY(50, 340, '- Premier a aligner 4 jetons gagne!');
 OutTextXY(50, 380, 'Modes de jeu:');
 OutTextXY(50, 400, '1: Contre l''ordinateur');
 OutTextXY(50, 420, '2: Deux joueurs');
 OutTextXY(50, 450, 'Appuyez sur 1 ou 2 pour choisir le mode...');
 Repeat
  If KeyPressed Then
  Begin
   Case ReadKey of
    '1': Begin
     Game.gameMode := 1;
     Exit;
    End;
    '2': Begin
     Game.gameMode := 2;
     Exit;
    End;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;Begin
 ClearBoard;
 Game.currentPlayer := pHuman;
 Game.gameState := gsPlaying;
 Game.selectedColumn := 3;
 Game.needRedraw := True;
 Game.computerMoved := False;
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
  If Game.gameMode = 1 Then ComputerMove;
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
End;

BEGIN
 InitializeGraphics;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.