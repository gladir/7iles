{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Poker Draw a 5 cartes contre l'ordinateur
}

Program Poker;

Uses
{$IFDEF FPC}
  Windows, Crt, PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 CARD_WIDTH = 60;
 CARD_HEIGHT = 80;
 CARD_SPACING = 70;

 PLAYER_CARD_Y = 300;
 COMPUTER_CARD_Y = 50;
 CARDS_START_X = 50;

 MAX_CARDS = 52;
 HAND_SIZE = 5;

 { Types de mains (du plus faible au plus fort) }
 HIGH_CARD = 0;
 ONE_PAIR = 1;
 TWO_PAIR = 2;
 THREE_KIND = 3;
 STRAIGHT = 4;
 FLUSH = 5;
 FULL_HOUSE = 6;
 FOUR_KIND = 7;
 STRAIGHT_FLUSH = 8;
 ROYAL_FLUSH = 9;

Type
 TSuit = (Hearts, Diamonds, Clubs, Spades);
 TRank = (Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace);

 TCard = Record
  suit: TSuit;
  rank: TRank;
  visible: Boolean;
 End;

 TDeck = Record
  cards: Array[1..MAX_CARDS] of TCard;
  count: Integer;
 End;

 TPlayerHand = Record
  cards: Array[1..HAND_SIZE] of TCard;
  selected: Array[1..HAND_SIZE] of Boolean;
  count: Integer;
 End;

 TGameState = Record
  deck: TDeck;
  playerHand: TPlayerHand;
  computerHand: TPlayerHand;
  playerMoney: Integer;
  currentBet: Integer;
  pot: Integer;
  gamePhase: Integer; { 0=deal, 1=draw, 2=showdown }
  playerHandType: Integer;
  computerHandType: Integer;
  playerHandName: String;
  computerHandName: String;
  gameOver: Boolean;
  winner: Integer; { 0=tie, 1=player, 2=computer }
 End;

Var
 Game: TGameState;
 needRedraw: Boolean;

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

Function GetCardValue(rank:TRank):Integer;Begin
 GetCardValue:=Ord(rank) + 2;
End;

Function IsRed(suit:TSuit):Boolean;Begin
 IsRed:=(suit=Hearts)or(suit=Diamonds);
End;

Procedure InitializeDeck;
Var
 i,j,k:Integer;
 temp:TCard;
Begin
 { Créer le deck de 52 cartes }
 k:=1;
 For i := 0 to 3 do For j := 0 to 12 do Begin
  With Game.deck.cards[k] do Begin
   suit:=TSuit(i);
   rank:=TRank(j);
   visible:=True;
  End;
  Inc(k);
 End;
 Game.deck.count:=52;
  { Mélanger le deck }
 For i:=1 to 52 do Begin
  j:=Random(52) + 1;
  temp:=Game.deck.cards[i];
  Game.deck.cards[i]:=Game.deck.cards[j];
  Game.deck.cards[j]:=temp;
 End;
End;

Procedure DrawCardFromDeck(Var card:TCard);Begin
 card:=Game.deck.cards[Game.deck.count];
 Dec(Game.deck.count);
End;

Procedure InitializeGame;
Var
 i:Integer;
Begin
 Game.playerMoney:=1000;
 Game.currentBet:=50;
 Game.pot:=0;
 Game.gamePhase:=0;
 Game.gameOver:=False;
 Game.winner:=0;
 { Initialiser les mains }
 For i:=1 to HAND_SIZE do Begin
  Game.playerHand.selected[i] := False;
 End;
 Game.playerHand.count := 0;
 Game.computerHand.count := 0;
 InitializeDeck;
 needRedraw:=True;
End;

Procedure DrawCard(x,y:Integer;card:TCard;faceUp,selected:Boolean);
Var
 suitChar:Char;
 rankStr:String;
 color:Integer;
Begin
  { Fond de la carte }
 If selected Then SetColor(14) { Jaune }
             Else SetColor(15); { Blanc }
 SetFillStyle(1, GetColor);
 Bar(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
  { Bordure }
 SetColor(0); { Noir }
 Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
 If faceUp Then Begin
   { Déterminer la couleur }
  If IsRed(card.suit)Then color:=4 { Rouge }
                     Else color:=0; { Noir }
  { Symbole de la suite }
  Case card.suit of
   Hearts: suitChar := #3;
   Diamonds: suitChar := #4;
   Clubs: suitChar := #5;
   Spades: suitChar := #6;
  End;
   { Rang de la carte }
  Case card.rank of
   Two: rankStr := '2';
   Three: rankStr := '3';
   Four: rankStr := '4';
   Five: rankStr := '5';
   Six: rankStr := '6';
   Seven: rankStr := '7';
   Eight: rankStr := '8';
   Nine: rankStr := '9';
   Ten: rankStr := '10';
   Jack: rankStr := 'J';
   Queen: rankStr := 'Q';
   King: rankStr := 'K';
   Ace: rankStr := 'A';
  End;
   { Dessiner le rang et la suite }
  SetColor(color);
  SetTextStyle(0,0,1);
  OutTextXY(x+3,y+3,rankStr);
  OutTextXY(x+3,y+15,suitChar);
   { Symbole central }
  If card.rank>=Jack Then Begin
   SetTextStyle(0, 0, 2);
   OutTextXY(x + CARD_WIDTH div 2 - 8, y + CARD_HEIGHT div 2 - 8, rankStr);
  End
   Else
  Begin
   SetTextStyle(0, 0, 3);
   OutTextXY(x + CARD_WIDTH div 2 - 8, y + CARD_HEIGHT div 2 - 8, suitChar);
  End;
 End
  Else
 Begin
   { Dos de carte }
  SetColor(1); { Bleu }
  SetFillStyle(1, 1);
  Bar(x + 3, y + 3, x + CARD_WIDTH - 3, y + CARD_HEIGHT - 3);
  SetColor(15); { White }
  Rectangle(x + 6, y + 6, x + CARD_WIDTH - 6, y + CARD_HEIGHT - 6);
 End;
End;

Procedure DrawPlayerHand;
Var
 i,x:Integer;
Begin
 For i:=1 to Game.playerHand.count do Begin
  x:=CARDS_START_X+(i-1)*CARD_SPACING;
  DrawCard(x,PLAYER_CARD_Y,Game.playerHand.cards[i],True,Game.playerHand.selected[i]);
 End;
End;

Procedure DrawComputerHand;
Var
 i,x:Integer;
 showCards:Boolean;
Begin
 showCards:=(Game.gamePhase=2); { Montrer les cartes au showdown }
 For i:=1 to Game.computerHand.count do Begin
  x:=CARDS_START_X + (i - 1) * CARD_SPACING;
  DrawCard(x, COMPUTER_CARD_Y, Game.computerHand.cards[i], showCards, False);
 End;
End;

Function EvaluateHand(Var hand:TPlayerHand):Integer;
Var
 i:Integer;
 ranks:Array[1..13] of Integer;
 suits:Array[1..4] of Integer;
 isFlush,isStraight:Boolean;
 pairs,threes,fours:Integer;
Begin
  { Initialiser les compteurs }
 For i:=1 to 13 do ranks[i] := 0;
 For i:=1 to 4 do suits[i] := 0;
  { Compter les rangs et les couleurs }
 For i:=1 to hand.count do Begin
  Inc(ranks[Ord(hand.cards[i].rank) + 1]);
  Inc(suits[Ord(hand.cards[i].suit) + 1]);
 End;
  { Vérifier flush }
 isFlush:=False;
 For i:=1 to 4 do If suits[i]=5 Then isFlush:=True;
  { Vérifier straight }
 isStraight := False;
 For i:=1 to 9 do Begin
  If (ranks[i]=1)and(ranks[i+1]=1)and(ranks[i+2] = 1)and(ranks[i+3] = 1)and(ranks[i+4]=1)Then isStraight:=True;
 End;
  { Vérifier A-2-3-4-5 (wheel) }
 If(ranks[1] = 1)and(ranks[2]=1)and(ranks[3]=1)and(ranks[4]=1)and(ranks[13]=1)Then isStraight:=True;
  { Compter les paires, brelans, carrés }
 pairs:=0;
 threes:=0;
 fours:=0;
 For i:=1 to 13 do Begin
  If ranks[i] = 2 Then Inc(pairs);
  If ranks[i] = 3 Then Inc(threes);
  If ranks[i] = 4 Then Inc(fours);
 End;
  { Déterminer le type de main }
 If isFlush and isStraight Then Begin
  { Vérifier quinte flush royale }
  If(ranks[10]=1)and(ranks[11]=1)and(ranks[12]=1)and(ranks[13]=1)and(ranks[1]=1)Then EvaluateHand:=ROYAL_FLUSH
                                                                                Else EvaluateHand:=STRAIGHT_FLUSH;
 End
  Else
 If fours=1 Then EvaluateHand:=FOUR_KIND Else
 If(threes=1)and(pairs=1)Then EvaluateHand:=FULL_HOUSE Else
 If isFlush Then EvaluateHand:=FLUSH Else
 If isStraight Then EvaluateHand:=STRAIGHT Else
 If threes=1 Then EvaluateHand:=THREE_KIND Else
 If pairs=2 Then EvaluateHand:=TWO_PAIR Else
 If pairs=1 Then EvaluateHand:=ONE_PAIR
            Else EvaluateHand:=HIGH_CARD;
End;

Function GetHandName(handType:Integer):String;Begin
 Case handType of
  HIGH_CARD: GetHandName := 'Carte haute';
  ONE_PAIR: GetHandName := 'Paire';
  TWO_PAIR: GetHandName := 'Double paire';
  THREE_KIND: GetHandName := 'Brelan';
  STRAIGHT: GetHandName := 'Quinte';
  FLUSH: GetHandName := 'Couleur';
  FULL_HOUSE: GetHandName := 'Full';
  FOUR_KIND: GetHandName := 'Carre';
  STRAIGHT_FLUSH: GetHandName := 'Quinte flush';
  ROYAL_FLUSH: GetHandName := 'Quinte flush royale';
  Else GetHandName := 'Inconnu';
 End;
End;

Procedure DealInitialCards;
Var
 i: Integer;
Begin
 { Distribuer 5 cartes à chaque joueur }
 For i := 1 to HAND_SIZE do Begin
  DrawCardFromDeck(Game.playerHand.cards[i]);
  Game.playerHand.count := i;
 End;
 For i:=1 to HAND_SIZE do Begin
  DrawCardFromDeck(Game.computerHand.cards[i]);
  Game.computerHand.count := i;
 End;
 Game.gamePhase := 1; { Phase de draw }
 needRedraw := True;
End;

Procedure ComputerDraw;
Var
 i,j,cardsToReplace:Integer;
 handType:Integer;
Begin
  { IA simple pour l'ordinateur }
 handType := EvaluateHand(Game.computerHand);
  { Stratégie basique : garder les bonnes cartes }
 If handType >= ONE_PAIR Then cardsToReplace:=Random(2) { Garder la paire ou mieux }
                         Else cardsToReplace:=3+Random(2); { Remplacer 3-4 cartes }
  { Remplacer les cartes aléatoirement }
 For i:=1 to cardsToReplace do Begin
  j:=Random(HAND_SIZE) + 1;
  If Game.deck.count>0 Then DrawCardFromDeck(Game.computerHand.cards[j]);
 End;
End;

Procedure DrawPhase;
Var
 i,replacedCards: Integer;
Begin
 { Remplacer les cartes sélectionnées du joueur }
 replacedCards := 0;
 For i:=1 to HAND_SIZE do Begin
  If Game.playerHand.selected[i]Then Begin
   If Game.deck.count>0 Then Begin
    DrawCardFromDeck(Game.playerHand.cards[i]);
    Inc(replacedCards);
   End;
   Game.playerHand.selected[i] := False;
  End;
 End;
  { L'ordinateur fait son draw }
 ComputerDraw;
  { Passer au showdown }
 Game.gamePhase := 2;
 needRedraw := True;
End;

Procedure Showdown;Begin
 { Évaluer les mains }
 Game.playerHandType:=EvaluateHand(Game.playerHand);
 Game.computerHandType:=EvaluateHand(Game.computerHand);
 Game.playerHandName:=GetHandName(Game.playerHandType);
 Game.computerHandName:=GetHandName(Game.computerHandType);
  { Déterminer le gagnant }
 If Game.playerHandType>Game.computerHandType Then Begin
  Game.winner:=1; { Joueur gagne }
  Inc(Game.playerMoney, Game.pot);
 End
  Else
 If Game.computerHandType > Game.playerHandType Then Begin
  Game.winner:=2; { Ordinateur gagne }
 End
  Else
 Begin
  Game.winner := 0; { Match nulle }
  Inc(Game.playerMoney, Game.currentBet); { Remboursement }
 End;
 needRedraw := True;
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
 OutTextXY(SCREEN_WIDTH div 2 - 50, 10, 'POKER DRAW');
   { Informations du joueur }
 SetTextStyle(0, 0, 1);
 Str(Game.playerMoney, s);
 OutTextXY(10, SCREEN_HEIGHT - 80, 'Argent: $' + s);
 Str(Game.currentBet, s);
 OutTextXY(10, SCREEN_HEIGHT - 65, 'Mise: $' + s);
 Str(Game.pot, s);
 OutTextXY(10, SCREEN_HEIGHT - 50, 'Pot: $' + s);
  { Instructions selon la phase }
 Case Game.gamePhase of
  0:OutTextXY(10, SCREEN_HEIGHT - 35, 'Appuyez ESPACE pour distribuer');
  1:Begin
     OutTextXY(10, SCREEN_HEIGHT - 35, 'Cliquez sur les cartes a remplacer');
     OutTextXY(10, SCREEN_HEIGHT - 20, 'Appuyez ENTREE pour echanger');
    End;
  2:Begin
     OutTextXY(10, SCREEN_HEIGHT - 35, 'Votre main: ' + Game.playerHandName);
     OutTextXY(10, SCREEN_HEIGHT - 20, 'Ordinateur: ' + Game.computerHandName);
      Case Game.winner of
      0: OutTextXY(300, SCREEN_HEIGHT - 35, 'EGALITE!');
      1: OutTextXY(300, SCREEN_HEIGHT - 35, 'VOUS GAGNEZ!');
      2: OutTextXY(300, SCREEN_HEIGHT - 35, 'ORDINATEUR GAGNE!');
     End;
     OutTextXY(300, SCREEN_HEIGHT - 20, 'Appuyez N pour nouvelle partie');
    End;
 End;
 { Légende générale }
 OutTextXY(450, SCREEN_HEIGHT - 50, 'ESC: Quitter');
End;

Function GetCardAtPosition(x,y:Integer):Integer;
Var
 i,cardX:Integer;
Begin
 GetCardAtPosition := 0;
  { Vérifier si on clique sur une carte du joueur pendant la phase draw }
 If(Game.gamePhase=1)and(y >= PLAYER_CARD_Y)and(y <= PLAYER_CARD_Y + CARD_HEIGHT)Then Begin
  For i:=1 to Game.playerHand.count do Begin
   cardX:=CARDS_START_X+(i-1)*CARD_SPACING;
   If (x>=cardX)and(x <= cardX+CARD_WIDTH) Then Begin
    GetCardAtPosition := i;
    Exit;
   End;
  End;
 End;
End;

Procedure HandleMouseClick(x,y:Integer);
Var
 cardIndex:Integer;
Begin
 cardIndex:=GetCardAtPosition(x, y);
 If cardIndex>0 Then Begin
   { Toggle selection de la carte }
  Game.playerHand.selected[cardIndex] := not Game.playerHand.selected[cardIndex];
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
 If (mouseButton and 1)<>0 Then Begin
  { Attendre le relâchement }
  repeat
   GetMouseState(mouseX, mouseY, mouseButton);
   Delay(10);
  Until (mouseButton and 1) = 0;
  HandleMouseClick(mouseX, mouseY);
 End;
  { Gérer le clavier }
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   ' ': If Game.gamePhase = 0 Then Begin
     { Nouvelle donne }
    Game.pot := Game.currentBet * 2;
    Dec(Game.playerMoney, Game.currentBet);
    DealInitialCards;
   End;
   #13: If Game.gamePhase = 1 Then Begin
     { Draw phase }
    DrawPhase;
    Showdown;
   End;
   'n', 'N': If Game.gamePhase = 2 Then Begin
     { Nouvelle partie }
    If Game.playerMoney >= Game.currentBet Then Begin
     InitializeGame;
    End
     Else
    Begin
      { Game over - pas assez d'argent }
     Game.gameOver := True;
    End;
   End;
   #27: Game.gameOver := True; { ESC pour quitter }
  End;
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
 If ErrCode = grOk Then
 Begin
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
   DrawComputerHand;
   DrawPlayerHand;
   needRedraw:=False;
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