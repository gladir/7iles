{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Badugi - Jeu de poker draw cor�en
  L'objectif est d'avoir la main la plus basse avec 4 cartes de couleurs diff�rentes
}

Program Badugi;

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
 MAX_PLAYERS = 4;
 HAND_SIZE = 4;
 MAX_DRAWS = 3;

  { Couleurs des cartes }
 HEARTS = 0;
 DIAMONDS = 1;
 CLUBS = 2;
 SPADES = 3;

  { Valeurs des cartes (As = 1 est la plus basse) }
 ACE = 1;
 JACK = 11;
 QUEEN = 12;
 KING = 13;

  { États du jeu }
 GAME_DEALING = 0;
 GAME_BETTING = 1;
 GAME_DRAWING = 2;
 GAME_SHOWDOWN = 3;
 GAME_HAND_END = 4;
 GAME_OVER = 5;

  { Actions de mise }
 ACTION_FOLD = 0;
 ACTION_CALL = 1;
 ACTION_RAISE = 2;
 ACTION_CHECK = 3;

  { Tailles des mises }
 SMALL_BLIND = 1;
 BIG_BLIND = 2;
 MIN_RAISE = 2;

Type
 TCard = Record
  Suit: Integer;
  Value: Integer;
  Visible: Boolean;
  Selected: Boolean;
 End;

 TPlayer = Record
  Name: String;
  Hand: Array[0..HAND_SIZE-1] of TCard;
  IsHuman: Boolean;
  Chips: Integer;
  Bet: Integer;
  TotalBet: Integer;
  IsActive: Boolean;
  IsFolded: Boolean;
  Action: Integer;
  IsDealer: Boolean;
  IsSmallBlind: Boolean;
  IsBigBlind: Boolean;
 End;

 TGameState = Record
  Players: Array[0..MAX_PLAYERS-1] of TPlayer;
  Deck: Array[0..DECK_SIZE-1] of TCard;
  CurrentPlayer: Integer;
  Dealer: Integer;
  SmallBlind: Integer;
  BigBlind: Integer;
  CurrentBet: Integer;
  Pot: Integer;
  PlayerCount: Integer;
  GamePhase: Integer;
  DrawRound: Integer;
  BettingRound: Integer;
  AnimationDelay: Integer;
  ShowResults: Boolean;
  WinnerIndex: Integer;
  ErrorCard: Integer;
  ErrorTimer: Integer;
  DeckIndex: Integer;
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
 Function MouseDriverFound:Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse; Begin
  { Pas d'impl�mentation pour Free Pascal }
 End;

 Procedure HideMouse; Begin
  { Pas d'impl�mentation pour Free Pascal }
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
  2..10: Begin
   If (Card.Value >= 2) And (Card.Value <= 10) Then Begin
    If (Card.Value >= 2) And (Card.Value <= 9) Then
     GetCardName := Chr(Ord('0') + Card.Value)
    Else If Card.Value = 10 Then
     GetCardName := '10'
    Else
     GetCardName := '?';
   End
   Else
    GetCardName := '?';
  End;
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

Function GetActionName(Action:Integer):String;Begin
 Case Action of
  ACTION_FOLD: GetActionName := 'Passe';
  ACTION_CALL: GetActionName := 'Suit';
  ACTION_RAISE: GetActionName := 'Relance';
  ACTION_CHECK: GetActionName := 'Parole';
  Else GetActionName := 'Inconnu';
 End;
End;

Procedure InitDeck;
Var
 I,Suit,Value:Integer;
Begin
 I := 0;
 For Suit := 0 to 3 Do Begin
  For Value := 1 to 13 Do Begin
   If (I >= 0) And (I < DECK_SIZE) Then Begin
    Game.Deck[I].Suit := Suit;
    Game.Deck[I].Value := Value;
    Game.Deck[I].Visible := True;
    Game.Deck[I].Selected := False;
   End;
   Inc(I);
  End;
 End;
End;

Procedure ShuffleDeck;
Var
 I,J:Integer;
 TempCard:TCard;
Begin
 For I := 0 to DECK_SIZE - 1 Do Begin
  J := Random(DECK_SIZE);
  If (I >= 0) And (I < DECK_SIZE) And (J >= 0) And (J < DECK_SIZE) Then Begin
   TempCard := Game.Deck[I];
   Game.Deck[I] := Game.Deck[J];
   Game.Deck[J] := TempCard;
  End;
 End;
End;

Procedure InitPlayers;
Var
 I:Integer;
Begin
 Game.PlayerCount := 4;
  { Joueur humain }
 If Game.PlayerCount > 0 Then Begin
  Game.Players[0].Name := 'Joueur';
  Game.Players[0].IsHuman := True;
  Game.Players[0].Chips := 1000;
  Game.Players[0].IsActive := True;
 End;
  { Joueurs ordinateurs }
 If Game.PlayerCount > 1 Then Begin
  Game.Players[1].Name := 'Nord';
  Game.Players[1].IsHuman := False;
  Game.Players[1].Chips := 1000;
  Game.Players[1].IsActive := True;
 End;
 If Game.PlayerCount > 2 Then Begin
  Game.Players[2].Name := 'Est';
  Game.Players[2].IsHuman := False;
  Game.Players[2].Chips := 1000;
  Game.Players[2].IsActive := True;
 End;
 If Game.PlayerCount > 3 Then Begin
  Game.Players[3].Name := 'Ouest';
  Game.Players[3].IsHuman := False;
  Game.Players[3].Chips := 1000;
  Game.Players[3].IsActive := True;
 End;
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  If (I >= 0) And (I < MAX_PLAYERS) Then Begin
   Game.Players[I].Bet := 0;
   Game.Players[I].TotalBet := 0;
   Game.Players[I].IsFolded := False;
   Game.Players[I].Action := ACTION_CHECK;
   Game.Players[I].IsDealer := False;
   Game.Players[I].IsSmallBlind := False;
   Game.Players[I].IsBigBlind := False;
  End;
 End;
End;

Procedure DealCards;
Var
 I,J:Integer;
Begin
 Game.DeckIndex := 0;
  { Distribuer 4 cartes � chaque joueur }
 For I := 0 to HAND_SIZE - 1 Do Begin
  For J := 0 to Game.PlayerCount - 1 Do Begin
   If (J >= 0) And (J < Game.PlayerCount) And (J < MAX_PLAYERS) And (I >= 0) And (I < HAND_SIZE) And
      (Game.DeckIndex >= 0) And (Game.DeckIndex < DECK_SIZE) Then Begin
    If Game.Players[J].IsActive And Not Game.Players[J].IsFolded Then Begin
     Game.Players[J].Hand[I] := Game.Deck[Game.DeckIndex];
     If J = 0 Then Game.Players[J].Hand[I].Visible := True
              Else Game.Players[J].Hand[I].Visible := False;
     Game.Players[J].Hand[I].Selected := False;
     Inc(Game.DeckIndex);
     { Vérifier si on dépasse la limite du deck }
     If Game.DeckIndex >= DECK_SIZE Then Game.DeckIndex := DECK_SIZE - 1;
    End;
   End;
  End;
 End;
End;

Procedure SortPlayerHand(PlayerIndex: Integer);
Var
 I,J:Integer;
 TempCard:TCard;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Exit;
 
 { Tri par valeur croissante (As = 1 est le plus bas) }
 For I := 0 to HAND_SIZE - 2 Do Begin
  For J := I + 1 to HAND_SIZE - 1 Do Begin
   If (I >= 0) And (I < HAND_SIZE) And (J >= 0) And (J < HAND_SIZE) And
      (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
    If Game.Players[PlayerIndex].Hand[I].Value > Game.Players[PlayerIndex].Hand[J].Value Then Begin
     TempCard := Game.Players[PlayerIndex].Hand[I];
     Game.Players[PlayerIndex].Hand[I] := Game.Players[PlayerIndex].Hand[J];
     Game.Players[PlayerIndex].Hand[J] := TempCard;
    End;
   End;
  End;
 End;
End;

Procedure SetBlinds;Begin
 If (Game.SmallBlind < 0) Or (Game.SmallBlind >= Game.PlayerCount) Or
    (Game.BigBlind < 0) Or (Game.BigBlind >= Game.PlayerCount) Or
    (Game.SmallBlind >= MAX_PLAYERS) Or (Game.BigBlind >= MAX_PLAYERS) Then Exit;
    
 Game.Players[Game.SmallBlind].IsSmallBlind := True;
 Game.Players[Game.SmallBlind].Bet := SMALL_BLIND;
 Game.Players[Game.SmallBlind].TotalBet := SMALL_BLIND;
 Game.Players[Game.SmallBlind].Chips := Game.Players[Game.SmallBlind].Chips - SMALL_BLIND;
 Game.Pot := Game.Pot + SMALL_BLIND;
 Game.Players[Game.BigBlind].IsBigBlind := True;
 Game.Players[Game.BigBlind].Bet := BIG_BLIND;
 Game.Players[Game.BigBlind].TotalBet := BIG_BLIND;
 Game.Players[Game.BigBlind].Chips := Game.Players[Game.BigBlind].Chips - BIG_BLIND;
 Game.Pot := Game.Pot + BIG_BLIND;
 Game.CurrentBet := BIG_BLIND;
End;

Procedure InitHand;
Var
 I: Integer;
Begin
 If Game.PlayerCount <= 0 Then Exit;
 
 Game.GamePhase := GAME_DEALING;
 If Game.PlayerCount > 0 Then Begin
  Game.Dealer := (Game.Dealer + 1) Mod Game.PlayerCount;
  Game.SmallBlind := (Game.Dealer + 1) Mod Game.PlayerCount;
  Game.BigBlind := (Game.Dealer + 2) Mod Game.PlayerCount;
  Game.CurrentPlayer := (Game.BigBlind + 1) Mod Game.PlayerCount;
 End;
 Game.DrawRound := 0;
 Game.BettingRound := 1;
 Game.CurrentBet := 0;
 Game.Pot := 0;
 Game.AnimationDelay := 0;
 Game.ShowResults := False;
 Game.WinnerIndex := -1;
 Game.ErrorCard := -1;
 Game.ErrorTimer := 0;
  { R�initialiser les donn�es des joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   Game.Players[I].Bet := 0;
   Game.Players[I].TotalBet := 0;
   Game.Players[I].IsFolded := False;
   Game.Players[I].Action := ACTION_CHECK;
   Game.Players[I].IsDealer := False;
   Game.Players[I].IsSmallBlind := False;
   Game.Players[I].IsBigBlind := False;
  End;
 End;
 
 If (Game.Dealer >= 0) And (Game.Dealer < Game.PlayerCount) And (Game.Dealer < MAX_PLAYERS) Then
  Game.Players[Game.Dealer].IsDealer := True;
  
 InitDeck;
 ShuffleDeck;
 DealCards;
 SortPlayerHand(0);
 SetBlinds;
 Game.GamePhase:=GAME_BETTING;
 NeedRedraw := True;
End;

Procedure InitGlobalVariables;
Var
 I, J: Integer;
Begin
 { Initialiser complètement la structure Game }
 Game.PlayerCount := 0;
 Game.CurrentPlayer := 0;
 Game.Dealer := 0;
 Game.SmallBlind := 0;
 Game.BigBlind := 0;
 Game.CurrentBet := 0;
 Game.Pot := 0;
 Game.GamePhase := GAME_DEALING;
 Game.DrawRound := 0;
 Game.BettingRound := 0;
 Game.AnimationDelay := 0;
 Game.ShowResults := False;
 Game.WinnerIndex := -1;
 Game.ErrorCard := -1;
 Game.ErrorTimer := 0;
 Game.DeckIndex := 0;
 
 { Initialiser tous les joueurs }
 For I := 0 to MAX_PLAYERS - 1 Do Begin
  Game.Players[I].Name := '';
  Game.Players[I].IsHuman := False;
  Game.Players[I].Chips := 0;
  Game.Players[I].Bet := 0;
  Game.Players[I].TotalBet := 0;
  Game.Players[I].IsActive := False;
  Game.Players[I].IsFolded := False;
  Game.Players[I].Action := ACTION_CHECK;
  Game.Players[I].IsDealer := False;
  Game.Players[I].IsSmallBlind := False;
  Game.Players[I].IsBigBlind := False;
  { Initialiser les cartes de chaque joueur }
  For J := 0 to HAND_SIZE - 1 Do Begin
   Game.Players[I].Hand[J].Suit := 0;
   Game.Players[I].Hand[J].Value := 1;
   Game.Players[I].Hand[J].Visible := False;
   Game.Players[I].Hand[J].Selected := False;
  End;
 End;
 
 { Initialiser le deck }
 For I := 0 to DECK_SIZE - 1 Do Begin
  Game.Deck[I].Suit := 0;
  Game.Deck[I].Value := 1;
  Game.Deck[I].Visible := False;
  Game.Deck[I].Selected := False;
 End;
 
 { Initialiser la variable de redessin }
 NeedRedraw := True;
End;

Procedure InitGame;Begin
 InitGlobalVariables;
 InitPlayers;
 { S'assurer que les variables sont dans des limites valides }
 If Game.PlayerCount <= 0 Then Game.PlayerCount := 4;
 If Game.PlayerCount > MAX_PLAYERS Then Game.PlayerCount := MAX_PLAYERS;
 Game.Dealer := 0;
 InitHand;
End;

Procedure DrawCard(X, Y: Integer; Card: TCard; Highlighted: Boolean; ErrorHighlight: Boolean);
Var
 CardName: String;
 SuitSymbol: String;
 SuitColor: Integer;
Begin
 { Fond de la carte }
 If ErrorHighlight Then SetColor(LightRed) Else
 If Card.Selected Then SetColor(LightBlue) Else
 If Highlighted Then SetColor(Yellow)
                Else SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 { Bordure }
 If ErrorHighlight Then SetColor(Red) Else
 If Card.Selected Then SetColor(Blue) Else
 If Highlighted Then SetColor(Yellow)
                Else SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If Card.Visible Then Begin
   { Afficher la carte }
  CardName := GetCardName(Card);
  SuitSymbol := GetSuitSymbol(Card.Suit);
  SuitColor := GetSuitColor(Card.Suit);
   { Valeur en haut � gauche }
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 3, Y + 3, CardName);
  OutTextXY(X + 3, Y + 13, SuitSymbol);
   { Valeur en bas à droite (invers�e) }
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 25, CardName);
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 15, SuitSymbol);
   { Symbole au centre }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X + CARD_WIDTH Div 2 - 8, Y + CARD_HEIGHT Div 2 - 8, SuitSymbol);
   { Marquer si s�lectionn�e }
  If Card.Selected Then Begin
   SetColor(Blue);
   SetTextStyle(DefaultFont, HorizDir, 1);
   OutTextXY(X + 2, Y + CARD_HEIGHT - 12, 'S');
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
  OutTextXY(X + CARD_WIDTH Div 2 - 20, Y + CARD_HEIGHT Div 2 - 4, 'BADUGI');
 End;
End;

Procedure DrawPlayerHand(PlayerIndex:Integer);
Var
 I,X,Y,StartX,StartY:Integer;
 IsHighlighted,IsError:Boolean;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Exit;
 If Not Game.Players[PlayerIndex].IsActive Or Game.Players[PlayerIndex].IsFolded Then Exit;
 
 Case PlayerIndex of
  0: Begin { Joueur humain - en bas }
   StartX := 100;
   StartY := 350;
   For I := 0 to HAND_SIZE - 1 Do Begin
    If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
     X := StartX + I * (CARD_WIDTH + 10);
     IsHighlighted := False;
     IsError := (Game.ErrorCard = I) And (Game.ErrorTimer > 0);
     DrawCard(X, StartY, Game.Players[PlayerIndex].Hand[I], IsHighlighted, IsError);
    End;
   End;
  End;
  1: Begin { Nord - en haut }
   StartX := 100;
   StartY := 20;
   For I := 0 to HAND_SIZE - 1 Do Begin
    If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
     X := StartX + I * (CARD_WIDTH + 10);
     DrawCard(X, StartY, Game.Players[PlayerIndex].Hand[I], False, False);
    End;
   End;
  End;
  2: Begin { Est - � droite }
   StartX := 550;
   StartY := 150;
   For I := 0 to HAND_SIZE - 1 Do Begin
    If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
     Y := StartY + I * (CARD_HEIGHT Div 2 + 5);
     DrawCard(StartX, Y, Game.Players[PlayerIndex].Hand[I], False, False);
    End;
   End;
  End;
  3: Begin { Ouest - � gauche }
   StartX := 10;
   StartY := 150;
   For I := 0 to HAND_SIZE - 1 Do Begin
    If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
     Y := StartY + I * (CARD_HEIGHT Div 2 + 5);
     DrawCard(StartX, Y, Game.Players[PlayerIndex].Hand[I], False, False);
    End;
   End;
  End;
 End;
End;

Procedure DrawPlayerInfo;
Var
 I:Integer;
 PlayerName:String;
 ChipsText:String;
 BetText:String;
 ActionText:String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir,1);
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   If Not Game.Players[I].IsActive Then Continue;
  PlayerName := Game.Players[I].Name;
  Str(Game.Players[I].Chips, ChipsText);
  Str(Game.Players[I].Bet, BetText);
  ActionText := GetActionName(Game.Players[I].Action);
   { Marquer les rôles spéciaux }
  If Game.Players[I].IsDealer Then PlayerName := PlayerName + ' (D)';
  If Game.Players[I].IsSmallBlind Then PlayerName := PlayerName + ' (SB)';
  If Game.Players[I].IsBigBlind Then PlayerName := PlayerName + ' (BB)';
  Case I of
   0: Begin { Joueur humain }
    OutTextXY(100, 320, PlayerName + ' - Jetons: ' + ChipsText);
    OutTextXY(100, 330, 'Mise: ' + BetText + ' - Action: ' + ActionText);
    If Game.Players[I].IsFolded Then Begin
     SetColor(Red);
     OutTextXY(100, 340, 'PASSE');
     SetColor(White);
    End;
    If Game.CurrentPlayer = 0 Then Begin
     SetColor(Yellow);
     OutTextXY(80, 320, '>');
     SetColor(White);
    End;
   End;
   1: Begin { Nord }
    OutTextXY(100, 5, PlayerName + ' - Jetons: ' + ChipsText);
    OutTextXY(100, 15, 'Mise: ' + BetText + ' - Action: ' + ActionText);
    If Game.Players[I].IsFolded Then Begin
     SetColor(Red);
     OutTextXY(100, 25, 'PASSE');
     SetColor(White);
    End;
    If Game.CurrentPlayer = 1 Then Begin
     SetColor(Yellow);
     OutTextXY(80, 5, '>');
     SetColor(White);
    End;
   End;
   2: Begin { Est }
    OutTextXY(450, 120, PlayerName);
    OutTextXY(450, 130, 'Jetons: ' + ChipsText);
    OutTextXY(450, 140, 'Mise: ' + BetText);
    OutTextXY(450, 150, 'Action: ' + ActionText);
    If Game.Players[I].IsFolded Then Begin
     SetColor(Red);
     OutTextXY(450, 160, 'PASSE');
     SetColor(White);
    End;
    If Game.CurrentPlayer = 2 Then Begin
     SetColor(Yellow);
     OutTextXY(440, 120, '>');
     SetColor(White);
    End;
   End;
   3:Begin { Ouest }
    OutTextXY(70, 120, PlayerName);
    OutTextXY(70, 130, 'Jetons: ' + ChipsText);
    OutTextXY(70, 140, 'Mise: ' + BetText);
    OutTextXY(70, 150, 'Action: ' + ActionText);
    If Game.Players[I].IsFolded Then Begin
     SetColor(Red);
     OutTextXY(70, 160, 'PASSE');
     SetColor(White);
    End;
    If Game.CurrentPlayer = 3 Then Begin
     SetColor(Yellow);
     OutTextXY(60, 120, '>');
     SetColor(White);
    End;
    End;
   End;
  End;
 End;
End;

Procedure DrawGameInfo;
Var
 PotText: String;
 RoundText: String;
 DrawText: String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
  { Pot }
 Str(Game.Pot, PotText);
 OutTextXY(350, 200, 'Pot: ' + PotText + ' jetons');
  { Tour d'ench�res }
 Str(Game.BettingRound, RoundText);
 OutTextXY(350, 220, 'Tour: ' + RoundText);
  { Tour de draw }
 Str(Game.DrawRound, DrawText);
 If (MAX_DRAWS >= 0) And (MAX_DRAWS <= 9) Then
  OutTextXY(350, 240, 'Draw: ' + DrawText + '/' + Chr(Ord('0') + MAX_DRAWS))
 Else Begin
  Str(MAX_DRAWS, RoundText);
  OutTextXY(350, 240, 'Draw: ' + DrawText + '/' + RoundText);
 End;
  { Phase de jeu }
 Case Game.GamePhase of
  GAME_BETTING: OutTextXY(350, 260, 'Phase: Encheres');
  GAME_DRAWING: OutTextXY(350, 260, 'Phase: Echange');
  GAME_SHOWDOWN: OutTextXY(350, 260, 'Phase: Abattage');
  GAME_HAND_END: OutTextXY(350, 260, 'Phase: Fin de donne');
 End;
  { Instructions }
 SetColor(LightGray);
 OutTextXY(350, 290, 'Instructions:');
 Case Game.GamePhase of
  GAME_BETTING: Begin
   OutTextXY(350, 305, 'F - Passer');
   OutTextXY(350, 320, 'C - Suivre/Parole');
   OutTextXY(350, 335, 'R - Relancer');
  End;
  GAME_DRAWING: Begin
   OutTextXY(350, 305, 'Clic - Selectionner');
   OutTextXY(350, 320, 'D - Echanger');
   OutTextXY(350, 335, 'S - Rester');
  End;
 End;
 OutTextXY(350, 360, 'N - Nouvelle donne');
 OutTextXY(350, 375, 'ESC - Quitter');
End;

Procedure DrawBackground;Begin
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(480, 5, 'BADUGI');
End;

Function CountActivePlayers:Integer;
Var
 I,Count:Integer;
Begin
 Count:=0;
 For I:=0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   If Game.Players[I].IsActive And Not Game.Players[I].IsFolded Then
    Inc(Count);
  End;
 End;
 CountActivePlayers := Count;
End;

Function EvaluateBadugiHand(PlayerIndex: Integer): Integer;
Var
 I, J, Score, UniqueSuits, UniqueValues: Integer;
 UsedSuits: Array[0..3] of Boolean;
 UsedValues: Array[1..13] of Boolean;
 ValidCards: Array[0..3] of Boolean;
 CardCount: Integer;
 TempSuit, TempValue: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Begin
  EvaluateBadugiHand := 0;
  Exit;
 End;
  { Initialiser les tableaux }
 For I := 0 to 3 Do UsedSuits[I] := False;
 For I := 1 to 13 Do UsedValues[I] := False;
 For I := 0 to 3 Do ValidCards[I] := False;
  { Identifier les cartes valides (couleur et valeur uniques) }
 CardCount := 0;
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
   TempSuit := Game.Players[PlayerIndex].Hand[I].Suit;
   TempValue := Game.Players[PlayerIndex].Hand[I].Value;
   If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) Then Begin
    If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) And
       (Not UsedSuits[TempSuit]) And (Not UsedValues[TempValue]) Then Begin
     ValidCards[I] := True;
     UsedSuits[TempSuit] := True;
     UsedValues[TempValue] := True;
     Inc(CardCount);
    End;
   End;
  End;
 End;
  { Calculer le pointage bas� sur les cartes valides }
 Score := 0;
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And ValidCards[I] And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
   TempValue := Game.Players[PlayerIndex].Hand[I].Value;
   If (TempValue >= 1) And (TempValue <= 13) Then Begin
    Score := Score * 100 + TempValue;
   End;
  End;
 End;
  { Ajouter un bonus pour le nombre de cartes valides }
 Score := Score + CardCount * 10000;
 EvaluateBadugiHand := Score;
End;

Function GetHandDescription(PlayerIndex:Integer):String;
Var
 I,J,UniqueSuits,UniqueValues:Integer;
 UsedSuits:Array[0..3] of Boolean;
 UsedValues:Array[1..13] of Boolean;
 ValidCards:Array[0..3] of Boolean;
 CardCount:Integer;
 TempSuit, TempValue: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Begin
  GetHandDescription := 'Invalide';
  Exit;
 End;
  { Initialiser les tableaux }
 For I := 0 to 3 Do UsedSuits[I] := False;
 For I := 1 to 13 Do UsedValues[I] := False;
 For I := 0 to 3 Do ValidCards[I] := False;
  { Identifier les cartes valides }
 CardCount := 0;
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
   TempSuit := Game.Players[PlayerIndex].Hand[I].Suit;
   TempValue := Game.Players[PlayerIndex].Hand[I].Value;
   If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) Then Begin
    If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) And
       (Not UsedSuits[TempSuit]) And (Not UsedValues[TempValue]) Then Begin
     ValidCards[I] := True;
     UsedSuits[TempSuit] := True;
     UsedValues[TempValue] := True;
     Inc(CardCount);
    End;
   End;
  End;
 End;
 Case CardCount of
  4: GetHandDescription := 'Badugi';
  3: GetHandDescription := 'Tri';
  2: GetHandDescription := 'Paire';
  1: GetHandDescription := 'Carte haute';
  Else GetHandDescription := 'Invalide';
 End;
End;

Procedure DrawScreen;
Var
 I:Integer;
Begin
 DrawBackground;
  { Dessiner les mains de tous les joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   DrawPlayerHand(I);
  End;
 End;
 DrawPlayerInfo;
 DrawGameInfo;
 If Game.ShowResults Then Begin
   { Afficher les r�sultats }
  SetColor(Green);
  SetFillStyle(SolidFill, Green);
  Bar(150, 180, 490, 350);
  SetColor(White);
  Rectangle(150, 180, 490, 350);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(200, 200, 'Fin de donne');
  SetTextStyle(DefaultFont, HorizDir, 1);
  If (Game.WinnerIndex >= 0) And (Game.WinnerIndex < MAX_PLAYERS) Then Begin
   OutTextXY(160, 230, 'Gagnant: ' + Game.Players[Game.WinnerIndex].Name);
   OutTextXY(160, 250, 'Main: ' + GetHandDescription(Game.WinnerIndex));
  End;
  For I := 0 to Game.PlayerCount - 1 Do Begin
   If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
    If Game.Players[I].IsActive And Not Game.Players[I].IsFolded Then Begin
     OutTextXY(160, 270 + I * 15, Game.Players[I].Name + ': ' + GetHandDescription(I));
    End;
   End;
  End;
  OutTextXY(160, 320, 'Appuyez sur une touche...');
 End;
End;

Procedure PlaceBet(PlayerIndex,Amount:Integer);Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or 
    (PlayerIndex >= MAX_PLAYERS) Then Exit;
 If Amount > Game.Players[PlayerIndex].Chips Then
  Amount := Game.Players[PlayerIndex].Chips;
 Game.Players[PlayerIndex].Chips := Game.Players[PlayerIndex].Chips - Amount;
 Game.Players[PlayerIndex].Bet := Game.Players[PlayerIndex].Bet + Amount;
 Game.Players[PlayerIndex].TotalBet := Game.Players[PlayerIndex].TotalBet + Amount;
 Game.Pot := Game.Pot + Amount;
 If Game.Players[PlayerIndex].Bet > Game.CurrentBet Then
  Game.CurrentBet := Game.Players[PlayerIndex].Bet;
End;

Procedure HandlePlayerAction(PlayerIndex, Action: Integer);
Var
 LoopCount: Integer;
Begin
 If(PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Exit;
 Game.Players[PlayerIndex].Action := Action;
 Case Action of
  ACTION_FOLD: Begin
   Game.Players[PlayerIndex].IsFolded := True;
  End;
  ACTION_CALL: Begin
   If Game.CurrentBet > Game.Players[PlayerIndex].Bet Then
    PlaceBet(PlayerIndex, Game.CurrentBet - Game.Players[PlayerIndex].Bet);
  End;
  ACTION_RAISE: Begin
   If Game.CurrentBet > Game.Players[PlayerIndex].Bet Then
    PlaceBet(PlayerIndex, Game.CurrentBet - Game.Players[PlayerIndex].Bet);
   PlaceBet(PlayerIndex, MIN_RAISE);
  End;
  ACTION_CHECK: Begin
   { Rien à faire }
  End;
 End;
  { Passer au joueur suivant }
 LoopCount := 0;
 Repeat
  If Game.PlayerCount > 0 Then Begin
   Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod Game.PlayerCount;
   If Game.CurrentPlayer >= Game.PlayerCount Then Game.CurrentPlayer := 0;
  End
  Else Begin
   Game.CurrentPlayer := 0;
  End;
  Inc(LoopCount);
  If LoopCount > Game.PlayerCount Then Break; { Éviter les boucles infinies }
  If LoopCount > MAX_PLAYERS Then Break; { Protection supplémentaire }
 Until (Game.PlayerCount > 0) And (Game.CurrentPlayer >= 0) And (Game.CurrentPlayer < Game.PlayerCount) And
       (Game.CurrentPlayer < MAX_PLAYERS) And
       ((Game.CurrentPlayer >= 0) And (Game.CurrentPlayer < MAX_PLAYERS) And
        Game.Players[Game.CurrentPlayer].IsActive And Not Game.Players[Game.CurrentPlayer].IsFolded);
 NeedRedraw := True;
End;

Function IsBettingRoundComplete:Boolean;
Var
 I: Integer;
 AllCalled: Boolean;
Begin
 AllCalled := True;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   If Game.Players[I].IsActive And Not Game.Players[I].IsFolded Then Begin
    If Game.Players[I].Bet <> Game.CurrentBet Then Begin
     AllCalled := False;
     Break;
    End;
   End;
  End;
 End;
 IsBettingRoundComplete := AllCalled;
End;

Procedure StartDrawingPhase;
Var
 I: Integer;
Begin
 Game.GamePhase := GAME_DRAWING;
 Game.CurrentPlayer := 0;
 Inc(Game.DrawRound);
  { R�initialiser les mises pour le prochain tour }
 Game.CurrentBet := 0;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   Game.Players[I].Bet := 0;
  End;
 End;
 NeedRedraw := True;
End;

Procedure DetermineWinner;
Var
 I,BestScore,PlayerScore:Integer;
Begin
 Game.WinnerIndex := -1;
 BestScore := -1;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) And (I < MAX_PLAYERS) Then Begin
   If Game.Players[I].IsActive And Not Game.Players[I].IsFolded Then Begin
    PlayerScore := EvaluateBadugiHand(I);
    If PlayerScore > BestScore Then Begin
     BestScore := PlayerScore;
     Game.WinnerIndex := I;
    End;
   End;
  End;
 End;
 If (Game.WinnerIndex >= 0) And (Game.WinnerIndex < MAX_PLAYERS) Then Begin
  Game.Players[Game.WinnerIndex].Chips := Game.Players[Game.WinnerIndex].Chips + Game.Pot;
 End;
 Game.GamePhase := GAME_HAND_END;
 Game.ShowResults := True;
End;

Procedure DrawCards(PlayerIndex: Integer);
Var
 I, CardsDrawn, LoopCount: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Exit;
 CardsDrawn := 0;
  { �changer les cartes s�lectionn�es }
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
   If Game.Players[PlayerIndex].Hand[I].Selected Then Begin
    If (Game.DeckIndex >= 0) And (Game.DeckIndex < DECK_SIZE) Then Begin
     Game.Players[PlayerIndex].Hand[I] := Game.Deck[Game.DeckIndex];
     If PlayerIndex = 0 Then Game.Players[PlayerIndex].Hand[I].Visible := True
                        Else Game.Players[PlayerIndex].Hand[I].Visible := False;
     Game.Players[PlayerIndex].Hand[I].Selected := False;
     Inc(Game.DeckIndex);
     { Vérifier si on dépasse la limite du deck }
     If Game.DeckIndex >= DECK_SIZE Then Game.DeckIndex := DECK_SIZE - 1;
     Inc(CardsDrawn);
    End;
   End;
  End;
 End;
  { Trier la main du joueur humain }
 If PlayerIndex = 0 Then SortPlayerHand(0);
  { Passer au joueur suivant }
 LoopCount := 0;
 Repeat
  If Game.PlayerCount > 0 Then Begin
   Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod Game.PlayerCount;
   If Game.CurrentPlayer >= Game.PlayerCount Then Game.CurrentPlayer := 0;
  End
  Else Begin
   Game.CurrentPlayer := 0;
  End;
  Inc(LoopCount);
  If LoopCount > Game.PlayerCount Then Break; { Éviter les boucles infinies }
  If LoopCount > MAX_PLAYERS Then Break; { Protection supplémentaire }
 Until (Game.PlayerCount > 0) And (Game.CurrentPlayer >= 0) And (Game.CurrentPlayer < Game.PlayerCount) And
       (Game.CurrentPlayer < MAX_PLAYERS) And
       ((Game.CurrentPlayer >= 0) And (Game.CurrentPlayer < MAX_PLAYERS) And
        Game.Players[Game.CurrentPlayer].IsActive And Not Game.Players[Game.CurrentPlayer].IsFolded);
  { V�rifier si le tour d'�change est termin�e }
 If Game.CurrentPlayer = 0 Then Begin
  If Game.DrawRound >= MAX_DRAWS Then Begin
   Game.GamePhase := GAME_SHOWDOWN;
   DetermineWinner;
  End
  Else Begin
   Game.GamePhase := GAME_BETTING;
   Inc(Game.BettingRound);
  End;
 End;
 NeedRedraw := True;
End;

Function GetComputerAction(PlayerIndex:Integer):Integer;
Var
 HandStrength:Integer;
 Score:Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Begin
  GetComputerAction := ACTION_FOLD;
  Exit;
 End;
 
 Score := EvaluateBadugiHand(PlayerIndex);
  { �valuer la force de la main }
 If Score >= 40000 Then HandStrength := 3 Else { Badugi }
 If Score >= 30000 Then HandStrength := 2 Else { Tri }
 If Score >= 20000 Then HandStrength := 1  { Paire }
                   Else HandStrength := 0;  { Carte haute }
 { Strat�gie simple basée sur la force de la main }
 If HandStrength >= 2 Then GetComputerAction := ACTION_RAISE Else
 If HandStrength >= 1 Then GetComputerAction := ACTION_CALL Else
 If Game.CurrentBet <= BIG_BLIND Then GetComputerAction := ACTION_CALL
                                 Else GetComputerAction := ACTION_FOLD;
End;

Procedure GetComputerDrawDecision(PlayerIndex: Integer);
Var
 I, J: Integer;
 UsedSuits: Array[0..3] of Boolean;
 UsedValues: Array[1..13] of Boolean;
 KeepCard: Array[0..3] of Boolean;
 TempSuit, TempValue: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Or (PlayerIndex >= MAX_PLAYERS) Then Exit;
 
 { Initialiser les tableaux }
 For I := 0 to 3 Do UsedSuits[I] := False;
 For I := 1 to 13 Do UsedValues[I] := False;
 For I := 0 to 3 Do KeepCard[I] := False;
 { Identifier les cartes � garder (couleur et valeur uniques) }
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) Then Begin
   TempSuit := Game.Players[PlayerIndex].Hand[I].Suit;
   TempValue := Game.Players[PlayerIndex].Hand[I].Value;
   If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) Then Begin
    If (TempSuit >= 0) And (TempSuit <= 3) And (TempValue >= 1) And (TempValue <= 13) And
       (Not UsedSuits[TempSuit]) And (Not UsedValues[TempValue]) Then Begin
     KeepCard[I] := True;
     UsedSuits[TempSuit] := True;
     UsedValues[TempValue] := True;
    End;
   End;
  End;
 End;
  { Marquer les cartes à échanger }
 For I := 0 to HAND_SIZE - 1 Do Begin
  If (I >= 0) And (I < HAND_SIZE) And (PlayerIndex >= 0) And (PlayerIndex < MAX_PLAYERS) And
     (I >= 0) And (I <= 3) Then Begin
   Game.Players[PlayerIndex].Hand[I].Selected := Not KeepCard[I];
  End;
 End;
End;

Procedure HandleComputerTurn;
Var
 Action: Integer;
Begin
 If (Game.CurrentPlayer < 0) Or (Game.CurrentPlayer >= Game.PlayerCount) Or (Game.CurrentPlayer >= MAX_PLAYERS) Then Exit;
 
 If Not Game.Players[Game.CurrentPlayer].IsHuman Then Begin
  Case Game.GamePhase of
   GAME_BETTING: Begin
    Action := GetComputerAction(Game.CurrentPlayer);
    HandlePlayerAction(Game.CurrentPlayer, Action);
   End;
   GAME_DRAWING: Begin
    GetComputerDrawDecision(Game.CurrentPlayer);
    DrawCards(Game.CurrentPlayer);
   End;
  End;
  Delay(1000);
 End;
End;

Function GetClickedCard(X, Y: Integer): Integer;
Var
 I, CardX, CardY: Integer;
Begin
 GetClickedCard := -1;
  { V�rifier les cartes du joueur humain seulement }
 If Game.CurrentPlayer <> 0 Then Exit;
 If Game.GamePhase <> GAME_DRAWING Then Exit;
 CardY := 350;
 For I := 0 to HAND_SIZE - 1 Do Begin
  CardX := 100 + I * (CARD_WIDTH + 10);
  If (X >= CardX) And (X <= CardX + CARD_WIDTH) And
     (Y >= CardY) And (Y <= CardY + CARD_HEIGHT) Then Begin
   GetClickedCard := I;
   Exit;
  End;
 End;
End;

Procedure HandleMouseClick(X, Y: Integer);
Var
 ClickedCard: Integer;
Begin
 If Game.GamePhase <> GAME_DRAWING Then Exit;
 If Game.CurrentPlayer <> 0 Then Exit;
 If (Game.PlayerCount <= 0) Or (0 >= MAX_PLAYERS) Then Exit;
 ClickedCard := GetClickedCard(X, Y);
 If ClickedCard >= 0 Then Begin
  { Basculer la sélection de la carte }
  If (ClickedCard >= 0) And (ClickedCard < HAND_SIZE) And (0 >= 0) And (0 < MAX_PLAYERS) And
     (ClickedCard >= 0) And (ClickedCard < HAND_SIZE) Then Begin
   Game.Players[0].Hand[ClickedCard].Selected := Not Game.Players[0].Hand[ClickedCard].Selected;
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
    If (Game.GamePhase = GAME_BETTING) And (Game.CurrentPlayer = 0) And
       (Game.PlayerCount > 0) And (0 >= 0) And (0 < MAX_PLAYERS) Then
     HandlePlayerAction(0, ACTION_FOLD);
   End;
   'c', 'C': Begin
    If (Game.GamePhase = GAME_BETTING) And (Game.CurrentPlayer = 0) And 
       (Game.PlayerCount > 0) And (0 >= 0) And (0 < MAX_PLAYERS) Then Begin
     If Game.CurrentBet > Game.Players[0].Bet Then
      HandlePlayerAction(0, ACTION_CALL)
     Else
      HandlePlayerAction(0, ACTION_CHECK);
    End;
   End;
   'r', 'R': Begin
    If (Game.GamePhase = GAME_BETTING) And (Game.CurrentPlayer = 0) And
       (Game.PlayerCount > 0) And (0 >= 0) And (0 < MAX_PLAYERS) Then
     HandlePlayerAction(0, ACTION_RAISE);
   End;
   'd', 'D': Begin
    If (Game.GamePhase = GAME_DRAWING) And (Game.CurrentPlayer = 0) And
       (Game.PlayerCount > 0) And (0 >= 0) And (0 < MAX_PLAYERS) Then
     DrawCards(0);
   End;
   's', 'S': Begin
    If (Game.GamePhase = GAME_DRAWING) And (Game.CurrentPlayer = 0) And
       (Game.PlayerCount > 0) And (0 >= 0) And (0 < MAX_PLAYERS) Then Begin
     { Rester (ne pas échanger) }
     If (0 >= 0) And (0 < HAND_SIZE) And (0 >= 0) And (0 < MAX_PLAYERS) Then
      Game.Players[0].Hand[0].Selected := False;
     If (1 >= 0) And (1 < HAND_SIZE) And (0 >= 0) And (0 < MAX_PLAYERS) Then
      Game.Players[0].Hand[1].Selected := False;
     If (2 >= 0) And (2 < HAND_SIZE) And (0 >= 0) And (0 < MAX_PLAYERS) Then
      Game.Players[0].Hand[2].Selected := False;
     If (3 >= 0) And (3 < HAND_SIZE) And (0 >= 0) And (0 < MAX_PLAYERS) Then
      Game.Players[0].Hand[3].Selected := False;
     DrawCards(0);
    End;
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
 InitGlobalVariables;
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
   GAME_BETTING: Begin
    HandleComputerTurn;
    If IsBettingRoundComplete And (CountActivePlayers > 1) Then Begin
     StartDrawingPhase;
    End
    Else If CountActivePlayers <= 1 Then Begin
     DetermineWinner;
    End;
   End;
   GAME_DRAWING: Begin
    HandleComputerTurn;
   End;
   GAME_HAND_END: Begin
    If Game.AnimationDelay > 0 Then Begin
     Dec(Game.AnimationDelay);
    End;
   End;
  End;
  Delay(50);
 Until False;
END.
