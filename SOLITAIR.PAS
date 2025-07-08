{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Solitaire Klondike avec controles clavier complets
}

Program Solitaire;

Uses
{$IFDEF FPC}
  Windows, Crt, PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS,Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH=640;
 SCREEN_HEIGHT=480;
 CARD_WIDTH=50;
 CARD_HEIGHT=70;
 CARD_SPACING=60;
 CARD_OVERLAP=20;

 DECK_X=50;
 DECK_Y=50;
 WASTE_X=120;
 WASTE_Y=50;

 FOUNDATION_START_X = 300;
 FOUNDATION_Y = 50;

 TABLEAU_START_X = 50;
 TABLEAU_Y = 150;

 MAX_CARDS = 52;
 MAX_TABLEAU_CARDS = 25;

Type
 TSuit=(Hearts,Diamonds,Clubs,Spades);
 TRank=(Ace,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Jack,Queen,King);

 TCard=Record
  suit:TSuit;
  rank:TRank;
  faceUp:Boolean;
  visible:Boolean;
 End;

 TCardStack=Record
  cards:Array[1..MAX_CARDS] of TCard;
  count:Integer;
  End;

  TTableauColumn=Record
   cards:Array[1..MAX_TABLEAU_CARDS] of TCard;
   count:Integer;
  End;

 TGameState=Record
  deck:TCardStack;
  waste:TCardStack;
  foundations:Array[1..4] of TCardStack;
  tableau:Array[1..7] of TTableauColumn;
  score:Integer;
  moves:Integer;
  gameWon:Boolean;
 End;

 TSelection=Record
  sourceType:Integer; { 0=aucun, 1=defausse, 2=fondation, 3=tableau }
  sourceIndex:Integer;
  cardIndex:Integer;
  active:Boolean;
 End;

 TCursor=Record
  areaType:Integer;    { 0=paquet, 1=defausse, 2=fondation, 3=tableau }
  areaIndex:Integer;   { Index dans la zone (1-4 pour fondation, 1-7 pour tableau) }
  cardIndex:Integer;   { Index de la carte dans la colonne }
 End;

Var
 GraphDriver,GraphMode:Integer;
 Game:TGameState;
 Selection:TSelection;
 Cursor:TCursor;
 NeedRedraw:Boolean;

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
 GetCardValue:=Ord(rank)+1;
End;

Function IsRed(suit:TSuit):Boolean;Begin
 IsRed:=(suit=Hearts)or(suit=Diamonds);
End;

Function IsBlack(suit:TSuit):Boolean;Begin
 IsBlack:=(suit=Clubs)or(suit=Spades);
End;

Function CanPlaceOnFoundation(card:TCard;foundationIndex:Integer):Boolean;Begin
 With Game.foundations[foundationIndex] do Begin
  If count = 0 then
   CanPlaceOnFoundation:=(card.rank = Ace)
  Else
   CanPlaceOnFoundation:=(card.suit = cards[count].suit) and(GetCardValue(card.rank) = GetCardValue(cards[count].rank) + 1);
 End;
End;

Function CanPlaceOnTableau(card:TCard;tableauIndex:Integer):Boolean;Begin
 With Game.tableau[tableauIndex] do Begin
  If count = 0 then
   CanPlaceOnTableau := (card.rank = King)
  Else
   CanPlaceOnTableau := (IsRed(card.suit) <> IsRed(cards[count].suit)) and
                        (GetCardValue(card.rank) = GetCardValue(cards[count].rank) - 1);
  End;
End;

Function GetSequenceStart(columnIndex,cardIndex:Integer):Integer;
Var
 i:Integer;
Begin
 GetSequenceStart := cardIndex;
  { Chercher le début de la séquence déplaçable }
 For i := cardIndex - 1 downto 1 do Begin
    { Arrêter si la carte n'est pas face visible }
  If Not Game.tableau[columnIndex].cards[i].faceUp Then Break;
   { Arrêter si la séquence n'est pas valide }
  If (GetCardValue(Game.tableau[columnIndex].cards[i].rank) <>
      GetCardValue(Game.tableau[columnIndex].cards[i + 1].rank) + 1) or
     (IsRed(Game.tableau[columnIndex].cards[i].suit) =
      IsRed(Game.tableau[columnIndex].cards[i + 1].suit))Then Break;

  GetSequenceStart := i;
 End;
End;

Function CanMoveSequence(sourceIndex,startCard:Integer):Boolean;
Var
 i:Integer;
Begin
 CanMoveSequence := True;
  { Vérifier que toutes les cartes de la séquence sont face visible }
 For i:=startCard to Game.tableau[sourceIndex].count do Begin
  If Not Game.tableau[sourceIndex].cards[i].faceUp Then Begin
   CanMoveSequence:=False;
   Exit;
  End;
 End;
  { Vérifier que la séquence est bien ordonnée (décroissante et alternée) }
 For i:=startCard to Game.tableau[sourceIndex].count - 1 do Begin
  If (GetCardValue(Game.tableau[sourceIndex].cards[i].rank) <>
      GetCardValue(Game.tableau[sourceIndex].cards[i + 1].rank) + 1) or
     (IsRed(Game.tableau[sourceIndex].cards[i].suit) =
      IsRed(Game.tableau[sourceIndex].cards[i + 1].suit))Then Begin
   CanMoveSequence := False;
   Exit;
  End;
 End;
End;

Procedure InitializeGraphics;
Var
 Driver,Mode:Integer;
 ErrCode:Integer;
Begin
 {$IFDEF FPC}
   Driver := VGA;
   Mode := VGAHi;
 {$ELSE}
   Driver := Detect;
   Mode := VGAHi;
 {$ENDIF}
 InitGraph(Driver, Mode, '');
 ErrCode:=GraphResult;
 If ErrCode = grOk Then Begin
  SetColor(15); { White }
  SetLineStyle(0, 0, 1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure InitializeDeck;
Var
 i,j,k:Integer;
 temp:TCard;
Begin
  { Créer le deck de 52 cartes }
 k := 1;
 For i := 0 to 3 do For j := 0 to 12 do Begin
  With Game.deck.cards[k] do Begin
   suit := TSuit(i);
   rank := TRank(j);
   faceUp := False;
   visible := True;
  End;
  Inc(k);
 End;
 Game.deck.count:=52;
  { Mélanger le deck }
 For i := 1 to 52 do Begin
  j:=Random(52)+1;
  temp := Game.deck.cards[i];
  Game.deck.cards[i] := Game.deck.cards[j];
  Game.deck.cards[j] := temp;
 End;
End;

Procedure InitializeGame;
Var
  i,j,cardIndex:Integer;
Begin
  { Initialiser les structures }
 Game.waste.count:=0;
 For i:=1 to 4 do Game.foundations[i].count := 0;
 For i:=1 to 7 do Game.tableau[i].count := 0;
 Game.score:=0;
 Game.moves:=0;
 Game.gameWon:=False;
 Selection.active:=False;
 Selection.sourceType := 0;

  { Initialiser le curseur }
  Cursor.areaType := 0;
  Cursor.areaIndex := 1;
  Cursor.cardIndex := 1;

  { Initialiser le deck }
  InitializeDeck;

  { Distribuer les cartes sur le tableau }
  cardIndex := 1;
  For i := 1 to 7 do
    For j := 1 to i do
    Begin
      With Game.tableau[i] do
      Begin
        Inc(count);
        cards[count] := Game.deck.cards[cardIndex];
        cards[count].faceUp := (j = i); { Seule la dernière carte est face visible }
        Inc(cardIndex);
      End;
    End;

  { Ajuster le deck }
  For i := cardIndex to 52 do
    Game.deck.cards[i - cardIndex + 1] := Game.deck.cards[i];
  Game.deck.count := 52 - cardIndex + 1;
End;

Procedure DrawCard(x, y: Integer; card: TCard; selected: Boolean);
Var
  suitChar: Char;
  rankStr: String;
  color: Integer;
Begin
  { Fond de la carte }
  If selected then
    SetColor(14) { Yellow }
  Else
    SetColor(15); { White }
  SetFillStyle(1, GetColor); { SolidFill }
  Bar(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);

  { Bordure }
  SetColor(0); { Black }
  Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);

  If card.faceUp then
  Begin
    { Déterminer la couleur }
    If IsRed(card.suit) then
      color := 4 { Red }
    Else
      color := 0; { Black }

    { Symbole de la suite }
    Case card.suit of
      Hearts: suitChar := #3;
      Diamonds: suitChar := #4;
      Clubs: suitChar := #5;
      Spades: suitChar := #6;
    End;

    { Rang de la carte }
    Case card.rank of
      Ace: rankStr := 'A';
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
    End;

    { Dessiner le rang et la suite }
    SetColor(color);
    SetTextStyle(0, 0, 1); { DefaultFont, HorizDir, size 1 }
    OutTextXY(x + 3, y + 3, rankStr);
    OutTextXY(x + 3, y + 15, suitChar);

    { Symbole central pour les figures }
    If card.rank >= Jack then
    Begin
      SetTextStyle(0, 0, 2); { DefaultFont, HorizDir, size 2 }
      OutTextXY(x + CARD_WIDTH div 2 - 5, y + CARD_HEIGHT div 2 - 5, rankStr);
    End
    Else
    Begin
      SetTextStyle(0, 0, 3); { DefaultFont, HorizDir, size 3 }
      OutTextXY(x + CARD_WIDTH div 2 - 8, y + CARD_HEIGHT div 2 - 8, suitChar);
    End;
  End
  Else
  Begin
    { Dos de carte }
    SetColor(1); { Blue }
    SetFillStyle(1, 1); { SolidFill, Blue }
    Bar(x + 3, y + 3, x + CARD_WIDTH - 3, y + CARD_HEIGHT - 3);
    SetColor(15); { White }
    Rectangle(x + 6, y + 6, x + CARD_WIDTH - 6, y + CARD_HEIGHT - 6);
  End;
End;

Procedure DrawEmptySlot(x, y: Integer);
Begin
  SetColor(8); { DarkGray }
  SetFillStyle(1, 8); { SolidFill, DarkGray }
  Bar(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
  SetColor(7); { LightGray }
  Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);
End;

Procedure GetCursorPosition(var x, y: Integer);
Begin
  Case Cursor.areaType of
    0: Begin { Paquet }
      x := DECK_X;
      y := DECK_Y;
    End;
    1: Begin { Defausse }
      x := WASTE_X;
      y := WASTE_Y;
    End;
    2: Begin { Fondation }
      x := FOUNDATION_START_X + (Cursor.areaIndex - 1) * CARD_SPACING;
      y := FOUNDATION_Y;
    End;
    3: Begin { Tableau }
      x := TABLEAU_START_X + (Cursor.areaIndex - 1) * CARD_SPACING;
      If Game.tableau[Cursor.areaIndex].count > 0 then
        y := TABLEAU_Y + (Cursor.cardIndex - 1) * CARD_OVERLAP
      Else
        y := TABLEAU_Y;
    End;
  End;
End;

Procedure DrawCursor;
Var
  x, y: Integer;
Begin
  GetCursorPosition(x, y);
  { Dessiner le curseur autour de la zone sélectionnée }
  SetColor(11); { Cyan }
  SetLineStyle(0, 0, 3);
  Rectangle(x - 2, y - 2, x + CARD_WIDTH + 2, y + CARD_HEIGHT + 2);
  SetLineStyle(0, 0, 1);
End;

Procedure DrawDeck;
Begin
  If Game.deck.count > 0 then
    DrawCard(DECK_X, DECK_Y, Game.deck.cards[Game.deck.count], False)
  Else
    DrawEmptySlot(DECK_X, DECK_Y);
End;

Procedure DrawWaste;
Begin
  If Game.waste.count > 0 then
    DrawCard(WASTE_X, WASTE_Y, Game.waste.cards[Game.waste.count],
             Selection.active and (Selection.sourceType = 1))
  Else
    DrawEmptySlot(WASTE_X, WASTE_Y);
End;

Procedure DrawFoundations;
Var
  i: Integer;
Begin
  For i := 1 to 4 do
  Begin
    If Game.foundations[i].count > 0 then
      DrawCard(FOUNDATION_START_X + (i - 1) * CARD_SPACING, FOUNDATION_Y,
               Game.foundations[i].cards[Game.foundations[i].count],
               Selection.active and (Selection.sourceType = 2) and (Selection.sourceIndex = i))
    Else
      DrawEmptySlot(FOUNDATION_START_X + (i - 1) * CARD_SPACING, FOUNDATION_Y);
  End;
End;

Procedure DrawTableau;
Var
  i, j: Integer;
  x, y: Integer;
  selected: Boolean;
Begin
  For i := 1 to 7 do
  Begin
    x := TABLEAU_START_X + (i - 1) * CARD_SPACING;

    If Game.tableau[i].count = 0 then
      DrawEmptySlot(x, TABLEAU_Y)
    Else
      For j := 1 to Game.tableau[i].count do
      Begin
        y := TABLEAU_Y + (j - 1) * CARD_OVERLAP;
        { Mettre en surbrillance toute la séquence si elle est sélectionnée }
        selected := Selection.active and (Selection.sourceType = 3) and
                   (Selection.sourceIndex = i) and (j >= Selection.cardIndex);
        DrawCard(x, y, Game.tableau[i].cards[j], selected);
      End;
  End;
End;

Procedure DrawHUD;
Var
  s: String;
Begin
  { Pointage }
  SetColor(15); { Blanc }
  SetTextStyle(0, 0, 2); { DefaultFont, HorizDir, size 2 }
  Str(Game.score, s);
  OutTextXY(10, 10, 'Points : ' + s);

  { Moves }
  Str(Game.moves, s);
  OutTextXY(200, 10, 'Coups : ' + s);

  { Instructions }
  SetTextStyle(0, 0, 1); { DefaultFont, HorizDir, size 1 }
  OutTextXY(10, SCREEN_HEIGHT - 110, 'Fleches: Deplacer curseur');
  OutTextXY(10, SCREEN_HEIGHT - 95, 'ESPACE: Selectionner/Deplacer');
  OutTextXY(10, SCREEN_HEIGHT - 80, 'D: Retourner paquet');
  OutTextXY(10, SCREEN_HEIGHT - 65, 'F: Retourner carte tableau');
  OutTextXY(10, SCREEN_HEIGHT - 50, 'A: Deplacement auto fondations');
  OutTextXY(10, SCREEN_HEIGHT - 35, 'R: Recommencer, ESC: Quitter');
  OutTextXY(10, SCREEN_HEIGHT - 20, 'Sequences auto-selectionnees');
End;

Procedure DrawWinMessage;
Begin
  SetColor(14); { Yellow }
  SetFillStyle(1, 14); { SolidFill, Yellow }
  Bar(SCREEN_WIDTH div 2 - 100, SCREEN_HEIGHT div 2 - 30,
      SCREEN_WIDTH div 2 + 100, SCREEN_HEIGHT div 2 + 30);

  SetColor(4); { Red }
  Rectangle(SCREEN_WIDTH div 2 - 100, SCREEN_HEIGHT div 2 - 30,
            SCREEN_WIDTH div 2 + 100, SCREEN_HEIGHT div 2 + 30);

  SetColor(0); { Black }
  SetTextStyle(0, 0, 2); { DefaultFont, HorizDir, size 2 }
  OutTextXY(SCREEN_WIDTH div 2 - 80, SCREEN_HEIGHT div 2 - 15, 'VICTOIRE !');

  SetTextStyle(0, 0, 1); { DefaultFont, HorizDir, size 1 }
  OutTextXY(SCREEN_WIDTH div 2 - 80, SCREEN_HEIGHT div 2 + 5, 'Appuyez R pour rejouer');
End;

Procedure FlipDeckCard;
Begin
  If Game.deck.count > 0 then
  Begin
    { Déplacer la carte du deck vers la waste }
    Inc(Game.waste.count);
    Game.waste.cards[Game.waste.count] := Game.deck.cards[Game.deck.count];
    Game.waste.cards[Game.waste.count].faceUp := True;
    Dec(Game.deck.count);
  End
  Else If Game.waste.count > 0 then
  Begin
    { Remettre toutes les cartes de la waste dans le deck }
    While Game.waste.count > 0 do
    Begin
      Inc(Game.deck.count);
      Game.deck.cards[Game.deck.count] := Game.waste.cards[Game.waste.count];
      Game.deck.cards[Game.deck.count].faceUp := False;
      Dec(Game.waste.count);
    End;
  End;
  NeedRedraw := True;
End;

Procedure MoveCard(sourceType, sourceIndex, cardIndex, destType, destIndex: Integer);
Var
  card: TCard;
  i: Integer;
Begin
  { Prendre la carte source }
  Case sourceType of
    1: card := Game.waste.cards[Game.waste.count];
    2: card := Game.foundations[sourceIndex].cards[Game.foundations[sourceIndex].count];
    3: card := Game.tableau[sourceIndex].cards[cardIndex];
  End;

  { Placer la carte à destination }
  Case destType of
    2: Begin { Foundation }
      Inc(Game.foundations[destIndex].count);
      Game.foundations[destIndex].cards[Game.foundations[destIndex].count] := card;
      Inc(Game.score, 10);
    End;
    3: Begin { Tableau }
      Inc(Game.tableau[destIndex].count);
      Game.tableau[destIndex].cards[Game.tableau[destIndex].count] := card;
      If sourceType = 2 then Dec(Game.score, 15); { Pénalité pour retirer de foundation }
    End;
  End;

  { Supprimer la carte source }
  Case sourceType of
    1: Dec(Game.waste.count);
    2: Dec(Game.foundations[sourceIndex].count);
    3: Begin
      { Supprimer la carte du tableau }
      For i := cardIndex to Game.tableau[sourceIndex].count - 1 do
        Game.tableau[sourceIndex].cards[i] := Game.tableau[sourceIndex].cards[i + 1];
      Dec(Game.tableau[sourceIndex].count);

      { Retourner la carte qui devient visible si elle existe et est face cachée }
      If (Game.tableau[sourceIndex].count > 0) and
         (cardIndex <= Game.tableau[sourceIndex].count) and
         (not Game.tableau[sourceIndex].cards[cardIndex].faceUp) then
        Game.tableau[sourceIndex].cards[cardIndex].faceUp := True
      Else If (Game.tableau[sourceIndex].count > 0) and
              (cardIndex > Game.tableau[sourceIndex].count) and
              (not Game.tableau[sourceIndex].cards[Game.tableau[sourceIndex].count].faceUp) then
        Game.tableau[sourceIndex].cards[Game.tableau[sourceIndex].count].faceUp := True;
    End;
  End;

  Inc(Game.moves);
  NeedRedraw := True;
End;

Procedure MoveSequence(sourceIndex, startCard, destIndex: Integer);
Var
  i, sequenceLength: Integer;
  tempCards: array[1..MAX_TABLEAU_CARDS] of TCard;
Begin
  { Calculer la longueur de la séquence }
  sequenceLength := Game.tableau[sourceIndex].count - startCard + 1;

  { Copier la séquence dans un tableau temporaire }
  For i := 1 to sequenceLength do
    tempCards[i] := Game.tableau[sourceIndex].cards[startCard + i - 1];

  { Supprimer la séquence de la source }
  Game.tableau[sourceIndex].count := startCard - 1;

  { Retourner la carte qui devient visible si elle existe et est face cachée }
  If (Game.tableau[sourceIndex].count > 0) and
     (not Game.tableau[sourceIndex].cards[Game.tableau[sourceIndex].count].faceUp) then
    Game.tableau[sourceIndex].cards[Game.tableau[sourceIndex].count].faceUp := True;

  { Ajouter la séquence à la destination }
  For i := 1 to sequenceLength do
  Begin
    Inc(Game.tableau[destIndex].count);
    Game.tableau[destIndex].cards[Game.tableau[destIndex].count] := tempCards[i];
  End;

  Inc(Game.moves);
  NeedRedraw := True;
End;

Procedure MoveCursor(direction: Integer);
Begin
  Case direction of
    1: Begin { Gauche }
      Case Cursor.areaType of
        1: Cursor.areaType := 0; { Waste -> Deck }
        2: Begin { Foundation }
          If Cursor.areaIndex > 1 then
            Dec(Cursor.areaIndex)
          Else
          Begin
            Cursor.areaType := 1; { -> Waste }
            Cursor.areaIndex := 1;
          End;
        End;
        3: Begin { Tableau }
          If Cursor.areaIndex > 1 then
          Begin
            Dec(Cursor.areaIndex);
            If Game.tableau[Cursor.areaIndex].count > 0 then
              Cursor.cardIndex := Game.tableau[Cursor.areaIndex].count
            Else
              Cursor.cardIndex := 1;
          End
          Else
          Begin
            Cursor.areaType := 2; { -> Foundation }
            Cursor.areaIndex := 4;
          End;
        End;
      End;
    End;
    2: Begin { Droite }
      Case Cursor.areaType of
        0: Begin { Deck -> Waste }
          Cursor.areaType := 1;
          Cursor.areaIndex := 1;
        End;
        1: Begin { Waste -> Foundation }
          Cursor.areaType := 2;
          Cursor.areaIndex := 1;
        End;
        2: Begin { Foundation }
          If Cursor.areaIndex < 4 then
            Inc(Cursor.areaIndex)
          Else
          Begin
            Cursor.areaType := 3; { -> Tableau }
            Cursor.areaIndex := 1;
            If Game.tableau[1].count > 0 then
              Cursor.cardIndex := Game.tableau[1].count
            Else
              Cursor.cardIndex := 1;
          End;
        End;
        3: Begin { Tableau }
          If Cursor.areaIndex < 7 then
          Begin
            Inc(Cursor.areaIndex);
            If Game.tableau[Cursor.areaIndex].count > 0 then
              Cursor.cardIndex := Game.tableau[Cursor.areaIndex].count
            Else
              Cursor.cardIndex := 1;
          End;
        End;
      End;
    End;
    3: Begin { Haut }
      Case Cursor.areaType of
        3: Begin { Tableau }
          If Cursor.cardIndex > 1 then
          Begin
            Dec(Cursor.cardIndex);
            { Permettre de naviguer sur toutes les cartes, même cachées }
          End;
        End;
        Else
        Begin
          Cursor.areaType := 2; { -> Foundation }
          If Cursor.areaType = 0 then
            Cursor.areaIndex := 1
          Else If Cursor.areaType = 1 then
            Cursor.areaIndex := 1
          Else
            Cursor.areaIndex := 1;
        End;
      End;
    End;
    4: Begin { Bas }
      Case Cursor.areaType of
        0, 1, 2: Begin { Deck/Waste/Foundation -> Tableau }
          Cursor.areaType := 3;
          Case Cursor.areaType of
            0: Cursor.areaIndex := 1;
            1: Cursor.areaIndex := 1;
            2: Cursor.areaIndex := Cursor.areaIndex;
          End;
          If Game.tableau[Cursor.areaIndex].count > 0 then
            Cursor.cardIndex := Game.tableau[Cursor.areaIndex].count
          Else
            Cursor.cardIndex := 1;
        End;
        3: Begin { Tableau }
          If (Cursor.cardIndex < Game.tableau[Cursor.areaIndex].count) then
            Inc(Cursor.cardIndex);
        End;
      End;
    End;
  End;
  NeedRedraw := True;
End;

Procedure FlipTableauCard;
Var
  columnIndex: Integer;
Begin
  { Vérifier si on est sur le tableau }
  If Cursor.areaType = 3 then
  Begin
    columnIndex := Cursor.areaIndex;

    { Vérifier s'il y a des cartes dans cette colonne }
    If Game.tableau[columnIndex].count > 0 then
    Begin
      { Si on est sur une carte cachée, la retourner }
      If (Cursor.cardIndex <= Game.tableau[columnIndex].count) and
         (not Game.tableau[columnIndex].cards[Cursor.cardIndex].faceUp) then
      Begin
        Game.tableau[columnIndex].cards[Cursor.cardIndex].faceUp := True;
        NeedRedraw := True;
        Inc(Game.score, 5); { Bonus pour retourner une carte }
      End
      { Sinon, retourner la dernière carte si elle est cachée }
      Else If not Game.tableau[columnIndex].cards[Game.tableau[columnIndex].count].faceUp then
      Begin
        Game.tableau[columnIndex].cards[Game.tableau[columnIndex].count].faceUp := True;
        NeedRedraw := True;
        Inc(Game.score, 5); { Bonus pour retourner une carte }
      End;
    End;
  End;
End;

Procedure AutoMoveToFoundation;
Var
  i, j: Integer;
  moved: Boolean;
Begin
  moved := False;

  { Essayer de déplacer depuis la waste }
  If Game.waste.count > 0 then
  Begin
    For i := 1 to 4 do
    Begin
      If CanPlaceOnFoundation(Game.waste.cards[Game.waste.count], i) then
      Begin
        MoveCard(1, 0, Game.waste.count, 2, i);
        moved := True;
        Break;
      End;
    End;
  End;

  { Essayer de déplacer depuis le tableau }
  If not moved then
  Begin
    For i := 1 to 7 do
    Begin
      If Game.tableau[i].count > 0 then
      Begin
        For j := 1 to 4 do
        Begin
          If CanPlaceOnFoundation(Game.tableau[i].cards[Game.tableau[i].count], j) then
          Begin
            MoveCard(3, i, Game.tableau[i].count, 2, j);
            moved := True;
            Break;
          End;
        End;
      End;
      If moved then Break;
    End;
  End;

  If moved then NeedRedraw := True;
End;

Procedure HandleKeyboardInput;
Var
  areaType, areaIndex, cardIndex: Integer;
  canMove: Boolean;
Begin
  { Déterminer la position actuelle du curseur }
  areaType := Cursor.areaType;
  areaIndex := Cursor.areaIndex;
  cardIndex := Cursor.cardIndex;

  If not Selection.active then
  Begin
    { Sélectionner une carte }
    Case areaType of
      0: FlipDeckCard; { Deck }
      1: If Game.waste.count > 0 then { Waste }
         Begin
           Selection.active := True;
           Selection.sourceType := 1;
           Selection.sourceIndex := 0;
           Selection.cardIndex := Game.waste.count;
           NeedRedraw := True;
         End;
      2: If Game.foundations[areaIndex].count > 0 then { Foundation }
         Begin
           Selection.active := True;
           Selection.sourceType := 2;
           Selection.sourceIndex := areaIndex;
           Selection.cardIndex := Game.foundations[areaIndex].count;
           NeedRedraw := True;
         End;
      3: If (Game.tableau[areaIndex].count > 0) and { Tableau }
            (cardIndex <= Game.tableau[areaIndex].count) and
            (Game.tableau[areaIndex].cards[cardIndex].faceUp) then
         Begin
           Selection.active := True;
           Selection.sourceType := 3;
           Selection.sourceIndex := areaIndex;
           { Sélectionner le début de la séquence déplaçable }
           Selection.cardIndex := GetSequenceStart(areaIndex, cardIndex);
           NeedRedraw := True;
         End
         Else If (Game.tableau[areaIndex].count > 0) and
                 (cardIndex <= Game.tableau[areaIndex].count) and
                 (not Game.tableau[areaIndex].cards[cardIndex].faceUp) then
         Begin
           { Si la carte est cachée, la retourner automatiquement }
           FlipTableauCard;
         End;
    End;
  End
  Else
  Begin
    { Tenter de déplacer la carte sélectionnée }
    canMove := False;

    Case areaType of
      2: { Foundation }
        If Selection.sourceType = 1 then
          canMove := CanPlaceOnFoundation(Game.waste.cards[Game.waste.count], areaIndex)
        Else If Selection.sourceType = 3 then
          canMove := CanPlaceOnFoundation(Game.tableau[Selection.sourceIndex].cards[Selection.cardIndex], areaIndex);
      3: { Tableau }
        If Selection.sourceType = 1 then
          canMove := CanPlaceOnTableau(Game.waste.cards[Game.waste.count], areaIndex)
        Else If Selection.sourceType = 2 then
          canMove := CanPlaceOnTableau(Game.foundations[Selection.sourceIndex].cards[Selection.cardIndex], areaIndex)
        Else If Selection.sourceType = 3 then
        Begin
          { Vérifier si on peut placer la carte sélectionnée }
          canMove := CanPlaceOnTableau(Game.tableau[Selection.sourceIndex].cards[Selection.cardIndex], areaIndex);
          { Vérifier si on peut déplacer toute la séquence }
          If canMove and CanMoveSequence(Selection.sourceIndex, Selection.cardIndex) then
          Begin
            { Déplacer la séquence complète }
            MoveSequence(Selection.sourceIndex, Selection.cardIndex, areaIndex);
            canMove := False; { Pour éviter le MoveCard normal }
          End;
        End;
    End;

    If canMove then
      MoveCard(Selection.sourceType, Selection.sourceIndex, Selection.cardIndex, areaType, areaIndex);

    Selection.active := False;
    NeedRedraw := True;
  End;
End;

Function CheckWin: Boolean;
Var
  i: Integer;
Begin
  CheckWin := True;
  For i := 1 to 4 do
    If Game.foundations[i].count <> 13 then
    Begin
      CheckWin := False;
      Exit;
    End;
End;

Procedure HandleInput;
Var
  key: Char;
Begin
  { Gérer le clavier }
  If KeyPressed then
  Begin
    key := ReadKey;
    Case key of
      #0: Case ReadKey of
        #72: MoveCursor(3); { Flèche haut }
        #80: MoveCursor(4); { Flèche bas }
        #75: MoveCursor(1); { Flèche gauche }
        #77: MoveCursor(2); { Flèche droite }
      End;
      ' ': HandleKeyboardInput; { Espace }
      'd', 'D': FlipDeckCard; { D pour flip deck }
      'f', 'F': FlipTableauCard; { F pour flip tableau card }
      'a', 'A': AutoMoveToFoundation; { A pour auto-move }
      #27: Game.gameWon := True; { ESC pour quitter }
      'r', 'R': If Game.gameWon then
                Begin
                  InitializeGame;
                  NeedRedraw := True;
                End
                Else
                Begin
                  { Permettre restart pendant le jeu }
                  InitializeGame;
                  NeedRedraw := True;
                End;
    End;
  End;
End;

Procedure GameLoop;
Var
 firstDraw:Boolean;
Begin
 InitializeGraphics;
 InitializeGame;
  { Dessiner le fond une seule fois }
 SetColor(2); { Green }
 SetFillStyle(1, 2); { SolidFill, Green }
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 firstDraw := True;
 NeedRedraw := True;
 Repeat
    { Redessiner seulement si nécessaire }
  If firstDraw or NeedRedraw Then Begin
    { Redessiner le fond vert aux positions des cartes }
   SetColor(2); { Green }
   SetFillStyle(1, 2); { SolidFill, Green }
   Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   DrawDeck;
   DrawWaste;
   DrawFoundations;
   DrawTableau;
   DrawCursor;
   DrawHUD;
   firstDraw:=False;
   NeedRedraw:=False;
  End;
  If CheckWin Then Begin
   Game.gameWon := True;
   DrawWinMessage;
  End;
  HandleInput;
  Delay(50);
 Until Game.gameWon and KeyPressed;
 CloseGraph;
End;

BEGIN
 Randomize;
 GameLoop;
END.
