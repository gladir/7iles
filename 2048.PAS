{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program _2048;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcCrt,PtcGraph
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 GRID_SIZE=4;
 TILE_SIZE=60;
 SPACING=10;
 COLORS:Array[0..11] of Integer = (
    LightGray,  { 0 }
    LightBlue,  { 2 }
    LightCyan,  { 4 }
    LightGreen, { 8 }
    Yellow,     { 16 }
    LightRed,   { 32 }
    Red,        { 64 }
    Magenta,    { 128 }
    Brown,      { 256 }
    LightMagenta,{ 512 }
    White,      { 1024 }
    Blue        { 2048 }
  );

Type
 TGrid=Array[0..GRID_SIZE-1, 0..GRID_SIZE-1] of LongInt;

Var
 Grid:TGrid;
 Score:LongInt;
 GameOver:Boolean;
 GraphDriver,GraphMode:Integer;

Procedure InitScr;
Begin
 {$IFDEF FPC}
  GraphDriver:=VGA;
  GraphMode:=VGAHi;
 {$ELSE}
  GraphDriver:=Detect;
  GraphMode:=VGAHi;
 {$ENDIF}
 InitGraph(GraphDriver, GraphMode,'');
 If GraphResult <> grOk then
 Begin
  WriteLn('Erreur d''initialisation graphique!');
  Halt(1);
 End;
End;

Procedure InitializeGame;
Var
 i,j:Integer;
Begin
 For i:=0 to GRID_SIZE-1 do For j:=0 to GRID_SIZE-1 do Grid[i,j]:=0;
 Score:=0;
 GameOver:=False;
End;

Function GetColorIndex(Value:LongInt):Integer;
Var
 Power: integer;
Begin
 If Value=0 Then GetColorIndex:=0
  Else
 Begin
  Power := 0;
  While Value>1 do Begin
   Value := Value div 2;
   Inc(Power);
  End;
  GetColorIndex := Power;
  If Power>11 then GetColorIndex := 11;
 End;
End;

Procedure DrawTile(x,y:Integer;Value:LongInt);
Var
 PosX,PosY:Integer;
 ValueStr:String;
Begin
 PosX:=x*(TILE_SIZE+SPACING)+SPACING;
 PosY:=y*(TILE_SIZE+SPACING)+SPACING;
 SetFillStyle(SolidFill, COLORS[GetColorIndex(Value)]);
 Bar(PosX,PosY,PosX+TILE_SIZE,PosY+TILE_SIZE);
 SetColor(Black);
 Rectangle(PosX, PosY, PosX + TILE_SIZE, PosY + TILE_SIZE);
 If Value>0 Then Begin
  Str(Value,ValueStr);
  SetTextStyle(DefaultFont, HorizDir, 2);
  SetTextJustify(CenterText, CenterText);
  OutTextXY(PosX + TILE_SIZE div 2, PosY + TILE_SIZE div 2, ValueStr);
 End;
End;

Procedure DrawGame;
Var
 i,j:Integer;
 ScoreStr:String;
Begin
 ClearDevice;
 For i:=0 to GRID_SIZE-1 do For j:=0 to GRID_SIZE-1 do DrawTile(i,j,Grid[i,j]);
 SetColor(White);
 Str(Score,ScoreStr);
 SetTextStyle(DefaultFont,HorizDir,2);
 OutTextXY(120,320, 'Pointage : '+ScoreStr);
End;

Procedure AddNewTile;
Var
 x,y:Integer;
 EmptySpots:Integer;
Begin
 EmptySpots:=0;
 For x:=0 to GRID_SIZE-1 do For y:=0 to GRID_SIZE-1 do
  If Grid[x,y]=0 then Inc(EmptySpots);
 If EmptySpots>0 Then Begin
  Repeat
   x:=Random(GRID_SIZE);
   y:=Random(GRID_SIZE);
  Until Grid[x,y] = 0;
  If Random(10)=0 Then Grid[x,y] := 4
                  Else Grid[x,y] := 2;
 End;
End;

Procedure MoveTiles(Direction:Char);
Var
 i,j,k:Integer;
 Moved:Boolean;
Begin
 Moved := false;
 Case Direction of
    'U': Begin  { Up }
      For j := 0 to GRID_SIZE-1 do Begin
        For i := 0 to GRID_SIZE-1 do Begin
          k := i;
          While (k > 0) and (Grid[j,k-1] = 0) do Begin
            Grid[j,k-1] := Grid[j,k];
            Grid[j,k] := 0;
            Dec(k);
            Moved := true;
          End;
          If (k > 0) and (Grid[j,k-1] = Grid[j,k]) then Begin
            Grid[j,k-1] := Grid[j,k-1] * 2;
            Grid[j,k] := 0;
            Inc(Score, Grid[j,k-1]);
            Moved := true;
          End;
        End;
      End;
    End;
    'D': Begin  { Down }
      For j := 0 to GRID_SIZE-1 do Begin
        For i := GRID_SIZE-1 downto 0 do Begin
          k := i;
          While (k < GRID_SIZE-1) and (Grid[j,k+1] = 0) do Begin
            Grid[j,k+1] := Grid[j,k];
            Grid[j,k] := 0;
            Inc(k);
            Moved := true;
          End;
          If (k < GRID_SIZE-1) and (Grid[j,k+1] = Grid[j,k]) then Begin
            Grid[j,k+1] := Grid[j,k+1] * 2;
            Grid[j,k] := 0;
            Inc(Score, Grid[j,k+1]);
            Moved := true;
          End;
        End;
      End;
    End;
    'L': Begin  { Left }
      For i := 0 to GRID_SIZE-1 do Begin
        For j := 0 to GRID_SIZE-1 do Begin
          k := j;
          While (k > 0) and (Grid[k-1,i] = 0) do Begin
            Grid[k-1,i] := Grid[k,i];
            Grid[k,i] := 0;
            Dec(k);
            Moved := true;
          End;
          If (k > 0) and (Grid[k-1,i] = Grid[k,i]) then Begin
            Grid[k-1,i] := Grid[k-1,i] * 2;
            Grid[k,i] := 0;
            Inc(Score, Grid[k-1,i]);
            Moved := true;
          End;
        End;
      End;
    End;
    'R': Begin  { Right }
      For i := 0 to GRID_SIZE-1 do Begin
        For j := GRID_SIZE-1 downto 0 do Begin
          k := j;
          While (k < GRID_SIZE-1) and (Grid[k+1,i] = 0) do Begin
            Grid[k+1,i] := Grid[k,i];
            Grid[k,i] := 0;
            Inc(k);
            Moved := true;
          End;
          If (k < GRID_SIZE-1) and (Grid[k+1,i] = Grid[k,i]) then Begin
            Grid[k+1,i] := Grid[k+1,i] * 2;
            Grid[k,i] := 0;
            Inc(Score, Grid[k+1,i]);
            Moved := true;
          End;
        End;
      End;
    End;
  End;

  If Moved then AddNewTile;
End;

Function CheckGameOver:Boolean;
Var
 i,j:Integer;
Begin
 CheckGameOver:=True;
  { V‚rifie les cellules vides }
 For i:=0 to GRID_SIZE-1 do For j := 0 to GRID_SIZE-1 do
  If Grid[i,j]=0 Then Begin
   CheckGameOver := false;
   Exit;
  End;
  { V‚rifie les fusions possibles }
  For i:=0 to GRID_SIZE-1 do For j:=0 to GRID_SIZE-2 do Begin
   If Grid[i,j]=Grid[i,j+1]Then Begin
    CheckGameOver:=False;
    Exit;
   End;
   If Grid[j,i]=Grid[j+1,i]Then Begin
    CheckGameOver := false;
    Exit;
   End;
  End;
End;

BEGIN
 Randomize;
 InitScr;
 InitializeGame;
 AddNewTile;
 AddNewTile;
 Repeat
  DrawGame;
  Case ReadKey of
   #0: Case ReadKey of
   #72: MoveTiles('U');  { FlŠche du haut }
   #80: MoveTiles('D');  { FlŠche du bas }
   #75: MoveTiles('L');  { FlŠche de gauche }
   #77: MoveTiles('R');  { FlŠche de droite }
  End;
  #27: GameOver := true;  { ESC }
 End;
 GameOver:=GameOver or CheckGameOver;
 Until GameOver;
 SetTextStyle(DefaultFont, HorizDir, 3);
 OutTextXY(160, 200, 'Partie terimin‚ !');
 ReadKey;
 CloseGraph;
END.
