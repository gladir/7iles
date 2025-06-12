{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program QBert;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  { Configuration du jeu }
  CUBE_SIZE = 20;
  PYRAMID_LEVELS = 7;
  MAX_ENEMIES = 3;
  SNAKE_SPEED = 2.0;
  MAX_SNAKES = 3;

  { Couleurs }
  BACKGROUND_COLOR = BLACK;
  INITIAL_CUBE_COLOR = LIGHTBLUE;
  COMPLETED_CUBE_COLOR = YELLOW;
  QBERT_COLOR = RED;
  ENEMY_COLOR = MAGENTA;
  TEXT_COLOR = WHITE;

Type
  TPosition = Record
    X, Y: Integer;
  End;

  TCube = RECORD
    Row, Col: Integer;
    Position: TPosition;
    Completed: Boolean;
  END;

  TCharacter = Record
    Row, Col: Integer;
    Position: TPosition;
    IsJumping: Boolean;
    StartPos, TargetPos: TPosition;
    JumpProgress: Real;
  End;

  TSnake = Record
    Active: Boolean;
    Row, Col: Integer;
    Position: TPosition;
    Direction: Integer; { -1: gauche, 1: droite }
    Speed: Real;
  End;

  TPyramid = Array[0..PYRAMID_LEVELS-1, 0..PYRAMID_LEVELS-1] OF TCube;

Var
  GraphDriver, GraphMode: Integer;
  Pyramid: TPyramid;
  Q_Bert: TCharacter;
  Enemies: Array[1..MAX_ENEMIES] OF TCharacter;
  Snakes: Array[1..MAX_SNAKES] of TSnake;
  Score, Lives, CompletedCubes, TotalCubes: Integer;
  GameRunning, GameOver: Boolean;
  LastTime, CurrentTime: LongInt;
  Key:Char;
  ElapsedTime: Real;
  SnakeSpawnTimer: Real;
  I:Integer;

Function GetCurrentTime:LongInt;Begin
 {$IFDEF FPC}
  GetCurrentTime := GetTickCount64 div 55; { Free Pascal - conversion pour correspondre � l'�chelle de temps }
 {$ELSE}
  GetCurrentTime := MemL[Seg0040:$006C]; { Turbo Pascal - lecture directe de la m�moire }
 {$ENDIF}
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

{ Fonction modifi�e pour calculer la position d'un cube sur l'�cran - Structure pyramidale corrig�e }
Procedure CalculatePosition(Row, Col: Integer; Var Result: TPosition);
Var
 CenterX, TopY: Integer;
Begin
 CenterX := GetMaxX DIV 2;
 TopY := 50;

 { Nouvelle formule pour cr�er une pyramide correcte }
 Result.X := Trunc(CenterX + (Col - Row/2) * CUBE_SIZE * 2);
 Result.Y := Trunc(TopY + Row * CUBE_SIZE * 1.5);
End;

{ Proc�dure pour initialiser la pyramide - Mise � jour pour l'appel � CalculatePosition }
Procedure InitializePyramid;
Var
 Row,Col:Integer;
Begin
 TotalCubes:=0;
 CompletedCubes:=0;
 For Row:=0 TO Pyramid_Levels-1 do Begin
  For Col := 0 TO Row do Begin
   Pyramid[Row,Col].Row := Row;
   Pyramid[Row,Col].Col := Col;
   CalculatePosition(Row,Col,Pyramid[Row,Col].Position);
   Pyramid[Row,Col].Completed:=False;
   Inc(TotalCubes);
  End;
 End;
End;

{ Proc�dure pour initialiser QBert - Mise � jour pour l'appel � CalculatePosition }
PROCEDURE InitializeQBert;
BEGIN
  Q_Bert.Row := 0;
  Q_Bert.Col := 0;
  CalculatePosition(0, 0, Q_Bert.Position);
  Q_Bert.IsJumping := FALSE;
  Q_Bert.JumpProgress := 0;
END;

Procedure InitializeSnakes;
Var
  I: Integer;
Begin
  For I := 1 to MAX_SNAKES do Begin
    Snakes[I].Active := False;
  End;
  SnakeSpawnTimer := 0;
End;

Procedure SpawnSnake;
Var
  I: Integer;
Begin
  For I := 1 to MAX_SNAKES do Begin
    If Not Snakes[I].Active Then Begin
      Snakes[I].Active := True;
      Snakes[I].Row := 0;
      Snakes[I].Col := 0;
      Snakes[I].Direction := 1;
      Snakes[I].Speed := SNAKE_SPEED;
      CalculatePosition(Snakes[I].Row, Snakes[I].Col, Snakes[I].Position);
      Break;
    End;
  End;
End;

{ Proc�dure pour dessiner un cube }
PROCEDURE DrawCube(X, Y: Integer; Completed: Boolean);
VAR
  Points: ARRAY[1..12] OF Integer;
  Color: Integer;
BEGIN
  IF Completed THEN
    Color := COMPLETED_CUBE_COLOR
  ELSE
    Color := INITIAL_CUBE_COLOR;

  { D�finition des points du cube isom�trique }
  Points[1] := X;
  Points[2] := Y - CUBE_SIZE;
  Points[3] := X + CUBE_SIZE;
  Points[4] := Y - CUBE_SIZE DIV 2;
  Points[5] := X;
  Points[6] := Y;
  Points[7] := X - CUBE_SIZE;
  Points[8] := Y - CUBE_SIZE DIV 2;

  Points[9] := X;
  Points[10] := Y;
  Points[11] := X + CUBE_SIZE;
  Points[12] := Y - CUBE_SIZE DIV 2;

  { Face sup�rieure }
  SetFillStyle(SolidFill, Color);
  SetColor(DARKGRAY);
  FillPoly(4, Points);

  { Face droite }
  Points[1] := X;
  Points[2] := Y;
  Points[3] := X + CUBE_SIZE;
  Points[4] := Y - CUBE_SIZE DIV 2;
  Points[5] := X + CUBE_SIZE;
  Points[6] := Y + CUBE_SIZE DIV 2;
  Points[7] := X;
  Points[8] := Y + CUBE_SIZE;

  SetFillStyle(SolidFill, Color - 8); { Plus fonc� }
  FillPoly(4, Points);

  { Face gauche }
  Points[1] := X;
  Points[2] := Y;
  Points[3] := X - CUBE_SIZE;
  Points[4] := Y - CUBE_SIZE DIV 2;
  Points[5] := X - CUBE_SIZE;
  Points[6] := Y + CUBE_SIZE DIV 2;
  Points[7] := X;
  Points[8] := Y + CUBE_SIZE;

  SetFillStyle(SolidFill,Color-4); { Moyennement fonc� }
  FillPoly(4, Points);
END;

{ Proc�dure pour dessiner QBert }
PROCEDURE DrawQBert(X, Y: Integer);
BEGIN
  { Corps principal (cercle) }
  SetColor({BLACK}QBERT_COLOR);
  SetFillStyle(SolidFill, QBERT_COLOR);
  FillEllipse(X, Y - CUBE_SIZE * 3 DIV 4, CUBE_SIZE DIV 2, CUBE_SIZE DIV 2);

  { Yeux }
  SetFillStyle(SolidFill,WHITE);
  FillEllipse(X - CUBE_SIZE DIV 6, Y - CUBE_SIZE DIV 1 - 2, 3, 3);
  FillEllipse(X + CUBE_SIZE DIV 6, Y - CUBE_SIZE DIV 1 - 2, 3, 3);

  { Pupilles }
  SetFillStyle(SolidFill, BLACK);
  FillEllipse(X - CUBE_SIZE DIV 6, Y - CUBE_SIZE DIV 1 - 2, 1, 1);
  FillEllipse(X + CUBE_SIZE DIV 6, Y - CUBE_SIZE DIV 1 - 2, 1, 1);

  { Museau }
  SetColor(BLACK);
  Arc(X,Y - CUBE_SIZE DIV 2, 180, 360, CUBE_SIZE DIV 4);
END;

Procedure DrawPyramid;
Var
 Row,Col:Integer;
Begin
 For Row:=PYRAMID_LEVELS-1 downto 0 do Begin
  For Col := 0 TO Row do Begin
   With Pyramid[Row, Col] do Begin
    DrawCube(Position.X, Position.Y, Completed);
   End;
  End;
 End;
End;

Procedure DrawSnake(Const Snake: TSnake);
Begin
  If Snake.Active Then Begin
    SetColor(MAGENTA);
    SetFillStyle(SolidFill, MAGENTA);
    FillEllipse(Snake.Position.X, Snake.Position.Y - CUBE_SIZE DIV 2,
                CUBE_SIZE DIV 3, CUBE_SIZE DIV 4);
    { Dessiner la langue }
    SetColor(RED);
    Line(Snake.Position.X, Snake.Position.Y - CUBE_SIZE DIV 2,
         Snake.Position.X + Snake.Direction * CUBE_SIZE DIV 2,
         Snake.Position.Y - CUBE_SIZE DIV 2);
  End;
End;

{ Fonction pour v�rifier si un mouvement est valide }
Function IsValidMove(Row,Col:Integer):Boolean;Begin
 IsValidMove:=(Row>=0)and(Row<PYRAMID_LEVELS)and(Col>=0)and(Col<=Row);
End;

{ Proc�dure pour faire sauter QBert - Mise � jour pour l'appel � CalculatePosition }
Procedure JumpQBert(TargetRow, TargetCol: Integer);
Begin
  { Correction de la condition - Not() �tait mal utilis� }
  If (NOT Q_Bert.IsJumping) AND IsValidMove(TargetRow, TargetCol) Then Begin
    Q_Bert.IsJumping := True;
    Q_Bert.StartPos := Q_Bert.Position;
    CalculatePosition(TargetRow, TargetCol, Q_Bert.TargetPos);
    Q_Bert.JumpProgress := 0;

    { Marque la case pr�c�dente comme compl�t�e }
    If Not(Pyramid[Q_Bert.Row, Q_Bert.Col].Completed) Then Begin
      Pyramid[Q_Bert.Row, Q_Bert.Col].Completed := True;
      Inc(CompletedCubes);
      Inc(Score, 25);
    End;

    Q_Bert.Row := TargetRow;
    Q_Bert.Col := TargetCol;
  End;
End;

{ Proc�dure pour mettre � jour l'animation du saut }
Procedure UpdateJump(Var Character:TCharacter;Var ElapsedTime:Real);Begin
 If Character.IsJumping Then Begin
  Character.JumpProgress := Character.JumpProgress + ElapsedTime * 4;
  If Character.JumpProgress >= 1 Then Begin
   Character.Position := Character.TargetPos;
   Character.IsJumping := FALSE;
  End
   Else
  Begin
   { Calcul de la position interm�diaire avec une courbe de saut }
   Character.Position.X:=Character.StartPos.X +
                         Round((Character.TargetPos.X - Character.StartPos.X) * Character.JumpProgress);
   Character.Position.Y:=Character.StartPos.Y +
                         Round((Character.TargetPos.Y - Character.StartPos.Y) * Character.JumpProgress);
   { Ajout d'un effet de saut (courbe parabolique) }
   Character.Position.Y := Character.Position.Y - Round(Sin(Character.JumpProgress * PI) * CUBE_SIZE);
  End;
 End;
End;

Procedure UpdateSnakes(ElapsedTime: Real);
Var
 I: Integer;
Begin
 SnakeSpawnTimer := SnakeSpawnTimer + ElapsedTime;

 { Créer un nouveau serpent toutes les 5 secondes }
 If SnakeSpawnTimer >= 5.0 Then Begin
  SpawnSnake;
  SnakeSpawnTimer := 0;
 End;

 For I := 1 to MAX_SNAKES do Begin
  If Snakes[I].Active Then Begin
    { Déplacer le serpent }
   Snakes[I].Col := Snakes[I].Col + Round(Snakes[I].Direction * Snakes[I].Speed * ElapsedTime);

    { Vérifier si le serpent est sorti de la pyramide }
   If (Snakes[I].Col < 0) or (Snakes[I].Col > Snakes[I].Row) Then
    Snakes[I].Active := False
   Else
    CalculatePosition(Snakes[I].Row, Snakes[I].Col, Snakes[I].Position);

    { Vérifier la collision avec Q*bert }
   If Abs(Snakes[I].Position.X - Q_Bert.Position.X) < CUBE_SIZE div 2 Then
    If Abs(Snakes[I].Position.Y - Q_Bert.Position.Y) < CUBE_SIZE div 2 Then Begin
     Dec(Lives);
     InitializeQBert;
     InitializeSnakes;
     Break;
   End;
  End;
 End;
End;

{ Proc�dure pour afficher l'interface utilisateur }
Procedure DrawUI;
Var
 ScoreText,LivesText:String;
Begin
  { Fond pour le texte }
 SetFillStyle(SolidFill,BLACK);
 Bar(0,0,GetMaxX,30);

  { Affichage du score }
 Str(Score,ScoreText);
 ScoreText:='Pointage: '+ScoreText;
 SetColor(TEXT_COLOR);
 OutTextXY(10,10,ScoreText);

  { Affichage des vies }
 Str(Lives,LivesText);
 LivesText:='Vies: '+LivesText;
 OutTextXY(GetMaxX-TextWidth(LivesText)-10,10,LivesText);

  { Affichage des instructions }
 If Not(GameRunning)Then Begin
 SetColor(LIGHTGREEN);
 OutTextXY(GetMaxX DIV 2 - TextWidth('Appuyez sur ESPACE pour commencer') DIV 2,
           GetMaxY - 40, 'Appuyez sur ESPACE pour commencer');
 OutTextXY(GetMaxX DIV 2 - TextWidth('W: Haut-Gauche, E: Haut-Droite, S: Bas-Gauche, D: Bas-Droite') DIV 2,
           GetMaxY - 20, 'W: Haut-Gauche, E: Haut-Droite, S: Bas-Gauche, D: Bas-Droite');
 End;
 If(GameOver)Then Begin
  SetFillStyle(SolidFill,BLACK);
  Bar(GetMaxX DIV 2 - 150, GetMaxY DIV 2 - 50, GetMaxX DIV 2 + 150, GetMaxY DIV 2 + 50);
  SetColor(RED);
    OutTextXY(GetMaxX DIV 2 - TextWidth('GAME OVER') DIV 2, GetMaxY DIV 2 - 20, 'GAME OVER');
    SetColor(YELLOW);
    OutTextXY(GetMaxX DIV 2 - TextWidth('Appuyez sur ESPACE pour rejouer') DIV 2,
              GetMaxY DIV 2 + 10, 'Appuyez sur ESPACE pour rejouer');
  End;

  { �cran de victoire }
  If CompletedCubes = TotalCubes Then Begin
   SetFillStyle(SolidFill,BLACK);
   Bar(GetMaxX DIV 2 - 150, GetMaxY DIV 2 - 50, GetMaxX DIV 2 + 150, GetMaxY DIV 2 + 50);
   SetColor(LIGHTGREEN);
   OutTextXY(GetMaxX DIV 2 - TextWidth('NIVEAU TERMIN�!') DIV 2, GetMaxY DIV 2 - 20, 'NIVEAU TERMIN�!');
   SetColor(YELLOW);
   OutTextXY(GetMaxX DIV 2 - TextWidth('Appuyez sur ESPACE pour continuer') DIV 2,
             GetMaxY DIV 2 + 10, 'Appuyez sur ESPACE pour continuer');
  End;
End;

BEGIN
 InitScr;
 SetTextStyle(DefaultFont,HorizDir,1);
 SetTextJustify(LeftText,TopText);
 CurrentTime:=GetCurrentTime;
 InitializePyramid;
 InitializeQBert;
 InitializeSnakes; { Ajouter cette ligne }
 Score:=0;
 Lives:=3;
 GameRunning:=False; { Chang� � False pour que le jeu d�marre seulement apr�s appui sur ESPACE }
 GameOver:=False;
 While(Lives>0)and(NOT GameOver)do Begin
   { Calcul du temps �coul� pour les animations }
  LastTime := CurrentTime;
  CurrentTime:=GetCurrentTime; { Utilisation de la fonction GetCurrentTime }
  ElapsedTime:=(CurrentTime-LastTime)/18.2; { Converti en secondes }

  { Effacement de l'�cran - D�comment� pour rafra�chir l'affichage correctement }
  ClearDevice;

  If(KeyPressed) Then Begin
    Key := ReadKey;
    If Key = #27 Then Begin
      GameRunning := False;
      Break;
    End
    Else If Key = ' ' Then Begin
      GameRunning := True; { L'espace active le jeu }
    End
    Else If Not Q_Bert.IsJumping AND GameRunning Then Begin
      Case Key of
        's', 'S': JumpQBert(Q_Bert.Row+1, Q_Bert.Col);   { Bas-Gauche }
        'w', 'W': JumpQBert(Q_Bert.Row-1, Q_Bert.Col-1); { Haut-Gauche }
        'e', 'E': JumpQBert(Q_Bert.Row-1, Q_Bert.Col);   { Haut-Droite }
        'd', 'D': JumpQBert(Q_Bert.Row+1, Q_Bert.Col+1); { Bas-Droite }
      End;
    End;
  End;
  If GameRunning Then Begin
   UpdateJump(Q_Bert,ElapsedTime);
   UpdateSnakes(ElapsedTime); { Ajouter cette ligne }
   If CompletedCubes=TotalCubes THEN Begin
    Inc(Score, 100);
    Delay(1000);
    InitializePyramid;
    InitializeQBert;
   End;
  End;
  DrawPyramid;

  { Dessiner les serpents avant Q*bert pour qu'il apparaisse au-dessus }
  For I := 1 to MAX_SNAKES do
    If Snakes[I].Active Then DrawSnake(Snakes[I]);

  DrawQBert(Q_Bert.Position.X, Q_Bert.Position.Y);
  DrawUI; { Cette ligne affichera maintenant les instructions au d�marrage }
  Delay(20);
 End;
 CloseGraph;
END.
