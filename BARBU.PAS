{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Barbu - Jeu de cartes de levÇes avec pÇnalitÇs
  L'objectif est d'Çviter les cartes qui donnent des points de pÇnalitÇ
}

Program Barbu;

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
 CARDS_PER_PLAYER = 13;
 MAX_PLAYERS = 4;

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
 GAME_DEALING = 0;
 GAME_PLAYING = 1;
 GAME_TRICK_END = 2;
 GAME_ROUND_END = 3;
 GAME_OVER = 4;

  { Contrats Barbu }
 CONTRACT_NO_TRICKS = 0;     { Pas de levÇes }
 CONTRACT_NO_HEARTS = 1;     { Pas de coeurs }
 CONTRACT_NO_QUEENS = 2;     { Pas de dames }
 CONTRACT_NO_KING_HEARTS = 3; { Pas le roi de coeur }
 CONTRACT_NO_LAST_TRICK = 4; { Pas la derniäre levÇe }

  { Points de p√©nalit√© }
 PENALTY_TRICK = 2;          { Par levÇe }
 PENALTY_HEART = 2;          { Par coeur }
 PENALTY_QUEEN = 6;          { Par dame }
 PENALTY_KING_HEARTS = 16;   { Roi de coeur }
 PENALTY_LAST_TRICK = 16;    { Derniäre levÇe }

Type
  TCard = Record
   Suit: Integer;      { Couleur: 0=Coeur, 1=Pique, 2=Carreau, 3=träfle }
   Value: Integer;     { Valeur: 1-13 }
   Visible: Boolean;   { Carte visible ou face cachÇe }
  End;

  TPlayer = Record
   Name: String;
   Cards: Array[0..CARDS_PER_PLAYER-1] of TCard;
   CardCount: Integer;
   IsHuman: Boolean;
   Score: Integer;
   TricksWon: Integer;
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
   Contract: Integer;
   CurrentPlayer: Integer;
   Dealer: Integer;
   TrickNumber: Integer;
   GamePhase: Integer;
   SelectedCard: Integer;
   AnimationDelay: Integer;
   ShowScores: Boolean;
   ErrorCard: Integer;        { Index de la carte en erreur (-1 si aucune) }
   ErrorTimer: Integer;       { Compteur pour l'animation d'erreur }
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

 Procedure ShowMouse;
 Begin
  { Pas d'implÇmentation pour Free Pascal }
 End;

 Procedure HideMouse;
 Begin
  { Pas d'implÇmentation pour Free Pascal }
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

Function GetContractName(Contract: Integer):String;Begin
 Case Contract of
  CONTRACT_NO_TRICKS: GetContractName := 'Pas de levees';
  CONTRACT_NO_HEARTS: GetContractName := 'Pas de coeurs';
  CONTRACT_NO_QUEENS: GetContractName := 'Pas de dames';
  CONTRACT_NO_KING_HEARTS: GetContractName := 'Pas le roi de coeur';
  CONTRACT_NO_LAST_TRICK: GetContractName := 'Pas derniere levee';
  Else GetContractName := 'Inconnu';
 End;
End;

Procedure InitDeck;
Var
 I,Suit,Value:Integer;
Begin
 I := 0;
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
 I, J: Integer;
 TempCard: TCard;
Begin
 For I := 0 to DECK_SIZE - 1 Do Begin
  J := Random(DECK_SIZE);
  TempCard := Game.Deck[I];
  Game.Deck[I] := Game.Deck[J];
  Game.Deck[J] := TempCard;
 End;
End;

Procedure InitPlayers;
Var
 I:Integer;
Begin
  { Joueur humain }
 Game.Players[0].Name := 'Joueur';
 Game.Players[0].IsHuman := True;
 Game.Players[0].Score := 0;
  { Joueurs ordinateurs }
 Game.Players[1].Name := 'Nord';
 Game.Players[1].IsHuman := False;
 Game.Players[1].Score := 0;
 Game.Players[2].Name := 'Est';
 Game.Players[2].IsHuman := False;
 Game.Players[2].Score := 0;
 Game.Players[3].Name := 'Ouest';
 Game.Players[3].IsHuman := False;
 Game.Players[3].Score := 0;
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  Game.Players[I].CardCount := 0;
  Game.Players[I].TricksWon := 0;
 End;
End;

Procedure DealCards;
Var
 I,J,CardIndex:Integer;
Begin
 CardIndex := 0;
 For I := 0 to CARDS_PER_PLAYER - 1 Do Begin
  For J := 0 to MAX_PLAYERS - 1 Do Begin
   Game.Players[J].Cards[I] := Game.Deck[CardIndex];
   If J = 0 Then Game.Players[J].Cards[I].Visible := True
            Else Game.Players[J].Cards[I].Visible := False;
   Inc(CardIndex);
  End;
 End;
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  Game.Players[I].CardCount := CARDS_PER_PLAYER;
 End;
End;

Procedure SortPlayerCards(PlayerIndex: Integer);
Var
 I,J:Integer;
 TempCard:TCard;
Begin
  { Tri par couleur puis par valeur }
 For I := 0 to Game.Players[PlayerIndex].CardCount - 2 Do Begin
  For J := I + 1 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
   If (Game.Players[PlayerIndex].Cards[I].Suit > Game.Players[PlayerIndex].Cards[J].Suit) Or
      ((Game.Players[PlayerIndex].Cards[I].Suit = Game.Players[PlayerIndex].Cards[J].Suit) And
      (Game.Players[PlayerIndex].Cards[I].Value > Game.Players[PlayerIndex].Cards[J].Value)) Then Begin
    TempCard := Game.Players[PlayerIndex].Cards[I];
    Game.Players[PlayerIndex].Cards[I] := Game.Players[PlayerIndex].Cards[J];
    Game.Players[PlayerIndex].Cards[J] := TempCard;
   End;
  End;
 End;
End;

Procedure InitGame;Begin
 Game.GamePhase := GAME_DEALING;
 Game.Contract := CONTRACT_NO_HEARTS; { Contrat par d√©faut }
 Game.Dealer := 0;
 Game.CurrentPlayer := (Game.Dealer + 1) Mod MAX_PLAYERS;
 Game.TrickNumber := 1;
 Game.SelectedCard := -1;
 Game.AnimationDelay := 0;
 Game.ShowScores := False;
 Game.ErrorCard := -1;
 Game.ErrorTimer := 0;
  { Initialiser la lev√©e courante }
 Game.CurrentTrick.Count := 0;
 Game.CurrentTrick.Winner := -1;
 Game.CurrentTrick.LeadSuit := -1;
 InitDeck;
 ShuffleDeck;
 InitPlayers;
 DealCards;
  { Trier les cartes du joueur humain }
 SortPlayerCards(0);
 Game.GamePhase := GAME_PLAYING;
 NeedRedraw := True;
End;

Procedure DrawCard(X, Y: Integer; Card: TCard; Highlighted: Boolean; ErrorHighlight: Boolean);
Var
 CardName:String;
 SuitSymbol:String;
 SuitColor:Integer;
Begin
  { Fond de la carte }
 If ErrorHighlight Then
  SetColor(LightRed)
 Else If Highlighted Then
  SetColor(Yellow)
 Else
  SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
  { Bordure }
 If ErrorHighlight Then
  SetColor(Red)
 Else If Highlighted Then
  SetColor(Yellow)
 Else
  SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If Card.Visible Then Begin
   { Afficher la carte }
  CardName := GetCardName(Card);
  SuitSymbol := GetSuitSymbol(Card.Suit);
  SuitColor := GetSuitColor(Card.Suit);
   { Valeur en haut Ö gauche }
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 3, Y + 3, CardName);
  OutTextXY(X + 3, Y + 13, SuitSymbol);
   { Valeur en bas Ö droite (inversÇe) }
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 25, CardName);
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 15, SuitSymbol);
   { Symbole au centre }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X + CARD_WIDTH Div 2 - 8, Y + CARD_HEIGHT Div 2 - 8, SuitSymbol);
   { Remettre la taille de police normale }
  SetTextStyle(DefaultFont, HorizDir, 1);
 End
  Else
 Begin
   { Dos de carte }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(X + 5, Y + 5, X + CARD_WIDTH - 5, Y + CARD_HEIGHT - 5);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + CARD_WIDTH Div 2 - 20, Y + CARD_HEIGHT Div 2 - 4, 'BARBU');
 End;
End;

Procedure DrawPlayerCards(PlayerIndex: Integer);
Var
 I, X, Y, StartX, StartY: Integer;
 IsHighlighted, IsError: Boolean;
Begin
 Case PlayerIndex of
  0:Begin { Joueur humain - en bas }
   StartX := 50;
   StartY := 350;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    X := StartX + I * (CARD_WIDTH Div 2 + 5);
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
  2: Begin { Est - A droite }
   StartX := 550;
   StartY := 100;
   For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
    Y := StartY + I * (CARD_HEIGHT Div 3 + 2);
    DrawCard(StartX, Y, Game.Players[PlayerIndex].Cards[I], False, False);
   End;
  End;
  3: Begin { Ouest - ÔøΩ gauche }
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
  { Positions pour les cartes de la levÇe courante }
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

Procedure DrawPlayerInfo;
Var
 I:Integer;
 PlayerName:String;
 ScoreText:String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  PlayerName := Game.Players[I].Name;
  ScoreText := Chr(Ord('0') + (Game.Players[I].Score Mod 10));
  Case I of
   0: Begin { Joueur humain }
    OutTextXY(60, 330, PlayerName + ' - Pointage: ' + ScoreText);
    If Game.CurrentPlayer = 0 Then Begin
     SetColor(Yellow);
     OutTextXY(40, 330, '>');
     SetColor(White);
    End;
   End;
   1:Begin { Nord }
    OutTextXY(60, 10, PlayerName + ' - Pointage: ' + ScoreText);
    If Game.CurrentPlayer = 1 Then Begin
     SetColor(Yellow);
     OutTextXY(40, 10, '>');
     SetColor(White);
    End;
   End;
   2: Begin { Est }
    OutTextXY(470, 100, PlayerName);
    OutTextXY(470, 115, 'Pointage: ' + ScoreText);
    If Game.CurrentPlayer = 2 Then Begin
     SetColor(Yellow);
     OutTextXY(460, 100, '>');
     SetColor(White);
    End;
   End;
   3: Begin { Ouest }
    OutTextXY(70, 100, PlayerName);
    OutTextXY(70, 115, 'Pointage: ' + ScoreText);
    If Game.CurrentPlayer = 3 Then Begin
     SetColor(Yellow);
     OutTextXY(60, 100, '>');
     SetColor(White);
    End;
   End;
  End;
 End;
End;

Procedure DrawGameInfo;Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
  { Contrat }
 OutTextXY(400, 50, 'Contrat:');
 OutTextXY(400, 65, GetContractName(Game.Contract));
  { NumÔøΩro de levÔøΩe }
 OutTextXY(400, 90, 'Levee: ' + Chr(Ord('0') + (Game.TrickNumber Mod 10)));
  { Instructions }
 SetColor(LightGray);
 OutTextXY(400, 120, 'Instructions:');
 OutTextXY(400, 135, 'Clic - Jouer carte');
 OutTextXY(400, 150, 'C - Changer contrat');
 OutTextXY(400, 165, 'N - Nouvelle partie');
 OutTextXY(400, 180, 'ESC - Quitter');
End;

Procedure DrawBackground;Begin
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(500, 5, 'BARBU');
End;

Procedure DrawScreen;
Var
 I:Integer;
Begin
 DrawBackground;
  { Dessiner les cartes de tous les joueurs }
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  DrawPlayerCards(I);
 End;
 DrawCurrentTrick;
 DrawPlayerInfo;
 DrawGameInfo;
 If Game.ShowScores Then Begin
   { Afficher les scores de fin de manche }
  SetColor(Green);
  SetFillStyle(SolidFill, Green);
  Bar(150, 200, 490, 350);
  SetColor(White);
  Rectangle(150, 200, 490, 350);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(180, 220, 'Fin de manche');
  SetTextStyle(DefaultFont, HorizDir, 1);
  For I := 0 to MAX_PLAYERS - 1 Do Begin
   OutTextXY(160, 250 + I * 20, Game.Players[I].Name + ': ' +
             Chr(Ord('0') + (Game.Players[I].Score Mod 10)) + ' points');
  End;
  OutTextXY(160, 320, 'Appuyez sur une touche...');
 End;
End;

Function IsValidCard(PlayerIndex,CardIndex:Integer):Boolean;
Var
 Card:TCard;
 I:Integer;
Begin
 IsValidCard:=False;
 If (CardIndex < 0) Or (CardIndex >= Game.Players[PlayerIndex].CardCount)Then Exit;
 Card := Game.Players[PlayerIndex].Cards[CardIndex];
  { Si c'est la premi√®re carte de la lev√©e }
 If Game.CurrentTrick.Count = 0 Then Begin
  IsValidCard := True;
  Exit;
 End;
  { Doit suivre la couleur si possible }
 If Card.Suit = Game.CurrentTrick.LeadSuit Then Begin
  IsValidCard := True;
 End
  Else
 Begin
  { VÔøΩrifier si le joueur a des cartes de la couleur demandÔøΩe }
  For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
   If Game.Players[PlayerIndex].Cards[I].Suit = Game.CurrentTrick.LeadSuit Then Begin
    Exit; { Le joueur a des cartes de la couleur, doit la jouer }
   End;
  End;
   { Le joueur n'a pas la couleur, peut jouer n'importe quoi }
  IsValidCard := True;
 End;
End;

Procedure PlayCard(PlayerIndex, CardIndex:Integer);
Var
 I: Integer;
Begin
  { Ajouter la carte Ö la levÇe courante }
 Game.CurrentTrick.Cards[Game.CurrentTrick.Count] := Game.Players[PlayerIndex].Cards[CardIndex];
 Game.CurrentTrick.Players[Game.CurrentTrick.Count] := PlayerIndex;
  { DÇfinir la couleur de la levÇe si c'est la premiäre carte }
 If Game.CurrentTrick.Count = 0 Then Begin
  Game.CurrentTrick.LeadSuit := Game.Players[PlayerIndex].Cards[CardIndex].Suit;
 End;
 Inc(Game.CurrentTrick.Count);
  { Retirer la carte de la main du joueur }
 For I := CardIndex to Game.Players[PlayerIndex].CardCount - 2 Do Begin
  Game.Players[PlayerIndex].Cards[I] := Game.Players[PlayerIndex].Cards[I + 1];
 End;
 Dec(Game.Players[PlayerIndex].CardCount);
  { Passer au joueur suivant ou Çvaluer la levÇe }
 If Game.CurrentTrick.Count = MAX_PLAYERS Then Begin
  Game.GamePhase := GAME_TRICK_END;
  Game.AnimationDelay := 100; { DÇlai pour voir la levÇe }
 End
  Else
 Begin
  Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod MAX_PLAYERS;
 End;
 NeedRedraw := True;
End;

Function GetTrickWinner: Integer;
Var
 I, WinnerIndex, HighestValue: Integer;
 WinningCard: TCard;
 FirstLeadCard: Boolean;
Begin
 WinnerIndex := 0;
 HighestValue := 0;
 FirstLeadCard := True;
  { Trouver la carte la plus haute de la couleur de levÇe }
 For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
  If Game.CurrentTrick.Cards[I].Suit = Game.CurrentTrick.LeadSuit Then Begin
   If FirstLeadCard Or (Game.CurrentTrick.Cards[I].Value > HighestValue) Then Begin
    HighestValue := Game.CurrentTrick.Cards[I].Value;
    WinnerIndex := I;
    WinningCard := Game.CurrentTrick.Cards[I];
    FirstLeadCard := False;
   End;
  End;
 End;
 GetTrickWinner := Game.CurrentTrick.Players[WinnerIndex];
End;

Procedure CalculatePenalties;
Var
 I,J,Winner: Integer;
 Penalties: Integer;
Begin
 Winner := GetTrickWinner;
 Game.CurrentTrick.Winner := Winner;
 Inc(Game.Players[Winner].TricksWon);
 Penalties := 0;
 Case Game.Contract of
  CONTRACT_NO_TRICKS: Begin
    { 2 points par levÇe }
   Penalties := PENALTY_TRICK;
  End;
  CONTRACT_NO_HEARTS: Begin
   { 2 points par coeur dans la levÇe }
   For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
    If Game.CurrentTrick.Cards[I].Suit = HEARTS Then Begin
     Penalties := Penalties + PENALTY_HEART;
    End;
   End;
  End;
  CONTRACT_NO_QUEENS: Begin
    { 6 points par dame dans la levÇe }
   For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
    If Game.CurrentTrick.Cards[I].Value = QUEEN Then Begin
     Penalties := Penalties + PENALTY_QUEEN;
    End;
   End;
  End;
  CONTRACT_NO_KING_HEARTS: Begin
    { 16 points pour le roi de coeur }
   For I := 0 to Game.CurrentTrick.Count - 1 Do Begin
     If (Game.CurrentTrick.Cards[I].Suit = HEARTS) And
        (Game.CurrentTrick.Cards[I].Value = KING) Then Begin
      Penalties := PENALTY_KING_HEARTS;
     End;
   End;
  End;
  CONTRACT_NO_LAST_TRICK: Begin
    { 16 points pour la derniäre levÇe }
   If Game.TrickNumber = 13 Then Begin
    Penalties := PENALTY_LAST_TRICK;
   End;
  End;
 End;
  { Ajouter les pÇnalitÇs au gagnant de la levÇe }
 Game.Players[Winner].Score := Game.Players[Winner].Score + Penalties;
End;

Procedure NextTrick;
Var
 TrickWinner: Integer;
Begin
 CalculatePenalties;
 TrickWinner:=Game.CurrentTrick.Winner;
  { PrÇparer la prochaine levÇe }
 Game.CurrentTrick.Count := 0;
 Game.CurrentTrick.Winner := -1;
 Game.CurrentTrick.LeadSuit := -1;
 Game.CurrentPlayer := TrickWinner;
 Inc(Game.TrickNumber);
 If Game.TrickNumber > 13 Then Begin
  Game.GamePhase := GAME_ROUND_END;
  Game.ShowScores := True;
 End
  Else
 Begin
  Game.GamePhase := GAME_PLAYING;
 End;
 NeedRedraw := True;
End;

Function GetComputerCardChoice(PlayerIndex:Integer):Integer;
Var
 I,BestCard,LowestValue:Integer;
 CanFollow:Boolean;
Begin
 BestCard := 0;
 LowestValue := 14;
 CanFollow := False;
  { StratÇgie simple: jouer la carte la plus basse possible }
 For I := 0 to Game.Players[PlayerIndex].CardCount - 1 Do Begin
  If IsValidCard(PlayerIndex, I) Then Begin
    { Si on peut suivre la couleur, privil√©gier les cartes basses }
   If (Game.CurrentTrick.Count > 0) And
      (Game.Players[PlayerIndex].Cards[I].Suit = Game.CurrentTrick.LeadSuit) Then Begin
    If Not CanFollow Or (Game.Players[PlayerIndex].Cards[I].Value < LowestValue) Then Begin
     BestCard := I;
     LowestValue := Game.Players[PlayerIndex].Cards[I].Value;
     CanFollow := True;
    End;
   End
    Else
   If Not CanFollow Then Begin
     { Si on ne peut pas suivre, jouer la carte la plus basse }
    If Game.Players[PlayerIndex].Cards[I].Value < LowestValue Then Begin
     BestCard := I;
     LowestValue := Game.Players[PlayerIndex].Cards[I].Value;
    End;
   End;
  End;
 End;
 GetComputerCardChoice := BestCard;
End;

Procedure HandleComputerTurn;
Var
 CardChoice: Integer;
Begin
 If Not Game.Players[Game.CurrentPlayer].IsHuman Then Begin
  CardChoice := GetComputerCardChoice(Game.CurrentPlayer);
  PlayCard(Game.CurrentPlayer, CardChoice);
  Delay(1000); { DÇlai pour l'animation }
 End;
End;

Function GetClickedCard(X,Y:Integer):Integer;
Var
 I, CardX, CardY: Integer;
Begin
 GetClickedCard := -1;
  { VÇrifier les cartes du joueur humain seulement }
 If Game.CurrentPlayer <> 0 Then Exit;
 CardY := 350;
 For I := 0 to Game.Players[0].CardCount - 1 Do Begin
  CardX := 50 + I * (CARD_WIDTH Div 2 + 5);
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
 If Game.CurrentPlayer <> 0 Then Exit; { Seulement pour le joueur humain }
 ClickedCard := GetClickedCard(X, Y);
 If ClickedCard >= 0 Then Begin
  If IsValidCard(0, ClickedCard) Then Begin
   Game.SelectedCard := ClickedCard;
   PlayCard(0, ClickedCard);
  End
   Else
  Begin
    { Clic sur une carte invalide - afficher l'erreur }
   Game.ErrorCard := ClickedCard;
   Game.ErrorTimer := 60; { 60 frames = ~2 secondes √† 30 FPS }
   NeedRedraw := True;
  End;
 End;
End;

Procedure ChangeContract;Begin
 Game.Contract := (Game.Contract + 1) Mod 5;
 NeedRedraw := True;
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
  'c', 'C': Begin
   If Game.GamePhase = GAME_PLAYING Then
   ChangeContract;
  End;
  'n', 'N': Begin
    InitGame;
   End;
   #27:Begin
    CloseGraph;
    Halt;
   End;
   #13, ' ': Begin
    If Game.ShowScores Then Begin
     Game.ShowScores := False;
     InitGame;
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
   { Gestion du timer d'erreur pour l'affichage rouge }
  If Game.ErrorTimer > 0 Then Begin
   Dec(Game.ErrorTimer);
   If Game.ErrorTimer = 0 Then Begin
    Game.ErrorCard := -1;
    NeedRedraw := True;
   End;
  End;
  Case Game.GamePhase of
   GAME_PLAYING: Begin
    HandleComputerTurn;
   End;
   GAME_TRICK_END: Begin
    If Game.AnimationDelay > 0 Then Begin
     Dec(Game.AnimationDelay);
    End
     Else
    Begin
     NextTrick;
    End;
   End;
  End;
  Delay(50);
 Until False;
END.
