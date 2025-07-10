{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Gin Rummy - Jeu de cartes classique
}

Program GinRummy;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 CARD_WIDTH = 40;
 CARD_HEIGHT = 55;
 MAX_CARDS = 52;
 HAND_SIZE = 10;
 PLAYER_Y = 380;
 COMPUTER_Y = 50;
 DISCARD_X = 320;
 DISCARD_Y = 200;
 STOCK_X = 250;
 STOCK_Y = 200;

Type
 TSuit = (sHearts, sDiamonds, sClubs, sSpades);
 TValue = (vAce, v2, v3, v4, v5, v6, v7, v8, v9, v10, vJack, vQueen, vKing);
 
 TCard = Record
  suit: TSuit;
  value: TValue;
  visible: Boolean;
 End;
 
 TDeck = Array[1..MAX_CARDS] of TCard;
 THandCards = Array[1..HAND_SIZE + 1] of TCard; { +1 pour la carte piochée }
 
 TGameState = (gsPlaying, gsPlayerKnocks, gsComputerKnocks, gsPlayerGin, gsComputerGin, gsGameOver, gsQuit);
 
 TGame = Record
  deck: TDeck;
  deckTop: Integer;
  playerHand: THandCards;
  computerHand: THandCards;
  playerCardCount: Integer;
  computerCardCount: Integer;
  discardPile: Array[1..52] of TCard;
  discardTop: Integer;
  currentPlayer: Integer; { 1=Player, 2=Computer }
  gameState: TGameState;
  selectedCard: Integer;
  needRedraw: Boolean;
  playerScore: Integer;
  computerScore: Integer;
  gameMode: Integer; { 1=vs Computer, 2=vs Human }
  canKnock: Boolean;
  lastAction: String;
  turnPhase: Integer; { 1=Draw, 2=Discard }
 End;

Var
 Game: TGame;

{ Déclarations forward }
Procedure InitializeGame; Forward;

Function GetSuitName(suit: TSuit): String;
Begin
 Case suit of
  sHearts: GetSuitName := 'Coeur';
  sDiamonds: GetSuitName := 'Carreau';
  sClubs: GetSuitName := 'Trefle';
  sSpades: GetSuitName := 'Pique';
 End;
End;

Function GetValueName(value: TValue): String;
Begin
 Case value of
  vAce: GetValueName := 'A';
  v2: GetValueName := '2';
  v3: GetValueName := '3';
  v4: GetValueName := '4';
  v5: GetValueName := '5';
  v6: GetValueName := '6';
  v7: GetValueName := '7';
  v8: GetValueName := '8';
  v9: GetValueName := '9';
  v10: GetValueName := '10';
  vJack: GetValueName := 'V';
  vQueen: GetValueName := 'D';
  vKing: GetValueName := 'R';
 End;
End;

Function GetCardValue(value: TValue): Integer;
Begin
 Case value of
  vAce: GetCardValue := 1;
  v2: GetCardValue := 2;
  v3: GetCardValue := 3;
  v4: GetCardValue := 4;
  v5: GetCardValue := 5;
  v6: GetCardValue := 6;
  v7: GetCardValue := 7;
  v8: GetCardValue := 8;
  v9: GetCardValue := 9;
  v10: GetCardValue := 10;
  vJack: GetCardValue := 10;
  vQueen: GetCardValue := 10;
  vKing: GetCardValue := 10;
 End;
End;

Function GetSuitColor(suit: TSuit): Integer;
Begin
 Case suit of
  sHearts, sDiamonds: GetSuitColor := 12; { Rouge }
  sClubs, sSpades: GetSuitColor := 0; { Noir }
 End;
End;

Function GetSuitChar(suit: TSuit): Char;
Begin
 Case suit of
  sHearts: GetSuitChar := #3;
  sDiamonds: GetSuitChar := #4;
  sClubs: GetSuitChar := #5;
  sSpades: GetSuitChar := #6;
 End;
End;

Procedure InitializeDeck;
Var
 cardIndex: Integer;
 suit: TSuit;
 value: TValue;
Begin
 cardIndex := 1;
 For suit := sHearts to sSpades do
  For value := vAce to vKing do
  Begin
   Game.deck[cardIndex].suit := suit;
   Game.deck[cardIndex].value := value;
   Game.deck[cardIndex].visible := True;
   Inc(cardIndex);
  End;
 Game.deckTop := 52;
End;

Procedure ShuffleDeck;
Var
 i, j: Integer;
 temp: TCard;
Begin
 For i := 1 to 100 do
 Begin
  j := Random(Game.deckTop) + 1;
  temp := Game.deck[1];
  Game.deck[1] := Game.deck[j];
  Game.deck[j] := temp;
 End;
End;

Procedure GetCard(Var result: TCard);
Begin
 If Game.deckTop > 0 Then
 Begin
  result := Game.deck[Game.deckTop];
  Dec(Game.deckTop);
 End
 Else
 Begin
  { Reshuffler la pioche avec la défausse sauf la dernière carte }
  Game.deckTop := Game.discardTop - 1;
  { Récupérer une carte par défaut depuis la pioche restante }
  If Game.deckTop > 0 Then
  Begin
   result := Game.deck[Game.deckTop];
   Dec(Game.deckTop);
  End
  Else
  Begin
   { Situation d'urgence - créer une carte par défaut }
   result.suit := sHearts;
   result.value := vAce;
   result.visible := True;
  End;
 End;
End;

Procedure AddToDiscard(card: TCard);
Begin
 Inc(Game.discardTop);
 Game.discardPile[Game.discardTop] := card;
End;

Procedure DealInitialCards;
Var
 i: Integer;
Begin
 { Distribuer 10 cartes à chaque joueur }
 For i := 1 to HAND_SIZE do
 Begin
  GetCard(Game.playerHand[i]);
  GetCard(Game.computerHand[i]);
 End;
 Game.playerCardCount := HAND_SIZE;
 Game.computerCardCount := HAND_SIZE;
 
 { Première carte de la défausse }
 Game.discardTop := 1;
 GetCard(Game.discardPile[1]);
End;

Procedure SortHand(Var hand: THandCards; count: Integer);
Var
 i, j: Integer;
 temp: TCard;
Begin
 For i := 1 to count - 1 do
  For j := i + 1 to count do
   If (Ord(hand[i].suit) > Ord(hand[j].suit)) or
      ((hand[i].suit = hand[j].suit) and (Ord(hand[i].value) > Ord(hand[j].value))) Then
   Begin
    temp := hand[i];
    hand[i] := hand[j];
    hand[j] := temp;
   End;
End;

Function IsRun(cards: Array of TCard; count: Integer): Boolean;
Var
 i: Integer;
 suit: TSuit;
Begin
 IsRun := False;
 If count < 3 Then Exit;
 
 suit := cards[0].suit;
 For i := 1 to count - 1 do
 Begin
  If (cards[i].suit <> suit) or 
     (Ord(cards[i].value) <> Ord(cards[i-1].value) + 1) Then
   Exit;
 End;
 IsRun := True;
End;

Function IsSet(cards: Array of TCard; count: Integer): Boolean;
Var
 i: Integer;
 value: TValue;
Begin
 IsSet := False;
 If count < 3 Then Exit;
 
 value := cards[0].value;
 For i := 1 to count - 1 do
  If cards[i].value <> value Then Exit;
 
 IsSet := True;
End;

Function CalculateDeadwood(Var hand: THandCards; count: Integer): Integer;
Var
 i, total: Integer;
Begin
 total := 0;
 
 { Version simplifiée - calcul basique du deadwood }
 For i := 1 to count do
  total := total + GetCardValue(hand[i].value);
 
 CalculateDeadwood := total;
End;

Function CanKnock(Var hand: THandCards; count: Integer): Boolean;
Begin
 CanKnock := CalculateDeadwood(hand, count) <= 10;
End;

Function HasGin(Var hand: THandCards; count: Integer): Boolean;
Begin
 HasGin := CalculateDeadwood(hand, count) = 0;
End;

Procedure DrawCard(x, y: Integer; card: TCard; faceUp: Boolean; selected: Boolean);
Var
 valueStr: String;
 suitChar: Char;
Begin
 { Fond de la carte }
 If faceUp Then
 Begin
  SetColor(15);
  SetFillStyle(1, 15);
 End
 Else
 Begin
  SetColor(1);
  SetFillStyle(1, 1);
 End;
 
 Bar(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
 
 { Contour }
 If selected Then
 Begin
  SetColor(14);
  SetLineStyle(0, 0, 2);
 End
 Else
 Begin
  SetColor(0);
  SetLineStyle(0, 0, 1);
 End;
 Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
 SetLineStyle(0, 0, 1);
 
 If faceUp Then
 Begin
  { Valeur de la carte }
  valueStr := GetValueName(card.value);
  SetColor(GetSuitColor(card.suit));
  SetTextStyle(0, 0, 1);
  OutTextXY(x + 2, y + 2, valueStr);
  
  { Symbole de la couleur }
  suitChar := GetSuitChar(card.suit);
  OutTextXY(x + 2, y + 12, suitChar);
  
  { Valeur en bas à droite (inversée) }
  OutTextXY(x + CARD_WIDTH - 10, y + CARD_HEIGHT - 15, valueStr);
 End
 Else
 Begin
  { Dos de carte }
  SetColor(4);
  SetFillStyle(11, 4);
  Bar(x + 2, y + 2, x + CARD_WIDTH - 2, y + CARD_HEIGHT - 2);
 End;
End;

Procedure DrawPlayerHand;
Var
 i, x: Integer;
Begin
 For i := 1 to Game.playerCardCount do
 Begin
  x := 0 + (i - 1) * (CARD_WIDTH + 5);
  DrawCard(x, PLAYER_Y, Game.playerHand[i], True, i = Game.selectedCard);
 End;
End;

Procedure DrawComputerHand;
Var
 i, x: Integer;
Begin
 For i := 1 to Game.computerCardCount do
 Begin
  x := 0 + (i - 1) * (CARD_WIDTH + 5);
  DrawCard(x, COMPUTER_Y, Game.computerHand[i], False, False);
 End;
End;

Procedure DrawGameArea;
Begin
 { Pioche }
 If Game.deckTop > 0 Then
  DrawCard(STOCK_X, STOCK_Y, Game.deck[Game.deckTop], False, False);
 
 { Défausse }
 If Game.discardTop > 0 Then
  DrawCard(DISCARD_X, DISCARD_Y, Game.discardPile[Game.discardTop], True, False);
End;

Procedure DrawGameInfo;
Var
 scoreStr, deadwoodStr: String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 
 OutTextXY(450, 50, 'GIN RUMMY');
 
 Str(Game.playerScore, scoreStr);
 OutTextXY(450, 80, 'Votre score: ' + scoreStr);
 
 Str(Game.computerScore, scoreStr);
 OutTextXY(450, 100, 'IA score: ' + scoreStr);
 
 Str(CalculateDeadwood(Game.playerHand, Game.playerCardCount), deadwoodStr);
 OutTextXY(450, 120, 'Deadwood: ' + deadwoodStr);
 
 If Game.currentPlayer = 1 Then
  OutTextXY(450, 140, 'Votre tour')
 Else
  OutTextXY(450, 140, 'Tour IA');
 
 If Game.turnPhase = 1 Then
  OutTextXY(450, 160, 'Phase: Piocher')
 Else
  OutTextXY(450, 160, 'Phase: Défausser');
 
 If Game.canKnock Then
 Begin
  SetColor(14);
  OutTextXY(450, 180, 'Vous pouvez frapper!');
 End;
 
 SetColor(15);
 OutTextXY(450, 200, 'Actions:');
 OutTextXY(250, 280, 'PIOCHE');
 OutTextXY(320, 280, 'DEFAUSSE');
End;

Procedure DrawInstructions;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 
 OutTextXY(450, 230, 'Regles:');
 OutTextXY(450, 250, '- Former suites et groupes');
 OutTextXY(450, 265, '- Deadwood <= 10 pour frapper');
 OutTextXY(450, 280, '- Deadwood = 0 pour Gin');
 
 OutTextXY(450, 310, 'Commandes:');
 OutTextXY(450, 330, 'Fleches: Selection');
 OutTextXY(450, 345, 'ENTREE: Piocher/Jouer');
 OutTextXY(450, 360, 'D: Defausser');
 OutTextXY(450, 375, 'K: Frapper (Knock)');
 OutTextXY(450, 390, 'S: Trier main');
 OutTextXY(450, 405, 'N: Nouvelle partie');
 OutTextXY(450, 420, 'ESC: Quitter');
End;

Procedure DrawGameStatus;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 1);
 
 If Game.lastAction <> '' Then
  OutTextXY(50, 320, Game.lastAction);
 
 Case Game.gameState of
  gsPlayerKnocks: OutTextXY(50, 340, 'Vous frappez!');
  gsComputerKnocks: OutTextXY(50, 340, 'IA frappe!');
  gsPlayerGin: OutTextXY(50, 340, 'GIN! Vous gagnez!');
  gsComputerGin: OutTextXY(50, 340, 'IA fait Gin!');
  gsGameOver: OutTextXY(50, 340, 'Partie terminee');
 End;
End;

Function GetCardAt(x, y: Integer): Integer;
Var
 i, cardX: Integer;
Begin
 GetCardAt := 0;
 
 { Vérifier les cartes du joueur }
 For i := 1 to Game.playerCardCount do
 Begin
  cardX := 0 + (i - 1) * (CARD_WIDTH + 5);
  If (x >= cardX) and (x <= cardX + CARD_WIDTH) and
     (y >= PLAYER_Y) and (y <= PLAYER_Y + CARD_HEIGHT) Then
  Begin
   GetCardAt := i;
   Exit;
  End;
 End;
 
 { Vérifier la pioche }
 If (x >= STOCK_X) and (x <= STOCK_X + CARD_WIDTH) and
    (y >= STOCK_Y) and (y <= STOCK_Y + CARD_HEIGHT) Then
  GetCardAt := -1; { Pioche }
 
 { Vérifier la défausse }
 If (x >= DISCARD_X) and (x <= DISCARD_X + CARD_WIDTH) and
    (y >= DISCARD_Y) and (y <= DISCARD_Y + CARD_HEIGHT) Then
  GetCardAt := -2; { Défausse }
End;

Procedure PlayerDrawFromStock;
Begin
 If (Game.deckTop > 0) and (Game.playerCardCount < HAND_SIZE + 1) Then
 Begin
  Inc(Game.playerCardCount);
  GetCard(Game.playerHand[Game.playerCardCount]);
  Game.turnPhase := 2; { Phase défausse }
  Game.lastAction := 'Vous piochez du stock';
  Game.needRedraw := True;
 End;
End;

Procedure PlayerDrawFromDiscard;
Begin
 If (Game.discardTop > 0) and (Game.playerCardCount < HAND_SIZE + 1) Then
 Begin
  Inc(Game.playerCardCount);
  Game.playerHand[Game.playerCardCount] := Game.discardPile[Game.discardTop];
  Dec(Game.discardTop);
  Game.turnPhase := 2; { Phase défausse }
  Game.lastAction := 'Vous piochez de la defausse';
  Game.needRedraw := True;
 End;
End;

Procedure PlayerDiscard(cardIndex: Integer);
Begin
 If (cardIndex > 0) and (cardIndex <= Game.playerCardCount) and (Game.turnPhase = 2) Then
 Begin
  AddToDiscard(Game.playerHand[cardIndex]);
  
  { Décaler les cartes }
  While cardIndex < Game.playerCardCount do
  Begin
   Game.playerHand[cardIndex] := Game.playerHand[cardIndex + 1];
   Inc(cardIndex);
  End;
  Dec(Game.playerCardCount);
  
  Game.currentPlayer := 2; { Tour de l'IA }
  Game.turnPhase := 1; { Phase pioche }
  Game.lastAction := 'Vous defaussez';
  Game.selectedCard := 0;
  Game.needRedraw := True;
 End;
End;

Procedure ComputerTurn;
Var
 i, bestCard, minDeadwood, testDeadwood: Integer;
 tempHand: THandCards;
 tempCount: Integer;
Begin
 If Game.currentPlayer <> 2 Then Exit;
 
 Delay(1000); { Délai pour la réflexion }
 
 { Phase pioche }
 If Game.turnPhase = 1 Then
 Begin
  { IA pioche toujours du stock pour cette version simple }
  Inc(Game.computerCardCount);
  GetCard(Game.computerHand[Game.computerCardCount]);
  Game.turnPhase := 2;
  Game.lastAction := 'IA pioche du stock';
 End
 Else
 Begin
  { Phase défausse - choisir la carte qui minimise le deadwood }
  bestCard := 1;
  minDeadwood := 999;
  
  For i := 1 to Game.computerCardCount do
  Begin
   { Simuler la défausse de cette carte }
   tempCount := 0;
   For testDeadwood := 1 to Game.computerCardCount do
    If testDeadwood <> i Then
    Begin
     Inc(tempCount);
     tempHand[tempCount] := Game.computerHand[testDeadwood];
    End;
   
   testDeadwood := CalculateDeadwood(tempHand, tempCount);
   If testDeadwood < minDeadwood Then
   Begin
    minDeadwood := testDeadwood;
    bestCard := i;
   End;
  End;
  
  { Défausser la meilleure carte }
  AddToDiscard(Game.computerHand[bestCard]);
  
  { Décaler les cartes }
  While bestCard < Game.computerCardCount do
  Begin
   Game.computerHand[bestCard] := Game.computerHand[bestCard + 1];
   Inc(bestCard);
  End;
  Dec(Game.computerCardCount);
  
  Game.currentPlayer := 1; { Tour du joueur }
  Game.turnPhase := 1;
  Game.lastAction := 'IA defausse';
 End;
 
 Game.needRedraw := True;
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
      If Game.selectedCard > 1 Then
      Begin
       Dec(Game.selectedCard);
       Game.needRedraw := True;
      End;
     End;
     #77: Begin { Flèche droite }
      If Game.selectedCard < Game.playerCardCount Then
      Begin
       Inc(Game.selectedCard);
       Game.needRedraw := True;
      End
      Else If Game.selectedCard = 0 Then
      Begin
       Game.selectedCard := 1;
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   #13: Begin { Entrée }
    If Game.currentPlayer = 1 Then
    Begin
     If Game.turnPhase = 1 Then
     Begin
      { Piocher du stock }
      PlayerDrawFromStock;
     End
     Else If (Game.selectedCard > 0) and (Game.turnPhase = 2) Then
     Begin
      { Défausser la carte sélectionnée }
      PlayerDiscard(Game.selectedCard);
     End;
    End;
   End;
   'd', 'D': Begin { Défausser }
    If (Game.currentPlayer = 1) and (Game.selectedCard > 0) and (Game.turnPhase = 2) Then
     PlayerDiscard(Game.selectedCard);
   End;
   'p', 'P': Begin { Piocher de la défausse }
    If (Game.currentPlayer = 1) and (Game.turnPhase = 1) Then
     PlayerDrawFromDiscard;
   End;
   'k', 'K': Begin { Knock }
    If (Game.currentPlayer = 1) and CanKnock(Game.playerHand, Game.playerCardCount) Then
    Begin
     Game.gameState := gsPlayerKnocks;
     Game.needRedraw := True;
    End;
   End;
   's', 'S': Begin { Trier }
    SortHand(Game.playerHand, Game.playerCardCount);
    Game.needRedraw := True;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure CheckGameEnd;
Begin
 { Vérifier Gin }
 If HasGin(Game.playerHand, Game.playerCardCount) Then
  Game.gameState := gsPlayerGin
 Else If HasGin(Game.computerHand, Game.computerCardCount) Then
  Game.gameState := gsComputerGin;
 
 { Vérifier si le stock est vide }
 If Game.deckTop <= 0 Then
  Game.gameState := gsGameOver;
 
 { Mettre à jour les informations de frappe }
 Game.canKnock := CanKnock(Game.playerHand, Game.playerCardCount);
End;

Procedure Render;
Begin
 If Game.needRedraw Then
 Begin
  { Fond }
  SetColor(2);
  SetFillStyle(1, 2);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  
  { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 3);
  OutTextXY(50, 10, 'GIN RUMMY');
  
  DrawPlayerHand;
  DrawComputerHand;
  DrawGameArea;
  DrawGameInfo;
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
 
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 60, 'GIN RUMMY');
 
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de cartes classique ou il faut former des combinaisons');
 OutTextXY(50, 140, 'pour minimiser les points de deadwood.');
 
 OutTextXY(50, 170, 'Regles:');
 OutTextXY(50, 190, '- Former des suites (meme couleur) et groupes (meme valeur)');
 OutTextXY(50, 210, '- Les cartes non utilisees comptent comme deadwood');
 OutTextXY(50, 230, '- Frapper (Knock) quand deadwood <= 10 points');
 OutTextXY(50, 250, '- Gin = deadwood 0, bonus de 25 points');
 
 OutTextXY(50, 280, 'Commandes:');
 OutTextXY(50, 300, 'Fleches: Selectionner une carte');
 OutTextXY(50, 320, 'ENTREE: Piocher du stock / Defausser carte');
 OutTextXY(50, 340, 'P: Piocher de la defausse');
 OutTextXY(50, 360, 'K: Frapper (Knock) si deadwood <= 10');
 OutTextXY(50, 380, 'S: Trier votre main');
 
 OutTextXY(50, 410, 'Appuyez sur une touche pour commencer...');
 
 ReadKey;
End;

Procedure InitializeGame;
Begin
 { Initialiser le jeu }
 InitializeDeck;
 ShuffleDeck;
 
 Game.playerCardCount := 0;
 Game.computerCardCount := 0;
 Game.discardTop := 0;
 Game.currentPlayer := 1;
 Game.gameState := gsPlaying;
 Game.selectedCard := 1;
 Game.needRedraw := True;
 Game.playerScore := 0;
 Game.computerScore := 0;
 Game.gameMode := 1;
 Game.canKnock := False;
 Game.lastAction := '';
 Game.turnPhase := 1; { Commencer par piocher }
 
 DealInitialCards;
 SortHand(Game.playerHand, Game.playerCardCount);
 SortHand(Game.computerHand, Game.computerCardCount);
End;

Procedure GameLoop;
Begin
 While Game.gameState <> gsQuit do
 Begin
  HandleInput;
  
  If Game.currentPlayer = 2 Then
   ComputerTurn;
  
  CheckGameEnd;
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
