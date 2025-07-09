{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu MasterMind - Devinez la combinaison secrète de couleurs
}

Program MasterMind;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 MAX_ATTEMPTS = 10;
 CODE_LENGTH = 4;
 NUM_COLORS = 6;

 { Couleurs disponibles }
 COLOR_RED = 4;
 COLOR_GREEN = 2;
 COLOR_BLUE = 1;
 COLOR_YELLOW = 14;
 COLOR_MAGENTA = 5;
 COLOR_CYAN = 3;

 PEG_SIZE = 30;
 FEEDBACK_SIZE = 15;

Type
 TCode = Array[0..CODE_LENGTH-1] of Integer;
 TGameState = (gsPlaying, gsWon, gsLost, gsQuit);

 TGame = Record
  secretCode: TCode;
  attempts: Array[0..MAX_ATTEMPTS-1] of TCode;
  feedback: Array[0..MAX_ATTEMPTS-1, 0..CODE_LENGTH-1] of Integer;
  currentAttempt: Integer;
  currentPosition: Integer;
  gameState: TGameState;
  needRedraw: Boolean;
 End;

Var
 Game: TGame;
 Colors: Array[0..NUM_COLORS-1] of Integer;

Procedure InitializeColors;
Begin
 Colors[0] := COLOR_RED;
 Colors[1] := COLOR_GREEN;
 Colors[2] := COLOR_BLUE;
 Colors[3] := COLOR_YELLOW;
 Colors[4] := COLOR_MAGENTA;
 Colors[5] := COLOR_CYAN;
End;

Procedure GenerateSecretCode;
Var
 i: Integer;
Begin
 Randomize;
 For i := 0 to CODE_LENGTH-1 do
  Game.secretCode[i] := Random(NUM_COLORS);
End;

Procedure InitializeGame;
Var
 i, j: Integer;
Begin
 GenerateSecretCode;
 Game.currentAttempt := 0;
 Game.currentPosition := 0;
 Game.gameState := gsPlaying;
 Game.needRedraw := True;

 { Initialiser les tentatives }
 For i := 0 to MAX_ATTEMPTS-1 do
 Begin
  For j := 0 to CODE_LENGTH-1 do
  Begin
   Game.attempts[i][j] := -1;
   Game.feedback[i][j] := 0;
  End;
 End;
End;

Procedure CalculateFeedback(attempt: Integer);
Var
 i, j: Integer;
 correctPosition, correctColor: Integer;
 secretUsed, attemptUsed: Array[0..CODE_LENGTH-1] of Boolean;
Begin
 correctPosition := 0;
 correctColor := 0;

 { Initialiser les tableaux d'utilisation }
 For i := 0 to CODE_LENGTH-1 do
 Begin
  secretUsed[i] := False;
  attemptUsed[i] := False;
 End;

 { Vérifier les bonnes positions }
 For i := 0 to CODE_LENGTH-1 do
 Begin
  If Game.attempts[attempt][i] = Game.secretCode[i] Then
  Begin
   Inc(correctPosition);
   secretUsed[i] := True;
   attemptUsed[i] := True;
  End;
 End;

 { Vérifier les bonnes couleurs mal placées }
 For i := 0 to CODE_LENGTH-1 do
 Begin
  If Not attemptUsed[i] Then
  Begin
   For j := 0 to CODE_LENGTH-1 do
   Begin
    If (Not secretUsed[j]) and
       (Game.attempts[attempt][i] = Game.secretCode[j]) Then
    Begin
     Inc(correctColor);
     secretUsed[j] := True;
     Break;
    End;
   End;
  End;
 End;

 { Stocker le feedback }
 For i := 0 to correctPosition-1 do
  Game.feedback[attempt][i] := 2; { Noir - bonne position }
 For i := correctPosition to correctPosition + correctColor - 1 do
  Game.feedback[attempt][i] := 1; { Blanc - bonne couleur }
End;

Function IsCodeComplete: Boolean;
Var
 i: Integer;
Begin
 IsCodeComplete := True;
 For i := 0 to CODE_LENGTH-1 do
 Begin
  If Game.attempts[Game.currentAttempt][i] = -1 Then
  Begin
   IsCodeComplete := False;
   Exit;
  End;
 End;
End;

Function IsWinningCode: Boolean;
Var
 i: Integer;
Begin
 IsWinningCode := True;
 For i := 0 to CODE_LENGTH-1 do
 Begin
  If Game.attempts[Game.currentAttempt][i] <> Game.secretCode[i] Then
  Begin
   IsWinningCode := False;
   Exit;
  End;
 End;
End;

Procedure HandleInput;
Var
 key: Char;
Begin
 If KeyPressed Then
 Begin
  key := ReadKey;
  Case key of
   '1'..'6': Begin
    If Game.gameState = gsPlaying Then
    Begin
     Game.attempts[Game.currentAttempt][Game.currentPosition] := Ord(key) - Ord('1');
     Inc(Game.currentPosition);
     If Game.currentPosition >= CODE_LENGTH Then
      Game.currentPosition := CODE_LENGTH - 1;
     Game.needRedraw := True;
    End;
   End;
   #8: Begin { Backspace }
    If (Game.gameState = gsPlaying) and (Game.currentPosition > 0) Then
    Begin
     Dec(Game.currentPosition);
     Game.attempts[Game.currentAttempt][Game.currentPosition] := -1;
     Game.needRedraw := True;
    End;
   End;
   #13: Begin { Entrée }
    If (Game.gameState = gsPlaying) and IsCodeComplete Then
    Begin
     CalculateFeedback(Game.currentAttempt);

     If IsWinningCode Then
      Game.gameState := gsWon
     Else
     Begin
      Inc(Game.currentAttempt);
      Game.currentPosition := 0;

      If Game.currentAttempt >= MAX_ATTEMPTS Then
       Game.gameState := gsLost;
     End;
     Game.needRedraw := True;
    End;
   End;
   'n', 'N': Begin
    If Game.gameState in [gsWon, gsLost] Then
    Begin
     InitializeGame;
     Game.needRedraw := True;
    End;
   End;
   #27: Game.gameState := gsQuit; { ESC }
  End;
 End;
End;

Procedure DrawPeg(x, y, colorIndex: Integer);
Begin
 If colorIndex >= 0 Then
 Begin
  SetColor(Colors[colorIndex]);
  SetFillStyle(1, Colors[colorIndex]);
  FillEllipse(x, y, PEG_SIZE div 2, PEG_SIZE div 2);
  SetColor(0);
  Circle(x, y, PEG_SIZE div 2);
 End
 Else
 Begin
  SetColor(8);
  SetFillStyle(1, 8);
  FillEllipse(x, y, PEG_SIZE div 2, PEG_SIZE div 2);
  SetColor(15);
  Circle(x, y, PEG_SIZE div 2);
 End;
End;

Procedure DrawFeedbackPeg(x, y, feedbackType: Integer);
Begin
 Case feedbackType of
  2: Begin { Noir - bonne position }
   SetColor(0);
   SetFillStyle(1, 0);
  End;
  1: Begin { Blanc - bonne couleur }
   SetColor(15);
   SetFillStyle(1, 15);
  End;
  Else Begin { Vide }
   SetColor(8);
   SetFillStyle(1, 8);
  End;
 End;

 FillEllipse(x, y, FEEDBACK_SIZE div 2, FEEDBACK_SIZE div 2);
 SetColor(7);
 Circle(x, y, FEEDBACK_SIZE div 2);
End;

Procedure DrawAttempt(attemptNum: Integer);
Var
 i: Integer;
 x, y: Integer;
Begin
 y := 60 + attemptNum * 40;

 { Dessiner le numéro de tentative }
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(10, y - 5, Chr(Ord('1') + attemptNum));

 { Dessiner les pegs de la tentative }
 For i := 0 to CODE_LENGTH-1 do
 Begin
  x := 50 + i * 40;
  DrawPeg(x, y, Game.attempts[attemptNum][i]);
 End;

 { Dessiner le feedback }
 For i := 0 to CODE_LENGTH-1 do
 Begin
  x := 250 + (i mod 2) * 20;
  y := 55 + attemptNum * 40 + (i div 2) * 20;
  DrawFeedbackPeg(x, y, Game.feedback[attemptNum][i]);
 End;
End;

Procedure DrawCurrentAttempt;
Var
 i: Integer;
 x, y: Integer;
Begin
 If Game.gameState = gsPlaying Then
 Begin
  y := 60 + Game.currentAttempt * 40;

  { Dessiner le numéro de tentative }
  SetColor(14);
  SetTextStyle(0, 0, 1);
  OutTextXY(10, y - 5, Chr(Ord('1') + Game.currentAttempt));

  { Dessiner les pegs de la tentative courante }
  For i := 0 to CODE_LENGTH-1 do
  Begin
   x := 50 + i * 40;
   DrawPeg(x, y, Game.attempts[Game.currentAttempt][i]);

   { Surbrillance pour la position courante }
   If i = Game.currentPosition Then
   Begin
    SetColor(14);
    Circle(x, y, PEG_SIZE div 2 + 2);
   End;
  End;
 End;
End;

Procedure DrawColorPalette;
Var
 i: Integer;
 x, y: Integer;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(350, 50, 'Couleurs disponibles:');

 For i := 0 to NUM_COLORS-1 do
 Begin
  x := 350 + (i mod 3) * 50;
  y := 80 + (i div 3) * 50;
  DrawPeg(x, y, i);

  { Afficher le numéro }
  SetColor(15);
  OutTextXY(x - 5, y + 25, Chr(Ord('1') + i));
 End;
End;

Procedure DrawSecretCode;
Var
 i: Integer;
 x: Integer;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 0, 'Code secret:');

 For i := 0 to CODE_LENGTH-1 do
 Begin
  x := 50 + i * 40;
  If Game.gameState in [gsWon, gsLost] Then
   DrawPeg(x, 30, Game.secretCode[i])
  Else
  Begin
   SetColor(0);
   SetFillStyle(1, 0);
   FillEllipse(x, 30, PEG_SIZE div 2, PEG_SIZE div 2);
   SetColor(15);
   Circle(x, 30, PEG_SIZE div 2);
   OutTextXY(x - 5, 25, '?');
  End;
 End;
End;

Procedure DrawInstructions;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(350, 200, 'Instructions:');
 OutTextXY(350, 220, '1-6: Choisir couleur');
 OutTextXY(350, 240, 'Retour: Effacer');
 OutTextXY(350, 260, 'Entrée: Valider');
 OutTextXY(350, 280, 'ESC: Quitter');

 SetColor(12);
 OutTextXY(350, 320, 'Feedback:');
 DrawFeedbackPeg(350, 340, 2);
 OutTextXY(370, 335, 'Bonne position');
 DrawFeedbackPeg(350, 360, 1);
 OutTextXY(370, 355, 'Bonne couleur');
End;

Procedure DrawGameStatus;
Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);

 Case Game.gameState of
  gsPlaying: Begin
   OutTextXY(350, 400, 'Tentative: ' + Chr(Ord('1') + Game.currentAttempt));
   OutTextXY(350, 420, 'Position: ' + Chr(Ord('1') + Game.currentPosition));
  End;
  gsWon: Begin
   SetColor(10);
   SetTextStyle(0, 0, 2);
   OutTextXY(350, 400, 'GAGNE!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(350, 430, 'N: Nouvelle partie');
  End;
  gsLost: Begin
   SetColor(12);
   SetTextStyle(0, 0, 2);
   OutTextXY(350, 400, 'PERDU!');
   SetColor(15);
   SetTextStyle(0, 0, 1);
   OutTextXY(350, 430, 'N: Nouvelle partie');
  End;
 End;
End;

Procedure Render;
Var
 i: Integer;
Begin
 If Game.needRedraw Then
 Begin
  { Fond noir }
  SetColor(0);
  SetFillStyle(1, 0);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  DrawSecretCode;
  DrawColorPalette;
  DrawInstructions;
  DrawGameStatus;

  { Dessiner toutes les tentatives }
  For i := 0 to Game.currentAttempt-1 do
   DrawAttempt(i);

  { Dessiner la tentative courante }
  DrawCurrentAttempt;

  Game.needRedraw := False;
 End;
End;

Procedure ShowTitle;
Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

 SetColor(14);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 100, 'MASTERMIND');

 SetColor(15);
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 200, 'Devinez la combinaison secrète de 4 couleurs.');
 OutTextXY(50, 220, 'Vous avez 10 tentatives.');
 OutTextXY(50, 240, 'Utilisez les chiffres 1-6 pour choisir les couleurs.');
 OutTextXY(50, 260, 'Un peg noir indique une couleur à la bonne position.');
 OutTextXY(50, 280, 'Un peg blanc indique une bonne couleur mal placée.');

 OutTextXY(50, 320, 'Appuyez sur ENTRÉE pour commencer...');
 OutTextXY(50, 340, 'ESC pour quitter');

 Repeat
  If KeyPressed Then
  Begin
   Case ReadKey of
    #13: Exit;
    #27: Halt;
   End;
  End;
  Delay(50);
 Until False;
End;

Procedure GameLoop;
Begin
 While Game.gameState <> gsQuit do
 Begin
  HandleInput;
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
 ErrCode := GraphResult;
 If ErrCode <> grOk Then
 Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;

 SetLineStyle(0, 0, 1);
End;

BEGIN
 InitializeGraphics;
 InitializeColors;
 ShowTitle;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.
