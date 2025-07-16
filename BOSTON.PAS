{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @description: BOSTON - Jeu de cartes de lev√©es
}

Program Boston;

Uses {$IFDEF FPC}
      PtcCrt,PtcGraph
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
 MAX_CARDS = 52;
 CARDS_PER_PLAYER = 13;
 NUM_PLAYERS = 4;

Type
 TCard = Record
  Suit: Integer;    { 0=Träfle, 1=Carreau, 2=Coeur, 3=Pique }
  Value: Integer;   { 1=As, 2-10=Valeur, 11=Valet, 12=Dame, 13=Roi }
 End;

 TPlayer = Record
  Name: String[20];
  Cards: Array[1..CARDS_PER_PLAYER] of TCard;
  CardCount: Integer;
  Tricks: Integer;
  IsHuman: Boolean;
 End;

 TBid = Record
  Player: Integer;
  Suit: Integer;    { 0-3=Couleur, 4=Sans Atout }
  Level: Integer;   { 6-13 levÇes }
 End;

Var
 Players: Array[1..NUM_PLAYERS] of TPlayer;
 Deck: Array[1..MAX_CARDS] of TCard;
 CurrentTrick: Array[1..NUM_PLAYERS] of TCard;
 TrickPlayed: Array[1..NUM_PLAYERS] of Boolean;
 CurrentPlayer: Integer;
 FirstPlayer: Integer;
 TrumpSuit: Integer;
 CurrentBid: TBid;
 GamePhase: Integer; { 0=Distribution, 1=Enchäres, 2=Jeu, 3=Fin }
 TrickCount: Integer;
 SelectedCard: Integer;
 ActionMessage: String;

Function GetSuitName(Suit: Integer): String;Begin
 Case Suit of
  0: GetSuitName := 'Träfle';
  1: GetSuitName := 'Carreau';
  2: GetSuitName := 'Coeur';
  3: GetSuitName := 'Pique';
  4: GetSuitName := 'Sans Atout';
 End;
End;

Function GetValueName(Value:Integer):String;
Var
 S:String;
Begin
 Case Value of
  1: GetValueName := 'As';
  2..10: Begin
   Str(Value, S);
   GetValueName := S;
  End;
  11: GetValueName := 'Valet';
  12: GetValueName := 'Dame';
  13: GetValueName := 'Roi';
 End;
End;

Procedure InitScreen;
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
 ErrCode := GraphResult;
 If ErrCode <> grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt(1);
 End;
End;

Procedure InitDeck;
Var
 I,Suit,Value:Integer;
Begin
 I := 1;
 For Suit := 0 to 3 Do Begin
  For Value := 1 to 13 Do Begin
   Deck[I].Suit := Suit;
   Deck[I].Value := Value;
   Inc(I);
  End;
 End;
End;

Procedure ShuffleDeck;
Var
 I, J: Integer;
 Temp: TCard;
Begin
 For I := 1 to MAX_CARDS Do Begin
  J := Random(MAX_CARDS) + 1;
  Temp := Deck[I];
  Deck[I] := Deck[J];
  Deck[J] := Temp;
 End;
End;

Procedure InitPlayers;Begin
 Players[1].Name := 'Joueur Humain';
 Players[1].IsHuman := True;
 Players[2].Name := 'Ordinateur 1';
 Players[2].IsHuman := False;
 Players[3].Name := 'Ordinateur 2';
 Players[3].IsHuman := False;
 Players[4].Name := 'Ordinateur 3';
 Players[4].IsHuman := False;
End;

Procedure DealCards;
Var
 I,J,CardIndex:Integer;
Begin
 CardIndex:=1;
 For I:=1 to NUM_PLAYERS Do Begin
  Players[I].CardCount := 0;
  Players[I].Tricks := 0;
  For J := 1 to CARDS_PER_PLAYER Do Begin
   Players[I].Cards[J] := Deck[CardIndex];
   Inc(CardIndex);
   Inc(Players[I].CardCount);
  End;
 End;
End;

Procedure SortHand(PlayerIndex:Integer);
Var
 I,J:Integer;
 Temp:TCard;
Begin
 For I := 1 to Players[PlayerIndex].CardCount - 1 Do Begin
  For J := I + 1 to Players[PlayerIndex].CardCount Do Begin
   If (Players[PlayerIndex].Cards[I].Suit > Players[PlayerIndex].Cards[J].Suit) Or
      ((Players[PlayerIndex].Cards[I].Suit = Players[PlayerIndex].Cards[J].Suit) And
       (Players[PlayerIndex].Cards[I].Value > Players[PlayerIndex].Cards[J].Value)) Then Begin
    Temp := Players[PlayerIndex].Cards[I];
    Players[PlayerIndex].Cards[I] := Players[PlayerIndex].Cards[J];
    Players[PlayerIndex].Cards[J] := Temp;
   End;
  End;
 End;
End;

Procedure DrawCard(X,Y:Integer;Card:TCard;FaceUp:Boolean);
Var
 SuitColor:Integer;
 ValueStr:String;
Begin
 { Dessiner le fond de la carte }
 SetColor(Black);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + 30, Y + 45);
 Rectangle(X, Y, X + 30, Y + 45);
 If FaceUp Then Begin
  { DÇterminer la couleur de la couleur }
  If(Card.Suit = 1)Or(Card.Suit = 2)Then SuitColor:=Red
                                    Else SuitColor:=Black;
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
   { Dessiner la valeur }
  ValueStr := GetValueName(Card.Value);
  If Length(ValueStr) = 1 Then OutTextXY(X + 5, Y + 5, ValueStr)
                          Else OutTextXY(X + 2, Y + 5, ValueStr);
   { Dessiner le symbole de la couleur }
  SetColor(SuitColor);
  Case Card.Suit of
   0: Begin { Tr√®fle }
    FillEllipse(X + 15, Y + 25, 3, 3);
    FillEllipse(X + 12, Y + 22, 3, 3);
    FillEllipse(X + 18, Y + 22, 3, 3);
    Line(X + 15, Y + 28, X + 15, Y + 35);
    Line(X + 12, Y + 35, X + 18, Y + 35);
   End;
   1: Begin { Carreau }
    SetFillStyle(SolidFill, Red);
    FillEllipse(X + 15, Y + 25, 5, 3);
   End;
   2: Begin { Coeur }
    SetFillStyle(SolidFill, Red);
    FillEllipse(X + 12, Y + 22, 3, 3);
    FillEllipse(X + 18, Y + 22, 3, 3);
    Line(X + 15, Y + 32, X + 9, Y + 25);
    Line(X + 15, Y + 32, X + 21, Y + 25);
   End;
   3: Begin { Pique }
    SetFillStyle(SolidFill, Black);
    FillEllipse(X + 15, Y + 20, 5, 8);
    Line(X + 15, Y + 28, X + 15, Y + 35);
    Line(X + 12, Y + 35, X + 18, Y + 35);
   End;
  End;
 End
  Else
 Begin
  { Carte cachÇe }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(X + 2, Y + 2, X + 28, Y + 43);
  SetColor(White);
  OutTextXY(X + 12, Y + 20, '?');
 End;
End;

Procedure DrawPlayerCards(PlayerIndex:Integer);
Var
 I,StartX,StartY:Integer;
Begin
 Case PlayerIndex of
  1: Begin { Joueur humain - en bas }
   StartX := 50;
   StartY := 400;
   For I := 1 to Players[PlayerIndex].CardCount Do Begin
    If I = SelectedCard Then SetColor(Yellow)
                        Else SetColor(Black);
    DrawCard(StartX + (I - 1) * 35, StartY, Players[PlayerIndex].Cards[I], True);
   End;
  End;
  2: Begin { Ordinateur 1 - Ö gauche }
   StartX := 10;
   StartY := 50;
   For I := 1 to Players[PlayerIndex].CardCount Do Begin
    DrawCard(StartX, StartY + (I - 1) * 20, Players[PlayerIndex].Cards[I], False);
   End;
  End;
  3: Begin { Ordinateur 2 - en haut }
   StartX := 50;
   StartY := 10;
   For I := 1 to Players[PlayerIndex].CardCount Do Begin
    DrawCard(StartX + (I - 1) * 35, StartY, Players[PlayerIndex].Cards[I], False);
   End;
  End;
  4: Begin { Ordinateur 3 - Ö droite }
   StartX := 550;
   StartY := 50;
   For I := 1 to Players[PlayerIndex].CardCount Do Begin
    DrawCard(StartX, StartY + (I - 1) * 20, Players[PlayerIndex].Cards[I], False);
   End;
  End;
 End;
End;

Procedure DrawCurrentTrick;
Var
 I: Integer;
Begin
 { Dessiner les cartes jouÇes au centre }
 For I := 1 to NUM_PLAYERS Do Begin
  If TrickPlayed[I] Then Begin
   Case I of
    1: DrawCard(280, 320, CurrentTrick[I], True);
    2: DrawCard(230, 270, CurrentTrick[I], True);
    3: DrawCard(280, 220, CurrentTrick[I], True);
    4: DrawCard(330, 270, CurrentTrick[I], True);
   End;
  End;
 End;
End;

Function IntToStr(Value:Integer):String;
Var
 S: String;
Begin
 Str(Value, S);
 IntToStr := S;
End;

Procedure DrawGameInfo;
Var
 I:Integer;
 ScoreStr:String;
Begin
  { Zone d'information }
 SetColor(Black);
 SetFillStyle(SolidFill, LightGray);
 Bar(400, 10, 630, 160);
 Rectangle(400, 10, 630, 160);
  { Titre }
 SetColor(Blue);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(480, 20, 'BOSTON');
  { Information sur les enchäres }
 SetColor(Black);
 If CurrentBid.Player > 0 Then Begin
  OutTextXY(410, 40, 'Contrat: ' + Players[CurrentBid.Player].Name);
  OutTextXY(410, 55, IntToStr(CurrentBid.Level) + ' ' + GetSuitName(CurrentBid.Suit));
 End Else Begin
  OutTextXY(410, 40, 'Phase: Enchäres');
 End;
  { Atout }
 OutTextXY(410, 75, 'Atout: ' + GetSuitName(TrumpSuit));
 { Pointages }
 OutTextXY(410, 95, 'LevÇes:');
 For I := 1 to NUM_PLAYERS Do Begin
  Str(Players[I].Tricks, ScoreStr);
  OutTextXY(410, 110 + (I - 1) * 12, Players[I].Name + ': ' + ScoreStr);
 End;
End;

Procedure DrawActionMessage;Begin
 { Zone des messages }
 SetColor(Black);
 SetFillStyle(SolidFill, Yellow);
 Bar(50, 350, 630, 380);      { Agrandi de 80 pixels }
 Rectangle(50, 350, 630, 380); { Agrandi de 80 pixels }
 SetColor(Black);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(60, 360, ActionMessage);
End;

Procedure DrawBoard;
Var
 I: Integer;
Begin
  { Fond }
 SetColor(Black);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, 640, 480);
  { Dessiner les cartes de chaque joueur }
 For I := 1 to NUM_PLAYERS Do Begin
  DrawPlayerCards(I);
 End;
  { Dessiner la lev√©e en cours }
 DrawCurrentTrick;
  { Dessiner les informations }
 DrawGameInfo;
  { Dessiner le message d'action }
 DrawActionMessage;
End;

Function GetCardValue(Card:TCard):Integer;Begin
 If Card.Value = 1 Then GetCardValue := 14  { As = 14 }
                   Else GetCardValue := Card.Value;
End;

Function CompareCards(Card1,Card2:TCard;LeadSuit:Integer):Integer;
Var
 Value1,Value2:Integer;
Begin
 Value1:=GetCardValue(Card1);
 Value2:=GetCardValue(Card2);
  { Atout gagne toujours }
 If (Card1.Suit = TrumpSuit) And (Card2.Suit <> TrumpSuit) Then Begin
  CompareCards := 1;
  Exit;
 End;
 If (Card2.Suit = TrumpSuit) And (Card1.Suit <> TrumpSuit) Then Begin
  CompareCards := -1;
  Exit;
 End;
  { Couleur demandÇe gagne sur les autres }
 If (Card1.Suit = LeadSuit) And (Card2.Suit <> LeadSuit) And (Card2.Suit <> TrumpSuit) Then Begin
  CompareCards := 1;
  Exit;
 End;
 If (Card2.Suit = LeadSuit) And (Card1.Suit <> LeadSuit) And (Card1.Suit <> TrumpSuit) Then Begin
  CompareCards := -1;
  Exit;
 End;
 { Màme couleur - comparer les valeurs }
 If Card1.Suit = Card2.Suit Then Begin
  If Value1 > Value2 Then
   CompareCards := 1
  Else If Value1 < Value2 Then
   CompareCards := -1
  Else
   CompareCards := 0;
 End Else Begin
  CompareCards := 0;
 End;
End;

Function GetTrickWinner(LeadSuit: Integer): Integer;
Var
 I,Winner:Integer;
Begin
 Winner:=FirstPlayer;
 For I := 1 to NUM_PLAYERS Do Begin
  If TrickPlayed[I] Then Begin
   If CompareCards(CurrentTrick[I], CurrentTrick[Winner], LeadSuit) > 0 Then Winner:=I;
  End;
 End;
 GetTrickWinner:=Winner;
End;

Function CanPlayCard(PlayerIndex,CardIndex:Integer):Boolean;
Var
 I:Integer;
 LeadSuit:Integer;
 HasSuit:Boolean;
Begin
 { Premiäre carte de la levÇe }
 If FirstPlayer = PlayerIndex Then Begin
  CanPlayCard := True;
  Exit;
 End;
 { DÇterminer la couleur demandÇe }
 LeadSuit := CurrentTrick[FirstPlayer].Suit;
 { VÇrifier si le joueur a la couleur demandÇe }
 HasSuit := False;
 For I := 1 to Players[PlayerIndex].CardCount Do Begin
  If Players[PlayerIndex].Cards[I].Suit = LeadSuit Then Begin
   HasSuit := True;
   Break;
  End;
 End;
 { Si on a la couleur, on doit la jouer }
 If HasSuit Then CanPlayCard:=(Players[PlayerIndex].Cards[CardIndex].Suit = LeadSuit)
            Else CanPlayCard:=True;
End;

Procedure PlayCard(PlayerIndex,CardIndex:Integer);
Var
 I:Integer;
Begin
 CurrentTrick[PlayerIndex]:=Players[PlayerIndex].Cards[CardIndex];
 TrickPlayed[PlayerIndex]:=True;
  { Supprimer la carte de la main }
 For I := CardIndex to Players[PlayerIndex].CardCount - 1 Do Begin
  Players[PlayerIndex].Cards[I] := Players[PlayerIndex].Cards[I + 1];
 End;
 Dec(Players[PlayerIndex].CardCount);
  { Passer au joueur suivant }
 CurrentPlayer := (CurrentPlayer Mod NUM_PLAYERS) + 1;
End;

Function GetComputerCardChoice(PlayerIndex:Integer):Integer;
Var
 I,BestCard:Integer;
 LeadSuit:Integer;
 HasSuit:Boolean;
Begin
 BestCard:=1;
  { Si c'est le premier joueur, jouer une carte moyenne }
 If FirstPlayer = PlayerIndex Then Begin
  GetComputerCardChoice := (Players[PlayerIndex].CardCount + 1) Div 2;
  Exit;
 End;
 { DÇterminer la couleur demandÇe }
 LeadSuit := CurrentTrick[FirstPlayer].Suit;
 { VÇrifier si on a la couleur }
 HasSuit := False;
 For I := 1 to Players[PlayerIndex].CardCount Do Begin
  If Players[PlayerIndex].Cards[I].Suit = LeadSuit Then Begin
   HasSuit:=True;
   BestCard:=I;
   Break;
  End;
 End;
  { Si on n'a pas la couleur, jouer n'importe quelle carte }
 If Not HasSuit Then BestCard:=1;
 GetComputerCardChoice:=BestCard;
End;

Procedure ProcessTrick;
Var
 Winner:Integer;
 I:Integer;
Begin
 { DÇterminer le gagnant }
 Winner := GetTrickWinner(CurrentTrick[FirstPlayer].Suit);
 Inc(Players[Winner].Tricks);
 ActionMessage := Players[Winner].Name + ' remporte la levÇe!';
 { RÇinitialiser pour la prochaine levÇe }
 For I := 1 to NUM_PLAYERS Do Begin
  TrickPlayed[I] := False;
 End;
 FirstPlayer := Winner;
 CurrentPlayer := Winner;
 Inc(TrickCount);
 { VÇrifier si la partie est terminÇe }
 If TrickCount >= 13 Then Begin
  GamePhase := 3;
  ActionMessage := 'Partie terminÇe!';
 End;
End;

Procedure HandleHumanTurn;
Var
 Key:Char;
Begin
 ActionMessage := 'Votre tour : Appuyez sur 1-9 pour jouer une carte, ESC pour quitter.';
 DrawBoard;
 Key:=ReadKey;
 Case Key of
  '1'..'9': Begin
   SelectedCard := Ord(Key) - Ord('0');
   If SelectedCard <= Players[1].CardCount Then Begin
    If CanPlayCard(1, SelectedCard) Then Begin
     PlayCard(1, SelectedCard);
     ActionMessage := 'Vous avez jouÇ ' + GetValueName(CurrentTrick[1].Value) + ' de ' + GetSuitName(CurrentTrick[1].Suit);
     SelectedCard := 0;
    End Else Begin
     ActionMessage := 'Vous ne pouvez pas jouer cette carte!';
    End;
   End;
  End;
  #27: Begin { Escape }
   CloseGraph;
   Halt;
  End;
 End;
End;

Procedure HandleComputerTurn;
Var
 CardChoice: Integer;
Begin
 CardChoice := GetComputerCardChoice(CurrentPlayer);
 PlayCard(CurrentPlayer, CardChoice);
 ActionMessage := Players[CurrentPlayer].Name + ' joue ' +
                  GetValueName(CurrentTrick[CurrentPlayer].Value) + ' de ' +
                  GetSuitName(CurrentTrick[CurrentPlayer].Suit);
 { Attendre un peu }
 Delay(1500);
End;

Procedure ProcessBidding;Begin
 { Ench√®res simplifiÇes - contrat fixe pour l'exemple }
 CurrentBid.Player := 1;
 CurrentBid.Suit := Random(4);
 CurrentBid.Level := 7;
 TrumpSuit := CurrentBid.Suit;
 GamePhase := 2;
 ActionMessage := 'Contrat: ' + IntToStr(CurrentBid.Level) + ' ' + GetSuitName(CurrentBid.Suit);
End;

Procedure CheckTrickComplete;
Var
 I,PlayedCount:Integer;
Begin
 PlayedCount := 0;
 For I := 1 to NUM_PLAYERS Do Begin
  If TrickPlayed[I]Then Inc(PlayedCount);
 End;
 If PlayedCount = NUM_PLAYERS Then Begin
  Delay(2000);
  ProcessTrick;
 End;
End;

BEGIN
 Randomize;
 InitScreen;
 InitDeck;
 InitPlayers;
 GamePhase := 0;
 TrickCount := 0;
 CurrentPlayer := 1;
 FirstPlayer := 1;
 SelectedCard := 0;
 TrumpSuit := 0;
  { Initialiser les enchäres }
 CurrentBid.Player := 0;
 CurrentBid.Suit := 0;
 CurrentBid.Level := 0;
  { Initialiser les levÇes }
 FillChar(TrickPlayed, SizeOf(TrickPlayed), False);
 ActionMessage := 'Bienvenue au Boston! Appuyez sur 1-9 pour jouer une carte, ESC pour quitter';
  { Distribution des cartes }
 ShuffleDeck;
 DealCards;
  { Trier les mains }
 SortHand(1);
 SortHand(2);
 SortHand(3);
 SortHand(4);
  { Enchäres }
 ProcessBidding;
  { Boucle principale }
 Repeat
  DrawBoard;
  Case GamePhase of
   2: Begin { Phase de jeu }
    If Players[CurrentPlayer].IsHuman Then Begin
     HandleHumanTurn;
    End Else Begin
     HandleComputerTurn;
    End;
    CheckTrickComplete;
   End;
   3: Begin { Fin de partie }
    ActionMessage := 'Partie termin√©e! Appuyez sur ESC pour quitter';
    If ReadKey = #27 Then Break;
   End;
  End;
 Until False;
 CloseGraph;
END.
