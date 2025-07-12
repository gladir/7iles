{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program TTT3D;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
       {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  GRID_SIZE = 4;
  CELL_SIZE = 35;
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
  { Variables pour GetImage/PutImage }
  CursorBackup: Pointer;
  CursorBackupSize: Word;
  LastCursorX, LastCursorY: Integer;
  LastCursorWidth, LastCursorHeight: Integer;
  CursorSaved: Boolean;
  { Variable pour éviter de redessiner le titre }
  TitleDrawn: Boolean;
  { Variable pour éviter de redessiner les infos inutilement }
  LastDisplayedLayer: Integer;
  { Variables pour sauvegarder le cube 3D }
  CubeBackup: Pointer;
  CubeBackupSize: Word;
  CubeSaved: Boolean;
  { Variables pour les 4 niveaux (juste les flags) }
  LayerSaved: Array[0..GRID_SIZE-1] of Boolean;

{ Déclarations forward pour les procedures d'aide }
Procedure SaveCursorArea(X, Y, Width, Height: Integer); Forward;
Procedure RestoreCursorArea; Forward;
Procedure DrawCursor(X, Y, Width, Height: Integer); Forward;
Procedure SaveCubeArea; Forward;
Procedure RestoreCubeArea; Forward;

{ Implémentations des procedures d'aide }
Procedure SaveCursorArea(X, Y, Width, Height: Integer);
Begin
  If CursorSaved Then RestoreCursorArea;

  CursorBackupSize := ImageSize(X, Y, X + Width, Y + Height);
  If CursorBackup <> Nil Then FreeMem(CursorBackup, CursorBackupSize);

  GetMem(CursorBackup, CursorBackupSize);
  GetImage(X, Y, X + Width, Y + Height, CursorBackup^);

  LastCursorX := X;
  LastCursorY := Y;
  CursorSaved := True;
End;

Procedure RestoreCursorArea;
Begin
  If CursorSaved and (CursorBackup <> Nil) Then Begin
    PutImage(LastCursorX, LastCursorY, CursorBackup^, NormalPut);
    CursorSaved := False;
  End;
End;

Procedure DrawCursor(X, Y, Width, Height: Integer);
Begin
  SaveCursorArea(X, Y, Width, Height);
  SetColor(Yellow);
  Rectangle(X, Y, X + Width, Y + Height);
End;

Procedure SaveCubeArea;
Begin
  { Procedure désactivée pour éviter les Access Violations }
  { Le cube 3D sera simplement redessiné à chaque fois }
End;

Procedure RestoreCubeArea;
Begin
  { Procedure désactivée pour éviter les Access Violations }
  { Le cube 3D sera simplement redessiné à chaque fois }
End;

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
  { Vérification de sécurité des indices }
  If (X < 0) or (X >= GRID_SIZE) or
     (Y < 0) or (Y >= GRID_SIZE) or
     (Z < 0) or (Z >= GRID_SIZE) Then Begin
    IsValidMove := False;
    Exit;
  End;

  IsValidMove := (Grid[X,Y,Z] = Empty);
End;

Procedure DrawLayer(LayerNum, OffsetX: Integer);
Var
  I, J, BaseX, BaseY: Integer;
Begin
  { Vérification de sécurité des indices }
  If (LayerNum < 0) or (LayerNum >= GRID_SIZE) Then Exit;

  BaseX := OffsetX;
  BaseY := 315;

  { Dessiner le plateau seulement si nécessaire }
  If Not LayerSaved[LayerNum] Then Begin
    { Effacer seulement cette zone de plateau }
    SetColor(Black);
    SetFillStyle(1, Black);
    Bar(BaseX - 5, BaseY - 25, BaseX + GRID_SIZE*CELL_SIZE + 5, BaseY + GRID_SIZE*CELL_SIZE + 5);

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

    { Marquer comme dessiné }
    LayerSaved[LayerNum] := True;
  End;

  { Curseur clignotant avec GetImage/PutImage }
  If (LayerNum = CurrentLayer) and (SelectedX >= 0) and (SelectedX < GRID_SIZE) and
     (SelectedY >= 0) and (SelectedY < GRID_SIZE) Then Begin
    If CursorVisible Then Begin
      { Sauvegarder la zone si pas déjà fait }
      If Not CursorSaved Then Begin
        SaveCursorArea(BaseX + SelectedX*CELL_SIZE, BaseY + SelectedY*CELL_SIZE,
                       CELL_SIZE, CELL_SIZE);
      End;
      { Dessiner le curseur }
      SetColor(Yellow);
      Rectangle(BaseX + SelectedX*CELL_SIZE, BaseY + SelectedY*CELL_SIZE,
                BaseX + (SelectedX+1)*CELL_SIZE, BaseY + (SelectedY+1)*CELL_SIZE);
    End Else Begin
      { Restaurer la zone sauvegardée pour effacer le curseur }
      RestoreCursorArea;
    End;
  End Else Begin
    { Si ce n'est pas le niveau actuel, s'assurer que le curseur est effacé }
    If CursorSaved Then RestoreCursorArea;
  End;
End;

Procedure Draw3DCube;
Var
  I, J, K: Integer;
  X1, Y1, X2, Y2: Integer;
  OffsetX, OffsetY: Integer;
  GridSize3D: Integer;
Begin
  { Position de base du cube }
  OffsetX := CUBE_OFFSET_X;
  OffsetY := CUBE_OFFSET_Y;
  GridSize3D := CUBE_SIZE_3D div GRID_SIZE;

  SetColor(LightGray);

  { Face avant }
  Rectangle(OffsetX, OffsetY - CUBE_SIZE_3D,
           OffsetX + CUBE_SIZE_3D, OffsetY);

  { Face arrière }
  Rectangle(OffsetX + Round(CUBE_SIZE_3D * PERSPECTIVE),
           OffsetY - Round(CUBE_SIZE_3D * (1 + PERSPECTIVE)),
           OffsetX + Round(CUBE_SIZE_3D * (1 + PERSPECTIVE)),
           OffsetY - Round(CUBE_SIZE_3D * PERSPECTIVE));

  { Lignes de connexion des coins }
  For I := 0 To 1 do
    For J := 0 To 1 do Begin
      Line(OffsetX + I*CUBE_SIZE_3D,
           OffsetY - J*CUBE_SIZE_3D,
           OffsetX + Round(CUBE_SIZE_3D * (PERSPECTIVE + I)),
           OffsetY - Round(CUBE_SIZE_3D * (PERSPECTIVE + J)));
    End;

  { Dessiner la grille sur la face avant }
  For I := 1 to GRID_SIZE-1 do Begin
    Line(OffsetX + I*GridSize3D, OffsetY,
         OffsetX + I*GridSize3D, OffsetY - CUBE_SIZE_3D);
    Line(OffsetX, OffsetY - I*GridSize3D,
         OffsetX + CUBE_SIZE_3D, OffsetY - I*GridSize3D);
  End;

  { Dessiner les grilles des autres faces avec perspective }
  For I := 1 to GRID_SIZE-1 do Begin
    { Face du dessus }
    Line(OffsetX + I*GridSize3D,
         OffsetY - CUBE_SIZE_3D,
         OffsetX + I*GridSize3D + Round(CUBE_SIZE_3D*PERSPECTIVE),
         OffsetY - CUBE_SIZE_3D - Round(CUBE_SIZE_3D*PERSPECTIVE));

    { Face de droite }
    Line(OffsetX + CUBE_SIZE_3D,
         OffsetY - I*GridSize3D,
         OffsetX + CUBE_SIZE_3D + Round(CUBE_SIZE_3D*PERSPECTIVE),
         OffsetY - I*GridSize3D - Round(CUBE_SIZE_3D*PERSPECTIVE));
  End;

  { Dessiner les symboles dans le cube avec perspective }
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do
      For J := 0 to GRID_SIZE-1 do
        If Grid[I,J,K] <> Empty Then Begin
          X1 := OffsetX + I*GridSize3D;
          Y1 := OffsetY - J*GridSize3D;
          X2 := X1 + Round(K*GridSize3D*PERSPECTIVE);
          Y2 := Y1 - Round(K*GridSize3D*PERSPECTIVE);

          If Grid[I,J,K] = X Then Begin
            SetColor(LightRed);
            Line(X2-5, Y2-5, X2+5, Y2+5);
            Line(X2-5, Y2+5, X2+5, Y2-5);
          End Else Begin
            SetColor(LightBlue);
            Circle(X2, Y2, 5);
          End;
        End;
End;

Procedure Draw3DGrid;
Var
  I, J, K: Integer;
  PlayerSymbol: String[1];
  CenterX, CenterY: Integer;
  BackSize, FrontSize: Integer;
  BackX1, BackY1, BackX2, BackY2: Integer;
  FrontX1, FrontY1, FrontX2, FrontY2: Integer;
  GridStep: Integer;
  InterpX, InterpY: Integer;
  BackCellX, BackCellY: Integer;
  FrontCellX, FrontCellY: Integer;
  Factor: Real;
  CursorX, CursorY: Integer;
  CellSize: Integer;
Begin
  { Effacement minimal et ciblé }
  SetColor(Black);
  SetFillStyle(1, Black);

  { Dessiner le titre une seule fois }
  If Not TitleDrawn Then Begin
    { Effacer seulement la zone du titre }
    Bar(0, 0, 640, 100);

    { Dessiner le titre }
    SetColor(Magenta);
    SetTextStyle(0, 0, 2);
    OutTextXY(230, 5, 'Tic-Tac-Toe 3D');
    SetTextStyle(0, 0, 1);
    TitleDrawn := True;
    LastDisplayedLayer := -1; { Forcer la mise à jour des infos }
  End;

  { Mettre à jour les infos seulement si le niveau a changé }
  If CurrentLayer <> LastDisplayedLayer Then Begin
    { Effacer seulement la zone des contrôles (ligne d'info dynamique) }
    Bar(0, 35, 640, 100);

    { Légende et contrôles (info dynamique) }
    SetColor(White);
    SetTextStyle(0, 0, 1);
    OutTextXY(20, 40, '(X) Humain, (O) Ordinateur, Niveau: ' + Chr(CurrentLayer + Ord('1')));
    OutTextXY(20, 60, 'Fleches: deplacer, PgUp/PgDn: changer niveau');
    OutTextXY(20, 80, 'Entree: placer symbole, Echap: quitter');

    LastDisplayedLayer := CurrentLayer;

    { Forcer le redessin du cube 3D car le niveau a changé }
    CubeSaved := False;
    { Forcer le redessin des niveaux }
    For I := 0 to GRID_SIZE-1 do LayerSaved[I] := False;
  End;

  { Dessiner les 4 niveaux côte à côte }
  For I := 0 to GRID_SIZE-1 do
    DrawLayer(I, 5 + I*(GRID_SIZE*CELL_SIZE + 20));

  { Sauvegarder la zone du cube 3D avant de le dessiner }
  { Désactivé pour éviter les Access Violations - le cube sera redessiné à chaque fois }
  { If Not CubeSaved Then SaveCubeArea; }


  { Paramètres de la vue aérienne }
  CenterX := 320;  { Centre de l'écran }
  CenterY := 190;
  BackSize := 200;   { Taille du carré arrière }
  FrontSize := 120;  { Taille du carré avant }

  { Calculer les positions des carrés }
  BackX1 := CenterX - BackSize div 2;
  BackY1 := CenterY - BackSize div 2;
  BackX2 := CenterX + BackSize div 2;
  BackY2 := CenterY + BackSize div 2;

  FrontX1 := CenterX - FrontSize div 2;
  FrontY1 := CenterY - FrontSize div 2;
  FrontX2 := CenterX + FrontSize div 2;
  FrontY2 := CenterY + FrontSize div 2;

  { Dessiner le carré arrière (fond) }
  SetColor(LightGray);
  Rectangle(BackX1, BackY1, BackX2, BackY2);

  { Dessiner la grille du carré arrière }
  GridStep := BackSize div GRID_SIZE;
  For I := 1 to GRID_SIZE-1 do Begin
    Line(BackX1 + I*GridStep, BackY1, BackX1 + I*GridStep, BackY2);
    Line(BackX1, BackY1 + I*GridStep, BackX2, BackY1 + I*GridStep);
  End;

  { Dessiner le carré avant (premier plan) }
  SetColor(White);
  Rectangle(FrontX1, FrontY1, FrontX2, FrontY2);

  { Dessiner la grille du carré avant }
  GridStep := FrontSize div GRID_SIZE;
  For I := 1 to GRID_SIZE-1 do Begin
    Line(FrontX1 + I*GridStep, FrontY1, FrontX1 + I*GridStep, FrontY2);
    Line(FrontX1, FrontY1 + I*GridStep, FrontX2, FrontY1 + I*GridStep);
  End;

  { Dessiner les lignes diagonales de connexion entre les carrés }
  SetColor(DarkGray);
  Line(BackX1, BackY1, FrontX1, FrontY1);  { Coin supérieur gauche }
  Line(BackX2, BackY1, FrontX2, FrontY1);  { Coin supérieur droit }
  Line(BackX1, BackY2, FrontX1, FrontY2);  { Coin inférieur gauche }
  Line(BackX2, BackY2, FrontX2, FrontY2);  { Coin inférieur droit }

  { Dessiner les lignes de grille diagonales }
  GridStep := BackSize div GRID_SIZE;
  For I := 1 to GRID_SIZE-1 do Begin
    { Lignes verticales }
    Line(BackX1 + I*GridStep, BackY1, FrontX1 + I*(FrontSize div GRID_SIZE), FrontY1);
    Line(BackX1 + I*GridStep, BackY2, FrontX1 + I*(FrontSize div GRID_SIZE), FrontY2);
    { Lignes horizontales }
    Line(BackX1, BackY1 + I*GridStep, FrontX1, FrontY1 + I*(FrontSize div GRID_SIZE));
    Line(BackX2, BackY1 + I*GridStep, FrontX2, FrontY1 + I*(FrontSize div GRID_SIZE));
  End;

  { Dessiner les symboles dans le cube 3D }
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do
      For J := 0 to GRID_SIZE-1 do
        If Grid[I,J,K] <> Empty Then Begin
          { Calculer la position interpolée entre arrière et avant }
          { K=0 = arrière, K=3 = avant }
          If GRID_SIZE > 1 Then
            Factor := K / (GRID_SIZE - 1)
          Else
            Factor := 0;

          { Position dans le carré arrière }
          If GRID_SIZE > 0 Then Begin
            BackCellX := BackX1 + I * (BackSize div GRID_SIZE) + (BackSize div GRID_SIZE) div 2;
            BackCellY := BackY1 + J * (BackSize div GRID_SIZE) + (BackSize div GRID_SIZE) div 2;

            { Position dans le carré avant }
            FrontCellX := FrontX1 + I * (FrontSize div GRID_SIZE) + (FrontSize div GRID_SIZE) div 2;
            FrontCellY := FrontY1 + J * (FrontSize div GRID_SIZE) + (FrontSize div GRID_SIZE) div 2;
          End Else Begin
            BackCellX := BackX1;
            BackCellY := BackY1;
            FrontCellX := FrontX1;
            FrontCellY := FrontY1;
          End;

          { Interpolation }
          InterpX := Round(BackCellX + Factor * (FrontCellX - BackCellX));
          InterpY := Round(BackCellY + Factor * (FrontCellY - BackCellY));

          { Dessiner le symbole }
          If Grid[I,J,K] = X Then Begin
            SetColor(LightRed);
            Line(InterpX-8, InterpY-8, InterpX+8, InterpY+8);
            Line(InterpX-8, InterpY+8, InterpX+8, InterpY-8);
          End Else Begin
            SetColor(LightBlue);
            Circle(InterpX, InterpY, 8);
          End;
        End;

  { Dessiner le curseur sur le niveau actuel }
  If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) and CursorVisible and
     (SelectedX >= 0) and (SelectedX < GRID_SIZE) and
     (SelectedY >= 0) and (SelectedY < GRID_SIZE) Then Begin
    If GRID_SIZE > 1 Then
      Factor := CurrentLayer / (GRID_SIZE - 1)
    Else
      Factor := 0;

    { Position dans le carré arrière }
    If GRID_SIZE > 0 Then Begin
      BackCellX := BackX1 + SelectedX * (BackSize div GRID_SIZE);
      BackCellY := BackY1 + SelectedY * (BackSize div GRID_SIZE);

      { Position dans le carré avant }
      FrontCellX := FrontX1 + SelectedX * (FrontSize div GRID_SIZE);
      FrontCellY := FrontY1 + SelectedY * (FrontSize div GRID_SIZE);
    End Else Begin
      BackCellX := BackX1;
      BackCellY := BackY1;
      FrontCellX := FrontX1;
      FrontCellY := FrontY1;
    End;

    { Interpolation }
    CursorX := Round(BackCellX + Factor * (FrontCellX - BackCellX));
    CursorY := Round(BackCellY + Factor * (FrontCellY - BackCellY));

    { Dessiner le curseur avec sauvegarde/restauration }
    SetColor(Yellow);
    If GRID_SIZE > 0 Then Begin
      If CurrentLayer = 0 Then
        CellSize := BackSize div GRID_SIZE
      Else If CurrentLayer = GRID_SIZE-1 Then
        CellSize := FrontSize div GRID_SIZE
      Else
        CellSize := Round((BackSize div GRID_SIZE) + Factor * ((FrontSize div GRID_SIZE) - (BackSize div GRID_SIZE)));
    End Else Begin
      CellSize := 20; { Taille par défaut }
    End;

    DrawCursor(CursorX, CursorY, CellSize, CellSize);
  End;

  { Préparer le symbole du joueur }
  If CurrentPlayer = 1 Then PlayerSymbol := 'X'
                      Else PlayerSymbol := 'O';

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
  Row, Col: Integer;
  S: TSymbol;
Begin
  CheckWin := False;
  Winner := 0;

  { Vérification de sécurité des indices }
  If GRID_SIZE <= 0 Then Exit;

  { Vérification horizontale dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do
    For Row := 0 to GRID_SIZE-1 do Begin
      If (Row >= 0) and (Row < GRID_SIZE) and (K >= 0) and (K < GRID_SIZE) Then Begin
        S := Grid[0,Row,K];
        If S <> Empty Then Begin
          CheckWin := True;
          For Col := 1 to GRID_SIZE-1 do
            If (Col >= 0) and (Col < GRID_SIZE) and (Row >= 0) and
               (Row < GRID_SIZE) and (K >= 0) and (K < GRID_SIZE) and (Grid[Col,Row,K] <> S) Then Begin
              CheckWin := False;
              Break;
            End;
          If CheckWin Then Begin
            If S = X Then Winner := 1 Else Winner := 2;
            Exit;
          End;
        End;
      End;
    End;

  { Vérification verticale dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do
    For Col := 0 to GRID_SIZE-1 do Begin
      If (Col >= 0) and (Col < GRID_SIZE) and (K >= 0) and (K < GRID_SIZE) Then Begin
        S := Grid[Col,0,K];
        If S <> Empty Then Begin
          CheckWin := True;
          For Row := 1 to GRID_SIZE-1 do
            If (Col >= 0) and (Col < GRID_SIZE) and (Row >= 0) and (Row < GRID_SIZE) and (K >= 0) and
               (K < GRID_SIZE) and (Grid[Col,Row,K] <> S) Then Begin
              CheckWin := False;
              Break;
            End;
          If CheckWin Then Begin
            If S = X Then Winner := 1 Else Winner := 2;
            Exit;
          End;
        End;
      End;
    End;

  { Vérification des diagonales dans chaque niveau }
  For K := 0 to GRID_SIZE-1 do Begin
    If (K >= 0) and (K < GRID_SIZE) Then Begin
      S := Grid[0,0,K];
      If S <> Empty Then Begin
        CheckWin := True;
        For I := 1 to GRID_SIZE-1 do
          If (I >= 0) and (I < GRID_SIZE) and (K >= 0) and (K < GRID_SIZE) and (Grid[I,I,K] <> S) Then Begin
            CheckWin := False;
            Break;
          End;
        If CheckWin Then Begin
          If S = X Then Winner := 1 Else Winner := 2;
          Exit;
        End;
      End;

      If (GRID_SIZE > 1) and (GRID_SIZE-1 >= 0) and (GRID_SIZE-1 < GRID_SIZE) and (K >= 0) and (K < GRID_SIZE) Then Begin
        S := Grid[0,GRID_SIZE-1,K];
        If S <> Empty Then Begin
          CheckWin := True;
          For I := 1 to GRID_SIZE-1 do
            If (I >= 0) and (I < GRID_SIZE) and (GRID_SIZE-1-I >= 0) and (GRID_SIZE-1-I < GRID_SIZE) and (K >= 0) and
               (K < GRID_SIZE) and (Grid[I,GRID_SIZE-1-I,K] <> S) Then Begin
              CheckWin := False;
              Break;
            End;
          If CheckWin Then Begin
            If S = X Then Winner := 1 Else Winner := 2;
            Exit;
          End;
        End;
      End;
    End;
  End;

  { Vérification diagonale à travers les niveaux }
  S := Grid[0,0,0];
  If S <> Empty Then Begin
    CheckWin := True;
    For I := 1 to GRID_SIZE-1 do
      If (I >= 0) and (I < GRID_SIZE) and (Grid[I,I,I] <> S) Then Begin
        CheckWin := False;
        Break;
      End;
    If CheckWin Then Begin
      If S = X Then Winner := 1 Else Winner := 2;
      Exit;
    End;
  End;

  If (GRID_SIZE > 1) and (GRID_SIZE-1 >= 0) and (GRID_SIZE-1 < GRID_SIZE) Then Begin
    S := Grid[0,GRID_SIZE-1,0];
    If S <> Empty Then Begin
      CheckWin := True;
      For I := 1 to GRID_SIZE-1 do
        If (I >= 0) and (I < GRID_SIZE) and (GRID_SIZE-1-I >= 0) and
           (GRID_SIZE-1-I < GRID_SIZE) and (Grid[I,GRID_SIZE-1-I,I] <> S) Then Begin
          CheckWin := False;
          Break;
        End;
      If CheckWin Then Begin
        If S = X Then Winner := 1 Else Winner := 2;
        Exit;
      End;
    End;

    { Diagonale 3D: Grid[0,0,GRID_SIZE-1] vers Grid[GRID_SIZE-1,GRID_SIZE-1,0] }
    S := Grid[0,0,GRID_SIZE-1];
    If S <> Empty Then Begin
      CheckWin := True;
      For I := 1 to GRID_SIZE-1 do
        If (I >= 0) and (I < GRID_SIZE) and (GRID_SIZE-1-I >= 0) and
           (GRID_SIZE-1-I < GRID_SIZE) and (Grid[I,I,GRID_SIZE-1-I] <> S) Then Begin
          CheckWin := False;
          Break;
        End;
      If CheckWin Then Begin
        If S = X Then Winner := 1 Else Winner := 2;
        Exit;
      End;
    End;

    { Diagonale 3D: Grid[GRID_SIZE-1,0,0] vers Grid[0,GRID_SIZE-1,GRID_SIZE-1] }
    S := Grid[GRID_SIZE-1,0,0];
    If S <> Empty Then Begin
      CheckWin := True;
      For I := 1 to GRID_SIZE-1 do
        If (GRID_SIZE-1-I >= 0) and (GRID_SIZE-1-I < GRID_SIZE) and
           (I >= 0) and (I < GRID_SIZE) and (Grid[GRID_SIZE-1-I,I,I] <> S) Then Begin
          CheckWin := False;
          Break;
        End;
      If CheckWin Then Begin
        If S = X Then Winner := 1 Else Winner := 2;
        Exit;
      End;
    End;
  End;
End;

Procedure MakeComputerMove(Var Pos: TPosition);
Var
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
          Exit;
        End;
End;

Function IsBoardFull: Boolean;
Var
  I, J, K: Integer;
Begin
  IsBoardFull := True;
  For K := 0 to GRID_SIZE-1 do
    For I := 0 to GRID_SIZE-1 do
      For J := 0 to GRID_SIZE-1 do
        If Grid[I,J,K] = Empty Then Begin
          IsBoardFull := False;
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
        #72: If SelectedY > 0 Then Begin { Up }
          RestoreCursorArea; { Restaurer avant de bouger }
          Dec(SelectedY);
          { Forcer le redessin du niveau actuel pour mettre à jour l'affichage }
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
        End;
        #80: If SelectedY < GRID_SIZE-1 Then Begin { Down }
          RestoreCursorArea;
          Inc(SelectedY);
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
        End;
        #75: If SelectedX > 0 Then Begin { Left }
          RestoreCursorArea;
          Dec(SelectedX);
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
        End;
        #77: If SelectedX < GRID_SIZE-1 Then Begin { Right }
          RestoreCursorArea;
          Inc(SelectedX);
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
        End;
        #73: If CurrentLayer < GRID_SIZE-1 Then Begin { PgUp }
          RestoreCursorArea;
          { Forcer le redessin de l'ancien niveau pour effacer le curseur }
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
          Inc(CurrentLayer);
        End;
        #81: If CurrentLayer > 0 Then Begin { PgDn }
          RestoreCursorArea;
          { Forcer le redessin de l'ancien niveau pour effacer le curseur }
          If (CurrentLayer >= 0) and (CurrentLayer < GRID_SIZE) Then
            LayerSaved[CurrentLayer] := False;
          Dec(CurrentLayer);
        End;
      End;
      #13: Begin { Enter }
        { Déboguer les valeurs }
        If (SelectedX < 0) or (SelectedX >= GRID_SIZE) or
           (SelectedY < 0) or (SelectedY >= GRID_SIZE) or
           (CurrentLayer < 0) or (CurrentLayer >= GRID_SIZE) Then Begin
          { Valeurs invalides - ne rien faire }
        End Else If IsValidMove(SelectedX, SelectedY, CurrentLayer) Then Begin
          If CurrentPlayer = 1 Then Symbol := X
                              Else Symbol := O;
          Grid[SelectedX, SelectedY, CurrentLayer] := Symbol;
          { Forcer le redessin du niveau modifié }
          LayerSaved[CurrentLayer] := False;
          CubeSaved := False;
          If CheckWin Then
            GameOver := True
          Else If IsBoardFull Then Begin
            Winner := 0; { Match nul }
            GameOver := True;
          End Else
            CurrentPlayer := 3 - CurrentPlayer;
        End;
      End;
      #27: GameOver := True; { Escape }
    End;
  End;

  If Not GameOver And (PlayerType[CurrentPlayer] = Computer) Then Begin
    MakeComputerMove(ComputerMove);
    If CurrentPlayer = 1 Then Symbol := X
                        Else Symbol := O;
    Grid[ComputerMove.X, ComputerMove.Y, ComputerMove.Z] := Symbol;
    { Forcer le redessin du niveau modifié }
    If (ComputerMove.Z >= 0) and (ComputerMove.Z < GRID_SIZE) Then
      LayerSaved[ComputerMove.Z] := False;
    CubeSaved := False;
    If CheckWin Then
      GameOver := True
    Else If IsBoardFull Then Begin
      Winner := 0; { Match nul }
      GameOver := True;
    End Else
      CurrentPlayer := 3 - CurrentPlayer;
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

  { Initialiser les variables de sauvegarde du curseur }
  CursorBackup := Nil;
  CursorBackupSize := 0;
  LastCursorX := -1;
  LastCursorY := -1;
  CursorSaved := False;
  TitleDrawn := False;
  LastDisplayedLayer := -1;

  { Initialiser les variables du cube 3D }
  CubeBackup := Nil;
  CubeBackupSize := 0;
  CubeSaved := False;

  { Initialiser les variables des niveaux (juste le flag) }
  For I := 0 to GRID_SIZE-1 do Begin
    LayerSaved[I] := False;
  End;
End;

Procedure ShowGameResult;
Var
  ResultMessage: String;
  Key: Char;
  MessageColor: Integer;
Begin
  { Déterminer le message et la couleur }
  If Winner = 1 Then Begin
    If PlayerType[1] = Human Then Begin
      ResultMessage := 'FELICITATIONS ! VOUS AVEZ GAGNE !';
      MessageColor := LightGreen;
    End Else Begin
      ResultMessage := 'L''ORDINATEUR A GAGNE !';
      MessageColor := LightRed;
    End;
  End Else If Winner = 2 Then Begin
    If PlayerType[2] = Human Then Begin
      ResultMessage := 'FELICITATIONS ! VOUS AVEZ GAGNE !';
      MessageColor := LightGreen;
    End Else Begin
      ResultMessage := 'L''ORDINATEUR A GAGNE !';
      MessageColor := LightRed;
    End;
  End Else Begin
    ResultMessage := 'MATCH NUL !';
    MessageColor := Yellow;
  End;

  { Afficher le message de résultat }
  SetColor(MessageColor);
  SetTextStyle(0, 0, 2);
  OutTextXY((640 - TextWidth(ResultMessage))shr 1, 240, ResultMessage);

  { Instructions }
  SetColor(White);
  SetTextStyle(0, 0, 1);
  OutTextXY(320 - 80, 270, 'Appuyez sur une touche pour quitter...');

  { Attendre une pression de touche }
  Repeat
    If KeyPressed Then Begin
      Key := ReadKey;
      If Key = #0 Then ReadKey; { Ignorer les touches spéciales }
      Exit;
    End;
    Delay(50);
  Until False;
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

 { Libérer la mémoire du curseur }
 If CursorBackup <> Nil Then
   FreeMem(CursorBackup, CursorBackupSize);

 { Libérer la mémoire du cube 3D }
 If CubeBackup <> Nil Then
   FreeMem(CubeBackup, CubeBackupSize);

 { Afficher le résultat de la partie }
 ShowGameResult;

 CloseGraph;
END.
