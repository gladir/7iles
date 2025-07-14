{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Bourr‚ - Jeu de cartes traditionnel louisianais
  Jeu de lev‚es avec mise et bourrage pour 3-6 joueurs
}

Program Bourre;

Uses {$IFDEF FPC}
      PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 CARD_WIDTH = 50;
 CARD_HEIGHT = 70;
 DECK_SIZE = 52;
 MAX_PLAYERS = 5;
 MIN_PLAYERS = 3;
 CARDS_PER_HAND = 5;

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

  { Ã‰tats du jeu }
 GAME_DEALING = 0;
 GAME_BIDDING = 1;
 GAME_PLAYING = 2;
 GAME_TRICK_END = 3;
 GAME_HAND_END = 4;
 GAME_OVER = 5;

  { Actions de mise }
 BID_FOLD = 0;
 BID_PLAY = 1;
 BID_BOURRE = 2;

  { Ordre des cartes au Bourr‚ (Ace haut) }
 BOURRE_VALUES: Array[1..13] of Integer = (14, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13);

Type
  TCard = Record
   Suit: Integer;
   Value: Integer;
   Visible: Boolean;
  End;

  TPlayer = Record
   Name: String;
   Cards: Array[0..CARDS_PER_HAND-1] of TCard;
   CardCount: Integer;
   IsHuman: Boolean;
   Chips: Integer;
   Bid: Integer;
   TricksWon: Integer;
   IsActive: Boolean;
   IsBourre: Boolean;
  End;

  TTrick = Record
   Cards: Array[0..MAX_PLAYERS-1] of TCard;
   Players: Array[0..MAX_PLAYERS-1] of Integer;
   Count: Integer;
   Winner: Integer;
   LeadSuit: Integer;
  End;

  TGameState = Record
   Players: Array[0..MAX_PLAYERS-1] of TPlayer;
   Deck: Array[0..DECK_SIZE-1] of TCard;
   CurrentTrick: TTrick;
   TrumpSuit: Integer;
   TrumpCard: TCard;
   CurrentPlayer: Integer;
   Dealer: Integer;
   TrickNumber: Integer;
   GamePhase: Integer;
   SelectedCard: Integer;
   Pot: Integer;
   PlayerCount: Integer;
   BiddingPlayer: Integer;
   AnimationDelay: Integer;
   ShowResults: Boolean;
   ErrorCard: Integer;
   ErrorTimer: Integer;
  End;

Var
 Game: TGameState;
 NeedRedraw: Boolean;

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

 Procedure ShowMouse;Begin
  { Pas d'impl‚mentation pour Free Pascal }
 End;

 Procedure HideMouse;Begin
  { Pas d'impl‚mentation pour Free Pascal }
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

Function GetSuitName(Suit:Integer):String;Begin
 Case Suit of
  HEARTS: GetSuitName := 'Coeurs';
  DIAMONDS: GetSuitName := 'Carreaux';
  CLUBS: GetSuitName := 'Trefles';
  SPADES: GetSuitName := 'Piques';
  Else GetSuitName := 'Inconnu';
 End;
End;

Function GetBourreValue(Card:TCard):Integer;Begin
 GetBourreValue := BOURRE_VALUES[Card.Value];
End;

Function GetBidName(Bid:Integer):String;Begin
 Case Bid of
  BID_FOLD: GetBidName := 'Passe';
  BID_PLAY: GetBidName := 'Joue';
  BID_BOURRE: GetBidName := 'Bourre';
  Else GetBidName := 'Inconnu';
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
   Game.Deck[I].Visible := True;
   Inc(I);
  End;
 End;
End;

Procedure ShuffleDeck;
Var
 I,J:Integer;
 TempCard:TCard;
Begin
 For I:=0 to DECK_SIZE-1 Do Begin
  J := Random(DECK_SIZE);
  TempCard := Game.Deck[I];
  Game.Deck[I] := Game.Deck[J];
  Game.Deck[J] := TempCard;
 End;
End;

Procedure InitPlayers;
Var
 I: Integer;
Begin
 Game.PlayerCount := 4; { 4 joueurs par d‚faut }
  { Joueur humain }
 Game.Players[0].Name := 'Joueur';
 Game.Players[0].IsHuman := True;
 Game.Players[0].Chips := 100;
 Game.Players[0].IsActive := True;
  { Joueurs ordinateurs }
 Game.Players[1].Name := 'Nord';
 Game.Players[1].IsHuman := False;
 Game.Players[1].Chips := 100;
 Game.Players[1].IsActive := True;
 Game.Players[2].Name := 'Est';
 Game.Players[2].IsHuman := False;
 Game.Players[2].Chips := 100;
 Game.Players[2].IsActive := True;
 Game.Players[3].Name := 'Ouest';
 Game.Players[3].IsHuman := False;
 Game.Players[3].Chips := 100;
 Game.Players[3].IsActive := True;
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  Game.Players[I].CardCount := 0;
  Game.Players[I].TricksWon := 0;
  Game.Players[I].Bid := BID_FOLD;
  Game.Players[I].IsBourre := False;
 End;
End;

Procedure DealCards;
Var
 I, J, CardIndex: Integer;
Begin
 CardIndex := 0;
  { Distribuer 5 cartes … chaque joueur }
 For I := 0 to CARDS_PER_HAND - 1 Do Begin
  For J := 0 to Game.PlayerCount - 1 Do Begin
   If Game.Players[J].IsActive Then Begin
    Game.Players[J].Cards[I] := Game.Deck[CardIndex];
    If J = 0 Then Game.Players[J].Cards[I].Visible := True
             Else Game.Players[J].Cards[I].Visible := False;
    Inc(CardIndex);
   End;
  End;
 End;
  { D‚finir l'atout avec la carte suivante }
 Game.TrumpCard := Game.Deck[CardIndex];
 Game.TrumpSuit := Game.TrumpCard.Suit;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Game.Players[I].IsActive Then Begin
   Game.Players[I].CardCount := CARDS_PER_HAND;
  End;
 End;
End;

Procedure SortPlayerCards(PlayerIndex: Integer);
Var
 I,J:Integer;
 TempCard:TCard;
Begin
 { Tri par couleur puis par valeur Bourr‚ }
 For I := 0 to Game.Players[PlayerIndex].CardCount - 2 Do Begin
  For J := I + 1 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
   If (Game.Players[PlayerIndex].Cards[I].Suit > Game.Players[PlayerIndex].Cards[J].Suit) Or
      ((Game.Players[PlayerIndex].Cards[I].Suit = Game.Players[PlayerIndex].Cards[J].Suit) And
       (GetBourreValue(Game.Players[PlayerIndex].Cards[I]) > GetBourreValue(Game.Players[PlayerIndex].Cards[J]))) Then Begin
    TempCard := Game.Players[PlayerIndex].Cards[I];
    Game.Players[PlayerIndex].Cards[I] := Game.Players[PlayerIndex].Cards[J];
    Game.Players[PlayerIndex].Cards[J] := TempCard;
   End;
  End;
 End;
End;

Procedure InitHand;Begin
 Game.GamePhase := GAME_DEALING;
 Game.Dealer := (Game.Dealer + 1) Mod Game.PlayerCount;
 Game.BiddingPlayer := (Game.Dealer + 1) Mod Game.PlayerCount;
 Game.CurrentPlayer := Game.BiddingPlayer;
 Game.TrickNumber := 1;
 Game.SelectedCard := -1;
 Game.AnimationDelay := 0;
 Game.ShowResults := False;
 Game.ErrorCard := -1;
 Game.ErrorTimer := 0;
 Game.Pot := 0;
 { R‚initialiser les donn‚es des joueurs }
 Game.Players[0].TricksWon := 0;
 Game.Players[0].Bid := BID_FOLD;
 Game.Players[0].IsBourre := False;
 Game.Players[1].TricksWon := 0;
 Game.Players[1].Bid := BID_FOLD;
 Game.Players[1].IsBourre := False;
 Game.Players[2].TricksWon := 0;
 Game.Players[2].Bid := BID_FOLD;
 Game.Players[2].IsBourre := False;
 Game.Players[3].TricksWon := 0;
 Game.Players[3].Bid := BID_FOLD;
 Game.Players[3].IsBourre := False;
  { Initialiser la lev‚e courante }
 Game.CurrentTrick.Count := 0;
 Game.CurrentTrick.Winner := -1;
 Game.CurrentTrick.LeadSuit := -1;
 InitDeck;
 ShuffleDeck;
 DealCards;
 SortPlayerCards(0);
 Game.GamePhase := GAME_BIDDING;
 NeedRedraw := True;
End;

Procedure InitGame;Begin
 InitPlayers;
 Game.Dealer:=0;
 InitHand;
End;

Procedure DrawCard(X, Y: Integer; Card: TCard; Highlighted: Boolean;ErrorHighlight:Boolean);
Var
 CardName: String;
 SuitSymbol: String;
 SuitColor: Integer;
Begin
  { Fond de la carte }
 If ErrorHighlight Then SetColor(LightRed) Else
 If Highlighted Then SetColor(Yellow)
                Else SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
  { Bordure }
 If ErrorHighlight Then SetColor(Red)
 Else If Highlighted Then SetColor(Yellow)
                     Else SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If Card.Visible Then Begin
   { Afficher la carte }
  CardName := GetCardName(Card);
  SuitSymbol := GetSuitSymbol(Card.Suit);
  SuitColor := GetSuitColor(Card.Suit);
   { Valeur en haut Ã  gauche }
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 3, Y + 3, CardName);
  OutTextXY(X + 3, Y + 13, SuitSymbol);
   { Valeur en bas Ã  droite (inversÃ©e) }
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 25, CardName);
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 15, SuitSymbol);
   { Symbole au centre }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X + CARD_WIDTH Div 2 - 8, Y + CARD_HEIGHT Div 2 - 8, SuitSymbol);
   { Marquer l'atout }
  If Card.Suit = Game.TrumpSuit Then Begin
   SetColor(Magenta);
   SetTextStyle(DefaultFont, HorizDir, 1);
   OutTextXY(X + 2, Y + CARD_HEIGHT - 12, 'T');
  End;
   { Remettre la taille de police normale }
  SetTextStyle(DefaultFont, HorizDir, 1);
 End
 Else Begin
  { Dos de carte }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(X + 5, Y + 5, X + CARD_WIDTH - 5, Y + CARD_HEIGHT - 5);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + CARD_WIDTH Div 2 - 25, Y + CARD_HEIGHT Div 2 - 4, 'BOURRE');
 End;
End;

Procedure DrawPlayerCards(PlayerIndex: Integer);
Var
 I, X, Y, StartX, StartY: Integer;
 IsHighlighted, IsError: Boolean;
Begin
 If Not Game.Players[PlayerIndex].IsActive Then Exit;
 Case PlayerIndex of
  0: Begin { Joueur humain - en bas }
   StartX := 50;
   StartY := 350;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    X := StartX + I * (CARD_WIDTH + 5);
    IsHighlighted := (Game.SelectedCard = I) And (Game.CurrentPlayer = 0);
    IsError := (Game.ErrorCard = I) And (Game.ErrorTimer > 0);
    DrawCard(X, StartY, Game.Players[PlayerIndex].Cards[I], IsHighlighted, IsError);
   End;
  End;
  1: Begin { Nord - en haut }
   StartX := 50;
   StartY := 20;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    X := StartX + I * (CARD_WIDTH Div 2 + 5);
    DrawCard(X, StartY, Game.Players[PlayerIndex].Cards[I], False, False);
   End;
  End;
  2: Begin { Est - … droite }
   StartX := 550;
   StartY := 100;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    Y := StartY + I * (CARD_HEIGHT Div 3 + 2);
    DrawCard(StartX, Y, Game.Players[PlayerIndex].Cards[I], False, False);
   End;
  End;
  3: Begin { Ouest - … gauche }
   StartX := 10;
   StartY := 100;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    Y := StartY + I * (CARD_HEIGHT Div 3 + 2);
    DrawCard(StartX, Y, Game.Players[PlayerIndex].Cards[I], False, False);
   End;
  End;
 End;
End;

Procedure DrawCurrentTrick;
Var
 I, X, Y: Integer;
Begin
 { Positions pour les cartes de la lev‚e courante }
 For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
  Case Game.CurrentTrick.Players[I] of
   0: Begin X := 250; Y := 280; End; { Joueur humain }
   1: Begin X := 250; Y := 150; End; { Nord }
   2: Begin X := 320; Y := 215; End; { Est }
   3: Begin X := 180; Y := 215; End; { Ouest }
  End;
  DrawCard(X, Y, Game.CurrentTrick.Cards[I], False, False);
 End;
End;

Procedure DrawTrumpCard;Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(450, 370, 'Atout: ' + GetSuitName(Game.TrumpSuit));
 DrawCard(450, 390, Game.TrumpCard, False, False);
End;

Procedure DrawPlayerInfo;
Var
 I:Integer;
 PlayerName:String;
 ChipsText:String;
 BidText:String;
 TricksText:String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Not Game.Players[I].IsActive Then Continue;
  PlayerName := Game.Players[I].Name;
  Str(Game.Players[I].Chips, ChipsText);
  BidText := GetBidName(Game.Players[I].Bid);
  Str(Game.Players[I].TricksWon, TricksText);
  Case I of
   0: Begin { Joueur humain }
    OutTextXY(60, 320, PlayerName + ' - Jetons: ' + ChipsText);
    OutTextXY(60, 330, 'Mise: ' + BidText + ' - Levees: ' + TricksText);
    If Game.CurrentPlayer = 0 Then Begin
     SetColor(Yellow);
     OutTextXY(40, 320, '>');
     SetColor(White);
    End;
   End;
   1: Begin { Nord }
    OutTextXY(300, 5, PlayerName + ' - Jetons: ' + ChipsText);
    OutTextXY(300, 15, 'Mise: ' + BidText + ' - Levees: ' + TricksText);
    If Game.CurrentPlayer = 1 Then Begin
     SetColor(Yellow);
     OutTextXY(280, 5, '>');
     SetColor(White);
    End;
   End;
   2: Begin { Est }
    OutTextXY(470, 60, PlayerName);
    OutTextXY(470, 70, 'Jetons: ' + ChipsText);
    OutTextXY(470, 80, 'Mise: ' + BidText);
    OutTextXY(470, 90, 'Levees: ' + TricksText);
    If Game.CurrentPlayer = 2 Then Begin
     SetColor(Yellow);
     OutTextXY(460, 60, '>');
     SetColor(White);
    End;
   End;
   3: Begin { Ouest }
    OutTextXY(70, 100, PlayerName);
    OutTextXY(70, 110, 'Jetons: ' + ChipsText);
    OutTextXY(70, 130, 'Mise: ' + BidText);
    OutTextXY(70, 150, 'Levees: ' + TricksText);
    If Game.CurrentPlayer = 3 Then Begin
     SetColor(Yellow);
     OutTextXY(60, 100, '>');
     SetColor(White);
    End;
   End;
  End;
 End;
End;

Procedure DrawGameInfo;
Var
 PotText: String;
 TrickText: String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
  { Pot }
 Str(Game.Pot, PotText);
 OutTextXY(400, 200, 'Pot: ' + PotText + ' jetons');
 { Num‚ro de lev‚e }
 Str(Game.TrickNumber, TrickText);
 OutTextXY(400, 220, 'Levee: ' + TrickText + '/5');
 { Phase de jeu }
 Case Game.GamePhase of
  GAME_BIDDING: OutTextXY(400, 240, 'Phase: Encheres');
  GAME_PLAYING: OutTextXY(400, 240, 'Phase: Jeu');
  GAME_HAND_END: OutTextXY(400, 240, 'Phase: Fin de donne');
 End;
  { Instructions }
 SetColor(LightGray);
 OutTextXY(400, 270, 'Instructions:');
 Case Game.GamePhase of
  GAME_BIDDING: Begin
   OutTextXY(400, 285, 'F - Passer');
   OutTextXY(400, 300, 'J - Jouer');
   OutTextXY(400, 315, 'B - Bourrer');
  End;
  GAME_PLAYING: Begin
   OutTextXY(400, 285, 'Clic - Jouer carte');
  End;
 End;
 OutTextXY(400, 330, 'N - Nouvelle donne');
 OutTextXY(400, 345, 'ESC - Quitter');
End;

Procedure DrawBackground;Begin
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(500, 5, 'BOURRE');
End;

Procedure DrawScreen;
Var
 I: Integer;
Begin
 DrawBackground;
  { Dessiner les cartes de tous les joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  DrawPlayerCards(I);
 End;
 If Game.GamePhase = GAME_PLAYING Then Begin
  DrawCurrentTrick;
 End;
 DrawTrumpCard;
 DrawPlayerInfo;
 DrawGameInfo;
 If Game.ShowResults Then Begin
   { Afficher les rÃ©sultats de fin de donne }
  SetColor(Green);
  SetFillStyle(SolidFill, Green);
  Bar(150, 150, 490, 330);
  SetColor(White);
  Rectangle(150, 150, 490, 330);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(180, 170, 'Fin de donne');
  SetTextStyle(DefaultFont, HorizDir, 1);
  For I := 0 to Game.PlayerCount - 1 Do Begin
   If Game.Players[I].IsActive Then Begin
    OutTextXY(160, 200 + I * 20, Game.Players[I].Name + ': ' +
              GetBidName(Game.Players[I].Bid));
    If Game.Players[I].IsBourre Then Begin
     SetColor(Red);
     OutTextXY(300, 200 + I * 20, 'BOURRE!');
     SetColor(White);
    End;
   End;
  End;
  OutTextXY(160, 300, 'Appuyez sur une touche...');
 End;
End;

Function CountActivePlayers:Integer;
Var
 I, Count: Integer;
Begin
 Count := 0;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Game.Players[I].IsActive And (Game.Players[I].Bid <> BID_FOLD) Then
   Inc(Count);
 End;
 CountActivePlayers := Count;
End;

Function IsValidCard(PlayerIndex, CardIndex: Integer): Boolean;
Var
 Card: TCard;
 I: Integer;
 HasLeadSuit: Boolean;
 HasTrump: Boolean;
Begin
 IsValidCard := False;
 If (CardIndex < 0) Or (CardIndex >= Game.Players[PlayerIndex].CardCount) Then Exit;
 Card := Game.Players[PlayerIndex].Cards[CardIndex];
  { Si c'est la premiÃ¨re carte de la levÃ©e }
 If Game.CurrentTrick.Count = 0 Then Begin
  IsValidCard := True;
  Exit;
 End;
  { V‚rifier si le joueur a la couleur demand‚e }
 HasLeadSuit := False;
 HasTrump := False;
 For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
  If Game.Players[PlayerIndex].Cards[I].Suit = Game.CurrentTrick.LeadSuit Then
   HasLeadSuit := True;
  If Game.Players[PlayerIndex].Cards[I].Suit = Game.TrumpSuit Then
   HasTrump := True;
 End;
  { Doit suivre la couleur si possible }
 If HasLeadSuit And (Card.Suit = Game.CurrentTrick.LeadSuit) Then Begin
  IsValidCard := True;
 End
 Else If Not HasLeadSuit Then Begin
  { Si on ne peut pas suivre, on peut jouer n'importe quoi }
  IsValidCard := True;
 End;
End;

Procedure CalculateResults;
Var
 I: Integer;
 PlayersCount: Integer;
 WinAmount: Integer;
Begin
 PlayersCount:=CountActivePlayers;
  { Calculer les gains et bourres }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Game.Players[I].IsActive And (Game.Players[I].Bid <> BID_FOLD) Then Begin
   Case Game.Players[I].Bid of
    BID_PLAY: Begin
     If Game.Players[I].TricksWon >= 1 Then Begin
      { Gagne sa part du pot }
      WinAmount := Game.Pot Div PlayersCount;
      Game.Players[I].Chips := Game.Players[I].Chips + WinAmount;
     End
     Else Begin
      { Bourr‚ - doit payer le pot }
      Game.Players[I].Chips := Game.Players[I].Chips - Game.Pot;
      Game.Players[I].IsBourre := True;
     End;
    End;
    BID_BOURRE: Begin
     If Game.Players[I].TricksWon = 5 Then Begin
      { Gagne tout le pot }
      Game.Players[I].Chips := Game.Players[I].Chips + Game.Pot;
     End
     Else Begin
      { Bourr‚ - doit payer double le pot }
      Game.Players[I].Chips := Game.Players[I].Chips - (Game.Pot * 2);
      Game.Players[I].IsBourre := True;
     End;
    End;
   End;
  End;
 End;
 Game.ShowResults := True;
End;

Procedure StartPlayingPhase;
Var
 I:Integer;
Begin
 { Trouver le premier joueur qui n'a pas pass‚ }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Game.Players[I].IsActive And (Game.Players[I].Bid <> BID_FOLD) Then Begin
   Game.CurrentPlayer := I;
   Break;
  End;
 End;
 Game.GamePhase:=GAME_PLAYING;
End;

Procedure PlayCard(PlayerIndex, CardIndex: Integer);
Var
 I:Integer;
Begin
 { Ajouter la carte … la lev‚e courante }
 Game.CurrentTrick.Cards[Game.CurrentTrick.Count] := Game.Players[PlayerIndex].Cards[CardIndex];
 Game.CurrentTrick.Players[Game.CurrentTrick.Count] := PlayerIndex;
 { D‚finir la couleur de la lev‚e si c'est la premiŠre carte }
 If Game.CurrentTrick.Count = 0 Then Begin
  Game.CurrentTrick.LeadSuit := Game.Players[PlayerIndex].Cards[CardIndex].Suit;
 End;
 Inc(Game.CurrentTrick.Count);
  { Retirer la carte de la main du joueur }
 For I := CardIndex to Game.Players[PlayerIndex].CardCount - 2 Do Begin
  Game.Players[PlayerIndex].Cards[I] := Game.Players[PlayerIndex].Cards[I + 1];
 End;
 Dec(Game.Players[PlayerIndex].CardCount);
  { Passer au joueur suivant ou ‚valuer la lev‚e }
 If Game.CurrentTrick.Count = CountActivePlayers Then Begin
  Game.GamePhase := GAME_TRICK_END;
  Game.AnimationDelay := 100;
 End
 Else Begin
  Repeat
   Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod Game.PlayerCount;
  Until Game.Players[Game.CurrentPlayer].IsActive And (Game.Players[Game.CurrentPlayer].Bid <> BID_FOLD);
 End;
 NeedRedraw := True;
End;

Function GetTrickWinner:Integer;
Var
 I, WinnerIndex,HighestValue:Integer;
 HasTrump:Boolean;
 FirstCard:Boolean;
Begin
 WinnerIndex := 0;
 HighestValue := 0;
 HasTrump := False;
 FirstCard := True;
  { Chercher d'abord les atouts }
 For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
  If Game.CurrentTrick.Cards[I].Suit = Game.TrumpSuit Then Begin
   If (Not HasTrump) Or (GetBourreValue(Game.CurrentTrick.Cards[I]) > HighestValue) Then Begin
    HighestValue := GetBourreValue(Game.CurrentTrick.Cards[I]);
    WinnerIndex := I;
    HasTrump := True;
   End;
  End;
 End;
  { Si pas d'atout, chercher la carte la plus haute de la couleur demandÃ©e }
 If Not HasTrump Then Begin
  For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
   If Game.CurrentTrick.Cards[I].Suit = Game.CurrentTrick.LeadSuit Then Begin
    If FirstCard Or (GetBourreValue(Game.CurrentTrick.Cards[I]) > HighestValue) Then Begin
     HighestValue := GetBourreValue(Game.CurrentTrick.Cards[I]);
     WinnerIndex := I;
     FirstCard := False;
    End;
   End;
  End;
 End;
 GetTrickWinner := Game.CurrentTrick.Players[WinnerIndex];
End;

Procedure NextTrick;
Var
 TrickWinner: Integer;
Begin
 TrickWinner := GetTrickWinner;
 Game.CurrentTrick.Winner := TrickWinner;
 Inc(Game.Players[TrickWinner].TricksWon);
  { Pr‚parer la prochaine lev‚e }
 Game.CurrentTrick.Count := 0;
 Game.CurrentTrick.Winner := -1;
 Game.CurrentTrick.LeadSuit := -1;
 Game.CurrentPlayer := TrickWinner;
 Inc(Game.TrickNumber);
 If Game.TrickNumber > 5 Then Begin
  Game.GamePhase := GAME_HAND_END;
  CalculateResults;
 End
  Else
 Begin
  Game.GamePhase := GAME_PLAYING;
 End;
 NeedRedraw := True;
End;

Procedure PlaceBid(PlayerIndex,BidType:Integer);Begin
 Game.Players[PlayerIndex].Bid := BidType;
  { Ajouter au pot selon la mise }
 Case BidType of
  BID_PLAY: Begin
   Game.Players[PlayerIndex].Chips := Game.Players[PlayerIndex].Chips - 5;
   Game.Pot := Game.Pot + 5;
  End;
  BID_BOURRE: Begin
   Game.Players[PlayerIndex].Chips := Game.Players[PlayerIndex].Chips - 10;
   Game.Pot := Game.Pot + 10;
  End;
 End;
  { Passer au joueur suivant }
 Repeat
  Game.BiddingPlayer := (Game.BiddingPlayer + 1) Mod Game.PlayerCount;
 Until Game.Players[Game.BiddingPlayer].IsActive Or (Game.BiddingPlayer = (Game.Dealer + 1) Mod Game.PlayerCount);
 { V‚rifier si les enchŠres sont termin‚es }
 If Game.BiddingPlayer = (Game.Dealer + 1) Mod Game.PlayerCount Then Begin
  StartPlayingPhase;
 End
  Else
 Begin
  Game.CurrentPlayer := Game.BiddingPlayer;
 End;
 NeedRedraw := True;
End;

Function GetComputerBid(PlayerIndex:Integer):Integer;
Var
 I: Integer;
 TrumpCards: Integer;
 HighCards: Integer;
Begin
 TrumpCards := 0;
 HighCards := 0;
  { Compter les atouts et les cartes hautes }
 For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
  If Game.Players[PlayerIndex].Cards[I].Suit = Game.TrumpSuit Then
   Inc(TrumpCards);
  If GetBourreValue(Game.Players[PlayerIndex].Cards[I]) >= 12 Then
   Inc(HighCards);
 End;
  { Strat‚gie simple }
 If(TrumpCards >= 3)And(HighCards >= 2)Then GetComputerBid := BID_BOURRE Else
 If(TrumpCards >= 2)Or(HighCards >= 3)Then GetComputerBid := BID_PLAY
                                      Else GetComputerBid := BID_FOLD;
End;

Function GetComputerCardChoice(PlayerIndex:Integer):Integer;
Var
 I, BestCard: Integer;
 BestValue: Integer;
 CanFollow: Boolean;
Begin
 BestCard := 0;
 BestValue := 0;
 CanFollow := False;
  { Strat‚gie simple: jouer la carte la plus haute possible }
 For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
  If IsValidCard(PlayerIndex, I) Then Begin
   If (Game.CurrentTrick.Count > 0) And
      (Game.Players[PlayerIndex].Cards[I].Suit = Game.CurrentTrick.LeadSuit) Then Begin
    If (Not CanFollow) Or (GetBourreValue(Game.Players[PlayerIndex].Cards[I]) > BestValue) Then Begin
     BestCard := I;
     BestValue := GetBourreValue(Game.Players[PlayerIndex].Cards[I]);
     CanFollow := True;
    End;
   End
   Else If Not CanFollow Then Begin
    { Jouer un atout si possible }
    If Game.Players[PlayerIndex].Cards[I].Suit = Game.TrumpSuit Then Begin
     If GetBourreValue(Game.Players[PlayerIndex].Cards[I]) > BestValue Then Begin
      BestCard := I;
      BestValue := GetBourreValue(Game.Players[PlayerIndex].Cards[I]);
     End;
    End
    Else If BestValue = 0 Then Begin
     BestCard := I;
     BestValue := GetBourreValue(Game.Players[PlayerIndex].Cards[I]);
    End;
   End;
  End;
 End;
 GetComputerCardChoice := BestCard;
End;

Procedure HandleComputerTurn;
Var
 Choice: Integer;
Begin
 If Not Game.Players[Game.CurrentPlayer].IsHuman Then Begin
  Case Game.GamePhase of
   GAME_BIDDING: Begin
    Choice := GetComputerBid(Game.CurrentPlayer);
    PlaceBid(Game.CurrentPlayer, Choice);
   End;
   GAME_PLAYING: Begin
    Choice := GetComputerCardChoice(Game.CurrentPlayer);
    PlayCard(Game.CurrentPlayer, Choice);
   End;
  End;
  Delay(1000);
 End;
End;

Function GetClickedCard(X,Y:Integer):Integer;
Var
 I,CardX,CardY:Integer;
Begin
 GetClickedCard := -1;
  { V‚rifier les cartes du joueur humain seulement }
 If Game.CurrentPlayer <> 0 Then Exit;
 CardY := 350;
 For I := 0 to Game.Players[0].CardCount - 1 Do Begin
  CardX := 50 + I * (CARD_WIDTH + 5);
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
 If Game.GamePhase <> GAME_PLAYING Then Exit;
 If Game.CurrentPlayer <> 0 Then Exit;
 ClickedCard := GetClickedCard(X, Y);
 If ClickedCard >= 0 Then Begin
  If IsValidCard(0, ClickedCard) Then Begin
   Game.SelectedCard := ClickedCard;
   PlayCard(0, ClickedCard);
  End
  Else Begin
   { Clic sur une carte invalide }
   Game.ErrorCard := ClickedCard;
   Game.ErrorTimer := 60;
   NeedRedraw := True;
  End;
 End;
End;

Procedure HandleInput;
Var
 Key: Char;
 MouseX, MouseY, MouseButton: LongInt;
Begin
  { Clavier }
 If KeyPressed Then Begin
  Key := ReadKey;
  Case Key of
   'f', 'F': Begin
    If (Game.GamePhase = GAME_BIDDING) And (Game.CurrentPlayer = 0) Then
     PlaceBid(0, BID_FOLD);
   End;
   'j', 'J': Begin
    If (Game.GamePhase = GAME_BIDDING) And (Game.CurrentPlayer = 0) Then
     PlaceBid(0, BID_PLAY);
   End;
   'b', 'B': Begin
    If (Game.GamePhase = GAME_BIDDING) And (Game.CurrentPlayer = 0) Then
     PlaceBid(0, BID_BOURRE);
   End;
   'n', 'N': Begin
    InitHand;
   End;
   #27: Begin
    CloseGraph;
    Halt;
   End;
   #13, ' ': Begin
    If Game.ShowResults Then Begin
     Game.ShowResults := False;
     InitHand;
    End;
   End;
  End;
 End;
  { Souris }
 If MouseDriverFound Then Begin
  GetMouseState(MouseX, MouseY, MouseButton);
  If MouseButton = 1 Then Begin
   HandleMouseClick(MouseX, MouseY);
   While MouseButton = 1 Do GetMouseState(MouseX, MouseY, MouseButton);
  End;
 End;
End;

BEGIN
 Randomize;
 InitScreen;
 If MouseDriverFound Then ShowMouse;
 InitGame;
  { Boucle principale }
 Repeat
  If NeedRedraw Then Begin
   DrawScreen;
   NeedRedraw := False;
  End;
  HandleInput;
   { Gestion du timer d'erreur }
  If Game.ErrorTimer > 0 Then Begin
   Dec(Game.ErrorTimer);
   If Game.ErrorTimer = 0 Then Begin
    Game.ErrorCard := -1;
    NeedRedraw := True;
   End;
  End;
  Case Game.GamePhase of
   GAME_BIDDING, GAME_PLAYING: Begin
    HandleComputerTurn;
   End;
   GAME_TRICK_END: Begin
    If Game.AnimationDelay > 0 Then Begin
     Dec(Game.AnimationDelay);
    End
    Else Begin
     NextTrick;
    End;
   End;
  End;
  Delay(50);
 Until False;
END.
