{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: CRAPS - Jeu de dés de casino
  Règles: Premier lancer - 7 ou 11 = gagné, 2,3,12 = perdu
  Autres nombres deviennent le "point" - relancer jusqu'à obtenir le point (gagné) ou 7 (perdu)
}

Program GameCraps;

Uses {$IFDEF FPC}
      PtcCrt,PtcGraph,PtcMouse
     {$ELSE}
      Graph,Crt
     {$ENDIF};

Const
 SCREEN_WIDTH = 640;
 SCREEN_HEIGHT = 480;
 DIE_SIZE = 60;
 
 { Couleurs personnalisées }
 Green = 2;
 DarkGreen = 1;
 
 { États du jeu }
 GAME_COME_OUT = 0;  { Premier lancer }
 GAME_POINT = 1;     { Phase point }
 GAME_WON = 2;       { Gagné }
 GAME_LOST = 3;      { Perdu }
 
 { Résultats possibles }
 RESULT_NATURAL = 0;    { 7 ou 11 au premier lancer }
 RESULT_CRAPS = 1;      { 2, 3 ou 12 au premier lancer }
 RESULT_POINT = 2;      { Point établi }
 RESULT_SEVEN_OUT = 3;  { 7 en phase point }
 RESULT_POINT_MADE = 4; { Point refait }

Type
 TDie = Record
  Value: Integer;
  X, Y: Integer;
 End;

 TGameState = Record
  Die1, Die2: TDie;
  Total: Integer;
  Point: Integer;
  GamePhase: Integer;
  Message: String;
  SubMessage: String;
  Credits: Integer;
  Bet: Integer;
  NeedRedraw: Boolean;
  RollCount: Integer;
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
 Function MouseDriverFound: Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse;
 Begin
  { Pas d'implémentation pour Free Pascal }
 End;

 Procedure GetMouseState(Var X, Y, Button: LongInt);
 Begin
  { Implémentation basique pour Free Pascal }
  X := 0; Y := 0; Button := 0;
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

Procedure DrawDie(X, Y: Integer; Value: Integer);
Begin
 { Fond du dé }
 SetColor(White);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + DIE_SIZE, Y + DIE_SIZE);
 
 { Bordure }
 SetColor(Black);
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

Procedure DrawDice;
Begin
 { Positionner les dés au centre }
 Game.Die1.X := 250;
 Game.Die1.Y := 200;
 Game.Die2.X := 330;
 Game.Die2.Y := 200;
 
 DrawDie(Game.Die1.X, Game.Die1.Y, Game.Die1.Value);
 DrawDie(Game.Die2.X, Game.Die2.Y, Game.Die2.Value);
End;

Procedure DrawTokens;
Var
 I, TokenCount: Integer;
 X, Y: Integer;
Begin
 { Déterminer le nombre de jetons selon la mise }
 Case Game.Bet of
  5: TokenCount := 1;
  10: TokenCount := 2;
  25: TokenCount := 3;
  50: TokenCount := 4;
  100: TokenCount := 5;
  Else TokenCount := 0;
 End;
 
 { Position des jetons dans le coin supérieur droit }
 X := 550;
 Y := 70;
 
 { Dessiner les jetons empilés }
 For I := 1 to TokenCount Do Begin
  { Ombre du jeton }
  SetColor(DarkGray);
  SetFillStyle(SolidFill, DarkGray);
  FillEllipse(X + 2, Y - (I-1) * 3 + 2, 15, 15);
  
  { Jeton principal - alterner entre bleu foncé et rouge }
  If I Mod 2 = 1 Then Begin
   { Jeton bleu foncé (jetons impairs) }
   SetColor(Blue);
   SetFillStyle(SolidFill, Blue);
  End Else Begin
   { Jeton rouge (jetons pairs) }
   SetColor(Red);
   SetFillStyle(SolidFill, Red);
  End;
  FillEllipse(X, Y - (I-1) * 3, 15, 15);
  
  { Bordure du jeton }
  SetColor(White);
  Circle(X, Y - (I-1) * 3, 15);
  
  { Cercle intérieur pour l'effet 3D }
  SetColor(Black);
  Circle(X, Y - (I-1) * 3, 12);
  
  { Point central }
  SetColor(White);
  FillEllipse(X, Y - (I-1) * 3, 3, 3);
 End;
 
 { Afficher le texte "MISE" }
 If TokenCount > 0 Then Begin
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X - 10, Y + 40, 'MISE');
 End;
End;

Procedure DrawGameInfo;
Var
 TotalText, PointText, CreditsText, BetText, RollText: String;
Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(250, 20, 'CRAPS');
 
 SetTextStyle(DefaultFont, HorizDir, 1);
 
 { Afficher le total }
 Str(Game.Total, TotalText);
 OutTextXY(300, 330, 'Total: ' + TotalText);
 
 { Afficher le point s'il y en a un }
 If Game.Point > 0 Then Begin
  Str(Game.Point, PointText);
  OutTextXY(300, 350, 'Point: ' + PointText);
 End;
 
 { Afficher les crédits et mise }
 Str(Game.Credits, CreditsText);
 Str(Game.Bet, BetText);
 OutTextXY(50, 50, 'Credits: ' + CreditsText);
 OutTextXY(50, 70, 'Mise: ' + BetText);
 
 { Afficher le nombre de lancers }
 Str(Game.RollCount, RollText);
 OutTextXY(50, 90, 'Lancers: ' + RollText);
 
 { Afficher la phase de jeu }
 Case Game.GamePhase of
  GAME_COME_OUT: OutTextXY(50, 110, 'Phase: Come Out');
  GAME_POINT: OutTextXY(50, 110, 'Phase: Point');
  GAME_WON: OutTextXY(50, 110, 'Phase: GAGNE!');
  GAME_LOST: OutTextXY(50, 110, 'Phase: PERDU!');
 End;
End;

Procedure DrawMessages;
Begin
 { Choisir la couleur selon la phase du jeu }
 Case Game.GamePhase of
  GAME_WON: SetColor(Green);     { Messages de victoire en vert }
  GAME_LOST: SetColor(Red);      { Messages de défaite en rouge }
  Else SetColor(Yellow);         { Messages normaux en jaune }
 End;
 
 SetTextStyle(DefaultFont, HorizDir, 1);
 
 { Message principal }
 OutTextXY(50, 350, Game.Message);
 
 { Sous-message }
 If Game.SubMessage <> '' Then Begin
  OutTextXY(50, 370, Game.SubMessage);
 End;
End;

Procedure DrawInstructions;
Begin
 SetColor(LightGray);
 SetTextStyle(DefaultFont, HorizDir, 1);
 
 OutTextXY(400, 350, 'Instructions:');
 OutTextXY(400, 370, 'ESPACE - Lancer les des');
 OutTextXY(400, 390, 'N - Nouvelle partie');
 OutTextXY(400, 410, 'ESC - Quitter');
 
 { Afficher les boutons de mise avec détails }
 OutTextXY(400, 430, 'Mises: 1=5  2=10  3=25  4=50  5=100');
End;

Procedure DrawBackground;
Begin
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
 
 { Cadre principal }
 SetColor(White);
 Rectangle(10, 10, SCREEN_WIDTH - 10, SCREEN_HEIGHT - 10);
 
 { Table de craps avec coins arrondis - élargie de 2 fois }
 SetColor(DarkGreen);
 SetFillStyle(SolidFill, DarkGreen);
 
 { Corps principal de la table - largeur augmentée de 50 pixels }
 Bar(95, 140, 555, 340);
 
 { Coins arrondis - gauche }
 FillEllipse(95, 160, 20, 20);
 FillEllipse(95, 320, 20, 20);
 Bar(75, 160, 95, 320);
 
 { Coins arrondis - droite }
 FillEllipse(555, 160, 20, 20);
 FillEllipse(555, 320, 20, 20);
 Bar(555, 160, 575, 320);
 
 { Bordure verte de la table }
 SetColor(Green);
 SetLineStyle(SolidLn, 0, ThickWidth);
 
 { Bordures droites }
 Line(95, 140, 555, 140); { Haut }
 Line(95, 340, 555, 340); { Bas }
 Line(75, 160, 75, 320); { Gauche }
 Line(575, 160, 575, 320); { Droite }
 
 { Bordures courbes }
 Arc(95, 160, 90, 180, 20);  { Coin haut-gauche }
 Arc(95, 320, 180, 270, 20); { Coin bas-gauche }
 Arc(555, 160, 0, 90, 20);    { Coin haut-droite }
 Arc(555, 320, 270, 360, 20); { Coin bas-droite }
 
 { Ligne centrale de la table }
 SetColor(White);
 SetLineStyle(SolidLn, 0, NormWidth);
 Line(325, 160, 325, 320);
 
 { Lignes blanches pour délimiter les zones de paris }
 { Ligne horizontale pour séparer PASS/DON'T PASS }
 Line(95, 240, 555, 240);
 
 { Lignes verticales pour délimiter les sections }
 Line(200, 160, 200, 320); { Sépare la zone gauche }
 Line(450, 160, 450, 320); { Sépare la zone droite }
 
 { Lignes pour les zones de nombres }
 Line(115, 180, 185, 180); { Ligne au-dessus de PASS }
 Line(115, 200, 185, 200); { Ligne en dessous de PASS }
 Line(115, 280, 185, 280); { Ligne au-dessus de DON'T PASS }
 Line(115, 300, 185, 300); { Ligne en dessous de DON'T PASS }
 
 Line(340, 180, 435, 180); { Ligne au-dessus de COME }
 Line(340, 200, 435, 200); { Ligne en dessous de COME }
 Line(340, 280, 435, 280); { Ligne au-dessus de DON'T COME }
 Line(340, 300, 435, 300); { Ligne en dessous de DON'T COME }
 
 { Lignes pour délimiter les zones de nombres de points }
 Line(220, 160, 220, 200); { Sépare 4 }
 Line(240, 160, 240, 200); { Sépare 5 }
 Line(260, 160, 260, 200); { Sépare SIX }
 Line(290, 160, 290, 200); { Sépare 8 }
 Line(310, 160, 310, 200); { Sépare NINE }
 Line(335, 160, 335, 200); { Sépare 10 }
 
 Line(220, 280, 220, 320); { Sépare 4 (bas) }
 Line(240, 280, 240, 320); { Sépare 5 (bas) }
 Line(260, 280, 260, 320); { Sépare SIX (bas) }
 Line(290, 280, 290, 320); { Sépare 8 (bas) }
 Line(310, 280, 310, 320); { Sépare NINE (bas) }
 Line(335, 280, 335, 320); { Sépare 10 (bas) }
 
 { Zones de paris simplifiées }
 SetColor(Yellow);
 OutTextXY(115, 170, 'PASS');
 OutTextXY(115, 300, 'DON''T PASS');
 SetColor(Red);
 OutTextXY(405, 170, 'COME');
 OutTextXY(405, 300, 'DON''T COME');
 
 { Zones de nombres de points - rangée supérieure }
 SetColor(White);
 OutTextXY(225, 170, '4');
 OutTextXY(245, 170, '5');
 OutTextXY(265, 170, 'SIX');
 OutTextXY(295, 170, '8');
 OutTextXY(315, 170, 'NINE');
 OutTextXY(340, 170, '10');
 
 { Zones de nombres de points - rangée inférieure }
 OutTextXY(225, 300, '4');
 OutTextXY(245, 300, '5');
 OutTextXY(265, 300, 'SIX');
 OutTextXY(295, 300, '8');
 OutTextXY(315, 300, 'NINE');
 OutTextXY(340, 300, '10');
 
 SetColor(Yellow);
End;

Procedure DrawScreen;
Begin
 DrawBackground;
 DrawDice;
 DrawTokens;
 DrawGameInfo;
 DrawMessages;
 DrawInstructions;
End;

Function EvaluateRoll: Integer;
Begin
 Case Game.Total of
  7, 11: Begin
   If Game.GamePhase = GAME_COME_OUT Then
    EvaluateRoll := RESULT_NATURAL
   Else
    EvaluateRoll := RESULT_SEVEN_OUT;
  End;
  2, 3, 12: Begin
   If Game.GamePhase = GAME_COME_OUT Then
    EvaluateRoll := RESULT_CRAPS
   Else
    EvaluateRoll := RESULT_POINT;
  End;
  Else Begin
   If Game.GamePhase = GAME_COME_OUT Then
    EvaluateRoll := RESULT_POINT
   Else Begin
    If Game.Total = Game.Point Then
     EvaluateRoll := RESULT_POINT_MADE
    Else
     EvaluateRoll := RESULT_POINT;
   End;
  End;
 End;
End;

Procedure RollDice;
Var
 Result: Integer;
 PointText: String;
Begin
 { Lancer les dés }
 Game.Die1.Value := Random(6) + 1;
 Game.Die2.Value := Random(6) + 1;
 Game.Total := Game.Die1.Value + Game.Die2.Value;
 Inc(Game.RollCount);
 
 { Évaluer le résultat }
 Result := EvaluateRoll;
 
 Case Result of
  RESULT_NATURAL: Begin
   Game.Message := 'NATURAL! Vous avez gagne!';
   Game.SubMessage := 'Vous remportez votre mise';
   Game.Credits := Game.Credits + Game.Bet;
   Game.GamePhase := GAME_WON;
  End;
  
  RESULT_CRAPS: Begin
   Game.Message := 'CRAPS! Vous avez perdu!';
   Game.SubMessage := 'Vous perdez votre mise';
   Game.Credits := Game.Credits - Game.Bet;
   Game.GamePhase := GAME_LOST;
  End;
  
  RESULT_POINT: Begin
   If Game.GamePhase = GAME_COME_OUT Then Begin
    Game.Point := Game.Total;
    Game.GamePhase := GAME_POINT;
    Str(Game.Point, PointText);
    Game.Message := 'Point etabli: ' + PointText;
    Game.SubMessage := 'Relancez pour obtenir le point ou eviter le 7';
   End Else Begin
    Str(Game.Point, PointText);
    Game.Message := 'Continuez... Point: ' + PointText;
    Game.SubMessage := 'Il faut obtenir ' + PointText + ' avant le 7';
   End;
  End;
  
  RESULT_SEVEN_OUT: Begin
   Game.Message := 'SEVEN OUT! Vous avez perdu!';
   Game.SubMessage := 'Vous perdez votre mise';
   Game.Credits := Game.Credits - Game.Bet;
   Game.GamePhase := GAME_LOST;
  End;
  
  RESULT_POINT_MADE: Begin
   Game.Message := 'POINT MADE! Vous avez gagne!';
   Game.SubMessage := 'Vous remportez votre mise';
   Game.Credits := Game.Credits + Game.Bet;
   Game.GamePhase := GAME_WON;
  End;
 End;
 
 Game.NeedRedraw := True;
End;

Procedure InitGame;
Begin
 { Initialiser les dés avec des valeurs aléatoires }
 Game.Die1.Value := Random(6) + 1;
 Game.Die2.Value := Random(6) + 1;
 Game.Total := Game.Die1.Value + Game.Die2.Value;
 Game.Point := 0;
 Game.GamePhase := GAME_COME_OUT;
 Game.Message := 'Appuyez sur ESPACE pour commencer';
 Game.SubMessage := 'Come Out Roll - 7,11 gagne / 2,3,12 perd';
 Game.Credits := 100;
 Game.Bet := 10;
 Game.NeedRedraw := True;
 Game.RollCount := 0;
End;

Procedure NewGame;
Begin
 { Réinitialiser les dés avec des valeurs aléatoires }
 Game.Die1.Value := Random(6) + 1;
 Game.Die2.Value := Random(6) + 1;
 Game.Total := Game.Die1.Value + Game.Die2.Value;
 Game.Point := 0;
 Game.GamePhase := GAME_COME_OUT;
 Game.Message := 'Nouvelle partie - Appuyez sur ESPACE';
 Game.SubMessage := 'Come Out Roll - 7,11 gagne / 2,3,12 perd';
 Game.RollCount := 0;
 Game.NeedRedraw := True;
End;

Procedure HandleInput;
Var
 Key: Char;
Begin
 If KeyPressed Then Begin
  Key := ReadKey;
  Case Key of
   ' ': Begin { Espace - Lancer les dés }
    If (Game.GamePhase = GAME_COME_OUT) Or (Game.GamePhase = GAME_POINT) Then Begin
     If Game.Credits >= Game.Bet Then Begin
      RollDice;
     End Else Begin
      Game.Message := 'Credits insuffisants!';
      Game.SubMessage := 'Appuyez sur N pour une nouvelle partie';
      Game.NeedRedraw := True;
     End;
    End;
   End;
   
   '1': Begin { Mise 5 }
    Game.Bet := 5;
    Game.NeedRedraw := True;
   End;
   
   '2': Begin { Mise 10 }
    Game.Bet := 10;
    Game.NeedRedraw := True;
   End;
   
   '3': Begin { Mise 25 }
    Game.Bet := 25;
    Game.NeedRedraw := True;
   End;
   
   '4': Begin { Mise 50 }
    Game.Bet := 50;
    Game.NeedRedraw := True;
   End;
   
   '5': Begin { Mise 100 }
    Game.Bet := 100;
    Game.NeedRedraw := True;
   End;
   
   'n', 'N': Begin { Nouvelle partie }
    If (Game.GamePhase = GAME_WON) Or (Game.GamePhase = GAME_LOST) Then Begin
     NewGame;
    End Else Begin
     InitGame;
    End;
   End;
   
   #27: Begin { Escape - Quitter }
    CloseGraph;
    Halt;
   End;
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
  
  Delay(50);
 Until False;
END.
