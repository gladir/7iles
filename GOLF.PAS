{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Golf - Jeu de cartes oó l'objectif est d'obtenir le plus bas score
  Chaque joueur a 6 cartes arrangÇes en 2 rangÇes de 3 cartes
}

Program Golf;

Uses {$IFDEF FPC}
      PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  CARD_WIDTH = 50;
  CARD_HEIGHT = 70;
  MAX_PLAYERS = 2;
  CARDS_PER_PLAYER = 6;
  DECK_SIZE = 52;

  { Couleurs des cartes }
  HEARTS = 0;
  DIAMONDS = 1;
  CLUBS = 2;
  SPADES = 3;

  { Valeurs des cartes }
  ACE = 1;
  JACK = 11;
  QUEEN = 12;
  KING = 13;

  { êtats du jeu }
  GAME_SETUP = 0;
  GAME_PLAYING = 1;
  GAME_OVER = 2;

  { Tours }
  TURN_DRAW = 0;
  TURN_DISCARD = 1;

Type
 TCard=Record
  Suit:Integer;      { Couleur: 0=Coeur, 1=Pique 2=carreau, 3=träfle }
  Value:Integer;     { Valeur: 1-13 }
  Visible:Boolean;   { Carte visible ou face cachÇe }
 End;

 TPlayer=Record
  Name: String;
  Cards: Array[0..CARDS_PER_PLAYER-1] of TCard;
  Score: Integer;
  IsHuman: Boolean;
  CardsRevealed: Integer;
 End;

 TGameState = Record
  Players: Array[0..MAX_PLAYERS-1] of TPlayer;
  Deck: Array[0..DECK_SIZE-1] of TCard;
  DiscardPile: Array[0..DECK_SIZE-1] of TCard;
  DeckTop: Integer;
  DiscardTop: Integer;
  CurrentPlayer: Integer;
  GamePhase: Integer;
  TurnPhase: Integer;
  Round: Integer;
  DrawnCard: TCard;
  HasDrawn: Boolean;
  SelectedCard: Integer;
  GameWon: Boolean;
  ShowScores: Boolean;
 End;

Var
 Game:TGameState;
 NeedRedraw:Boolean;

Procedure NewGame;Forward;

{$IFNDEF FPC}
 Function MouseDriverFound:Boolean;
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

 Procedure HideMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0002;
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
  { Pas d'impl√©mentation pour Free Pascal }
 End;

 Procedure HideMouse;
 Begin
  { Pas d'impl√©mentation pour Free Pascal }
 End;
{$ENDIF}

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

Function GetCardScore(Card:TCard):Integer;Begin
 Case Card.Value of
  ACE: GetCardScore := 1;
  2..10: GetCardScore := Card.Value;
  JACK, QUEEN: GetCardScore := 10;
  KING: GetCardScore := 0;
  Else GetCardScore := 0;
 End;
End;

Function GetCardName(Card:TCard):String;Begin
 Case Card.Value of
  ACE: GetCardName := 'A';
  2..10: GetCardName := Chr(Ord('0') + Card.Value);
  JACK: GetCardName := 'J';
  QUEEN: GetCardName := 'Q';
  KING: GetCardName := 'K';
  Else GetCardName := '?';
 End;
End;

Function GetSuitSymbol(Suit:Integer):String;Begin
 Case Suit of
  HEARTS: GetSuitSymbol := #3;
  DIAMONDS: GetSuitSymbol := #4;
  CLUBS: GetSuitSymbol := #5;
  SPADES: GetSuitSymbol := #6;
  Else GetSuitSymbol := '?';
 End;
End;

Function GetSuitColor(Suit:Integer):Integer;Begin
 Case Suit of
  HEARTS, DIAMONDS: GetSuitColor := Red;
  CLUBS, SPADES: GetSuitColor := Black;
  Else GetSuitColor := White;
 End;
End;

Procedure InitDeck;
Var
 I,Suit,Value:Integer;
Begin
 I:=0;
 For Suit := 0 to 3 Do Begin
  For Value := 1 to 13 Do Begin
   Game.Deck[I].Suit := Suit;
   Game.Deck[I].Value := Value;
   Game.Deck[I].Visible := False;
   Inc(I);
  End;
 End;
 Game.DeckTop := DECK_SIZE - 1;
End;

Procedure ShuffleDeck;
Var
 I,J:Integer;
 TempCard:TCard;
Begin
 For I:=0 to DECK_SIZE - 1 Do Begin
  J:=Random(DECK_SIZE);
  TempCard:=Game.Deck[I];
  Game.Deck[I]:=Game.Deck[J];
  Game.Deck[J]:=TempCard;
 End;
End;

Procedure DrawCardFromDeck(Var Card:TCard);Begin
 Card := Game.Deck[Game.DeckTop];
 Dec(Game.DeckTop);
End;

Procedure AddToDiscard(Card:TCard);Begin
 Inc(Game.DiscardTop);
 Game.DiscardPile[Game.DiscardTop] := Card;
End;

Procedure GetTopDiscard(Var Card:TCard);Begin
 If Game.DiscardTop >= 0 Then Card := Game.DiscardPile[Game.DiscardTop]
  Else
 Begin
  Card.Suit := 0;
  Card.Value := 0;
  Card.Visible := False;
 End;
End;

Procedure InitPlayers;
Var
 I,J:Integer;
Begin
  { Joueur humain }
 Game.Players[0].Name := 'Joueur';
 Game.Players[0].IsHuman := True;
 Game.Players[0].Score := 0;
 Game.Players[0].CardsRevealed := 0;
  { Joueur ordinateur }
 Game.Players[1].Name := 'Ordinateur';
 Game.Players[1].IsHuman := False;
 Game.Players[1].Score := 0;
 Game.Players[1].CardsRevealed := 0;
  { Distribuer les cartes }
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  For J := 0 to CARDS_PER_PLAYER - 1 Do Begin
   DrawCardFromDeck(Game.Players[I].Cards[J]);
    { Les 2 premiäres cartes sont rÇvÇlÇes }
   If J < 2 Then Begin
    Game.Players[I].Cards[J].Visible := True;
    Inc(Game.Players[I].CardsRevealed);
   End;
  End;
 End;
  { Premiäre carte sur la pile de dÇfausse }
 DrawCardFromDeck(Game.DrawnCard);
 AddToDiscard(Game.DrawnCard);
 Game.DiscardPile[Game.DiscardTop].Visible := True;
End;

Function CalculatePlayerScore(PlayerIndex:Integer):Integer;
Var
 I,Total:Integer;
Begin
 Total := 0;
 For I := 0 to CARDS_PER_PLAYER - 1 Do Begin
  If Game.Players[PlayerIndex].Cards[I].Visible Then
   Total := Total + GetCardScore(Game.Players[PlayerIndex].Cards[I]);
 End;
 CalculatePlayerScore := Total;
End;

Procedure DrawCard(X,Y:Integer;Card:TCard;Highlighted:Boolean);
Var
 CardName:String;
 SuitSymbol:String;
 SuitColor:Integer;
Begin
  { Fond de la carte }
 If Highlighted Then SetColor(Yellow)
                Else SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
  { Bordure }
 If Highlighted Then SetColor(Yellow)
                Else SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If Card.Visible Then Begin
   { Afficher la carte }
  CardName := GetCardName(Card);
  SuitSymbol := GetSuitSymbol(Card.Suit);
  SuitColor := GetSuitColor(Card.Suit);
   { Valeur en haut √† gauche }
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 5, Y + 5, CardName);
  OutTextXY(X + 5, Y + 15, SuitSymbol);
   { Valeur en bas √† droite (invers√©e) }
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 25, CardName);
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 15, SuitSymbol);
   { Symbole au centre }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X + CARD_WIDTH Div 2 - 8, Y + CARD_HEIGHT Div 2 - 8, SuitSymbol);
 End
  Else
 Begin
   { Dos de carte }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(X + 5, Y + 5, X + CARD_WIDTH - 5, Y + CARD_HEIGHT - 5);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + CARD_WIDTH Div 2 - 10, Y + CARD_HEIGHT Div 2 - 4, 'GOLF');
 End;
End;

Procedure DrawPlayerCards(PlayerIndex:Integer);
Var
 I, X, Y, Row, Col: Integer;
 StartX, StartY: Integer;
 IsCurrentPlayer: Boolean;
Begin
 IsCurrentPlayer:=(PlayerIndex = Game.CurrentPlayer);
 If PlayerIndex = 0 Then Begin
   { Joueur humain - en bas }
  StartX := 50;
  StartY := 320;
 End
  Else
 Begin
   { Ordinateur - en haut }
  StartX := 50;
  StartY := 50;
 End;
  { Nom du joueur }
 If IsCurrentPlayer Then SetColor(Yellow)
                    Else SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(StartX, StartY - 20, Game.Players[PlayerIndex].Name);
  { Pointage }
 SetColor(LightGray);
 OutTextXY(StartX + 200, StartY - 15, 'Pointage: ' + Chr(Ord('0') + CalculatePlayerScore(PlayerIndex)));
  { Cartes arrang√©es en 2 rang√©es de 3 }
 For I := 0 to CARDS_PER_PLAYER - 1 Do Begin
  Row := I Div 3;
  Col := I Mod 3;
  X := StartX + Col * (CARD_WIDTH + 10);
  Y := StartY + Row * (CARD_HEIGHT + 10);
   { Mettre en √©vidence la carte s√©lectionn√©e }
  DrawCard(X, Y, Game.Players[PlayerIndex].Cards[I],
           (PlayerIndex = 0) And (Game.SelectedCard = I) And IsCurrentPlayer);
 End;
End;

Procedure DrawDeckAndDiscard;
Var
 DeckCard,DiscardCard:TCard;
Begin
  { Pile de pioche }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(400, 170, 'Pioche');
 DeckCard.Visible := False;
 DrawCard(400, 190, DeckCard, False);
  { Pile de d√©fausse }
 OutTextXY(480, 170, 'Defausse');
 GetTopDiscard(DiscardCard);
 DrawCard(480, 190, DiscardCard, False);
  { Carte pioch√©e si applicable }
 If Game.HasDrawn Then Begin
  SetColor(Yellow);
  OutTextXY(360, 170, 'Piochee');
  DrawCard(360, 190, Game.DrawnCard, False);
 End;
End;

Procedure DrawGameInfo;Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(400, 300, 'Round: ' + Chr(Ord('0') + Game.Round));
 SetColor(LightGray);
 OutTextXY(400, 320, 'Tour: ' + Game.Players[Game.CurrentPlayer].Name);
  { Instructions }
 SetColor(LightGray);
 OutTextXY(400, 350, 'Instructions:');
 OutTextXY(400, 365, 'Clic - Selectionner carte');
 OutTextXY(400, 380, 'D - Piocher');
 OutTextXY(400, 395, 'P - Prendre defausse');
 OutTextXY(400, 410, 'E - Echanger');
 OutTextXY(400, 425, 'F - Finir tour');
 OutTextXY(400, 440, 'R - Nouvelle partie');
 OutTextXY(400, 455, 'ESC - Quitter');
End;

Procedure DrawGameOver;
Var
 Winner:Integer;
 WinnerName:String;
Begin
 If Game.GameWon Then Begin
   { DÇterminer le gagnant }
  If CalculatePlayerScore(0) < CalculatePlayerScore(1) Then Begin
   Winner := 0;
   WinnerName := 'Joueur';
  End
   Else
  Begin
   Winner := 1;
   WinnerName := 'Ordinateur';
  End;
   { Afficher le rÇsultat }
  SetColor(Green);
  SetFillStyle(SolidFill, Green);
  Bar(200, 200, 440, 280);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(220, 220, 'Partie terminee!');
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(220, 250, 'Gagnant: ' + WinnerName);
  OutTextXY(220, 265, 'Appuyez sur R pour rejouer');
 End;
End;

Procedure DrawBackground;Begin
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(250, 10, 'GOLF');
End;

Procedure DrawScreen;Begin
 DrawBackground;
 DrawPlayerCards(0);  { Joueur humain }
 DrawPlayerCards(1);  { Ordinateur }
 DrawDeckAndDiscard;
 DrawGameInfo;
 DrawGameOver;
End;

Function GetClickedCard(X,Y:Integer):Integer;
Var
 I,CardX,CardY,Row,Col:Integer;
 StartX,StartY:Integer;
Begin
 GetClickedCard := -1;
  { VÇrifier les cartes du joueur humain }
 StartX := 50;
 StartY := 320;
 For I := 0 to CARDS_PER_PLAYER-1 Do Begin
  Row := I Div 3;
  Col := I Mod 3;
  CardX := StartX + Col * (CARD_WIDTH + 10);
  CardY := StartY + Row * (CARD_HEIGHT + 10);
  If (X >= CardX) And (X <= CardX + CARD_WIDTH) And
     (Y >= CardY) And (Y <= CardY + CARD_HEIGHT) Then Begin
    GetClickedCard := I;
    Exit;
  End;
 End;
End;

Procedure HandleMouseClick(X,Y:Integer);
Var
 ClickedCard: Integer;
Begin
 If Game.CurrentPlayer = 0 Then Begin { Joueur humain }
  ClickedCard := GetClickedCard(X, Y);
  If ClickedCard >= 0 Then Begin
   Game.SelectedCard := ClickedCard;
   NeedRedraw := True;
  End;
 End;
End;

Procedure DrawFromDeck;Begin
 If Game.DeckTop >= 0 Then Begin
  DrawCardFromDeck(Game.DrawnCard);
  Game.HasDrawn := True;
  Game.TurnPhase := TURN_DISCARD;
  NeedRedraw := True;
 End;
End;

Procedure DrawFromDiscard;Begin
 If Game.DiscardTop >= 0 Then Begin
  Game.DrawnCard := Game.DiscardPile[Game.DiscardTop];
  Dec(Game.DiscardTop);
  Game.HasDrawn := True;
  Game.TurnPhase := TURN_DISCARD;
  NeedRedraw := True;
 End;
End;

Procedure ExchangeCard;Begin
 If Game.HasDrawn And (Game.SelectedCard >= 0) Then Begin
   { êchanger la carte s√©lectionn√©e avec la carte piochÇe }
  AddToDiscard(Game.Players[Game.CurrentPlayer].Cards[Game.SelectedCard]);
  Game.DiscardPile[Game.DiscardTop].Visible := True;
  Game.Players[Game.CurrentPlayer].Cards[Game.SelectedCard] := Game.DrawnCard;
  Game.Players[Game.CurrentPlayer].Cards[Game.SelectedCard].Visible := True;
  Game.HasDrawn := False;
  Game.SelectedCard := -1;
   { Passer au joueur suivant }
  Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod MAX_PLAYERS;
  Game.TurnPhase := TURN_DRAW;
  NeedRedraw := True;
 End;
End;

Procedure FinishTurn;Begin
 If Game.HasDrawn Then Begin
   { DÇfausser la carte piochÇe }
  AddToDiscard(Game.DrawnCard);
  Game.DiscardPile[Game.DiscardTop].Visible := True;
  Game.HasDrawn := False;
 End;
  { Passer au joueur suivant }
 Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod MAX_PLAYERS;
 Game.TurnPhase := TURN_DRAW;
 Game.SelectedCard := -1;
 NeedRedraw := True;
End;

Procedure ComputerTurn;
Var
 I,BestCard,BestScore,CurrentScore:Integer;
 TopDiscard:TCard;
Begin
 If Game.CurrentPlayer = 1 Then Begin { Ordinateur }
  Case Game.TurnPhase of
   TURN_DRAW: Begin
     { DÇcider de piocher ou prendre la dÇfausse }
    GetTopDiscard(TopDiscard);
    If GetCardScore(TopDiscard) <= 5 Then DrawFromDiscard
                                     Else DrawFromDeck;
    Delay(1000);
   End;
   TURN_DISCARD:Begin
     { Trouver la meilleure carte √† remplacer }
    BestCard := -1;
    BestScore := -1;
    For I := 0 to CARDS_PER_PLAYER - 1 Do Begin
     If Game.Players[1].Cards[I].Visible Then Begin
      CurrentScore := GetCardScore(Game.Players[1].Cards[I]);
      If CurrentScore > BestScore Then Begin
       BestScore := CurrentScore;
       BestCard := I;
      End;
     End;
    End;
     { DÇcider d'√©changer ou de finir le tour }
    If (BestCard >= 0) And (GetCardScore(Game.DrawnCard) < BestScore) Then Begin
     Game.SelectedCard := BestCard;
     ExchangeCard;
    End
     Else
    Begin
     FinishTurn;
    End;
    Delay(1000);
   End;
  End;
 End;
End;

Procedure CheckGameEnd;
Var
 I:Integer;
Begin
  { VÇrifier si toutes les cartes d'un joueur sont rÇvÇlÇes }
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  If Game.Players[I].CardsRevealed >= CARDS_PER_PLAYER Then Begin
   Game.GameWon := True;
   NeedRedraw := True;
   Exit;
  End;
 End;
End;

Procedure HandleInput;
Var
 Key:Char;
 MouseX,MouseY,MouseButton:LongInt;
Begin
  { Clavier }
 If KeyPressed Then Begin
  Key := ReadKey;
  Case Key of
      'd', 'D': Begin
        If (Game.CurrentPlayer = 0) And (Game.TurnPhase = TURN_DRAW) Then
          DrawFromDeck;
      End;
      'p', 'P': Begin
        If (Game.CurrentPlayer = 0) And (Game.TurnPhase = TURN_DRAW) Then
          DrawFromDiscard;
      End;
      'e', 'E': Begin
        If (Game.CurrentPlayer = 0) And (Game.TurnPhase = TURN_DISCARD) Then
          ExchangeCard;
      End;
      'f', 'F': Begin
        If (Game.CurrentPlayer = 0) And (Game.TurnPhase = TURN_DISCARD) Then
          FinishTurn;
      End;
      'r', 'R': Begin
        NewGame;
      End;
      #27: Begin
        CloseGraph;
        Halt;
      End;
    End;
  End;
   { Souris }
  If MouseDriverFound Then Begin
    GetMouseState(MouseX, MouseY, MouseButton);
    If MouseButton = 1 Then Begin
      HandleMouseClick(MouseX, MouseY);
      While MouseButton = 1 Do
        GetMouseState(MouseX, MouseY, MouseButton);
    End;
  End;
End;

Procedure NewGame;Begin
 Game.CurrentPlayer := 0;
 Game.GamePhase := GAME_PLAYING;
 Game.TurnPhase := TURN_DRAW;
 Game.Round := 1;
 Game.HasDrawn := False;
 Game.SelectedCard := -1;
 Game.GameWon := False;
 Game.ShowScores := False;
 Game.DiscardTop := -1;
 InitDeck;
 ShuffleDeck;
 InitPlayers;
 NeedRedraw := True;
End;

BEGIN
 Randomize;
 InitScreen;
 If MouseDriverFound Then ShowMouse;
 NewGame;
  { Boucle principale }
 Repeat
  If NeedRedraw Then Begin
   DrawScreen;
   NeedRedraw := False;
  End;
  HandleInput;
  If Not Game.GameWon Then Begin
   ComputerTurn;
   CheckGameEnd;
  End;
  Delay(50);
 Until False;
END.