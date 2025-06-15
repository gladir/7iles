{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program MouseTrap;

Uses {$IFDEF FPC}
      Crt,PtcCrt,PtcGraph,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  GRID_SIZE = 20;
  GRID_WIDTH = 28;    { Réduit de 30 à 28 }
  GRID_HEIGHT = 20;
  CAT_COUNT = 3;
  CHEESE_COUNT = 5;
  CHEESE_POINTS = 50;  { Points pour chaque fromage }

Type
  TPosition = Record
    x, y: Integer;
  End;

  TDoor = Record
    pos: TPosition;
    isOpen: Boolean;
  End;

  TCat = Record
    pos: TPosition;
    direction: Integer;
    active: Boolean;
  End;

  TCheese = record
    x, y: Integer;
    active: Boolean;
  end;

{ Ajouter les d�clarations forward ici, après les types et avant les variables }
Procedure CheckCollisions; Forward;
Function  FindNearestDoor:Integer; Forward;
Function  IsDoorClosed(x,y:Integer):Boolean;Forward;
Procedure ShowCaughtMessage; Forward;
procedure CheckCheese; forward;

Var
  GraphDriver, GraphMode: Integer;
  Grid: array[1..GRID_WIDTH, 1..GRID_HEIGHT] of Char;
  PlayerPos: TPosition;
  Cats: array[1..CAT_COUNT] of TCat;
  Doors: array[1..8] of TDoor;
  Cheese: array[1..CHEESE_COUNT] of TCheese;
  Score, Lives: Integer;
  QuitGame: Boolean;
  MouthOpen: Boolean;  { Nouvelle variable pour l'animation }

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

Procedure InitGame;
const
  MAZE: array[1..20, 1..28] of Char = (  { Ajusté à 28 colonnes }
    '############################',
    '#..........................#',
    '#.####.####.#####.####.####',
    '#.#  #.#  #.#   #.#  #.# #',
    '#.####.####.#####.####.####',
    '#..........................#',
    '#.####.##.########.##.####.#',    { Ajout du # }
    '#.#  #.##.#  ##  #.##.#  #.#',    { Ajout du # }
    '#.####.##.########.##.####.#',    { Ajout du # }
    '#..........................#',
    '#.####.####.#####.####.####',
    '#.#  #.#  #.#   #.#  #.# #',
    '#.####.####.#####.####.####',
    '#..........................#',
    '#.##.####.########.####.##.#',    { Ajout du # }
    '#.##.#  #.#  ##  #.#  #.##.#',    { Ajout du # }
    '#.##.####.########.####.##.#',    { Ajout du # }
    '#..........................#',
    '#.####.####.#####.####.####',
    '############################');
var
  i, j: Integer;
begin
  { Initialize grid with maze layout }
  for i := 1 to GRID_HEIGHT do
    for j := 1 to GRID_WIDTH do
      Grid[j,i] := MAZE[i,j];

  { Initialize player }
  PlayerPos.x := 2;
  PlayerPos.y := 2;

  { Initialize cats at strategic positions }
  Cats[1].pos.x := GRID_WIDTH - 3;
  Cats[1].pos.y := 2;
  Cats[2].pos.x := GRID_WIDTH - 3;
  Cats[2].pos.y := GRID_HEIGHT div 2;
  Cats[3].pos.x := GRID_WIDTH - 3;
  Cats[3].pos.y := GRID_HEIGHT - 2;

  for i := 1 to CAT_COUNT do
  begin
    Cats[i].direction := Random(4);
    Cats[i].active := True;
  end;

  { Initialize doors at strategic intersections }
  Doors[1].pos.x := 7;
  Doors[1].pos.y := 5;
  Doors[2].pos.x := 15;
  Doors[2].pos.y := 5;
  Doors[3].pos.x := 23;
  Doors[3].pos.y := 5;
  Doors[4].pos.x := 7;
  Doors[4].pos.y := 10;
  Doors[5].pos.x := 15;
  Doors[5].pos.y := 10;
  Doors[6].pos.x := 23;
  Doors[6].pos.y := 10;
  Doors[7].pos.x := 7;
  Doors[7].pos.y := 15;
  Doors[8].pos.x := 23;
  Doors[8].pos.y := 15;

  for i := 1 to 8 do
    Doors[i].isOpen := False;

  { Initialize cheese }
  for i := 1 to CHEESE_COUNT do
  begin
    repeat
      Cheese[i].x := 2 + Random(GRID_WIDTH-2);
      Cheese[i].y := 2 + Random(GRID_HEIGHT-2);
    until (Grid[Cheese[i].x, Cheese[i].y] = '.') and
          not IsDoorClosed(Cheese[i].x, Cheese[i].y);
    Cheese[i].active := True;
  end;

  Score := 0;
  Lives := 3;
  QuitGame := False;
  MouthOpen := False;
end;

procedure DrawGrid;
var
  i, j: Integer;
begin
  for i := 1 to GRID_WIDTH do
    for j := 1 to GRID_HEIGHT do
    begin
      case Grid[i,j] of
        '#': begin
          SetColor(Blue);
          SetFillStyle(SolidFill, Blue);
          Bar(i*GRID_SIZE, j*GRID_SIZE,
              i*GRID_SIZE+GRID_SIZE, j*GRID_SIZE+GRID_SIZE);
        end;
        '.': begin
          SetColor(White);
          PutPixel(i*GRID_SIZE+GRID_SIZE div 2,
                  j*GRID_SIZE+GRID_SIZE div 2, White);
        end;
      end;
    end;
end;

Procedure DrawDoors;
Var
  i: Integer;
Begin
  for i := 1 to 8 do
    if not Doors[i].isOpen then
    begin
      SetColor(Brown);
      SetFillStyle(SolidFill, Brown);
      Bar(Doors[i].pos.x * GRID_SIZE,
          Doors[i].pos.y * GRID_SIZE,
          Doors[i].pos.x * GRID_SIZE + GRID_SIZE,
          Doors[i].pos.y * GRID_SIZE + GRID_SIZE);
    end;
End;

procedure DrawPlayer;
var
  x, y: Integer;
begin
  x := PlayerPos.x * GRID_SIZE;
  y := PlayerPos.y * GRID_SIZE;

  { Corps principal jaune }
  SetColor(Yellow);
  SetFillStyle(SolidFill, Yellow);
  Bar(x + 4, y + 4, x + GRID_SIZE - 4, y + GRID_SIZE - 4);

  { Oreilles }
  Bar(x + 4, y + 2, x + 8, y + 6);
  Bar(x + GRID_SIZE - 8, y + 2, x + GRID_SIZE - 4, y + 6);

  { Yeux }
  SetColor(Black);
  SetFillStyle(SolidFill, Black);
  Bar(x + 7, y + 7, x + 9, y + 9);
  Bar(x + GRID_SIZE - 9, y + 7, x + GRID_SIZE - 7, y + 9);

  { Bouche animée }
  if MouthOpen then
    Bar(x + 8, y + GRID_SIZE - 8, x + GRID_SIZE - 8, y + GRID_SIZE - 6)
  else
    Bar(x + 10, y + GRID_SIZE - 7, x + GRID_SIZE - 10, y + GRID_SIZE - 7);

  MouthOpen := not MouthOpen;  { Alterner l'état de la bouche }
end;

Procedure DrawCats;
Var
 i,x,y:Integer;
begin
  for i := 1 to CAT_COUNT do
    if Cats[i].active then
    begin
      x := Cats[i].pos.x * GRID_SIZE;
      y := Cats[i].pos.y * GRID_SIZE;

      { Corps principal }
      SetColor(LightGray);
      SetFillStyle(SolidFill, LightGray);

      { Corps central - légèrement réduit }
      Bar(x + 5, y + 5, x + GRID_SIZE - 5, y + GRID_SIZE - 5);

      { Queue - maintenant plus visible avec un espace }
      case Cats[i].direction of
        0: begin { Droite }
          Bar(x + GRID_SIZE - 3, y + 8, x + GRID_SIZE, y + 11);
        end;
        1: begin { Gauche }
          Bar(x, y + 8, x + 3, y + 11);
        end;
        2: begin { Bas }
          Bar(x + 8, y + GRID_SIZE - 3, x + 11, y + GRID_SIZE);
        end;
        3: begin { Haut }
          Bar(x + 8, y, x + 11, y + 3);
        end;
      end;

      { Oreilles pointues }
      Bar(x + 2, y + 2, x + 6, y + 6);
      Bar(x + GRID_SIZE - 6, y + 2, x + GRID_SIZE - 2, y + 6);

      { Yeux }
      SetColor(Black);
      SetFillStyle(SolidFill, Black);
      Bar(x + 7, y + 7, x + 9, y + 9);
      Bar(x + GRID_SIZE - 9, y + 7, x + GRID_SIZE - 7, y + 9);

      { Museau }
      SetColor(DarkGray);
      SetFillStyle(SolidFill, DarkGray);
      Bar(x + 8, y + GRID_SIZE - 8, x + GRID_SIZE - 8, y + GRID_SIZE - 6);
    end;
end;

Procedure DrawCheese;
var
  i: Integer;
begin
  SetColor(Yellow);
  SetFillStyle(SolidFill, Yellow);
  for i := 1 to CHEESE_COUNT do
    if Cheese[i].active then
    begin
      Bar(Cheese[i].x * GRID_SIZE + 6,
          Cheese[i].y * GRID_SIZE + 6,
          Cheese[i].x * GRID_SIZE + GRID_SIZE - 6,
          Cheese[i].y * GRID_SIZE + GRID_SIZE - 6);
    end;
end;

Function IsDoorClosed(x,y:Integer):Boolean;
Var
 i:Integer;
Begin
 IsDoorClosed := False;
 For i := 1 to 8 do
  if (x = Doors[i].pos.x) and (y = Doors[i].pos.y) and not Doors[i].isOpen then
   Begin
    IsDoorClosed := True;
    Exit;
   End;
End;

procedure HandleInput;
var
  doorIndex: Integer;
begin
  if KeyPressed then
    case ReadKey of
      #27: QuitGame := True;
      #0: case ReadKey of
        #72: if (Grid[PlayerPos.x, PlayerPos.y-1] <> '#') and
                not IsDoorClosed(PlayerPos.x, PlayerPos.y-1) then
              begin
                Dec(PlayerPos.y);
                if Grid[PlayerPos.x, PlayerPos.y] = '.' then
                begin
                  Grid[PlayerPos.x, PlayerPos.y] := ' ';  { Efface le point }
                  Inc(Score, 10);  { Augmente le score }
                end;
              end;
        #80: if (Grid[PlayerPos.x, PlayerPos.y+1] <> '#') and
                not IsDoorClosed(PlayerPos.x, PlayerPos.y+1) then
              begin
                Inc(PlayerPos.y);
                if Grid[PlayerPos.x, PlayerPos.y] = '.' then
                begin
                  Grid[PlayerPos.x, PlayerPos.y] := ' ';
                  Inc(Score, 10);
                end;
              end;
        #75: if (Grid[PlayerPos.x-1, PlayerPos.y] <> '#') and
                not IsDoorClosed(PlayerPos.x-1, PlayerPos.y) then
              begin
                Dec(PlayerPos.x);
                if Grid[PlayerPos.x, PlayerPos.y] = '.' then
                begin
                  Grid[PlayerPos.x, PlayerPos.y] := ' ';
                  Inc(Score, 10);
                end;
              end;
        #77: if (Grid[PlayerPos.x+1, PlayerPos.y] <> '#') and
                not IsDoorClosed(PlayerPos.x+1, PlayerPos.y) then
              begin
                Inc(PlayerPos.x);
                if Grid[PlayerPos.x, PlayerPos.y] = '.' then
                begin
                  Grid[PlayerPos.x, PlayerPos.y] := ' ';
                  Inc(Score, 10);
                end;
              end;
      end;
      ' ': begin  { Touche espace pour les portes }
        doorIndex := FindNearestDoor;
        if doorIndex > 0 then
        begin
          Doors[doorIndex].isOpen := not Doors[doorIndex].isOpen;
          { Son ou effet visuel optionnel }
          Inc(Score);  { Point bonus pour utilisation de porte }
        end;
      end;
    end;
end;

function FindNearestDoor: Integer;
var
  i, dx, dy, dist, minDist: Integer;
  nearest: Integer;
begin
  nearest := 0;
  minDist := 999;
  for i := 1 to 8 do
  begin
    dx := Abs(PlayerPos.x - Doors[i].pos.x);
    dy := Abs(PlayerPos.y - Doors[i].pos.y);
    dist := dx + dy;
    if dist < 3 then  { Distance maximale pour activer une porte }
    begin
      if dist < minDist then
      begin
        minDist := dist;
        nearest := i;
      end;
    end;
  end;
  FindNearestDoor := nearest;
end;

Procedure MoveCats;
Var
  i: Integer;
  newX, newY: Integer;
Begin
  For i := 1 To CAT_COUNT Do
    If Cats[i].active Then
    Begin
      newX := Cats[i].pos.x;
      newY := Cats[i].pos.y;

      Case Cats[i].direction Of
        0: newX := newX + 1;
        1: newX := newX - 1;
        2: newY := newY + 1;
        3: newY := newY - 1;
      End;

      { Vérifier les limites du labyrinthe }
      If (newX > 1) And (newX < GRID_WIDTH) And
         (newY > 1) And (newY < GRID_HEIGHT) And
         (Grid[newX, newY] <> '#') And
         Not IsDoorClosed(newX, newY) Then
      Begin
        Cats[i].pos.x := newX;
        Cats[i].pos.y := newY;
      End
      Else
        Cats[i].direction := Random(4);  { Changer de direction si bloqué }

      If Random(20) = 0 Then
        Cats[i].direction := Random(4);
    End;
End;

Procedure CheckCollisions;
Var
 i:Integer;
Begin
 For i:=1 to CAT_COUNT do
  If Cats[i].active and(Cats[i].pos.x = PlayerPos.x) and
    (Cats[i].pos.y = PlayerPos.y) Then Begin
   ShowCaughtMessage;
   Dec(Lives);
   If Lives <= 0 Then QuitGame := True
    Else
   Begin
    PlayerPos.x := 2;
    PlayerPos.y := 2;
   End;
  End;
End;

Procedure ShowCaughtMessage;
Var
 centerX,centerY,i:Integer;
 message: String;
 oldTextInfo:TextSettingsType;
Begin
  { Sauvegarder les paramStres de texte actuels }
 GetTextSettings(oldTextInfo);

 centerX:=GetMaxX div 2;
 centerY:=GetMaxY div 2;
 message:='LA SOURIS EST ATTRAPEE!';

 For i := 1 to 6 do Begin
  If i mod 2=0 Then SetColor(Yellow)
               Else SetColor(Red);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(centerX - 100, centerY, message);
  Delay(500);
 End;

  { Restaurer les paramStres de texte }
 With oldTextInfo do SetTextStyle(Font, Direction, CharSize);
End;

procedure CheckCheese;
var
  i: Integer;
begin
  for i := 1 to CHEESE_COUNT do
    if Cheese[i].active and
       (PlayerPos.x = Cheese[i].x) and
       (PlayerPos.y = Cheese[i].y) then
    begin
      Cheese[i].active := False;
      Inc(Score, CHEESE_POINTS);
    end;
end;

Procedure ShowStatus;
Var
 s:String;
Begin
 SetColor(White);
 Str(Score, s);
 OutTextXY(10, 10, 'Pointage : ' + s);
 Str(Lives, S);
 OutTextXY(GetMaxX - 100, 10, 'Vies : ' + s);
End;

BEGIN
 InitializeGraphics;
 Randomize;
 InitGame;
 Repeat
  ClearDevice;
  DrawGrid;
  DrawDoors;
  DrawCheese;  { Ajouter cette ligne }
  DrawPlayer;
  DrawCats;
  ShowStatus;
  HandleInput;
  MoveCats;
  CheckCollisions;
  CheckCheese;  { Ajouter cette ligne }
  Delay(50);
 Until QuitGame;
 CloseGraph;
 WriteLn('Partie terminer ! Pointages : ', Score);
END.

