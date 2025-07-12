{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Baseball avec interface graphique
}

Program Baseball;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
 SCREEN_WIDTH=640;
 SCREEN_HEIGHT=480;
 FIELD_CENTER_X=320;
 FIELD_CENTER_Y=400;
 BASE_SIZE=8;
 PLAYER_SIZE=4;
 BALL_SIZE=2;
 MAX_INNINGS=9;
 TEAM_SIZE=9;

Type
 TGameState = (gsMainMenu, gsPlaying, gsAtBat, gsPitching, gsFielding, gsGameOver, gsQuit);
 TTeam = (tmHome, tmAway);
 TBase = (bsHome, bsFirst, bsSecond, bsThird);
 TPosition = (psPitcher, psCatcher, psFirstBase, psSecondBase, psThirdBase,
              psShortstop, psLeftField, psCenterField, psRightField);

 TPlayer=Record
  name:String[20];
  position:TPosition;
  x,y:Integer;
  battingAvg:Real;
  fieldingSkill:Integer;
 End;

 TBall=Record
  x,y:Integer;
  dx,dy:Integer;
  inPlay:Boolean;
  speed:Integer;
 End;

 TeamArray=Array[0..TEAM_SIZE-1] of TPlayer;

 TGameData=Record
  gameState:TGameState;
  currentInning:Integer;
  currentTeam:TTeam;
  homeScore,awayScore:Integer;
  outs:Integer;
  balls,strikes:Integer;
  bases:Array[TBase] of Boolean;
  currentBatter:Integer;
  currentPitcher:Integer;
  ball:TBall;
  homeTeam:TeamArray;
  awayTeam:TeamArray;
  message:String;
  needRedraw:Boolean;
  pitchPower:Integer;
  swingTiming:Integer;
  inningTop:Boolean;
 End;

Var
 Game:TGameData;

Function IntToStr(value:LongInt):String;
Var
 s:String;
Begin
 Str(value, s);
 IntToStr := s;
End;

Function FloatToStr(value:Real;decimals:Integer):String;
Var
 s:String;
Begin
 Str(value:0:decimals,s);
 FloatToStr:=s;
End;

Procedure InitializePlayers;
Var
 i:Integer;
Begin
  { êquipe domicile }
 Game.homeTeam[0].name := 'Rodriguez';
 Game.homeTeam[0].position := psPitcher;
 Game.homeTeam[0].battingAvg := 0.245;
 Game.homeTeam[0].fieldingSkill := 85;
 Game.homeTeam[1].name := 'Johnson';
 Game.homeTeam[1].position := psCatcher;
 Game.homeTeam[1].battingAvg := 0.278;
 Game.homeTeam[1].fieldingSkill := 90;
 Game.homeTeam[2].name := 'Williams';
 Game.homeTeam[2].position := psFirstBase;
 Game.homeTeam[2].battingAvg := 0.312;
 Game.homeTeam[2].fieldingSkill := 82;
 Game.homeTeam[3].name := 'Davis';
 Game.homeTeam[3].position := psSecondBase;
 Game.homeTeam[3].battingAvg := 0.289;
 Game.homeTeam[3].fieldingSkill := 88;
 Game.homeTeam[4].name := 'Martinez';
 Game.homeTeam[4].position := psThirdBase;
 Game.homeTeam[4].battingAvg := 0.301;
 Game.homeTeam[4].fieldingSkill := 85;
 Game.homeTeam[5].name := 'Garcia';
 Game.homeTeam[5].position := psShortstop;
 Game.homeTeam[5].battingAvg := 0.267;
 Game.homeTeam[5].fieldingSkill := 92;
 Game.homeTeam[6].name := 'Thompson';
 Game.homeTeam[6].position := psLeftField;
 Game.homeTeam[6].battingAvg := 0.298;
 Game.homeTeam[6].fieldingSkill := 78;
 Game.homeTeam[7].name := 'Anderson';
 Game.homeTeam[7].position := psCenterField;
 Game.homeTeam[7].battingAvg := 0.315;
 Game.homeTeam[7].fieldingSkill := 89;
 Game.homeTeam[8].name := 'Wilson';
 Game.homeTeam[8].position := psRightField;
 Game.homeTeam[8].battingAvg := 0.283;
 Game.homeTeam[8].fieldingSkill := 81;
  { êquipe visiteur }
 Game.awayTeam[0].name := 'Lopez';
 Game.awayTeam[0].position := psPitcher;
 Game.awayTeam[0].battingAvg := 0.198;
 Game.awayTeam[0].fieldingSkill := 87;
 Game.awayTeam[1].name := 'Brown';
 Game.awayTeam[1].position := psCatcher;
 Game.awayTeam[1].battingAvg := 0.254;
 Game.awayTeam[1].fieldingSkill := 93;
 Game.awayTeam[2].name := 'Taylor';
 Game.awayTeam[2].position := psFirstBase;
 Game.awayTeam[2].battingAvg := 0.276;
 Game.awayTeam[2].fieldingSkill := 84;
 Game.awayTeam[3].name := 'Moore';
 Game.awayTeam[3].position := psSecondBase;
 Game.awayTeam[3].battingAvg := 0.298;
 Game.awayTeam[3].fieldingSkill := 86;
 Game.awayTeam[4].name := 'Jackson';
 Game.awayTeam[4].position := psThirdBase;
 Game.awayTeam[4].battingAvg := 0.312;
 Game.awayTeam[4].fieldingSkill := 83;
 Game.awayTeam[5].name := 'White';
 Game.awayTeam[5].position := psShortstop;
 Game.awayTeam[5].battingAvg := 0.289;
 Game.awayTeam[5].fieldingSkill := 91;
 Game.awayTeam[6].name := 'Harris';
 Game.awayTeam[6].position := psLeftField;
 Game.awayTeam[6].battingAvg := 0.301;
 Game.awayTeam[6].fieldingSkill := 77;
 Game.awayTeam[7].name := 'Clark';
 Game.awayTeam[7].position := psCenterField;
 Game.awayTeam[7].battingAvg := 0.287;
 Game.awayTeam[7].fieldingSkill := 88;
 Game.awayTeam[8].name := 'Lewis';
 Game.awayTeam[8].position := psRightField;
 Game.awayTeam[8].battingAvg := 0.269;
 Game.awayTeam[8].fieldingSkill := 79;
  { Positionner les joueurs sur le terrain }
 For i:=0 to TEAM_SIZE-1 do Begin
  Case Game.homeTeam[i].position of
   psPitcher:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-50;
   End;
   psCatcher:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X;
    Game.homeTeam[i].y:=FIELD_CENTER_Y+10;
   End;
   psFirstBase:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X+80;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-80;
   End;
   psSecondBase:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-113;
   End;
   psThirdBase:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X-80;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-80;
   End;
   psShortstop: Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X-40;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-100;
   End;
   psLeftField:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X-120;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-180;
   End;
   psCenterField:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-200;
   End;
   psRightField:Begin
    Game.homeTeam[i].x:=FIELD_CENTER_X+120;
    Game.homeTeam[i].y:=FIELD_CENTER_Y-180;
   End;
  End;
   { Copier les positions pour l'Çquipe visiteur }
  Game.awayTeam[i].x := Game.homeTeam[i].x;
  Game.awayTeam[i].y := Game.homeTeam[i].y;
 End;
End;

Procedure DrawField;Begin
  { Fond vert }
 SetColor(2);
 SetFillStyle(1, 2);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
  { Terrain de baseball (diamant) }
 SetColor(6);
 SetFillStyle(1, 6);
  { Monticule du lanceur }
 FillEllipse(FIELD_CENTER_X, FIELD_CENTER_Y - 50, 15, 8);
  { Bases }
 SetColor(15);
 SetFillStyle(1, 15);
  { Marbre (home plate) }
 Rectangle(FIELD_CENTER_X - BASE_SIZE, FIELD_CENTER_Y - BASE_SIZE,
           FIELD_CENTER_X + BASE_SIZE, FIELD_CENTER_Y + BASE_SIZE);
  { Premiäre base }
 Rectangle(FIELD_CENTER_X + 80 - BASE_SIZE, FIELD_CENTER_Y - 80 - BASE_SIZE,
           FIELD_CENTER_X + 80 + BASE_SIZE, FIELD_CENTER_Y - 80 + BASE_SIZE);
  { Deuxiäme base }
 Rectangle(FIELD_CENTER_X - BASE_SIZE, FIELD_CENTER_Y - 113 - BASE_SIZE,
           FIELD_CENTER_X + BASE_SIZE, FIELD_CENTER_Y - 113 + BASE_SIZE);
   { Troisiäme base }
 Rectangle(FIELD_CENTER_X - 80 - BASE_SIZE, FIELD_CENTER_Y - 80 - BASE_SIZE,
           FIELD_CENTER_X - 80 + BASE_SIZE, FIELD_CENTER_Y - 80 + BASE_SIZE);
  { Lignes de dÇmarcation }
 SetColor(15);
 Line(FIELD_CENTER_X, FIELD_CENTER_Y, FIELD_CENTER_X + 80, FIELD_CENTER_Y - 80);
 Line(FIELD_CENTER_X, FIELD_CENTER_Y, FIELD_CENTER_X - 80, FIELD_CENTER_Y - 80);
 Line(FIELD_CENTER_X + 80, FIELD_CENTER_Y - 80, FIELD_CENTER_X, FIELD_CENTER_Y - 113);
 Line(FIELD_CENTER_X - 80, FIELD_CENTER_Y - 80, FIELD_CENTER_X, FIELD_CENTER_Y - 113);
  { Cercle ext√©rieur }
 SetColor(15);
 Circle(FIELD_CENTER_X, FIELD_CENTER_Y, 200);
End;

Procedure DrawPlayers;
Var
 i:Integer;
 team:TeamArray;
Begin
 { Choisir l'Çquipe Ö afficher (Çquipe dÇfensive) }
 If Game.currentTeam=tmHome Then team:=Game.awayTeam
                            Else team:=Game.homeTeam;
  { Dessiner les joueurs }
 SetColor(14);
 SetFillStyle(1, 14);
 For i:=0 to TEAM_SIZE-1 do Begin
  FillEllipse(team[i].x, team[i].y, PLAYER_SIZE, PLAYER_SIZE);
   { Çtiquette du joueur }
  SetColor(15);
  SetTextStyle(0, 0, 0);
  OutTextXY(team[i].x - 10, team[i].y - 15, team[i].name);
 End;
End;

Procedure DrawBall;Begin
 If Game.ball.inPlay Then Begin
  SetColor(15);
  SetFillStyle(1, 15);
  FillEllipse(Game.ball.x, Game.ball.y, BALL_SIZE, BALL_SIZE);
 End;
End;

Procedure DrawScoreboard;Begin
  { Cadre du tableau de bord }
 SetColor(15);
 Rectangle(10,10,250,100);
  { Titre }
 SetTextStyle(0, 0, 1);
 OutTextXY(20, 20, 'BASEBALL');
  { Pointage }
 OutTextXY(20, 40, 'Visiteur: ' + IntToStr(Game.awayScore));
 OutTextXY(20, 55, 'Domicile: ' + IntToStr(Game.homeScore));
  { Manche }
 OutTextXY(20, 75, 'Manche: ' + IntToStr(Game.currentInning));
 If Game.inningTop Then OutTextXY(90, 75, '(Haut)')
                   Else OutTextXY(90, 75, '(Bas)');
End;

Procedure DrawGameInfo;Begin
  { Cadre des informations }
 SetColor(15);
 Rectangle(400, 10, 630, 120);
 SetTextStyle(0, 0, 1);
 OutTextXY(410, 20, 'Retraits: ' + IntToStr(Game.outs));
 OutTextXY(410, 35, 'Balles: ' + IntToStr(Game.balls));
 OutTextXY(410, 50, 'Prises: ' + IntToStr(Game.strikes));
  { Bases occup√©es }
 OutTextXY(410, 70, 'Bases:');
 If Game.bases[bsFirst] Then OutTextXY(450, 70, '1');
 If Game.bases[bsSecond] Then OutTextXY(465, 70, '2');
 If Game.bases[bsThird] Then OutTextXY(480, 70, '3');
  { Batteur actuel }
 If Game.currentTeam = tmHome Then OutTextXY(410, 90, 'Batteur: ' + Game.homeTeam[Game.currentBatter].name)
                              Else OutTextXY(410, 90, 'Batteur: ' + Game.awayTeam[Game.currentBatter].name);
  { Lanceur actuel }
 If Game.currentTeam=tmHome Then
  OutTextXY(410, 105, 'Lanceur: ' + Game.awayTeam[Game.currentPitcher].name)
 Else
  OutTextXY(410, 105, 'Lanceur: ' + Game.homeTeam[Game.currentPitcher].name);
End;

Procedure DrawMessage;Begin
 If Game.message<>''Then Begin
  SetColor(14);
  SetFillStyle(1, 14);
  Bar(50, 130, 590, 160);
  SetColor(0);
  SetTextStyle(0, 0, 1);
  OutTextXY(60, 140, Game.message);
 End;
End;

Procedure DrawInstructions;Begin
 SetColor(15);
 SetTextStyle(0, 0, 1);
 Case Game.gameState of
  gsPitching:Begin
   OutTextXY(50, 450, 'LANCER: ESPACE pour lancer  +/- pour ajuster la puissance');
  End;
  gsAtBat:Begin
   OutTextXY(50, 450, 'FRAPPER: ESPACE pour frapper  Timing important!');
  End;
  gsFielding:Begin
   OutTextXY(50, 450, 'DEFENSE: La balle est en jeu...');
  End;
 End;
 OutTextXY(450, 450, 'ESC: Quitter');
End;

Procedure DrawMainMenu;Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 4);
 OutTextXY(SCREEN_WIDTH div 2 - 120, 100, 'BASEBALL');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 180, 'Regles du Baseball:');
 OutTextXY(50, 200, '- Chaque equipe a 9 joueurs');
 OutTextXY(50, 220, '- 3 retraits par manche');
 OutTextXY(50, 240, '- 9 manches par partie');
 OutTextXY(50, 260, '- 4 balles = marche libre');
 OutTextXY(50, 280, '- 3 prises = retrait');
 OutTextXY(50, 300, '- Frappez au bon moment!');
 OutTextXY(50, 340, 'Commandes:');
 OutTextXY(50, 360, 'ESPACE: Lancer/Frapper');
 OutTextXY(50, 380, '+/-: Ajuster la puissance de lancer');
 OutTextXY(50, 400, 'ESC: Quitter');
 OutTextXY(50, 450, 'Appuyez sur ENTREE pour commencer...');
End;

Procedure DrawGameOver;Begin
 SetColor(0);
 SetFillStyle(1, 0);
 Bar(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
 SetColor(15);
 SetTextStyle(0, 0, 3);
 OutTextXY(SCREEN_WIDTH div 2 - 100, 150, 'PARTIE TERMINEE');
 SetTextStyle(0, 0, 2);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 200, 'Pointage Final:');
 OutTextXY(SCREEN_WIDTH div 2 - 80, 230, 'Visiteur: ' + IntToStr(Game.awayScore));
 OutTextXY(SCREEN_WIDTH div 2 - 80, 260, 'Domicile: ' + IntToStr(Game.homeScore));
 If Game.homeScore > Game.awayScore Then
  OutTextXY(SCREEN_WIDTH div 2 - 120, 320, 'L''equipe domicile gagne!')
 Else If Game.awayScore > Game.homeScore Then
  OutTextXY(SCREEN_WIDTH div 2 - 120, 320, 'L''equipe visiteur gagne!')
 Else
  OutTextXY(SCREEN_WIDTH div 2 - 60, 320, 'Match nul!');
 SetTextStyle(0, 0, 1);
 OutTextXY(50, 400, 'Appuyez sur N pour une nouvelle partie ou ESC pour quitter');
End;

Function GetBattingResult(battingAvg:Real;pitchQuality:Integer):String;
Var
 chance:Integer;
Begin
 chance:=Random(100);
  { Ajuster selon la qualitÇ du lancer }
 If pitchQuality > 75 Then chance:=chance + 20 Else
 If pitchQuality < 25 Then chance:=chance - 20;
 If chance<Round(battingAvg*100)Then Begin
   { Coup rÇussi }
  Case Random(10) of
   0..5:GetBattingResult := 'Simple';
   6..7:GetBattingResult := 'Double';
   8:GetBattingResult := 'Triple';
   9:GetBattingResult := 'Coup de circuit';
  End;
 End
  Else
 Begin
   { êchec }
  Case Random(3) of
   0: GetBattingResult := 'Prise';
   1: GetBattingResult := 'Fausse balle';
   2: GetBattingResult := 'Balle au sol';
  End;
 End;
End;

Procedure ProcessHit(hitType:String);
Var
 currentScore:Integer;
Begin
 If hitType='Simple'Then Begin
  Game.message:='Coup sur! Simple!';
   { Avancer les coureurs }
  If Game.bases[bsThird]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsThird] := False;
  End;
  If Game.bases[bsSecond] Then Begin
   Game.bases[bsThird] := True;
   Game.bases[bsSecond] := False;
  End;
  If Game.bases[bsFirst]Then Begin
   Game.bases[bsSecond] := True;
  End;
  Game.bases[bsFirst] := True;
 End
  Else
 If hitType='Double'Then Begin
  Game.message:='Excellent! Double!';
   { Avancer les coureurs de 2 bases }
  If Game.bases[bsThird]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsThird]:=False;
  End;
  If Game.bases[bsSecond]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsSecond] := False;
  End;
  If Game.bases[bsFirst]Then Begin
   Game.bases[bsThird]:=True;
   Game.bases[bsFirst]:=False;
  End;
  Game.bases[bsSecond]:=True;
 End
  Else
 If hitType='Triple'Then Begin
  Game.message := 'Incroyable! Triple!';
   { Marquer tous les coureurs }
  If Game.bases[bsThird]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsThird]:=False;
  End;
  If Game.bases[bsSecond]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsSecond]:=False;
  End;
  If Game.bases[bsFirst]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsFirst] := False;
  End;
  Game.bases[bsThird] := True;
 End
  Else
 If hitType='Coup de circuit'Then Begin
  Game.message := 'COUP DE CIRCUIT! Fantastique!';
   { Marquer tous les coureurs + le batteur }
  If Game.bases[bsThird]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsThird]:=False;
  End;
  If Game.bases[bsSecond]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsSecond]:=False;
  End;
  If Game.bases[bsFirst]Then Begin
   If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                              Else Inc(Game.awayScore);
   Game.bases[bsFirst] := False;
  End;
   { Le batteur marque aussi }
  If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                             Else Inc(Game.awayScore);
 End;
  { Prochain batteur }
 Game.currentBatter:=(Game.currentBatter + 1) mod TEAM_SIZE;
 Game.balls:=0;
 Game.strikes:=0;
 Game.gameState:=gsPitching;
End;

Procedure ProcessOut;Begin
 Inc(Game.outs);
 Game.message:='Retrait! ' + IntToStr(Game.outs) + ' retrait(s)';
 Game.currentBatter:=(Game.currentBatter + 1) mod TEAM_SIZE;
 Game.balls:=0;
 Game.strikes:=0;
 If Game.outs>=3 Then Begin
   { Fin de la manche }
  Game.outs := 0;
  Game.bases[bsFirst]:=False;
  Game.bases[bsSecond]:=False;
  Game.bases[bsThird]:=False;
  If Game.inningTop Then Begin
   Game.inningTop:=False;
   Game.currentTeam:=tmHome;
  End
   Else
  Begin
   Game.inningTop:=True;
   Game.currentTeam:=tmAway;
   Inc(Game.currentInning);
  End;
  Game.message:='Changement de manche!';
  If Game.currentInning>MAX_INNINGS Then Begin
   Game.gameState:=gsGameOver;
   Exit;
  End;
 End;
 Game.gameState:=gsPitching;
End;

Procedure ProcessPitch;
Var
 pitchQuality:Integer;
 isStrike:Boolean;
Begin
 pitchQuality:=Game.pitchPower+Random(50);
 isStrike:=Random(100)<60; { 60% de chance de strike }
 If isStrike Then Begin
  Inc(Game.strikes);
  Game.message := 'Prise! '+IntToStr(Game.strikes)+' prise(s)';
  If Game.strikes>=3 Then Begin
   ProcessOut;
   Exit;
  End;
 End
  Else
 Begin
  Inc(Game.balls);
  Game.message:='Balle! ' + IntToStr(Game.balls) + ' balle(s)';
  If Game.balls>=4 Then Begin
   Game.message:='Marche libre!';
    { Avancer les coureurs }
   If Game.bases[bsThird] and Game.bases[bsSecond]and Game.bases[bsFirst]Then Begin
    If Game.currentTeam=tmHome Then Inc(Game.homeScore)
                               Else Inc(Game.awayScore);
   End;
   If Game.bases[bsSecond]and Game.bases[bsFirst]Then Game.bases[bsThird]:=True;
   If Game.bases[bsFirst]Then Game.bases[bsSecond]:=True;
   Game.bases[bsFirst]:=True;
   Game.currentBatter := (Game.currentBatter + 1) mod TEAM_SIZE;
   Game.balls:=0;
   Game.strikes:=0;
  End;
 End;
 Game.gameState:=gsAtBat;
End;

Procedure ProcessSwing;
Var
 battingAvg:Real;
 pitchQuality:Integer;
 result:String;
Begin
 If Game.currentTeam=tmHome Then battingAvg:=Game.homeTeam[Game.currentBatter].battingAvg
                            Else battingAvg:=Game.awayTeam[Game.currentBatter].battingAvg;
 pitchQuality:=Game.pitchPower;
 result:=GetBattingResult(battingAvg, pitchQuality);
 If(result='Simple')or(result='Double')or(result='Triple')or(result='Coup de circuit')Then Begin
  ProcessHit(result);
 End
  Else
 If result='Prise'Then Begin
  Inc(Game.strikes);
  Game.message:='Prise! '+IntToStr(Game.strikes)+' prise(s)';
  If Game.strikes>=3 Then Begin
   ProcessOut;
   Exit;
  End;
  Game.gameState:=gsPitching;
 End
  Else
 If result='Fausse balle'Then Begin
  If Game.strikes<2 Then Inc(Game.strikes);
  Game.message:='Fausse balle! '+IntToStr(Game.strikes)+' prise(s)';
  Game.gameState:=gsPitching;
 End
  Else
 If result='Balle au sol'Then Begin
  Game.message := 'Balle au sol - tentative de retrait...';
  If Random(100)<70 Then Begin
   ProcessOut;
  End
   Else
  Begin
   Game.message := 'Sauf! Le coureur arrive a la base!';
   ProcessHit('Simple');
  End;
 End;
End;

Procedure HandleInput;
Var
 key:Char;
Begin
 If KeyPressed Then Begin
  key:=ReadKey;
  Case Game.gameState of
   gsMainMenu:Begin
    If key=#13 Then Begin { Enter }
     Game.gameState:=gsPitching;
     Game.needRedraw:=True;
    End
     Else
    If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
   gsPitching:Begin
    Case key of
     ' ':Begin
      ProcessPitch;
      Game.needRedraw := True;
     End;
     '+':Begin
      If Game.pitchPower<100 Then Inc(Game.pitchPower,10);
      Game.needRedraw:=True;
     End;
     '-':Begin
      If Game.pitchPower>0 Then Dec(Game.pitchPower, 10);
      Game.needRedraw := True;
     End;
     #27:Game.gameState := gsQuit; { ESC }
    End;
   End;
   gsAtBat:Begin
    If key=' 'Then Begin
     ProcessSwing;
     Game.needRedraw := True;
    End
     Else
    If key=#27 Then { ESC }
     Game.gameState:=gsQuit;
   End;
   gsGameOver:Begin
    If key='n'Then Begin
      { Nouvelle partie }
     Game.currentInning := 1;
     Game.homeScore := 0;
     Game.awayScore := 0;
     Game.outs := 0;
     Game.balls := 0;
     Game.strikes := 0;
     Game.currentBatter := 0;
     Game.currentTeam := tmAway;
     Game.inningTop := True;
     Game.bases[bsFirst] := False;
     Game.bases[bsSecond] := False;
     Game.bases[bsThird] := False;
     Game.message := '';
     Game.gameState := gsPitching;
     Game.needRedraw := True;
    End
    Else If key = #27 Then { ESC }
     Game.gameState := gsQuit;
   End;
  End;
 End;
End;

Procedure Render;Begin
 If Game.needRedraw Then Begin
  Case Game.gameState of
   gsMainMenu: DrawMainMenu;
   gsPitching,gsAtBat,gsFielding:Begin
    DrawField;
    DrawPlayers;
    DrawBall;
    DrawScoreboard;
    DrawGameInfo;
    DrawMessage;
    DrawInstructions;
   End;
   gsGameOver: DrawGameOver;
  End;
  Game.needRedraw:=False;
 End;
End;

Procedure InitializeGame;Begin
 Game.gameState := gsMainMenu;
 Game.currentInning := 1;
 Game.homeScore := 0;
 Game.awayScore := 0;
 Game.outs := 0;
 Game.balls := 0;
 Game.strikes := 0;
 Game.currentBatter := 0;
 Game.currentPitcher := 0;
 Game.currentTeam := tmAway;
 Game.inningTop := True;
 Game.bases[bsFirst] := False;
 Game.bases[bsSecond] := False;
 Game.bases[bsThird] := False;
 Game.message := '';
 Game.needRedraw := True;
 Game.pitchPower := 50;
 Game.swingTiming := 0;
 Game.ball.inPlay := False;
 InitializePlayers;
 Randomize;
End;

Procedure GameLoop;Begin
 While Game.gameState<>gsQuit do Begin
  HandleInput;
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
 InitGraph(Driver, Mode, '');
 ErrCode:=GraphResult;
 If ErrCode<>grOk Then Begin
  WriteLn('Erreur graphique : ', GraphErrorMsg(ErrCode));
  Halt;
 End;
 SetLineStyle(0, 0, 1);
End;

BEGIN
 InitializeGraphics;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.