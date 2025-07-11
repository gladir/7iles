{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu Lights Out - Puzzle game o— il faut ‚teindre toutes les lumiŠres}

Program LightsOut;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 GRID_SIZE = 5;
 CELL_SIZE = 60;
 BOARD_X = 150;
 BOARD_Y = 80;
 MAX_LEVELS = 25;

Type
 TLightState = (lsOff, lsOn);
 TGameState = (gsPlaying, gsLevelComplete, gsGameOver);

 TGame = Record
  board: Array[0..GRID_SIZE-1, 0..GRID_SIZE-1] of TLightState;
  cursorX, cursorY: Integer;
  currentLevel: Integer;
  gameState: TGameState;
  needRedraw: Boolean;
  moves: Integer;
 End;

Var
 Game: TGame;

Const
 { Niveaux pr‚d‚finis (patterns de d‚part) }
 LevelPatterns: Array[1..MAX_LEVELS, 0..GRID_SIZE-1, 0..GRID_SIZE-1] of TLightState =
 (
  { Niveau 1 - Pattern simple }
  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff)),

  { Niveau 2 - Pattern en croix }
  ((lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn)),

  { Niveau 3 - Pattern en X }
  ((lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff)),

  { Niveau 4 - Pattern complexe }
  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn)),

  { Niveau 5 - Pattern en L }
  ((lsOn,  lsOn,  lsOn,  lsOn,  lsOff),
   (lsOn,  lsOn,  lsOn,  lsOff, lsOn),
   (lsOn,  lsOn,  lsOn,  lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOn,  lsOn),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn)),

  { Niveau 6 - Pattern plein avec trous }
  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff)),

  { Niveau 7 - Pattern en U }
  ((lsOn,  lsOn,  lsOn,  lsOn,  lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOff)),

  { Niveau 8 - Pattern en damier }
  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOn,  lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff)),

  { Niveau 9 - Pattern complexe }
  ((lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOn),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOff, lsOn,  lsOn),
   (lsOn,  lsOn,  lsOn,  lsOff, lsOff)),

  { Niveau 10 - Pattern rectangulaire }
  ((lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff)),

  { Niveaux 11-25 - Patterns plus complexes }
  ((lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff)),

  ((lsOn,  lsOn,  lsOn,  lsOn,  lsOn),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOn,  lsOff, lsOn,  lsOn),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff)),

  ((lsOff, lsOff, lsOff, lsOn,  lsOff),
   (lsOff, lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff)),

  { Continuer avec d'autres patterns... }
  ((lsOn,  lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOn)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOn,  lsOff, lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOn)),

  ((lsOff, lsOff, lsOn,  lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOn,  lsOff, lsOn,  lsOff),
   (lsOff, lsOff, lsOn,  lsOff, lsOff)),

  ((lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOn,  lsOff, lsOn)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff)),

  ((lsOff, lsOn,  lsOn,  lsOn,  lsOn),
   (lsOff, lsOn,  lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff),
   (lsOff, lsOn,  lsOff, lsOff, lsOff)),

  ((lsOff, lsOn,  lsOn,  lsOn,  lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOff)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOn,  lsOn,  lsOn),
   (lsOff, lsOff, lsOn,  lsOn,  lsOff),
   (lsOff, lsOff, lsOn,  lsOff, lsOff)),

  ((lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOff, lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOff, lsOff, lsOff, lsOn),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOn),
   (lsOff, lsOn,  lsOff, lsOff, lsOn)),

  ((lsOn,  lsOff, lsOff, lsOff, lsOff),
   (lsOn,  lsOn,  lsOff, lsOff, lsOff),
   (lsOn,  lsOn,  lsOn,  lsOff, lsOff),
   (lsOn,  lsOn,  lsOn,  lsOn,  lsOff),
   (lsOff, lsOn,  lsOn,  lsOn,  lsOn))
 );

{ D‚clarations forward }
Procedure InitializeGame; Forward;

Procedure LoadLevel(level: Integer);
Var
 i,j:Integer;
Begin
 If(level>=1)and(level<=MAX_LEVELS)Then Begin
  For i := 0 to GRID_SIZE - 1 do For j := 0 to GRID_SIZE - 1 do
   Game.board[i, j] := LevelPatterns[level, i, j];
  Game.currentLevel := level;
  Game.moves := 0;
  Game.gameState := gsPlaying;
  Game.needRedraw := True;
 End;
End;

Procedure ToggleLight(x,y:Integer);Begin
 If(x>=0)and(x<GRID_SIZE)and(y>=0)and(y<GRID_SIZE)Then Begin
  If Game.board[y,x]=lsOn Then Game.board[y,x]:=lsOff
                          Else Game.board[y,x]:=lsOn;
 End;
End;

Procedure ToggleLights(x,y:Integer);Begin
 If(x>=0)and(x<GRID_SIZE)and(y>=0)and(y<GRID_SIZE)Then Begin
   { Basculer la lumiŠre principale }
  ToggleLight(x, y);
   { Basculer les lumiŠres adjacentes }
  ToggleLight(x - 1, y);     { Gauche }
  ToggleLight(x + 1, y);     { Droite }
  ToggleLight(x, y - 1);     { Haut }
  ToggleLight(x, y + 1);     { Bas }
  Inc(Game.moves);
  Game.needRedraw := True;
 End;
End;

Function AllLightsOff:Boolean;
Var
 i,j:Integer;
Begin
 AllLightsOff:=True;
 For i:=0 to GRID_SIZE - 1 do For j:=0 to GRID_SIZE - 1 do
  If Game.board[i,j]=lsOn Then Begin
   AllLightsOff := False;
   Exit;
  End;
End;

Procedure DrawLight(x,y:Integer;state:TLightState;selected:Boolean);
Var
 centerX,centerY:Integer;
 lightColor,borderColor:Integer;
Begin
 centerX:=BOARD_X+x*CELL_SIZE+CELL_SIZE div 2;
 centerY:=BOARD_Y+y*CELL_SIZE+CELL_SIZE div 2;
  { Couleur de la lumiÃ¨re }
 If state=lsOn Then lightColor:=14  { Jaune pour allum‚ }
               Else lightColor:=8;  { Gris fonc‚ pour ‚teint }
  { Couleur de la bordure }
 If selected Then borderColor:=15  { Blanc pour sÃ©lectionnÃ© }
             Else borderColor:=0;  { Noir pour normal }
  { Dessiner la cellule }
 SetColor(lightColor);
 SetFillStyle(1,lightColor);
 Bar(centerX-CELL_SIZE div 2 + 5,centerY-CELL_SIZE div 2+5,
     centerX+CELL_SIZE div 2 - 5,centerY+CELL_SIZE div 2-5);
  { Dessiner la bordure }
 SetColor(borderColor);
 If selected Then SetLineStyle(0, 0, 3)
             Else SetLineStyle(0, 0, 1);
 Rectangle(centerX - CELL_SIZE div 2 + 5, centerY - CELL_SIZE div 2 + 5,
           centerX + CELL_SIZE div 2 - 5, centerY + CELL_SIZE div 2 - 5);
  { Effet de lumiŠre pour les cellules allum‚es }
 If state=lsOn Then Begin
  SetColor(15);
  Circle(centerX, centerY, 15);
  SetColor(14);
  SetFillStyle(1, 14);
  FloodFill(centerX, centerY, 15);
 End;
 SetLineStyle(0,0,1);
End;

Procedure DrawBoard;
Var
 i,j:Integer;
Begin
  { Fond du plateau }
 SetColor(3);
 SetFillStyle(1,3);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
  { Titre }
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 20, 'LIGHTS OUT');
  { Informations du niveau }
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 60, 'Niveau: ' + Chr(Ord('0') + Game.currentLevel div 10) + Chr(Ord('0') + Game.currentLevel mod 10));
 OutTextXY(50, 80, 'Coups: ' + Chr(Ord('0') + Game.moves div 10) + Chr(Ord('0') + Game.moves mod 10));
  { Grille des lumiŠres }
 For i := 0 to GRID_SIZE-1 do For j:=0 to GRID_SIZE-1 do
  DrawLight(j, i, Game.board[i,j],(j=Game.cursorX)and(i=Game.cursorY));
  { Instructions }
 SetColor(15);
 OutTextXY(50,400,'Fleches: Deplacer curseur');
 OutTextXY(50,420,'ENTREE: Basculer lumieres');
 OutTextXY(50,440,'R: Recommencer niveau');
 OutTextXY(50,460,'ESC: Quitter');
  { Objectif }
 SetColor(11);
 OutTextXY(400,400,'Objectif: Eteindre toutes les lumieres');
 OutTextXY(400,420,'Cliquer sur une lumiere bascule');
 OutTextXY(400,440,'son etat et celui des voisines');
End;

Procedure DrawGameStatus;Begin
 Case Game.gameState of
  gsLevelComplete:Begin
   SetColor(15);
   SetFillStyle(1,4);
   Bar(200,200,440,280);
   SetColor(0);
   Rectangle(200,200,440,280);
   SetColor(15);
   SetTextStyle(0,0,2);
   OutTextXY(220,220,'NIVEAU COMPLETE !');
   SetTextStyle(0,0,1);
   OutTextXY(220,250,'Appuyez sur ENTREE pour continuer');
  End;
  gsGameOver:Begin
   SetColor(15);
   SetFillStyle(1, 2);
   Bar(150, 180, 490, 300);
   SetColor(0);
   Rectangle(150, 180, 490, 300);
   SetColor(15);
   SetTextStyle(0, 0, 3);
   OutTextXY(200, 200, 'FELICITATIONS !');
   SetTextStyle(0, 0, 1);
   OutTextXY(160, 240, 'Vous avez termine tous les niveaux !');
   OutTextXY(200, 260, 'Appuyez sur N pour rejouer');
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
     #72: Begin { FlŠche haut }
      Game.cursorY:=(Game.cursorY - 1 + GRID_SIZE) mod GRID_SIZE;
      Game.needRedraw:=True;
     End;
     #80:Begin { FlŠche bas }
      Game.cursorY:=(Game.cursorY + 1) mod GRID_SIZE;
      Game.needRedraw:=True;
     End;
     #75:Begin { FlŠche gauche }
      Game.cursorX:=(Game.cursorX - 1 + GRID_SIZE) mod GRID_SIZE;
      Game.needRedraw:=True;
     End;
     #77:Begin { FlŠche droite }
      Game.cursorX:=(Game.cursorX + 1) mod GRID_SIZE;
      Game.needRedraw:=True;
     End;
    End;
   End;
   #13: Begin { Entr‚e }
    Case Game.gameState of
     gsPlaying:Begin
      ToggleLights(Game.cursorX, Game.cursorY);
      If AllLightsOff Then Begin
       Game.gameState := gsLevelComplete;
       Game.needRedraw := True;
      End;
     End;
     gsLevelComplete:Begin
      If Game.currentLevel<MAX_LEVELS Then Begin
       LoadLevel(Game.currentLevel + 1);
      End
       Else
      Begin
       Game.gameState := gsGameOver;
       Game.needRedraw := True;
      End;
     End;
    End;
   End;
   'r','R':Begin { Recommencer niveau }
    If Game.gameState=gsPlaying Then Begin
     LoadLevel(Game.currentLevel);
    End;
   End;
   'n', 'N': Begin { Nouvelle partie }
    If Game.gameState=gsGameOver Then Begin
     InitializeGame;
    End;
   End;
   #27: Halt; { ESC - Quitter }
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  DrawBoard;
  DrawGameStatus;
  Game.needRedraw:=False;
 End;
End;

Procedure InitializeGame;Begin
 Game.cursorX:=2;
 Game.cursorY:=2;
 Game.moves:=0;
 Game.needRedraw:=True;
 LoadLevel(1);
End;

Procedure ShowTitle;Begin
 SetColor(3);
 SetFillStyle(1,3);
 Bar(0,0,SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 4);
 OutTextXY(SCREEN_WIDTH div 2 - 120,80,'LIGHTS OUT');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 150, 'Jeu de puzzle ou vous devez eteindre toutes les lumieres');
 OutTextXY(50, 170, 'Quand vous cliquez sur une lumiere, elle change d''etat');
 OutTextXY(50, 190, 'ainsi que ses 4 voisines (haut, bas, gauche, droite)');
 SetColor(14);
 OutTextXY(50, 230, 'Regles:');
 OutTextXY(50, 250, '- Utilisez les fleches pour deplacer le curseur');
 OutTextXY(50, 270, '- Appuyez sur ENTREE pour basculer les lumieres');
 OutTextXY(50, 290, '- Le but est d''eteindre toutes les lumieres');
 OutTextXY(50, 310, '- Essayez de le faire en moins de coups possible');
 SetColor(11);
 OutTextXY(50, 350, 'Commandes:');
 OutTextXY(50, 370, 'Fleches: Deplacer le curseur');
 OutTextXY(50, 390, 'ENTREE: Basculer les lumieres');
 OutTextXY(50, 410, 'R: Recommencer le niveau');
 OutTextXY(50, 430, 'ESC: Quitter le jeu');
 SetColor(15);
 OutTextXY(50, 460, 'Appuyez sur une touche pour commencer...');
 ReadKey;
End;

Procedure GameLoop;Begin
 While True do Begin
  HandleInput;
  Render;
  Delay(50);
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
 InitGraph(Driver, Mode, '');
 ErrCode := GraphResult;
 If ErrCode <> grOk Then Begin
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
