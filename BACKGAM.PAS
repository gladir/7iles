{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Backgammon;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 BOARD_WIDTH = 490;
 BOARD_HEIGHT = 360;  { Réduit de 380 à 360 }
 POINT_HEIGHT = 140; { Réduit de 150 à 140 pour garder les proportions }
 MARGIN_TOP = 60;
 MARGIN_BOTTOM = 40;
 DICE_AREA_LEFT = 550; { Augment� de 510 � 550 }
 BOARD_TOP_OFFSET = 20;  { Nouvelle constante }

Type
 TPlayerType = (Human, Computer);

 TPoint=Record
  count:integer;
  color:integer; { 1 = white, 2 = black }
 End;

 TBoard=Array[1..24] of TPoint;

 TDiceUsed = Array[1..2] of Boolean;  { Pour suivre l'état des dés }

Var
 Gd,Gm:Integer;
 Board:TBoard;
 CurrentPlayer:Integer;
 Dice:Array[1..2] of Integer;      { d�s de l'ordinateur }
 HumanDice:Array[1..2] of Integer; { d�s de l'humain }
 Player1Type,Player2Type:TPlayerType;
 DiceUsed, HumanDiceUsed: TDiceUsed;  { État des dés (utilisé ou non) }

Function IntToStr(Value:Integer):String;
Var
 S:String[11];  { Maximum de 11 caract�res pour un Integer }
Begin
 Str(Value, S);
 IntToStr := S;
End;

Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
 ErrCode:=GraphResult;
 If ErrCode=grOk Then Begin
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure InitializeBoard;
Var
 I: Integer;
Begin
 For I := 1 To 24 Do Begin
  Board[I].Count := 0;
  Board[I].Color := 0;
 End;

  { Fixe les positions initiales }
 Board[1].Count := 2; Board[1].Color := 1;  { Blanc }
 Board[12].Count := 5; Board[12].Color := 1;
 Board[17].Count := 3; Board[17].Color := 1;
 Board[19].Count := 5; Board[19].Color := 1;

 Board[24].Count := 2; Board[24].Color := 2;  { Rouge }
 Board[13].Count := 5; Board[13].Color := 2;
 Board[8].Count := 3; Board[8].Color := 2;
 Board[6].Count := 5; Board[6].Color := 2;
End;

Procedure DrawLetters;
Var
 I:Integer;
 X:Integer;
 Letter:Char;
Begin
 SetTextStyle(DefaultFont, HorizDir, 2);
 SetColor(White);  { Force la couleur du texte en blanc }
 For I:=0 To 11 Do Begin
  X:=I * (BOARD_WIDTH Div 12) + (BOARD_WIDTH Div 24) - 8;
  Letter := Chr(Ord('A') + I);
  OutTextXY(X, MARGIN_TOP - 10, Letter);
  Letter := Chr(Ord('M') + I);
  OutTextXY(X, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET + 30, Letter);
 End;
End;

Procedure DrawDiceShape(X,Y,Value:Integer; Used:Boolean);
Const
 DICE_SIZE=40;
 DOT_SIZE=6;
Var
 CenterX,CenterY:Integer;
Begin
  { Dessine le rectangle arrondi du dé }
  If Used Then Begin
    SetColor(LightGray);
    SetFillStyle(SolidFill, LightGray);
  End Else Begin
    SetColor(White);
    SetFillStyle(SolidFill, White);
  End;

  Bar(X,Y,X+DICE_SIZE,Y+DICE_SIZE);
 Rectangle(X,Y,X+DICE_SIZE,Y+DICE_SIZE);

  { Points centraux pour le dé }
 CenterX:=X + DICE_SIZE Div 2;
 CenterY:=Y + DICE_SIZE Div 2;
 SetFillStyle(SolidFill, Black);
 Case Value Of
  1:FillEllipse(CenterX, CenterY, DOT_SIZE, DOT_SIZE);
  2:Begin
   FillEllipse(CenterX - 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
  End;
  3:Begin
   FillEllipse(CenterX - 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX, CenterY, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
  End;
  4:Begin
   FillEllipse(CenterX - 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX - 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
  End;
  5:Begin
   FillEllipse(CenterX - 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX, CenterY, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX - 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
  End;
  6:Begin
   FillEllipse(CenterX - 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY - 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX - 10, CenterY, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX - 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
   FillEllipse(CenterX + 10, CenterY + 10, DOT_SIZE, DOT_SIZE);
  End;
 End;
End;

Procedure DrawDice;
Var
 Y:Integer;
Begin
  Y:=MARGIN_TOP + 45;
  SetTextStyle(DefaultFont, HorizDir, 2);

  If Player1Type = Human Then Begin
    { Si l'humain commence, affiche dans cet ordre }
    OutTextXY(DICE_AREA_LEFT + 5, Y - 30, 'Ordi:');
    OutTextXY(DICE_AREA_LEFT + 15, Y + 60, 'Humain:');
  End Else Begin
    { Si l'ordi commence, inverse les légendes }
    OutTextXY(DICE_AREA_LEFT + 5, Y - 30, 'Humain:');
    OutTextXY(DICE_AREA_LEFT + 15, Y + 60, 'Ordi:');
  End;

  DrawDiceShape(DICE_AREA_LEFT - 15, Y + 5, Dice[1], DiceUsed[1]);
  DrawDiceShape(DICE_AREA_LEFT + 45, Y + 5, Dice[2], DiceUsed[2]);
  DrawDiceShape(DICE_AREA_LEFT - 15, Y + 85, HumanDice[1], HumanDiceUsed[1]);
  DrawDiceShape(DICE_AREA_LEFT + 45, Y + 85, HumanDice[2], HumanDiceUsed[2]);

  { Ajoute la légende des couleurs selon qui commence }
  SetTextStyle(DefaultFont, HorizDir, 1);

  If Player1Type = Human Then Begin
    { Si l'humain commence: humain = rouge, ordi = blanc }
    SetColor(Red);
    SetFillStyle(SolidFill, Red);
    FillEllipse(DICE_AREA_LEFT + 10, Y + 310, 8, 8);
    OutTextXY(DICE_AREA_LEFT + 50, Y + 307, 'Humain');

    SetFillStyle(SolidFill, White);
    FillEllipse(DICE_AREA_LEFT + 10, Y + 330, 8, 8);
    OutTextXY(DICE_AREA_LEFT + 42, Y + 327, 'Ordi');
  End Else Begin
    { Si l'ordi commence: ordi = rouge, humain = blanc }
    SetColor(Red);
    SetFillStyle(SolidFill, Red);
    FillEllipse(DICE_AREA_LEFT + 10, Y + 310, 8, 8);
    OutTextXY(DICE_AREA_LEFT + 50, Y + 307, 'Ordi');

    SetFillStyle(SolidFill, White);
    FillEllipse(DICE_AREA_LEFT + 10, Y + 330, 8, 8);
    OutTextXY(DICE_AREA_LEFT + 42, Y + 327, 'Humain');
  End;
End;

Procedure DrawDirectionArrows;
Const
 ARROW_SIZE=30;
 ARROW_X=DICE_AREA_LEFT+100;
Begin
  { Fl�che du haut (ordi - blanc) }
 SetColor(White);
 SetFillStyle(SolidFill, White);
 Line(ARROW_X, MARGIN_TOP + 20, ARROW_X, MARGIN_TOP + 50);
 Line(ARROW_X - 10, MARGIN_TOP + 35, ARROW_X, MARGIN_TOP + 20);
 Line(ARROW_X + 10, MARGIN_TOP + 35, ARROW_X, MARGIN_TOP + 20);

  { Fl�che du bas (humain - noir) }
 SetColor(Red);
 SetFillStyle(SolidFill, Red);
 Line(ARROW_X, MARGIN_TOP + 70, ARROW_X, MARGIN_TOP + 100);
 Line(ARROW_X - 10, MARGIN_TOP + 85, ARROW_X, MARGIN_TOP + 100);
 Line(ARROW_X + 10, MARGIN_TOP + 85, ARROW_X, MARGIN_TOP + 100);
End;

Procedure DrawBoard;
Var
 I,J,X,Y:Integer;
 TrianglePoints:Array[1..6] of Integer;
Begin
 ClearDevice;
 SetBkColor(Green);

  { Dessin le tableau }
 Rectangle(0, MARGIN_TOP + BOARD_TOP_OFFSET,
           BOARD_WIDTH, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET);
 Line(BOARD_WIDTH div 2, MARGIN_TOP + BOARD_TOP_OFFSET,
      BOARD_WIDTH div 2, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET);

 { Dessine les points }
 For I := 1 To 24 do Begin
  X:=((I-1) Mod 12) * (BOARD_WIDTH Div 12);
  If I>12 Then Y:=BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET
          Else Y:=MARGIN_TOP + BOARD_TOP_OFFSET;

 { Dessine le triangle }
  SetColor(Black);
  If I Mod 2=0 Then SetFillStyle(SolidFill,LightGray)
               Else SetFillStyle(SolidFill,DarkGray);
  TrianglePoints[1] := X;
  TrianglePoints[2] := Y;
  TrianglePoints[3] := X + (BOARD_WIDTH Div 12);
  TrianglePoints[4] := Y;
  TrianglePoints[5] := X + (BOARD_WIDTH Div 24);
  If I <= 12 Then
   TrianglePoints[6] := Y + POINT_HEIGHT  { Triangles du haut pointant vers le bas }
  Else
   TrianglePoints[6] := Y - POINT_HEIGHT; { Triangles du bas pointant vers le haut }
  FillPoly(3, TrianglePoints);

   { Dessin la jetons avec positions ajust�es }
  If Board[I].Count>0 Then Begin
   If Board[I].Color=1 Then Begin
    SetColor(Red);  { Ajout pour le contour }
    SetFillStyle(SolidFill,Red)  { Pour l'humain }
   End
    Else
   Begin
    SetColor(White);  { Ajout pour le contour }
    SetFillStyle(SolidFill,White); { Pour l'ordi }
   End;
   For J:=1 To Board[I].Count Do Begin
    If I <= 12 Then FillEllipse(X+(BOARD_WIDTH Div 24),Y+J*30,15,15)
               Else FillEllipse(X + (BOARD_WIDTH Div 24),Y-J*30,15,15);
   End;
  End;
 End;
 DrawDice;
 DrawLetters;
 DrawDirectionArrows;  { Ajout de l'appel }
End;

Procedure RollDice;
Begin
  Randomize;
  { Tire les dés pour les deux joueurs }
  Dice[1] := Random(6) + 1;
  Dice[2] := Random(6) + 1;
  HumanDice[1] := Random(6) + 1;
  HumanDice[2] := Random(6) + 1;

  { Réinitialise l'état des dés }
  DiceUsed[1] := False;
  DiceUsed[2] := False;
  HumanDiceUsed[1] := False;
  HumanDiceUsed[2] := False;
End;

Function IsValidMove(FromPos, ToPos: Integer; Var UsedDice: Integer): Boolean;
Begin
  IsValidMove := False;
  UsedDice := 0;
  If (FromPos < 1) Or (FromPos > 24) Or (ToPos < 1) Or (ToPos > 24) Then Exit;

  { Basic move validation }
  If Board[FromPos].Color <> CurrentPlayer Then Exit;
  If (Board[ToPos].Count > 1) And (Board[ToPos].Color <> CurrentPlayer) Then Exit;

  { Pour l'humain, vérifie les deux dés disponibles }
  If CurrentPlayer = 1 Then Begin
    If Not HumanDiceUsed[1] And (Abs(ToPos - FromPos) = HumanDice[1]) Then Begin
      IsValidMove := True;
      UsedDice := 1;
    End;
    If Not HumanDiceUsed[2] And (Abs(ToPos - FromPos) = HumanDice[2]) Then Begin
      IsValidMove := True;
      UsedDice := 2;
    End;
  End Else Begin
    { Pour l'ordinateur, garde la logique existante }
    If Not DiceUsed[1] And (Abs(ToPos - FromPos) = Dice[1]) Then Begin
      IsValidMove := True;
      UsedDice := 1;
    End Else If Not DiceUsed[2] And (Abs(ToPos - FromPos) = Dice[2]) Then Begin
      IsValidMove := True;
      UsedDice := 2;
    End;
  End;
End;

Procedure FlashCheckers(FromPos, ToPos: Integer);
Var
  I, X, Y, OrigColor: Integer;
Begin
  For I := 1 To 5 Do Begin  { 5 cycles de clignotement }
    { Sauvegarde la couleur originale }
    OrigColor := Board[FromPos].Color;

    { Change la couleur en rouge }
    Board[FromPos].Color := Red;
    If Board[ToPos].Count > 0 Then
      Board[ToPos].Color := Red;
    DrawBoard;
    Delay(200);

    { Retourne à la couleur originale }
    Board[FromPos].Color := OrigColor;
    If Board[ToPos].Count > 0 Then
      Board[ToPos].Color := CurrentPlayer;
    DrawBoard;
    Delay(200);
  End;
End;

Procedure MakeMove(FromPos, ToPos: Integer);
Var
  UsedDice: Integer;
Begin
  If Not IsValidMove(FromPos, ToPos, UsedDice) Then Exit;

  { Marque le dé comme utilisé }
  If CurrentPlayer = 1 Then
    HumanDiceUsed[UsedDice] := True
  Else
    DiceUsed[UsedDice] := True;

  { Effet de clignotement }
  FlashCheckers(FromPos, ToPos);

  { Update board }
  Dec(Board[FromPos].Count);
  If Board[FromPos].Count = 0 Then
    Board[FromPos].Color := 0;

  Inc(Board[ToPos].Count);
  Board[ToPos].Color := CurrentPlayer;

  DrawBoard;
End;

Function LetterToPosition(C: Char; TopHalf: Boolean): Integer;
Begin
  If TopHalf Then
    LetterToPosition := Ord(UpCase(C)) - Ord('A') + 1
  Else
    LetterToPosition := Ord(UpCase(C)) - Ord('M') + 13;  { Modifié pour M-X }
End;

Procedure ComputerMove;
Var
  FromPos, ToPos, BestFrom, BestTo: Integer;
  MovesLeft, ValidMoves, UsedDice: Integer;  { Ajout de UsedDice }
Begin
  MovesLeft := 2;
  While MovesLeft > 0 Do Begin
    ValidMoves := 0;
    BestFrom := 0;
    BestTo := 0;

    { Cherche un mouvement valide }
    For FromPos := 1 To 24 Do
      For ToPos := 1 To 24 Do
        If IsValidMove(FromPos, ToPos, UsedDice) Then Begin  { Ajout du paramètre UsedDice }
          BestFrom := FromPos;
          BestTo := ToPos;
          ValidMoves := ValidMoves + 1;
          Break;
        End;

    If ValidMoves > 0 Then Begin
      MakeMove(BestFrom, BestTo);
      Dec(MovesLeft);
    End
    Else MovesLeft := 0;

    Delay(500);
  End;
End;

Procedure SelectFirstPlayer;
Var
  C: Char;
  CenterX, CenterY: Integer;
Begin
  ClearDevice;
  SetBkColor(Black);
  CenterX := GetMaxX Div 2;
  CenterY := GetMaxY Div 2;

  { Affiche le titre }
  SetTextStyle(TriplexFont, HorizDir, 4);
  SetTextJustify(CenterText, CenterText);
  OutTextXY(CenterX, CenterY - 50, 'BACKGAMMON');

  { Affiche le message de sélection }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(CenterX, CenterY, 'Qui commence?');
  OutTextXY(CenterX, CenterY + 30, '(H)umain, (O)rdinateur ou (Q)uitter');

  Repeat
    C := UpCase(ReadKey);
  Until C In ['H', 'O', 'Q'];

  If C = 'Q' Then Begin
    CloseGraph;
    Halt;
  End Else If C = 'H' Then Begin
    CurrentPlayer := 1;
    Player1Type := Human;
    Player2Type := Computer;
  End Else Begin
    CurrentPlayer := 2;
    Player1Type := Computer;
    Player2Type := Human;
  End;
End;

Procedure HandlePlayerMove;
Var
  C: Char;
  FromPos, ToPos: Integer;
  MovesLeft, UsedDice: Integer;
Begin
  MovesLeft := 2;
  
  While MovesLeft > 0 Do Begin
    SetTextStyle(DefaultFont, HorizDir, 2);
    OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 180, 'Coups');
    OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 200, 'restants: ' + IntToStr(MovesLeft));
    OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 230, 'De: ');
    
    Repeat
      C := ReadKey;
      If C = #27 Then Begin { ESC }
        CloseGraph;
        Halt;
      End;
      If C = #13 Then Begin { ENTER pour passer }
        MovesLeft := 0;
        Break;
      End;
      C := UpCase(C);
    Until C in ['A'..'L', 'M'..'X'];

    If MovesLeft = 0 Then Break;

    OutTextXY(DICE_AREA_LEFT + 80, MARGIN_TOP + 230, C);
    
    If C in ['A'..'L'] Then FromPos := LetterToPosition(C, True)
                      Else FromPos := LetterToPosition(C, False);

    OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 260, 'Vers: ');
    Repeat
      C := ReadKey;
      If C = #27 Then Begin
        CloseGraph;
        Halt;
      End;
      C := UpCase(C);
    Until C in ['A'..'L', 'M'..'X'];

    OutTextXY(DICE_AREA_LEFT + 80, MARGIN_TOP + 260, C);

    If C in ['A'..'L'] Then ToPos := LetterToPosition(C, True)
                      Else ToPos := LetterToPosition(C, False);

    If IsValidMove(FromPos, ToPos, UsedDice) Then Begin
      MakeMove(FromPos, ToPos);
      Dec(MovesLeft);
      DrawBoard;
    End;
  End;
End;

{ Programme principal modifié }
BEGIN
  InitializeGraphics;
  SelectFirstPlayer;
  InitializeBoard;
  RollDice;
  DrawBoard;

  { Si l'ordinateur commence, joue immédiatement }
  If Player1Type = Computer Then Begin
    ComputerMove;
    CurrentPlayer := 3 - CurrentPlayer;
    RollDice;
    DrawBoard;
  End;
  
  Repeat
    If ((CurrentPlayer = 1) And (Player1Type = Human)) Or 
       ((CurrentPlayer = 2) And (Player2Type = Human)) Then
      HandlePlayerMove
    Else
      ComputerMove;

    If KeyPressed Then Begin
      If ReadKey = #27 Then Break;
    End;
    CurrentPlayer := 3 - CurrentPlayer;
    RollDice;  { Lance les dés pour le prochain tour }
    DrawBoard; { Affiche le nouveau plateau }
    Delay(500);
  Until False;
END.
