{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program SevenIsles;

Uses {$IFDEF FPC}
      DOS,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  MENU_X = 50;
  MENU_Y = 120;
  MENU_WIDTH = 400;
  MENU_HEIGHT = 300;
  VISIBLE_ITEMS = 12;

Type
 TGameInfo=Record
  Title:String[40];
  ProgramExec:String[20];
 End;

Const
  MAX_GAMES = 73;
  Games: Array[1..MAX_GAMES] of TGameInfo = (
    (Title: '649 - Lotto 6/49'; ProgramExec: '649.EXE'),
    (Title: '2048 - Puzzle de nombres'; ProgramExec: '2048.EXE'),
    (Title: 'Anagram - Jeu de mots'; ProgramExec: 'ANAGRAM.EXE'),
    (Title: 'Asteroid - Jeu spatial'; ProgramExec: 'ASTEROID.EXE'),
    (Title: 'Baccarat - Jeu de carte'; ProgramExec: 'BACCARAT.EXE'),
    (Title: 'Backgammon - Jeu de strategie'; ProgramExec: 'BACKGAM.EXE'),
    (Title: 'Barbu - Jeu de carte'; ProgramExec: 'BARBU.EXE'),
    (Title: 'Baseball - Jeu de sport'; ProgramExec: 'BASEBALL.EXE'),
    (Title: 'Berzerk - Labyrinthe action'; ProgramExec: 'BERZERK.EXE'),
    (Title: 'Billard - Jeu de billard'; ProgramExec: 'BILLARD.EXE'),
    (Title: 'Bingo - Jeu de hasard'; ProgramExec: 'BINGO.EXE'),
    (Title: 'Blackjack - Jeu de cartes'; ProgramExec: 'BLACJACK.EXE'),
    (Title: 'Blox - Puzzle de blocs'; ProgramExec: 'BLOX.EXE'),
    (Title: 'Bouncing Babies'; ProgramExec: 'BABY.EXE'),
    (Title: 'Bourr‚ - Jeu de carte'; ProgramExec: 'BOURRE.EXE'),
    (Title: 'Bowling'; ProgramExec: 'BOWLING.EXE'),
    (Title: 'Breakout - Casse-briques'; ProgramExec: 'BREAKOUT.EXE'),
    (Title: 'Bubble Shooter'; ProgramExec: 'BS.EXE'),
    (Title: 'Cannonball - Tir au canon'; ProgramExec: 'CANNONBA.EXE'),
    (Title: 'Centipede - Arcade insecte'; ProgramExec: 'CENTIPED.EXE'),
    (Title: 'Checkers - Jeu de dames'; ProgramExec: 'CHECKERS.EXE'),
    (Title: 'Coco-Yathzee - Jeu de d‚s'; ProgramExec: 'CYATHZEE.EXE'),
    (Title: 'Color Space Invaders'; ProgramExec: 'CSI.EXE'),
    (Title: 'Domino'; ProgramExec: 'DOMINO.EXE'),
    (Title: 'Dr Mario - Puzzle medical'; ProgramExec: 'DRMARIO.EXE'),
    (Title: 'FreeCell - Jeu de carte'; ProgramExec: 'FREECELL.EXE'),
    (Title: 'Frogger - Traversee de route'; ProgramExec: 'FROGGER.EXE'),
    (Title: 'Gin Rummmy - Jeu de carte'; ProgramExec: 'GINRUMMY.EXE'),
    (Title: 'Golf - Jeu de carte'; ProgramExec: 'GOLF.EXE'),
    (Title: 'Gomoku - Alignement 5 pions'; ProgramExec: 'GOMOKU.EXE'),
    (Title: 'Gravity - Jeu de gravit‚'; ProgramExec: 'GRAVITY.EXE'),
    (Title: 'Hangman - Jeu du pendu'; ProgramExec: 'HANGMAN.EXE'),
    (Title: 'Hex 2048'; ProgramExec: 'HEX2048.EXE'),
    (Title: 'Keno - Jeu de hasard'; ProgramExec: 'KENO.EXE'),
    (Title: 'L25 - Jeu de logique'; ProgramExec: 'L25.EXE'),
    (Title: 'Lights Out - Eteindre des lumiŠres'; ProgramExec: 'LIGHTS.EXE'),
    (Title: 'Lode Runner - Plateforme action'; ProgramExec: 'LODERUNN.EXE'),
    (Title: 'Lunar - Atterrissage lunaire'; ProgramExec: 'LUNAR.EXE'),
    (Title: 'Mahjong - Jeu de tuiles'; ProgramExec: 'MAHJONG.EXE'),
    (Title: 'Mancala - Jeu de billes'; ProgramExec: 'MANCALA.EXE'),
    (Title: 'MasterMind - Jeu de r‚flexion'; ProgramExec: 'MASTERMD.EXE'),
    (Title: 'Matching - Jeu d association'; ProgramExec: 'MATCHING.EXE'),
    (Title: 'Missile Command'; ProgramExec: 'MISSILE.EXE'),
    (Title: 'Mouse Trap'; ProgramExec: 'MOUSETRP.EXE'),
    (Title: 'Nibbles'; ProgramExec: 'NIBBLES.EXE'),
    (Title: 'O''Riley''s Mine'; ProgramExec: 'ORILEYS.EXE'),
    (Title: 'Othello - Jeu de plateau'; ProgramExec: 'OTHELLO.EXE'),
    (Title: 'Pac-Man - Labyrinthe arcade'; ProgramExec: 'PACMAN.EXE'),
    (Title: 'Pango'; ProgramExec: 'PANGO.EXE'),
    (Title: 'Patience - Jeu de carte'; ProgramExec: 'PATIENCE.EXE'),
    (Title: 'Peg Leap - Jeu de jeton'; ProgramExec: 'PEGLEAP.EXE'),
    (Title: 'Pipe Game - Jeu de deplacer les tuyaux'; ProgramExec: 'PIPE.EXE'),
    (Title: 'Poker - Jeu de carte'; ProgramExec: 'POKER.EXE'),
    (Title: 'Pong - Tennis electronique'; ProgramExec: 'PONG.EXE'),
    (Title: 'Puissance 4 - Alignement vertical'; ProgramExec: 'PUISS4.EXE'),
    (Title: 'QBert - Jeu de saut'; ProgramExec: 'QBERT.EXE'),
    (Title: 'Renju - Gomoku avance'; ProgramExec: 'RENJU.EXE'),
    (Title: 'Reversi - Retournement de pions'; ProgramExec: 'REVERSI.EXE'),
    (Title: 'Roulette - Jeu de casino'; ProgramExec: 'ROULETTE.EXE'),
    (Title: 'Rummy Cube - Jeu de tuiles'; ProgramExec: 'RUMMYCUB.EXE'),
    (Title: 'Sodoku - Puzzle de chiffres'; ProgramExec: 'SODOKU.EXE'),
    (Title: 'Sokoban - Pousse-caisses'; ProgramExec: 'SOKOBAN.EXE'),
    (Title: 'Solitaire - Jeu de cartes'; ProgramExec: 'SOLITAIR.EXE'),
    (Title: 'Space Invaders - Envahisseurs spatiaux'; ProgramExec: 'INVADERS.EXE'),
    (Title: 'Space Jockey - Pilote spatial'; ProgramExec: 'SPACEJOC.EXE'),
    (Title: 'Tetris - Puzzle de blocs'; ProgramExec: 'TETRIS.EXE'),
    (Title: 'TileMan'; ProgramExec: 'TILEMAN.EXE'),
    (Title: 'Tic-Tac-Toe - Morpion classique'; ProgramExec: 'TTT.EXE'),
    (Title: 'Tic-Tac-Toe 3D'; ProgramExec: 'TTT3D.EXE'),
    (Title: 'Tours de Hanoi'; ProgramExec: 'HANOIS.EXE'),
    (Title: 'VIC Avenger - Combat aerien'; ProgramExec: 'AVENGER.EXE'),
    (Title: 'Xiangqi - Echecs chinois'; ProgramExec: 'XIANGQI.EXE'),
    (Title: 'Yathzee - Jeu de des'; ProgramExec: 'YATHZEE.EXE')
  );

Var
  CurrentSelection: Integer;
  ScrollPosition: Integer;
  ExitMenu: Boolean;
  LastSelection: Integer;
  LastScrollPosition: Integer;
  NeedRedraw: Boolean;

Procedure InitScreen;
Var
 Driver,Mode:Integer;
 ErrCode:Integer;
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

Procedure DrawOcean;
Var
 I, J: Integer;
 WaveOffset: Integer;
Begin
  { Fond ocean bleu }
 SetColor(Blue);
 SetFillStyle(SolidFill, Blue);
 Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  { Ajouter des vagues }
 SetColor(LightBlue);
 For J := 0 to SCREEN_HEIGHT div 20 do Begin
  WaveOffset := (J * 3) mod 10;
  For I := 0 to SCREEN_WIDTH div 15 do Begin
   Circle(I * 15 + WaveOffset, J * 20 + 5, 2);
  End;
 End;
End;

Procedure DrawIslands;
Var
 I: Integer;
 IslandData: Array[1..7, 1..3] of Integer;
Begin
  { Coordonnees des 7 iles: X, Y, Taille }
 IslandData[1][1] := 80;  IslandData[1][2] := 80;  IslandData[1][3] := 25;
 IslandData[2][1] := 200; IslandData[2][2] := 60;  IslandData[2][3] := 20;
 IslandData[3][1] := 300; IslandData[3][2] := 90;  IslandData[3][3] := 30;
 IslandData[4][1] := 480; IslandData[4][2] := 70;  IslandData[4][3] := 22;
 IslandData[5][1] := 550; IslandData[5][2] := 120; IslandData[5][3] := 18;
 IslandData[6][1] := 120; IslandData[6][2] := 180; IslandData[6][3] := 28;
 IslandData[7][1] := 350; IslandData[7][2] := 170; IslandData[7][3] := 26;
  { Dessiner les iles }
 SetColor(Green);
 SetFillStyle(SolidFill, Green);
 For I := 1 to 7 do Begin
  FillEllipse(IslandData[I][1], IslandData[I][2],
              IslandData[I][3], IslandData[I][3]);
    { Ajouter des palmiers }
  SetColor(Brown);
  Line(IslandData[I][1], IslandData[I][2] - 5,
       IslandData[I][1], IslandData[I][2] - 15);
  SetColor(Green);
  Circle(IslandData[I][1], IslandData[I][2] - 15, 3);
 End;
End;

Procedure DrawArcadeBorder;Begin
  { Bordure externe }
 SetColor(Yellow);
 SetLineStyle(SolidLn, 0, ThickWidth);
 Rectangle(MENU_X - 10, MENU_Y - 40, MENU_X + MENU_WIDTH + 10, MENU_Y + MENU_HEIGHT + 20);
  { Bordure interne }
 SetColor(LightGray);
 SetLineStyle(SolidLn, 0, NormWidth);
 Rectangle(MENU_X - 5, MENU_Y - 35, MENU_X + MENU_WIDTH + 5, MENU_Y + MENU_HEIGHT + 15);
  { Coins decoratifs }
 SetColor(White);
  { Coin superieur gauche }
 Line(MENU_X - 8, MENU_Y - 38, MENU_X - 2, MENU_Y - 32);
 Line(MENU_X - 2, MENU_Y - 38, MENU_X - 8, MENU_Y - 32);
  { Coin superieur droit }
 Line(MENU_X + MENU_WIDTH + 2, MENU_Y - 38, MENU_X + MENU_WIDTH + 8, MENU_Y - 32);
 Line(MENU_X + MENU_WIDTH + 8, MENU_Y - 38, MENU_X + MENU_WIDTH + 2, MENU_Y - 32);
  { Coin inferieur gauche }
 Line(MENU_X - 8, MENU_Y + MENU_HEIGHT + 12, MENU_X - 2, MENU_Y + MENU_HEIGHT + 18);
 Line(MENU_X - 2, MENU_Y + MENU_HEIGHT + 12, MENU_X - 8, MENU_Y + MENU_HEIGHT + 18);
  { Coin inferieur droit }
 Line(MENU_X + MENU_WIDTH + 2, MENU_Y + MENU_HEIGHT + 12, MENU_X + MENU_WIDTH + 8, MENU_Y + MENU_HEIGHT + 18);
 Line(MENU_X + MENU_WIDTH + 8, MENU_Y + MENU_HEIGHT + 12, MENU_X + MENU_WIDTH + 2, MENU_Y + MENU_HEIGHT + 18);
End;

Procedure DrawTitle;Begin
  { Titre principal }
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 4);
 OutTextXY(SCREEN_WIDTH div 2 - 80, 20, '7-ILES');
  { Sous-titre }
 SetColor(LightGray);
 SetTextStyle(DefaultFont, HorizDir, 2);
 OutTextXY(SCREEN_WIDTH div 2 - 85, 60, 'Collection de jeux');
  { Ligne decorative }
 SetColor(Yellow);
 Line(SCREEN_WIDTH div 2 - 120, 90, SCREEN_WIDTH div 2 + 120, 90);
End;

Procedure DrawStaticBackground;Begin
  { Dessiner le fond statique une seule fois }
 DrawOcean;
 DrawIslands;
 DrawArcadeBorder;
 DrawTitle;
End;

Procedure DrawMenu;
Var
 I,ItemY:Integer;
 ItemIndex:Integer;
Begin
  { Fond du menu }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(MENU_X, MENU_Y, MENU_X + MENU_WIDTH, MENU_Y + MENU_HEIGHT);
  { Afficher les elements du menu }
 SetTextStyle(DefaultFont, HorizDir, 1);
 For I := 1 to VISIBLE_ITEMS do Begin
  ItemIndex := ScrollPosition + I;
  If ItemIndex <= MAX_GAMES Then Begin
   ItemY := MENU_Y + (I - 1) * 24 + 10;
    { Surbrillance pour l'element selectionne }
   If ItemIndex = CurrentSelection Then Begin
    SetColor(Yellow);
    SetFillStyle(SolidFill, DarkGray);
    Bar(MENU_X + 5, ItemY - 2, MENU_X + MENU_WIDTH - 5, ItemY + 16);
    SetColor(White);
   End
    Else
   Begin
    SetColor(LightGray);
   End;
    { Afficher le titre du jeu }
   OutTextXY(MENU_X + 10, ItemY, Games[ItemIndex].Title);
  End;
 End;
  { Indicateur de scroll }
 If ScrollPosition > 0 Then Begin
  SetColor(Yellow);
  OutTextXY(MENU_X + MENU_WIDTH - 20, MENU_Y + 5, '^');
 End;
 If ScrollPosition + VISIBLE_ITEMS < MAX_GAMES Then Begin
  SetColor(Yellow);
  OutTextXY(MENU_X + MENU_WIDTH - 20, MENU_Y + MENU_HEIGHT - 20, 'v');
 End;
End;

Procedure DrawInstructions;Begin
 SetColor(White);
 SetTextStyle(DefaultFont, HorizDir, 1);
 OutTextXY(MENU_X, MENU_Y + MENU_HEIGHT + 30, 'Fleches: Navigation    Entree: Lancer le jeu    Echap: Quitter');
End;

Procedure HandleInput;
Var
Key:Char;
Begin
  If KeyPressed Then Begin
    Key := ReadKey;
    Case Key of
      #0: Begin { Touches speciales }
        Key := ReadKey;
        Case Key of
          #72: Begin { Fleche haut }
            If CurrentSelection > 1 Then Begin
              Dec(CurrentSelection);
              If CurrentSelection <= ScrollPosition Then
                Dec(ScrollPosition);
              NeedRedraw := True;
            End;
          End;
          #80: Begin { Fleche bas }
            If CurrentSelection < MAX_GAMES Then Begin
              Inc(CurrentSelection);
              If CurrentSelection > ScrollPosition + VISIBLE_ITEMS Then
                Inc(ScrollPosition);
              NeedRedraw := True;
            End;
          End;
        End;
      End;
      #13: Begin { Entree }
       CloseGraph;
       { Lancer le jeu selectionne }
       Exec(Games[CurrentSelection].ProgramExec, '');
       If DosError <> 0 Then Begin
        WriteLn('Erreur lors du lancement de ', Games[CurrentSelection].ProgramExec);
        ReadLn;
       End;
       ExitMenu:=True;
       {InitScreen;
       NeedRedraw:=True;
       DrawStaticBackground;}
      End;
      #27:ExitMenu := True; { Echap }
    End;
  End;
End;

BEGIN
 InitScreen;
  { Initialisation }
 CurrentSelection := 1;
 ScrollPosition := 0;
 ExitMenu := False;
 LastSelection := 0;
 LastScrollPosition := -1;
 NeedRedraw := True;
  { Dessiner le fond statique une seule fois }
 DrawStaticBackground;
  { Boucle principale }
 Repeat
   { Redessiner seulement si necessaire }
  If NeedRedraw or (CurrentSelection <> LastSelection) or (ScrollPosition <> LastScrollPosition) Then Begin
   DrawMenu;
   LastSelection := CurrentSelection;
   LastScrollPosition := ScrollPosition;
   NeedRedraw := False;
  End;
  HandleInput;
 Until ExitMenu;
 CloseGraph;
END.
