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
 DICE_AREA_LEFT = 550; { Augmenté de 510 à 550 }
 BOARD_TOP_OFFSET = 20;  { Nouvelle constante }

Type
 TPlayerType = (Human, Computer);

 TPoint=Record
  count:integer;
  color:integer; { 1 = white, 2 = black }
 End;

  TBoard = array[1..24] of TPoint;

Function IntToStr(Value: Integer):String;
var
  S: string[11];  { Maximum de 11 caractères pour un Integer }
begin
  Str(Value, S);
  IntToStr := S;
end;

var
  gd, gm: integer;
  board: TBoard;
  currentPlayer: integer;
  dice: array[1..2] of integer;
  player1Type, player2Type: TPlayerType;

procedure InitializeGraphics;
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

procedure InitializeBoard;
var i: integer;
begin
  for i := 1 to 24 do
  begin
    board[i].count := 0;
    board[i].color := 0;
  end;

  { Set initial positions }
  board[1].count := 2; board[1].color := 1;  { White }
  board[12].count := 5; board[12].color := 1;
  board[17].count := 3; board[17].color := 1;
  board[19].count := 5; board[19].color := 1;

  board[24].count := 2; board[24].color := 2;  { Black }
  board[13].count := 5; board[13].color := 2;
  board[8].count := 3; board[8].color := 2;
  board[6].count := 5; board[6].color := 2;
end;

procedure DrawLetters;
var
  i: Integer;
  x: Integer;
  letter: Char;
begin
  SetTextStyle(DefaultFont, HorizDir, 2);
  for i := 0 to 11 do begin
    x := i * (BOARD_WIDTH div 12) + (BOARD_WIDTH div 24) - 8;
    letter := Chr(Ord('A') + i);
    OutTextXY(x, MARGIN_TOP - 10, letter);
    letter := Chr(Ord('M') + i);
    OutTextXY(x, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET + 30, letter); { Ajouté 20 pixels (de 10 à 30) }
  end;
end;

procedure DrawDiceShape(x, y, value: Integer);
const
  DICE_SIZE = 40;
  DOT_SIZE = 6;
var
  centerX, centerY: Integer;
begin
  { Dessine le rectangle arrondi du dé }
  SetColor(White);
  SetFillStyle(SolidFill, White);
  Bar(x, y, x + DICE_SIZE, y + DICE_SIZE);
  Rectangle(x, y, x + DICE_SIZE, y + DICE_SIZE);

  { Points centraux pour le dé }
  centerX := x + DICE_SIZE div 2;
  centerY := y + DICE_SIZE div 2;

  SetFillStyle(SolidFill, Black);

  case value of
    1: FillEllipse(centerX, centerY, DOT_SIZE, DOT_SIZE);

    2: begin
      FillEllipse(centerX - 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY + 10, DOT_SIZE, DOT_SIZE);
    end;

    3: begin
      FillEllipse(centerX - 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX, centerY, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY + 10, DOT_SIZE, DOT_SIZE);
    end;

    4: begin
      FillEllipse(centerX - 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX - 10, centerY + 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY + 10, DOT_SIZE, DOT_SIZE);
    end;

    5: begin
      FillEllipse(centerX - 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX, centerY, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX - 10, centerY + 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY + 10, DOT_SIZE, DOT_SIZE);
    end;

    6: begin
      FillEllipse(centerX - 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY - 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX - 10, centerY, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX - 10, centerY + 10, DOT_SIZE, DOT_SIZE);
      FillEllipse(centerX + 10, centerY + 10, DOT_SIZE, DOT_SIZE);
    end;
  end;
end;

procedure DrawDice;
var
  y: Integer;
begin
  y := MARGIN_TOP + 50;
  SetTextStyle(DefaultFont, HorizDir, 2);

  { Affiche le joueur courant }
  if currentPlayer = 1 then
    OutTextXY(DICE_AREA_LEFT + 5, y - 30, 'Joueur:')
  else
    OutTextXY(DICE_AREA_LEFT + 5, y - 30, 'Ordi:');

  { Dessine les dés }
  DrawDiceShape(DICE_AREA_LEFT + 5, y + 10, dice[1]);
  DrawDiceShape(DICE_AREA_LEFT + 65, y + 10, dice[2]);

  { Ajoute la légende des couleurs avec textes décalés vers la droite }
  SetTextStyle(DefaultFont, HorizDir, 1);

  SetFillStyle(SolidFill, White);
  FillEllipse(DICE_AREA_LEFT + 10, y + 90, 8, 8);
  OutTextXY(DICE_AREA_LEFT + 42, y + 87, 'Humain');

  SetFillStyle(SolidFill, Black);
  FillEllipse(DICE_AREA_LEFT + 10, y + 110, 8, 8);
  OutTextXY(DICE_AREA_LEFT + 42, y + 107, 'Ordi');
end;

procedure DrawBoard;
var
  i, j, x, y: integer;
  trianglePoints: array[1..6] of integer;
begin
  ClearDevice;
  SetBkColor(Green);

  { Draw board outline }
  Rectangle(0, MARGIN_TOP + BOARD_TOP_OFFSET,
           BOARD_WIDTH, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET);
  Line(BOARD_WIDTH div 2, MARGIN_TOP + BOARD_TOP_OFFSET,
       BOARD_WIDTH div 2, BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET);

  { Draw points }
  for i := 1 to 24 do
  begin
    x := ((i-1) mod 12) * (BOARD_WIDTH div 12);
    if i > 12 then
      y := BOARD_HEIGHT + MARGIN_TOP + BOARD_TOP_OFFSET
    else
      y := MARGIN_TOP + BOARD_TOP_OFFSET;

    { Draw triangle }
    if i mod 2 = 0 then
      SetFillStyle(SolidFill, LightGray)
    else
      SetFillStyle(SolidFill, DarkGray);

    trianglePoints[1] := x;
    trianglePoints[2] := y;
    trianglePoints[3] := x + (BOARD_WIDTH div 12);
    trianglePoints[4] := y;
    trianglePoints[5] := x + (BOARD_WIDTH div 24);
    if i <= 12 then
      trianglePoints[6] := y + POINT_HEIGHT  { Triangles du haut pointant vers le bas }
    else
      trianglePoints[6] := y - POINT_HEIGHT; { Triangles du bas pointant vers le haut }

    FillPoly(3, trianglePoints);

    { Draw checkers avec positions ajustées }
    if board[i].count > 0 then
    begin
      if board[i].color = 1 then
        SetFillStyle(SolidFill, White)
      else
        SetFillStyle(SolidFill, Black);

      for j := 1 to board[i].count do
      begin
        if i <= 12 then
          FillEllipse(x + (BOARD_WIDTH div 24),
                     y + j * 30,
                     15, 15)
        else
          FillEllipse(x + (BOARD_WIDTH div 24),
                     y - j * 30,
                     15, 15);
      end;
    end;
  end;

  DrawDice;
  DrawLetters;
end;

procedure RollDice;
begin
  randomize;
  dice[1] := random(6) + 1;
  dice[2] := random(6) + 1;
end;

function IsValidMove(fromPos, toPos: integer): boolean;
begin
  IsValidMove := false;
  if (fromPos < 1) or (fromPos > 24) or (toPos < 1) or (toPos > 24) then exit;

  { Basic move validation }
  if board[fromPos].color <> currentPlayer then exit;
  if (board[toPos].count > 1) and (board[toPos].color <> currentPlayer) then exit;

  { Check if move matches dice roll }
  if (abs(toPos - fromPos) = dice[1]) or
     (abs(toPos - fromPos) = dice[2]) then
    IsValidMove := true;
end;

procedure MakeMove(fromPos, toPos: integer);
begin
  if not IsValidMove(fromPos, toPos) then exit;

  { Update board }
  dec(board[fromPos].count);
  if board[fromPos].count = 0 then
    board[fromPos].color := 0;

  inc(board[toPos].count);
  board[toPos].color := currentPlayer;

  DrawBoard;
end;

function LetterToPosition(c: Char; topHalf: Boolean): Integer;
begin
  if topHalf then
    LetterToPosition := Ord(UpCase(c)) - Ord('A') + 1
  else
    LetterToPosition := Ord(UpCase(c)) - Ord('M') + 13;  { Modifié pour M-X }
end;

procedure ComputerMove;
var
  fromPos, toPos, bestFrom, bestTo: Integer;
  validMoves: Integer;
begin
  validMoves := 0;
  bestFrom := 0;
  bestTo := 0;

  { Simple AI - Trouve le premier mouvement valide }
  for fromPos := 1 to 24 do
    for toPos := 1 to 24 do
      if IsValidMove(fromPos, toPos) then begin
        bestFrom := fromPos;
        bestTo := toPos;
        validMoves := validMoves + 1;
        break;
      end;

  if validMoves > 0 then
    MakeMove(bestFrom, bestTo);
end;

procedure SelectFirstPlayer;
var
  c: Char;
  centerX, centerY: Integer;
begin
  ClearDevice;
  SetBkColor(Black);
  centerX := GetMaxX div 2;
  centerY := GetMaxY div 2;

  { Affiche le titre }
  SetTextStyle(TriplexFont, HorizDir, 4);
  SetTextJustify(CenterText, CenterText);
  OutTextXY(centerX, centerY - 50, 'BACKGAMMON');

  { Affiche le message de sélection }
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(centerX, centerY, 'Qui commence?');
  OutTextXY(centerX, centerY + 30, '(H)umain, (O)rdinateur ou (Q)uitter');

  repeat
    c := UpCase(ReadKey);
  until c in ['H', 'O', 'Q'];

  if c = 'Q' then begin
    CloseGraph;
    Halt;
  end else if c = 'H' then begin
    currentPlayer := 1;
    player1Type := Human;
    player2Type := Computer;
  end else begin
    currentPlayer := 2;
    player1Type := Computer;
    player2Type := Human;
  end;
end;

procedure HandlePlayerMove;
var
  c: Char;
  fromPos, toPos: Integer;
begin
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 100, 'De: ');
  repeat
    c := ReadKey;
    if c = #27 then begin  { ESC }
      CloseGraph;
      Halt;
    end;
    c := UpCase(c);
  until c in ['A'..'L', 'M'..'X'];

  OutTextXY(DICE_AREA_LEFT + 80, MARGIN_TOP + 100, c);

  if c in ['A'..'L'] then
    fromPos := LetterToPosition(c, true)
  else
    fromPos := LetterToPosition(c, false);

  OutTextXY(DICE_AREA_LEFT, MARGIN_TOP + 130, 'Vers: ');
  repeat
    c := ReadKey;
    if c = #27 then begin  { ESC }
      CloseGraph;
      Halt;
    end;
    c := UpCase(c);
  until c in ['A'..'L', 'M'..'X'];

  OutTextXY(DICE_AREA_LEFT + 80, MARGIN_TOP + 130, c);

  if c in ['A'..'L'] then
    toPos := LetterToPosition(c, true)
  else
    toPos := LetterToPosition(c, false);

  MakeMove(fromPos, toPos);
end;

{ Programme principal modifié }
BEGIN
  InitializeGraphics;
  SelectFirstPlayer;
  InitializeBoard;

  repeat
    DrawBoard;
    RollDice;

    if ((currentPlayer = 1) and (player1Type = Human)) or
       ((currentPlayer = 2) and (player2Type = Human)) then
      HandlePlayerMove
    else
      ComputerMove;

    if KeyPressed then
      if ReadKey = #27 then break;

    currentPlayer := 3 - currentPlayer;
    Delay(500);
  until false;

  CloseGraph;
END.
