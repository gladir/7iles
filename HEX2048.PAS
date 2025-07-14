{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Hex 2048 - Version hexagonale du jeu 2048
  Grille hexagonale avec 6 directions de mouvement
}

Program Hex2048;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 HEX_RADIUS = 25;
 CENTER_X = 320;
 CENTER_Y = 240;

  { Disposition hexagonale : 3 rangÃ©es avec 3, 4, 3 hexagones }
 MAX_HEXAGONS = 19;

Type
 THexCell=Record
  X,Y:Integer;        { Position … l'‚cran }
  Value:LongInt;      { Valeur de la tuile }
  Active:Boolean;     { Si cette cellule est utilis‚e }
 End;

 THexGrid=Array[0..MAX_HEXAGONS-1] of THexCell;

 THexPoint=Record
  X,Y:Integer;
 End;

Var
 Grid:THexGrid;
 Score:LongInt;
 BestScore:LongInt;
 GameOver:Boolean;
 Won:Boolean;
 ShowInstructions:Boolean;
 NeedRedraw:Boolean;  { Indique si un rafraichissement est n‚cessaire }

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=0;
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
  GetTickCount:= MemL[$0040:$006C]; { Turbo Pascal - lecture directe de la mÃ©moire }
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
  { Pas d'implï¿½mentation pour Free Pascal }
 End;

 Procedure HideMouse;Begin
  { Pas d'implï¿½mentation pour Free Pascal }
 End;

{$ENDIF}

Procedure InitHexGrid;
Var
 I:Integer;
 Row,Col:Integer;
 StartX,StartY:Integer;
 HexRadius:Integer;
 HexWidth,HexHeight:Integer;
Begin
  { Initialiser toutes les cellules comme inactives }
 For I:=0 to MAX_HEXAGONS-1 Do Begin
  Grid[I].Active:=False;
  Grid[I].Value:=0;
 End;
  { Disposition hexagonale authentique en forme de losange }
  { Pattern: 1-2-3-2-3-2-3-2-1 hexagones par rangÃ©e }
  { Espacement rÃ©duit pour tenir dans 640x480 }
 I:=0;
  { Rang‚e 0 : 1 hexagone - sommet }
 StartX:=320;  { CentrÃ© }
 StartY:=140;  { Plus haut pour avoir la place }
 Grid[I].X:=StartX;
 Grid[I].Y:=StartY;
 Grid[I].Active:=True;
 Inc(I);
  { Rang‚e 1 : 2 hexagones }
 StartX:=284;  { Centr‚ pour 2 hexagones }
 StartY:=168;  { Espacement r‚duit … 28px }
 For Col:=0 to 1 Do Begin
  Grid[I].X := StartX + Col * 72;
  Grid[I].Y := StartY;
  Grid[I].Active := True;
  Inc(I);
 End;
  { Rang‚e 2 : 3 hexagones }
 StartX:=248;  { Centr‚ pour 3 hexagones }
 StartY:=196;  { 168 + 28 }
 For Col := 0 to 2 do Begin
  Grid[I].X:=StartX + Col * 72;
  Grid[I].Y:=StartY;
  Grid[I].Active:=True;
  Inc(I);
 End;
  { Rang‚e 3 : 2 hexagones }
 StartX:=284;  { Centr‚ pour 2 hexagones }
 StartY:=224;  { 196 + 28 }
 For Col := 0 to 1 Do Begin
  Grid[I].X := StartX + Col * 72;
  Grid[I].Y := StartY;
  Grid[I].Active := True;
  Inc(I);
 End;
  { Rang‚e 4 : 3 hexagones }
 StartX:=248;  { Centr‚ pour 3 hexagones }
 StartY:=252;  { 224 + 28 }
 For Col := 0 to 2 Do Begin
  Grid[I].X := StartX + Col * 72;
  Grid[I].Y := StartY;
  Grid[I].Active := True;
  Inc(I);
 End;
  { Rang‚e 5 : 2 hexagones }
 StartX:=284;  { Centr‚ pour 2 hexagones }
 StartY:=280;  { 252 + 28 }
 For Col:=0 to 1 Do Begin
  Grid[I].X:=StartX + Col * 72;
  Grid[I].Y:=StartY;
  Grid[I].Active:=True;
  Inc(I);
 End;
  { Rang‚e 6 : 3 hexagones }
 StartX := 248;  { Centr‚ pour 3 hexagones }
 StartY := 308;  { 280 + 28 }
 For Col:=0 to 2 Do Begin
  Grid[I].X:=StartX+Col*72;
  Grid[I].Y:=StartY;
  Grid[I].Active:=True;
  Inc(I);
 End;
  { Rang‚e 7 : 2 hexagones }
 StartX:=284;  { Centr‚ pour 2 hexagones }
 StartY:=336;  { 308 + 28 }
 For Col := 0 to 1 Do Begin
  Grid[I].X := StartX + Col * 72;
  Grid[I].Y := StartY;
  Grid[I].Active := True;
  Inc(I);
 End;
  { Rang‚e 8 : 1 hexagone - pointe }
 StartX := 320;  { Centr‚ }
 StartY := 364;  { 336 + 28 }
 Grid[I].X:=StartX;
 Grid[I].Y:=StartY;
 Grid[I].Active:=True;
 Inc(I);
End;

Procedure InitScreen;
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
 ErrCode := GraphResult;
 If ErrCode <> grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt(1);
 End;
End;

Procedure GetHexCenter(Index: Integer; Var Point: THexPoint);Begin
 If (Index >= 0) And (Index < MAX_HEXAGONS) And Grid[Index].Active Then Begin
  Point.X := Grid[Index].X;
  Point.Y := Grid[Index].Y;
 End
  Else
 Begin
  Point.X := 0;
  Point.Y := 0;
 End;
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

Function GetTileColor(Value:LongInt):Integer;Begin
  { Couleurs adapt‚s pour VGA }
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
    Else GetTileColor := White;      { Valeurs supÃ©rieures -> White }
  End;
End;

Function GetTextColor(Value:LongInt):Integer;Begin
  { Couleur de texte bas‚e sur les couleurs de fond }
 Case Value of
  0: GetTextColor := LightGray;
  2,4: GetTextColor := Black;   { Sur fond clair }
  Else GetTextColor := White;   { Sur fond fonc‚ }
 End;
End;

Function GetTextSize(Value:LongInt):Integer;Begin
  { Tailles de police adapt‚ au VGA }
 Case Value of
  2, 4, 8, 16, 32, 64, 128: GetTextSize := 2;      { 48px -> taille 2 }
  256, 512: GetTextSize := 1;                      { 40px -> taille 1 }
  1024, 2048, 4096, 8192, 16384: GetTextSize := 1; { 32px -> taille 1 }
  Else GetTextSize := 1;
 End;
End;

Procedure DrawTile(Index:Integer);
Var
 Point:THexPoint;
 Value:LongInt;
 ValueStr:String;
 TextW,TextH:Integer;
Begin
 If Not Grid[Index].Active Then Exit;
 GetHexCenter(Index, Point);
 Value:=Grid[Index].Value;
  { Dessiner l'hexagone }
 DrawHexagon(Point.X, Point.Y, HEX_RADIUS-2, GetTileColor(Value), White);
  { Afficher la valeur si elle n'est pas zÃ©ro }
 If Value>0 Then Begin
  Str(Value, ValueStr);
  SetColor(GetTextColor(Value));
  SetTextStyle(DefaultFont, HorizDir, GetTextSize(Value));
   { Centrer le texte avec ajustement selon la taille }
  TextW := Length(ValueStr) * (8 * GetTextSize(Value));
  TextH := 8 * GetTextSize(Value);
  OutTextXY(Point.X - TextW div 2, Point.Y - TextH div 2, ValueStr);
 End;
End;

Procedure DrawBackground;Begin
  { Fond noir }
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
 ScoreStr,BestStr:String;
Begin
 SetColor(Yellow);
 SetTextStyle(DefaultFont, HorizDir, 1);
 Str(Score, ScoreStr);
 Str(BestScore, BestStr);
 OutTextXY(50, 60, 'Pointage: ' + ScoreStr);
 OutTextXY(50, 80, 'Meilleur: ' + BestStr);
End;

Procedure DrawInstructions;Begin
 If ShowInstructions Then Begin
   { Affichage modal des instructions basÃ© sur displayInstructionsModal }
  SetColor(DarkGray);
  SetFillStyle(SolidFill, DarkGray);
  Bar(40, 50, SCREEN_WIDTH - 40, 100);
  SetColor(Blue);
  SetLineStyle(SolidLn, 0, ThickWidth);
  Rectangle(40, 50, SCREEN_WIDTH - 40, 100);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(60, 60, 'Utilisez les touches Q/W/E/A/S/D');
  OutTextXY(60, 75, 'pour deplacer les tuiles');
  OutTextXY(60, 90, 'R - Nouveau jeu, ESC - Quitter');
 End
  Else
 Begin
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
 I:Integer;
Begin
 For I := 0 to MAX_HEXAGONS-1 Do Begin
  If Grid[I].Active Then DrawTile(I);
 End;
End;

Procedure DrawGameOver;Begin
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

Procedure DrawWin;Begin
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

Procedure DrawScreen;Begin
 DrawBackground;
 DrawScore;
 DrawGrid;
 DrawInstructions;
 DrawGameOver;
 DrawWin;
End;

Procedure AddRandomTile;
Var
 I:Integer;
 EmptyFound:Boolean;
 Attempts:Integer;
 EmptySlots:Array[0..MAX_HEXAGONS-1] of Integer;
 EmptyCount:Integer;
Begin
  { Trouver toutes les cases vides }
 EmptyCount:=0;
 For I := 0 to MAX_HEXAGONS-1 Do Begin
  If Grid[I].Active And (Grid[I].Value = 0) Then Begin
   EmptySlots[EmptyCount] := I;
   Inc(EmptyCount);
  End;
 End;
  { Ajouter une tuile dans une case vide alÃ©atoire }
 If EmptyCount>0 Then Begin
  I:=EmptySlots[Random(EmptyCount)];
   { 90% chance d'avoir un 2, 10% chance d'avoir un 4 }
  If Random(10)=0 Then Grid[I].Value:=4
                  Else Grid[I].Value := 2;
 End;
End;

Procedure InitGrid;
Var
 I:Integer;
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

Function HasEmptyTiles:Boolean;
Var
 I:Integer;
Begin
 HasEmptyTiles:=False;
 For I := 0 to MAX_HEXAGONS-1 do Begin
  If Grid[I].Active And (Grid[I].Value = 0) Then Begin
   HasEmptyTiles := True;
   Exit;
  End;
 End;
End;

{ Cartographie des voisins hexagonaux pour disposition en losange }
{ Pattern: 1-2-3-2-3-2-3-2-1 }
{ Direction 0=Q (nord-ouest), 1=W (nord), 2=E (nord-est) }
{ Direction 3=A (sud-ouest), 4=S (sud), 5=D (sud-est) }
Function GetNeighbor(Index:Integer;Direction:Integer):Integer;Begin
 GetNeighbor := -1; { -1 = pas de voisin }
 Case Index of
   { Index 0 : Sommet (rangÃ©e 0, 1 hexagone) }
  0:Case Direction of
   3:GetNeighbor:=1;      { A -> rang‚e 1, gauche }
   5:GetNeighbor:=2;      { D -> rang‚e 1, droite }
  End;
   { Index 1-2 : Rang‚e 1 (2 hexagones) }
  1: Case Direction of
   1: GetNeighbor := 0;      { W -> rang‚e 0 }
   2: GetNeighbor := 2;      { E -> droite }
   4: GetNeighbor := 3;      { S -> rang‚e 2, gauche }
   5: GetNeighbor := 4;      { D -> rang‚e 2, centre }
  End;
  2:Case Direction of
   1: GetNeighbor := 0;      { W -> rang‚e 0 }
   3: GetNeighbor := 1;      { A -> gauche }
   4: GetNeighbor := 4;      { S -> rang‚e 2, centre }
   5: GetNeighbor := 5;      { D -> rang‚e 2, droite }
  End;
   { Index 3-5 : Rang‚e 2 (3 hexagones) }
  3: Case Direction of
   0:GetNeighbor := 1;      { Q -> rang‚e 1, gauche }
   2:GetNeighbor := 4;      { E -> droite }
   3:GetNeighbor := 6;      { A -> rang‚e 3, gauche }
   4:GetNeighbor := 7;      { S -> rang‚e 3, droite }
  End;
  4:Case Direction of
   0:GetNeighbor := 1;      { Q -> rang‚e 1, gauche }
   1:GetNeighbor := 2;      { W -> rang‚e 1, droite }
   2: GetNeighbor := 5;      { E -> droite }
   3: GetNeighbor := 3;      { A -> gauche }
   4: GetNeighbor := 6;      { S -> rang‚e 3, gauche }
   5: GetNeighbor := 7;      { D -> rang‚e 3, droite }
  End;
  5:Case Direction of
   1:GetNeighbor := 2;      { W -> rang‚e 1, droite }
   3:GetNeighbor := 4;      { A -> gauche }
   4:GetNeighbor := 7;      { S -> rang‚e 3, droite }
   5:GetNeighbor := 8;      { D -> rang‚e 4, gauche }
  End;
   { Index 6-7 : Rang‚e 3 (2 hexagones) }
  6:Case Direction of
   1:GetNeighbor := 3;      { W -> rang‚e 2, gauche }
   0:GetNeighbor := 4;      { Q -> rang‚e 2, centre }
   2:GetNeighbor := 7;      { E -> droite }
   4:GetNeighbor := 8;      { S -> rang‚e 4, gauche }
   5:GetNeighbor := 9;      { D -> rang‚e 4, centre }
  End;
  7:Case Direction of
   0:GetNeighbor := 3;      { Q -> rang‚e 2, gauche }
   1:GetNeighbor := 4;      { W -> rang‚e 2, centre }
   2:GetNeighbor := 5;      { E -> rang‚e 2, droite }
   3:GetNeighbor := 6;      { A -> gauche }
   4:GetNeighbor := 9;      { S -> rang‚e 4, centre }
   5:GetNeighbor := 10;     { D -> rang‚e 4, droite }
  End;
   { Index 8-10 : Rang‚e 4 (3 hexagones) }
  8: Case Direction of
   0: GetNeighbor := 6;      { Q -> rang‚e 3, gauche }
   1: GetNeighbor := 7;      { W -> rang‚e 3, droite }
   2: GetNeighbor := 9;      { E -> droite }
   4: GetNeighbor := 11;     { S -> rang‚e 5, gauche }
   5: GetNeighbor := 12;     { D -> rang‚e 5, droite }
  End;
  9: Case Direction of
   0: GetNeighbor := 6;      { Q -> rang‚e 3, gauche }
   1: GetNeighbor := 7;      { W -> rang‚e 3, droite }
   2: GetNeighbor := 10;     { E -> droite }
   3: GetNeighbor := 8;      { A -> gauche }
   4: GetNeighbor := 11;     { S -> rang‚e 5, gauche }
   5: GetNeighbor := 12;     { D -> rang‚e 5, droite }
  End;
  10: Case Direction of
   1: GetNeighbor := 7;      { W -> rang‚e 3, droite }
   3: GetNeighbor := 9;      { A -> gauche }
   4: GetNeighbor := 12;     { S -> rang‚e 5, droite }
   5: GetNeighbor := 13;     { D -> rang‚e 6, gauche }
  End;
   { Index 11-12 : RangÃ©e 5 (2 hexagones) }
  11:Case Direction of
   1: GetNeighbor := 8;      { W -> rang‚e 4, gauche }
   0: GetNeighbor := 9;      { Q -> rang‚e 4, centre }
   2: GetNeighbor := 12;     { E -> droite }
   4: GetNeighbor := 13;     { S -> rang‚e 6, gauche }
   5: GetNeighbor := 14;     { D -> rang‚e 6, centre }
  End;
  12: Case Direction of
   0: GetNeighbor := 8;      { Q -> rang‚e 4, gauche }
   1: GetNeighbor := 9;      { W -> rang‚e 4, centre }
   2: GetNeighbor := 10;     { E -> rang‚e 4, droite }
   3: GetNeighbor := 11;     { A -> gauche }
   4: GetNeighbor := 14;     { S -> rang‚e 6, centre }
   5: GetNeighbor := 15;     { D -> rang‚e 6, droite }
  End;
   { Index 13-15 : Rang‚e 6 (3 hexagones) }
  13: Case Direction of
   0: GetNeighbor := 11;     { Q -> rang‚e 5, gauche }
   1: GetNeighbor := 12;     { W -> rang‚e 5, droite }
   2: GetNeighbor := 14;     { E -> droite }
   4: GetNeighbor := 16;     { S -> rang‚e 7, gauche }
   5: GetNeighbor := 17;     { D -> rang‚e 7, droite }
  End;
  14: Case Direction of
   0: GetNeighbor := 11;     { Q -> rang‚e 5, gauche }
   1: GetNeighbor := 12;     { W -> rang‚e 5, droite }
   2: GetNeighbor := 15;     { E -> droite }
   3: GetNeighbor := 13;     { A -> gauche }
   4: GetNeighbor := 16;     { S -> rang‚e 7, gauche }
   5: GetNeighbor := 17;     { D -> rang6e 7, droite }
  End;
  15: Case Direction of
   1: GetNeighbor := 12;     { W -> rang‚e 5, droite }
   3: GetNeighbor := 14;     { A -> gauche }
   4: GetNeighbor := 17;     { S -> rang‚e 7, droite }
   5: GetNeighbor := 18;     { D -> pointe }
  End;
   { Index 16-17 : Rang‚e 7 (2 hexagones) }
  16: Case Direction of
   1: GetNeighbor := 13;     { W -> rang‚e 6, gauche }
   0: GetNeighbor := 14;     { Q -> rang‚e 6, centre }
   2: GetNeighbor := 17;     { E -> droite }
   4: GetNeighbor := 18;     { S -> pointe }
  End;
  17: Case Direction of
   0: GetNeighbor := 13;     { Q -> rang‚e 6, gauche }
   1: GetNeighbor := 14;     { W -> rang‚e 6, centre }
   2: GetNeighbor := 15;     { E -> rang‚e 6, droite }
   3: GetNeighbor := 16;     { A -> gauche }
   4: GetNeighbor := 18;     { S -> pointe }
  End;
   { Index 18 : Pointe (rang‚e 8, 1 hexagone) }
  18: Case Direction of
   0: GetNeighbor := 16;     { Q -> rangÃ©e 7, gauche }
   1: GetNeighbor := 17;     { W -> rangÃ©e 7, droite }
  End;
 End;
End;

Function CanMove:Boolean;
Var
 I,J,Neighbor:Integer;
Begin
 CanMove:=False;
  { V‚rifier s'il y a des cases vides }
 If HasEmptyTiles Then Begin
  CanMove := True;
  Exit;
 End;
  { V‚rifier s'il y a des mouvements possibles }
 For I := 0 to MAX_HEXAGONS-1 Do Begin
  If Grid[I].Active And (Grid[I].Value > 0) Then Begin
   For J:=0 to 5 Do Begin
    Neighbor := GetNeighbor(I,J);
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

Function MoveInDirection(Direction:Integer):Boolean;
Var
 I,Neighbor:Integer;
 Moved:Boolean;
 TempGrid:THexGrid;
Begin
 Moved:=False;
  { Copier la grille actuelle }
 For I:=0 to MAX_HEXAGONS-1 Do Begin
  TempGrid[I] := Grid[I];
 End;
  { D‚placer et fusionner les tuiles dans la direction donn‚e }
 For I := 0 to MAX_HEXAGONS-1 Do Begin
  If Grid[I].Active And (Grid[I].Value > 0) Then Begin
   Neighbor := GetNeighbor(I, Direction);
   If(Neighbor >= 0)And Grid[Neighbor].Active Then Begin
    If Grid[Neighbor].Value = 0 Then Begin
      { Case vide : d‚placer }
     Grid[Neighbor].Value := Grid[I].Value;
     Grid[I].Value:=0;
     Moved:=True;
    End
     Else
    If Grid[Neighbor].Value = Grid[I].Value Then Begin
      { Mˆme valeur : fusionner }
     Grid[Neighbor].Value := Grid[Neighbor].Value * 2;
     Grid[I].Value:=0;
     Score:=Score+Grid[Neighbor].Value;
     Moved:=True;
      { V‚rifier la victoire }
     If Grid[Neighbor].Value = 2048 Then Won:=True;
    End;
   End;
  End;
 End;
  { Ajouter deux tuiles si un mouvement a eu lieu }
 If Moved Then Begin
  AddRandomTile;
  AddRandomTile;
 End;
 MoveInDirection := Moved;
End;

Procedure NewGame;Begin
 Score := 0;
 GameOver:=False;
 Won := False;
 ShowInstructions:=True;  { Afficher les instructions comme dans le JavaScript }
 InitGrid;
 NeedRedraw:=True;  { Marquer pour rafraÃ®chissement }
End;

Procedure HandleInput;
Var
 Key:Char;
 Moved:Boolean;
Begin
 Moved:=False;
  { Gestion du clavier }
 If KeyPressed Then Begin
  Key:=ReadKey;
  Case Key Of
      'i', 'I': Begin
        ShowInstructions := Not ShowInstructions;
        NeedRedraw := True;  { Marquer pour rafraÃ®chissement }
      End;
      'q', 'Q': Begin
        Moved := MoveInDirection(0);
        If Moved Then NeedRedraw := True;
      End;
      'w', 'W': Begin
        Moved := MoveInDirection(1);
        If Moved Then NeedRedraw := True;
      End;
      'e', 'E': Begin
        Moved := MoveInDirection(2);
        If Moved Then NeedRedraw := True;
      End;
      'a', 'A': Begin
        Moved := MoveInDirection(3);
        If Moved Then NeedRedraw := True;
      End;
      's', 'S': Begin
        Moved := MoveInDirection(4);
        If Moved Then NeedRedraw := True;
      End;
      'd', 'D': Begin
        Moved := MoveInDirection(5);
        If Moved Then NeedRedraw := True;
      End;
      'r', 'R': Begin
        NewGame;
        NeedRedraw := True;
      End;
      #27: Begin
        CloseGraph;
        Halt;
      End;
    End;
    If Moved Then Begin
      { Ajouter deux nouvelles tuiles aprÃ¨s chaque mouvement }
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
 NeedRedraw := True;  { Dessiner l'‚cran initial }
 NewGame;
  { Boucle principale avec rafraichissement conditionnel }
 Repeat
  If NeedRedraw Then Begin
   DrawScreen;
   NeedRedraw := False;  { R‚initialiser le drapeau }
  End;
  HandleInput;
  Delay(10);  { D‚lai r‚duit pour une meilleure r‚activit‚ }
 Until False;
END.
