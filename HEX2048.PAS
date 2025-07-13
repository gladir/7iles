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
  GRID_SIZE = 4;
  HEX_RADIUS = 30;
  CENTER_X = 320;
  CENTER_Y = 240;

Type
  THexGrid = Array[0..GRID_SIZE-1, 0..GRID_SIZE-1] of Integer;
  THexPoint = Record
    X, Y: Integer;
  End;

Var
  Grid: THexGrid;
  Score: LongInt;
  BestScore: LongInt;
  GameOver: Boolean;
  Won: Boolean;

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

Function GetHexCenter(Row, Col: Integer): THexPoint;
Var
  Point: THexPoint;
  OffsetX, OffsetY: Integer;
Begin
  { Calcul des positions hexagonales }
  OffsetX := Col * (HEX_RADIUS * 3 div 2);
  OffsetY := Row * (HEX_RADIUS * 2);
  
  { Décalage pour les rangées impaires }
  If Col Mod 2 = 1 Then
    OffsetY := OffsetY + HEX_RADIUS;
    
  Point.X := CENTER_X - ((GRID_SIZE-1) * HEX_RADIUS * 3 div 4) + OffsetX;
  Point.Y := CENTER_Y - ((GRID_SIZE-1) * HEX_RADIUS) + OffsetY;
  
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

Procedure DrawTile(Row, Col: Integer);
Var
  Point: THexPoint;
  Value: Integer;
  ValueStr: String;
  TextW, TextH: Integer;
Begin
  Point := GetHexCenter(Row, Col);
  Value := Grid[Row, Col];
  
  { Dessiner l'hexagone }
  DrawHexagon(Point.X, Point.Y, HEX_RADIUS-2, GetTileColor(Value), Black);
  
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
  OutTextXY(50, 415, 'Q/W/E - Haut gauche/Haut/Haut droit');
  OutTextXY(50, 430, 'A/S/D - Bas gauche/Bas/Bas droit');
  OutTextXY(50, 445, 'R - Nouveau jeu, ESC - Quitter');
End;

Procedure DrawGrid;
Var
  Row, Col: Integer;
Begin
  For Row := 0 to GRID_SIZE-1 Do Begin
    For Col := 0 to GRID_SIZE-1 Do Begin
      DrawTile(Row, Col);
    End;
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
  Row, Col: Integer;
  EmptyFound: Boolean;
  Attempts: Integer;
Begin
  EmptyFound := False;
  Attempts := 0;
  
  { Chercher une case vide }
  Repeat
    Row := Random(GRID_SIZE);
    Col := Random(GRID_SIZE);
    Inc(Attempts);
    
    If Grid[Row, Col] = 0 Then Begin
      { 90% chance d'avoir un 2, 10% chance d'avoir un 4 }
      If Random(10) = 0 Then
        Grid[Row, Col] := 4
      Else
        Grid[Row, Col] := 2;
      EmptyFound := True;
    End;
  Until EmptyFound Or (Attempts > 100);
End;

Procedure InitGrid;
Var
  Row, Col: Integer;
Begin
  { Vider la grille }
  For Row := 0 to GRID_SIZE-1 Do Begin
    For Col := 0 to GRID_SIZE-1 Do Begin
      Grid[Row, Col] := 0;
    End;
  End;
  
  { Ajouter deux tuiles initiales }
  AddRandomTile;
  AddRandomTile;
End;

Function HasEmptyTiles: Boolean;
Var
  Row, Col: Integer;
Begin
  HasEmptyTiles := False;
  For Row := 0 to GRID_SIZE-1 Do Begin
    For Col := 0 to GRID_SIZE-1 Do Begin
      If Grid[Row, Col] = 0 Then Begin
        HasEmptyTiles := True;
        Exit;
      End;
    End;
  End;
End;

Function CanMove: Boolean;
Var
  Row, Col: Integer;
Begin
  CanMove := False;
  
  { Vérifier s'il y a des cases vides }
  If HasEmptyTiles Then Begin
    CanMove := True;
    Exit;
  End;
  
  { Vérifier s'il y a des mouvements possibles }
  For Row := 0 to GRID_SIZE-1 Do Begin
    For Col := 0 to GRID_SIZE-1 Do Begin
      { Vérifier les directions adjacentes }
      If (Col > 0) And (Grid[Row, Col] = Grid[Row, Col-1]) Then Begin
        CanMove := True;
        Exit;
      End;
      If (Col < GRID_SIZE-1) And (Grid[Row, Col] = Grid[Row, Col+1]) Then Begin
        CanMove := True;
        Exit;
      End;
      If (Row > 0) And (Grid[Row, Col] = Grid[Row-1, Col]) Then Begin
        CanMove := True;
        Exit;
      End;
      If (Row < GRID_SIZE-1) And (Grid[Row, Col] = Grid[Row+1, Col]) Then Begin
        CanMove := True;
        Exit;
      End;
    End;
  End;
End;

Function MoveLeft: Boolean;
Var
  Row, Col, Target: Integer;
  Moved: Boolean;
Begin
  Moved := False;
  
  For Row := 0 to GRID_SIZE-1 Do Begin
    Target := 0;
    For Col := 0 to GRID_SIZE-1 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Col Then Begin
          Grid[Row, Target] := Grid[Row, Col];
          Grid[Row, Col] := 0;
          Moved := True;
        End;
        Inc(Target);
      End;
    End;
    
    { Fusion des tuiles }
    For Col := 0 to GRID_SIZE-2 Do Begin
      If (Grid[Row, Col] <> 0) And (Grid[Row, Col] = Grid[Row, Col+1]) Then Begin
        Grid[Row, Col] := Grid[Row, Col] * 2;
        Grid[Row, Col+1] := 0;
        Score := Score + Grid[Row, Col];
        Moved := True;
        
        { Vérifier la victoire }
        If Grid[Row, Col] = 2048 Then
          Won := True;
      End;
    End;
    
    { Compacter après fusion }
    Target := 0;
    For Col := 0 to GRID_SIZE-1 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Col Then Begin
          Grid[Row, Target] := Grid[Row, Col];
          Grid[Row, Col] := 0;
        End;
        Inc(Target);
      End;
    End;
  End;
  
  MoveLeft := Moved;
End;

Function MoveRight: Boolean;
Var
  Row, Col, Target: Integer;
  Moved: Boolean;
Begin
  Moved := False;
  
  For Row := 0 to GRID_SIZE-1 Do Begin
    Target := GRID_SIZE-1;
    For Col := GRID_SIZE-1 Downto 0 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Col Then Begin
          Grid[Row, Target] := Grid[Row, Col];
          Grid[Row, Col] := 0;
          Moved := True;
        End;
        Dec(Target);
      End;
    End;
    
    { Fusion des tuiles }
    For Col := GRID_SIZE-1 Downto 1 Do Begin
      If (Grid[Row, Col] <> 0) And (Grid[Row, Col] = Grid[Row, Col-1]) Then Begin
        Grid[Row, Col] := Grid[Row, Col] * 2;
        Grid[Row, Col-1] := 0;
        Score := Score + Grid[Row, Col];
        Moved := True;
        
        If Grid[Row, Col] = 2048 Then
          Won := True;
      End;
    End;
    
    { Compacter après fusion }
    Target := GRID_SIZE-1;
    For Col := GRID_SIZE-1 Downto 0 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Col Then Begin
          Grid[Row, Target] := Grid[Row, Col];
          Grid[Row, Col] := 0;
        End;
        Dec(Target);
      End;
    End;
  End;
  
  MoveRight := Moved;
End;

Function MoveUp: Boolean;
Var
  Row, Col, Target: Integer;
  Moved: Boolean;
Begin
  Moved := False;
  
  For Col := 0 to GRID_SIZE-1 Do Begin
    Target := 0;
    For Row := 0 to GRID_SIZE-1 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Row Then Begin
          Grid[Target, Col] := Grid[Row, Col];
          Grid[Row, Col] := 0;
          Moved := True;
        End;
        Inc(Target);
      End;
    End;
    
    { Fusion des tuiles }
    For Row := 0 to GRID_SIZE-2 Do Begin
      If (Grid[Row, Col] <> 0) And (Grid[Row, Col] = Grid[Row+1, Col]) Then Begin
        Grid[Row, Col] := Grid[Row, Col] * 2;
        Grid[Row+1, Col] := 0;
        Score := Score + Grid[Row, Col];
        Moved := True;
        
        If Grid[Row, Col] = 2048 Then
          Won := True;
      End;
    End;
    
    { Compacter après fusion }
    Target := 0;
    For Row := 0 to GRID_SIZE-1 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Row Then Begin
          Grid[Target, Col] := Grid[Row, Col];
          Grid[Row, Col] := 0;
        End;
        Inc(Target);
      End;
    End;
  End;
  
  MoveUp := Moved;
End;

Function MoveDown: Boolean;
Var
  Row, Col, Target: Integer;
  Moved: Boolean;
Begin
  Moved := False;
  
  For Col := 0 to GRID_SIZE-1 Do Begin
    Target := GRID_SIZE-1;
    For Row := GRID_SIZE-1 Downto 0 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Row Then Begin
          Grid[Target, Col] := Grid[Row, Col];
          Grid[Row, Col] := 0;
          Moved := True;
        End;
        Dec(Target);
      End;
    End;
    
    { Fusion des tuiles }
    For Row := GRID_SIZE-1 Downto 1 Do Begin
      If (Grid[Row, Col] <> 0) And (Grid[Row, Col] = Grid[Row-1, Col]) Then Begin
        Grid[Row, Col] := Grid[Row, Col] * 2;
        Grid[Row-1, Col] := 0;
        Score := Score + Grid[Row, Col];
        Moved := True;
        
        If Grid[Row, Col] = 2048 Then
          Won := True;
      End;
    End;
    
    { Compacter après fusion }
    Target := GRID_SIZE-1;
    For Row := GRID_SIZE-1 Downto 0 Do Begin
      If Grid[Row, Col] <> 0 Then Begin
        If Target <> Row Then Begin
          Grid[Target, Col] := Grid[Row, Col];
          Grid[Row, Col] := 0;
        End;
        Dec(Target);
      End;
    End;
  End;
  
  MoveDown := Moved;
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
      'Q': Moved := MoveUp;          { Haut-gauche simulé }
      'W': Moved := MoveUp;          { Haut }
      'E': Moved := MoveUp;          { Haut-droite simulé }
      'A': Moved := MoveLeft;        { Gauche }
      'S': Moved := MoveDown;        { Bas }
      'D': Moved := MoveRight;       { Droite }
      'R': Begin                     { Nouveau jeu }
        NewGame;
        Exit;
      End;
      #27: Begin                     { Échap }
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