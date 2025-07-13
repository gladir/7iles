{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)

  Hex 2048 - Version hexagonale du jeu 2048
  Grille hexagonale avec 6 directions de mouvement
}

Program Hex2048;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  HEX_RADIUS = 35;
  CENTER_X = 320;
  CENTER_Y = 240;

  { Disposition hexagonale : 3 rangées avec 3, 4, 3 hexagones }
  MAX_HEXAGONS = 19;

Type
  THexCell = Record
    X, Y: Integer;        { Position à l'écran }
    Value: LongInt;       { Valeur de la tuile }
    Active: Boolean;      { Si cette cellule est utilisée }
  End;

  THexGrid = Array[0..MAX_HEXAGONS-1] of THexCell;

  THexPoint = Record
    X, Y: Integer;
  End;

Var
  Grid: THexGrid;
  Score: LongInt;
  BestScore: LongInt;
  GameOver: Boolean;
  Won: Boolean;
  ShowInstructions: Boolean;

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs:Registers;
 Begin
  Regs.AX := 0;
  Intr($33, Regs);
  MouseDriverFound := Regs.AX = $FFFF;
 End;

 Procedure ShowMouse;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0001;
  Intr($33,Regs);
 End;

 Procedure HideMouse;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0002;
  Intr($33, Regs);
 End;

 Procedure GetMouseState(Var X,Y,Button:LongInt);
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0003;
  Intr($33, Regs);
  Button := Regs.BX;
  X := Regs.CX;
  Y := Regs.DX;
 End;

 Function GetMouseButton:Word;
 Var
  X,Y,Button:LongInt;
 Begin
  GetMouseState(X,Y,Button);
  GetMouseButton:=Button;
 End;

 Procedure SetMousePosition(X,Y:Integer);
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0004;
  Regs.CX:=X;
  Regs.DX:=Y;
  Intr($33,Regs);
 End;

 Function GetTickCount:LongInt;Begin
  GetTickCount:= MemL[Seg0040:$006C]; { Turbo Pascal - lecture directe de la m�moire }
 End;
{$ELSE}
 Function MouseDriverFound:Boolean;Begin
  MouseDriverFound := True; { Pas de support souris direct en Free Pascal }
 End;

 Function GetMouseButton:Word;
 Var
  X,Y,Button:LongInt;
 Begin
  GetMouseState(X,Y,Button);
  GetMouseButton:=Button;
 End;

 Procedure ShowMouse;Begin
  { Pas d'impl�mentation pour Free Pascal }
 End;

 Procedure HideMouse;Begin
  { Pas d'impl�mentation pour Free Pascal }
 End;

{$ENDIF}

Procedure InitHexGrid;
Var
  I: Integer;
  Row, Col: Integer;
  StartX, StartY: Integer;
  HexRadius: Integer;
  HexWidth, HexHeight: Integer;
Begin
  { Initialiser toutes les cellules comme inactives }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    Grid[I].Active := False;
    Grid[I].Value := 0;
  End;

  { Disposition hexagonale compacte avec espacement de 2 pixels }
  { Rayon hexagone = 35px, largeur = 70px, espacement = 2px }
  { Espacement horizontal = 72px, vertical = 60px }
  
  I := 0;

  { Rangée 0 : 3 hexagones - descendu de 60px pour éviter le chevauchement avec les instructions }
  StartX := 200;
  StartY := 180;
  For Col := 0 to 2 Do Begin
    Grid[I].X := StartX + Col * 72;  { Espacement horizontal de 72px (70+2) }
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;

  { Rangée 1 : 4 hexagones - décalé de 36px à gauche }
  StartX := 164;
  StartY := 240;
  For Col := 0 to 3 Do Begin
    Grid[I].X := StartX + Col * 72;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;

  { Rangée 2 : 5 hexagones - centre }
  StartX := 128;
  StartY := 300;
  For Col := 0 to 4 Do Begin
    Grid[I].X := StartX + Col * 72;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;

  { Rangée 3 : 4 hexagones - décalé de 36px à droite }
  StartX := 164;
  StartY := 360;
  For Col := 0 to 3 Do Begin
    Grid[I].X := StartX + Col * 72;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;

  { Rangée 4 : 3 hexagones }
  StartX := 200;
  StartY := 420;
  For Col := 0 to 2 Do Begin
    Grid[I].X := StartX + Col * 72;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
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

Function GetHexCenter(Index: Integer): THexPoint;
Var
  Point: THexPoint;
Begin
  If (Index >= 0) And (Index < MAX_HEXAGONS) And Grid[Index].Active Then Begin
    Point.X := Grid[Index].X;
    Point.Y := Grid[Index].Y;
  End Else Begin
    Point.X := 0;
    Point.Y := 0;
  End;
  GetHexCenter := Point;
End;

Procedure DrawHexagon(CenterX, CenterY, Radius: Integer; FillColor, BorderColor: Integer);
Var
  Points: Array[0..5] of PointType;
  I: Integer;
  Angle: Real;
Begin
  { Calculer les 6 points de l'hexagone }
  For I := 0 to 5 Do Begin
    Angle := I * Pi / 3;
    Points[I].X := CenterX + Round(Radius * Cos(Angle));
    Points[I].Y := CenterY + Round(Radius * Sin(Angle));
  End;

  { Remplir l'hexagone }
  SetColor(FillColor);
  SetFillStyle(SolidFill, FillColor);
  FillPoly(6, Points);

  { Dessiner la bordure }
  SetColor(BorderColor);
  SetLineStyle(SolidLn, 0, NormWidth);
  For I := 0 to 5 Do Begin
    Line(Points[I].X, Points[I].Y, Points[(I+1) Mod 6].X, Points[(I+1) Mod 6].Y);
  End;
End;

Function GetTileColor(Value: LongInt): Integer;
Begin
  { Couleurs basées sur setUpDisplay() du JavaScript, adaptées pour VGA }
  Case Value of
    0: GetTileColor := DarkGray;
    2: GetTileColor := White;        { fff -> White }
    4: GetTileColor := LightCyan;    { add -> LightCyan }
    8: GetTileColor := Cyan;         { 5bb -> Cyan }
    16: GetTileColor := LightRed;    { ed717c -> LightRed }
    32: GetTileColor := LightMagenta; { db6fdb -> LightMagenta }
    64: GetTileColor := Red;         { f99 -> Red }
    128: GetTileColor := LightGreen; { 9f9 -> LightGreen }
    256: GetTileColor := LightBlue;  { 10c5ee -> LightBlue }
    512: GetTileColor := Yellow;     { c5ee10 -> Yellow }
    1024: GetTileColor := Cyan;      { 1eb -> Cyan }
    2048: GetTileColor := LightGray; { ff9 -> LightGray }
    4096: GetTileColor := Brown;     { eea -> Brown }
    8192: GetTileColor := LightGray; { ddc -> LightGray }
    16384: GetTileColor := LightCyan; { cce -> LightCyan }
    Else GetTileColor := White;      { Valeurs supérieures -> White }
  End;
End;

Function GetTextColor(Value: LongInt): Integer;
Begin
  { Couleur de texte basée sur les couleurs de fond }
  Case Value of
    0: GetTextColor := LightGray;
    2, 4: GetTextColor := Black;     { Sur fond clair }
    Else GetTextColor := White;      { Sur fond foncé }
  End;
End;

Function GetTextSize(Value: LongInt): Integer;
Begin
  { Tailles de police basées sur setUpDisplay() du JavaScript }
  Case Value of
    2, 4, 8, 16, 32, 64, 128: GetTextSize := 2;      { 48px -> taille 2 }
    256, 512: GetTextSize := 1;                       { 40px -> taille 1 }
    1024, 2048, 4096, 8192, 16384: GetTextSize := 1; { 32px -> taille 1 }
    Else GetTextSize := 1;
  End;
End;

Procedure DrawTile(Index: Integer);
Var
  Point: THexPoint;
  Value: LongInt;
  ValueStr: String;
  TextW, TextH: Integer;
Begin
  If Not Grid[Index].Active Then Exit;

  Point := GetHexCenter(Index);
  Value := Grid[Index].Value;

  { Dessiner l'hexagone }
  DrawHexagon(Point.X, Point.Y, HEX_RADIUS-2, GetTileColor(Value), White);

  { Afficher la valeur si elle n'est pas zéro }
  If Value > 0 Then Begin
    Str(Value, ValueStr);
    SetColor(GetTextColor(Value));
    SetTextStyle(DefaultFont, HorizDir, GetTextSize(Value));

    { Centrer le texte avec ajustement selon la taille }
    TextW := Length(ValueStr) * (8 * GetTextSize(Value));
    TextH := 8 * GetTextSize(Value);
    OutTextXY(Point.X - TextW div 2, Point.Y - TextH div 2, ValueStr);
  End;
End;

Procedure DrawBackground;
Begin
  { Fond noir comme dans setUpDisplay() : game.stage.backgroundColor = "#000000" }
  SetColor(Black);
  SetFillStyle(SolidFill, Black);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  { Titre }
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 3);
  OutTextXY(SCREEN_WIDTH div 2 - 60, 20, 'HEX 2048');

  { Bordure principale }
  SetColor(White);
  SetLineStyle(SolidLn, 0, ThickWidth);
  Rectangle(10, 10, SCREEN_WIDTH - 10, SCREEN_HEIGHT - 10);
End;

Procedure DrawScore;
Var
  ScoreStr, BestStr: String;
Begin
  SetColor(Yellow);
  SetTextStyle(DefaultFont, HorizDir, 1);

  Str(Score, ScoreStr);
  Str(BestScore, BestStr);

  OutTextXY(50, 60, 'Score: ' + ScoreStr);
  OutTextXY(50, 80, 'Meilleur: ' + BestStr);
End;

Procedure DrawInstructions;
Begin
  If ShowInstructions Then Begin
    { Affichage modal des instructions basé sur displayInstructionsModal }
    SetColor(DarkGray);
    SetFillStyle(SolidFill, DarkGray);
    Bar(40, 50, SCREEN_WIDTH - 40, 150);

    SetColor(Blue);
    SetLineStyle(SolidLn, 0, ThickWidth);
    Rectangle(40, 50, SCREEN_WIDTH - 40, 150);

    SetColor(White);
    SetTextStyle(DefaultFont, HorizDir, 2);
    OutTextXY(60, 70, 'Utilisez les touches Q/W/E/A/S/D');
    OutTextXY(60, 90, 'pour deplacer les tuiles');

    SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(60, 110, 'Cliquez ou appuyez sur une touche pour commencer');
    OutTextXY(60, 125, 'R - Nouveau jeu, ESC - Quitter');
  End Else Begin
    { Instructions normales en bas }
    SetColor(LightGray);
    SetTextStyle(DefaultFont, HorizDir, 1);

    OutTextXY(50, 400, 'Touches:');
    OutTextXY(50, 415, 'Q - Haut gauche    W - Haut    E - Haut droite');
    OutTextXY(50, 430, 'A - Bas gauche     S - Bas     D - Bas droite');
    OutTextXY(50, 445, 'R - Nouveau jeu, ESC - Quitter');
  End;
End;

Procedure DrawGrid;
Var
  I: Integer;
Begin
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    If Grid[I].Active Then
      DrawTile(I);
  End;
End;

Procedure DrawGameOver;
Begin
  If GameOver Then Begin
    SetColor(Red);
    SetFillStyle(SolidFill, Red);
    Bar(CENTER_X - 100, CENTER_Y - 30, CENTER_X + 100, CENTER_Y + 30);

    SetColor(White);
    SetTextStyle(DefaultFont, HorizDir, 2);
    OutTextXY(CENTER_X - 70, CENTER_Y - 10, 'GAME OVER');

    SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(CENTER_X - 80, CENTER_Y + 15, 'Appuyez sur R pour rejouer');
  End;
End;

Procedure DrawWin;
Begin
  If Won Then Begin
    SetColor(Green);
    SetFillStyle(SolidFill, Green);
    Bar(CENTER_X - 100, CENTER_Y - 50, CENTER_X + 100, CENTER_Y + 50);

    SetColor(White);
    SetTextStyle(DefaultFont, HorizDir, 2);
    OutTextXY(CENTER_X - 50, CENTER_Y - 20, 'VOUS AVEZ');
    OutTextXY(CENTER_X - 40, CENTER_Y, 'GAGNE!');

    SetTextStyle(DefaultFont, HorizDir, 1);
    OutTextXY(CENTER_X - 80, CENTER_Y + 25, 'Appuyez sur R pour rejouer');
  End;
End;

Procedure DrawScreen;
Begin
  DrawBackground;
  DrawScore;
  DrawGrid;
  DrawInstructions;
  DrawGameOver;
  DrawWin;
End;

Procedure AddRandomTile;
Var
  I: Integer;
  EmptyFound: Boolean;
  Attempts: Integer;
  EmptySlots: Array[0..MAX_HEXAGONS-1] of Integer;
  EmptyCount: Integer;
Begin
  { Trouver toutes les cases vides }
  EmptyCount := 0;
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    If Grid[I].Active And (Grid[I].Value = 0) Then Begin
      EmptySlots[EmptyCount] := I;
      Inc(EmptyCount);
    End;
  End;

  { Ajouter une tuile dans une case vide aléatoire }
  If EmptyCount > 0 Then Begin
    I := EmptySlots[Random(EmptyCount)];
    { 90% chance d'avoir un 2, 10% chance d'avoir un 4 }
    If Random(10) = 0 Then
      Grid[I].Value := 4
    Else
      Grid[I].Value := 2;
  End;
End;

Procedure InitGrid;
Var
  I: Integer;
Begin
  { Initialiser la grille hexagonale }
  InitHexGrid;

  { Vider toutes les valeurs }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    Grid[I].Value := 0;
  End;

  { Ajouter deux tuiles initiales }
  AddRandomTile;
  AddRandomTile;
End;

Function HasEmptyTiles: Boolean;
Var
  I: Integer;
Begin
  HasEmptyTiles := False;
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    If Grid[I].Active And (Grid[I].Value = 0) Then Begin
      HasEmptyTiles := True;
      Exit;
    End;
  End;
End;

{ Mapping des voisins hexagonaux basé sur la fonction connectBlocks() du JavaScript }
{ Direction 0=Q (nord-ouest), 1=W (nord), 2=E (est) }
{ Direction 3=A (ouest), 4=S (sud), 5=D (sud-est) }
Function GetNeighbor(Index: Integer; Direction: Integer): Integer;
Begin
  GetNeighbor := -1; { -1 = pas de voisin }

  Case Index of
    { Rangée 0 : 3 hexagones (0-2) }
    0: Case Direction of
         2: GetNeighbor := 1;      { E -> horizontalement à droite }
         4: GetNeighbor := 3;      { S -> rangée 1, pos 0 }
         5: GetNeighbor := 4;      { D -> rangée 1, pos 0+1 }
       End;
    1: Case Direction of
         2: GetNeighbor := 2;      { E -> horizontalement à droite }
         3: GetNeighbor := 0;      { A -> horizontalement à gauche }
         4: GetNeighbor := 4;      { S -> rangée 1, pos 1 }
         5: GetNeighbor := 5;      { D -> rangée 1, pos 1+1 }
       End;
    2: Case Direction of
         3: GetNeighbor := 1;      { A -> horizontalement à gauche }
         4: GetNeighbor := 5;      { S -> rangée 1, pos 2 }
         5: GetNeighbor := 6;      { D -> rangée 1, pos 2+1 }
       End;

    { Rangée 1 : 4 hexagones (3-6) }
    3: Case Direction of
         1: GetNeighbor := 0;      { W -> rangée 0, pos 0 }
         2: GetNeighbor := 4;      { E -> horizontalement à droite }
         4: GetNeighbor := 7;      { S -> rangée 2, pos 0 }
         5: GetNeighbor := 8;      { D -> rangée 2, pos 0+1 }
       End;
    4: Case Direction of
         0: GetNeighbor := 0;      { Q -> rangée 0, pos 0 }
         1: GetNeighbor := 1;      { W -> rangée 0, pos 1 }
         2: GetNeighbor := 5;      { E -> horizontalement à droite }
         3: GetNeighbor := 3;      { A -> horizontalement à gauche }
         4: GetNeighbor := 8;      { S -> rangée 2, pos 1 }
         5: GetNeighbor := 9;      { D -> rangée 2, pos 1+1 }
       End;
    5: Case Direction of
         0: GetNeighbor := 1;      { Q -> rangée 0, pos 1 }
         1: GetNeighbor := 2;      { W -> rangée 0, pos 2 }
         2: GetNeighbor := 6;      { E -> horizontalement à droite }
         3: GetNeighbor := 4;      { A -> horizontalement à gauche }
         4: GetNeighbor := 9;      { S -> rangée 2, pos 2 }
         5: GetNeighbor := 10;     { D -> rangée 2, pos 2+1 }
       End;
    6: Case Direction of
         0: GetNeighbor := 2;      { Q -> rangée 0, pos 2 }
         3: GetNeighbor := 5;      { A -> horizontalement à gauche }
         4: GetNeighbor := 10;     { S -> rangée 2, pos 3 }
         5: GetNeighbor := 11;     { D -> rangée 2, pos 3+1 }
       End;

    { Rangée 2 : 5 hexagones - centre (7-11) }
    7: Case Direction of
         0: GetNeighbor := 3;      { Q -> rangée 1, pos 0 }
         1: GetNeighbor := 12;     { W -> rangée 3, pos 0 }
         2: GetNeighbor := 8;      { E -> horizontalement à droite }
         4: GetNeighbor := 13;     { S -> rangée 3, pos 0+1 }
       End;
    8: Case Direction of
         0: GetNeighbor := 3;      { Q -> rangée 1, pos 0 }
         1: GetNeighbor := 4;      { W -> rangée 1, pos 1 }
         2: GetNeighbor := 9;      { E -> horizontalement à droite }
         3: GetNeighbor := 7;      { A -> horizontalement à gauche }
         4: GetNeighbor := 12;     { S -> rangée 3, pos 0 }
         5: GetNeighbor := 13;     { D -> rangée 3, pos 1 }
       End;
    9: Case Direction of
         0: GetNeighbor := 4;      { Q -> rangée 1, pos 1 }
         1: GetNeighbor := 5;      { W -> rangée 1, pos 2 }
         2: GetNeighbor := 10;     { E -> horizontalement à droite }
         3: GetNeighbor := 8;      { A -> horizontalement à gauche }
         4: GetNeighbor := 13;     { S -> rangée 3, pos 1 }
         5: GetNeighbor := 14;     { D -> rangée 3, pos 2 }
       End;
    10: Case Direction of
         0: GetNeighbor := 5;      { Q -> rangée 1, pos 2 }
         1: GetNeighbor := 6;      { W -> rangée 1, pos 3 }
         2: GetNeighbor := 11;     { E -> horizontalement à droite }
         3: GetNeighbor := 9;      { A -> horizontalement à gauche }
         4: GetNeighbor := 14;     { S -> rangée 3, pos 2 }
         5: GetNeighbor := 15;     { D -> rangée 3, pos 3 }
       End;
    11: Case Direction of
         0: GetNeighbor := 6;      { Q -> rangée 1, pos 3 }
         3: GetNeighbor := 10;     { A -> horizontalement à gauche }
         4: GetNeighbor := 15;     { S -> rangée 3, pos 3 }
       End;

    { Rangée 3 : 4 hexagones (12-15) }
    12: Case Direction of
         1: GetNeighbor := 7;      { W -> rangée 2, pos 0 }
         2: GetNeighbor := 13;     { E -> horizontalement à droite }
         4: GetNeighbor := 16;     { S -> rangée 4, pos 0 }
         5: GetNeighbor := 17;     { D -> rangée 4, pos 0+1 }
       End;
    13: Case Direction of
         0: GetNeighbor := 7;      { Q -> rangée 2, pos 0 }
         1: GetNeighbor := 8;      { W -> rangée 2, pos 1 }
         2: GetNeighbor := 14;     { E -> horizontalement à droite }
         3: GetNeighbor := 12;     { A -> horizontalement à gauche }
         4: GetNeighbor := 17;     { S -> rangée 4, pos 1 }
       End;
    14: Case Direction of
         0: GetNeighbor := 8;      { Q -> rangée 2, pos 1 }
         1: GetNeighbor := 9;      { W -> rangée 2, pos 2 }
         2: GetNeighbor := 15;     { E -> horizontalement à droite }
         3: GetNeighbor := 13;     { A -> horizontalement à gauche }
         4: GetNeighbor := 17;     { S -> rangée 4, pos 1 }
         5: GetNeighbor := 18;     { D -> rangée 4, pos 2 }
       End;
    15: Case Direction of
         0: GetNeighbor := 9;      { Q -> rangée 2, pos 2 }
         1: GetNeighbor := 10;     { W -> rangée 2, pos 3 }
         3: GetNeighbor := 14;     { A -> horizontalement à gauche }
         4: GetNeighbor := 18;     { S -> rangée 4, pos 2 }
       End;

    { Rangée 4 : 3 hexagones (16-18) }
    16: Case Direction of
         1: GetNeighbor := 12;     { W -> rangée 3, pos 0 }
         2: GetNeighbor := 17;     { E -> horizontalement à droite }
       End;
    17: Case Direction of
         0: GetNeighbor := 12;     { Q -> rangée 3, pos 0 }
         1: GetNeighbor := 13;     { W -> rangée 3, pos 1 }
         2: GetNeighbor := 18;     { E -> horizontalement à droite }
         3: GetNeighbor := 16;     { A -> horizontalement à gauche }
       End;
    18: Case Direction of
         0: GetNeighbor := 13;     { Q -> rangée 3, pos 1 }
         1: GetNeighbor := 14;     { W -> rangée 3, pos 2 }
         3: GetNeighbor := 17;     { A -> horizontalement à gauche }
       End;
  End;
End;

Function CanMove: Boolean;
Var
  I, J, Neighbor: Integer;
Begin
  CanMove := False;

  { Vérifier s'il y a des cases vides }
  If HasEmptyTiles Then Begin
    CanMove := True;
    Exit;
  End;

  { Vérifier s'il y a des mouvements possibles }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    If Grid[I].Active And (Grid[I].Value > 0) Then Begin
      For J := 0 to 5 Do Begin
        Neighbor := GetNeighbor(I, J);
        If (Neighbor >= 0) And Grid[Neighbor].Active Then Begin
          If Grid[Neighbor].Value = Grid[I].Value Then Begin
            CanMove := True;
            Exit;
          End;
        End;
      End;
    End;
  End;
End;

Function MoveInDirection(Direction: Integer): Boolean;
Var
  I, Neighbor: Integer;
  Moved: Boolean;
  TempGrid: THexGrid;
Begin
  Moved := False;

  { Copier la grille actuelle }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    TempGrid[I] := Grid[I];
  End;

  { Déplacer et fusionner les tuiles dans la direction donnée }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    If Grid[I].Active And (Grid[I].Value > 0) Then Begin
      Neighbor := GetNeighbor(I, Direction);
      If (Neighbor >= 0) And Grid[Neighbor].Active Then Begin
        If Grid[Neighbor].Value = 0 Then Begin
          { Case vide : déplacer }
          Grid[Neighbor].Value := Grid[I].Value;
          Grid[I].Value := 0;
          Moved := True;
        End
        Else If Grid[Neighbor].Value = Grid[I].Value Then Begin
          { Même valeur : fusionner }
          Grid[Neighbor].Value := Grid[Neighbor].Value * 2;
          Grid[I].Value := 0;
          Score := Score + Grid[Neighbor].Value;
          Moved := True;

          { Vérifier la victoire }
          If Grid[Neighbor].Value = 2048 Then
            Won := True;
        End;
      End;
    End;
  End;

  { Comme dans le JavaScript, ajouter deux tuiles si un mouvement a eu lieu }
  If Moved Then Begin
    AddRandomTile;
    AddRandomTile;
  End;

  MoveInDirection := Moved;
End;

Procedure NewGame;
Begin
  Score := 0;
  GameOver := False;
  Won := False;
  ShowInstructions := True;  { Afficher les instructions comme dans le JavaScript }
  InitGrid;
End;

Procedure HandleInput;
Var
  Key: Char;
  Moved: Boolean;
Begin
  Moved := False;

  { Gestion du clavier }
  If KeyPressed Then Begin
    Key := ReadKey;
    Case Key Of
      'i', 'I': Begin
        ShowInstructions := Not ShowInstructions;
      End;
      'q', 'Q': Moved := MoveInDirection(0);
      'w', 'W': Moved := MoveInDirection(1);
      'e', 'E': Moved := MoveInDirection(2);
      'a', 'A': Moved := MoveInDirection(3);
      's', 'S': Moved := MoveInDirection(4);
      'd', 'D': Moved := MoveInDirection(5);
      'r', 'R': NewGame;
      #27: Begin
        CloseGraph;
        Halt;
      End;
    End;

    If Moved Then Begin
      { Ajouter deux nouvelles tuiles après chaque mouvement }
      AddRandomTile;
      AddRandomTile;
      Score := Score + 10;
    End;
  End;
End;

BEGIN
  Randomize;
  InitScreen;

  { Initialisation }
  Score := 0;
  BestScore := 0;
  GameOver := False;
  Won := False;
  ShowInstructions := True;

  NewGame;

  { Boucle principale }
  Repeat
    DrawScreen;
    HandleInput;
    Delay(50);
  Until False;
END.
