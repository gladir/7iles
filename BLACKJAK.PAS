{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu BlackJack - Atteignez 21 sans d�passer
}

Program BlackJack;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 MAX_CARDS = 21;
 CARD_WIDTH = 40;
 CARD_HEIGHT = 60;
 DECK_SIZE = 52;

Type
 TSuit = (spades, hearts, diamonds, clubs);
 TRank = (ace, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king);

 TCard = Record
  suit: TSuit;
  rank: TRank;
 End;

 TDeck = Array[0..DECK_SIZE-1] of TCard;
 THand = Array[0..MAX_CARDS-1] of TCard;

 TGameState = (gsPlaying, gsPlayerWin, gsDealerWin, gsPush, gsBlackjack, gsQuit);

 TGame=Record
  deck:TDeck;
  deckIndex: Integer;
  playerHand: THand;
  dealerHand: THand;
  playerCards: Integer;
  dealerCards: Integer;
  gameState: TGameState;
  dealerRevealed: Boolean;
  needRedraw: Boolean;
 End;

Var
 Game: TGame;

Function GetCardValue(rank: TRank): Integer;
Begin
 Case rank of
  ace: GetCardValue := 11;
  two: GetCardValue := 2;
  three: GetCardValue := 3;
  four: GetCardValue := 4;
  five: GetCardValue := 5;
  six: GetCardValue := 6;
  seven: GetCardValue := 7;
  eight: GetCardValue := 8;
  nine: GetCardValue := 9;
  ten, jack, queen, king: GetCardValue := 10;
 End;
End;

Function GetRankString(rank: TRank): String;
Begin
 Case rank of
  ace: GetRankString := 'A';
  two: GetRankString := '2';
  three: GetRankString := '3';
  four: GetRankString := '4';
  five: GetRankString := '5';
  six: GetRankString := '6';
  seven: GetRankString := '7';
  eight: GetRankString := '8';
  nine: GetRankString := '9';
  ten: GetRankString := '10';
  jack: GetRankString := 'J';
  queen: GetRankString := 'Q';
  king: GetRankString := 'K';
 End;
End;

Function GetSuitChar(suit: TSuit): Char;
Begin
 Case suit of
  spades: GetSuitChar := #6;    { ♠ }
  hearts: GetSuitChar := #3;    { ♥ }
  diamonds: GetSuitChar := #4;  { ♦ }
  clubs: GetSuitChar := #5;     { ♣ }
 End;
End;

Function GetSuitColor(suit: TSuit): Integer;
Begin
 Case suit of
  spades, clubs: GetSuitColor := 0;      { Noir }
  hearts, diamonds: GetSuitColor := 4;   { Rouge }
 End;
End;

Procedure InitializeDeck;
Var
 i, j, index: Integer;
Begin
 index := 0;
 For i := 0 to 3 do
  For j := 0 to 12 do
  Begin
   Game.deck[index].suit := TSuit(i);
   Game.deck[index].rank := TRank(j);
   Inc(index);
  End;
End;

Procedure ShuffleDeck;
Var
 i, j: Integer;
 temp: TCard;
Begin
 Randomize;
 For i := DECK_SIZE-1 downto 1 do
 Begin
  j := Random(i + 1);
  temp := Game.deck[i];
  Game.deck[i] := Game.deck[j];
  Game.deck[j] := temp;
 End;
 Game.deckIndex := 0;
End;

Procedure DealCard(Var card: TCard);
Begin
 card := Game.deck[Game.deckIndex];
 Inc(Game.deckIndex);
End;

Function CalculateHandValue(hand: THand; cardCount: Integer): Integer;
Var
 i, total, aces: Integer;
Begin
 total := 0;
 aces := 0;

 For i := 0 to cardCount-1 do
 Begin
  If hand[i].rank = ace Then
   Inc(aces)
  Else
   total := total + GetCardValue(hand[i].rank);
 End;

 { Gérer les As }
 For i := 1 to aces do
 Begin
  If total + 11 <= 21 Then
   total := total + 11
  Else
   total := total + 1;
 End;

 CalculateHandValue := total;
End;

Function IsBlackjack(hand: THand; cardCount: Integer): Boolean;
Begin
 IsBlackjack := (cardCount = 2) and (CalculateHandValue(hand, cardCount) = 21);
End;

Function IsBust(hand: THand; cardCount: Integer): Boolean;
Begin
 IsBust := CalculateHandValue(hand, cardCount) > 21;
End;

Procedure InitializeGame;
Begin
 InitializeDeck;
 ShuffleDeck;

 Game.playerCards := 0;
 Game.dealerCards := 0;
 Game.gameState := gsPlaying;
 Game.dealerRevealed := False;
 Game.needRedraw := True;

 { Distribuer les cartes initiales }
 DealCard(Game.playerHand[0]);
 Game.playerCards := 1;
 DealCard(Game.dealerHand[0]);
 Game.dealerCards := 1;
 DealCard(Game.playerHand[1]);
 Game.playerCards := 2;
 DealCard(Game.dealerHand[1]);
 Game.dealerCards := 2;

 { Vérifier BlackJack immédiat }
 If IsBlackjack(Game.playerHand, Game.playerCards) Then
 Begin
  Game.dealerRevealed := True;
  If IsBlackjack(Game.dealerHand, Game.dealerCards) Then
   Game.gameState := gsPush
  Else
   Game.gameState := gsBlackjack;
 End;
End;

Procedure PlayerHit;
Begin
 If (Game.gameState = gsPlaying) and (Game.playerCards < MAX_CARDS) Then
 Begin
  DealCard(Game.playerHand[Game.playerCards]);
  Inc(Game.playerCards);

  If IsBust(Game.playerHand, Game.playerCards) Then
  Begin
   Game.dealerRevealed := True;
   Game.gameState := gsDealerWin;
  End;

  Game.needRedraw := True;
 End;
End;

Procedure PlayerStand;
Var
 dealerValue: Integer;
Begin
 If Game.gameState = gsPlaying Then
 Begin
  Game.dealerRevealed := True;

  { Le croupier tire jusqu'à 17 }
  While CalculateHandValue(Game.dealerHand, Game.dealerCards) < 17 do
  Begin
   DealCard(Game.dealerHand[Game.dealerCards]);
   Inc(Game.dealerCards);
  End;

  dealerValue := CalculateHandValue(Game.dealerHand, Game.dealerCards);

  If IsBust(Game.dealerHand, Game.dealerCards) Then
   Game.gameState := gsPlayerWin
  Else
  Begin
   If dealerValue > CalculateHandValue(Game.playerHand, Game.playerCards) Then
    Game.gameState := gsDealerWin
   Else If dealerValue < CalculateHandValue(Game.playerHand, Game.playerCards) Then
    Game.gameState := gsPlayerWin
   Else
    Game.gameState := gsPush;
  End;

  Game.needRedraw := True;
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
   'h', 'H': PlayerHit;
   's', 'S': PlayerStand;
   'n', 'N': Begin
    If Game.gameState <> gsPlaying Then
    Begin
     InitializeGame;
     Game.needRedraw := True;
    End;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure DrawCard(x, y: Integer; card: TCard; faceDown: Boolean);
Var
 rankStr: String;
 suitChar: Char;
 suitColor: Integer;
Begin
 { Dessiner le contour de la carte }
 SetColor(15);
 SetFillStyle(1, 15);
 Bar(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
 SetColor(0);
 Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);

 If faceDown Then
 Begin
  { Carte face cachée }
  SetColor(1);
  SetFillStyle(1, 1);
  Bar(x + 2, y + 2, x + CARD_WIDTH - 2, y + CARD_HEIGHT - 2);

  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(x + 15, y + 25, '?');
 End
 Else
 Begin
  { Carte face visible }
  rankStr := GetRankString(card.rank);
  suitChar := GetSuitChar(card.suit);
  suitColor := GetSuitColor(card.suit);

  { Afficher le rang }
  SetColor(suitColor);
  SetTextStyle(0, 0, 1);
  OutTextXY(x + 5, y + 5, rankStr);
  OutTextXY(x + CARD_WIDTH - 15, y + CARD_HEIGHT - 15, rankStr);

  { Afficher la couleur }
  SetColor(suitColor);
  OutTextXY(x + CARD_WIDTH div 2 - 5, y + CARD_HEIGHT div 2 - 5, suitChar);
 End;
End;

Procedure DrawHand(x, y: Integer; hand: THand; cardCount: Integer; hideFirst: Boolean);
Var
 i: Integer;
Begin
 For i := 0 to cardCount-1 do
 Begin
  DrawCard(x + i * 50, y, hand[i], hideFirst and (i = 0));
 End;
End;

Procedure DrawHandValue(x, y: Integer; hand: THand; cardCount: Integer; hideFirst: Boolean);
Var
 value: Integer;
 valueStr: String;
Begin
 If hideFirst Then
  value := GetCardValue(hand[1].rank)
 Else
  value := CalculateHandValue(hand, cardCount);

 Str(value, valueStr);
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(x, y, 'Total: ' + valueStr);
End;

Procedure DrawGameStatus;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);

 Case Game.gameState of
  gsPlaying: Begin
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(400, 350, 'H: Tirer une carte');
   OutTextXY(400, 370, 'S: Rester');
  End;
  gsPlayerWin: Begin
   OutTextXY(400, 350, 'VOUS GAGNEZ!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(400, 380, 'N: Nouvelle partie');
  End;
  gsDealerWin: Begin
   OutTextXY(400, 350, 'VOUS PERDEZ!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(400, 380, 'N: Nouvelle partie');
  End;
  gsPush: Begin
   OutTextXY(400, 350, 'EGALITE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(400, 380, 'N: Nouvelle partie');
  End;
  gsBlackjack: Begin
   OutTextXY(400, 350, 'BLACKJACK!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(400, 380, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure DrawInstructions;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(400, 50, 'BLACKJACK');
 OutTextXY(400, 80, 'But: Atteindre 21');
 OutTextXY(400, 100, 'sans depasser');

 OutTextXY(400, 130, 'Valeurs:');
 OutTextXY(400, 150, 'As = 1 ou 11');
 OutTextXY(400, 170, 'Figures = 10');
 OutTextXY(400, 190, 'Autres = valeur');

 OutTextXY(400, 220, 'ESC: Quitter');
End;

Procedure Render;
Begin
 If Game.needRedraw Then
 Begin
  { Fond vert }
  SetColor(2);
  SetFillStyle(1, 2);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 2);
  OutTextXY(50, 20, 'BLACKJACK');

  { Main du croupier }
  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(50, 60, 'Croupier:');
  DrawHand(50, 80, Game.dealerHand, Game.dealerCards, Not Game.dealerRevealed);
  DrawHandValue(50, 150, Game.dealerHand, Game.dealerCards, Not Game.dealerRevealed);

  { Main du joueur }
  OutTextXY(50, 220, 'Joueur:');
  DrawHand(50, 240, Game.playerHand, Game.playerCards, False);
  DrawHandValue(50, 310, Game.playerHand, Game.playerCards, False);

  { Instructions et statut }
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
 OutTextXY(SCREEN_WIDTH div 2 - 100, 100, 'BLACKJACK');

 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 200, 'Le but est d''atteindre 21 points sans les depasser.');
 OutTextXY(50, 220, 'L''As vaut 1 ou 11, les figures valent 10.');
 OutTextXY(50, 240, 'Le croupier tire jusqu''a 17.');
 OutTextXY(50, 260, 'BlackJack = 21 avec 2 cartes.');

 OutTextXY(50, 300, 'Commandes:');
 OutTextXY(50, 320, 'H: Tirer une carte (Hit)');
 OutTextXY(50, 340, 'S: Rester (Stand)');
 OutTextXY(50, 360, 'N: Nouvelle partie');

 OutTextXY(50, 400, 'Appuyez sur ENTREE pour commencer...');
 OutTextXY(50, 420, 'ESC pour quitter');

 Repeat
  If KeyPressed Then
  Begin
   Case ReadKey of
    #13: Exit;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure GameLoop;
Begin
 While Game.gameState <> gsQuit do
 Begin
  HandleInput;
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
End;

BEGIN
 InitializeGraphics;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.
