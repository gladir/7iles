{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de cartes Bataille - Jeu classique √† deux joueurs
}

Program Bataille;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 MAX_CARDS = 52;
 CARD_WIDTH = 50;
 CARD_HEIGHT = 70;
 ANIMATION_DELAY = 200;

Type
 TCardSuit=(csSpades, csHearts, csDiamonds,csClubs);
 TCardValue = (cv2, cv3, cv4, cv5, cv6, cv7, cv8, cv9, cv10, cvJack, cvQueen, cvKing, cvAce);

 TCard=Record
  suit:TCardSuit;
  value:TCardValue;
 End;

 TPlayer=Record
  name:String;
  cards:Array[1..MAX_CARDS] of TCard;
  cardCount:Integer;
  isHuman:Boolean;
 End;

 TGameState=(gsPlaying,gsGameOver,gsWaitingInput,gsBattle);

 TGame=Record
  player1,player2:TPlayer;
  gameState:TGameState;
  currentCard1,currentCard2:TCard;
  hasCurrentCards:Boolean;
  winner:Integer;
  lastAction:String;
  battleCards:Array[1..10] of Record
   card1,card2:TCard;
   valid:Boolean;
  End;
  battleCount:Integer;
  needRedraw:Boolean;
  roundWinner:Integer;
 End;

Var
 Game:TGame;
 Deck:Array[1..MAX_CARDS] of TCard;

{ DÇclarations forward }
Procedure InitializeGame; Forward;

Function GetCardValueName(value:TCardValue):String;Begin
 Case value of
  cv2: GetCardValueName := '2';
  cv3: GetCardValueName := '3';
  cv4: GetCardValueName := '4';
  cv5: GetCardValueName := '5';
  cv6: GetCardValueName := '6';
  cv7: GetCardValueName := '7';
  cv8: GetCardValueName := '8';
  cv9: GetCardValueName := '9';
  cv10: GetCardValueName := '10';
  cvJack: GetCardValueName := 'V';
  cvQueen: GetCardValueName := 'D';
  cvKing: GetCardValueName := 'R';
  cvAce: GetCardValueName := 'As';
 End;
End;

Function GetCardSuitName(suit:TCardSuit):String;Begin
 Case suit of
  csSpades:GetCardSuitName:='Pique';
  csHearts:GetCardSuitName:='Coeur';
  csDiamonds:GetCardSuitName:='Carreau';
  csClubs:GetCardSuitName:='Trefle';
 End;
End;

Function GetCardSuitChar(suit:TCardSuit):Char;Begin
 Case suit of
  csSpades:GetCardSuitChar := #6;    { Pique }
  csHearts:GetCardSuitChar := #3;    { Coeur }
  csDiamonds:GetCardSuitChar := #4;  { Carreau }
  csClubs:GetCardSuitChar := #5;     { Tr√®fle }
 End;
End;

Function GetCardColor(suit:TCardSuit):Integer;Begin
 Case suit of
  csSpades,csClubs: GetCardColor := 0;     { Noir }
  csHearts,csDiamonds: GetCardColor := 4;  { Rouge }
 End;
End;

Function GetCardValue(value:TCardValue):Integer;Begin
 Case value of
  cv2: GetCardValue := 2;
  cv3: GetCardValue := 3;
  cv4: GetCardValue := 4;
  cv5: GetCardValue := 5;
  cv6: GetCardValue := 6;
  cv7: GetCardValue := 7;
  cv8: GetCardValue := 8;
  cv9: GetCardValue := 9;
  cv10: GetCardValue := 10;
  cvJack: GetCardValue := 11;
  cvQueen: GetCardValue := 12;
  cvKing: GetCardValue := 13;
  cvAce: GetCardValue := 14;
 End;
End;

Procedure InitializeDeck;
Var
 i,suitIndex,valueIndex:Integer;
Begin
 i:=1;
 For suitIndex:=0 to 3 do For valueIndex:=0 to 12 do Begin
  Deck[i].suit:=TCardSuit(suitIndex);
  Deck[i].value:=TCardValue(valueIndex);
  Inc(i);
 End;
End;

Procedure ShuffleDeck;
Var
 i,j:Integer;
 tempCard:TCard;
Begin
 For i:=1 to MAX_CARDS do Begin
  j:=Random(MAX_CARDS)+1;
  tempCard:=Deck[i];
  Deck[i]:=Deck[j];
  Deck[j]:=tempCard;
 End;
End;

Procedure DistributeCards;
Var
 i:Integer;
Begin
 { Distribuer 26 cartes Ö chaque joueur }
 Game.player1.cardCount:=26;
 Game.player2.cardCount:=26;
 For i:=1 to 26 do Begin
  Game.player1.cards[i] := Deck[i];
  Game.player2.cards[i] := Deck[i + 26];
 End;
End;

Procedure DrawCard(x,y:Integer;card:TCard;faceUp:Boolean);
Var
 valueStr:String;
 suitChar:Char;
 textColor:Integer;
Begin
 { Fond de la carte }
 If faceUp Then Begin
  SetColor(15);
  SetFillStyle(1, 15);
 End
  Else
 Begin
  SetColor(1);
  SetFillStyle(1, 1);
 End;
 Bar(x,y,x+CARD_WIDTH,y+CARD_HEIGHT);
  { Contour de la carte }
 SetColor(0);
 Rectangle(x,y,x+CARD_WIDTH,y+CARD_HEIGHT);
 If faceUp Then Begin
  { Afficher la valeur et la couleur }
  valueStr:=GetCardValueName(card.value);
  suitChar:=GetCardSuitChar(card.suit);
  textColor:=GetCardColor(card.suit);
  SetColor(textColor);
  SetTextStyle(0,0,1);
   { Valeur en haut √† gauche }
  OutTextXY(x+5,y+5,valueStr);
   { Symbole de la couleur au centre }
  SetTextStyle(0,0,3);
  OutTextXY(x+CARD_WIDTH div 2-10,y+CARD_HEIGHT div 2-10,suitChar);
   { Valeur en bas Ö droite (inversÇe) }
  SetTextStyle(0,0,1);
  OutTextXY(x+CARD_WIDTH-15,y+CARD_HEIGHT-15,valueStr);
 End
  Else
 Begin
  { Dos de carte - motif }
  SetColor(1);
  SetFillStyle(11,1);
  Bar(x+5, y+5,x+CARD_WIDTH-5,y+CARD_HEIGHT-5);
 End;
End;

Procedure DrawPlayingField;
Var
 i:Integer;
Begin
 { Fond }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
  { Titre }
 SetColor(15);
 SetTextStyle(0,0,2);
 OutTextXY(SCREEN_WIDTH div 2-50,10,'BATAILLE');
  { Zones des joueurs }
 SetColor(15);
 SetTextStyle(0,0,1);
 OutTextXY(50,50,'Joueur 1 (Vous)');
 OutTextXY(50,70,'Cartes: ' + Chr(Ord('0') +
                 Game.player1.cardCount div 10)+Chr(Ord('0')+
                 Game.player1.cardCount mod 10));
 OutTextXY(450, 50, 'Joueur 2 (ordinateur)');
 OutTextXY(450, 70, 'Cartes: ' + Chr(Ord('0') +
                    Game.player2.cardCount div 10) + Chr(Ord('0') +
                    Game.player2.cardCount mod 10));
  { Piles de cartes (dos) }
 DrawCard(70, 100, Game.player1.cards[1], False);
 DrawCard(470, 100, Game.player2.cards[1], False);
  { Cartes jou√©es au centre }
 If Game.hasCurrentCards Then Begin
  DrawCard(200, 200,Game.currentCard1,True);
  DrawCard(350, 200,Game.currentCard2,True);
 End;
 { Afficher les cartes de bataille si n√©cessaire }
 If Game.battleCount > 0 Then Begin
  SetColor(14);
  OutTextXY(SCREEN_WIDTH div 2 - 30, 180, 'BATAILLE !');
  { Afficher les cartes de bataille }
  For i := 1 to Game.battleCount do If Game.battleCards[i].valid Then Begin
    DrawCard(150 + i * 15, 300, Game.battleCards[i].card1, False);
    DrawCard(350 + i * 15, 300, Game.battleCards[i].card2, False);
   End;
 End;
End;

Procedure DrawGameStatus;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
  { Instructions }
 OutTextXY(50, 400, 'Appuyez sur ESPACE pour jouer une carte');
 OutTextXY(50, 420, 'ESC pour quitter');
  { Derniäre action }
 If Game.lastAction<>''Then Begin
  SetColor(14);
  OutTextXY(50, 440, Game.lastAction);
 End;
  { Afficher le gagnant du round }
 If Game.roundWinner>0 Then Begin
  SetColor(12);
  SetTextStyle(0,0,2);
  If Game.roundWinner=1 Then OutTextXY(200,320,'VOUS GAGNEZ!')
                        Else OutTextXY(200,320,'ORDINATEUR GAGNE!');
 End;
  { Afficher le gagnant final }
 If Game.gameState=gsGameOver Then Begin
  SetColor(15);
  SetFillStyle(1, 4);
  Bar(150, 150, 490, 250);
  SetColor(0);
  Rectangle(150, 150, 490, 250);
  SetColor(15);
  SetTextStyle(0, 0, 2);
  OutTextXY(200, 180, 'PARTIE TERMINEE');
  SetTextStyle(0, 0, 1);
  If Game.winner=1 Then OutTextXY(220, 210, 'VOUS AVEZ GAGNE!')
                   Else OutTextXY(220, 210, 'L''ORDINATEUR A GAGNE!');
  OutTextXY(180, 230, 'Appuyez sur N pour rejouer');
 End;
End;

Function CompareCards(card1,card2:TCard):Integer;
Var
 value1,value2:Integer;
Begin
 value1:=GetCardValue(card1.value);
 value2:=GetCardValue(card2.value);
 If value1>value2 Then CompareCards:=1 Else
 If value1<value2 Then CompareCards:=-1
                  Else CompareCards:=0;
End;

Procedure RemoveCard(Var player:TPlayer);
Var
 i:Integer;
Begin
 If player.cardCount>0 Then Begin
  { DÇcaler toutes les cartes vers la gauche }
  For i:=1 to player.cardCount-1 do player.cards[i]:=player.cards[i+1];
  Dec(player.cardCount);
 End;
End;

Procedure AddCard(Var player:TPlayer;card:TCard);Begin
 If player.cardCount<MAX_CARDS Then Begin
  Inc(player.cardCount);
  player.cards[player.cardCount] := card;
 End;
End;

Procedure AddCards(Var player:TPlayer;cards:Array of TCard;count:Integer);
Var
 i:Integer;
Begin
 For i:=0 to count-1 do AddCard(player, cards[i]);
End;

Procedure PlayRound;
Var
 result:Integer;
 i,totalCards:Integer;
 wonCards:Array[1..20] of TCard;
Begin
 If(Game.player1.cardCount = 0)or(Game.player2.cardCount=0)Then Begin
  Game.gameState:=gsGameOver;
  If Game.player1.cardCount>0 Then Game.winner:=1
                              Else Game.winner:=2;
  Exit;
 End;
  { Jouer les cartes du dessus }
 Game.currentCard1:=Game.player1.cards[1];
 Game.currentCard2:=Game.player2.cards[1];
 Game.hasCurrentCards:=True;
 RemoveCard(Game.player1);
 RemoveCard(Game.player2);
  { Comparer les cartes }
 result:=CompareCards(Game.currentCard1, Game.currentCard2);
 If result=0 Then Begin
  { Bataille ! }
  Game.gameState:=gsBattle;
  Game.battleCount:=1;
  Game.battleCards[1].card1:=Game.currentCard1;
  Game.battleCards[1].card2:=Game.currentCard2;
  Game.battleCards[1].valid:=True;
  Game.lastAction:='Bataille ! Egalite avec '+GetCardValueName(Game.currentCard1.value);
  Game.roundWinner:=0;
   { Ajouter 3 cartes face cachÇe et 1 face visible pour chaque joueur }
  totalCards:=2; { Les cartes dÇjÖ jouÇes }
  wonCards[1]:=Game.currentCard1;
  wonCards[2]:=Game.currentCard2;
   { Continuer la bataille tant qu'il y a ÇgalitÇ }
  While(result=0)and(Game.player1.cardCount>=4)and(Game.player2.cardCount>=4)do Begin
    { Prendre 3 cartes face cachÇe }
   For i:=1 to 3 do Begin
    If Game.player1.cardCount>0 Then Begin
     wonCards[totalCards+1]:=Game.player1.cards[1];
     RemoveCard(Game.player1);
     Inc(totalCards);
    End;
    If Game.player2.cardCount>0 Then Begin
     wonCards[totalCards+1]:=Game.player2.cards[1];
     RemoveCard(Game.player2);
     Inc(totalCards);
    End;
   End;
    { Prendre 1 carte face visible }
   If(Game.player1.cardCount>0)and(Game.player2.cardCount>0)Then Begin
    Game.currentCard1:=Game.player1.cards[1];
    Game.currentCard2:=Game.player2.cards[1];
    RemoveCard(Game.player1);
    RemoveCard(Game.player2);
    wonCards[totalCards+1]:=Game.currentCard1;
    wonCards[totalCards+2]:=Game.currentCard2;
    Inc(totalCards,2);
    result:=CompareCards(Game.currentCard1,Game.currentCard2);
    If Game.battleCount<10 Then Begin
     Inc(Game.battleCount);
     Game.battleCards[Game.battleCount].card1:=Game.currentCard1;
     Game.battleCards[Game.battleCount].card2:=Game.currentCard2;
     Game.battleCards[Game.battleCount].valid:=True;
    End;
   End
   Else
    Break;
  End;
 End
  Else
 Begin
  { Pas de bataille }
  Game.gameState:=gsWaitingInput;
  Game.battleCount:=0;
  totalCards:=2;
  wonCards[1]:=Game.currentCard1;
  wonCards[2]:=Game.currentCard2;
 End;
 { DÇterminer le gagnant et donner les cartes }
 If result>0 Then Begin
   { Joueur 1 gagne }
  Game.roundWinner:=1;
  AddCards(Game.player1,wonCards,totalCards);
  Game.lastAction := 'Vous gagnez avec ' +
                     GetCardValueName(Game.currentCard1.value) + ' vs ' +
                     GetCardValueName(Game.currentCard2.value);
 End
  Else
 If result<0 Then Begin
  { Joueur 2 gagne }
  Game.roundWinner:=2;
  AddCards(Game.player2, wonCards, totalCards);
  Game.lastAction := 'Ordinateur gagne avec ' +
                     GetCardValueName(Game.currentCard2.value) + ' vs ' +
                     GetCardValueName(Game.currentCard1.value);
 End;
 Game.gameState:=gsWaitingInput;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   ' ': Begin { Espace - Jouer une carte }
    If Game.gameState=gsWaitingInput Then Begin
     Game.hasCurrentCards:=False;
     Game.roundWinner:=0;
     Game.needRedraw:=True;
     Delay(ANIMATION_DELAY);
     PlayRound;
    End;
   End;
   'n','N':Begin { Nouvelle partie }
    If Game.gameState=gsGameOver Then InitializeGame;
   End;
   #27: Halt; { ESC - Quitter }
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  DrawPlayingField;
  DrawGameStatus;
  Game.needRedraw:=False;
 End;
End;

Procedure InitializeGame;
Var
 i:Integer;
Begin
  { Initialiser les joueurs }
 Game.player1.name:='Joueur 1';
 Game.player1.isHuman:=True;
 Game.player1.cardCount:=0;
 Game.player2.name:='Ordinateur';
 Game.player2.isHuman:=False;
 Game.player2.cardCount:=0;
  { Initialiser le jeu }
 Game.gameState := gsWaitingInput;
 Game.hasCurrentCards := False;
 Game.winner := 0;
 Game.lastAction := 'Nouvelle partie commencee';
 Game.battleCount := 0;
 Game.needRedraw := True;
 Game.roundWinner := 0;
  { Initialiser les cartes de bataille }
 For i:=1 to 10 do Game.battleCards[i].valid := False;
  { CrÇer et mÇlanger le deck }
 InitializeDeck;
 ShuffleDeck;
  { Distribuer les cartes }
 DistributeCards;
End;

Procedure ShowTitle;Begin
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0,0,4);
 OutTextXY(SCREEN_WIDTH div 2-100,80,'BATAILLE');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 150, 'Jeu de cartes classique a deux joueurs');
 OutTextXY(50, 170, 'Chaque joueur joue la carte du dessus de sa pile');
 OutTextXY(50, 190, 'La plus haute carte gagne les deux cartes');
 OutTextXY(50, 210, 'En cas d''egalite: BATAILLE !');
 OutTextXY(50, 230, 'Chaque joueur pose 3 cartes face cachee et 1 face visible');
 OutTextXY(50, 250, 'Le gagnant remporte toutes les cartes');
 OutTextXY(50, 270, 'Premier joueur sans cartes perd la partie');
 SetColor(14);
 OutTextXY(50, 310, 'Commandes:');
 OutTextXY(50, 330, 'ESPACE: Jouer une carte');
 OutTextXY(50, 350, 'N: Nouvelle partie (en fin de jeu)');
 OutTextXY(50, 370, 'ESC: Quitter');
 SetColor(15);
 OutTextXY(50, 420, 'Appuyez sur une touche pour commencer...');
 ReadKey;
End;

Procedure GameLoop;Begin
 While True do Begin
  HandleInput;
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
 Driver:=VGA;
 Mode:=VGAHi;
 {$ELSE}
 Driver:=Detect;
 Mode:=VGAHi;
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