{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: FreeCell - Jeu de solitaire classique
  L'objectif est de d√©placer toutes les cartes vers les 4 piles de fondation
}

Program FreeCell;

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

  { Dimensions du plateau }
 FREECELLS = 4;      { Cellules libres }
 FOUNDATIONS = 4;    { Piles de fondation }
 COLUMNS = 8;        { Colonnes du tableau }
 MAX_CARDS_IN_COLUMN = 20;

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
 GAME_PLAYING = 0;
 GAME_WON = 1;

  { Zones de clic }
 ZONE_FREECELL = 0;
 ZONE_FOUNDATION = 1;
 ZONE_COLUMN = 2;

Type
 TCard=Record
  Suit:Integer;      { Couleur: 0=Coeur, 1=Pique, 2=Carreau, 3=trefle }
  Value:Integer;     { Valeur: 1-13 }
  Visible:Boolean;   { Toujours visible dans FreeCell }
 End;

 TColumn = Record
  Cards: Array[0..19] of TCard;
  Count: Integer;
 End;

 TGameState=Record
  Deck:Array[0..51] of TCard;
  FreeCells: Array[0..3] of TCard;
  FreeCellsUsed: Array[0..3] of Boolean;
  Foundations: Array[0..3] of TCard;
  FoundationCounts: Array[0..3] of Integer;
  Columns: Array[0..7] of TColumn;
  SelectedCard: TCard;
  SelectedZone: Integer;
  SelectedIndex: Integer;
  HasSelection: Boolean;
  GameState: Integer;
  MovesCount: Integer;
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

Function IsRedSuit(Suit:Integer):Boolean;Begin
 IsRedSuit:=(Suit = HEARTS) Or (Suit = DIAMONDS);
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
 I,J:Integer;
 TempCard:TCard;
Begin
 For I:=0 to DECK_SIZE - 1 Do Begin
  J := Random(DECK_SIZE);
  TempCard := Game.Deck[I];
  Game.Deck[I] := Game.Deck[J];
  Game.Deck[J] := TempCard;
 End;
End;

Procedure InitGame;
Var
 I,J,CardIndex:Integer;
Begin
  { Initialiser les variables de jeu }
 Game.GameState := GAME_PLAYING;
 Game.HasSelection := False;
 Game.MovesCount := 0;
  { Vider les cellules libres }
 For I := 0 to FREECELLS - 1 Do Begin
  Game.FreeCellsUsed[I] := False;
 End;
  { Vider les fondations }
 For I:=0 to FOUNDATIONS - 1 Do Begin
  Game.FoundationCounts[I] := 0;
 End;
  { Vider les colonnes }
 For I := 0 to COLUMNS - 1 Do Begin
  Game.Columns[I].Count := 0;
 End;
  { Distribuer les cartes dans les colonnes }
 InitDeck;
 ShuffleDeck;
 CardIndex := 0;
 For I := 0 to COLUMNS - 1 Do Begin
   { Les 4 premiäres colonnes ont 7 cartes, les 4 suivantes ont 6 cartes }
  If I < 4 Then Begin
   For J := 0 to 6 Do Begin
    Game.Columns[I].Cards[J] := Game.Deck[CardIndex];
    Inc(CardIndex);
   End;
   Game.Columns[I].Count := 7;
  End
   Else
  Begin
   For J:=0 to 5 Do Begin
    Game.Columns[I].Cards[J] := Game.Deck[CardIndex];
    Inc(CardIndex);
   End;
   Game.Columns[I].Count := 6;
  End;
 End;
 NeedRedraw := True;
End;

Procedure DrawCard(X, Y: Integer; Card: TCard; Highlighted: Boolean);
Var
 CardName: String;
 SuitSymbol: String;
 SuitColor: Integer;
Begin
  { Fond de la carte }
 If Highlighted Then SetColor(Yellow)
                Else SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
  { Bordure }
 If Highlighted Then SetColor(Yellow)
                Else SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y+CARD_HEIGHT);
 If Card.Value > 0 Then Begin
   { Afficher la carte }
  CardName := GetCardName(Card);
  SuitSymbol := GetSuitSymbol(Card.Suit);
  SuitColor := GetSuitColor(Card.Suit);
   { Valeur en haut √† gauche }
  SetColor(SuitColor);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 3, Y + 3, CardName);
  OutTextXY(X + 3, Y + 13, SuitSymbol);
   { Valeur en bas √† droite (invers√©e) }
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 25, CardName);
  OutTextXY(X + CARD_WIDTH - 15, Y + CARD_HEIGHT - 15, SuitSymbol);
   { Symbole au centre }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(X + CARD_WIDTH Div 2 - 8, Y + CARD_HEIGHT Div 2 - 8, SuitSymbol);
 End;
End;

Procedure DrawEmptySlot(X,Y:Integer; Highlighted: Boolean);Begin
 If Highlighted Then SetColor(Yellow)
                Else SetColor(DarkGray);
 SetFillStyle(SolidFill, DarkGray);
 Bar(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
 If Highlighted Then SetColor(Yellow)
                Else SetColor(Black);
 Rectangle(X, Y, X + CARD_WIDTH, Y + CARD_HEIGHT);
End;

Procedure DrawFreeCells;
Var
 I,X:Integer;
 IsHighlighted:Boolean;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(10, 10, 'Cellules libres:');
 For I := 0 to FREECELLS - 1 Do Begin
  X := 10 + I * (CARD_WIDTH + 5);
  IsHighlighted := Game.HasSelection And (Game.SelectedZone = ZONE_FREECELL) And (Game.SelectedIndex = I);
  If Game.FreeCellsUsed[I]Then DrawCard(X, 30, Game.FreeCells[I], IsHighlighted)
                          Else DrawEmptySlot(X, 30, IsHighlighted);
 End;
End;

Procedure DrawFoundations;
Var
 I, X: Integer;
 IsHighlighted: Boolean;
 TopCard: TCard;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(350, 10, 'Fondations:');
 For I := 0 to FOUNDATIONS - 1 Do Begin
  X := 350 + I * (CARD_WIDTH + 5);
  IsHighlighted := Game.HasSelection And (Game.SelectedZone = ZONE_FOUNDATION) And (Game.SelectedIndex = I);
  If Game.FoundationCounts[I] > 0 Then Begin
   TopCard := Game.Foundations[I];
   DrawCard(X, 30, TopCard, IsHighlighted);
  End
   Else
  Begin
   DrawEmptySlot(X, 30, IsHighlighted);
  End;
 End;
End;

Procedure DrawColumns;
Var
 I, J, X, Y: Integer;
 IsHighlighted: Boolean;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(10, 120, 'Colonnes:');
 For I := 0 to COLUMNS - 1 Do Begin
  X := 10 + I * (CARD_WIDTH + 5);
  If Game.Columns[I].Count = 0 Then Begin
    { Colonne vide }
   IsHighlighted := Game.HasSelection And (Game.SelectedZone = ZONE_COLUMN) And (Game.SelectedIndex = I);
   DrawEmptySlot(X, 140, IsHighlighted);
  End
   Else
  Begin
    { Dessiner les cartes de la colonne }
   For J := 0 to Game.Columns[I].Count - 1 Do Begin
    Y := 140 + J * 20;
    IsHighlighted := Game.HasSelection And (Game.SelectedZone = ZONE_COLUMN) And
                     (Game.SelectedIndex = I) And (J = Game.Columns[I].Count - 1);
    DrawCard(X, Y, Game.Columns[I].Cards[J], IsHighlighted);
   End;
  End;
 End;
End;

Procedure DrawGameInfo;Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(10, 450, 'Mouvements: ' + Chr(Ord('0') + (Game.MovesCount Mod 10)));
 If Game.GameState = GAME_WON Then Begin
  SetColor(Green);
  OutTextXY(200, 450, 'FELICITATIONS! Vous avez gagne!');
 End;
  { Instructions }
 SetColor(LightGray);
 OutTextXY(400, 400, 'Instructions:');
 OutTextXY(400, 415, 'Clic - Selectionner/Deplacer');
 OutTextXY(400, 430, 'R - Nouvelle partie');
 OutTextXY(400, 445, 'ESC - Quitter');
End;

Procedure DrawBackground;Begin
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(150, 5, 'FREECELL');
End;

Procedure DrawScreen;Begin
 DrawBackground;
 DrawFreeCells;
 DrawFoundations;
 DrawColumns;
 DrawGameInfo;
End;

Function CanMoveToFoundation(Card:TCard;FoundationIndex:Integer):Boolean;Begin
 CanMoveToFoundation := False;
  { VÇrifier si la fondation correspond Ö la couleur }
 If FoundationIndex <> Card.Suit Then Exit;
  { VÇrifier si c'est la prochaine carte dans la sÇquence }
 If Game.FoundationCounts[FoundationIndex] = 0 Then Begin
   { Premiäre carte doit àtre un As }
  CanMoveToFoundation := (Card.Value = ACE);
 End
  Else
 Begin
   { Doit àtre la carte suivante }
  CanMoveToFoundation := (Card.Value = Game.Foundations[FoundationIndex].Value + 1);
 End;
End;

Function CanMoveToColumn(Card:TCard;ColumnIndex:Integer):Boolean;
Var
 TopCard:TCard;
Begin
 CanMoveToColumn := False;
 If Game.Columns[ColumnIndex].Count = 0 Then Begin
   { Colonne vide - toute carte peut àtre placÇe }
  CanMoveToColumn := True;
 End
  Else
 Begin
   { Doit àtre une carte de valeur infÇrieure et de couleur opposÇe }
  TopCard := Game.Columns[ColumnIndex].Cards[Game.Columns[ColumnIndex].Count - 1];
  If (Card.Value = TopCard.Value - 1) And (IsRedSuit(Card.Suit) <> IsRedSuit(TopCard.Suit)) Then
   CanMoveToColumn := True;
 End;
End;

Function GetClickZone(X,Y:Integer;Var Zone,Index:Integer):Boolean;
Var
 I, CardX, CardY: Integer;
Begin
 GetClickZone := False;
  { VÇrifier les cellules libres }
 For I := 0 to FREECELLS - 1 Do Begin
  CardX := 10 + I * (CARD_WIDTH + 5);
  If (X >= CardX) And (X <= CardX + CARD_WIDTH) And (Y >= 30) And (Y <= 30 + CARD_HEIGHT) Then Begin
   Zone := ZONE_FREECELL;
   Index := I;
   GetClickZone := True;
   Exit;
  End;
 End;
  { VÇrifier les fondations }
 For I := 0 to FOUNDATIONS - 1 Do Begin
  CardX := 350 + I * (CARD_WIDTH + 5);
  If (X >= CardX) And (X <= CardX + CARD_WIDTH) And (Y >= 30) And (Y <= 30 + CARD_HEIGHT) Then Begin
   Zone := ZONE_FOUNDATION;
   Index := I;
   GetClickZone := True;
   Exit;
  End;
 End;
  { VÇrifier les colonnes }
  For I := 0 to COLUMNS - 1 Do Begin
   CardX := 10 + I * (CARD_WIDTH + 5);
   If (X >= CardX) And (X <= CardX + CARD_WIDTH) And (Y >= 140) Then Begin
    Zone := ZONE_COLUMN;
    Index := I;
    GetClickZone := True;
    Exit;
   End;
  End;
End;

Procedure MoveCardToFoundation(Card: TCard; FoundationIndex: Integer);Begin
 Game.Foundations[FoundationIndex] := Card;
 Inc(Game.FoundationCounts[FoundationIndex]);
 Inc(Game.MovesCount);
End;

Procedure MoveCardToColumn(Card: TCard; ColumnIndex: Integer);Begin
 Game.Columns[ColumnIndex].Cards[Game.Columns[ColumnIndex].Count] := Card;
 Inc(Game.Columns[ColumnIndex].Count);
 Inc(Game.MovesCount);
End;

Procedure MoveCardToFreeCell(Card: TCard; FreeCellIndex: Integer);Begin
 Game.FreeCells[FreeCellIndex] := Card;
 Game.FreeCellsUsed[FreeCellIndex] := True;
 Inc(Game.MovesCount);
End;

Procedure RemoveCardFromColumn(ColumnIndex: Integer);Begin
 If Game.Columns[ColumnIndex].Count > 0 Then Dec(Game.Columns[ColumnIndex].Count);
End;

Procedure RemoveCardFromFreeCell(FreeCellIndex: Integer);Begin
 Game.FreeCellsUsed[FreeCellIndex] := False;
End;

Procedure HandleCardSelection(Zone,Index:Integer);
Var
 Card:TCard;
Begin
 If Not Game.HasSelection Then Begin
   { SÇlectionner une carte }
  Case Zone of
   ZONE_FREECELL:Begin
    If Game.FreeCellsUsed[Index] Then Begin
     Game.SelectedCard := Game.FreeCells[Index];
     Game.SelectedZone := Zone;
     Game.SelectedIndex := Index;
     Game.HasSelection := True;
    End;
   End;
   ZONE_COLUMN: Begin
    If Game.Columns[Index].Count > 0 Then Begin
     Game.SelectedCard := Game.Columns[Index].Cards[Game.Columns[Index].Count - 1];
     Game.SelectedZone := Zone;
     Game.SelectedIndex := Index;
     Game.HasSelection := True;
    End;
   End;
  End;
 End
  Else
 Begin
   { DÇplacer la carte sÇlectionnÇe }
  Case Zone of
   ZONE_FREECELL:Begin
    If Not Game.FreeCellsUsed[Index] Then Begin
      { DÇplacer vers cellule libre }
     MoveCardToFreeCell(Game.SelectedCard,Index);
      { Retirer la carte de sa position originale }
     Case Game.SelectedZone of
      ZONE_FREECELL: RemoveCardFromFreeCell(Game.SelectedIndex);
      ZONE_COLUMN: RemoveCardFromColumn(Game.SelectedIndex);
     End;
     Game.HasSelection := False;
    End;
   End;
   ZONE_FOUNDATION:Begin
    If CanMoveToFoundation(Game.SelectedCard, Index) Then Begin
      { DÇplacer vers fondation }
     MoveCardToFoundation(Game.SelectedCard, Index);
      { Retirer la carte de sa position originale }
     Case Game.SelectedZone of
      ZONE_FREECELL: RemoveCardFromFreeCell(Game.SelectedIndex);
      ZONE_COLUMN: RemoveCardFromColumn(Game.SelectedIndex);
     End;
     Game.HasSelection := False;
    End;
   End;
   ZONE_COLUMN:Begin
    If CanMoveToColumn(Game.SelectedCard,Index)Then Begin
      { DÇplacer vers colonne }
     MoveCardToColumn(Game.SelectedCard, Index);
      { Retirer la carte de sa position originale }
     Case Game.SelectedZone of
      ZONE_FREECELL: RemoveCardFromFreeCell(Game.SelectedIndex);
      ZONE_COLUMN: RemoveCardFromColumn(Game.SelectedIndex);
     End;
     Game.HasSelection := False;
    End;
   End;
  End;
 End;
 NeedRedraw := True;
End;

Procedure HandleMouseClick(X,Y:Integer);
Var
 Zone, Index: Integer;
Begin
 If GetClickZone(X, Y, Zone, Index) Then Begin
  HandleCardSelection(Zone, Index);
 End
  Else
 Begin
   { Clic dans le vide - annuler la s√©lection }
  Game.HasSelection := False;
  NeedRedraw := True;
 End;
End;

Procedure CheckGameWon;
Var
I: Integer;
Begin
 For I := 0 to FOUNDATIONS - 1 Do Begin
  If Game.FoundationCounts[I] <> 13 Then Exit;
 End;
 Game.GameState := GAME_WON;
 Game.HasSelection := False;
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
   'r', 'R': Begin
    InitGame;
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
  If Game.GameState = GAME_PLAYING Then CheckGameWon;
  Delay(50);
 Until False;
END.
