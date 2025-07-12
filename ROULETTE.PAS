{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu Roulette de Casino - Placez vos mises et tentez votre chance
}

Program RouletteCasino;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  DOS,Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 MAX_BETS = 10;
 STARTING_MONEY = 1000;

Type
 TBetType=(btNumber, btRed, btBlack, btEven, btOdd, btLow, btHigh, btDozen1, btDozen2, btDozen3);

 TBet=Record
  betType:TBetType;
  number:Integer;     { Pour les mises sur num√©ro }
  amount:Integer;
  active:Boolean;
 End;

 TGameState=(gsPlacing, gsSpinning, gsResult, gsQuit);

 TGame=Record
  playerMoney: Integer;
  currentBet: Integer;
  bets: Array[0..MAX_BETS-1] of TBet;
  betCount: Integer;
  selectedBetType: TBetType;
  selectedNumber: Integer;
  winningNumber: Integer;
  gameState: TGameState;
  needRedraw: Boolean;
  spinAnimation: Integer;
  resultTimer: Integer;
 End;

Var
 Game: TGame;
 RedNumbers: Array[1..18] of Integer;

{ DÇclarations forward }
Procedure InitializeRedNumbers; Forward;
Procedure InitializeGame; Forward;

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
  { Pas d'implÔøΩmentation pour Free Pascal }
 End;

 Procedure HideMouse;Begin
  { Pas d'implÔøΩmentation pour Free Pascal }
 End;

{$ENDIF}

Procedure InitializeRedNumbers;Begin
 RedNumbers[1] := 1; RedNumbers[2] := 3; RedNumbers[3] := 5; RedNumbers[4] := 7;
 RedNumbers[5] := 9; RedNumbers[6] := 12; RedNumbers[7] := 14; RedNumbers[8] := 16;
 RedNumbers[9] := 18; RedNumbers[10] := 19; RedNumbers[11] := 21; RedNumbers[12] := 23;
 RedNumbers[13] := 25; RedNumbers[14] := 27; RedNumbers[15] := 30; RedNumbers[16] := 32;
 RedNumbers[17] := 34; RedNumbers[18] := 36;
End;

Function IsRedNumber(num:Integer):Boolean;
Var
 i:Integer;
Begin
 IsRedNumber := False;
 For i:=1 to 18 do If RedNumbers[i]=num Then Begin
   IsRedNumber := True;
   Exit;
  End;
End;

Function GetNumberColor(num:Integer):Integer;Begin
 If num=0 Then GetNumberColor:=2 Else { Vert pour le 0 }
 If IsRedNumber(num)Then GetNumberColor:=4  { Rouge }
                    Else GetNumberColor:=0; { Noir }
End;

Function GetBetTypeName(betType:TBetType):String;Begin
 Case betType of
  btNumber: GetBetTypeName := 'Numero';
  btRed: GetBetTypeName := 'Rouge';
  btBlack: GetBetTypeName := 'Noir';
  btEven: GetBetTypeName := 'Pair';
  btOdd: GetBetTypeName := 'Impair';
  btLow: GetBetTypeName := '1-18';
  btHigh: GetBetTypeName := '19-36';
  btDozen1: GetBetTypeName := '1ere 12';
  btDozen2: GetBetTypeName := '2eme 12';
  btDozen3: GetBetTypeName := '3eme 12';
 End;
End;

Function GetBetMultiplier(betType:TBetType):Integer;Begin
 Case betType of
  btNumber: GetBetMultiplier := 35;
  btRed, btBlack, btEven, btOdd, btLow, btHigh: GetBetMultiplier := 1;
  btDozen1, btDozen2, btDozen3: GetBetMultiplier := 2;
 End;
End;

Function IsBetWinning(var bet:TBet;winningNum:Integer):Boolean;Begin
 IsBetWinning := False;
 Case bet.betType of
  btNumber: IsBetWinning := (bet.number = winningNum);
  btRed: IsBetWinning := (winningNum > 0) and IsRedNumber(winningNum);
  btBlack: IsBetWinning := (winningNum > 0) and not IsRedNumber(winningNum);
  btEven: IsBetWinning := (winningNum > 0) and (winningNum mod 2 = 0);
  btOdd: IsBetWinning := (winningNum > 0) and (winningNum mod 2 = 1);
  btLow: IsBetWinning := (winningNum >= 1) and (winningNum <= 18);
  btHigh: IsBetWinning := (winningNum >= 19) and (winningNum <= 36);
  btDozen1: IsBetWinning := (winningNum >= 1) and (winningNum <= 12);
  btDozen2: IsBetWinning := (winningNum >= 13) and (winningNum <= 24);
  btDozen3: IsBetWinning := (winningNum >= 25) and (winningNum <= 36);
 End;
End;

Procedure PlaceBet(betType: TBetType; number, amount: Integer);Begin
 If(Game.betCount<MAX_BETS)and(amount<=Game.playerMoney)and(amount>0)Then Begin
  Game.bets[Game.betCount].betType := betType;
  Game.bets[Game.betCount].number := number;
  Game.bets[Game.betCount].amount := amount;
  Game.bets[Game.betCount].active := True;
  Inc(Game.betCount);
  Game.playerMoney := Game.playerMoney - amount;
  Game.needRedraw := True;
 End;
End;

Procedure ClearBets;
Var
 i:Integer;
Begin
 For i := 0 to Game.betCount-1 do If Game.bets[i].active Then
  Game.playerMoney := Game.playerMoney + Game.bets[i].amount;
 Game.betCount:=0;
 Game.needRedraw:=True;
End;

Procedure SpinWheel;Begin
 Randomize;
 Game.winningNumber := Random(37); { 0-36 }
 Game.gameState := gsSpinning;
 Game.spinAnimation := 0;
 Game.needRedraw := True;
End;

Procedure CalculateWinnings;
Var
 i,winnings:Integer;
Begin
 winnings:=0;
 For i := 0 to Game.betCount-1 do
  If Game.bets[i].active and IsBetWinning(Game.bets[i], Game.winningNumber) Then
   winnings := winnings + Game.bets[i].amount * (GetBetMultiplier(Game.bets[i].betType) + 1);
 Game.playerMoney := Game.playerMoney + winnings;
 Game.gameState := gsResult;
 Game.resultTimer := 100; { Afficher rÇsultat pendant 10 secondes }
 Game.needRedraw := True;
End;

Function HandleMouseClick:Boolean;
Var
 mouseX,mouseY,button:LongInt;
 x,y:Integer;
 i:Integer;
 clickedNumber:Integer;
Begin
 HandleMouseClick:=False;
 GetMouseState(mouseX,mouseY,button);
 If button and 1=1 Then Begin { Clic gauche }
  x := 400;  { Position du plateau de mises }
  y := 80;
   { VÇrifier clic sur case 0 }
  If(mouseX>=x)and(mouseX<=x+30)and(mouseY>=y)and(mouseY<=y+60)Then Begin
   PlaceBet(btNumber, 0, Game.currentBet);
   HandleMouseClick := True;
   Exit;
  End;
   { VÇrifier clic sur cases 1-36 }
  For i := 1 to 36 do Begin
   If (mouseX >= x + 35 + ((i-1) mod 3) * 25) and
      (mouseX <= x + 35 + ((i-1) mod 3) * 25 + 25) and
      (mouseY >= y + ((i-1) div 3) * 15) and
      (mouseY <= y + ((i-1) div 3) * 15 + 15)Then Begin
    PlaceBet(btNumber, i, Game.currentBet);
    HandleMouseClick := True;
    Exit;
   End;
  End;
   { VÇrifier clic sur cases des mises extÇrieures }
  y := y + 200;
   { Case ROUGE }
  If(mouseX>=x)and(mouseX<=x+40)and(mouseY>=y)and(mouseY<=y+20)Then Begin
   PlaceBet(btRed, 0, Game.currentBet);
   HandleMouseClick := True;
   Exit;
  End;
   { Case NOIR }
  If(mouseX>=x+45)and(mouseX<=x+85)and(mouseY>=y)and(mouseY<=y+20)Then Begin
   PlaceBet(btBlack, 0, Game.currentBet);
   HandleMouseClick := True;
   Exit;
  End;
   { Case PAIR }
  If(mouseX>=x+90)and(mouseX<=x+130)and(mouseY>=y)and(mouseY<=y+20)Then Begin
   PlaceBet(btEven, 0, Game.currentBet);
   HandleMouseClick := True;
   Exit;
  End;
   { Case IMPAIR }
  If(mouseX>=x+135)and(mouseX<=x+175)and(mouseY>=y)and(mouseY<=y+20)Then Begin
   PlaceBet(btOdd, 0, Game.currentBet);
   HandleMouseClick := True;
   Exit;
  End;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 { GÇrer les clics de souris }
 If (Game.gameState = gsPlacing) and HandleMouseClick Then
  Exit; { Un clic a ÇtÇ traitÇ, pas besoin de vÇrifier le clavier }
 If KeyPressed Then Begin
  key:=ReadKey;
  Case key of
   #0:Begin
    key:=ReadKey;
    Case key of
     #72: Begin { Fläche haut }
      If Game.gameState = gsPlacing Then Begin
       If Game.selectedBetType > btNumber Then Begin
        Game.selectedBetType := TBetType(Ord(Game.selectedBetType) - 1);
        Game.needRedraw := True;
       End;
      End;
     End;
     #80: Begin { Fläche bas }
      If Game.gameState = gsPlacing Then Begin
       If Game.selectedBetType < btDozen3 Then Begin
        Game.selectedBetType := TBetType(Ord(Game.selectedBetType) + 1);
        Game.needRedraw := True;
       End;
      End;
     End;
     #75: Begin { Fläche gauche }
      If (Game.gameState = gsPlacing) and (Game.selectedBetType = btNumber) Then
      Begin
       If Game.selectedNumber > 0 Then Begin
        Dec(Game.selectedNumber);
        Game.needRedraw := True;
       End;
      End;
     End;
     #77: Begin { Fläche droite }
      If (Game.gameState = gsPlacing) and (Game.selectedBetType = btNumber) Then
      Begin
       If Game.selectedNumber < 36 Then Begin
        Inc(Game.selectedNumber);
        Game.needRedraw := True;
       End;
      End;
     End;
    End;
   End;
   '1'..'9': Begin { Miser 1-9 }
    If Game.gameState = gsPlacing Then Begin
     Game.currentBet := Ord(key) - Ord('0');
     Game.needRedraw := True;
    End;
   End;
   '+': Begin { Augmenter mise }
    If Game.gameState = gsPlacing Then Begin
     If Game.currentBet < 100 Then
      Game.currentBet := Game.currentBet + 5;
     Game.needRedraw := True;
    End;
   End;
   '-': Begin { Diminuer mise }
    If Game.gameState = gsPlacing Then Begin
     If Game.currentBet > 1 Then
      Game.currentBet := Game.currentBet - 5;
     Game.needRedraw := True;
    End;
   End;
   #13: Begin { Entr√©e }
    Case Game.gameState of
     gsPlacing: Begin
      If Game.selectedBetType = btNumber Then
       PlaceBet(Game.selectedBetType, Game.selectedNumber, Game.currentBet)
      Else
       PlaceBet(Game.selectedBetType, 0, Game.currentBet);
     End;
     gsResult: Begin
      Game.betCount := 0;
      Game.gameState := gsPlacing;
      Game.needRedraw := True;
     End;
    End;
   End;
   's', 'S': Begin { Lancer }
    If (Game.gameState = gsPlacing) and (Game.betCount > 0) Then
     SpinWheel;
   End;
   'c', 'C': Begin { Effacer mises }
    If Game.gameState = gsPlacing Then
     ClearBets;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitializeGame;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Function HasBetOnNumber(number:Integer):Boolean;
Var
 i:Integer;
Begin
 HasBetOnNumber := False;
 For i := 0 to Game.betCount-1 do
  If Game.bets[i].active and (Game.bets[i].betType = btNumber) and (Game.bets[i].number = number) Then
  Begin
   HasBetOnNumber := True;
   Exit;
  End;
End;

Function HasBetOnType(betType: TBetType): Boolean;
Var
 i: Integer;
Begin
 HasBetOnType := False;
 For i := 0 to Game.betCount-1 do
  If Game.bets[i].active and (Game.bets[i].betType = betType) Then
  Begin
   HasBetOnType := True;
   Exit;
  End;
End;

Procedure DrawRouletteWheel;
Var
 i,x,y,angle:Integer;
 numStr:String;
Begin
 x := 230;  { DÇplacÇ de 80 pixels vers la droite (150 + 80) }
 y := 150;
  { Roue principale }
 SetColor(8);
 SetFillStyle(1, 8);
 FillEllipse(x, y, 80, 80);
  { Cercle intÇrieur }
 SetColor(0);
 SetFillStyle(1, 0);
 FillEllipse(x, y, 60, 60);
  { NumÇros sur la roue }
 For i := 0 to 36 do Begin
  angle := (i * 360) div 37;
  SetColor(GetNumberColor(i));
  If GetNumberColor(i) = 0 Then
   SetColor(15); { Blanc pour lisibilitÇ sur noir }
  Str(i, numStr);
  SetTextStyle(0, 0, 1);
  OutTextXY(x + Round(40 * Cos(angle * Pi / 180)) - 4,
           y + Round(40 * Sin(angle * Pi / 180)) - 4, numStr);
 End;
  { Animation de rotation pendant le spin }
 If Game.gameState = gsSpinning Then Begin
  SetColor(14);
  SetFillStyle(1, 14);
  FillEllipse(x + Random(6) - 3, y + Random(6) - 3, 5, 5);
 End;
  { Bille sur num√©ro gagnant }
 If Game.gameState = gsResult Then Begin
  angle := (Game.winningNumber * 360) div 37;
  SetColor(15);
  SetFillStyle(1, 15);
  FillEllipse(x + Round(40 * Cos(angle * Pi / 180)),
             y + Round(40 * Sin(angle * Pi / 180)), 3, 3);
 End;
End;

Procedure DrawBettingGrid;
Var
 i,x,y:Integer;
 numStr:String;
Begin
 x := 400;  { DÇplacÇ de 80 pixels vers la droite (320 + 80) }
 y := 80;
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(x, y - 20, 'PLATEAU DE MISES');
  { Cases des numÇros 1-36 + 0 }
 For i := 0 to 36 do Begin
  If i = 0 Then Begin
   { Case 0 spÇciale }
   If HasBetOnNumber(0) Then Begin
    SetColor(14);  { Jaune si mise placÇe }
    SetFillStyle(1, 14);
   End
    Else
   Begin
    SetColor(2);   { Vert normal }
    SetFillStyle(1, 2);
   End;
   Bar(x, y, x + 30, y + 60);
   SetColor(15);
   Rectangle(x, y, x + 30, y + 60);
   SetColor(0);  { Texte noir pour lisibilit√© }
   OutTextXY(x + 12, y + 25, '0');
  End
   Else
  Begin
   { Cases 1-36 }
   If HasBetOnNumber(i) Then Begin
    SetColor(14);  { Jaune si mise placÇe }
    SetFillStyle(1, 14);
   End
    Else
   Begin
    SetColor(GetNumberColor(i));  { Couleur normale (rouge/noir) }
    SetFillStyle(1, GetNumberColor(i));
   End;
   Bar(x + 35 + ((i-1) mod 3) * 25, y + ((i-1) div 3) * 15,
       x + 35 + ((i-1) mod 3) * 25 + 25, y + ((i-1) div 3) * 15 + 15);
   SetColor(15);
   Rectangle(x + 35 + ((i-1) mod 3) * 25, y + ((i-1) div 3) * 15,
            x + 35 + ((i-1) mod 3) * 25 + 25, y + ((i-1) div 3) * 15 + 15);
    { Couleur du texte selon le fond }
   If HasBetOnNumber(i) Then SetColor(0) Else { Texte noir sur fond jaune }
   If GetNumberColor(i)=0 Then SetColor(15) { Texte blanc sur fond noir }
                          Else SetColor(15); { Texte blanc sur fond rouge }
   Str(i, numStr);
   OutTextXY(x + 35 + ((i-1) mod 3) * 25 + 8, y + ((i-1) div 3) * 15 + 5, numStr);
  End;
 End;
  { Cases des mises ext√©rieures }
 y := y + 200;
  { Case ROUGE }
 If HasBetOnType(btRed) Then Begin
  SetColor(14);  { Jaune si mise placÇe }
  SetFillStyle(1, 14);
 End
  Else
 Begin
  SetColor(4);   { Rouge normal }
  SetFillStyle(1, 4);
 End;
 Bar(x, y, x + 40, y + 20);
 SetColor(15);
 Rectangle(x, y, x + 40, y + 20);
 If HasBetOnType(btRed)Then SetColor(0)   { Texte noir sur fond jaune }
                       Else SetColor(15); { Texte blanc sur fond rouge }
 OutTextXY(x + 8, y + 8, 'ROUGE');
  { Case NOIR }
 If HasBetOnType(btBlack) Then Begin
  SetColor(14);  { Jaune si mise placÇe }
  SetFillStyle(1, 14);
 End
  Else
 Begin
  SetColor(0);   { Noir normal }
  SetFillStyle(1, 0);
 End;
 Bar(x + 45, y, x + 85, y + 20);
 SetColor(15);
 Rectangle(x + 45, y, x + 85, y + 20);
 If HasBetOnType(btBlack)Then SetColor(0)   { Texte noir sur fond jaune }
                         Else SetColor(15); { Texte blanc sur fond noir }
 OutTextXY(x + 53, y + 8, 'NOIR');
  { Case PAIR }
 If HasBetOnType(btEven) Then Begin
  SetColor(14);  { Jaune si mise placÇe }
  SetFillStyle(1, 14);
 End
  Else
 Begin
  SetColor(7);   { Gris normal }
  SetFillStyle(1, 7);
 End;
 Bar(x + 90, y, x + 130, y + 20);
 SetColor(0);
 Rectangle(x + 90, y, x + 130, y + 20);
 OutTextXY(x + 98, y + 8, 'PAIR');
  { Case IMPAIR }
 If HasBetOnType(btOdd) Then Begin
  SetColor(14);  { Jaune si mise placÇe }
  SetFillStyle(1, 14);
 End
  Else
 Begin
  SetColor(7);   { Gris normal }
  SetFillStyle(1, 7);
 End;
 Bar(x + 135, y, x + 175, y + 20);
 SetColor(0);
 Rectangle(x + 135, y, x + 175, y + 20);
 OutTextXY(x + 140, y + 8, 'IMPAIR');
End;

Procedure DrawGameInfo;
Var
 moneyStr,betStr:String;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 Str(Game.playerMoney, moneyStr);
 OutTextXY(50, 50, 'Argent: ' + moneyStr + ' euros');
 Str(Game.currentBet, betStr);
 OutTextXY(50, 70, 'Mise: ' + betStr + ' euros');
 OutTextXY(50, 90, 'Type: ' + GetBetTypeName(Game.selectedBetType));
 If Game.selectedBetType = btNumber Then Begin
  Str(Game.selectedNumber, betStr);
  OutTextXY(50, 110, 'Numero: ' + betStr);
 End;
End;

Procedure DrawBets;
Var
 i, y:Integer;
 betStr,amountStr:String;
Begin
 If Game.betCount > 0 Then Begin
  SetColor(14);
  SetTextStyle(0, 0, 1);
  OutTextXY(50, 280, 'VOS MISES:');
  y := 300;
  For i := 0 to Game.betCount-1 do If Game.bets[i].active Then Begin
   betStr := GetBetTypeName(Game.bets[i].betType);
   If Game.bets[i].betType = btNumber Then Begin
    Str(Game.bets[i].number, amountStr);
    betStr := betStr + ' ' + amountStr;
   End;
   Str(Game.bets[i].amount, amountStr);
   betStr := betStr + ': ' + amountStr + ' euros';
    { Mettre en √©vidence les mises gagnantes }
   If (Game.gameState = gsResult) and IsBetWinning(Game.bets[i], Game.winningNumber) Then
    SetColor(10)
   Else
    SetColor(15);
   OutTextXY(50, y, betStr);
   y := y + 15;
  End;
 End;
End;

Procedure DrawInstructions;Begin
 SetColor(11);
 SetTextStyle(0, 0, 1);
 OutTextXY(320, 320, 'COMMANDES:');
 OutTextXY(320, 340, 'Fleches: Choisir type/numero');
 OutTextXY(320, 355, '1-9: Mise rapide');
 OutTextXY(320, 370, '+/-: Ajuster mise');
 OutTextXY(320, 385, 'ENTREE: Placer mise');
 OutTextXY(320, 400, 'S: Lancer la bille');
 OutTextXY(320, 415, 'C: Effacer mises');
 OutTextXY(320, 430, 'N: Nouvelle partie');
 OutTextXY(320, 445, 'ESC: Quitter');
 SetColor(10);
 OutTextXY(320, 460, 'SOURIS: Cliquer sur cases');
End;

Procedure DrawGameStatus;
Var
 numStr:String;
Begin
 SetColor(14);
 SetTextStyle(0, 0, 2);
 Case Game.gameState of
  gsPlacing: Begin
   OutTextXY(50, 250, 'Placez vos mises!');
  End;
  gsSpinning: Begin
   OutTextXY(50, 250, 'La bille tourne...');
  End;
  gsResult: Begin
   Str(Game.winningNumber, numStr);
   OutTextXY(50, 250, 'Numero gagnant: ' + numStr);
   SetColor(GetNumberColor(Game.winningNumber));
   If GetNumberColor(Game.winningNumber) = 0 Then SetColor(15);
   If Game.winningNumber = 0 Then OutTextXY(50, 270, '(ZERO - Vert)')  Else
   If IsRedNumber(Game.winningNumber)Then OutTextXY(50, 270, '(Rouge)')
                                     Else OutTextXY(50, 270, '(Noir)');
  End;
 End;
End;

Procedure Update;Begin
 Case Game.gameState of
  gsSpinning:Begin
   Inc(Game.spinAnimation);
   If Game.spinAnimation > 30 Then { Animation pendant 3 secondes }
    CalculateWinnings;
   Game.needRedraw := True;
  End;
  gsResult:Begin
   Dec(Game.resultTimer);
   If Game.resultTimer <= 0 Then Begin
    Game.betCount := 0;
    Game.gameState := gsPlacing;
    Game.needRedraw := True;
   End;
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  HideMouse; { Masquer la souris pendant le rendu }
   { Fond }
  SetColor(2);
  SetFillStyle(1, 2);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
   { Titre }
  SetColor(14);
  SetTextStyle(0, 0, 2);
  OutTextXY(50, 20, 'ROULETTE CASINO');
  DrawRouletteWheel;
  DrawBettingGrid;
  DrawGameInfo;
  DrawBets;
  DrawInstructions;
  DrawGameStatus;
  Game.needRedraw := False;
  ShowMouse; { RÇafficher la souris apräs le rendu }
 End;
End;

Procedure ShowTitle;Begin
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 SetColor(14);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 150, 80, 'ROULETTE CASINO');
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 160, 'Bienvenue au casino! Placez vos mises et tentez votre chance.');
 OutTextXY(50, 200, 'Types de mises:');
 OutTextXY(50, 220, '- Numero (0-36): Paye 35 contre 1');
 OutTextXY(50, 240, '- Rouge/Noir: Paye 1 contre 1');
 OutTextXY(50, 260, '- Pair/Impair: Paye 1 contre 1');
 OutTextXY(50, 280, '- 1-18/19-36: Paye 1 contre 1');
 OutTextXY(50, 300, '- Douzaines (1-12, 13-24, 25-36): Paye 2 contre 1');
 SetColor(11);
 OutTextXY(50, 340, 'Vous commencez avec 1000 euros.');
 OutTextXY(50, 360, 'Utilisez les fleches pour naviguer dans les options.');
 OutTextXY(50, 380, 'Placez vos mises puis appuyez sur S pour lancer!');
 OutTextXY(50, 420, 'Appuyez sur ENTREE pour commencer...');
 OutTextXY(50, 440, 'ESC pour quitter');
 Repeat
  If KeyPressed Then Begin
   Case ReadKey of
    #13: Exit;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure InitializeGame;Begin
 Game.playerMoney := STARTING_MONEY;
 Game.currentBet := 10;
 Game.betCount := 0;
 Game.selectedBetType := btNumber;
 Game.selectedNumber := 1;
 Game.winningNumber := 0;
 Game.gameState := gsPlacing;
 Game.needRedraw := True;
 Game.spinAnimation := 0;
 Game.resultTimer := 0;
End;

Procedure GameLoop;Begin
 While Game.gameState <> gsQuit do Begin
  HandleInput;
  Update;
  Render;
  Delay(100);
   { VÇrifier si le joueur a perdu tout son argent }
  If (Game.playerMoney <= 0) and (Game.betCount = 0) Then Begin
   SetColor(12);
   SetTextStyle(0, 0, 2);
   OutTextXY(200, 200, 'GAME OVER!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(150, 230, 'Vous avez perdu tout votre argent!');
   OutTextXY(150, 250, 'Appuyez sur N pour rejouer...');
   Repeat
    If KeyPressed Then Begin
     Case ReadKey of
      'n', 'N':Begin
       InitializeGame;
       Break;
      End;
      #27:Begin
       Game.gameState := gsQuit;
       Break;
      End;
     End;
    End;
    Delay(100);
   Until False;
  End;
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
 ErrCode := GraphResult;
 If ErrCode <> grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
 SetLineStyle(0, 0, 1);
 {$IFNDEF FPC}
 { Initialiser la souris si disponible }
 If MouseDriverFound Then
  ShowMouse;
 {$ENDIF}
End;

BEGIN
 InitializeRedNumbers;
 InitializeGraphics;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.
