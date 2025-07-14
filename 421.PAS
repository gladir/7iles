{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: 421 - Jeu de dÇs traditionnel franáais
  L'objectif est d'obtenir la combinaison 4-2-1 ou d'autres combinaisons spÇciales
}

Program Game421;

Uses {$IFDEF FPC}
      PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 DIE_SIZE = 60;
 MAX_PLAYERS = 4;
 MAX_ROUNDS = 11;
 STARTING_TOKENS = 21;

 { Scores des combinaisons }
 SCORE_421 = 10;
 SCORE_111 = 8;
 SCORE_666 = 8;
 SCORE_555 = 8;
 SCORE_444 = 8;
 SCORE_333 = 8;
 SCORE_222 = 8;
 SCORE_654 = 6;
 SCORE_543 = 6;
 SCORE_432 = 6;
 SCORE_321 = 6;

 { êtats du jeu }
 GAME_INIT = 0;
 GAME_ROLLING = 1;
 GAME_SCORING = 2;
 GAME_ROUND_END = 3;
 GAME_OVER = 4;

Type
 TDie = Record
  Value: Integer;
  X, Y: Integer;
  Selected: Boolean;
 End;

 TPlayer = Record
  Name: String;
  Tokens: Integer;
  Score: Integer;
  IsHuman: Boolean;
  IsActive: Boolean;
  Dice: Array[1..3] of TDie;
  RollsLeft: Integer;
  CurrentScore: Integer;
 End;

 TGameState = Record
  Players: Array[0..MAX_PLAYERS-1] of TPlayer;
  CurrentPlayer: Integer;
  PlayerCount: Integer;
  Round: Integer;
  GamePhase: Integer;
  Winner: Integer;
  ShowResults: Boolean;
  NeedRedraw: Boolean;
  AnimationDelay: Integer;
 End;

Var
 Game: TGameState;

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs: Registers;
 Begin
  Regs.AX := 0;
  Intr($33, Regs);
  MouseDriverFound := Regs.AX = $FFFF;
 End;

 Procedure ShowMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0001;
  Intr($33, Regs);
 End;

 Procedure HideMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0002;
  Intr($33, Regs);
 End;

 Procedure GetMouseState(Var X, Y, Button: LongInt);
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0003;
  Intr($33, Regs);
  Button := Regs.BX;
  X := Regs.CX;
  Y := Regs.DX;
 End;
{$ELSE}
 Function MouseDriverFound:Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse; Begin
  { Pas d'implÇmentation pour Free Pascal }
 End;

 Procedure HideMouse; Begin
  { Pas d'implÇmentation pour Free Pascal }
 End;
{$ENDIF}

Procedure InitScreen;
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
  Halt(1);
 End;
End;

Procedure DrawDie(X, Y: Integer; Value: Integer; Selected: Boolean);Begin
  { Fond du dÇ }
 If Selected Then SetColor(Yellow) Else SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + DIE_SIZE, Y + DIE_SIZE);
  { Bordure }
 If Selected Then SetColor(Red) Else SetColor(Black);
 Rectangle(X, Y, X + DIE_SIZE, Y + DIE_SIZE);
  { Dessiner les points selon la valeur }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Case Value of
  1: Begin
   { Centre }
   FillEllipse(X + DIE_SIZE Div 2, Y + DIE_SIZE Div 2, 4, 4);
  End;
  2: Begin
   { Diagonale }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 45, Y + 45, 4, 4);
  End;
  3: Begin
   { Diagonale + centre }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + DIE_SIZE Div 2, Y + DIE_SIZE Div 2, 4, 4);
   FillEllipse(X + 45, Y + 45, 4, 4);
  End;
  4: Begin
   { Quatre coins }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 45, Y + 15, 4, 4);
   FillEllipse(X + 15, Y + 45, 4, 4);
   FillEllipse(X + 45, Y + 45, 4, 4);
  End;
  5: Begin
   { Quatre coins + centre }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 45, Y + 15, 4, 4);
   FillEllipse(X + DIE_SIZE Div 2, Y + DIE_SIZE Div 2, 4, 4);
   FillEllipse(X + 15, Y + 45, 4, 4);
   FillEllipse(X + 45, Y + 45, 4, 4);
  End;
  6: Begin
   { Deux colonnes }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 45, Y + 15, 4, 4);
   FillEllipse(X + 15, Y + 30, 4, 4);
   FillEllipse(X + 45, Y + 30, 4, 4);
   FillEllipse(X + 15, Y + 45, 4, 4);
   FillEllipse(X + 45, Y + 45, 4, 4);
  End;
 End;
End;

Procedure DrawPlayerDice(PlayerIndex: Integer);
Var
 I: Integer;
 StartX, StartY: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Then Exit;
  { Position des dÇs selon le joueur }
 Case PlayerIndex of
  0: Begin { Joueur humain - en bas }
   StartX := 250;
   StartY := 350;
  End;
  1: Begin { Joueur 2 - en haut }
   StartX := 250;
   StartY := 100;
  End;
  2: Begin { Joueur 3 - A droite }
   StartX := 520;
   StartY := 200;
  End;
  3: Begin { Joueur 4 - A gauche }
   StartX := 50;
   StartY := 200;
  End;
 End;
 { Dessiner les trois dÇs }
 For I := 1 to 3 Do Begin
  Game.Players[PlayerIndex].Dice[I].X := StartX + (I-1) * (DIE_SIZE + 10);
  Game.Players[PlayerIndex].Dice[I].Y := StartY;
  DrawDie(Game.Players[PlayerIndex].Dice[I].X,
          Game.Players[PlayerIndex].Dice[I].Y,
          Game.Players[PlayerIndex].Dice[I].Value,
          Game.Players[PlayerIndex].Dice[I].Selected);
 End;
End;

Function CalculateScore(PlayerIndex: Integer): Integer;
Var
 D1, D2, D3: Integer;
 Score: Integer;
Begin
 Score := 0;
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Then Begin
  CalculateScore := Score;
  Exit;
 End;
 D1 := Game.Players[PlayerIndex].Dice[1].Value;
 D2 := Game.Players[PlayerIndex].Dice[2].Value;
 D3 := Game.Players[PlayerIndex].Dice[3].Value;
 { Trier les dÇs }
 If D1 > D2 Then Begin
  Score := D1; D1 := D2; D2 := Score;
 End;
 If D2 > D3 Then Begin
  Score := D2; D2 := D3; D3 := Score;
 End;
 If D1 > D2 Then Begin
  Score := D1; D1 := D2; D2 := Score;
 End;
 { VÇrifier les combinaisons spÇciales }
 If (D1 = 1) And (D2 = 2) And (D3 = 4) Then Score := SCORE_421
 Else If (D1 = 1) And (D2 = 1) And (D3 = 1) Then Score := SCORE_111
 Else If (D1 = 6) And (D2 = 6) And (D3 = 6) Then Score := SCORE_666
 Else If (D1 = 5) And (D2 = 5) And (D3 = 5) Then Score := SCORE_555
 Else If (D1 = 4) And (D2 = 4) And (D3 = 4) Then Score := SCORE_444
 Else If (D1 = 3) And (D2 = 3) And (D3 = 3) Then Score := SCORE_333
 Else If (D1 = 2) And (D2 = 2) And (D3 = 2) Then Score := SCORE_222
 Else If (D1 = 4) And (D2 = 5) And (D3 = 6) Then Score := SCORE_654
 Else If (D1 = 3) And (D2 = 4) And (D3 = 5) Then Score := SCORE_543
 Else If (D1 = 2) And (D2 = 3) And (D3 = 4) Then Score := SCORE_432
 Else If (D1 = 1) And (D2 = 2) And (D3 = 3) Then Score := SCORE_321
 Else Begin
  { Compter les 1 (as) }
  Score := 0;
  If D1 = 1 Then Inc(Score);
  If D2 = 1 Then Inc(Score);
  If D3 = 1 Then Inc(Score);
 End;
 CalculateScore := Score;
End;

Function GetScoreDescription(PlayerIndex: Integer): String;
Var
 D1, D2, D3, Score: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Then Begin
  GetScoreDescription := 'Invalide';
  Exit;
 End;

 D1 := Game.Players[PlayerIndex].Dice[1].Value;
 D2 := Game.Players[PlayerIndex].Dice[2].Value;
 D3 := Game.Players[PlayerIndex].Dice[3].Value;

 { Trier les dÇs }
 If D1 > D2 Then Begin
  Score := D1; D1 := D2; D2 := Score;
 End;
 If D2 > D3 Then Begin
  Score := D2; D2 := D3; D3 := Score;
 End;
 If D1 > D2 Then Begin
  Score := D1; D1 := D2; D2 := Score;
 End;

 { V√©rifier les combinaisons sp√©ciales }
 If (D1 = 1) And (D2 = 2) And (D3 = 4) Then GetScoreDescription := '421 - Meilleure main!'
 Else If (D1 = 1) And (D2 = 1) And (D3 = 1) Then GetScoreDescription := '111 - Brelans d''as'
 Else If (D1 = 6) And (D2 = 6) And (D3 = 6) Then GetScoreDescription := '666 - Brelans de 6'
 Else If (D1 = 5) And (D2 = 5) And (D3 = 5) Then GetScoreDescription := '555 - Brelans de 5'
 Else If (D1 = 4) And (D2 = 4) And (D3 = 4) Then GetScoreDescription := '444 - Brelans de 4'
 Else If (D1 = 3) And (D2 = 3) And (D3 = 3) Then GetScoreDescription := '333 - Brelans de 3'
 Else If (D1 = 2) And (D2 = 2) And (D3 = 2) Then GetScoreDescription := '222 - Brelans de 2'
 Else If (D1 = 4) And (D2 = 5) And (D3 = 6) Then GetScoreDescription := '654 - Suite'
 Else If (D1 = 3) And (D2 = 4) And (D3 = 5) Then GetScoreDescription := '543 - Suite'
 Else If (D1 = 2) And (D2 = 3) And (D3 = 4) Then GetScoreDescription := '432 - Suite'
 Else If (D1 = 1) And (D2 = 2) And (D3 = 3) Then GetScoreDescription := '321 - Suite'
 Else Begin
  { Compter les 1 (as) }
  Score := 0;
  If D1 = 1 Then Inc(Score);
  If D2 = 1 Then Inc(Score);
  If D3 = 1 Then Inc(Score);
  If Score > 0 Then GetScoreDescription := 'As: ' + Chr(Ord('0') + Score) + ' point(s)'
               Else GetScoreDescription := 'Aucun point';
 End;
End;

Procedure RollDice(PlayerIndex: Integer);
Var
 I: Integer;
Begin
 If (PlayerIndex < 0) Or (PlayerIndex >= Game.PlayerCount) Then Exit;

 For I := 1 to 3 Do Begin
  If Not Game.Players[PlayerIndex].Dice[I].Selected Then Begin
   Game.Players[PlayerIndex].Dice[I].Value := Random(6) + 1;
  End;
 End;

 Dec(Game.Players[PlayerIndex].RollsLeft);
 Game.Players[PlayerIndex].CurrentScore := CalculateScore(PlayerIndex);
End;

Procedure DrawPlayerInfo;
Var
 I: Integer;
 PlayerName: String;
 TokensText: String;
 ScoreText: String;
 RollsText: String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) Then Begin
   PlayerName := Game.Players[I].Name;
   Str(Game.Players[I].Tokens, TokensText);
   Str(Game.Players[I].CurrentScore, ScoreText);
   Str(Game.Players[I].RollsLeft, RollsText);
   Case I of
    0: Begin { Joueur humain - en bas }
     OutTextXY(50, 320, PlayerName + ' - Jetons: ' + TokensText);
     OutTextXY(50, 330, 'Pointage: ' + ScoreText + ' - Lancers: ' + RollsText);
     OutTextXY(50, 340, GetScoreDescription(I));
     If Game.CurrentPlayer = 0 Then Begin
      SetColor(Yellow);
      OutTextXY(30, 320, '>');
      SetColor(White);
     End;
    End;
    1: Begin { Joueur 2 - en haut }
     OutTextXY(50, 70, PlayerName + ' - Jetons: ' + TokensText);
     OutTextXY(50, 80, 'Pointage: ' + ScoreText + ' - Lancers: ' + RollsText);
     If Game.CurrentPlayer = 1 Then Begin
      SetColor(Yellow);
      OutTextXY(30, 70, '>');
      SetColor(White);
     End;
    End;
    2: Begin { Joueur 3 - A droite }
     OutTextXY(420, 150, PlayerName);
     OutTextXY(420, 160, 'Jetons: ' + TokensText);
     OutTextXY(420, 170, 'Pointage: ' + ScoreText);
     OutTextXY(420, 180, 'Lancers: ' + RollsText);
     If Game.CurrentPlayer = 2 Then Begin
      SetColor(Yellow);
      OutTextXY(410, 150, '>');
      SetColor(White);
     End;
    End;
    3: Begin { Joueur 4 - A gauche }
     OutTextXY(50, 150, PlayerName);
     OutTextXY(50, 160, 'Jetons: ' + TokensText);
     OutTextXY(50, 170, 'Pointage: ' + ScoreText);
     OutTextXY(50, 180, 'Lancers: ' + RollsText);
     If Game.CurrentPlayer = 3 Then Begin
      SetColor(Yellow);
      OutTextXY(30, 150, '>');
      SetColor(White);
     End;
    End;
   End;
  End;
 End;
End;

Procedure DrawGameInfo;
Var
 RoundText: String;
 MaxRoundsText: String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 { Informations gÇnÇrales }
 Str(Game.Round, RoundText);
 Str(MAX_ROUNDS, MaxRoundsText);
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(270, 20, 'JEU DU 421');
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(300, 75, 'Manche: ' + RoundText + '/' + MaxRoundsText);
  { Instructions }
 SetColor(LightGray);
 OutTextXY(20, 450, 'Instructions:');
 Case Game.GamePhase of
  GAME_ROLLING: Begin
   OutTextXY(20, 460, 'ESPACE - Lancer les des  |  Clic - Selectionner des');
   OutTextXY(20, 470, 'ENTREE - Garder le score actuel');
  End;
 End;
 OutTextXY(450, 450, 'N - Nouvelle partie');
 OutTextXY(450, 460, 'ESC - Quitter');
End;

Procedure DrawBackground;Begin
 SetColor(DarkGray);
 SetFillStyle(SolidFill, DarkGray);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Cadre principal }
 SetColor(White);
 Rectangle(10, 10, SCREEN_WIDTH - 10, SCREEN_HEIGHT - 40);
End;

Procedure DrawScreen;
Var
 I: Integer;
Begin
 DrawBackground;
  { Dessiner les dÇs de tous les joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If (I >= 0) And (I < Game.PlayerCount) Then Begin
   DrawPlayerDice(I);
  End;
 End;
 DrawPlayerInfo;
 DrawGameInfo;
  { Afficher les rÇsultats de fin de manche }
 If Game.ShowResults Then Begin
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(150, 180, 490, 300);
  SetColor(White);
  Rectangle(150, 180, 490, 300);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(200, 200, 'Fin de manche');
  SetTextStyle(DefaultFont, HorizDir, 1);
   { Afficher le gagnant de la manche }
  If (Game.Winner >= 0) And (Game.Winner < Game.PlayerCount) Then Begin
   OutTextXY(160, 230, 'Gagnant: ' + Game.Players[Game.Winner].Name);
   OutTextXY(160, 250, GetScoreDescription(Game.Winner));
  End;
  OutTextXY(160, 270, 'Appuyez sur une touche...');
 End;
End;

Procedure InitPlayers;
Var
 I, J: Integer;
Begin
 Game.PlayerCount := 2; { Commencer avec 2 joueurs }
  { Joueur humain }
 Game.Players[0].Name := 'Joueur';
 Game.Players[0].IsHuman := True;
 Game.Players[0].Tokens := STARTING_TOKENS;
 Game.Players[0].IsActive := True;
  { Joueur ordinateur }
 Game.Players[1].Name := 'Ordinateur';
 Game.Players[1].IsHuman := False;
 Game.Players[1].Tokens := STARTING_TOKENS;
 Game.Players[1].IsActive := True;
  { Initialiser les d√©s }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  Game.Players[I].Score := 0;
  Game.Players[I].CurrentScore := 0;
  Game.Players[I].RollsLeft := 3;
  For J := 1 to 3 Do Begin
   Game.Players[I].Dice[J].Value := 1;
   Game.Players[I].Dice[J].Selected := False;
  End;
 End;
End;

Procedure InitGame;
Var
 I: Integer;
Begin
 Game.CurrentPlayer := 0;
 Game.Round := 1;
 Game.GamePhase := GAME_ROLLING;
 Game.Winner := -1;
 Game.ShowResults := False;
 Game.NeedRedraw := True;
 Game.AnimationDelay := 0;
 InitPlayers;
  { Premier lancer automatique pour tous les joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  RollDice(I);
 End;
End;

Function GetClickedDie(X, Y: Integer): Integer;
Var
 I: Integer;
 DieX, DieY: Integer;
Begin
 GetClickedDie := -1;
 If Game.CurrentPlayer <> 0 Then Exit;
 If Game.GamePhase <> GAME_ROLLING Then Exit;
 For I := 1 to 3 Do Begin
  DieX := Game.Players[0].Dice[I].X;
  DieY := Game.Players[0].Dice[I].Y;
  If (X >= DieX) And (X <= DieX + DIE_SIZE) And
     (Y >= DieY) And (Y <= DieY + DIE_SIZE) Then Begin
   GetClickedDie := I;
   Exit;
  End;
 End;
End;

Procedure HandleMouseClick(X, Y: Integer);
Var
 ClickedDie: Integer;
Begin
 If Game.GamePhase <> GAME_ROLLING Then Exit;
 If Game.CurrentPlayer <> 0 Then Exit;
 ClickedDie := GetClickedDie(X, Y);
 If ClickedDie > 0 Then Begin
  Game.Players[0].Dice[ClickedDie].Selected := Not Game.Players[0].Dice[ClickedDie].Selected;
  Game.NeedRedraw := True;
 End;
End;

Procedure DetermineWinner;
Var
 I, BestScore, BestPlayer: Integer;
Begin
 BestScore := -1;
 BestPlayer := -1;
 For I := 0 to Game.PlayerCount - 1 Do Begin
  If Game.Players[I].CurrentScore > BestScore Then Begin
   BestScore := Game.Players[I].CurrentScore;
   BestPlayer := I;
  End;
 End;
 Game.Winner := BestPlayer;
  { Distribuer les jetons }
 If BestPlayer >= 0 Then Begin
  If BestScore = SCORE_421 Then Begin
   { 421 - tous les autres perdent 2 jetons }
   For I := 0 to Game.PlayerCount - 1 Do Begin
    If I <> BestPlayer Then Begin
     Game.Players[I].Tokens := Game.Players[I].Tokens - 2;
     If Game.Players[I].Tokens < 0 Then Game.Players[I].Tokens := 0;
    End;
   End;
  End
  Else If BestScore >= SCORE_222 Then Begin
   { Brelan ou suite - tous les autres perdent 1 jeton }
   For I := 0 to Game.PlayerCount - 1 Do Begin
    If I <> BestPlayer Then Begin
     Game.Players[I].Tokens := Game.Players[I].Tokens - 1;
     If Game.Players[I].Tokens < 0 Then Game.Players[I].Tokens := 0;
    End;
   End;
  End;
 End;
 Game.ShowResults := True;
 Game.GamePhase := GAME_ROUND_END;
End;

Procedure NextPlayer;Begin
 Game.CurrentPlayer := (Game.CurrentPlayer + 1) Mod Game.PlayerCount;
 If Game.CurrentPlayer = 0 Then Begin
  { Fin de la manche }
  DetermineWinner;
 End;
End;

Procedure NextRound;
Var
 I,J:Integer;
Begin
 Inc(Game.Round);
 Game.ShowResults := False;
 { VÇrifier si le jeu est terminÇ }
 If Game.Round > MAX_ROUNDS Then Begin
  Game.GamePhase := GAME_OVER;
  Exit;
 End;
 { RÇinitialiser pour la prochaine manche }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  Game.Players[I].CurrentScore := 0;
  Game.Players[I].RollsLeft := 3;
  For J := 1 to 3 Do Begin
   Game.Players[I].Dice[J].Value := 1;
   Game.Players[I].Dice[J].Selected := False;
  End;
 End;
 Game.CurrentPlayer := 0;
 Game.GamePhase := GAME_ROLLING;
  { Premier lancer automatique pour tous les joueurs }
 For I := 0 to Game.PlayerCount - 1 Do Begin
  RollDice(I);
 End;
 Game.NeedRedraw := True;
End;

Procedure HandleComputerTurn;
Var
 I: Integer;
 KeepDie: Boolean;
 CountOnes, CountTwos, CountFours: Integer;
Begin
 If Game.Players[Game.CurrentPlayer].IsHuman Then Exit;
 If Game.GamePhase <> GAME_ROLLING Then Exit;
  { StratÇgie de l'ordinateur }
 If Game.Players[Game.CurrentPlayer].RollsLeft > 0 Then Begin
  { Compter les valeurs intÇressantes }
  CountOnes := 0;
  CountTwos := 0;
  CountFours := 0;
  For I := 1 to 3 Do Begin
   If Game.Players[Game.CurrentPlayer].Dice[I].Value = 1 Then Inc(CountOnes);
   If Game.Players[Game.CurrentPlayer].Dice[I].Value = 2 Then Inc(CountTwos);
   If Game.Players[Game.CurrentPlayer].Dice[I].Value = 4 Then Inc(CountFours);
  End;
  { Si on a dÇjÖ 111, on garde tout }
  If CountOnes = 3 Then Begin
   For I := 1 to 3 Do Begin
    Game.Players[Game.CurrentPlayer].Dice[I].Selected := True;
   End;
  End
  Else Begin
   { Sinon, garder les 1, 2 et 4 pour tenter le 421 }
   For I := 1 to 3 Do Begin
    KeepDie := False;
    If Game.Players[Game.CurrentPlayer].Dice[I].Value = 1 Then KeepDie := True;
    If Game.Players[Game.CurrentPlayer].Dice[I].Value = 2 Then KeepDie := True;
    If Game.Players[Game.CurrentPlayer].Dice[I].Value = 4 Then KeepDie := True;
    Game.Players[Game.CurrentPlayer].Dice[I].Selected := KeepDie;
   End;
  End;
  RollDice(Game.CurrentPlayer);
  Game.NeedRedraw := True;
 End
 Else Begin
  { Plus de lancers - passer au joueur suivant }
  NextPlayer;
 End;
End;

Procedure HandleInput;
Var
 Key: Char;
 MouseX, MouseY, MouseButton: LongInt;
Begin
 { Clavier }
 If KeyPressed Then Begin
  Key := ReadKey;
  Case Key of
   ' ': Begin { Espace - Lancer les dÇs }
    If (Game.GamePhase = GAME_ROLLING) And (Game.CurrentPlayer = 0)Then Begin
     If Game.Players[0].RollsLeft > 0 Then Begin
      RollDice(0);
      Game.NeedRedraw := True;
     End;
    End Else If Game.ShowResults Then Begin
     NextRound;
    End;
   End;
   #13:Begin { EntrÇe - Garder le pointage }
    If (Game.GamePhase = GAME_ROLLING) And (Game.CurrentPlayer = 0) Then Begin
     Game.Players[0].RollsLeft := 0;
     NextPlayer;
     Game.NeedRedraw := True;
    End;
   End;
   'n', 'N': Begin { Nouvelle partie }
    InitGame;
   End;
   #27: Begin { Escape - Quitter }
    CloseGraph;
    Halt;
   End;
  End;
 End;
  { Souris }
 If MouseDriverFound Then Begin
  GetMouseState(MouseX, MouseY, MouseButton);
  If MouseButton = 1 Then Begin
   HandleMouseClick(MouseX, MouseY);
   While MouseButton = 1 Do GetMouseState(MouseX, MouseY, MouseButton);
  End;
 End;
End;

BEGIN
 Randomize;
 InitScreen;
 If MouseDriverFound Then ShowMouse;
 InitGame;
  { Boucle principale }
 Repeat
  If Game.NeedRedraw Then Begin
   DrawScreen;
   Game.NeedRedraw := False;
  End;
  HandleInput;
   { Gestion des tours de l'ordinateur }
  If Not Game.Players[Game.CurrentPlayer].IsHuman Then Begin
   HandleComputerTurn;
   Delay(1000);
  End;
   { Gestion du dÇlai d'animation }
  If Game.AnimationDelay > 0 Then Begin
   Dec(Game.AnimationDelay);
   If Game.AnimationDelay = 0 Then Begin
    Game.NeedRedraw := True;
   End;
  End;
  Delay(50);
 Until False;
END.
