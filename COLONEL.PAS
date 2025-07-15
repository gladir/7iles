{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: COLONEL - Jeu de cartes fran‡ais
  RÃ¨gles: Jeu de cartes avec 32 cartes (7 … As), but de faire des plis
}

Program GameColonel;

Uses {$IFDEF FPC}
      PtcCrt,PtcGraph,PtcMouse
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 CARD_WIDTH = 50;
 CARD_HEIGHT = 70;
 MAX_CARDS = 32;
 CARDS_PER_HAND = 8;

 { Couleurs des cartes }
 HEARTS = 0;    { Coeur }
 DIAMONDS = 1;  { Carreau }
 CLUBS = 2;     { TrŠfle }
 SPADES = 3;    { Pique }

 { Valeurs des cartes }
 SEVEN = 7;
 EIGHT = 8;
 NINE = 9;
 TEN = 10;
 JACK = 11;
 QUEEN = 12;
 KING = 13;
 ACE = 14;

 { Ã‰tats du jeu }
 GAME_DEALING = 0;
 GAME_PLAYING = 1;
 GAME_TRICK_END = 2;
 GAME_ROUND_END = 3;
 GAME_OVER = 4;

Type
 TCard = Record
  Suit: Integer;
  Value: Integer;
  Visible: Boolean;
 End;

 TPlayer = Record
  Name: String;
  Cards: Array[1..CARDS_PER_HAND] of TCard;
  CardCount: Integer;
  Tricks: Integer;
  Score: Integer;
 End;

 TGameState = Record
  Players: Array[1..4] of TPlayer;
  Deck: Array[1..MAX_CARDS] of TCard;
  DeckCount: Integer;
  PlayedCards: Array[1..4] of TCard;
  PlayedCount: Integer;
  CurrentPlayer: Integer;
  TrickWinner: Integer;
  TrumpSuit: Integer;
  GamePhase: Integer;
  RoundNumber: Integer;
  SelectedCard: Integer;
  Message: String;
  NeedRedraw: Boolean;
 End;

Var
 Game: TGameState;

{ D‚clarations forward }
Procedure EvaluateTrick; Forward;
Procedure PlayCard(PlayerNum: Integer; CardIndex: Integer); Forward;
Function CanPlayCard(Card: TCard; PlayerNum: Integer): Boolean; Forward;

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs: Registers;
 Begin
  Regs.AX := 0;
  Intr($33, Regs);
  MouseDriverFound := Regs.AX = $FFFF;
 End;

 Procedure ShowMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0001;
  Intr($33, Regs);
 End;

 Procedure GetMouseState(Var X, Y, Button: LongInt);
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0003;
  Intr($33, Regs);
  Button := Regs.BX;
  X := Regs.CX;
  Y := Regs.DX;
 End;
{$ELSE}
 Function MouseDriverFound: Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse;
 Begin
  { Pas d'impl‚mentation pour Free Pascal }
 End;
{$ENDIF}

Procedure HandleMouseClick(MouseX, MouseY: Integer);
Var
 I, CardX, CardY: Integer;
Begin
 { V‚rifier si on clique sur une carte du joueur humain }
 If (Game.GamePhase = GAME_PLAYING) And (Game.CurrentPlayer = 1) Then Begin
  CardY := 370;
  For I := 1 to Game.Players[1].CardCount Do Begin
   CardX := 50 + (I - 1) * 60;
   { V‚rifier si le clic est dans la zone de la carte }
   If (MouseX >= CardX) And (MouseX <= CardX + CARD_WIDTH) And
      (MouseY >= CardY) And (MouseY <= CardY + CARD_HEIGHT) Then Begin
    { Si c'est la carte d‚j… s‚lectionn‚e, la jouer }
    If Game.SelectedCard = I Then Begin
     If CanPlayCard(Game.Players[1].Cards[Game.SelectedCard], 1) Then Begin
      PlayCard(1, Game.SelectedCard);
      If Game.SelectedCard > Game.Players[1].CardCount Then
       Game.SelectedCard := Game.Players[1].CardCount;
      Game.NeedRedraw := True;
     End Else Begin
      Game.Message := 'Vous devez jouer la couleur demand‚e!';
      Game.NeedRedraw := True;
     End;
    End Else Begin
     { Sinon, s‚lectionner cette carte }
     Game.SelectedCard := I;
     Game.NeedRedraw := True;
    End;
    Exit;
   End;
  End;
 End;
End;

Procedure InitScreen;
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
 If ErrCode <> grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt(1);
 End;
End;

Function GetCardName(Card:TCard):String;
Var
 ValueStr, SuitStr: String;
Begin
 Case Card.Value of
  SEVEN: ValueStr := '7';
  EIGHT: ValueStr := '8';
  NINE: ValueStr := '9';
  TEN: ValueStr := '10';
  JACK: ValueStr := 'V';
  QUEEN: ValueStr := 'D';
  KING: ValueStr := 'R';
  ACE: ValueStr := 'A';
 End;
 Case Card.Suit of
  HEARTS: SuitStr := 'C';
  DIAMONDS: SuitStr := 'K';
  CLUBS: SuitStr := 'T';
  SPADES: SuitStr := 'P';
 End;
 GetCardName := ValueStr + SuitStr;
End;

Function GetSuitColor(Suit:Integer):Integer;Begin
 Case Suit of
  HEARTS, DIAMONDS: GetSuitColor := Red;
  CLUBS, SPADES: GetSuitColor := Black;
 End;
End;

Procedure DrawCard(X,Y:Integer;Card:TCard;FaceUp:Boolean);
Var
 CardName:String;
 SuitColor:Integer;
Begin
 { Fond de la carte }
 If FaceUp Then Begin
  SetColor(White);
  SetFillStyle(SolidFill, White);
 End
  Else
 Begin
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
 End;
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
  { Bordure }
 SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If FaceUp Then Begin
   { Afficher la valeur et la couleur }
  CardName:=GetCardName(Card);
  SuitColor:=GetSuitColor(Card.Suit);
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 5, Y + 5, CardName);
   { Dessiner le symbole de la couleur au centre }
  SetColor(SuitColor);
  Case Card.Suit of
   HEARTS: Begin
    FillEllipse(X + 20, Y + 30, 5, 5);
    FillEllipse(X + 30, Y + 30, 5, 5);
    Line(X + 15, Y + 33, X + 25, Y + 43);
    Line(X + 25, Y + 43, X + 35, Y + 33);
   End;
   DIAMONDS: Begin
    Line(X + 25, Y + 25, X + 15, Y + 35);
    Line(X + 15, Y + 35, X + 25, Y + 45);
    Line(X + 25, Y + 45, X + 35, Y + 35);
    Line(X + 35, Y + 35, X + 25, Y + 25);
   End;
   CLUBS: Begin
    FillEllipse(X + 25, Y + 28, 4, 4);
    FillEllipse(X + 20, Y + 35, 4, 4);
    FillEllipse(X + 30, Y + 35, 4, 4);
    Line(X + 25, Y + 38, X + 25, Y + 45);
    Line(X + 22, Y + 45, X + 28, Y + 45);
   End;
   SPADES: Begin
    Line(X + 25, Y + 25, X + 15, Y + 40);
    Line(X + 15, Y + 40, X + 20, Y + 38);
    Line(X + 20, Y + 38, X + 25, Y + 42);
    Line(X + 25, Y + 42, X + 30, Y + 38);
    Line(X + 30, Y + 38, X + 35, Y + 40);
    Line(X + 35, Y + 40, X + 25, Y + 25);
    Line(X + 25, Y + 40, X + 25, Y + 45);
    Line(X + 22, Y + 45, X + 28, Y + 45);
   End;
  End;
 End Else Begin
  { Dos de carte }
  SetColor(Yellow);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 15, Y + 30, 'COL');
 End;
End;

Procedure DrawPlayerHand(PlayerNum:Integer);
Var
 I, X, Y: Integer;
 Player: TPlayer;
Begin
 Player := Game.Players[PlayerNum];
 Case PlayerNum of
  1: Begin { Joueur humain - bas }
   Y := 370;
   For I := 1 to Player.CardCount Do Begin
    X := 50 + (I - 1) * 60;
    If (PlayerNum = 1) And (I = Game.SelectedCard) Then Begin
     SetColor(Yellow);
     Rectangle(X - 2, Y - 2, X + CARD_WIDTH + 2, Y + CARD_HEIGHT + 2);
    End;
    DrawCard(X, Y, Player.Cards[I], True);
   End;
  End;
  2: Begin { Joueur gauche }
   X := 20;
   For I := 1 to Player.CardCount Do Begin
    Y := 50 + (I - 1) * 25;
    DrawCard(X, Y, Player.Cards[I], False);
   End;
  End;
  3: Begin { Joueur haut }
   Y := 40;
   For I := 1 to Player.CardCount Do Begin
    X := 50 + (I - 1) * 60;
    DrawCard(X, Y, Player.Cards[I], False);
   End;
  End;
  4: Begin { Joueur droite }
   X := 570;
   For I := 1 to Player.CardCount Do Begin
    Y := 50 + (I - 1) * 25;
    DrawCard(X, Y, Player.Cards[I], False);
   End;
  End;
 End;
End;

Procedure DrawPlayedCards;
Var
 I,X,Y:Integer;
Begin
 { Centre de la table }
 X := 250;
 Y := 150;
 For I := 1 to Game.PlayedCount Do Begin
  Case I of
   1: DrawCard(X, Y + 50, Game.PlayedCards[I], True);  { Bas }
   2: DrawCard(X - 70, Y, Game.PlayedCards[I], True);  { Gauche }
   3: DrawCard(X, Y - 50, Game.PlayedCards[I], True);  { Haut }
   4: DrawCard(X + 70, Y, Game.PlayedCards[I], True);  { Droite }
  End;
 End;
End;

Procedure DrawGameInfo;
Var
 I:Integer;
 ScoreText,TrickText:String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(250, 5, 'COLONEL');
 SetTextStyle(DefaultFont, HorizDir, 1);
  { Afficher les scores }
 For I := 1 to 4 Do Begin
  Str(Game.Players[I].Score, ScoreText);
  Str(Game.Players[I].Tricks, TrickText);
  Case I of
   1: OutTextXY(50, 450, Game.Players[I].Name + ': ' + ScoreText + ' (' + TrickText + ' plis)');
   2: OutTextXY(20, 250, Game.Players[I].Name + ': ' + ScoreText);
   3: OutTextXY(250, 25, Game.Players[I].Name + ': ' + ScoreText);
   4: OutTextXY(520, 250, Game.Players[I].Name + ': ' + ScoreText);
  End;
 End;
 { Afficher l'atout }
 If Game.TrumpSuit >= 0 Then Begin
  SetColor(Yellow);
  OutTextXY(350, 200,'Atout: ');
  SetColor(GetSuitColor(Game.TrumpSuit));
  Case Game.TrumpSuit of
   HEARTS: OutTextXY(400, 200, 'COEUR');
   DIAMONDS: OutTextXY(400, 200, 'CARREAU');
   CLUBS: OutTextXY(400, 200, 'TREFLE');
   SPADES: OutTextXY(400, 200, 'PIQUE');
  End;
 End;
  { Afficher le joueur courant }
 If Game.GamePhase = GAME_PLAYING Then Begin
  SetColor(LightGray);
  OutTextXY(50, 460, 'Tour de: ' + Game.Players[Game.CurrentPlayer].Name);
 End;
End;

Procedure DrawMessage;Begin
 SetColor(Yellow);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(200, 460, Game.Message);
End;

Procedure DrawBackground;Begin
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Table de jeu }
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 FillEllipse(320, 240, 200, 150);
  { Bordure de la table }
 SetColor(LightGreen);
 Ellipse(320, 240, 0, 360, 200, 150);
End;

Procedure DrawScreen;
Var
 I: Integer;
Begin
 DrawBackground;
 For I := 1 to 4 Do Begin
  DrawPlayerHand(I);
 End;
 DrawPlayedCards;
 DrawGameInfo;
 DrawMessage;
End;

Procedure InitDeck;
Var
 I, Suit, Value: Integer;
Begin
 I := 1;
 For Suit := HEARTS to SPADES Do Begin
  For Value := SEVEN to ACE Do Begin
   Game.Deck[I].Suit := Suit;
   Game.Deck[I].Value := Value;
   Game.Deck[I].Visible := False;
   Inc(I);
  End;
 End;
 Game.DeckCount := MAX_CARDS;
End;

Procedure ShuffleDeck;
Var
 I, J: Integer;
 TempCard: TCard;
Begin
 For I := 1 to Game.DeckCount Do Begin
  J := Random(Game.DeckCount) + 1;
  TempCard := Game.Deck[I];
  Game.Deck[I] := Game.Deck[J];
  Game.Deck[J] := TempCard;
 End;
End;

Procedure DealCards;
Var
 I, J: Integer;
Begin
 For I := 1 to 4 Do Begin
  Game.Players[I].CardCount := 0;
  Game.Players[I].Tricks := 0;
 End;
  { Distribuer 8 cartes Ã  chaque joueur }
 For I := 1 to CARDS_PER_HAND Do Begin
  For J := 1 to 4 Do Begin
   Inc(Game.Players[J].CardCount);
   Game.Players[J].Cards[Game.Players[J].CardCount] := Game.Deck[Game.DeckCount];
   Dec(Game.DeckCount);
  End;
 End;
  { D‚finir l'atout (derniÃ¨re carte distribu‚e) }
 Game.TrumpSuit := Game.Players[4].Cards[Game.Players[4].CardCount].Suit;
End;

Function GetCardValue(Card:TCard;TrumpSuit:Integer):Integer;Begin
 { Valeur pour comparer les cartes }
 If Card.Suit = TrumpSuit Then GetCardValue := Card.Value + 100  { Atout vaut plus }
                          Else GetCardValue := Card.Value;
End;

Function CanPlayCard(Card:TCard;PlayerNum:Integer):Boolean;
Var
 I: Integer;
 LeadSuit: Integer;
 HasLeadSuit: Boolean;
Begin
 If Game.PlayedCount=0 Then Begin
  CanPlayCard := True;
  Exit;
 End;
 LeadSuit := Game.PlayedCards[1].Suit;
 HasLeadSuit := False;
  { V‚rifier si le joueur a la couleur demand‚e }
 For I := 1 to Game.Players[PlayerNum].CardCount Do Begin
  If Game.Players[PlayerNum].Cards[I].Suit = LeadSuit Then Begin
   HasLeadSuit := True;
   Break;
  End;
 End;
  { Si on a la couleur, on doit la jouer }
 If HasLeadSuit Then CanPlayCard:=(Card.Suit = LeadSuit)
                Else CanPlayCard:=True;
End;

Procedure PlayCard(PlayerNum:Integer;CardIndex:Integer);
Var
 I:Integer;
Begin
 Inc(Game.PlayedCount);
 Game.PlayedCards[Game.PlayedCount] := Game.Players[PlayerNum].Cards[CardIndex];
  { Retirer la carte de la main }
 For I := CardIndex to Game.Players[PlayerNum].CardCount - 1 Do Begin
  Game.Players[PlayerNum].Cards[I] := Game.Players[PlayerNum].Cards[I + 1];
 End;
 Dec(Game.Players[PlayerNum].CardCount);
  { Passer au joueur suivant }
 Game.CurrentPlayer := (Game.CurrentPlayer Mod 4) + 1;
  { Si tout le monde a jouÃ©, Ã©valuer le pli }
 If Game.PlayedCount = 4 Then Begin
  EvaluateTrick;
 End;
End;

Procedure EvaluateTrick;
Var
 I,Winner,BestValue:Integer;
Begin
 Winner := 1;
 BestValue := GetCardValue(Game.PlayedCards[1], Game.TrumpSuit);
 For I := 2 to 4 Do Begin
  If GetCardValue(Game.PlayedCards[I], Game.TrumpSuit) > BestValue Then Begin
   Winner := I;
   BestValue := GetCardValue(Game.PlayedCards[I], Game.TrumpSuit);
  End;
 End;
 Game.TrickWinner := Winner;
 Inc(Game.Players[Winner].Tricks);
 Inc(Game.Players[Winner].Score, 10);
 Game.PlayedCount := 0;
 Game.CurrentPlayer := Winner;
 Game.GamePhase := GAME_TRICK_END;
 Game.Message := Game.Players[Winner].Name + ' remporte le pli!';
End;

Procedure AIPlayCard(PlayerNum: Integer);
Var
 I, BestCard: Integer;
 BestValue: Integer;
Begin
 BestCard := 1;
 BestValue := -1;
  { IA simple: jouer la premiŠre carte valide }
 For I := 1 to Game.Players[PlayerNum].CardCount Do Begin
  If CanPlayCard(Game.Players[PlayerNum].Cards[I], PlayerNum) Then Begin
   BestCard := I;
   Break;
  End;
 End;
 PlayCard(PlayerNum, BestCard);
End;

Procedure InitGame;
Var
 I:Integer;
Begin
 { Initialiser les joueurs }
 Game.Players[1].Name := 'Joueur';
 Game.Players[2].Name := 'Ordinateur 1';
 Game.Players[3].Name := 'Ordinateur 2';
 Game.Players[4].Name := 'Ordinateur 3';
 For I := 1 to 4 Do Begin
  Game.Players[I].Score := 0;
  Game.Players[I].Tricks := 0;
 End;
 Game.PlayedCount := 0;
 Game.CurrentPlayer := 1;
 Game.TrickWinner := 0;
 Game.GamePhase := GAME_DEALING;
 Game.RoundNumber := 1;
 Game.SelectedCard := 1;
 Game.Message := 'Nouvelle partie - Distribution des cartes...';
 Game.NeedRedraw := True;
 InitDeck;
 ShuffleDeck;
 DealCards;
 Game.GamePhase := GAME_PLAYING;
 Game.Message := 'S‚lectionnez une carte … jouer';
End;

Procedure HandleInput;
Var
 Key:Char;
Begin
 If KeyPressed Then Begin
  Key := ReadKey;
  Case Key of
   #0: Begin { Touches ‚tendues }
    Key := ReadKey;
    Case Key of
     #75: Begin { FlŠche gauche }
      If Game.SelectedCard > 1 Then Begin
       Dec(Game.SelectedCard);
       Game.NeedRedraw := True;
      End;
     End;
     #77: Begin { FlŠche droite }
      If Game.SelectedCard < Game.Players[1].CardCount Then Begin
       Inc(Game.SelectedCard);
       Game.NeedRedraw := True;
      End;
     End;
    End;
   End;
   #13: Begin { Entr‚e - Jouer la carte s‚lectionn‚e }
    If (Game.GamePhase = GAME_PLAYING) And (Game.CurrentPlayer = 1) Then Begin
     If CanPlayCard(Game.Players[1].Cards[Game.SelectedCard], 1) Then Begin
      PlayCard(1, Game.SelectedCard);
      If Game.SelectedCard > Game.Players[1].CardCount Then
       Game.SelectedCard := Game.Players[1].CardCount;
      Game.NeedRedraw := True;
     End Else Begin
      Game.Message := 'Vous devez jouer la couleur demand‚e!';
      Game.NeedRedraw := True;
     End;
    End;
   End;
   ' ': Begin { Espace - Continuer aprŠs un pli }
    If Game.GamePhase = GAME_TRICK_END Then Begin
     If Game.Players[1].CardCount = 0 Then Begin
      Game.GamePhase := GAME_ROUND_END;
      Game.Message := 'Manche termin‚e! Appuyez sur N pour une nouvelle manche';
     End Else Begin
      Game.GamePhase := GAME_PLAYING;
      Game.Message := 'S‚lectionnez une carte … jouer';
     End;
     Game.NeedRedraw := True;
    End;
   End;
   'n', 'N': Begin { Nouvelle manche }
    If Game.GamePhase = GAME_ROUND_END Then Begin
     Inc(Game.RoundNumber);
     InitDeck;
     ShuffleDeck;
     DealCards;
     Game.GamePhase := GAME_PLAYING;
     Game.CurrentPlayer := 1;
     Game.SelectedCard := 1;
     Game.Message := 'Nouvelle manche - S‚lectionnez une carte';
     Game.NeedRedraw := True;
    End;
   End;
   #27: Begin { Escape - Quitter }
    CloseGraph;
    Halt;
   End;
  End;
 End;
End;

Procedure HandleMouseInput;
Var
 MouseX, MouseY, Button: LongInt;
Begin
 { GÃ©rer les clics de souris }
 GetMouseState(MouseX, MouseY, Button);
 If Button = 1 Then Begin { Bouton gauche }
  HandleMouseClick(MouseX, MouseY);
  Repeat
   GetMouseState(MouseX, MouseY, Button);
   Delay(10);
  Until Button = 0;
 End;
End;

BEGIN
 Randomize;
 InitScreen;
 If MouseDriverFound Then ShowMouse;
 InitGame;
 { Boucle principale }
 Repeat
  If Game.NeedRedraw Then Begin
   DrawScreen;
   Game.NeedRedraw := False;
  End;
  HandleInput;
  HandleMouseInput;
   { IA joue }
  If (Game.GamePhase = GAME_PLAYING) And (Game.CurrentPlayer > 1) Then Begin
   Delay(1000);
   AIPlayCard(Game.CurrentPlayer);
   Game.NeedRedraw := True;
  End;
  Delay(50);
 Until False;
END.