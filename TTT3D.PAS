{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program TTR3D;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  GRID_SIZE = 4;
  CELL_SIZE = 40;
  LAYER_OFFSET = 100;
  MAX_PLAYERS = 2;
  CUBE_OFFSET_X = 300;  { Position X du cube 3D }
  CUBE_OFFSET_Y = 450;  { Position Y du cube 3D }
  CUBE_SIZE_3D = 100;   { Taille du cube 3D }
  PERSPECTIVE = 0.5;    { Facteur de perspective }

Type
  TPlayer = (Human, Computer);
  TSymbol = (Empty, X, O);
  TGrid = Array[0..GRID_SIZE-1, 0..GRID_SIZE-1, 0..GRID_SIZE-1] of TSymbol;
  TPosition = Record
    X, Y, Z: Integer;
  End;

Var
  Grid: TGrid;
  CurrentPlayer: Integer;
  PlayerType: Array[1..2] of TPlayer;
  CurrentLayer: Integer;
  GameOver: Boolean;
  Winner: Integer;
  SelectedX, SelectedY: Integer;
  CursorVisible: Boolean;
  CursorTimer: Integer;

Procedure InitScr;
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

Function IsValidMove(X, Y, Z: Integer): Boolean;
Begin
  IsValidMove := (X >= 0) and (X < GRID_SIZE) and
                 (Y >= 0) and (Y < GRID_SIZE) and
                 (Z >= 0) and (Z < GRID_SIZE) and
                 (Grid[X,Y,Z] = Empty);
End;

Procedure DrawLayer(LayerNum, OffsetX: Integer);
Var
  I, J, BaseX, BaseY: Integer;
Begin
  BaseX := OffsetX;
  BaseY := 100;

  { Titre du niveau }
  SetColor(White);
  OutTextXY(BaseX + (GRID_SIZE*CELL_SIZE) div 2 - 20, BaseY - 20, 'Niveau ' + Chr(LayerNum + Ord('1')));

  { Grille }
  SetColor(LightGray);
  For I := 0 to GRID_SIZE do Begin
    Line(BaseX, BaseY + I*CELL_SIZE, BaseX + GRID_SIZE*CELL_SIZE, BaseY + I*CELL_SIZE);
    Line(BaseX + I*CELL_SIZE, BaseY, BaseX + I*CELL_SIZE, BaseY + GRID_SIZE*CELL_SIZE);
  End;

  { Symboles }
  For I := 0 to GRID_SIZE-1 do Begin
    For J := 0 to GRID_SIZE-1 do Begin
      Case Grid[I,J,LayerNum] of
        X: Begin
          SetColor(LightRed);
          Line(BaseX + I*CELL_SIZE + 5, BaseY + J*CELL_SIZE + 5,
               BaseX + (I+1)*CELL_SIZE - 5, BaseY + (J+1)*CELL_SIZE - 5);
          Line(BaseX + (I+1)*CELL_SIZE - 5, BaseY + J*CELL_SIZE + 5,
               BaseX + I*CELL_SIZE + 5, BaseY + (J+1)*CELL_SIZE - 5);
        End;
        O: Begin
          SetColor(LightBlue);
          Circle(BaseX + I*CELL_SIZE + CELL_SIZE div 2,
                BaseY + J*CELL_SIZE + CELL_SIZE div 2, CELL_SIZE div 2 - 5);
        End;
      End;
    End;
  End;

  { Curseur clignotant }
  If (LayerNum = CurrentLayer) and CursorVisible and
     (SelectedX >= 0) and (SelectedY >= 0) Then Begin
    SetColor(Yellow);
    Rectangle(BaseX + SelectedX*CELL_SIZE, BaseY + SelectedY*CELL_SIZE,
             BaseX + (SelectedX+1)*CELL_SIZE, BaseY + (SelectedY+1)*CELL_SIZE);
  End;
End;

Procedure Draw3DCube;
Var 
  I, J, K: Integer;
  X1, Y1, X2, Y2: Integer;
  OffsetX, OffsetY: Integer;
Begin
  { Position de base du cube }
  OffsetX := CUBE_OFFSET_X;
  OffsetY := CUBE_OFFSET_Y;

  SetColor(LightGray);

  { Face avant }
  Rectangle(OffsetX, OffsetY - CUBE_SIZE_3D,
           OffsetX + CUBE_SIZE_3D, OffsetY);

  { Face arrière }
  Rectangle(OffsetX + Round(CUBE_SIZE_3D * PERSPECTIVE),
           OffsetY - Round(CUBE_SIZE_3D * (1 + PERSPECTIVE)),
           OffsetX + Round(CUBE_SIZE_3D * (1 + PERSPECTIVE)),
           OffsetY - Round(CUBE_SIZE_3D * PERSPECTIVE));

  { Lignes de connexion }
  For I := 0 To 1 do
    For J := 0 To 1 do Begin
      Line(OffsetX + I*CUBE_SIZE_3D,
           OffsetY - J*CUBE_SIZE_3D,
           OffsetX + Round(CUBE_SIZE_3D * (PERSPECTIVE + I)),
           OffsetY - Round(CUBE_SIZE_3D * (PERSPECTIVE + J)));
    End;

  { Dessiner les symboles dans le cube 3D }
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do
      For J := 0 to GRID_SIZE-1 do
        If Grid[I,J,K] <> Empty Then Begin
          X1 := OffsetX + Round((I * CUBE_SIZE_3D/GRID_SIZE));
          Y1 := OffsetY - Round((J * CUBE_SIZE_3D/GRID_SIZE));
          X2 := X1 + Round((K * CUBE_SIZE_3D/GRID_SIZE * PERSPECTIVE));
          Y2 := Y1 - Round((K * CUBE_SIZE_3D/GRID_SIZE * PERSPECTIVE));
          
          If Grid[I,J,K] = X Then Begin
            SetColor(LightRed);
            Line(X2-3, Y2-3, X2+3, Y2+3);
            Line(X2-3, Y2+3, X2+3, Y2-3);
          End Else Begin
            SetColor(LightBlue);
            Circle(X2, Y2, 3);
          End;
        End;
End;

Procedure Draw3DGrid;
Var
  I: Integer;
  PlayerSymbol: String[1];
Begin
  ClearDevice;
  
  { Dessiner les 4 niveaux côte à côte }
  For I := 0 to GRID_SIZE-1 do
    DrawLayer(I, 20 + I*(GRID_SIZE*CELL_SIZE + 20));

  { Dessiner le cube 3D }
  Draw3DCube;
  
  { Préparer le symbole du joueur }
  If CurrentPlayer = 1 Then PlayerSymbol := 'X'
                      Else PlayerSymbol := 'O';

  { Légende et contrôles }
  SetColor(White);
  OutTextXY(20, 20, 'Joueur ' + Chr(CurrentPlayer + Ord('0')) +
            ' (' + PlayerSymbol + ')');

  { Mise à jour du timer du curseur }
  Inc(CursorTimer);
  If CursorTimer >= 10 Then Begin
    CursorVisible := Not CursorVisible;
    CursorTimer := 0;
  End;
End;

Function CheckWin: Boolean;
Var
  I, J, K: Integer;
  S: TSymbol;
Begin
  CheckWin := False;

  { Vérification horizontale dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do Begin
      S := Grid[0,I,K];
      If S <> Empty Then Begin
        CheckWin := True;
        For J := 1 to GRID_SIZE-1 do
          If Grid[J,I,K] <> S Then Begin
            CheckWin := False;
            Break;
          End;
        If CheckWin Then Exit;
      End;
    End;

  { Vérification verticale dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do Begin
      S := Grid[I,0,K];
      If S <> Empty Then Begin
        CheckWin := True;
        For J := 1 to GRID_SIZE-1 do
          If Grid[I,J,K] <> S Then Begin
            CheckWin := False;
            Break;
          End;
        If CheckWin Then Exit;
      End;
    End;

  { Vérification des diagonales dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do Begin
    S := Grid[0,0,K];
    If S <> Empty Then Begin
      CheckWin := True;
      For I := 1 to GRID_SIZE-1 do
        If Grid[I,I,K] <> S Then Begin
          CheckWin := False;
          Break;
        End;
      If CheckWin Then Exit;
    End;

    S := Grid[0,GRID_SIZE-1,K];
    If S <> Empty Then Begin
      CheckWin := True;
      For I := 1 to GRID_SIZE-1 do
        If Grid[I,GRID_SIZE-1-I,K] <> S Then Begin
          CheckWin := False;
          Break;
        End;
      If CheckWin Then Exit;
    End;
  End;

  { Vérification diagonale à travers les niveaux }
  S := Grid[0,0,0];
  If S <> Empty Then Begin
    CheckWin := True;
    For I := 1 to GRID_SIZE-1 do
      If Grid[I,I,I] <> S Then Begin
        CheckWin := False;
        Break;
      End;
    If CheckWin Then Exit;
  End;

  S := Grid[0,GRID_SIZE-1,0];
  If S <> Empty Then Begin
    CheckWin := True;
    For I := 1 to GRID_SIZE-1 do
      If Grid[I,GRID_SIZE-1-I,I] <> S Then Begin
        CheckWin := False;
        Break;
      End;
    If CheckWin Then Exit;
  End;
End;

Function MakeComputerMove: TPosition;
Var
  Pos: TPosition;
  X, Y, Z: Integer;
Begin
  { Implémentation simple : choisir la première case vide }
  For X := 0 to GRID_SIZE-1 do
    For Y := 0 to GRID_SIZE-1 do
      For Z := 0 to GRID_SIZE-1 do
        If Grid[X, Y, Z] = Empty Then Begin
          Pos.X := X;
          Pos.Y := Y;
          Pos.Z := Z;
          MakeComputerMove := Pos;
          Exit;
        End;
End;

Procedure HandleInput;
Var
  Key: Char;
  ComputerMove: TPosition;
  Symbol: TSymbol;
Begin
  If KeyPressed Then Begin
    Key := ReadKey;
    Case Key of
      #0: Case ReadKey of
        #72: If SelectedY > 0 Then Dec(SelectedY);           { Up }
        #80: If SelectedY < GRID_SIZE-1 Then Inc(SelectedY); { Down }
        #75: If SelectedX > 0 Then Dec(SelectedX);           { Left }
        #77: If SelectedX < GRID_SIZE-1 Then Inc(SelectedX); { Right }
        #73: If CurrentLayer < GRID_SIZE-1 Then Inc(CurrentLayer); { PgUp }
        #81: If CurrentLayer > 0 Then Dec(CurrentLayer);          { PgDn }
      End;
      #13: Begin { Enter }
        If IsValidMove(SelectedX, SelectedY, CurrentLayer) Then Begin
          If CurrentPlayer = 1 Then Symbol := X
                              Else Symbol := O;
          Grid[SelectedX, SelectedY, CurrentLayer] := Symbol;
          If CheckWin Then GameOver := True
                     Else CurrentPlayer := 3 - CurrentPlayer;
        End;
      End;
      #27: GameOver := True; { Escape }
    End;
  End;

  If Not GameOver And (PlayerType[CurrentPlayer] = Computer) Then Begin
    ComputerMove := MakeComputerMove;
    If CurrentPlayer = 1 Then Symbol := X
                        Else Symbol := O;
    Grid[ComputerMove.X, ComputerMove.Y, ComputerMove.Z] := Symbol;
    If CheckWin Then GameOver := True
                Else CurrentPlayer := 3 - CurrentPlayer;
  End;
End;

Procedure InitializeGame;
Var
 I,J,K:Integer;
Begin
  For I := 0 to GRID_SIZE-1 do
    For J := 0 to GRID_SIZE-1 do
      For K := 0 to GRID_SIZE-1 do
        Grid[I,J,K] := Empty;
  CurrentPlayer := 1;
  CurrentLayer := 0;
  GameOver := False;
  Winner := 0;
  CursorVisible := True;
  CursorTimer := 0;
  SelectedX := 0;
  SelectedY := 0;
End;

BEGIN
  InitScr;
  InitializeGame;
  PlayerType[1] := Human;
  PlayerType[2] := Computer;

  Repeat
    Draw3DGrid;
    HandleInput;
    Delay(50);
  Until GameOver;

  CloseGraph;
END.
