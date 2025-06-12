{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Checkers;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  BOARD_SIZE = 8;
  SQUARE_SIZE = 50;
  PIECE_RADIUS = 20;
  MAX_MOVES = 50;
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;    { Ajout de cette constante }

Type
  TPieceType = (ptEmpty, ptWhite, ptBlack, ptWhiteKing, ptBlackKing);
  TPlayer = (plHuman, plComputer);

  TMove = Record
    FromX, FromY,
    ToX, ToY: Integer;
    Piece: TPieceType;
  End;

  TBoard = Array[0..7, 0..7] of TPieceType;

Var
  Board: TBoard;
  CurrentPlayer: TPlayer;
  MoveHistory: Array[1..MAX_MOVES] of TMove;
  MoveCount: Integer;
  CursorX, CursorY: Integer;
  CursorVisible: Boolean;
  CursorTimer: Integer;
  SelectedX, SelectedY: Integer;
  HasSelection: Boolean;
  FirstMove: TPlayer;
  { Ajouter aux variables globales après CursorVisible }
  DestCursorX, DestCursorY: Integer;
  DestCursorVisible: Boolean;
  DestCursorTimer: Integer;

Function IntToStr(Value:Integer):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Procedure InitScreen;
Var
 Driver,Mode:Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
End;

Procedure InitBoard;
Var
 I,J:Integer;
Begin
 FillChar(Board,SizeOf(Board),Ord(ptEmpty));
 For J:=0 to 2 do
  For I:=0 to 7 do
   If(I+J)Mod 2=1 Then Board[I,J]:=ptBlack;
 For J:=5 to 7 do
  For I:=0 to 7 do
   If(I+J)Mod 2=1 Then Board[I,J]:=ptWhite;
End;

{ Déplacer cette fonction avant DrawBoard }
Function CanCapture(FromX, FromY: Integer; Var ToX, ToY: Integer): Boolean;
Begin
  CanCapture := False;
  { Vérifier capture en haut à gauche }
  If (FromX > 1) and (FromY > 1) Then
    If (Board[FromX-1,FromY-1] in [ptBlack,ptBlackKing]) and
       (Board[FromX-2,FromY-2] = ptEmpty) Then Begin
      ToX := FromX-2;
      ToY := FromY-2;
      CanCapture := True;
      Exit;
    End;
  { Vérifier capture en haut à droite }
  If (FromX < 6) and (FromY > 1) Then
    If (Board[FromX+1,FromY-1] in [ptBlack,ptBlackKing]) and
       (Board[FromX+2,FromY-2] = ptEmpty) Then Begin
      ToX := FromX+2;
      ToY := FromY-2;
      CanCapture := True;
      Exit;
    End;
End;

Procedure DrawBoard;
Var
  I, J: Integer;
  X, Y: Integer;
  CaptureX, CaptureY: Integer;
Begin
  { Dessiner l'échiquier }
  For I := 0 to 7 do
    For J := 0 to 7 do Begin
      X := I * SQUARE_SIZE + 5;  { 50 - 45 = 5 }
      Y := J * SQUARE_SIZE + 50;
      If (I + J) Mod 2 = 0 Then SetFillStyle(SolidFill, LightGray)
                           Else SetFillStyle(SolidFill, DarkGray);
      Bar(X, Y, X + SQUARE_SIZE, Y + SQUARE_SIZE);
    End;

  { Dessiner les pièces avec le nouveau décalage }
  For I := 0 to 7 do
    For J := 0 to 7 do Begin
      X := I * SQUARE_SIZE + 5 + SQUARE_SIZE div 2;  { Ajusté pour les pièces }
      Y := J * SQUARE_SIZE + 50 + SQUARE_SIZE div 2;
      Case Board[I,J] of
        ptWhite, ptWhiteKing: Begin
          SetFillStyle(SolidFill, White);
          FillEllipse(X, Y, PIECE_RADIUS, PIECE_RADIUS);
          If Board[I,J] = ptWhiteKing Then Begin
            SetColor(Yellow);
            Circle(X, Y, 5);
          End;
        End;
        ptBlack, ptBlackKing: Begin
          SetFillStyle(SolidFill, Red);
          FillEllipse(X, Y, PIECE_RADIUS, PIECE_RADIUS);
          If Board[I,J] = ptBlackKing Then Begin
            SetColor(Yellow);
            Circle(X, Y, 5);
          End;
        End;
      End;
    End;

  { Dessiner le curseur clignotant }
  If CursorVisible and Not HasSelection Then Begin
    SetColor(Yellow);
    Rectangle(CursorX * SQUARE_SIZE + 3, CursorY * SQUARE_SIZE + 48,
             CursorX * SQUARE_SIZE + SQUARE_SIZE + 7,
             CursorY * SQUARE_SIZE + SQUARE_SIZE + 52);
  End;

  { Dessiner les cases possibles en magenta }
  If HasSelection Then Begin
    SetColor(Magenta);
    { Vérifier les captures possibles }
    If CanCapture(SelectedX, SelectedY, CaptureX, CaptureY) Then Begin
      Rectangle(CaptureX * SQUARE_SIZE + 3, CaptureY * SQUARE_SIZE + 48,
               CaptureX * SQUARE_SIZE + SQUARE_SIZE + 7,
               CaptureY * SQUARE_SIZE + SQUARE_SIZE + 52);
    End Else Begin
      { Mouvements normaux en diagonale }
      If (SelectedY > 0) Then Begin
        If (SelectedX > 0) Then Begin
          If Board[SelectedX-1,SelectedY-1] = ptEmpty Then
            Rectangle((SelectedX-1) * SQUARE_SIZE + 3, (SelectedY-1) * SQUARE_SIZE + 48,
                     (SelectedX-1) * SQUARE_SIZE + SQUARE_SIZE + 7,
                     (SelectedY-1) * SQUARE_SIZE + SQUARE_SIZE + 52);
        End;
        If (SelectedX < 7) Then Begin
          If Board[SelectedX+1,SelectedY-1] = ptEmpty Then
            Rectangle((SelectedX+1) * SQUARE_SIZE + 3, (SelectedY-1) * SQUARE_SIZE + 48,
                     (SelectedX+1) * SQUARE_SIZE + SQUARE_SIZE + 7,
                     (SelectedY-1) * SQUARE_SIZE + SQUARE_SIZE + 52);
        End;
      End;
    End;
  End;

  { Dessiner le curseur de destination et l'aperçu }
  If HasSelection and DestCursorVisible Then Begin
    { Curseur bleu pour la navigation }
    SetColor(LightBlue);
    Rectangle(DestCursorX * SQUARE_SIZE + 3, DestCursorY * SQUARE_SIZE + 48,
             DestCursorX * SQUARE_SIZE + SQUARE_SIZE + 7,
             DestCursorY * SQUARE_SIZE + SQUARE_SIZE + 52);
             
    { Aperçu en jaune de la destination - Cercle pointillé }
    SetColor(Yellow);
    SetLineStyle(DottedLn, 0, NormWidth);
    X := DestCursorX * SQUARE_SIZE + 5 + SQUARE_SIZE div 2;  { Ajusté }
    Y := DestCursorY * SQUARE_SIZE + 50 + SQUARE_SIZE div 2;
    Circle(X, Y, PIECE_RADIUS);
    SetLineStyle(SolidLn, 0, NormWidth);
  End;

  { Dessiner la sélection en vert }
  If HasSelection Then Begin
    SetColor(Green);
    Rectangle(SelectedX * SQUARE_SIZE + 3, SelectedY * SQUARE_SIZE + 48,
             SelectedX * SQUARE_SIZE + SQUARE_SIZE + 7,
             SelectedY * SQUARE_SIZE + SQUARE_SIZE + 52);
  End;

  { Ajouter la légende des couleurs }
  SetColor(White);
  OutTextXY(500, GetMaxY-60, 'Pièces:');

  SetColor(White);
  SetFillStyle(SolidFill, White);
  FillEllipse(520, GetMaxY-30, PIECE_RADIUS, PIECE_RADIUS);
  OutTextXY(540, GetMaxY-35, '- Humain');

  SetColor(Red);
  SetFillStyle(SolidFill, Red);
  FillEllipse(520, GetMaxY-10, PIECE_RADIUS, PIECE_RADIUS);
  OutTextXY(540, GetMaxY-15, '- Ordinateur');
End;

Procedure DrawMoveHistory;
Var
 I:Integer;
Begin
 SetColor(White);
 OutTextXY(405,50,'Historique des coups:');  { 400 + 5 }
 For I:=1 to MoveCount do Begin
  OutTextXY(405,70+I*20,IntToStr(I)+'. '+    { 400 + 5 }
           Chr(Ord('A')+MoveHistory[I].FromX)+
           IntToStr(MoveHistory[I].FromY+1)+' -> '+  { Correction: Y+1 au lieu de 8-Y }
           Chr(Ord('A')+MoveHistory[I].ToX)+
           IntToStr(MoveHistory[I].ToY+1));     { Correction: Y+1 au lieu de 8-Y }
 End;
End;

Function IsValidMove(FromX,FromY,ToX,ToY:Integer):Boolean;
Var
  CaptureToX, CaptureToY: Integer;
Begin
  IsValidMove := False;
  
  { Vérifier d'abord s'il y a une capture possible }
  If CanCapture(FromX, FromY, CaptureToX, CaptureToY) Then Begin
    IsValidMove := (ToX = CaptureToX) and (ToY = CaptureToY);
    Exit;
  End;
  
  { Si pas de capture, vérifier le mouvement normal }
  If Board[ToX,ToY] <> ptEmpty Then Exit;
  
  Case Board[FromX,FromY] of
    ptWhite: Begin
      IsValidMove := (ToY = FromY-1) and
                    ((ToX = FromX-1) or (ToX = FromX+1));
    End;
    ptWhiteKing: Begin
      IsValidMove := (Abs(ToX - FromX) = 1) and
                    (Abs(ToY - FromY) = 1);
    End;
  End;
End;

Procedure MakeMove(FromX,FromY,ToX,ToY:Integer);
Var
  MovingPiece: TPieceType;
Begin
  MovingPiece := Board[FromX,FromY];
  
  { Capturer la pièce si c'est un saut }
  If Abs(ToX - FromX) = 2 Then Begin
    Board[(FromX + ToX) div 2, (FromY + ToY) div 2] := ptEmpty;
  End;
  
  { Effectuer le mouvement }
  Board[ToX,ToY] := MovingPiece;
  Board[FromX,FromY] := ptEmpty;
  
  { Si la pièce atteint la dernière rangée, la transformer en dame }
  If (MovingPiece = ptWhite) and (ToY = 0) Then
    Board[ToX,ToY] := ptWhiteKing;
  
  { Enregistrer le mouvement dans l'historique }
  Inc(MoveCount);
  MoveHistory[MoveCount].FromX := FromX;
  MoveHistory[MoveCount].FromY := FromY;
  MoveHistory[MoveCount].ToX := ToX;
  MoveHistory[MoveCount].ToY := ToY;
  MoveHistory[MoveCount].Piece := MovingPiece;
End;

Function ComputerMove:Boolean;
Var 
  I, J: Integer;
  FoundMove: Boolean;
Begin
  FoundMove := False;
  Delay(500); { Pause pour simuler la réflexion }

  { Chercher une pièce noire qui peut bouger }
  For I := 0 to 7 do Begin
    For J := 7 downto 0 do Begin
      If Board[I,J] = ptBlack Then Begin
        { Essayer de déplacer en diagonale vers le bas }
        If (J < 7) Then Begin
          { Essai à gauche }
          If (I > 0) and (Board[I-1,J+1] = ptEmpty) Then Begin
            MakeMove(I, J, I-1, J+1);
            FoundMove := True;
            Break;
          End;
          { Essai à droite }
          If (I < 7) and (Board[I+1,J+1] = ptEmpty) Then Begin
            MakeMove(I, J, I+1, J+1);
            FoundMove := True;
            Break;
          End;
        End;
      End;
    End;
    If FoundMove Then Break;
  End;

  ComputerMove := FoundMove;
End;

BEGIN
  InitScreen;
  Randomize;

  { Menu initial }
  SetTextStyle(DefaultFont,HorizDir,2);
  OutTextXY(200,200,'Qui commence ?');
  OutTextXY(200,250,'H - Humain');
  OutTextXY(200,280,'O - Ordinateur');

  Repeat
    Case UpCase(ReadKey) of
      'H':Begin
        FirstMove:=plHuman;
        CurrentPlayer:=plHuman;
        Break;
      End;
      'O':Begin
        FirstMove:=plComputer;
        CurrentPlayer:=plComputer;
        Break;
      End;
    End;
  Until False;

  InitBoard;
  CursorX := 0;
  CursorY := 0;
  CursorVisible := True;
  CursorTimer := 0;
  DestCursorX := 0;
  DestCursorY := 0;
  DestCursorVisible := True;
  DestCursorTimer := 5; { Décalé pour alterner avec le premier curseur }
  HasSelection := False;
  MoveCount := 0;

  Repeat
    ClearDevice;
    DrawBoard;
    DrawMoveHistory;

    If CurrentPlayer = plHuman Then Begin
      If KeyPressed Then
        Case ReadKey of
          #0: Case ReadKey of
            #72: Begin { Haut }
              If Not HasSelection Then Begin
                If CursorY > 0 Then Dec(CursorY);
              End Else Begin
                If DestCursorY > 0 Then Dec(DestCursorY);
              End;
            End;
            #80: Begin { Bas }
              If Not HasSelection Then Begin
                If CursorY < 7 Then Inc(CursorY);
              End Else Begin
                If DestCursorY < 7 Then Inc(DestCursorY);
              End;
            End;
            #75: Begin { Gauche }
              If Not HasSelection Then Begin
                If CursorX > 0 Then Dec(CursorX);
              End Else Begin
                If DestCursorX > 0 Then Dec(DestCursorX);
              End;
            End;
            #77: Begin { Droite }
              If Not HasSelection Then Begin
                If CursorX < 7 Then Inc(CursorX);
              End Else Begin
                If DestCursorX < 7 Then Inc(DestCursorX);
              End;
            End;
          End;
          #13: Begin { Enter }
            If Not HasSelection Then Begin
              If Board[CursorX,CursorY] in [ptWhite,ptWhiteKing] Then Begin
                HasSelection := True;
                SelectedX := CursorX;
                SelectedY := CursorY;
                DestCursorX := CursorX;
                DestCursorY := CursorY;
              End;
            End Else Begin
              If IsValidMove(SelectedX, SelectedY, DestCursorX, DestCursorY) Then Begin
                MakeMove(SelectedX, SelectedY, DestCursorX, DestCursorY);
                HasSelection := False;
                CurrentPlayer := plComputer;
              End;
            End;
          End;
          #27: Break;
        End;
    End
    Else Begin { Tour de l'ordinateur }
      If ComputerMove Then CurrentPlayer:=plHuman;
    End;

    { Mise à jour des deux curseurs }
    Inc(CursorTimer);
    Inc(DestCursorTimer);
    If CursorTimer > 5 Then Begin
      CursorTimer := 0;
      CursorVisible := Not CursorVisible;
    End;
    If DestCursorTimer > 5 Then Begin
      DestCursorTimer := 0;
      DestCursorVisible := Not DestCursorVisible;
    End;

    Delay(50);
  Until False;

  CloseGraph;
END.
