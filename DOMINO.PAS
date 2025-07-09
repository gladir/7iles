{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Domino classique contre l'ordinateur
}

Program Domino;

Uses
{$IFDEF FPC}
  Windows, Crt, PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 DOMINO_WIDTH = 40;
 DOMINO_HEIGHT = 80;
 DOMINO_SPACING = 45;

 PLAYER_DOMINOS_Y = 400;
 COMPUTER_DOMINOS_Y = 20;
 DOMINOS_START_X = 250;

 BOARD_CENTER_X = 400;
 BOARD_CENTER_Y = 200;

 MAX_DOMINOS = 28;
 HAND_SIZE = 7;
 MAX_BOARD_DOMINOS = 20;

Type
 TDomino=Record
  leftDots:Integer;   { 0 à 6 points }
  rightDots:Integer;  { 0 à 6 points }
  horizontal:Boolean; { Orientation }
  visible:Boolean;
  selected:Boolean;
 End;

 TDominoSet=Record
  dominos:Array[1..MAX_DOMINOS] of TDomino;
  count:Integer;
 End;

 TPlayerHand=Record
  dominos:Array[1..HAND_SIZE] of TDomino;
  count:Integer;
 End;

 TBoardDomino=Record
  domino:TDomino;
  x,y:Integer;
 End;

 TGameBoard=Record
  dominos:Array[1..MAX_BOARD_DOMINOS] of TBoardDomino;
  count:Integer;
  leftEnd:Integer;  { Valeur à l'extrémité gauche }
  rightEnd:Integer; { Valeur à l'extrémité droite }
 End;

 TGameState=Record
  dominoSet:TDominoSet;
  playerHand:TPlayerHand;
  computerHand:TPlayerHand;
  board:TGameBoard;
  currentPlayer:Integer; { 1=joueur, 2=ordinateur }
  gamePhase:Integer;     { 0=distribution, 1=jeu, 2=fin }
  gameOver:Boolean;
  winner:Integer;        { 0=match nul, 1=joueur, 2=ordinateur }
  playerScore:Integer;
  computerScore:Integer;
  selectedDomino:Integer;
 End;

Var
 Game:TGameState;
 needRedraw:Boolean;

{$IFNDEF FPC}
Procedure GetMouseState(Var X, Y, Button: LongInt);
Var
 Regs: Registers;
Begin
 Regs.AX:=$0003;
 Intr($33,Regs);
 Button:=Regs.BX;
 X:=Regs.CX;
 Y:=Regs.DX;
End;
{$ENDIF}

Procedure InitializeDominoSet;
Var
 i,j,k:Integer;
 temp:TDomino;
Begin
 { Créer le jeu de 28 dominos (0-0 à 6-6) }
 k := 1;
 For i := 0 to 6 do For j := i to 6 do Begin
  With Game.dominoSet.dominos[k] do Begin
   leftDots := i;
   rightDots := j;
   horizontal := True;
   visible := True;
   selected := False;
  End;
  Inc(k);
 End;
 Game.dominoSet.count := 28;
  { Mélanger les dominos }
 For i := 1 to 28 do Begin
  j:=Random(28)+1;
  temp:=Game.dominoSet.dominos[i];
  Game.dominoSet.dominos[i]:=Game.dominoSet.dominos[j];
  Game.dominoSet.dominos[j]:=temp;
 End;
End;

Procedure DrawDots(x,y,dots:Integer;isTop:Boolean);
Var
 dotX,dotY,dotSize:Integer;
Begin
 dotSize:=3;
 SetColor(0); { Noir }
 SetFillStyle(1, 0);
 If isTop Then dotY:=y+10
          Else dotY:=y+50;
 Case dots of
  1:Begin
   { Un point au centre }
   dotX := x + DOMINO_WIDTH div 2;
   FillEllipse(dotX, dotY, dotSize, dotSize);
  End;
  2:Begin
   { Deux points en diagonale }
   FillEllipse(x + 8, dotY - 5, dotSize, dotSize);
   FillEllipse(x + 32, dotY + 5, dotSize, dotSize);
  End;
  3:Begin
   { Trois points en diagonale }
   FillEllipse(x + 8, dotY - 8, dotSize, dotSize);
   FillEllipse(x + 20, dotY, dotSize, dotSize);
   FillEllipse(x + 32, dotY + 8, dotSize, dotSize);
  End;
  4:Begin
   { Quatre points aux coins }
   FillEllipse(x + 8, dotY - 5, dotSize, dotSize);
   FillEllipse(x + 32, dotY - 5, dotSize, dotSize);
   FillEllipse(x + 8, dotY + 5, dotSize, dotSize);
   FillEllipse(x + 32, dotY + 5, dotSize, dotSize);
  End;
  5:Begin
   { Quatre coins + centre }
   FillEllipse(x + 8, dotY - 5, dotSize, dotSize);
   FillEllipse(x + 32, dotY - 5, dotSize, dotSize);
   FillEllipse(x + 20, dotY, dotSize, dotSize);
   FillEllipse(x + 8, dotY + 5, dotSize, dotSize);
   FillEllipse(x + 32, dotY + 5, dotSize, dotSize);
  End;
  6:Begin
   { Six points en deux colonnes }
   FillEllipse(x + 12, dotY - 8, dotSize, dotSize);
   FillEllipse(x + 28, dotY - 8, dotSize, dotSize);
   FillEllipse(x + 12, dotY, dotSize, dotSize);
   FillEllipse(x + 28, dotY, dotSize, dotSize);
   FillEllipse(x + 12, dotY + 8, dotSize, dotSize);
   FillEllipse(x + 28, dotY + 8, dotSize, dotSize);
  End;
 End;
End;

Procedure DrawDomino(x,y:Integer;domino:TDomino;selected:Boolean);
Begin
 { Fond du domino }
 If selected Then SetColor(14) { Jaune }
             Else SetColor(15); { Blanc }
 SetFillStyle(1,GetColor);
 Bar(x,y,x+DOMINO_WIDTH, y+DOMINO_HEIGHT);
  { Bordure }
 SetColor(0); { Noir }
 Rectangle(x, y, x + DOMINO_WIDTH, y + DOMINO_HEIGHT);
  { Ligne de séparation au milieu }
 Line(x, y + DOMINO_HEIGHT div 2, x + DOMINO_WIDTH, y + DOMINO_HEIGHT div 2);
 { Dessiner les points }
 If domino.leftDots>0 Then DrawDots(x, y, domino.leftDots, True);
 If domino.rightDots>0 Then DrawDots(x, y, domino.rightDots, False);
End;

Procedure DrawPlayerHand;
Var
 i,x:Integer;
Begin
 For i:=1 to Game.playerHand.count do Begin
  x:=DOMINOS_START_X + (i - 1) * DOMINO_SPACING;
  DrawDomino(x, PLAYER_DOMINOS_Y, Game.playerHand.dominos[i],Game.selectedDomino=i);
 End;
End;

Procedure DrawComputerHand;
Var
 i,x:Integer;
Begin
 For i:=1 to Game.computerHand.count do Begin
  x:=DOMINOS_START_X+(i-1)*DOMINO_SPACING;
   { Dos du domino pour l'ordinateur }
  SetColor(1); { Bleu }
  SetFillStyle(1,1);
  Bar(x,COMPUTER_DOMINOS_Y,x+DOMINO_WIDTH,COMPUTER_DOMINOS_Y+DOMINO_HEIGHT);
  SetColor(0);
  Rectangle(x,COMPUTER_DOMINOS_Y,x+DOMINO_WIDTH,COMPUTER_DOMINOS_Y+DOMINO_HEIGHT);
 End;
End;

Procedure DrawBoard;
Var
 i:Integer;
Begin
 For i:=1 to Game.board.count do Begin
  DrawDomino(Game.board.dominos[i].x, Game.board.dominos[i].y,Game.board.dominos[i].domino, False);
 End;
End;

Procedure DrawUI;
Var
 s:String;
Begin
  { Fond vert }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(15);
 SetTextStyle(0, 0, 2);
 OutTextXY(SCREEN_WIDTH div 2 - 40, 5, 'DOMINO');
  { Pointages }
 SetTextStyle(0, 0, 1);
 Str(Game.playerScore, s);
 OutTextXY(10, 10, 'Joueur: ' + s);
 Str(Game.computerScore, s);
 OutTextXY(10, 25, 'Ordinateur: ' + s);
  { Tour actuel }
 If Game.currentPlayer=1 Then OutTextXY(10, 45, 'Votre tour')
                         Else OutTextXY(10, 45, 'Tour ordinateur');
 { Extrémités du plateau }
 If Game.board.count > 0 Then
 Begin
  Str(Game.board.leftEnd, s);
  OutTextXY(10, 65, 'Gauche: ' + s);
  Str(Game.board.rightEnd, s);
  OutTextXY(10, 80, 'Droite: ' + s);
 End;
  { Instructions }
 Case Game.gamePhase of
  0:OutTextXY(10, SCREEN_HEIGHT - 50, 'Appuyez ESPACE pour commencer');
  1:Begin
   If Game.currentPlayer = 1 Then Begin
    OutTextXY(10, SCREEN_HEIGHT - 65, 'Cliquez sur un domino');
    OutTextXY(10, SCREEN_HEIGHT - 50, 'G: Placer a gauche, D: Droite');
    OutTextXY(10, SCREEN_HEIGHT - 35, 'P: Passer votre tour');
   End
    Else
   OutTextXY(10, SCREEN_HEIGHT - 50, 'L''ordinateur reflechit...');
  End;
  2:Begin
   Case Game.winner of
    0:OutTextXY(10, SCREEN_HEIGHT - 50, 'MATCH NUL!');
    1:OutTextXY(10, SCREEN_HEIGHT - 50, 'VOUS GAGNEZ!');
    2:OutTextXY(10, SCREEN_HEIGHT - 50, 'ORDINATEUR GAGNE!');
   End;
   OutTextXY(10, SCREEN_HEIGHT - 35, 'Appuyez N pour nouvelle partie');
  End;
 End;
 OutTextXY(10, SCREEN_HEIGHT - 20,'ESC: Quitter');
End;

Procedure DistributeInitialDominos;
Var
 i: Integer;
Begin
 { Distribuer 7 dominos à chaque joueur }
 For i := 1 to HAND_SIZE do Begin
  Game.playerHand.dominos[i]:=Game.dominoSet.dominos[i];
  Game.playerHand.count:=i;
 End;
 For i:=1 to HAND_SIZE do Begin
  Game.computerHand.dominos[i] := Game.dominoSet.dominos[HAND_SIZE+i];
  Game.computerHand.count:=i;
 End;
  { Le reste forme la pioche }
 Game.dominoSet.count := Game.dominoSet.count - (HAND_SIZE * 2);
  { Initialiser le plateau vide }
 Game.board.count:=0;
 Game.board.leftEnd:=-1;
 Game.board.rightEnd:=-1;
 Game.gamePhase:=1;
 Game.currentPlayer:=1; { Le joueur commence }
 Game.selectedDomino:=0;
 needRedraw := True;
End;

Function CanPlaceDomino(domino:TDomino;atLeft:Boolean):Boolean;
Begin
 CanPlaceDomino:=False;
 If Game.board.count=0 Then Begin
  { Premier domino, toujours possible }
  CanPlaceDomino := True;
 End
  Else
 Begin
  If atLeft Then Begin
   { Vérifier si on peut placer à gauche }
   If(domino.leftDots=Game.board.leftEnd)or(domino.rightDots = Game.board.leftEnd)Then CanPlaceDomino:=True;
  End
   Else
  Begin
   { Vérifier si on peut placer à droite }
   If (domino.leftDots=Game.board.rightEnd)or(domino.rightDots = Game.board.rightEnd)Then
    CanPlaceDomino:=True;
  End;
 End;
End;

Procedure PlaceDominoOnBoard(domino:TDomino;atLeft:Boolean);
Var
 i,newX,newY:Integer;
 placedDomino:TDomino;
Begin
 placedDomino:=domino;
 If Game.board.count=0 Then Begin
  { Premier domino au centre }
  newX:=BOARD_CENTER_X-DOMINO_WIDTH div 2;
  newY:=BOARD_CENTER_Y-DOMINO_HEIGHT div 2;
  Game.board.leftEnd:=domino.leftDots;
  Game.board.rightEnd:=domino.rightDots;
   { Placer le premier domino }
  Inc(Game.board.count);
  Game.board.dominos[Game.board.count].domino:=placedDomino;
  Game.board.dominos[Game.board.count].x:=newX;
  Game.board.dominos[Game.board.count].y:=newY;
 End
  Else
 Begin
  If atLeft Then Begin
   { Placer à gauche du premier domino }
   newX:=Game.board.dominos[1].x-DOMINO_WIDTH-5;
   newY:=Game.board.dominos[1].y;
    { Vérifier que le domino ne sort pas de l'écran }
   If newX<10 Then Begin
     { Si on sort à gauche, décaler toute la chaîne vers la droite }
    For i:=1 to Game.board.count do Inc(Game.board.dominos[i].x, DOMINO_WIDTH + 10);
    newX:=10;
   End;
   { Ajuster l'orientation si nécessaire }
   If placedDomino.rightDots=Game.board.leftEnd Then Begin
     { Garder l'orientation }
    Game.board.leftEnd := placedDomino.leftDots;
   End
    Else
   Begin
    { Inverser le domino }
    i:=placedDomino.leftDots;
    placedDomino.leftDots:=placedDomino.rightDots;
    placedDomino.rightDots:=i;
    Game.board.leftEnd:=placedDomino.leftDots;
   End;
    { Décaler tous les dominos existants vers la droite dans le tableau }
   For i:=Game.board.count downto 1 do Begin
    Game.board.dominos[i + 1]:=Game.board.dominos[i];
   End;
    { Insérer le nouveau domino au début }
   Inc(Game.board.count);
   Game.board.dominos[1].domino:=placedDomino;
   Game.board.dominos[1].x:=newX;
   Game.board.dominos[1].y:=newY;
  End
   Else
  Begin
   { Placer à droite du dernier domino }
   newX:=Game.board.dominos[Game.board.count].x+DOMINO_WIDTH+5;
   newY:=Game.board.dominos[Game.board.count].y;
    { Vérifier que le domino ne sort pas de l'écran }
   If newX+DOMINO_WIDTH>SCREEN_WIDTH-10 Then Begin
     { Si on sort à droite, décaler toute la chaîne vers la gauche }
    For i := 1 to Game.board.count do Dec(Game.board.dominos[i].x,DOMINO_WIDTH+10);
    newX:=SCREEN_WIDTH-DOMINO_WIDTH-10;
   End;
    { Ajuster l'orientation si nécessaire }
   If placedDomino.leftDots=Game.board.rightEnd Then Begin
    { Garder l'orientation }
    Game.board.rightEnd := placedDomino.rightDots;
   End
    Else
   Begin
    { Inverser le domino }
    i:=placedDomino.leftDots;
    placedDomino.leftDots:=placedDomino.rightDots;
    placedDomino.rightDots:=i;
    Game.board.rightEnd:=placedDomino.rightDots;
   End;
    { Ajouter le nouveau domino à la fin }
   Inc(Game.board.count);
   Game.board.dominos[Game.board.count].domino:=placedDomino;
   Game.board.dominos[Game.board.count].x:=newX;
   Game.board.dominos[Game.board.count].y:=newY;
  End;
 End;
End;

Function PlayerCanPlay:Boolean;
Var
 i:Integer;
Begin
 PlayerCanPlay:=False;
 For i:=1 to Game.playerHand.count do Begin
  If CanPlaceDomino(Game.playerHand.dominos[i],True)or CanPlaceDomino(Game.playerHand.dominos[i],False)Then Begin
   PlayerCanPlay:=True;
   Exit;
  End;
 End;
End;

Function ComputerCanPlay:Boolean;
Var
 i:Integer;
Begin
 ComputerCanPlay:=False;
 For i:=1 to Game.computerHand.count do Begin
  If CanPlaceDomino(Game.computerHand.dominos[i],True)or CanPlaceDomino(Game.computerHand.dominos[i],False)Then Begin
   ComputerCanPlay := True;
   Exit;
  End;
 End;
End;

Procedure RemoveDominoFromHand(Var hand:TPlayerHand;index:Integer);
Var
 i:Integer;
Begin
 For i:=index to hand.count-1 do hand.dominos[i]:=hand.dominos[i+1];
 Dec(hand.count);
End;

Procedure ComputerPlay;
Var
 i:Integer;
Begin
 { IA simple : jouer le premier domino possible }
 For i:=1 to Game.computerHand.count do Begin
  If CanPlaceDomino(Game.computerHand.dominos[i],True) Then Begin
   PlaceDominoOnBoard(Game.computerHand.dominos[i],True);
   RemoveDominoFromHand(Game.computerHand,i);
   Break;
  End
   Else
  If CanPlaceDomino(Game.computerHand.dominos[i],False)Then Begin
   PlaceDominoOnBoard(Game.computerHand.dominos[i],False);
   RemoveDominoFromHand(Game.computerHand,i);
   Break;
  End;
 End;
  { Changer de joueur }
 Game.currentPlayer:=1;
 needRedraw:=True;
End;

Function GetDominoAtPosition(x,y:Integer):Integer;
Var
 i,dominoX:Integer;
Begin
 GetDominoAtPosition:=0;
  { Vérifier si on clique sur un domino du joueur }
 If (y>=PLAYER_DOMINOS_Y)and(y<=PLAYER_DOMINOS_Y+DOMINO_HEIGHT)Then Begin
  For i:=1 to Game.playerHand.count do Begin
   dominoX:=DOMINOS_START_X+(i-1)*DOMINO_SPACING;
   If (x>=dominoX)and(x<=dominoX+DOMINO_WIDTH)Then Begin
    GetDominoAtPosition:=i;
    Exit;
   End;
  End;
 End;
End;

Procedure HandleMouseClick(x,y:Integer);
Var
 dominoIndex:Integer;
Begin
 If(Game.gamePhase=1)and(Game.currentPlayer=1)Then Begin
  dominoIndex:=GetDominoAtPosition(x,y);
  If dominoIndex>0 Then Begin
   Game.selectedDomino:=dominoIndex;
   needRedraw:=True;
  End;
 End;
End;

Procedure CheckGameEnd;
Var
 playerTotal,computerTotal,i:Integer;
Begin
 If(Game.playerHand.count=0)or(Game.computerHand.count=0)or(not PlayerCanPlay and not ComputerCanPlay)Then Begin
  Game.gamePhase:=2;
  If Game.playerHand.count=0 Then Game.winner:=1 Else
  If Game.computerHand.count=0 Then Game.winner:=2
   Else
  Begin
   { Compter les points restants }
   playerTotal:=0;
   For i:=1 to Game.playerHand.count do
    Inc(playerTotal,Game.playerHand.dominos[i].leftDots+Game.playerHand.dominos[i].rightDots);
   computerTotal := 0;
   For i:=1 to Game.computerHand.count do
    Inc(computerTotal, Game.computerHand.dominos[i].leftDots+Game.computerHand.dominos[i].rightDots);
   If playerTotal<computerTotal Then Game.winner:=1 Else
   If computerTotal<playerTotal Then Game.winner:=2
                                Else Game.winner:=0; { Match nul }
  End;
   { Mettre à jour les pointages }
  If Game.winner=1 Then Inc(Game.playerScore) Else
  If Game.winner=2 Then Inc(Game.computerScore);
  needRedraw := True;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
 mouseX,mouseY,mouseButton:LongInt;
Begin
  { Gérer la souris }
 GetMouseState(mouseX, mouseY, mouseButton);
 If(mouseButton and 1)<>0 Then Begin
  { Attendre le relâchement }
  Repeat
   GetMouseState(mouseX, mouseY, mouseButton);
   Delay(10);
  Until (mouseButton and 1)=0;
  HandleMouseClick(mouseX, mouseY);
 End;
  { Gérer le clavier }
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   ' ': If Game.gamePhase=0 Then Begin
    DistributeInitialDominos;
   End;
   'g','G':If (Game.gamePhase=1)and(Game.currentPlayer=1)and(Game.selectedDomino>0)Then Begin
    If CanPlaceDomino(Game.playerHand.dominos[Game.selectedDomino],True)Then Begin
     PlaceDominoOnBoard(Game.playerHand.dominos[Game.selectedDomino],True);
     RemoveDominoFromHand(Game.playerHand, Game.selectedDomino);
     Game.selectedDomino:=0;
     Game.currentPlayer:=2;
     needRedraw:=True;
     CheckGameEnd;
    End;
   End;
   'd', 'D':If(Game.gamePhase=1)and(Game.currentPlayer=1)and(Game.selectedDomino>0)Then Begin
    If CanPlaceDomino(Game.playerHand.dominos[Game.selectedDomino],False)Then Begin
     PlaceDominoOnBoard(Game.playerHand.dominos[Game.selectedDomino],False);
     RemoveDominoFromHand(Game.playerHand,Game.selectedDomino);
     Game.selectedDomino:=0;
     Game.currentPlayer:=2;
     needRedraw:=True;
     CheckGameEnd;
    End;
   End;
   'p', 'P':If (Game.gamePhase=1)and(Game.currentPlayer=1)Then Begin
    If Not PlayerCanPlay Then Begin
     Game.currentPlayer:=2;
     needRedraw:=True;
     CheckGameEnd;
    End;
   End;
   'n','N':If Game.gamePhase=2 Then Begin
     { Nouvelle partie }
    InitializeDominoSet;
    Game.gamePhase:=0;
    Game.selectedDomino:=0;
    needRedraw:=True;
   End;
   #27:Game.gameOver := True; { ESC pour quitter }
  End;
 End;
  { L'ordinateur joue automatiquement }
 If(Game.gamePhase=1)and(Game.currentPlayer=2)Then Begin
  Delay(1000); { Pause pour simulation de réflexion }
  If ComputerCanPlay Then ComputerPlay
   Else
  Begin
   Game.currentPlayer:=1;
   needRedraw:=True;
  End;
  CheckGameEnd;
 End;
End;

Procedure InitializeGame;Begin
 Game.playerScore:=0;
 Game.computerScore:=0;
 Game.gamePhase:=0;
 Game.gameOver:=False;
 Game.selectedDomino:=0;
 InitializeDominoSet;
 needRedraw:=True;
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
 If ErrCode=grOk Then Begin
  SetColor(15);
  SetLineStyle(0, 0, 1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure GameLoop;Begin
 InitializeGraphics;
 InitializeGame;
 Repeat
  If needRedraw Then Begin
   DrawUI;
   DrawBoard;
   DrawComputerHand;
   DrawPlayerHand;
   needRedraw := False;
  End;
  HandleInput;
  Delay(50);
 Until Game.gameOver;
 CloseGraph;
End;

BEGIN
 Randomize;
 GameLoop;
END.