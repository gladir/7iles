{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Bingo - Jeu de hasard classique
}

Program Bingo;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 CARD_SIZE = 5;
 CELL_SIZE = 35;
 CARD_X = 50;
 CARD_Y = 120;
 MAX_NUMBERS = 75;
 NUMBERS_PER_COLUMN = 15;

Type
 TBingoCard = Array[1..CARD_SIZE, 1..CARD_SIZE] of Integer;
 TMarkedCard = Array[1..CARD_SIZE, 1..CARD_SIZE] of Boolean;
 TDrawnNumbers = Array[1..MAX_NUMBERS] of Boolean;

 TGameState = (gsPlaying, gsPlayerWins, gsComputerWins, gsGameOver, gsQuit);

 TGame=Record
  playerCard:TBingoCard;
  computerCard:TBingoCard;
  playerMarked:TMarkedCard;
  computerMarked:TMarkedCard;
  drawnNumbers:TDrawnNumbers;
  numbersDrawn:Array[1..MAX_NUMBERS] of Integer;
  drawCount:Integer;
  currentNumber:Integer;
  gameState:TGameState;
  selectedRow,selectedCol:Integer;
  needRedraw:Boolean;
  gameMode:Integer; { 1=vs Computer, 2=Manual }
  autoPlay:Boolean;
  lastAction:String;
 End;

Var
 Game:TGame;

{ DÃ©clarations forward }
Procedure InitializeGame; Forward;

Function GetColumnLetter(col:Integer):Char;Begin
 Case col of
  1: GetColumnLetter := 'B';
  2: GetColumnLetter := 'I';
  3: GetColumnLetter := 'N';
  4: GetColumnLetter := 'G';
  5: GetColumnLetter := 'O';
  else GetColumnLetter := '?';
 End;
End;

Function GetColumnRange(col:Integer):String;Begin
 Case col of
  1: GetColumnRange := '1-15';
  2: GetColumnRange := '16-30';
  3: GetColumnRange := '31-45';
  4: GetColumnRange := '46-60';
  5: GetColumnRange := '61-75';
  else GetColumnRange := '???';
 End;
End;

Function GetNumberColumn(num:Integer):Integer;Begin
 If(num>=1)and(num<=15)Then GetNumberColumn:=1 Else
 If(num>=16)and(num<=30)Then GetNumberColumn:=2 Else
 If(num>=31)and(num<=45)Then GetNumberColumn:=3 Else
 If(num>=46)and(num<=60)Then GetNumberColumn:=4 Else
 If(num>=61)and(num<=75)Then GetNumberColumn:=5
                        Else GetNumberColumn:=0;
End;

Procedure GenerateBingoCard(Var card:TBingoCard);
Var
 col,row,num,attempts:Integer;
 used:Array[1..MAX_NUMBERS] of Boolean;
 found:Boolean;
Begin
  { Initialiser le tableau des num‚ros utilis‚s }
 For num:=1 to MAX_NUMBERS do used[num]:=False;
  { G‚n‚rer chaque colonne }
 For col := 1 to CARD_SIZE do Begin
  For row := 1 to CARD_SIZE do Begin
   { Case centrale gratuite (FREE) }
   If(col=3)and(row=3)Then Begin
    card[row,col]:=0; { 0 = FREE }
   End
    Else
   Begin
    attempts := 0;
    Repeat
     num:=Random(NUMBERS_PER_COLUMN)+1+(col-1)*NUMBERS_PER_COLUMN;
     Inc(attempts);
    Until (not used[num])or(attempts>100);
    used[num] := True;
    card[row, col] := num;
   End;
  End;
 End;
End;

Procedure ClearMarks(Var marked: TMarkedCard);
Var
 row,col:Integer;
Begin
 For row:=1 to CARD_SIZE do For col:=1 to CARD_SIZE do
  marked[row,col]:=False;
 { La case centrale est automatiquement marquÃ©e }
 marked[3,3]:=True;
End;

Function DrawNumber:Integer;
Var
 num:Integer;
 attempts:Integer;
Begin
 attempts:=0;
 Repeat
  num := Random(MAX_NUMBERS) + 1;
  Inc(attempts);
 Until(Not Game.drawnNumbers[num])or(attempts>1000);
 If Not Game.drawnNumbers[num]Then Begin
  Game.drawnNumbers[num] := True;
  Inc(Game.drawCount);
  Game.numbersDrawn[Game.drawCount] := num;
  DrawNumber := num;
 End
  Else
 DrawNumber:=0; { Plus de num‚ros disponibles }
End;

Function HasNumber(Var card:TBingoCard;number:Integer):Boolean;
Var
 row,col:Integer;
Begin
 HasNumber:=False;
 For row:=1 to CARD_SIZE do For col:=1 to CARD_SIZE do
  If card[row,col]=number Then Begin
    HasNumber:=True;
    Exit;
   End;
End;

Procedure MarkNumber(Var card:TBingoCard;Var marked:TMarkedCard;number:Integer);
Var
 row,col:Integer;
Begin
 For row:=1 to CARD_SIZE do For col:=1 to CARD_SIZE do
  If card[row,col]=number Then marked[row,col]:=True;
End;

Function CheckBingo(Var marked: TMarkedCard):Boolean;
Var
 row,col:Integer;
 hasLine,hasCol,hasDiag1,hasDiag2:Boolean;
Begin
 CheckBingo:=False;
  { V‚rifier les lignes }
 For row:=1 to CARD_SIZE do Begin
  hasLine:=True;
  For col := 1 to CARD_SIZE do If Not marked[row,col]Then Begin
   hasLine := False;
   Break;
  End;
  If hasLine Then Begin
   CheckBingo:=True;
   Exit;
  End;
 End;
  { V‚rifier les colonnes }
 For col:=1 to CARD_SIZE do Begin
  hasCol:=True;
  For row:=1 to CARD_SIZE do If not marked[row,col]Then Begin
   hasCol := False;
   Break;
  End;
  If hasCol Then Begin
   CheckBingo:=True;
   Exit;
  End;
 End;
  { V‚rifier la diagonale principale }
 hasDiag1:=True;
 For row:=1 to CARD_SIZE do If not marked[row,row]Then Begin
  hasDiag1:=False;
  Break;
 End;
 If hasDiag1 Then Begin
  CheckBingo:=True;
  Exit;
 End;
 { V‚rifier la diagonale inverse }
 hasDiag2:=True;
 For row:=1 to CARD_SIZE do If not marked[row,CARD_SIZE+1-row]Then Begin
  hasDiag2:=False;
  Break;
 End;
 If hasDiag2 Then CheckBingo:=True;
End;

Procedure DrawBingoCard(x,y:Integer;Var card:TBingoCard;Var marked:TMarkedCard;isPlayer:Boolean);
Var
 row,col,cellX,cellY:Integer;
 numStr:String;
Begin
 { Dessiner l'en-tˆte BINGO }
 SetColor(15);
 SetTextStyle(0, 0, 2);
 For col:=1 to CARD_SIZE do Begin
  cellX:=x + (col - 1) * CELL_SIZE;
  OutTextXY(cellX + 10, y - 25, GetColumnLetter(col));
 End;
  { Dessiner les cellules }
 For row:=1 to CARD_SIZE do For col:=1 to CARD_SIZE do Begin
  cellX:=x+(col-1)*CELL_SIZE;
  cellY:=y+(row-1)*CELL_SIZE;
   { Fond de la cellule }
  If marked[row,col] Then Begin
   SetColor(14);
   SetFillStyle(1, 14);
  End
   Else
  Begin
   SetColor(15);
   SetFillStyle(1, 15);
  End;
  Bar(cellX, cellY, cellX + CELL_SIZE, cellY + CELL_SIZE);
   { Contour }
  If isPlayer and(row=Game.selectedRow)and(col=Game.selectedCol)Then Begin
   SetColor(12);
   SetLineStyle(0, 0, 2);
  End
   Else
  Begin
   SetColor(0);
   SetLineStyle(0, 0, 1);
  End;
  Rectangle(cellX, cellY, cellX + CELL_SIZE, cellY + CELL_SIZE);
  SetLineStyle(0, 0, 1);
   { Num‚ro ou FREE }
  If card[row,col]=0 Then numStr:='FREE'
   Else
  Begin
   Str(card[row, col], numStr);
  End;
   { Couleur du texte }
  If marked[row,col]Then SetColor(0)
                    Else SetColor(0);
  SetTextStyle(0,0,1);
  If Length(numStr)<=2 Then OutTextXY(cellX + 8,cellY + 12,numStr)
                       Else OutTextXY(cellX + 3,cellY + 12,numStr);
 End;
End;

Procedure DrawGameInfo;
Var
 drawStr, colStr: String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 2);
 OutTextXY(300, 10, 'BINGO');
 SetTextStyle(0, 0, 1);
 If Game.currentNumber>0 Then Begin
  Str(Game.currentNumber,drawStr);
  colStr:=GetColumnLetter(GetNumberColumn(Game.currentNumber));
  SetColor(14);
  OutTextXY(300, 40, 'Numero tire: ' + colStr + drawStr);
 End;
 SetColor(15);
 Str(Game.drawCount,drawStr);
 OutTextXY(300,60,'Numeros tires: ' + drawStr + '/75');
 OutTextXY(50,80,'Votre carte:');
 OutTextXY(450,80,'Ordinateur:');
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(300, 280,'Regles:');
 OutTextXY(300, 300,'- Completez une ligne, colonne');
 OutTextXY(300, 315,'  ou diagonale pour gagner');
 OutTextXY(300, 330,'- Case centrale = gratuite');
 OutTextXY(300, 360, 'Commandes:');
 OutTextXY(300, 380, 'ESPACE: Tirer un numero');
 OutTextXY(300, 395, 'A: Mode automatique');
 OutTextXY(300, 410, 'N: Nouvelle partie');
 OutTextXY(300, 425, 'ESC: Quitter');
End;

Procedure DrawGameStatus;Begin
 SetColor(14);
 SetTextStyle(0,0,1);
 If Game.lastAction<>''Then OutTextXY(50, 320, Game.lastAction);
 Case Game.gameState of
  gsPlayerWins:Begin
   SetColor(10);
   SetTextStyle(0, 0, 2);
   OutTextXY(50,350,'BINGO! VOUS GAGNEZ!');
  End;
  gsComputerWins: Begin
   SetColor(12);
   SetTextStyle(0, 0, 2);
   OutTextXY(50,350,'BINGO! ORDINATEUR GAGNE!');
  End;
  gsGameOver:Begin
   SetColor(7);
   SetTextStyle(0,0,1);
   OutTextXY(50,350,'Plus de numeros - Partie terminee');
  End;
 End;
 If Game.autoPlay Then Begin
  SetColor(10);
  OutTextXY(50, 370, 'Mode automatique ON');
 End;
End;

Procedure DrawLastNumbers;
Var
 i,x,y,displayCount:Integer;
 numStr,colStr:String;
Begin
 SetColor(15);
 SetTextStyle(0,0,1);
 OutTextXY(245, 120,'Derniers numeros:');
  { Afficher les 10 derniers numÃ©ros }
 displayCount := Game.drawCount;
 If displayCount>10 Then displayCount := 10;
 For i:=1 to displayCount do Begin
  x := 245 + ((i - 1) mod 2) * 50;
  y := 140 + ((i - 1) div 2) * 20;
  Str(Game.numbersDrawn[Game.drawCount - displayCount + i], numStr);
  colStr := GetColumnLetter(GetNumberColumn(Game.numbersDrawn[Game.drawCount - displayCount + i]));
  SetColor(7);
  OutTextXY(x, y, colStr + numStr);
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   ' ': Begin { Espace - Tirer un numÃ©ro }
    If Game.gameState = gsPlaying Then
    Begin
     Game.currentNumber := DrawNumber;
     If Game.currentNumber > 0 Then
     Begin
      { Marquer sur les cartes si le num‚ro est pr‚sent }
      If HasNumber(Game.playerCard, Game.currentNumber) Then
       MarkNumber(Game.playerCard, Game.playerMarked, Game.currentNumber);
      If HasNumber(Game.computerCard, Game.currentNumber) Then
       MarkNumber(Game.computerCard, Game.computerMarked, Game.currentNumber);
      Game.lastAction := 'Numero tire: ' + GetColumnLetter(GetNumberColumn(Game.currentNumber)) +
                         Chr(Ord('0') + (Game.currentNumber div 10)) +
                         Chr(Ord('0') + (Game.currentNumber mod 10));
      { V‚rifier les victoires }
      If CheckBingo(Game.playerMarked) Then
       Game.gameState := gsPlayerWins
      Else If CheckBingo(Game.computerMarked) Then
       Game.gameState := gsComputerWins;
     End
     Else
      Game.gameState := gsGameOver;
     Game.needRedraw := True;
    End;
   End;
   'a', 'A': Begin { Mode automatique }
    Game.autoPlay := not Game.autoPlay;
    Game.needRedraw := True;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure AutoPlay;Begin
 If Game.autoPlay and(Game.gameState = gsPlaying)Then Begin
  Delay(2000); { D‚lai entre les tirages automatiques }
  Game.currentNumber := DrawNumber;
  If Game.currentNumber>0 Then Begin
   { Marquer sur les cartes si le num‚ro est pr‚sent }
   If HasNumber(Game.playerCard, Game.currentNumber) Then
    MarkNumber(Game.playerCard, Game.playerMarked, Game.currentNumber);
   If HasNumber(Game.computerCard, Game.currentNumber) Then
    MarkNumber(Game.computerCard, Game.computerMarked, Game.currentNumber);
   Game.lastAction := 'Auto: ' + GetColumnLetter(GetNumberColumn(Game.currentNumber)) +
                      Chr(Ord('0') + (Game.currentNumber div 10)) +
                      Chr(Ord('0') + (Game.currentNumber mod 10));
   { V‚rifier les victoires }
   If CheckBingo(Game.playerMarked)Then Game.gameState:=gsPlayerWins Else
   If CheckBingo(Game.computerMarked)Then Game.gameState := gsComputerWins;
  End
   Else
  Game.gameState := gsGameOver;
  Game.needRedraw := True;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  { Fond }
  SetColor(1);
  SetFillStyle(1, 1);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  DrawGameInfo;
  DrawBingoCard(CARD_X, CARD_Y, Game.playerCard, Game.playerMarked, True);
  DrawBingoCard(450, CARD_Y, Game.computerCard, Game.computerMarked, False);
  DrawInstructions;
  DrawGameStatus;
  DrawLastNumbers;
  Game.needRedraw:=False;
 End;
End;

Procedure ShowTitle;Begin
 SetColor(1);
 SetFillStyle(1,1);
 Bar(0,0,SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0,0,3);
 OutTextXY(SCREEN_WIDTH div 2-60,60,'BINGO');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de hasard ou il faut completer une ligne, colonne');
 OutTextXY(50, 140, 'ou diagonale en marquant les numeros tires.');
 OutTextXY(50, 170, 'Regles:');
 OutTextXY(50, 190, '- Les numeros sont divises en colonnes: B(1-15), I(16-30),');
 OutTextXY(50, 210, '  N(31-45), G(46-60), O(61-75)');
 OutTextXY(50, 230, '- La case centrale est gratuite (FREE)');
 OutTextXY(50, 250, '- Completez une ligne, colonne ou diagonale pour gagner');
 OutTextXY(50, 270, '- Premier qui crie BINGO gagne!');
 OutTextXY(50, 300, 'Commandes:');
 OutTextXY(50, 320, 'ESPACE: Tirer un numero manuellement');
 OutTextXY(50, 340, 'A: Activer/desactiver le mode automatique');
 OutTextXY(50, 360, 'N: Nouvelle partie');
 OutTextXY(50, 380, 'ESC: Quitter');
 OutTextXY(50, 410, 'Appuyez sur une touche pour commencer...');
 ReadKey;
End;

Procedure InitializeGame;
Var
 i:Integer;
Begin
 { Initialiser les tableaux }
 For i:=1 to MAX_NUMBERS do Game.drawnNumbers[i] := False;
 Game.drawCount := 0;
 Game.currentNumber := 0;
 Game.gameState := gsPlaying;
 Game.selectedRow := 3;
 Game.selectedCol := 3;
 Game.needRedraw := True;
 Game.gameMode := 1;
 Game.autoPlay := False;
 Game.lastAction := 'Nouvelle partie commencee';
  { G‚n‚rer les cartes }
 GenerateBingoCard(Game.playerCard);
 GenerateBingoCard(Game.computerCard);
  { Initialiser les marquages }
 ClearMarks(Game.playerMarked);
 ClearMarks(Game.computerMarked);
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
  AutoPlay;
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
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.