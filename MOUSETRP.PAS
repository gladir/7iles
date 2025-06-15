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
 GRID_SIZE=20;
 GRID_WIDTH=28;
 GRID_HEIGHT=20;
 CAT_COUNT=3;
 CHEESE_COUNT=5;
 CHEESE_POINTS=50;  { Points pour chaque fromage }

Type
 TPosition=Record
  x,y:Integer;
 End;

 TDoor=Record
  pos:TPosition;
  isHorizontal:Boolean;  { Alterne entre horizontal et vertical }
 End;

 TCat=Record
  pos:TPosition;
  direction:Integer;
  active:Boolean;
 End;

 TCheese=Record
  x,y:Integer;
  active:Boolean;
 End;

{ Ajouter les d�clarations forward ici, après les types et avant les variables }
Procedure CheckCollisions; Forward;
Function  FindNearestDoor:Integer; Forward;
Function  IsDoorClosed(x,y:Integer):Boolean;Forward;
Procedure ShowCaughtMessage; Forward;
procedure CheckCheese; forward;
procedure ShowTitleScreen; forward;

Var
 GraphDriver, GraphMode: Integer;
 Grid:Array[1..GRID_WIDTH, 1..GRID_HEIGHT] of Char;
 PlayerPos:TPosition;
 Cats:Array[1..CAT_COUNT] of TCat;
 Doors:Array[1..8] of TDoor;
 Cheese:Array[1..CHEESE_COUNT] of TCheese;
 Score,Lives:Integer;
 QuitGame:Boolean;
 MouthOpen:Boolean;  { Nouvelle variable pour l'animation }

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
Const
 MAZE: array[1..20, 1..28] of Char = (
    '############################',
    '#..........................#',
    '#.####.####.#####.####.####',
    '#.#  #.#  #.#   #.#  #.# #',
    '#.####.####.#####.####.####',
    '#..........................#',
    '#.####.##.########.##.####.#',
    '#.#  #.##.#  ##  #.##.#  #.#',
    '#.####.##.########.##.####.#',
    '#..........................#',
    '#.####.####.#####.####.####',
    '#.#  #.#  #.#   #.#  #.# #',
    '#.####.####.#####.####.####',
    '#..........................#',
    '#.##.####.########.####.##.#',
    '#.##.#  #.#  ##  #.#  #.##.#',
    '#.##.####.########.####.##.#',
    '#..........................#',
    '#.####.####.#####.####.####',
    '############################');
Var
 i,j:Integer;
Begin
 For i:=1 to GRID_HEIGHT do For j:=1 to GRID_WIDTH do Grid[j,i]:=MAZE[i,j];

  { Initialise le joueur }
 PlayerPos.x:=2;
 PlayerPos.y:=2;

  { Initialise les chats et la position strat�gique }
 Cats[1].pos.x:=GRID_WIDTH - 3;
 Cats[1].pos.y:=2;
 Cats[2].pos.x:=GRID_WIDTH - 3;
 Cats[2].pos.y:=GRID_HEIGHT div 2;
 Cats[3].pos.x:=GRID_WIDTH - 3;
 Cats[3].pos.y:=GRID_HEIGHT - 2;

 For i:=1 to CAT_COUNT do Begin
  Cats[i].direction:=Random(4);
  Cats[i].active:=True;
 End;

  { Initialise les portes et les intersections strat�giques }
  { Réinitialisation des positions des portes aux intersections avec des points }
  Doors[1].pos.x := 7;
  Doors[1].pos.y := 6;
  Doors[1].isHorizontal := True;

  Doors[2].pos.x := 15;
  Doors[2].pos.y := 6;
  Doors[2].isHorizontal := True;

  Doors[3].pos.x := 21;
  Doors[3].pos.y := 5;
  Doors[3].isHorizontal := True;

  Doors[4].pos.x := 7;
  Doors[4].pos.y := 10;
  Doors[4].isHorizontal := True;

  Doors[5].pos.x := 15;
  Doors[5].pos.y := 10;
  Doors[5].isHorizontal := True;

  Doors[6].pos.x := 21;
  Doors[6].pos.y := 10;
  Doors[6].isHorizontal := True;

  Doors[7].pos.x := 7;
  Doors[7].pos.y := 14;
  Doors[7].isHorizontal := True;

  Doors[8].pos.x := 21;
  Doors[8].pos.y := 14;
  Doors[8].isHorizontal := True;

  { Initialise le fromage }
 For i:=1 to CHEESE_COUNT do Begin
  Repeat
   Cheese[i].x:=2+Random(GRID_WIDTH-2);
   Cheese[i].y:=2+Random(GRID_HEIGHT-2);
  Until (Grid[Cheese[i].x, Cheese[i].y] = '.') and
        Not IsDoorClosed(Cheese[i].x, Cheese[i].y);
  Cheese[i].active := True;
 End;
 Score:=0;
 Lives:=3;
 QuitGame:=False;
 MouthOpen:=False;
End;

Procedure DrawGrid;
Var
 i,j:Integer;
Begin
 For i:=1 to GRID_WIDTH do For j:=1 to GRID_HEIGHT do Begin
  Case Grid[i,j] of
    '#':Begin
     SetColor(Blue);
     SetFillStyle(SolidFill, Blue);
     Bar(i*GRID_SIZE,j*GRID_SIZE,i*GRID_SIZE+GRID_SIZE,j*GRID_SIZE+GRID_SIZE);
    End;
    '.': begin
     SetColor(White);
     PutPixel(i*GRID_SIZE+GRID_SIZE div 2,j*GRID_SIZE+GRID_SIZE div 2,White);
   End;
  End;
 End;
End;

Procedure DrawDoors;
Var
 i, x, y: Integer;
Begin
 SetColor(Brown);
 SetFillStyle(SolidFill, Brown);

 For i := 1 to 8 do Begin
  x := Doors[i].pos.x * GRID_SIZE;
  y := Doors[i].pos.y * GRID_SIZE;

  If Doors[i].isHorizontal Then
  Begin
   { Porte en position horizontale - permet passage vers le haut }
   Bar(x, y + GRID_SIZE - 2,
       x + GRID_SIZE, y + GRID_SIZE + 2);
  End
  Else
  Begin
   { Porte en position verticale - permet passage vers la gauche }
   Bar(x + GRID_SIZE - 2, y,
       x + GRID_SIZE + 2, y + GRID_SIZE);
  End;
 End;
End;

Procedure DrawPlayer;
Var
 x,y:Integer;
Begin
 x:=PlayerPos.x*GRID_SIZE;
 y:=PlayerPos.y*GRID_SIZE;

  { Corps principal jaune }
 SetColor(Yellow);
 SetFillStyle(SolidFill, Yellow);
 Bar(x + 4, y + 4, x + GRID_SIZE - 4, y+GRID_SIZE-4);

  { Oreilles }
 Bar(x + 4, y + 2, x + 8, y + 6);
 Bar(x + GRID_SIZE - 8, y + 2, x + GRID_SIZE - 4, y + 6);

  { Yeux }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(x + 7, y + 7, x + 9, y + 9);
 Bar(x + GRID_SIZE - 9, y + 7, x + GRID_SIZE - 7, y + 9);

  { Bouche animée }
 If MouthOpen Then
  Bar(x + 8, y + GRID_SIZE - 8, x + GRID_SIZE - 8, y + GRID_SIZE - 6)
 Else
  Bar(x + 10, y + GRID_SIZE - 7, x + GRID_SIZE - 10, y + GRID_SIZE - 7);

 MouthOpen := not MouthOpen;  { Alterner l'�tat de la bouche }
End;

Procedure DrawCats;
Var
 i,x,y:Integer;
Begin
 For i := 1 to CAT_COUNT do If Cats[i].active Then Begin
  x:=Cats[i].pos.x*GRID_SIZE;
  y:=Cats[i].pos.y*GRID_SIZE;

   { Corps principal }
  SetColor(LightGray);
  SetFillStyle(SolidFill, LightGray);
   { Corps central - légèrement réduit }
  Bar(x + 5, y + 5, x + GRID_SIZE - 5, y + GRID_SIZE - 5);

   { Queue - maintenant plus visible avec un espace }
  Case Cats[i].direction of
   0:Begin { Droite }
    Bar(x + GRID_SIZE - 3, y + 8, x + GRID_SIZE, y + 11);
   End;
   1:Begin { Gauche }
    Bar(x, y + 8, x + 3, y + 11);
   End;
   2:Begin { Bas }
    Bar(x + 8, y + GRID_SIZE - 3, x + 11, y + GRID_SIZE);
   end;
   3:Begin { Haut }
    Bar(x + 8, y, x + 11, y + 3);
   End;
  End;

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
 End;
End;

Procedure DrawCheese;
Var
 i,baseX,baseY:Integer;
 points:Array[1..3] of PointType;
Begin
 For i:=1 to CHEESE_COUNT do If Cheese[i].active Then Begin
  baseX := Cheese[i].x * GRID_SIZE;
  baseY := Cheese[i].y * GRID_SIZE;

   { Dessiner le triangle du fromage }
  points[1].x := baseX + 4;
  points[1].y := baseY + GRID_SIZE - 4;
  points[2].x := baseX + GRID_SIZE - 4;
  points[2].y := baseY + GRID_SIZE - 4;
  points[3].x := baseX + (GRID_SIZE div 2);
  points[3].y := baseY + 4;

   { Dessiner le fromage en jaune }
  SetColor(Yellow);
  SetFillStyle(SolidFill, Yellow);
  FillPoly(3, points);

   { Dessiner les trous noirs }
  SetColor(Black);
  SetFillStyle(SolidFill, Black);
  FillEllipse(baseX + 8, baseY + 12, 2, 2);
  FillEllipse(baseX + GRID_SIZE - 8, baseY + 10, 2, 2);
  FillEllipse(baseX + (GRID_SIZE div 2), baseY + (GRID_SIZE div 2), 2, 2);
 End;
End;

Function IsDoorClosed(x,y:Integer):Boolean;
Var
 i:Integer;
Begin
 IsDoorClosed := False;
 For i := 1 to 8 do
  if (x = Doors[i].pos.x) and (y = Doors[i].pos.y) then
   Begin
    if Doors[i].isHorizontal then
    begin
      if y = Doors[i].pos.y then
        IsDoorClosed := True;
    end
    else
    begin
      if x = Doors[i].pos.x then
        IsDoorClosed := True;
    end;
    Exit;
   End;
End;

Function IsDoorBlocking(x, y, newX, newY: Integer): Boolean;
Var
  i: Integer;
  dx, dy: Integer;
Begin
  IsDoorBlocking := False;
  dx := newX - x;
  dy := newY - y;

  for i := 1 to 8 do
    if (x = Doors[i].pos.x) and (y = Doors[i].pos.y) then
    begin
      if Doors[i].isHorizontal then
      begin
        { Si la porte est horizontale }
        if dy > 0 then { Mouvement vers le bas }
          IsDoorBlocking := True
        else if dy < 0 then { Mouvement vers le haut }
          IsDoorBlocking := False;
      end
      else
      begin
        { Si la porte est verticale }
        if dx > 0 then { Mouvement vers la droite }
          IsDoorBlocking := True
        else if dx < 0 then { Mouvement vers la gauche }
          IsDoorBlocking := False;
      end;
      Exit;
    end;
End;

Procedure HandleInput;
var
  doorIndex: Integer;
  newX, newY: Integer;
begin
  if KeyPressed then
    case ReadKey of
      #27: QuitGame := True;
      #0: case ReadKey of
        #72: begin { Up }
          newX := PlayerPos.x;
          newY := PlayerPos.y - 1;
          if (Grid[newX, newY] <> '#') and
             not IsDoorBlocking(PlayerPos.x, PlayerPos.y, newX, newY) then
          begin
            Dec(PlayerPos.y);
            if Grid[PlayerPos.x, PlayerPos.y] = '.' then
            begin
              Grid[PlayerPos.x, PlayerPos.y] := ' ';
              Inc(Score, 10);
            end;
          end;
        end;
        #80: begin { Down }
          newX := PlayerPos.x;
          newY := PlayerPos.y + 1;
          if (Grid[newX, newY] <> '#') and
             not IsDoorBlocking(PlayerPos.x, PlayerPos.y, newX, newY) then
          begin
            Inc(PlayerPos.y);
            if Grid[PlayerPos.x, PlayerPos.y] = '.' then
            begin
              Grid[PlayerPos.x, PlayerPos.y] := ' ';
              Inc(Score, 10);
            end;
          end;
        end;
        #75: begin { Left }
          newX := PlayerPos.x - 1;
          newY := PlayerPos.y;
          if (Grid[newX, newY] <> '#') and
             not IsDoorBlocking(PlayerPos.x, PlayerPos.y, newX, newY) then
          begin
            Dec(PlayerPos.x);
            if Grid[PlayerPos.x, PlayerPos.y] = '.' then
            begin
              Grid[PlayerPos.x, PlayerPos.y] := ' ';
              Inc(Score, 10);
            end;
          end;
        end;
        #77: begin { Right }
          newX := PlayerPos.x + 1;
          newY := PlayerPos.y;
          if (Grid[newX, newY] <> '#') and
             not IsDoorBlocking(PlayerPos.x, PlayerPos.y, newX, newY) then
          begin
            Inc(PlayerPos.x);
            if Grid[PlayerPos.x, PlayerPos.y] = '.' then
            begin
              Grid[PlayerPos.x, PlayerPos.y] := ' ';
              Inc(Score, 10);
            end;
          end;
        end;
      end;
      ' ':Begin  { Touche espace pour les portes }
        doorIndex := FindNearestDoor;
        If doorIndex > 0 Then Begin
          Doors[doorIndex].isHorizontal := not Doors[doorIndex].isHorizontal;
          Inc(Score);
        End;
      End;
    end;
end;

Function FindNearestDoor:Integer;
Var
 i,dx,dy,dist,minDist:Integer;
 nearest: Integer;
Begin
 nearest := 0;
 minDist := 999;
 For i:=1 to 8 do Begin
  dx:=Abs(PlayerPos.x - Doors[i].pos.x);
  dy:=Abs(PlayerPos.y - Doors[i].pos.y);
  dist := dx + dy;
  If dist<3 Then Begin { Distance maximale pour activer une porte }
   If dist < minDist Then Begin
    minDist := dist;
    nearest := i;
   End;
  End;
 End;
 FindNearestDoor := nearest;
End;

Procedure MoveCats;
Var
 i:Integer;
 newX,newY:Integer;
Begin
 For i:=1 To CAT_COUNT do If Cats[i].active Then Begin
  newX := Cats[i].pos.x;
  newY := Cats[i].pos.y;
  Case Cats[i].direction Of
   0: newX:=newX + 1;
   1: newX:=newX - 1;
   2: newY:=newY + 1;
   3: newY:=newY - 1;
  End;

  { V�rifier les limites du labyrinthe }
  If (newX > 1) And (newX < GRID_WIDTH) And
     (newY > 1) And (newY < GRID_HEIGHT) And
     (Grid[newX, newY] <> '#') And
       Not IsDoorClosed(newX, newY)Then Begin
   Cats[i].pos.x := newX;
   Cats[i].pos.y := newY;
  End
   Else
  Cats[i].direction:=Random(4);  { Changer de direction si bloqu� }
  If Random(20)=0 Then Cats[i].direction:=Random(4);
 End;
End;

Procedure CheckCollisions;
Var
 i:Integer;
Procedure ResetCatPositions;
var
  i: Integer;
begin
  Cats[1].pos.x := GRID_WIDTH - 3;
  Cats[1].pos.y := 2;
  Cats[2].pos.x := GRID_WIDTH - 3;
  Cats[2].pos.y := GRID_HEIGHT div 2;
  Cats[3].pos.x := GRID_WIDTH - 3;
  Cats[3].pos.y := GRID_HEIGHT - 2;

  for i := 1 to CAT_COUNT do
    Cats[i].direction := Random(4);
end;

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
    ResetCatPositions;  { Ajout de la réinitialisation des chats }
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

Procedure CheckCheese;
Var
 i:Integer;
Begin
 For i:=1 to CHEESE_COUNT do Begin
  If(Cheese[i].active)and(PlayerPos.x=Cheese[i].x)and(PlayerPos.y=Cheese[i].y)Then Begin
   Cheese[i].active := False;
   Inc(Score, CHEESE_POINTS);
  End;
 End;
End;

Procedure ShowStatus;
Var
 s:String;
Begin
 SetTextStyle(SmallFont, HorizDir, 1);
 SetColor(White);
 Str(Score, s);
 OutTextXY(10, 10, 'Pointage : ' + s);
 Str(Lives, S);
 OutTextXY(GetMaxX - 100, 10, 'Vies : ' + s);
End;

Procedure ShowTitleScreen;
Var
 centerX,mouseX,mouseY,targetY:Integer;
 movingDown:Boolean;
 ch:Char;
Begin
 ClearDevice;
 centerX := GetMaxX div 2;
 SetTextStyle(TriplexFont, HorizDir, 6);
 SetColor(Yellow);
 OutTextXY(centerX - 200, 50, 'MOUSE TRAP');
 mouseX:=50;
 mouseY:=150;
 targetY:=300;
 MovingDown:=False;
 Repeat
  SetColor(Black);
  SetFillStyle(SolidFill, Black);
  Bar(mouseX - 10, mouseY - 10, mouseX + 30, mouseY + 30);
  If Not movingDown Then Begin
   Inc(mouseX,2);
   If mouseX >= centerX Then movingDown := True;
  End
   Else
  If mouseY<targetY Then Inc(mouseY, 2);
  SetColor(Yellow);
  SetFillStyle(SolidFill, Yellow);
  Bar(mouseX + 4, mouseY + 4, mouseX + GRID_SIZE - 4, mouseY + GRID_SIZE - 4);
  Bar(mouseX + 4, mouseY + 2, mouseX + 8, mouseY + 6);
  Bar(mouseX + GRID_SIZE - 8, mouseY + 2, mouseX + GRID_SIZE - 4, mouseY + 6);
  SetColor(Black);
  SetFillStyle(SolidFill, Black);
  Bar(mouseX + 7, mouseY + 7, mouseX + 9, mouseY + 9);
  Bar(mouseX + GRID_SIZE - 9, mouseY + 7, mouseX + GRID_SIZE - 7, mouseY + 9);
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(centerX - 240, GetMaxY - 50, 'Presse une touche pour commencer');
  Delay(20);
 Until KeyPressed;
 If(KeyPressed)Then ch:=ReadKey;
 ClearDevice;
End;

BEGIN
 InitializeGraphics;
 Randomize;
 ShowTitleScreen;  { Ajout de l'écran titre }
 InitGame;
 Repeat
  ClearDevice;
  DrawGrid;
  DrawDoors;
  DrawCheese;
  DrawPlayer;
  DrawCats;
  ShowStatus;
  HandleInput;
  MoveCats;
  CheckCollisions;
  CheckCheese;
  Delay(50);
 Until QuitGame;
 CloseGraph;
 WriteLn('Partie terminer ! Pointages : ', Score);
END.
