{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: MONOPOLY - Jeu de plateau graphique
  Plateau de Monopoly avec propriétés authentiques et couleurs originales
}

Program MonopolyBoard;

Uses {$IFDEF FPC}
      PtcCrt,PtcGraph
     {$ELSE}
      DOS,Graph,Crt
     {$ENDIF};

Const
 BOARD_SIZE = 400;
 CELL_SIZE = 40;
 PROPERTY_HEIGHT = 10;

Type
 TProperty = Record
  Name: String[30];
  Color: Integer;
  Price: Integer;
  Rent: Integer;
  PropertyType: Integer; { 0=Property, 1=Railroad, 2=Utility, 3=Special }
 End;

 TPlayer = Record
  Name: String[20];
  Money: Integer;
  Icon: Integer; { 0=Fer, 1=Dé, 2=Voiture, 3=Chapeau }
  IsHuman: Boolean;
  Position: Integer;
 End;

Var
 Properties: Array[0..39] of TProperty;
 Players: Array[1..4] of TPlayer;
 Dice1, Dice2: Integer;

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

Procedure InitProperties;
Begin
 { Coin inférieur droit - GO }
 Properties[0].Name := 'GO';
 Properties[0].Color := LightGreen;
 Properties[0].PropertyType := 3;
 Properties[0].Price := 0;

 { Côté bas - Groupe Marron }
 Properties[1].Name := 'Avenue Méditerranée';
 Properties[1].Color := Brown;
 Properties[1].PropertyType := 0;
 Properties[1].Price := 60;

 Properties[2].Name := 'Caisse Communauté';
 Properties[2].Color := LightBlue;
 Properties[2].PropertyType := 3;
 Properties[2].Price := 0;

 Properties[3].Name := 'Avenue Baltique';
 Properties[3].Color := Brown;
 Properties[3].PropertyType := 0;
 Properties[3].Price := 60;

 Properties[4].Name := 'Impôt sur Revenu';
 Properties[4].Color := White;
 Properties[4].PropertyType := 3;
 Properties[4].Price := 0;

 Properties[5].Name := 'Gare de Montparnasse';
 Properties[5].Color := Black;
 Properties[5].PropertyType := 1;
 Properties[5].Price := 200;

 { Groupe Bleu clair }
 Properties[6].Name := 'Avenue Orient';
 Properties[6].Color := LightCyan;
 Properties[6].PropertyType := 0;
 Properties[6].Price := 100;

 Properties[7].Name := 'Chance';
 Properties[7].Color := Red;
 Properties[7].PropertyType := 3;
 Properties[7].Price := 0;

 Properties[8].Name := 'Avenue Vermont';
 Properties[8].Color := LightCyan;
 Properties[8].PropertyType := 0;
 Properties[8].Price := 100;

 Properties[9].Name := 'Avenue Connecticut';
 Properties[9].Color := LightCyan;
 Properties[9].PropertyType := 0;
 Properties[9].Price := 120;

 { Coin inférieur gauche - Jail }
 Properties[10].Name := 'Prison';
 Properties[10].Color := LightGray;
 Properties[10].PropertyType := 3;
 Properties[10].Price := 0;

 { Côté gauche - Groupe Rose }
 Properties[11].Name := 'Place St Charles';
 Properties[11].Color := Magenta;
 Properties[11].PropertyType := 0;
 Properties[11].Price := 140;

 Properties[12].Name := 'Compagnie Électrique';
 Properties[12].Color := Yellow;
 Properties[12].PropertyType := 2;
 Properties[12].Price := 150;

 Properties[13].Name := 'Avenue États';
 Properties[13].Color := Magenta;
 Properties[13].PropertyType := 0;
 Properties[13].Price := 140;

 Properties[14].Name := 'Avenue Virginie';
 Properties[14].Color := Magenta;
 Properties[14].PropertyType := 0;
 Properties[14].Price := 160;

 Properties[15].Name := 'Gare du Nord';
 Properties[15].Color := Black;
 Properties[15].PropertyType := 1;
 Properties[15].Price := 200;

 { Groupe Orange }
 Properties[16].Name := 'Place St James';
 Properties[16].Color := Red;
 Properties[16].PropertyType := 0;
 Properties[16].Price := 180;

 Properties[17].Name := 'Caisse Communauté';
 Properties[17].Color := LightBlue;
 Properties[17].PropertyType := 3;
 Properties[17].Price := 0;

 Properties[18].Name := 'Avenue Tennessee';
 Properties[18].Color := Red;
 Properties[18].PropertyType := 0;
 Properties[18].Price := 180;

 Properties[19].Name := 'Avenue New York';
 Properties[19].Color := Red;
 Properties[19].PropertyType := 0;
 Properties[19].Price := 200;

 { Coin supérieur gauche - Free Parking }
 Properties[20].Name := 'Parc Gratuit';
 Properties[20].Color := LightRed;
 Properties[20].PropertyType := 3;
 Properties[20].Price := 0;

 { Côté haut - Groupe Rouge }
 Properties[21].Name := 'Avenue Kentucky';
 Properties[21].Color := Red;
 Properties[21].PropertyType := 0;
 Properties[21].Price := 220;

 Properties[22].Name := 'Chance';
 Properties[22].Color := Red;
 Properties[22].PropertyType := 3;
 Properties[22].Price := 0;

 Properties[23].Name := 'Avenue Indiana';
 Properties[23].Color := Red;
 Properties[23].PropertyType := 0;
 Properties[23].Price := 220;

 Properties[24].Name := 'Avenue Illinois';
 Properties[24].Color := Red;
 Properties[24].PropertyType := 0;
 Properties[24].Price := 240;

 Properties[25].Name := 'Gare de Lyon';
 Properties[25].Color := Black;
 Properties[25].PropertyType := 1;
 Properties[25].Price := 200;

 { Groupe Jaune }
 Properties[26].Name := 'Avenue Atlantique';
 Properties[26].Color := Yellow;
 Properties[26].PropertyType := 0;
 Properties[26].Price := 260;

 Properties[27].Name := 'Avenue Ventnor';
 Properties[27].Color := Yellow;
 Properties[27].PropertyType := 0;
 Properties[27].Price := 260;

 Properties[28].Name := 'Compagnie des Eaux';
 Properties[28].Color := Cyan;
 Properties[28].PropertyType := 2;
 Properties[28].Price := 150;

 Properties[29].Name := 'Jardins Marvin';
 Properties[29].Color := Yellow;
 Properties[29].PropertyType := 0;
 Properties[29].Price := 280;

 { Coin supérieur droit - Go to Jail }
 Properties[30].Name := 'Allez en Prison';
 Properties[30].Color := LightGray;
 Properties[30].PropertyType := 3;
 Properties[30].Price := 0;

 { Côté droit - Groupe Vert }
 Properties[31].Name := 'Avenue Pacifique';
 Properties[31].Color := Green;
 Properties[31].PropertyType := 0;
 Properties[31].Price := 300;

 Properties[32].Name := 'Avenue Caroline N.';
 Properties[32].Color := Green;
 Properties[32].PropertyType := 0;
 Properties[32].Price := 300;

 Properties[33].Name := 'Caisse Communauté';
 Properties[33].Color := LightBlue;
 Properties[33].PropertyType := 3;
 Properties[33].Price := 0;

 Properties[34].Name := 'Avenue Pennsylvanie';
 Properties[34].Color := Green;
 Properties[34].PropertyType := 0;
 Properties[34].Price := 320;

 Properties[35].Name := 'Gare Saint-Lazare';
 Properties[35].Color := Black;
 Properties[35].PropertyType := 1;
 Properties[35].Price := 200;

 Properties[36].Name := 'Chance';
 Properties[36].Color := Red;
 Properties[36].PropertyType := 3;
 Properties[36].Price := 0;

 { Groupe Bleu foncé }
 Properties[37].Name := 'Place du Parc';
 Properties[37].Color := Blue;
 Properties[37].PropertyType := 0;
 Properties[37].Price := 350;

 Properties[38].Name := 'Taxe de Luxe';
 Properties[38].Color := White;
 Properties[38].PropertyType := 3;
 Properties[38].Price := 0;

 Properties[39].Name := 'Promenade';
 Properties[39].Color := Blue;
 Properties[39].PropertyType := 0;
 Properties[39].Price := 400;
End;

Procedure InitPlayers;
Begin
 { Joueur 1 - Humain }
 Players[1].Name := 'Joueur Humain';
 Players[1].Money := 1500;
 Players[1].Icon := 0; { Fer à repasser }
 Players[1].IsHuman := True;
 Players[1].Position := 0;

 { Joueur 2 - Ordinateur }
 Players[2].Name := 'Ordinateur 1';
 Players[2].Money := 1500;
 Players[2].Icon := 1; { Dé à coudre }
 Players[2].IsHuman := False;
 Players[2].Position := 0;

 { Joueur 3 - Ordinateur }
 Players[3].Name := 'Ordinateur 2';
 Players[3].Money := 1500;
 Players[3].Icon := 2; { Voiture }
 Players[3].IsHuman := False;
 Players[3].Position := 0;

 { Joueur 4 - Ordinateur }
 Players[4].Name := 'Ordinateur 3';
 Players[4].Money := 1500;
 Players[4].Icon := 3; { Chapeau }
 Players[4].IsHuman := False;
 Players[4].Position := 0;
End;

Procedure DrawPlayerIcon(X, Y, IconType: Integer);
Begin
 SetColor(Black);
 Case IconType of
  0: Begin { Fer à repasser }
   SetFillStyle(SolidFill, LightGray);
   Bar(X + 2, Y + 8, X + 14, Y + 12);
   Bar(X + 4, Y + 4, X + 12, Y + 8);
   SetColor(Black);
   Rectangle(X + 2, Y + 8, X + 14, Y + 12);
   Rectangle(X + 4, Y + 4, X + 12, Y + 8);
   Line(X + 8, Y + 4, X + 8, Y + 2);
  End;
  
  1: Begin { Dé à coudre }
   SetFillStyle(SolidFill, Yellow);
   Bar(X + 4, Y + 2, X + 12, Y + 14);
   SetColor(Black);
   Rectangle(X + 4, Y + 2, X + 12, Y + 14);
   { Petits trous }
   SetColor(Black);
   Circle(X + 6, Y + 5, 1);
   Circle(X + 10, Y + 5, 1);
   Circle(X + 6, Y + 8, 1);
   Circle(X + 10, Y + 8, 1);
   Circle(X + 6, Y + 11, 1);
   Circle(X + 10, Y + 11, 1);
  End;
  
  2: Begin { Voiture }
   SetFillStyle(SolidFill, Red);
   Bar(X + 2, Y + 8, X + 14, Y + 12);
   Bar(X + 4, Y + 4, X + 12, Y + 8);
   SetColor(Black);
   Rectangle(X + 2, Y + 8, X + 14, Y + 12);
   Rectangle(X + 4, Y + 4, X + 12, Y + 8);
   { Roues }
   SetColor(Black);
   Circle(X + 4, Y + 12, 2);
   Circle(X + 12, Y + 12, 2);
  End;
  
  3: Begin { Chapeau }
   SetFillStyle(SolidFill, Brown);
   Bar(X + 2, Y + 12, X + 14, Y + 14);
   Bar(X + 6, Y + 4, X + 10, Y + 12);
   SetColor(Black);
   Rectangle(X + 2, Y + 12, X + 14, Y + 14);
   Rectangle(X + 6, Y + 4, X + 10, Y + 12);
  End;
 End;
End;

Procedure DrawPlayersInfo;
Var
 I: Integer;
 MoneyStr: String;
Begin
 { Dessiner la zone des joueurs - élargie de 50 pixels }
 SetColor(Black);
 SetFillStyle(SolidFill, DarkGray);
 Bar(420, 300, 630, 450);
 Rectangle(420, 300, 630, 450);
 
 { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(520, 310, 'JOUEURS');
 
 { Afficher chaque joueur }
 For I := 1 to 4 Do Begin
  { Icône du joueur }
  DrawPlayerIcon(430, 320 + (I - 1) * 30, Players[I].Icon);
  
  { Nom du joueur }
  SetColor(White);
  If Players[I].IsHuman Then
   SetColor(Yellow);
  OutTextXY(450, 325 + (I - 1) * 30, Players[I].Name);
  
  { Montant d'argent - déplacé de 50 pixels }
  SetColor(LightGreen);
  Str(Players[I].Money, MoneyStr);
  OutTextXY(570, 325 + (I - 1) * 30, MoneyStr + '$');
 End;
End;

Procedure DrawDice(X, Y, Value: Integer);
Var
 I, J, DotX, DotY: Integer;
Begin
 { Dessiner le fond du dé }
 SetColor(Black);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + 50, Y + 50);
 Rectangle(X, Y, X + 50, Y + 50);
 
 { Dessiner les points selon la valeur }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 
 Case Value of
  1: Begin
   { Centre }
   FillEllipse(X + 25, Y + 25, 4, 4);
  End;
  
  2: Begin
   { Diagonal }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 35, Y + 35, 4, 4);
  End;
  
  3: Begin
   { Diagonal + centre }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 25, Y + 25, 4, 4);
   FillEllipse(X + 35, Y + 35, 4, 4);
  End;
  
  4: Begin
   { Quatre coins }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 35, Y + 15, 4, 4);
   FillEllipse(X + 15, Y + 35, 4, 4);
   FillEllipse(X + 35, Y + 35, 4, 4);
  End;
  
  5: Begin
   { Quatre coins + centre }
   FillEllipse(X + 15, Y + 15, 4, 4);
   FillEllipse(X + 35, Y + 15, 4, 4);
   FillEllipse(X + 25, Y + 25, 4, 4);
   FillEllipse(X + 15, Y + 35, 4, 4);
   FillEllipse(X + 35, Y + 35, 4, 4);
  End;
  
  6: Begin
   { Deux colonnes de trois }
   FillEllipse(X + 15, Y + 12, 4, 4);
   FillEllipse(X + 15, Y + 25, 4, 4);
   FillEllipse(X + 15, Y + 38, 4, 4);
   FillEllipse(X + 35, Y + 12, 4, 4);
   FillEllipse(X + 35, Y + 25, 4, 4);
   FillEllipse(X + 35, Y + 38, 4, 4);
  End;
 End;
End;

Procedure DrawDiceArea;
Var
 SumStr: String;
Begin
 { Dessiner la zone des dés - élargie de 50 pixels }
 SetColor(Black);
 SetFillStyle(SolidFill, DarkGray);
 Bar(420, 150, 630, 280);
 Rectangle(420, 150, 630, 280);
 
 { Titre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(460, 160, 'LANCER DES');
 
 { Dessiner les deux dés }
 DrawDice(465, 180, Dice1);
 DrawDice(525, 180, Dice2);
 
 { Afficher la somme }
 SetColor(Yellow);
 SetTextStyle(DefaultFont, HorizDir, 2);
 Str(Dice1 + Dice2, SumStr);
 OutTextXY(520, 240, SumStr);
 
 { Instructions }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(420, 260, 'Appuyez ESPACE pour lancer');
End;

Procedure GetCellPosition(Index: Integer; Var X, Y: Integer);
Begin
 { Calcule la position X,Y d'une cellule selon son index }
 If Index <= 10 Then Begin
  { Côté bas - de droite à gauche }
  X := 360 - (Index * CELL_SIZE);
  Y := 360;
 End Else If Index <= 20 Then Begin
  { Côté gauche - de bas en haut }
  X := 0;
  Y := 360 - ((Index - 10) * CELL_SIZE);
 End Else If Index <= 30 Then Begin
  { Côté haut - de gauche à droite }
  X := (Index - 20) * CELL_SIZE;
  Y := 0;
 End Else Begin
  { Côté droit - de haut en bas }
  X := 360;
  Y := (Index - 30) * CELL_SIZE;
 End;
End;

Procedure DrawProperty(Index: Integer);
Var
 X, Y: Integer;
 PriceStr: String;
Begin
 GetCellPosition(Index, X, Y);
 
 { Dessiner la cellule de base }
 SetColor(Black);
 SetFillStyle(SolidFill, White);
 Bar(X, Y, X + CELL_SIZE, Y + CELL_SIZE);
 Rectangle(X, Y, X + CELL_SIZE, Y + CELL_SIZE);
 
 { Dessiner la bande de couleur pour les propriétés }
 If Properties[Index].PropertyType = 0 Then Begin
  SetFillStyle(SolidFill, Properties[Index].Color);
  If (Index <= 10) Or (Index > 30) Then Begin
   { Côté bas et droit - bande en haut }
   Bar(X + 1, Y + 1, X + CELL_SIZE - 1, Y + PROPERTY_HEIGHT);
  End Else Begin
   { Côté gauche et haut - bande à gauche ou en bas }
   If Index <= 20 Then
    Bar(X + 1, Y + 1, X + PROPERTY_HEIGHT, Y + CELL_SIZE - 1)
   Else
    Bar(X + 1, Y + CELL_SIZE - PROPERTY_HEIGHT, X + CELL_SIZE - 1, Y + CELL_SIZE - 1);
  End;
 End;
 
 { Dessiner le texte du nom }
 SetColor(Black);
 SetTextStyle(DefaultFont, HorizDir, 1);
 
 { Ajuster le texte selon la position }
 If Index <= 10 Then Begin
  { Côté bas - texte vertical }
  If Length(Properties[Index].Name) > 8 Then
   OutTextXY(X + 5, Y + 12, Copy(Properties[Index].Name, 1, 8))
  Else
   OutTextXY(X + 5, Y + 12, Properties[Index].Name);
 End Else If Index <= 20 Then Begin
  { Côté gauche - texte horizontal }
  If Length(Properties[Index].Name) > 6 Then
   OutTextXY(X + 12, Y + 15, Copy(Properties[Index].Name, 1, 6))
  Else
   OutTextXY(X + 12, Y + 15, Properties[Index].Name);
 End Else If Index <= 30 Then Begin
  { Côté haut - texte vertical }
  If Length(Properties[Index].Name) > 8 Then
   OutTextXY(X + 5, Y + 25, Copy(Properties[Index].Name, 1, 8))
  Else
   OutTextXY(X + 5, Y + 25, Properties[Index].Name);
 End Else Begin
  { Côté droit - texte horizontal }
  If Length(Properties[Index].Name) > 6 Then
   OutTextXY(X + 12, Y + 15, Copy(Properties[Index].Name, 1, 6))
  Else
   OutTextXY(X + 12, Y + 15, Properties[Index].Name);
 End;
 
 { Afficher le prix pour les propriétés }
 If Properties[Index].Price > 0 Then Begin
  Str(Properties[Index].Price, PriceStr);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(X + 5, Y + 30, PriceStr + '$');
 End;
End;

Procedure DrawCorners;
Begin
 { Coin GO (0) }
 SetColor(Black);
 SetFillStyle(SolidFill, LightGreen);
 Bar(360, 360, 400, 400);
 Rectangle(360, 360, 400, 400);
 SetColor(Black);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(370, 370, 'DEPART');
 OutTextXY(365, 385, 'Touchez');
 OutTextXY(368, 395, '200$');
 
 { Coin JAIL (10) }
 SetFillStyle(SolidFill, LightGray);
 Bar(0, 360, 40, 400);
 Rectangle(0, 360, 40, 400);
 SetColor(Black);
 OutTextXY(8, 370, 'PRISON');
 OutTextXY(5, 385, 'Simple');
 OutTextXY(3, 395, 'Visite');
 
 { Coin FREE PARKING (20) }
 SetFillStyle(SolidFill, LightRed);
 Bar(0, 0, 40, 40);
 Rectangle(0, 0, 40, 40);
 SetColor(Black);
 OutTextXY(5, 10, 'PARC');
 OutTextXY(3, 25, 'GRATUIT');
 
 { Coin GO TO JAIL (30) }
 SetFillStyle(SolidFill, LightGray);
 Bar(360, 0, 400, 40);
 Rectangle(360, 0, 400, 40);
 SetColor(Black);
 OutTextXY(365, 10, 'ALLEZ');
 OutTextXY(363, 25, 'PRISON');
End;

Procedure DrawBoard;
Var
 I: Integer;
Begin
 { Fond noir }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(0, 0, 640, 480);
 
 { Centre du plateau }
 SetFillStyle(SolidFill, Green);
 Bar(40, 40, 360, 360);
 
 { Titre au centre }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(150, 150, 'MONOPOLY');
 
 { Logo au centre }
 SetColor(Red);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(170, 180, 'Le Jeu de Plateau');
 OutTextXY(165, 195, 'des Affaires et');
 OutTextXY(175, 210, 'Propriétés');
 
 { Dessiner les coins spéciaux }
 DrawCorners;
 
 { Dessiner toutes les propriétés }
 For I := 1 to 39 Do Begin
  If (I <> 10) And (I <> 20) And (I <> 30) Then
   DrawProperty(I);
 End;
 
 { Dessiner la zone des dés }
 DrawDiceArea;
 
 { Dessiner les informations des joueurs }
 DrawPlayersInfo;
End;

Procedure DrawSpecialSymbols;
Begin
 { Dessiner des symboles spéciaux }
 SetColor(White);
 
 { Chance - point d'interrogation }
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(100, 100, '?');
 OutTextXY(250, 250, '?');
 
 { Community Chest - coffre }
 SetColor(Yellow);
 Rectangle(80, 280, 110, 300);
 SetColor(Brown);
 Rectangle(85, 285, 105, 295);
End;

BEGIN
 Randomize;
 
 { Initialiser les dés }
 Dice1 := Random(6) + 1;
 Dice2 := Random(6) + 1;
 
 InitScreen;
 InitProperties;
 InitPlayers;
 DrawBoard;
 DrawSpecialSymbols;
 
 { Boucle principale }
 Repeat
  Case ReadKey of
   ' ': Begin
    { Lancer les dés }
    Dice1 := Random(6) + 1;
    Dice2 := Random(6) + 1;
    DrawDiceArea;
   End;
   #27: Break; { Escape pour quitter }
  End;
 Until False;
 
 CloseGraph;
END.
