{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu d'echecs chinois Xiangqi - Strategie traditionnelle
}

Program Xiangqi;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 BOARD_WIDTH = 9;
 BOARD_HEIGHT = 10;
 CELL_SIZE = 35;
 BOARD_X = 50;
 BOARD_Y = 40;
 PIECE_RADIUS = 12;

Type
 TPieceType = (ptEmpty, ptGeneral, ptAdvisor, ptElephant, ptHorse, ptChariot, ptCannon, ptSoldier);
 TPlayer = (plRed, plBlack);
 TGameState = (gsPlaying, gsRedWins, gsBlackWins, gsDraw, gsQuit);

 TPosition=Record
  x,y:Integer;
 End;

 TPiece=Record
  pieceType:TPieceType;
  player:TPlayer;
  hasMoved:Boolean;
 End;

 TBoard=Array[0..BOARD_HEIGHT-1, 0..BOARD_WIDTH-1] of TPiece;

 TMove=Record
  fromX,fromY:Integer;
  toX,toY:Integer;
  score:Integer;
 End;

 TGame=Record
  board:TBoard;
  currentPlayer:TPlayer;
  gameState:TGameState;
  selectedX,selectedY:Integer;
  needRedraw:Boolean;
  moveCount:Integer;
  gameMode:Integer; { 1=vs Computer, 2=vs Human }
  lastMove:TMove;
  isMoving:Boolean;
  moveFromX,moveFromY:Integer;
 End;

Var
 Game:TGame;

{ D‚clarations forward }
Procedure InitializeGame; Forward;
Function IsValidMove(fromX,fromY,toX,toY:Integer):Boolean; Forward;

Function GetPlayerName(player:TPlayer):String;Begin
 Case player of
  plRed: GetPlayerName := 'Rouge';
  plBlack: GetPlayerName := 'Noir';
 End;
End;

Function GetPieceName(pieceType:TPieceType):String;Begin
 Case pieceType of
  ptGeneral: GetPieceName:='G';
  ptAdvisor: GetPieceName:='A';
  ptElephant: GetPieceName:='E';
  ptHorse: GetPieceName:='H';
  ptChariot: GetPieceName:='R';
  ptCannon: GetPieceName:='C';
  ptSoldier: GetPieceName:='S';
  else GetPieceName:=' ';
 End;
End;

Function OpponentPlayer(player:TPlayer):TPlayer;Begin
 If player=plRed Then OpponentPlayer:=plBlack
                 Else OpponentPlayer:=plRed;
End;

Procedure ClearBoard;
Var
 row,col:Integer;
Begin
 For row:=0 to BOARD_HEIGHT-1 do For col:=0 to BOARD_WIDTH-1 do Begin
  Game.board[row,col].pieceType:=ptEmpty;
  Game.board[row,col].player:=plRed;
  Game.board[row,col].hasMoved:=False;
 End;
End;

Procedure SetupInitialPosition;Begin
 ClearBoard;
  { Pieces noires (en haut) }
 Game.board[0, 0].pieceType := ptChariot; Game.board[0, 0].player := plBlack;
 Game.board[0, 1].pieceType := ptHorse; Game.board[0, 1].player := plBlack;
 Game.board[0, 2].pieceType := ptElephant; Game.board[0, 2].player := plBlack;
 Game.board[0, 3].pieceType := ptAdvisor; Game.board[0, 3].player := plBlack;
 Game.board[0, 4].pieceType := ptGeneral; Game.board[0, 4].player := plBlack;
 Game.board[0, 5].pieceType := ptAdvisor; Game.board[0, 5].player := plBlack;
 Game.board[0, 6].pieceType := ptElephant; Game.board[0, 6].player := plBlack;
 Game.board[0, 7].pieceType := ptHorse; Game.board[0, 7].player := plBlack;
 Game.board[0, 8].pieceType := ptChariot; Game.board[0, 8].player := plBlack;
  { Canons noirs }
 Game.board[2, 1].pieceType := ptCannon; Game.board[2, 1].player := plBlack;
 Game.board[2, 7].pieceType := ptCannon; Game.board[2, 7].player := plBlack;
  { Soldats noirs }
 Game.board[3, 0].pieceType := ptSoldier; Game.board[3, 0].player := plBlack;
 Game.board[3, 2].pieceType := ptSoldier; Game.board[3, 2].player := plBlack;
 Game.board[3, 4].pieceType := ptSoldier; Game.board[3, 4].player := plBlack;
 Game.board[3, 6].pieceType := ptSoldier; Game.board[3, 6].player := plBlack;
 Game.board[3, 8].pieceType := ptSoldier; Game.board[3, 8].player := plBlack;
  { Pieces rouges (en bas) }
 Game.board[9, 0].pieceType := ptChariot; Game.board[9, 0].player := plRed;
 Game.board[9, 1].pieceType := ptHorse; Game.board[9, 1].player := plRed;
 Game.board[9, 2].pieceType := ptElephant; Game.board[9, 2].player := plRed;
 Game.board[9, 3].pieceType := ptAdvisor; Game.board[9, 3].player := plRed;
 Game.board[9, 4].pieceType := ptGeneral; Game.board[9, 4].player := plRed;
 Game.board[9, 5].pieceType := ptAdvisor; Game.board[9, 5].player := plRed;
 Game.board[9, 6].pieceType := ptElephant; Game.board[9, 6].player := plRed;
 Game.board[9, 7].pieceType := ptHorse; Game.board[9, 7].player := plRed;
 Game.board[9, 8].pieceType := ptChariot; Game.board[9, 8].player := plRed;
  { Canons rouges }
 Game.board[7, 1].pieceType := ptCannon; Game.board[7, 1].player := plRed;
 Game.board[7, 7].pieceType := ptCannon; Game.board[7, 7].player := plRed;
  { Soldats rouges }
 Game.board[6, 0].pieceType := ptSoldier; Game.board[6, 0].player := plRed;
 Game.board[6, 2].pieceType := ptSoldier; Game.board[6, 2].player := plRed;
 Game.board[6, 4].pieceType := ptSoldier; Game.board[6, 4].player := plRed;
 Game.board[6, 6].pieceType := ptSoldier; Game.board[6, 6].player := plRed;
 Game.board[6, 8].pieceType := ptSoldier; Game.board[6, 8].player := plRed;
 Game.moveCount := 0;
 Game.lastMove.fromX := -1;
 Game.lastMove.fromY := -1;
 Game.lastMove.toX := -1;
 Game.lastMove.toY := -1;
End;

Function IsValidPosition(x,y:Integer):Boolean;Begin
 IsValidPosition:=(x>=0)and(x<BOARD_WIDTH)and
                  (y>=0)and(y<BOARD_HEIGHT);
End;

Function IsInPalace(x,y:Integer;player:TPlayer):Boolean;Begin
 If player=plRed Then IsInPalace:=(x >= 3) and (x <= 5) and (y >= 7) and (y <= 9)
                 Else IsInPalace:=(x >= 3) and (x <= 5) and (y >= 0) and (y <= 2);
End;

Function IsOnCorrectSide(x,y:Integer;player:TPlayer):Boolean;Begin
 If player = plRed Then IsOnCorrectSide:=y>=5
                   Else IsOnCorrectSide:=y<=4;
End;

Function HasPieceBetween(fromX,fromY,toX,toY:Integer):Boolean;
Var
 x,y,dx,dy,steps,i:Integer;
Begin
 HasPieceBetween:=False;
 If(fromX=toX)and(fromY=toY)Then Exit;
 dx:=0;
 dy:=0;
 steps:=0;
 If fromX=toX Then Begin
  If toY>fromY Then dy:=1
               Else dy:=-1;
  steps:=Abs(toY-fromY) - 1;
 End
  Else
 If fromY=toY Then Begin
  If toX>fromX Then dx:=1
               Else dx:=-1;
  steps:=Abs(toX - fromX)-1;
 End
  Else
 Exit; { Mouvement diagonal non supporte pour cette fonction }
 x:=fromX+dx;
 y:=fromY+dy;
 For i:=1 to steps do Begin
  If Game.board[y,x].pieceType<>ptEmpty Then Begin
   HasPieceBetween:=True;
   Exit;
  End;
  x:=x+dx;
  y:=y+dy;
 End;
End;

Function CountPiecesBetween(fromX,fromY,toX,toY:Integer):Integer;
Var
 x,y,dx,dy,steps,i,count:Integer;
Begin
 count:=0;
 If(fromX=toX)and(fromY=toY)Then Begin
  CountPiecesBetween := count;
  Exit;
 End;
 dx:=0;
 dy:=0;
 steps:=0;
 If fromX=toX Then Begin
  If toY > fromY Then dy := 1 else dy := -1;
  steps := Abs(toY - fromY) - 1;
 End
  Else
 If fromY=toY Then Begin
  If toX>fromX Then dx:=1
               Else dx:=-1;
  steps:=Abs(toX-fromX)-1;
 End
  Else
 Begin
  CountPiecesBetween:=count;
  Exit;
 End;
 x:=fromX+dx;
 y:=fromY+dy;
 For i:=1 to steps do Begin
  If Game.board[y, x].pieceType <> ptEmpty Then Inc(count);
  x:=x+dx;
  y:=y+dy;
 End;
 CountPiecesBetween:=count;
End;

Function IsValidGeneralMove(fromX,fromY,toX,toY:Integer;player:TPlayer):Boolean;Begin
 IsValidGeneralMove:=False;
  { Le general doit rester dans le palais }
 If not IsInPalace(toX, toY, player) Then Exit;
 { Mouvement d'une case orthogonalement }
 If (Abs(toX-fromX)=1)and(toY=fromY)Then IsValidGeneralMove:=True Else
 If (Abs(toY-fromY) = 1)and(toX=fromX)Then IsValidGeneralMove:=True;
End;

Function IsValidAdvisorMove(fromX,fromY,toX,toY:Integer;player:TPlayer):Boolean;Begin
 IsValidAdvisorMove := False;
  { L'advisor doit rester dans le palais }
 If Not IsInPalace(toX, toY,player)Then Exit;
 { Mouvement diagonal d'une case }
 If(Abs(toX-fromX)=1)and(Abs(toY-fromY)=1)Then IsValidAdvisorMove:=True;
End;

Function IsValidElephantMove(fromX,fromY,toX,toY:Integer;player:TPlayer):Boolean;
Var
 midX,midY:Integer;
Begin
 IsValidElephantMove:=False;
  { L'elephant ne peut pas traverser la riviere }
 If not IsOnCorrectSide(toX, toY, player)Then Exit;
  { Mouvement diagonal de deux cases }
 If(Abs(toX-fromX)=2)and(Abs(toY-fromY)=2)Then Begin
   { Verifier qu'il n'y a pas de piece qui bloque }
  midX := (fromX + toX) div 2;
  midY := (fromY + toY) div 2;
  If Game.board[midY,midX].pieceType=ptEmpty Then IsValidElephantMove:=True;
 End;
End;

Function IsValidHorseMove(fromX,fromY,toX,toY:Integer):Boolean;
Var
 dx,dy,blockX,blockY:Integer;
Begin
 IsValidHorseMove:=False;
 dx:=toX-fromX;
 dy:=toY-fromY;
 { Mouvement en L }
 If(Abs(dx)=2)and(Abs(dy)=1)Then Begin
   { Verifier le blocage horizontal }
  If dx>0 Then blockX := fromX + 1
          Else blockX:=fromX-1;
  blockY:=fromY;
  If Game.board[blockY,blockX].pieceType=ptEmpty Then
   IsValidHorseMove := True;
 End
  Else
 If(Abs(dx)=1)and(Abs(dy)=2)Then Begin
  { Verifier le blocage vertical }
  blockX:=fromX;
  If dy>0 Then blockY:=fromY+1
          Else blockY:=fromY-1;
  If Game.board[blockY,blockX].pieceType=ptEmpty Then
   IsValidHorseMove:=True;
 End;
End;

Function IsValidChariotMove(fromX,fromY,toX,toY:Integer):Boolean;Begin
 IsValidChariotMove:=False;
 { Mouvement orthogonal }
 If(fromX=toX)or(fromY=toY)Then Begin
  { Pas de piece entre les deux positions }
  If not HasPieceBetween(fromX,fromY,toX,toY)Then
   IsValidChariotMove:=True;
 End;
End;

Function IsValidCannonMove(fromX,fromY,toX,toY:Integer):Boolean;
Var
 piecesBetween:Integer;
 targetPiece:TPiece;
Begin
 IsValidCannonMove:=False;
  { Mouvement orthogonal }
 If(fromX=toX)or(fromY=toY)Then Begin
  targetPiece:=Game.board[toY,toX];
  piecesBetween:=CountPiecesBetween(fromX, fromY, toX, toY);
   { Pour capturer, il faut exactement une piece entre }
  If targetPiece.pieceType<>ptEmpty Then Begin
   If piecesBetween=1 Then IsValidCannonMove:=True;
  End
   Else
  Begin
   { Pour se deplacer, aucune piece entre }
   If piecesBetween=0 Then IsValidCannonMove:=True;
  End;
 End;
End;

Function IsValidSoldierMove(fromX,fromY,toX,toY:Integer;player:TPlayer):Boolean;
Var
 hasCrossedRiver:Boolean;
Begin
 IsValidSoldierMove:=False;
  { Verifier si le soldat a traverse la riviere }
 If player=plRed Then hasCrossedRiver:=fromY<=4
                 Else hasCrossedRiver:=fromY>=5;
  { Mouvement vers l'avant }
 If fromX=toX Then Begin
  If player=plRed Then Begin
   If(toY = fromY-1)Then IsValidSoldierMove:=True;
  End
   Else
  Begin
   If(toY=fromY+1)Then IsValidSoldierMove:=True;
  End;
 End
  { Mouvement lateral (seulement apres avoir traverse la riviere) }
  Else
 If hasCrossedRiver and(fromY=toY)and(Abs(toX-fromX)=1)Then
  IsValidSoldierMove:=True;
End;

Function IsValidMove(fromX,fromY,toX,toY:Integer):Boolean;
Var
 piece,targetPiece:TPiece;
Begin
 IsValidMove:=False;
  { Verifications de base }
 If not IsValidPosition(fromX,fromY)or not IsValidPosition(toX,toY)Then Exit;
 If(fromX=toX)and(fromY=toY)Then Exit;
 piece:=Game.board[fromY, fromX];
 targetPiece:=Game.board[toY,toX];
  { Il doit y avoir une piece a deplacer }
 If piece.pieceType=ptEmpty Then Exit;
  { La piece doit appartenir au joueur actuel }
 If piece.player<>Game.currentPlayer Then Exit;
 { Ne peut pas capturer ses propres pieces }
 If (targetPiece.pieceType<>ptEmpty)and(targetPiece.player=piece.player)Then Exit;
  { Verifier selon le type de piece }
 Case piece.pieceType of
  ptGeneral: IsValidMove:=IsValidGeneralMove(fromX, fromY, toX, toY, piece.player);
  ptAdvisor: IsValidMove:=IsValidAdvisorMove(fromX, fromY, toX, toY, piece.player);
  ptElephant: IsValidMove:=IsValidElephantMove(fromX, fromY, toX, toY, piece.player);
  ptHorse: IsValidMove:=IsValidHorseMove(fromX, fromY, toX, toY);
  ptChariot: IsValidMove:=IsValidChariotMove(fromX, fromY, toX, toY);
  ptCannon: IsValidMove:=IsValidCannonMove(fromX, fromY, toX, toY);
  ptSoldier: IsValidMove:=IsValidSoldierMove(fromX, fromY, toX, toY, piece.player);
 End;
End;

Function MakeMove(fromX,fromY,toX,toY:Integer):Boolean;Begin
 MakeMove:=False;
 If IsValidMove(fromX,fromY,toX,toY)Then Begin
  { Deplacer la piece }
  Game.board[toY,toX]:=Game.board[fromY,fromX];
  Game.board[fromY,fromX].pieceType:=ptEmpty;
  Game.board[toY,toX].hasMoved:=True;
  { Enregistrer le mouvement }
  Game.lastMove.fromX:=fromX;
  Game.lastMove.fromY:=fromY;
  Game.lastMove.toX:=toX;
  Game.lastMove.toY:=toY;
  Inc(Game.moveCount);
  MakeMove:=True;
 End;
End;

Function IsInCheck(player:TPlayer):Boolean;
Var
 generalX,generalY:Integer;
 x,y:Integer;
 found:Boolean;
Begin
 IsInCheck:=False;
  { Trouver le general }
 found:=False;
 For y:=0 to BOARD_HEIGHT-1 do For x:=0 to BOARD_WIDTH-1 do
  If(Game.board[y, x].pieceType=ptGeneral)and
    (Game.board[y, x].player=player)Then Begin
   generalX := x;
   generalY := y;
   found := True;
   Break;
  End;
 If not found Then Begin
  IsInCheck:=True; { General capture = echec }
  Exit;
 End;
  { Verifier si une piece adverse peut attaquer le general }
 For y := 0 to BOARD_HEIGHT-1 do For x := 0 to BOARD_WIDTH-1 do
  If(Game.board[y, x].pieceType<>ptEmpty)and
    (Game.board[y, x].player<>player)Then Begin
    If IsValidMove(x, y, generalX, generalY) Then Begin
     IsInCheck:=True;
     Exit;
    End;
   End;
End;

Function HasValidMoves(player:TPlayer):Boolean;
Var
 fromX,fromY,toX,toY:Integer;
 tempPiece:TPiece;
 canMove:Boolean;
Begin
 HasValidMoves:=False;
 For fromY:=0 to BOARD_HEIGHT-1 do For fromX:=0 to BOARD_WIDTH-1 do
   If(Game.board[fromY, fromX].pieceType <> ptEmpty)and
     (Game.board[fromY, fromX].player = player)Then Begin
    For toY:=0 to BOARD_HEIGHT-1 do For toX:=0 to BOARD_WIDTH-1 do
      If IsValidMove(fromX, fromY, toX, toY)Then Begin
        { Simuler le mouvement }
       tempPiece := Game.board[toY, toX];
       Game.board[toY, toX] := Game.board[fromY, fromX];
       Game.board[fromY, fromX].pieceType := ptEmpty;
       { Verifier si le roi est toujours en echec }
       canMove := not IsInCheck(player);
        { Restaurer }
       Game.board[fromY, fromX] := Game.board[toY, toX];
       Game.board[toY, toX] := tempPiece;
       If canMove Then Begin
        HasValidMoves:=True;
        Exit;
       End;
      End;
   End;
End;

Procedure CheckGameEnd;Begin
 If IsInCheck(Game.currentPlayer)Then Begin
  If not HasValidMoves(Game.currentPlayer) Then Begin
    { Echec et mat }
   If Game.currentPlayer=plRed Then Game.gameState := gsBlackWins
                               Else Game.gameState := gsRedWins;
  End;
 End
  Else
 If Not HasValidMoves(Game.currentPlayer)Then Begin
   { Pat }
  Game.gameState := gsDraw;
 End;
End;

Function EvaluatePosition(player:TPlayer):Integer;
Var
 x,y,score:Integer;
 piece:TPiece;
 pieceValues:Array[TPieceType] of Integer;
Begin
 pieceValues[ptGeneral]:=1000;
 pieceValues[ptAdvisor]:=20;
 pieceValues[ptElephant]:=20;
 pieceValues[ptHorse]:=40;
 pieceValues[ptChariot]:=90;
 pieceValues[ptCannon]:=45;
 pieceValues[ptSoldier]:=10;
 score:=0;
 For y:=0 to BOARD_HEIGHT-1 do For x:=0 to BOARD_WIDTH-1 do Begin
  piece:=Game.board[y,x];
  If piece.pieceType<>ptEmpty Then Begin
   If piece.player = player Then score:=score+pieceValues[piece.pieceType]
                            Else score:=score-pieceValues[piece.pieceType];
  End;
 End;
  { Bonus pour la mobilite }
 If HasValidMoves(player)Then score:=score+10;
 If HasValidMoves(OpponentPlayer(player)) Then score:=score-10;
  { Malus pour l'echec }
 If IsInCheck(player)Then score:=score-50;
 If IsInCheck(OpponentPlayer(player))Then score:=score+50;
 EvaluatePosition := score;
End;

Procedure GetBestMove(player:TPlayer;Var bestMove:TMove);
Var
 fromX,fromY,toX,toY,score,bestScore:Integer;
 tempBoard:TBoard;
 y,x:Integer;
Begin
 bestMove.fromX:=-1;
 bestMove.fromY:=-1;
 bestMove.toX:=-1;
 bestMove.toY:=-1;
 bestMove.score:=-10000;
 bestScore:=-10000;
  { Sauvegarder le plateau }
 For y:=0 to BOARD_HEIGHT-1 do For x:=0 to BOARD_WIDTH-1 do
  tempBoard[y, x] := Game.board[y, x];
 For fromY := 0 to BOARD_HEIGHT-1 do For fromX := 0 to BOARD_WIDTH-1 do
  If(Game.board[fromY,fromX].pieceType<>ptEmpty)and
    (Game.board[fromY,fromX].player=player)Then Begin
   For toY := 0 to BOARD_HEIGHT-1 do For toX := 0 to BOARD_WIDTH-1 do
    If IsValidMove(fromX, fromY, toX, toY)Then Begin
      { Simuler le mouvement }
     Game.board[toY, toX] := Game.board[fromY, fromX];
     Game.board[fromY, fromX].pieceType := ptEmpty;
      { Verifier si c'est legal (pas d'auto-echec) }
     If not IsInCheck(player) Then Begin
      score:=EvaluatePosition(player);
      score:=score+Random(5) - 2; { Petite variation }
      If score>bestScore Then Begin
       bestScore := score;
       bestMove.fromX := fromX;
       bestMove.fromY := fromY;
       bestMove.toX := toX;
       bestMove.toY := toY;
       bestMove.score := score;
      End;
     End;
      { Restaurer le plateau }
     For y := 0 to BOARD_HEIGHT-1 do For x := 0 to BOARD_WIDTH-1 do
      Game.board[y, x] := tempBoard[y, x];
    End;
  End;
End;

Procedure ComputerMove;
Var
 move:TMove;
Begin
 If(Game.gameMode=1)and(Game.currentPlayer=plBlack)and(Game.gameState=gsPlaying)Then Begin
  Delay(1000); { Delai pour la reflexion }
  GetBestMove(plBlack, move);
  If(move.fromX>=0)and(move.fromY>=0)and(move.toX>=0)and(move.toY>=0)Then Begin
   MakeMove(move.fromX, move.fromY, move.toX, move.toY);
   Game.currentPlayer := plRed;
   Game.needRedraw := True;
   CheckGameEnd;
  End;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   #0:Begin
    key:=ReadKey;
    Case key of
     #72:Begin { Fleche haut }
      If Game.selectedY>0 Then Begin
       Dec(Game.selectedY);
       Game.needRedraw:=True;
      End;
     End;
     #80: Begin { Fleche bas }
      If Game.selectedY<BOARD_HEIGHT-1 Then Begin
       Inc(Game.selectedY);
       Game.needRedraw:=True;
      End;
     End;
     #75:Begin { Fleche gauche }
      If Game.selectedX>0 Then Begin
       Dec(Game.selectedX);
       Game.needRedraw := True;
      End;
     End;
     #77:Begin { Fleche droite }
      If Game.selectedX<BOARD_WIDTH-1 Then Begin
       Inc(Game.selectedX);
       Game.needRedraw:=True;
      End;
     End;
    End;
   End;
   #13,' ':Begin { Entree ou Espace }
    If (Game.gameState=gsPlaying)and
       ((Game.gameMode=2)or(Game.currentPlayer=plRed))Then Begin
     If not Game.isMoving Then Begin
       { Selectionner une piece }
      If(Game.board[Game.selectedY, Game.selectedX].pieceType <> ptEmpty) and
        (Game.board[Game.selectedY, Game.selectedX].player = Game.currentPlayer)Then Begin
       Game.isMoving := True;
       Game.moveFromX := Game.selectedX;
       Game.moveFromY := Game.selectedY;
       Game.needRedraw := True;
      End;
     End
     Else
     Begin
      { Effectuer le mouvement }
      If MakeMove(Game.moveFromX,Game.moveFromY,Game.selectedX,Game.selectedY)Then Begin
       Game.currentPlayer := OpponentPlayer(Game.currentPlayer);
       CheckGameEnd;
      End;
      Game.isMoving := False;
      Game.needRedraw := True;
     End;
    End;
   End;
   'c', 'C': Begin { Annuler selection }
    Game.isMoving:=False;
    Game.needRedraw:=True;
   End;
   'n','N':Begin { Nouvelle partie }
    InitializeGame;
   End;
   'm','M':Begin { Changer mode }
    If Game.gameMode=1 Then Game.gameMode:=2
                       Else Game.gameMode:=1;
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure DrawPiece(x,y:Integer;piece:TPiece;selected,moving,lastMove:Boolean);
Var
 centerX,centerY:Integer;
 pieceName:String;
Begin
 centerX:=BOARD_X + x*CELL_SIZE + CELL_SIZE div 2;
 centerY:=BOARD_Y + y*CELL_SIZE + CELL_SIZE div 2;
 If piece.pieceType = ptEmpty Then Exit;
  { Marquer le dernier coup }
 If lastMove Then Begin
  SetColor(14);
  Circle(centerX, centerY, PIECE_RADIUS + 3);
 End;
  { Marquer la selection }
 If selected Then Begin
  SetColor(15);
  SetLineStyle(0, 0, 2);
  Circle(centerX, centerY, PIECE_RADIUS + 2);
  SetLineStyle(0, 0, 1);
 End;
  { Marquer le mouvement en cours }
 If moving Then Begin
  SetColor(10);
  Circle(centerX, centerY, PIECE_RADIUS + 4);
 End;
  { Dessiner la piece }
 If piece.player=plRed Then Begin
  SetColor(12);
  SetFillStyle(1, 12);
 End
  Else
 Begin
  SetColor(0);
  SetFillStyle(1, 0);
 End;
 FillEllipse(centerX, centerY, PIECE_RADIUS, PIECE_RADIUS);
  { Contour }
 SetColor(15);
 Circle(centerX, centerY, PIECE_RADIUS);
  { Texte }
 pieceName := GetPieceName(piece.pieceType);
 If piece.player = plRed Then SetColor(15)
                         Else SetColor(15);
 SetTextStyle(0,0,1);
 OutTextXY(centerX-3,centerY-4,pieceName);
End;

Procedure DrawBoard;
Var
 x,y,posX,posY:Integer;
 piece:TPiece;
 isSelected,isMoving,isLastMoveFrom,isLastMoveTo:Boolean;
Begin
  { Fond du plateau }
 SetColor(6);
 SetFillStyle(1, 6);
 Bar(BOARD_X - 10, BOARD_Y - 10,
     BOARD_X + BOARD_WIDTH * CELL_SIZE + 10,
     BOARD_Y + BOARD_HEIGHT * CELL_SIZE + 10);
  { Lignes horizontales }
 SetColor(0);
 For y:=0 to BOARD_HEIGHT do Begin
  posY:=BOARD_Y + y * CELL_SIZE;
  Line(BOARD_X, posY, BOARD_X + (BOARD_WIDTH - 1) * CELL_SIZE, posY);
 End;
  { Lignes verticales }
 For x:=0 to BOARD_WIDTH-1 do Begin
  posX := BOARD_X + x * CELL_SIZE;
  { Ligne complete en haut et en bas }
  Line(posX, BOARD_Y, posX, BOARD_Y + 4 * CELL_SIZE);
  Line(posX, BOARD_Y + 5 * CELL_SIZE, posX, BOARD_Y + BOARD_HEIGHT * CELL_SIZE);
 End;
  { Riviere }
 SetColor(8);
 SetTextStyle(0, 0, 1);
 OutTextXY(BOARD_X + BOARD_WIDTH * CELL_SIZE div 2 - 30, BOARD_Y + 4 * CELL_SIZE + 8, 'RIVIERE');
  { Palais - lignes diagonales }
 SetColor(0);
  { Palais noir }
 Line(BOARD_X + 3 * CELL_SIZE, BOARD_Y, BOARD_X + 5 * CELL_SIZE, BOARD_Y + 2 * CELL_SIZE);
 Line(BOARD_X + 5 * CELL_SIZE, BOARD_Y, BOARD_X + 3 * CELL_SIZE, BOARD_Y + 2 * CELL_SIZE);
  { Palais rouge }
 Line(BOARD_X + 3 * CELL_SIZE, BOARD_Y + 7 * CELL_SIZE, BOARD_X + 5 * CELL_SIZE, BOARD_Y + 9 * CELL_SIZE);
 Line(BOARD_X + 5 * CELL_SIZE, BOARD_Y + 7 * CELL_SIZE, BOARD_X + 3 * CELL_SIZE, BOARD_Y + 9 * CELL_SIZE);
  { Dessiner les pieces }
 For y := 0 to BOARD_HEIGHT-1 do For x := 0 to BOARD_WIDTH-1 do Begin
  piece := Game.board[y, x];
  isSelected := (x = Game.selectedX) and (y = Game.selectedY);
  isMoving := Game.isMoving and (x = Game.moveFromX) and (y = Game.moveFromY);
  isLastMoveFrom := (x = Game.lastMove.fromX) and (y = Game.lastMove.fromY);
  isLastMoveTo := (x = Game.lastMove.toX) and (y = Game.lastMove.toY);
  DrawPiece(x, y, piece, isSelected, isMoving, isLastMoveFrom or isLastMoveTo);
 End;
  { Marquer les coups possibles }
 If Game.isMoving and(Game.gameState=gsPlaying)Then Begin
  SetColor(10);
  For y := 0 to BOARD_HEIGHT-1 do For x := 0 to BOARD_WIDTH-1 do
   If IsValidMove(Game.moveFromX, Game.moveFromY, x, y)Then Begin
    posX := BOARD_X + x * CELL_SIZE + CELL_SIZE div 2;
    posY := BOARD_Y + y * CELL_SIZE + CELL_SIZE div 2;
    Circle(posX, posY, 5);
   End;
 End;
End;

Procedure DrawGameInfo;
Var
 modeStr,moveStr:String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(400, 50, 'XIANGQI');
 OutTextXY(400, 65, '(Echecs Chinois)');
 If Game.gameMode=1 Then modeStr:='vs IA'
                    Else modeStr:='2 Joueurs';
 OutTextXY(400, 90, 'Mode: ' + modeStr);
 Str(Game.moveCount, moveStr);
 OutTextXY(400, 110, 'Coups: ' + moveStr);
 If Game.gameState=gsPlaying Then Begin
  SetColor(15);
  OutTextXY(400, 130, 'Tour: ' + GetPlayerName(Game.currentPlayer));
  If IsInCheck(Game.currentPlayer)Then Begin
   SetColor(12);
   OutTextXY(400, 150, 'ECHEC!');
  End;
 End
  Else
 OutTextXY(400, 130, 'Partie terminee');
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(400, 180, 'Regles:');
 OutTextXY(400, 200, '- Capturer le General');
 OutTextXY(400, 215, '- Pieces speciales:');
 OutTextXY(400, 230, '  G=General, A=Conseiller');
 OutTextXY(400, 245, '  E=Elephant, H=Cheval');
 OutTextXY(400, 260, '  R=Tour, C=Canon');
 OutTextXY(400, 275, '  S=Soldat');

 OutTextXY(400, 300, 'Commandes:');
 OutTextXY(400, 320, 'Fleches: Curseur');
 OutTextXY(400, 335, 'ENTREE: Selectionner');
 OutTextXY(400, 350, 'C: Annuler');
 OutTextXY(400, 365, 'N: Nouvelle partie');
 OutTextXY(400, 380, 'M: Changer mode');
 OutTextXY(400, 395, 'ESC: Quitter');
End;

Procedure DrawGameStatus;Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 Case Game.gameState of
  gsPlaying: Begin
   If Game.isMoving Then Begin
    SetColor(10);
    SetTextStyle(0, 0, 1);
    OutTextXY(50, 400, 'Piece selectionnee - Choisissez destination');
   End;
  End;
  gsRedWins:Begin
   OutTextXY(50, 400, 'ROUGE GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 420, 'N: Nouvelle partie');
  End;
  gsBlackWins:Begin
   OutTextXY(50, 400, 'NOIR GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 420, 'N: Nouvelle partie');
  End;
  gsDraw:Begin
   OutTextXY(50, 400, 'MATCH NUL!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(50, 420, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
   { Fond }
  SetColor(1);
  SetFillStyle(1, 1);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 3);
  OutTextXY(50, 10, 'XIANGQI - ECHECS CHINOIS');
  DrawBoard;
  DrawGameInfo;
  DrawInstructions;
  DrawGameStatus;
  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;Begin
 SetColor(1);
 SetFillStyle(1, 1);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 120, 60, 'XIANGQI');
 SetTextStyle(0, 0, 1);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 100, 'Echecs Chinois');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 140, 'Jeu d''echecs traditionnel chinois avec des regles uniques.');
 OutTextXY(50, 170, 'Regles principales:');
 OutTextXY(50, 190, '- Le General ne peut sortir du palais');
 OutTextXY(50, 210, '- Les Elephants ne traversent pas la riviere');
 OutTextXY(50, 230, '- Les Chevaux peuvent etre bloques');
 OutTextXY(50, 250, '- Les Canons sautent pour capturer');
 OutTextXY(50, 270, '- Les Soldats avancent plus apres la riviere');
 OutTextXY(50, 300, 'Commandes:');
 OutTextXY(50, 320, 'Fleches: Deplacer le curseur');
 OutTextXY(50, 340, 'ENTREE: Selectionner piece / Jouer coup');
 OutTextXY(50, 360, 'C: Annuler la selection');
 OutTextXY(50, 390, 'Modes: 1=vs IA, 2=2 joueurs, ESC=Quitter');
 Repeat
  If KeyPressed Then Begin
   Case ReadKey of
    '1': Begin
     Game.gameMode := 1;
     Exit;
    End;
    '2': Begin
     Game.gameMode := 2;
     Exit;
    End;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;Begin
 SetupInitialPosition;
 Game.currentPlayer := plRed;
 Game.gameState := gsPlaying;
 Game.selectedX := 4;
 Game.selectedY := 9;
 Game.needRedraw := True;
 Game.isMoving := False;
 Game.moveFromX := -1;
 Game.moveFromY := -1;
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
  ComputerMove;
  Render;
  Delay(100);
 End;
End;

Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
Begin
 {$IFDEF FPC}
 Driver := VGA;
 Mode := VGAHi;
 {$ELSE}
 Driver := Detect;
 Mode := VGAHi;
 {$ENDIF}
 InitGraph(Driver, Mode, '');
 ErrCode:=GraphResult;
 If ErrCode<>grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
 SetLineStyle(0, 0, 1);
 Randomize;
End;

BEGIN
 InitializeGraphics;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.