{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Keno avec interface graphique
}

Program Keno;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS, Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 MAX_NUMBERS = 80;
 MAX_PLAYER_PICKS = 10;
 DRAWN_NUMBERS = 20;
 GRID_COLS = 10;
 GRID_ROWS = 8;
 CELL_SIZE = 30;
 GRID_START_X = 50;
 GRID_START_Y = 80;
 INITIAL_MONEY = 1000;

Type
 TGameState=(gsMainMenu, gsSelecting, gsPlaying, gsResults, gsGameOver, gsQuit);

 TGame=Record
  gameState:TGameState;
  playerMoney:LongInt;
  currentBet:LongInt;
  selectedNumbers:Array[1..MAX_PLAYER_PICKS] of Integer;
  selectedCount:Integer;
  drawnNumbers:Array[1..DRAWN_NUMBERS] of Integer;
  matches:Integer;
  winAmount:LongInt;
  needRedraw:Boolean;
  gameResult:String;
  roundComplete:Boolean;
 End;

Var
 Game:TGame;
 MouseAvailable:Boolean;
 LastMouseX,LastMouseY:Integer;
 LastMouseButton:Integer;

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs:Registers;
 Begin
  Regs.AX := 0;
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

{$ELSE}
 Function MouseDriverFound:Boolean;
 Begin
  MouseDriverFound := True; { Pas de support souris direct en Free Pascal }
 End;

 Procedure ShowMouse;Begin
  { Pas d'impl‚mentation pour Free Pascal }
 End;

 Procedure HideMouse;Begin
  { Pas d'impl‚mentation pour Free Pascal }
 End;

{$ENDIF}

Function IntToStr(value:LongInt):String;
Var
 s: String;
Begin
 Str(value, s);
 IntToStr := s;
End;

Function IsNumberSelected(number:Integer):Boolean;
Var
 i:Integer;
Begin
 IsNumberSelected:=False;
 For i:=1 to Game.selectedCount do If Game.selectedNumbers[i]=number Then Begin
  IsNumberSelected := True;
  Exit;
 End;
End;

Function IsNumberDrawn(number:Integer):Boolean;
Var
 i:Integer;
Begin
 IsNumberDrawn:=False;
 For i:=1 to DRAWN_NUMBERS do If Game.drawnNumbers[i]=number Then Begin
  IsNumberDrawn := True;
  Exit;
 End;
End;

Function IsNumberMatched(number:Integer):Boolean;Begin
 IsNumberMatched := IsNumberSelected(number) and IsNumberDrawn(number);
End;

Procedure AddSelectedNumber(number:Integer);Begin
 If(Game.selectedCount<MAX_PLAYER_PICKS)and not IsNumberSelected(number)Then Begin
  Inc(Game.selectedCount);
  Game.selectedNumbers[Game.selectedCount] := number;
 End;
End;

Procedure RemoveSelectedNumber(number: Integer);
Var
 i,j:Integer;
Begin
 For i:=1 to Game.selectedCount do If Game.selectedNumbers[i]=number Then Begin
  For j:=i to Game.selectedCount-1 do
   Game.selectedNumbers[j] := Game.selectedNumbers[j + 1];
  Dec(Game.selectedCount);
  Exit;
 End;
End;

Procedure DrawNumbers;
Var
 i,j,number,x,y:Integer;
 numberColor:Integer;
Begin
 number := 1;
 For i:=0 to GRID_ROWS - 1 do For j:=0 to GRID_COLS - 1 do Begin
  x := GRID_START_X + j * (CELL_SIZE + 5);
  y := GRID_START_Y + i * (CELL_SIZE + 5);
   { D‚terminer la couleur du num‚ro }
  If IsNumberMatched(number)Then numberColor:=10 Else { Vert clair - Match }
  If IsNumberSelected(number)Then numberColor:=14 Else { Jaune - S‚lectionn‚ }
  If IsNumberDrawn(number)Then numberColor:=12  { Rouge clair - Tir‚ mais pas s‚lectionn‚ }
                          Else numberColor:=8;  { Gris - Non s‚lectionn‚ }
   { Dessiner le cercle du num‚ro }
  SetColor(15);
  Circle(x+CELL_SIZE div 2,y+CELL_SIZE div 2,CELL_SIZE div 2);
   { Remplir le cercle avec la couleur appropriÃ©e }
  SetColor(numberColor);
  SetFillStyle(1, numberColor);
  FillEllipse(x + CELL_SIZE div 2, y + CELL_SIZE div 2,
                  CELL_SIZE div 2 - 2, CELL_SIZE div 2 - 2);
   { Afficher le numÃ©ro }
  SetColor(0);
  SetTextStyle(0, 0, 1);
  If number < 10 Then
   OutTextXY(x + CELL_SIZE div 2 - 4, y + CELL_SIZE div 2 - 4, IntToStr(number))
  Else
   OutTextXY(x + CELL_SIZE div 2 - 8, y + CELL_SIZE div 2 - 4, IntToStr(number));
  Inc(number);
 End;
End;

Procedure DrawInterface;Begin
  { Fond }
 SetColor(1);
 SetFillStyle(1, 1);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Titre }
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 60, 20, 'KENO');
  { Informations du jeu }
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(400, 100, 'Argent: ' + IntToStr(Game.playerMoney));
 OutTextXY(400, 120, 'Mise: ' + IntToStr(Game.currentBet));
 OutTextXY(400, 140, 'Numeros choisis: ' + IntToStr(Game.selectedCount) + '/' + IntToStr(MAX_PLAYER_PICKS));
 If Game.gameState=gsResults Then Begin
  OutTextXY(400, 180, 'Numeros correspons: ' + IntToStr(Game.matches));
  OutTextXY(400, 200, 'Gain: ' + IntToStr(Game.winAmount));
 End;
  { L‚gende }
 SetColor(15);
 OutTextXY(400, 250, 'Legende:');
  { Cercle vert - Match }
 SetColor(10);
 SetFillStyle(1, 10);
 FillEllipse(410, 270, 8, 8);
 SetColor(15);
 OutTextXY(425, 265, 'Match');
  { Cercle jaune - SÃ©lectionnÃ© }
 SetColor(14);
 SetFillStyle(1, 14);
 FillEllipse(410, 290, 8, 8);
 SetColor(15);
 OutTextXY(425, 285, 'Selectionne');
  { Cercle rouge - Tir‚ }
 SetColor(12);
 SetFillStyle(1, 12);
 FillEllipse(410, 310, 8, 8);
 SetColor(15);
 OutTextXY(425, 305, 'Tire');
  { Cercle gris - Non s‚lectionn‚ }
 SetColor(8);
 SetFillStyle(1, 8);
 FillEllipse(410, 330, 8, 8);
 SetColor(15);
 OutTextXY(425, 325, 'Non selectionne');
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 Case Game.gameState of
  gsSelecting:Begin
   OutTextXY(50, 400, 'Touches: 1-9, a-z, A-Z pour selectionner  R: Aleatoire  C: Effacer');
   OutTextXY(50, 420, 'ESPACE: Jouer  +/-: Ajuster mise  N: Nouveau jeu  ESC: Quitter');
   If MouseAvailable Then
    OutTextXY(50, 440, 'Souris: Cliquez sur les numeros pour les selectionner/deselectionner');
  End;
  gsResults:Begin
   OutTextXY(50, 420, Game.gameResult);
   OutTextXY(50, 440, 'ENTREE: Nouvelle partie  N: Nouveau jeu  ESC: Quitter');
  End;
 End;
End;

Procedure DrawMainMenu;Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 4);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 80, 'KENO');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 150, 'Regles du Keno:');
 OutTextXY(50, 170, '- Choisissez jusqu''a 10 numeros parmi 80 (1-80)');
 OutTextXY(50, 190, '- 20 numeros seront tires au hasard');
 OutTextXY(50, 210, '- Plus vous avez de numeros correspondants, plus vous gagnez');
 OutTextXY(50, 230, '- Les gains dependent du nombre de numeros choisis et trouves');
 OutTextXY(50, 270, 'Table des gains (pour 10 numeros choisis):');
 OutTextXY(50, 290, '10 matches: 10000x la mise');
 OutTextXY(50, 310, '9 matches: 2000x la mise');
 OutTextXY(50, 330, '8 matches: 500x la mise');
 OutTextXY(50, 350, '7 matches: 100x la mise');
 OutTextXY(50, 370, '6 matches: 20x la mise');
 OutTextXY(50, 390, '5 matches: 5x la mise');
 OutTextXY(50, 430, 'Commandes:');
 OutTextXY(50, 450, 'ENTREE: Commencer  ESC: Quitter');
End;

Function GetNumberAt(x,y:Integer):Integer;
Var
 col,row:Integer;
 R:Integer;
Begin
 GetNumberAt:=0;
 If(x>=GRID_START_X)and(y >= GRID_START_Y)Then Begin
  col:=(x - GRID_START_X) div (CELL_SIZE + 5);
  row:=(y - GRID_START_Y) div (CELL_SIZE + 5);
  If(col>=0)and(col<GRID_COLS)and(row>=0)and(row<GRID_ROWS)Then Begin
   R:=row * GRID_COLS + col + 1;
   If R>MAX_NUMBERS Then GetNumberAt := 0;
   GetNumberAt:=R;
  End;
 End;
End;

Procedure DrawKeno;
Var
 i:Integer;
Begin
 DrawInterface;
 DrawNumbers;
 DrawInstructions;
  { Afficher les numÃ©ros sÃ©lectionnÃ©s }
 If Game.selectedCount>0 Then Begin
  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(400, 160, 'Vos numeros:');
  For i := 1 to Game.selectedCount do Begin
   If i <= 5 Then
    OutTextXY(400 + (i - 1) * 25, 175, IntToStr(Game.selectedNumbers[i]))
   Else
    OutTextXY(400 + (i - 6) * 25, 190, IntToStr(Game.selectedNumbers[i]));
  End;
 End;
End;

Procedure GenerateDrawnNumbers;
Var
 i,j,number:Integer;
 alreadyDrawn:Boolean;
Begin
 For i := 1 to DRAWN_NUMBERS do Begin
  Repeat
   number := Random(MAX_NUMBERS) + 1;
   alreadyDrawn := False;
   For j:=1 to i-1 do If Game.drawnNumbers[j]=number Then Begin
    alreadyDrawn := True;
    Break;
   End;
  Until not alreadyDrawn;
  Game.drawnNumbers[i] := number;
 End;
End;

Function CalculateWinAmount:LongInt;
Var
 multiplier:Integer;
Begin
 multiplier := 0;
  { Table des gains bas‚e sur le nombre de numÃ©ros choisis et trouv‚s }
 Case Game.selectedCount of
  1:Case Game.matches of
   1:multiplier:=3;
  End;
  2:Case Game.matches of
   2:multiplier:=12;
  End;
  3:Case Game.matches of
   2: multiplier:=1;
   3: multiplier:=42;
  End;
  4:Case Game.matches of
   2:multiplier:=1;
   3:multiplier:=4;
   4:multiplier:=120;
  End;
  5:Case Game.matches of
   3:multiplier:=1;
   4:multiplier:=8;
   5:multiplier:=400;
  End;
  6:Case Game.matches of
   3:multiplier:=1;
   4:multiplier:=2;
   5:multiplier:=20;
   6:multiplier:=1000;
  End;
  7:Case Game.matches of
   4:multiplier:=1;
   5:multiplier:=5;
   6:multiplier:=100;
   7:multiplier:=2000;
  End;
  8:Case Game.matches of
   5:multiplier:=2;
   6:multiplier:=20;
   7:multiplier:=500;
   8:multiplier:=5000;
  End;
  9:Case Game.matches of
   5:multiplier:=1;
   6:multiplier:=5;
   7:multiplier:=100;
   8:multiplier:=2000;
   9:multiplier:=8000;
  End;
  10:Case Game.matches of
   5: multiplier := 5;
   6: multiplier := 20;
   7: multiplier := 100;
   8: multiplier := 500;
   9: multiplier := 2000;
   10: multiplier := 10000;
  End;
 End;
 CalculateWinAmount:=Game.currentBet*multiplier;
End;

Procedure PlayGame;
Var
 i:Integer;
Begin
 If Game.selectedCount=0 Then Exit;
  { D‚duire la mise }
 Game.playerMoney := Game.playerMoney - Game.currentBet;
  { G‚n‚rer les num‚ros tir‚s }
 GenerateDrawnNumbers;
  { Calculer les correspondances }
 Game.matches:=0;
 For i:=1 to Game.selectedCount do If IsNumberDrawn(Game.selectedNumbers[i])Then
  Inc(Game.matches);
  { Calculer le gain }
 Game.winAmount := CalculateWinAmount;
 Game.playerMoney := Game.playerMoney + Game.winAmount;
  { Pr‚parer le r‚sultat }
 If Game.winAmount > 0 Then
  Game.gameResult := 'Felicitations! Vous avez gagne ' + IntToStr(Game.winAmount) + ' credits!'
 Else
  Game.gameResult := 'Dommage! Aucun gain cette fois.';
 Game.gameState := gsResults;
 Game.roundComplete := True;
 Game.needRedraw := True;
End;

Procedure ResetGame;Begin
 Game.selectedCount := 0;
 Game.matches := 0;
 Game.winAmount := 0;
 Game.roundComplete := False;
 Game.gameResult := '';
 Game.gameState := gsSelecting;
 Game.needRedraw := True;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case Game.gameState of
   gsMainMenu:Begin
    If key = #13 Then Begin { Enter }
     ResetGame;
     Game.needRedraw:=True;
    End
    Else If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
   gsSelecting:Begin
    If(key >= '1')and(key <= '9')Then Begin
      { S‚lection rapide de num‚ros 1 … 9 }
     If IsNumberSelected(Ord(key)-Ord('0'))Then
      RemoveSelectedNumber(Ord(key) - Ord('0'))
     Else
      AddSelectedNumber(Ord(key) - Ord('0'));
     Game.needRedraw := True;
    End
     Else
    If(key >= 'a')and(key <= 'z')Then Begin
      { S‚lection de numÃ©ros 10-35 (a=10, b=11,...) }
     If IsNumberSelected(Ord(key) - Ord('a') + 10) Then
      RemoveSelectedNumber(Ord(key) - Ord('a') + 10)
     Else
      AddSelectedNumber(Ord(key) - Ord('a') + 10);
     Game.needRedraw := True;
    End
     Else
    If(key >= 'A')and(key <= 'Z')Then Begin
      { S‚lection de num‚ros 36-61 (A=36, B=37,...) }
     If IsNumberSelected(Ord(key)-Ord('A')+36) Then
      RemoveSelectedNumber(Ord(key)-Ord('A')+36)
     Else
      AddSelectedNumber(Ord(key) - Ord('A')+36);
     Game.needRedraw := True;
    End
     Else
    Begin
     Case key of
      ' ':Begin
       If (Game.selectedCount > 0) and (Game.currentBet <= Game.playerMoney) Then
        PlayGame;
      End;
      'r', 'R':Begin
       { S‚lection al‚atoire de num‚ros }
       Game.selectedCount:=0;
       While Game.selectedCount<10 do AddSelectedNumber(Random(MAX_NUMBERS)+1);
       Game.needRedraw := True;
      End;
      'c','C':Begin
       { Effacer la sÃ©lection }
       Game.selectedCount := 0;
       Game.needRedraw := True;
      End;
      '+':Begin
       If Game.currentBet < Game.playerMoney Then Begin
        Game.currentBet := Game.currentBet + 10;
        Game.needRedraw := True;
       End;
      End;
      '-':Begin
       If Game.currentBet>10 Then Begin
        Game.currentBet:=Game.currentBet-10;
        Game.needRedraw:=True;
       End;
      End;
      'n','N':Begin
       Game.playerMoney := INITIAL_MONEY;
       Game.currentBet := 50;
       ResetGame;
      End;
      #27: Game.gameState := gsQuit; { ESC }
     End;
    End;
   End;
   gsResults:Begin
    If key=#13 Then Begin { Enter }
     If Game.playerMoney<=0 Then Game.gameState := gsGameOver
                            Else ResetGame;
    End
     Else
    If key='n'Then Begin
     Game.playerMoney := INITIAL_MONEY;
     Game.currentBet := 50;
     ResetGame;
    End
     Else
    If key='N'Then Begin
     Game.playerMoney := INITIAL_MONEY;
     Game.currentBet := 50;
     ResetGame;
    End
     Else
    If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
  End;
 End;
End;

Procedure HandleMouse;
Var
 mouseX,mouseY,mouseButton:LongInt;
 number:Integer;
 buttonPressed:Boolean;
Begin
 If not MouseAvailable Then Exit;
 GetMouseState(mouseX, mouseY, mouseButton);
  { V‚rifier si le bouton gauche vient d'ˆtre press‚ }
 buttonPressed:=(mouseButton and 1=1)and(LastMouseButton and 1=0);
 If buttonPressed and(Game.gameState = gsSelecting)Then Begin
  number:=GetNumberAt(mouseX, mouseY);
  If number>0 Then Begin
   If IsNumberSelected(number)Then RemoveSelectedNumber(number)
                              Else AddSelectedNumber(number);
   Game.needRedraw := True;
  End;
 End;
  { Sauvegarder l'Ã©tat actuel pour la prochaine fois }
 LastMouseX:=mouseX;
 LastMouseY:=mouseY;
 LastMouseButton:=mouseButton;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  Case Game.gameState of
   gsMainMenu:DrawMainMenu;
   gsSelecting,gsResults:DrawKeno;
   gsGameOver:Begin
    SetColor(0);
    SetFillStyle(1, 0);
    Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    SetColor(15);
    SetTextStyle(0, 0, 3);
    OutTextXY(SCREEN_WIDTH div 2 - 100, 200, 'GAME OVER');
    OutTextXY(50, 300, 'Vous n''avez plus d''argent!');
    OutTextXY(50, 350, 'Appuyez sur N pour un nouveau jeu ou ESC pour quitter');
   End;
  End;
  Game.needRedraw := False;
 End;
End;

Procedure InitializeGame;Begin
 Game.gameState := gsMainMenu;
 Game.playerMoney := INITIAL_MONEY;
 Game.currentBet := 50;
 Game.selectedCount := 0;
 Game.matches := 0;
 Game.winAmount := 0;
 Game.needRedraw := True;
 Game.roundComplete := False;
 Game.gameResult := '';
 Randomize;
End;

Procedure GameLoop;Begin
 While Game.gameState <> gsQuit do Begin
  HandleInput;
  HandleMouse;
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
  { Initialiser la souris }
 MouseAvailable:=MouseDriverFound;
 If MouseAvailable Then Begin
  ShowMouse;
 End;
End;

BEGIN
 InitializeGraphics;
 InitializeGame;
 GameLoop;
 If MouseAvailable Then HideMouse;
 CloseGraph;
END.
