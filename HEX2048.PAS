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
    Value: Integer;       { Valeur de la tuile }
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

Procedure InitHexGrid;
Var
  I: Integer;
  Row, Col: Integer;
  StartX, StartY: Integer;
  HexWidth, HexHeight: Integer;
Begin
  { Initialiser toutes les cellules comme inactives }
  For I := 0 to MAX_HEXAGONS-1 Do Begin
    Grid[I].Active := False;
    Grid[I].Value := 0;
  End;
  
  { Calcul de l'espacement hexagonal correct }
  HexWidth := Round(HEX_RADIUS * 1.732);  { √3 * rayon }
  HexHeight := Round(HEX_RADIUS * 1.5);   { 3/2 * rayon }
  
  { Disposition hexagonale : 3-4-5-4-3 hexagones par rangée }
  I := 0;
  
  { Rangée 1 : 3 hexagones }
  StartX := CENTER_X - HexWidth;
  StartY := CENTER_Y - HexHeight * 2;
  For Col := 0 to 2 Do Begin
    Grid[I].X := StartX + Col * HexWidth;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;
  
  { Rangée 2 : 4 hexagones }
  StartX := CENTER_X - HexWidth * 3 div 2;
  StartY := CENTER_Y - HexHeight;
  For Col := 0 to 3 Do Begin
    Grid[I].X := StartX + Col * HexWidth;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;
  
  { Rangée 3 : 5 hexagones (centre) }
  StartX := CENTER_X - HexWidth * 2;
  StartY := CENTER_Y;
  For Col := 0 to 4 Do Begin
    Grid[I].X := StartX + Col * HexWidth;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;
  
  { Rangée 4 : 4 hexagones }
  StartX := CENTER_X - HexWidth * 3 div 2;
  StartY := CENTER_Y + HexHeight;
  For Col := 0 to 3 Do Begin
    Grid[I].X := StartX + Col * HexWidth;
    Grid[I].Y := StartY;
    Grid[I].Active := True;
    Inc(I);
  End;
  
  { Rangée 5 : 3 hexagones }
  StartX := CENTER_X - HexWidth;
  StartY := CENTER_Y + HexHeight * 2;
  For Col := 0 to 2 Do Begin
    Grid[I].X := StartX + Col * HexWidth;
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

Function GetTileColor(Value: Integer): Integer;
Begin
  Case Value of
    0: GetTileColor := DarkGray;
    2: GetTileColor := LightGray;
    4: GetTileColor := Yellow;
    8: GetTileColor := Brown;
    16: GetTileColor := Red;
    32: GetTileColor := Magenta;
    64: GetTileColor := Blue;
    128: GetTileColor := Cyan;
    256: GetTileColor := Green;
    512: GetTileColor := LightRed;
    1024: GetTileColor := LightMagenta;
    2048: GetTileColor := LightBlue;
    Else GetTileColor := White;
  End;
End;

Function GetTextColor(Value: Integer): Integer;
Begin
  If Value <= 4 Then
    GetTextColor := Black
  Else
    GetTextColor := White;
End;

Procedure DrawTile(Index: Integer);
Var
  Point: THexPoint;
  Value: Integer;
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
    SetTextStyle(DefaultFont, HorizDir, 1);
    
    { Centrer le texte }
    TextW := Length(ValueStr) * 8;
    TextH := 8;
    OutTextXY(Point.X - TextW div 2, Point.Y - TextH div 2, ValueStr);
  End;
End;

Procedure DrawBackground;
Begin
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
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
  SetColor(LightGray);
  SetTextStyle(DefaultFont, HorizDir, 1);
  
  OutTextXY(50, 400, 'Touches:');
  OutTextXY(50, 415, 'Q - Haut gauche    W - Haut    E - Haut droite');
  OutTextXY(50, 430, 'A - Bas gauche     S - Bas     D - Bas droite');
  OutTextXY(50, 445, 'R - Nouveau jeu, ESC - Quitter');
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

{ Mapping des voisins hexagonaux pour chaque direction }
{ Direction 0=Q (haut-gauche), 1=W (haut), 2=E (haut-droite) }
{ Direction 3=A (bas-gauche), 4=S (bas), 5=D (bas-droite) }
Function GetNeighbor(Index: Integer; Direction: Integer): Integer;
Begin
  GetNeighbor := -1; { -1 = pas de voisin }
  
  Case Index of
    { Rangée 1 (0-2) }
    0: Case Direction of
         1: GetNeighbor := 3;      { W -> haut }
         2: GetNeighbor := 4;      { E -> haut-droite }
         4: GetNeighbor := 3;      { S -> bas }
         5: GetNeighbor := 4;      { D -> bas-droite }
       End;
    1: Case Direction of
         0: GetNeighbor := 3;      { Q -> haut-gauche }
         1: GetNeighbor := 4;      { W -> haut }
         2: GetNeighbor := 5;      { E -> haut-droite }
         3: GetNeighbor := 3;      { A -> bas-gauche }
         4: GetNeighbor := 4;      { S -> bas }
         5: GetNeighbor := 5;      { D -> bas-droite }
       End;
    2: Case Direction of
         0: GetNeighbor := 4;      { Q -> haut-gauche }
         1: GetNeighbor := 5;      { W -> haut }
         3: GetNeighbor := 4;      { A -> bas-gauche }
         4: GetNeighbor := 5;      { S -> bas }
       End;
    
    { Rangée 2 (3-6) }
    3: Case Direction of
         1: GetNeighbor := 0;      { W -> haut }
         2: GetNeighbor := 1;      { E -> haut-droite }
         4: GetNeighbor := 7;      { S -> bas }
         5: GetNeighbor := 8;      { D -> bas-droite }
       End;
    4: Case Direction of
         0: GetNeighbor := 0;      { Q -> haut-gauche }
         1: GetNeighbor := 1;      { W -> haut }
         2: GetNeighbor := 2;      { E -> haut-droite }
         3: GetNeighbor := 7;      { A -> bas-gauche }
         4: GetNeighbor := 8;      { S -> bas }
         5: GetNeighbor := 9;      { D -> bas-droite }
       End;
    5: Case Direction of
         0: GetNeighbor := 1;      { Q -> haut-gauche }
         1: GetNeighbor := 2;      { W -> haut }
         3: GetNeighbor := 8;      { A -> bas-gauche }
         4: GetNeighbor := 9;      { S -> bas }
         5: GetNeighbor := 10;     { D -> bas-droite }
       End;
    6: Case Direction of
         0: GetNeighbor := 2;      { Q -> haut-gauche }
         3: GetNeighbor := 9;      { A -> bas-gauche }
         4: GetNeighbor := 10;     { S -> bas }
         5: GetNeighbor := 11;     { D -> bas-droite }
       End;
    
    { Rangée 3 - Centre (7-11) }
    7: Case Direction of
         1: GetNeighbor := 3;      { W -> haut }
         2: GetNeighbor := 4;      { E -> haut-droite }
         4: GetNeighbor := 12;     { S -> bas }
         5: GetNeighbor := 13;     { D -> bas-droite }
       End;
    8: Case Direction of
         0: GetNeighbor := 3;      { Q -> haut-gauche }
         1: GetNeighbor := 4;      { W -> haut }
         2: GetNeighbor := 5;      { E -> haut-droite }
         3: GetNeighbor := 12;     { A -> bas-gauche }
         4: GetNeighbor := 13;     { S -> bas }
         5: GetNeighbor := 14;     { D -> bas-droite }
       End;
    9: Case Direction of
         0: GetNeighbor := 4;      { Q -> haut-gauche }
         1: GetNeighbor := 5;      { W -> haut }
         2: GetNeighbor := 6;      { E -> haut-droite }
         3: GetNeighbor := 13;     { A -> bas-gauche }
         4: GetNeighbor := 14;     { S -> bas }
         5: GetNeighbor := 15;     { D -> bas-droite }
       End;
    10: Case Direction of
         0: GetNeighbor := 5;      { Q -> haut-gauche }
         1: GetNeighbor := 6;      { W -> haut }
         3: GetNeighbor := 14;     { A -> bas-gauche }
         4: GetNeighbor := 15;     { S -> bas }
         5: GetNeighbor := 16;     { D -> bas-droite }
       End;
    11: Case Direction of
         0: GetNeighbor := 6;      { Q -> haut-gauche }
         3: GetNeighbor := 15;     { A -> bas-gauche }
         4: GetNeighbor := 16;     { S -> bas }
       End;
    
    { Rangée 4 (12-15) }
    12: Case Direction of
         1: GetNeighbor := 7;      { W -> haut }
         2: GetNeighbor := 8;      { E -> haut-droite }
         4: GetNeighbor := 17;     { S -> bas }
         5: GetNeighbor := 18;     { D -> bas-droite }
       End;
    13: Case Direction of
         0: GetNeighbor := 7;      { Q -> haut-gauche }
         1: GetNeighbor := 8;      { W -> haut }
         2: GetNeighbor := 9;      { E -> haut-droite }
         3: GetNeighbor := 17;     { A -> bas-gauche }
         4: GetNeighbor := 18;     { S -> bas }
         5: GetNeighbor := 19;     { D -> bas-droite }
       End;
    14: Case Direction of
         0: GetNeighbor := 8;      { Q -> haut-gauche }
         1: GetNeighbor := 9;      { W -> haut }
         2: GetNeighbor := 10;     { E -> haut-droite }
         3: GetNeighbor := 18;     { A -> bas-gauche }
         4: GetNeighbor := 19;     { S -> bas }
       End;
    15: Case Direction of
         0: GetNeighbor := 9;      { Q -> haut-gauche }
         1: GetNeighbor := 10;     { W -> haut }
         2: GetNeighbor := 11;     { E -> haut-droite }
         3: GetNeighbor := 18;     { A -> bas-gauche }
         4: GetNeighbor := 19;     { S -> bas }
       End;
    16: Case Direction of
         0: GetNeighbor := 10;     { Q -> haut-gauche }
         1: GetNeighbor := 11;     { W -> haut }
         3: GetNeighbor := 19;     { A -> bas-gauche }
       End;
    
    { Rangée 5 (17-19) }
    17: Case Direction of
         1: GetNeighbor := 12;     { W -> haut }
         2: GetNeighbor := 13;     { E -> haut-droite }
       End;
    18: Case Direction of
         0: GetNeighbor := 12;     { Q -> haut-gauche }
         1: GetNeighbor := 13;     { W -> haut }
         2: GetNeighbor := 14;     { E -> haut-droite }
       End;
    19: Case Direction of
         0: GetNeighbor := 13;     { Q -> haut-gauche }
         1: GetNeighbor := 14;     { W -> haut }
         2: GetNeighbor := 15;     { E -> haut-droite }
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
  
  MoveInDirection := Moved;
End;

Procedure NewGame;
Begin
  Score := 0;
  GameOver := False;
  Won := False;
  InitGrid;
End;

Procedure HandleInput;
Var
  Key: Char;
  Moved: Boolean;
Begin
  If KeyPressed Then Begin
    Key := ReadKey;
    Key := UpCase(Key);
    
    Moved := False;
    
    Case Key of
      'Q': Moved := MoveInDirection(0);  { Haut-gauche }
      'W': Moved := MoveInDirection(1);  { Haut }
      'E': Moved := MoveInDirection(2);  { Haut-droite }
      'A': Moved := MoveInDirection(3);  { Bas-gauche }
      'S': Moved := MoveInDirection(4);  { Bas }
      'D': Moved := MoveInDirection(5);  { Bas-droite }
      'R': Begin                         { Nouveau jeu }
        NewGame;
        Exit;
      End;
      #27: Begin                         { Échap }
        CloseGraph;
        Halt;
      End;
    End;
    
    If Moved And Not GameOver And Not Won Then Begin
      AddRandomTile;
      
      If Not CanMove Then
        GameOver := True;
      
      If Score > BestScore Then
        BestScore := Score;
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
  
  NewGame;
  
  { Boucle principale }
  Repeat
    DrawScreen;
    HandleInput;
    Delay(50);
  Until False;
END.