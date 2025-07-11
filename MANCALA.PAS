{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Mancala - Jeu de stratÇgie traditionnel africain
}

Program Mancala;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH=640;
 SCREEN_HEIGHT=480;
 BOARD_WIDTH=500;
 BOARD_HEIGHT=200;
 BOARD_X=70;
 BOARD_Y=140;
 HOLE_SIZE=50;
 KALAHA_WIDTH=60;
 KALAHA_HEIGHT=140;
 SEED_RADIUS=3;
 MAX_SEEDS_PER_HOLE=48;

Type
 TPlayer=(pPlayer1, pPlayer2);
 TGameState=(gsPlaying,gsGameOver,gsQuit);

 TBoard=Array[0..13] of Integer; { 0-5: Joueur 1, 6: Kalaha J1, 7-12: Joueur 2, 13: Kalaha J2 }

 TGame=Record
  board:TBoard;
  currentPlayer:TPlayer;
  gameState:TGameState;
  selectedHole:Integer;
  needRedraw:Boolean;
  winner:TPlayer;
  winnerSet:Boolean;
  lastAction:String;
  validMoves:Array[0..5] of Boolean;
  hasValidMoves:Boolean;
 End;

Var
 Game:TGame;

 { Fonction IntToStr pour compatibilitÇ }
Function IntToStr(value:Integer):String;
Var
 s:String;
Begin
 Str(value,s);
 IntToStr:=s;
End;

{ DÇclarations forward }
Procedure InitializeGame;Forward;

Function GetPlayerName(player:TPlayer):String;Begin
 Case player of
  pPlayer1:GetPlayerName := 'Vous (Humain)';
  pPlayer2:GetPlayerName := 'Ordinateur (IA)';
 End;
End;

Function GetPlayerColor(player:TPlayer):Integer;Begin
 Case player of
  pPlayer1:GetPlayerColor := 4; { Rouge }
  pPlayer2:GetPlayerColor := 1; { Bleu }
 End;
End;

Function IsPlayerHole(player: TPlayer; hole: Integer):Boolean;Begin
 Case player of
  pPlayer1: IsPlayerHole:=(hole >= 0) and (hole <= 5);
  pPlayer2: IsPlayerHole:=(hole >= 7) and (hole <= 12);
 End;
End;

Function GetPlayerKalaha(player:TPlayer):Integer;Begin
 Case player of
  pPlayer1: GetPlayerKalaha := 6;
  pPlayer2: GetPlayerKalaha := 13;
 End;
End;

Function GetOppositeHole(hole:Integer):Integer;Begin
 If(hole >= 0)and(hole <= 5)Then GetOppositeHole:=12 - hole Else
 If(hole >= 7)and(hole <= 12)Then GetOppositeHole:=12 - hole
                             Else GetOppositeHole:=-1;
End;

Procedure CheckValidMoves(player:TPlayer);
Var
 i,startHole,endHole:Integer;
Begin
 Game.hasValidMoves:=False;
 Case player of
  pPlayer1:Begin
   startHole := 0;
   endHole := 5;
  End;
  pPlayer2:Begin
   startHole := 7;
   endHole := 12;
  End;
 End;

 For i:=startHole to endHole do Begin
  If player=pPlayer1 Then Game.validMoves[i]:=(Game.board[i] > 0)
                     Else Game.validMoves[i-7]:=(Game.board[i] > 0);
  If Game.board[i] > 0 Then Game.hasValidMoves := True;
 End;
End;

Function IsGameOver:Boolean;
Var
 i: Integer;
 player1HasSeeds,player2HasSeeds:Boolean;
Begin
 player1HasSeeds :=False;
 player2HasSeeds := False;
  { VÇrifier si le joueur 1 a des graines }
 For i:=0 to 5 do If Game.board[i]>0 Then player1HasSeeds:=True;
  { VÇrifier si le joueur 2 a des graines }
 For i:=7 to 12 do If Game.board[i]>0 Then player2HasSeeds := True;
 IsGameOver := not (player1HasSeeds and player2HasSeeds);
End;

Procedure CollectRemainingSeeds;
Var
 i:Integer;
Begin
  { Collecter les graines restantes du joueur 1 }
 For i:=0 to 5 do Begin
  Game.board[6]:=Game.board[6]+Game.board[i];
  Game.board[i]:=0;
 End;
  { Collecter les graines restantes du joueur 2 }
 For i:=7 to 12 do Begin
  Game.board[13] := Game.board[13] + Game.board[i];
  Game.board[i] := 0;
 End;
End;

Procedure CheckWinner;Begin
 If IsGameOver Then Begin
  CollectRemainingSeeds;
  If Game.board[6]>Game.board[13]Then Begin
   Game.winner:=pPlayer1;
   Game.lastAction:='Vous gagnez!';
  End
   Else
  If Game.board[13]>Game.board[6]Then Begin
   Game.winner := pPlayer2;
   Game.lastAction:='L''ordinateur gagne!';
  End
   Else
  Game.lastAction := 'Egalite!';
  Game.winnerSet:=True;
  Game.gameState:=gsGameOver;
 End;
End;

Function MakeMove(player:TPlayer;hole:Integer):Boolean;
Var
 seeds,currentHole:Integer;
 extraTurn:Boolean;
 oppositeHole:Integer;
Begin
 MakeMove:=False;
  { VÇrifier si le mouvement est valide }
 If Not IsPlayerHole(player,hole)or(Game.board[hole]=0)Then Exit;
  { Prendre les graines du trou }
 seeds:=Game.board[hole];
 Game.board[hole]:=0;
 currentHole:=hole;
 extraTurn:=False;
  { Distribuer les graines }
 While seeds>0 do Begin
  currentHole:=(currentHole+1) mod 14;
   { Ignorer le kalaha de l'adversaire }
  If((player=pPlayer1)and(currentHole=13))or
     ((player=pPlayer2)and(currentHole=6))Then
   currentHole:=(currentHole+1) mod 14;
  Game.board[currentHole] := Game.board[currentHole] + 1;
  Dec(seeds);
 End;
  { VÇrifier si on termine dans son propre kalaha (tour supplÇmentaire) }
 If((player=pPlayer1)and(currentHole=6))or
   ((player=pPlayer2)and(currentHole=13))Then Begin
  extraTurn:=True;
  Game.lastAction:=GetPlayerName(player)+' joue encore!';
 End
  Else
 Begin
  { VÇrifier la rägle de capture }
  If IsPlayerHole(player,currentHole)and(Game.board[currentHole]=1)Then Begin
   oppositeHole:=GetOppositeHole(currentHole);
   If (oppositeHole>=0)and(Game.board[oppositeHole]>0)Then Begin
     { Capturer les graines }
    If player = pPlayer1 Then Begin
     Game.board[6]:=Game.board[6] + Game.board[currentHole] + Game.board[oppositeHole];
     Game.lastAction:='Vous capturez les graines!';
    End
     Else
    Begin
     Game.board[13]:=Game.board[13]+Game.board[currentHole]+Game.board[oppositeHole];
     Game.lastAction:='L''ordinateur capture!';
    End;
    Game.board[currentHole] := 0;
    Game.board[oppositeHole] := 0;
   End
    Else
   Game.lastAction := GetPlayerName(player)+' joue';
  End
   Else
  Game.lastAction := GetPlayerName(player) + ' joue';
 End;
  { Changer de joueur si pas de tour supplÇmentaire }
 If not extraTurn Then Begin
  If Game.currentPlayer=pPlayer1 Then Game.currentPlayer:=pPlayer2
                                 Else Game.currentPlayer:=pPlayer1;
 End;
 MakeMove:=True;
End;

Procedure ComputerMove;
Var
 i,bestHole,bestScore,score:Integer;
 startHole,endHole:Integer;
 tempBoard:TBoard;
 tempSeeds,tempHole:Integer;
Begin
 bestHole:=-1;
 bestScore:=-1;
 { DÇterminer la plage de trous pour le joueur 2 }
 startHole:=7;
 endHole:=12;
 { êvaluer chaque mouvement possible }
 For i:=startHole to endHole do Begin
  If Game.board[i]>0 Then Begin
   score:=0;
    { Simuler le mouvement }
   tempBoard:=Game.board;
   tempSeeds:=tempBoard[i];
   tempBoard[i]:=0;
   tempHole:=i;
    { Distribuer les graines }
   While tempSeeds>0 do Begin
    tempHole:=(tempHole+1) mod 14;
     { Ignorer le kalaha du joueur 1 }
    If tempHole=6 Then tempHole:=(tempHole+1) mod 14;
    tempBoard[tempHole] := tempBoard[tempHole] + 1;
    Dec(tempSeeds);
   End;
    { Çvaluer le pointage }
   score:=tempBoard[13]; { Graines dans notre kalaha }
   { Bonus si on termine dans notre kalaha (tour suppl√©mentaire) }
   If tempHole=13 Then score := score + 10;
   { Bonus si on peut capturer }
   If IsPlayerHole(pPlayer2,tempHole)and(tempBoard[tempHole]=1)Then Begin
    If tempBoard[GetOppositeHole(tempHole)]>0 Then score:=score+20;
   End;
   { PrÇfÇrer les trous avec moins de graines pour plus de contrìle }
   score:=score+(6 - Game.board[i]);
   If score>bestScore Then Begin
    bestScore:=score;
    bestHole:=i;
   End;
  End;
 End;
  { Faire le mouvement }
 If bestHole>=0 Then MakeMove(pPlayer2,bestHole);
End;

Procedure DrawHole(x,y,seeds:Integer;selected:Boolean);
Var
 i,j,seedX,seedY:Integer;
 rows,cols,seedIndex:Integer;
Begin
  { Dessiner le trou }
 SetColor(8);
 SetFillStyle(1, 8);
 Bar(x-HOLE_SIZE div 2,y-HOLE_SIZE div 2,x+HOLE_SIZE div 2,y+HOLE_SIZE div 2);
  { Contour du trou }
 If selected Then SetColor(15)
             Else SetColor(0);
 SetLineStyle(0,0,2);
 Rectangle(x-HOLE_SIZE div 2,y-HOLE_SIZE div 2,x+HOLE_SIZE div 2,y+HOLE_SIZE div 2);
 SetLineStyle(0,0,1);
  { Dessiner les graines }
 If seeds>0 Then Begin
  SetColor(14);
  SetFillStyle(1,14);
  { Organiser les graines en grille }
  If seeds<=9 Then Begin
   rows:=3;
   cols:=3;
  End
   Else
  If seeds<=16 Then Begin
   rows:=4;
   cols:=4;
  End
   Else
  If seeds<=25 Then Begin
   rows:=5;
   cols:=5;
  End
   Else
  Begin
   rows := 6;
   cols := 6;
  End;
  seedIndex:=0;
  For i:=0 to rows-1 do For j:=0 to cols-1 do If seedIndex<seeds Then Begin
   seedX:=x-(HOLE_SIZE div 2)+8+j * ((HOLE_SIZE - 16) div (cols - 1));
   seedY:=y-(HOLE_SIZE div 2)+8+i * ((HOLE_SIZE - 16) div (rows - 1));
   Circle(seedX, seedY, SEED_RADIUS);
   FloodFill(seedX, seedY, 14);
   Inc(seedIndex);
  End;
 End;
  { Afficher le nombre de graines si trop nombreuses }
 If seeds>MAX_SEEDS_PER_HOLE Then Begin
  SetColor(15);
  SetTextStyle(0,0,2);
  OutTextXY(x-10,y-5,IntToStr(seeds));
 End;
End;

Procedure DrawKalaha(x,y,seeds:Integer;player:TPlayer);
Var
 i,j,seedX,seedY:Integer;
 rows,cols,seedIndex:Integer;
Begin
  { Dessiner le kalaha }
 SetColor(GetPlayerColor(player));
 SetFillStyle(1, GetPlayerColor(player));
 Bar(x-KALAHA_WIDTH div 2,y-KALAHA_HEIGHT div 2,x+KALAHA_WIDTH div 2,y+KALAHA_HEIGHT div 2);
  { Contour du kalaha }
 SetColor(0);
 SetLineStyle(0,0,2);
 Rectangle(x-KALAHA_WIDTH div 2,y-KALAHA_HEIGHT div 2,x+KALAHA_WIDTH div 2,y+KALAHA_HEIGHT div 2);
 SetLineStyle(0, 0, 1);
  { Dessiner les graines }
 If seeds>0 Then Begin
  SetColor(14);
  SetFillStyle(1, 14);
   { Organiser les graines en grille }
  If seeds<=20 Then Begin
   rows:=4;
   cols:=5;
  End
   Else
  If seeds<=35 Then Begin
   rows:=5;
   cols:=7;
  End
   Else
  Begin
   rows := 6;
   cols := 8;
  End;
  seedIndex:=0;
  For i:=0 to rows-1 do For j:=0 to cols-1 do If seedIndex<seeds Then Begin
   seedX:=x - (KALAHA_WIDTH div 2) + 8 + j * ((KALAHA_WIDTH - 16) div (cols - 1));
   seedY:=y - (KALAHA_HEIGHT div 2) + 8 + i * ((KALAHA_HEIGHT - 16) div (rows - 1));
   Circle(seedX, seedY, SEED_RADIUS);
   FloodFill(seedX, seedY, 14);
   Inc(seedIndex);
  End;
 End;
  { Afficher le nombre de graines }
 SetColor(15);
 SetTextStyle(0, 0, 2);
 OutTextXY(x - 10, y + KALAHA_HEIGHT div 2 + 10, IntToStr(seeds));
End;

Procedure DrawBoard;
Var
 i,holeX,holeY:Integer;
 selected:Boolean;
Begin
  { Fond du plateau }
 SetColor(6);
 SetFillStyle(1,6);
 Bar(BOARD_X, BOARD_Y, BOARD_X + BOARD_WIDTH, BOARD_Y + BOARD_HEIGHT);
  { Contour du plateau }
 SetColor(0);
 SetLineStyle(0, 0, 3);
 Rectangle(BOARD_X, BOARD_Y, BOARD_X + BOARD_WIDTH, BOARD_Y + BOARD_HEIGHT);
 SetLineStyle(0, 0, 1);
  { Dessiner les trous du joueur 2 (rangÇe du haut) }
 For i:=0 to 5 do Begin
  holeX:=BOARD_X + KALAHA_WIDTH + 20 + i * 60;
  holeY:=BOARD_Y + 50;
  selected := (Game.currentPlayer = pPlayer2) and (Game.selectedHole = i) and (Game.gameState = gsPlaying);
  DrawHole(holeX, holeY, Game.board[12 - i], selected);
 End;
  { Dessiner les trous du joueur 1 (rangÇe du bas) }
 For i:=0 to 5 do Begin
  holeX:=BOARD_X + KALAHA_WIDTH + 20 + i*60;
  holeY:=BOARD_Y + 150;
  selected := (Game.currentPlayer = pPlayer1) and (Game.selectedHole = i) and (Game.gameState = gsPlaying);
  DrawHole(holeX, holeY, Game.board[i], selected);
 End;
  { Dessiner le kalaha du joueur 1 (droite) }
 DrawKalaha(BOARD_X + BOARD_WIDTH - KALAHA_WIDTH div 2, BOARD_Y + BOARD_HEIGHT div 2, Game.board[6], pPlayer1);
  { Dessiner le kalaha du joueur 2 (gauche) }
 DrawKalaha(BOARD_X + KALAHA_WIDTH div 2, BOARD_Y + BOARD_HEIGHT div 2, Game.board[13], pPlayer2);
End;

Procedure DrawGameInfo;Begin
 SetColor(15);
 SetTextStyle(0,0,2);
 OutTextXY(50,20,'MANCALA');
 SetTextStyle(0,0,1);
 SetColor(15);
 OutTextXY(50,50,'Joueur actuel:');
 SetColor(GetPlayerColor(Game.currentPlayer));
 OutTextXY(50, 70, GetPlayerName(Game.currentPlayer));
 SetColor(15);
 OutTextXY(50, 100, 'Pointage:');
 SetColor(GetPlayerColor(pPlayer1));
 OutTextXY(50, 120, 'Vous: ' + IntToStr(Game.board[6]));
 SetColor(GetPlayerColor(pPlayer2));
 OutTextXY(150, 120, 'Ordinateur: ' + IntToStr(Game.board[13]));
 SetColor(15);
 OutTextXY(50, 370, 'Commandes:');
 OutTextXY(50, 390, 'Fleches: Selectionner trou');
 OutTextXY(50, 410, 'ENTREE: Jouer le trou');
 OutTextXY(50, 430, 'N: Nouvelle partie');
 OutTextXY(50, 450, 'ESC: Quitter');
 If Game.lastAction<>''Then Begin
  SetColor(14);
  OutTextXY(300, 370, Game.lastAction);
 End;
End;

Procedure DrawGameStatus;Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 Case Game.gameState of
  gsGameOver: Begin
   If Game.winnerSet Then Begin
    If Game.board[6] > Game.board[13] Then
     OutTextXY(200, 380, 'GAGNANT: Vous!')
    Else If Game.board[13] > Game.board[6] Then
     OutTextXY(200, 380, 'GAGNANT: Ordinateur!')
    Else
     OutTextXY(200, 380, 'EGALITE!');
   End;
  End;
 End;
End;

Procedure HandleInput;
Var
 key: Char;
 hole: Integer;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   #0:Begin
    key:=ReadKey;
    Case key of
     #75: Begin { Fl√®che gauche }
      If Game.selectedHole>0 Then Begin
       Dec(Game.selectedHole);
       Game.needRedraw := True;
      End;
     End;
     #77: Begin { Fläche droite }
      If Game.selectedHole<5 Then Begin
       Inc(Game.selectedHole);
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   #13:Begin { EntrÇe - Jouer le trou }
    If (Game.currentPlayer = pPlayer1) and (Game.gameState = gsPlaying)Then Begin
     hole := Game.selectedHole;
     If(hole>=0)and(hole<=5)and(Game.board[hole]>0)Then Begin
      If MakeMove(pPlayer1,hole)Then Begin
       CheckWinner;
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   'n', 'N':Begin { Nouvelle partie }
    InitializeGame;
   End;
   #27:Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure ProcessComputerTurn;Begin
 If(Game.currentPlayer=pPlayer2)and(Game.gameState=gsPlaying)Then Begin
  Delay(1000);
  CheckValidMoves(pPlayer2);
  If Game.hasValidMoves Then Begin
   ComputerMove;
   CheckWinner;
   Game.needRedraw := True;
  End
   Else
  Begin
   { Pas de mouvement possible, fin de partie }
   Game.gameState:=gsGameOver;
   CheckWinner;
   Game.needRedraw:=True;
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  { Fond }
  SetColor(3);
  SetFillStyle(1, 3);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  DrawBoard;
  DrawGameInfo;
  DrawGameStatus;
  Game.needRedraw:=False;
 End;
End;

Procedure ShowTitle;Begin
 SetColor(3);
 SetFillStyle(1, 3);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 60, 'MANCALA');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 120, 'Jeu de strategie traditionnel africain');
 OutTextXY(50, 150, 'Regles:');
 OutTextXY(50, 170, '- Choisissez un trou de votre cote et distribuez les graines');
 OutTextXY(50, 190, '- Si votre derniere graine tombe dans votre kalaha, rejouez');
 OutTextXY(50, 210, '- Si votre derniere graine tombe dans un trou vide de votre cote,');
 OutTextXY(50, 230, '  capturez les graines du trou oppose');
 OutTextXY(50, 250, '- Le joueur avec le plus de graines dans son kalaha gagne');
 OutTextXY(50, 280, 'Plateau:');
 OutTextXY(50, 300, '- Rangee du haut: Ordinateur (Bleu)');
 OutTextXY(50, 320, '- Rangee du bas: Vous (Rouge)');
 OutTextXY(50, 340, '- Kalaha: Grandes zones de stockage sur les cotes');
 OutTextXY(50, 370, 'Commandes:');
 OutTextXY(50, 390, 'Fleches: Selectionner un trou');
 OutTextXY(50, 410, 'ENTREE: Jouer le trou selectionne');
 OutTextXY(50, 440, 'Appuyez sur une touche pour commencer...');
 ReadKey;
End;

Procedure InitializeGame;
Var
 i:Integer;
Begin
 { Initialiser le plateau - 4 graines par trou }
 For i:=0 to 13 do Begin
  If(i = 6)or(i = 13)Then Game.board[i]:=0  { Kalaha vides }
                     Else Game.board[i]:=4; { 4 graines par trou }
 End;
 Game.currentPlayer := pPlayer1;
 Game.gameState := gsPlaying;
 Game.selectedHole := 0;
 Game.needRedraw := True;
 Game.winner := pPlayer1;
 Game.winnerSet := False;
 Game.lastAction := 'Nouvelle partie commencee';
 Game.hasValidMoves := True;
  { Initialiser les mouvements valides }
 For i:=0 to 5 do Game.validMoves[i]:=True;
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
  ProcessComputerTurn;
  Render;
  Delay(100);
 End;
End;

Procedure InitializeGraphics;
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