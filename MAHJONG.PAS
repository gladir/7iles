{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program MAHJONG;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  TILES = 52;          { Nombre total de tuiles }
  BOARD_WIDTH = 8;     { Largeur du plateau }
  BOARD_HEIGHT = 8;    { Hauteur du plateau }
  BOARD_DEPTH = 3;    { Nombre de niveaux }
  TILE_WIDTH = 40;     { Largeur d'une tuile }
  TILE_HEIGHT = 30;    { Hauteur d'une tuile }
  TILE_DEPTH = 5;     { Profondeur de l'effet 3D }

Type
  TTile = Record
    Value: Integer;    { Valeur de la tuile (1-26) }
    Visible: Boolean;  { Si la tuile est visible }
    Active: Boolean;   { Si la tuile est encore en jeu }
    Z: Integer;       { Niveau de la tuile }
  End;

  TPoint = record
    x, y: Integer;
  end;

Var
  Board: Array[1..BOARD_WIDTH, 1..BOARD_HEIGHT, 1..BOARD_DEPTH] of TTile;
  CursorX, CursorY: Integer;
  GraphDriver, GraphMode: Integer;
  FirstSelect: Boolean;
  FirstX, FirstY, FirstZ: Integer;
  RemainingTiles: Integer;
  QuitGame: Boolean;  { Nouvelle variable }

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
  i, j, k, z, v: Integer;
Begin
  Randomize;
  RemainingTiles := TILES;

  { Initialiser toutes les tuiles comme inactives }
  For i := 1 To BOARD_WIDTH Do
    For j := 1 To BOARD_HEIGHT Do
      For z := 1 To BOARD_DEPTH Do
        Board[i,j,z].Active := False;

  { Placer les tuiles aléatoirement sur différents niveaux }
  k := 0;
  While k < TILES Do
  Begin
    i := Random(BOARD_WIDTH) + 1;
    j := Random(BOARD_HEIGHT) + 1;
    z := Random(BOARD_DEPTH) + 1;
    If Not Board[i,j,z].Active Then
    Begin
      Board[i,j,z].Active := True;
      Board[i,j,z].Visible := True;
      Board[i,j,z].Value := (k Div 2) + 1;
      Board[i,j,z].Z := z;
      Inc(k);
    End;
  End;
End;

Function IsTileBlocked(x, y, z: Integer): Boolean;
Var
  i: Integer;
Begin
  IsTileBlocked := False;
  { Vérifie si une tuile active existe au-dessus }
  For i := z + 1 To BOARD_DEPTH Do
    If Board[x,y,i].Active Then
    Begin
      IsTileBlocked := True;
      Exit;
    End;
End;

function GetVisibleTileLevel(x, y: Integer): Integer;
var
  z: Integer;
begin
  GetVisibleTileLevel := 0;
  for z := BOARD_DEPTH downto 1 do
    if Board[x,y,z].Active then
    begin
      GetVisibleTileLevel := z;
      Exit;
    end;
end;

function Point(x, y: Integer): TPoint;
begin
  Point.x := x;
  Point.y := y;
end;

Procedure DrawTile(x, y, z: Integer; highlighted: Boolean);
Var
  baseX, baseY: Integer;
  points: array[0..3] of TPoint;
Begin
  If Board[x,y,z].Active Then
  Begin
    baseX := (x-1) * TILE_WIDTH + 10 + (z * 5);  { Décalage en fonction du niveau }
    baseY := (y-1) * TILE_HEIGHT + 10 - (z * 5);

    { Remplir le fond de la tuile }
    SetFillStyle(SolidFill, LightGray);
    Bar(baseX, baseY, baseX + TILE_WIDTH, baseY + TILE_HEIGHT);

    If highlighted Then
      SetColor(Yellow)
    Else
      SetColor(White);

    { Face avant }
    Rectangle(
      baseX,
      baseY,
      baseX + TILE_WIDTH,
      baseY + TILE_HEIGHT
    );

    { Face supérieure 3D avec remplissage }
    points[0] := Point(baseX, baseY);
    points[1] := Point(baseX + TILE_DEPTH, baseY - TILE_DEPTH);
    points[2] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY - TILE_DEPTH);
    points[3] := Point(baseX + TILE_WIDTH, baseY);
    SetFillStyle(SolidFill, LightGray);
    FillPoly(4, points);

    { Face latérale 3D avec remplissage }
    points[0] := Point(baseX + TILE_WIDTH, baseY);
    points[1] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY - TILE_DEPTH);
    points[2] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY + TILE_HEIGHT - TILE_DEPTH);
    points[3] := Point(baseX + TILE_WIDTH, baseY + TILE_HEIGHT);
    SetFillStyle(SolidFill, DarkGray);
    FillPoly(4, points);

    If Board[x,y,z].Visible Then
    Begin
      SetTextStyle(DefaultFont, HorizDir, 2);  { Taille de police augmentée }
      SetColor(Blue);
      OutTextXY(
        baseX + (TILE_WIDTH Div 4),    { Centrage horizontal }
        baseY + (TILE_HEIGHT Div 4),   { Centrage vertical }
        Chr(Board[x,y,z].Value + 64)
      );
    End;
  End;
End;

Procedure DrawBoard;
Var
  i, j, z: Integer;
Begin
  ClearDevice;
  For z := 1 To BOARD_DEPTH Do
    For i := 1 To BOARD_WIDTH Do
      For j := 1 To BOARD_HEIGHT Do
        If Board[i,j,z].Active Then
          DrawTile(i, j, z, (i = CursorX) And (j = CursorY));
End;

Procedure MoveCursor(Var x, y: Integer);
Var
  ch: Char;
  visibleZ: Integer;
Begin
  ch := ReadKey;
  Case ch Of
    #27: QuitGame := True;  { ESC key }
    #0: Case ReadKey Of
      #72: If y > 1 Then Dec(y);           { Up }
      #80: If y < BOARD_HEIGHT Then Inc(y); { Down }
      #75: If x > 1 Then Dec(x);           { Left }
      #77: If x < BOARD_WIDTH Then Inc(x);  { Right }
    End;
    #13: Begin { Enter }
      visibleZ := GetVisibleTileLevel(x, y);
      If (visibleZ > 0) And Not IsTileBlocked(x, y, visibleZ) Then
      Begin
        If Not FirstSelect Then
        Begin
          FirstX := x;
          FirstY := y;
          FirstZ := visibleZ;
          FirstSelect := True;
        End
        Else Begin
          If (Board[FirstX,FirstY,FirstZ].Value = Board[x,y,visibleZ].Value) And
             ((FirstX <> x) Or (FirstY <> y)) And
             Not IsTileBlocked(x, y, visibleZ) Then
          Begin
            Board[FirstX,FirstY,FirstZ].Active := False;
            Board[x,y,visibleZ].Active := False;
            Dec(RemainingTiles, 2);
          End;
          FirstSelect := False;
        End;
      End;
    End;
  End;
End;

BEGIN
  InitializeGraphics;
  InitializeBoard;
  CursorX := 1;
  CursorY := 1;
  FirstSelect := False;
  QuitGame := False;  { Initialisation }

  Repeat
    DrawBoard;
    MoveCursor(CursorX, CursorY);
  Until (RemainingTiles = 0) Or QuitGame;  { Modifié pour inclure QuitGame }

  CloseGraph;
  If RemainingTiles = 0 Then
    WriteLn('Félicitations! Vous avez gagné!')
  Else
    WriteLn('Jeu terminé!');
END.
