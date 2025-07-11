{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Jeu de Baccarat avec interface graphique
}

Program Baccarat;

Uses
{$IFDEF FPC}
  PtcCrt, PtcGraph, PtcMouse
{$ELSE}
  Crt, Graph
{$ENDIF};

Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  CARD_WIDTH = 60;
  CARD_HEIGHT = 80;
  MAX_CARDS = 3;
  INITIAL_MONEY = 1000;

Type
  TCard = Record
    suit: Integer;    { 0=Coeur, 1=Carreau, 2=Trèfle, 3=Pique }
    rank: Integer;    { 1=As, 2-10=valeur, 11=Valet, 12=Dame, 13=Roi }
    visible: Boolean;
  End;

  TGameState = (gsMainMenu, gsPlaying, gsBetting, gsGameOver, gsQuit);

  TBetType = (btPlayer, btBanker, btTie);

  TGame = Record
    playerCards: Array[0..MAX_CARDS-1] of TCard;
    bankerCards: Array[0..MAX_CARDS-1] of TCard;
    playerCardCount: Integer;
    bankerCardCount: Integer;
    playerTotal: Integer;
    bankerTotal: Integer;
    deck: Array[0..51] of TCard;
    deckPosition: Integer;
    gameState: TGameState;
    playerMoney: LongInt;
    currentBet: LongInt;
    betType: TBetType;
    gameResult: String;
    roundComplete: Boolean;
    needRedraw: Boolean;
  End;

Var
  Game: TGame;

Function IntToStr(value: LongInt): String;
Var
  s: String;
Begin
  Str(value, s);
  IntToStr := s;
End;

Function GetCardValue(card: TCard): Integer;
Begin
  Case card.rank of
    1: GetCardValue := 1;           { As = 1 }
    2..9: GetCardValue := card.rank; { 2-9 = valeur faciale }
    10..13: GetCardValue := 0;      { 10, Valet, Dame, Roi = 0 }
  End;
End;

Function GetCardName(card: TCard): String;
Var
  rankName, suitName: String;
Begin
  Case card.rank of
    1: rankName := 'As';
    2..10: rankName := IntToStr(card.rank);
    11: rankName := 'Valet';
    12: rankName := 'Dame';
    13: rankName := 'Roi';
  End;

  Case card.suit of
    0: suitName := 'Coeur';
    1: suitName := 'Carreau';
    2: suitName := 'Trefle';
    3: suitName := 'Pique';
  End;

  GetCardName := rankName + ' de ' + suitName;
End;

Procedure InitializeDeck;
Var
  i, suit, rank: Integer;
Begin
  i := 0;
  For suit := 0 to 3 do
    For rank := 1 to 13 do
    Begin
      Game.deck[i].suit := suit;
      Game.deck[i].rank := rank;
      Game.deck[i].visible := True;
      Inc(i);
    End;
End;

Procedure ShuffleDeck;
Var
  i, j: Integer;
  tempCard: TCard;
Begin
  For i := 0 to 51 do
  Begin
    j := Random(52);
    tempCard := Game.deck[i];
    Game.deck[i] := Game.deck[j];
    Game.deck[j] := tempCard;
  End;
  Game.deckPosition := 0;
End;

Procedure DealCard(Var card: TCard);
Begin
  card := Game.deck[Game.deckPosition];
  Inc(Game.deckPosition);
End;

Function CalculateHandValue(cards: Array of TCard; cardCount: Integer): Integer;
Var
  i, total: Integer;
Begin
  total := 0;
  For i := 0 to cardCount-1 do
    total := total + GetCardValue(cards[i]);
  CalculateHandValue := total mod 10;
End;

Procedure DealInitialCards;
Begin
  { Distribuer 2 cartes au joueur }
  DealCard(Game.playerCards[0]);
  DealCard(Game.playerCards[1]);
  Game.playerCardCount := 2;

  { Distribuer 2 cartes au banquier }
  DealCard(Game.bankerCards[0]);
  DealCard(Game.bankerCards[1]);
  Game.bankerCardCount := 2;

  { Calculer les totaux }
  Game.playerTotal := CalculateHandValue(Game.playerCards, Game.playerCardCount);
  Game.bankerTotal := CalculateHandValue(Game.bankerCards, Game.bankerCardCount);
End;

Function NeedsThirdCard(total: Integer): Boolean;
Begin
  NeedsThirdCard := total <= 5;
End;

Function BankerNeedsThirdCard(bankerTotal: Integer; playerThirdCard: Integer): Boolean;
Begin
  Case bankerTotal of
    0, 1, 2: BankerNeedsThirdCard := True;
    3: BankerNeedsThirdCard := playerThirdCard <> 8;
    4: BankerNeedsThirdCard := playerThirdCard in [2, 3, 4, 5, 6, 7];
    5: BankerNeedsThirdCard := playerThirdCard in [4, 5, 6, 7];
    6: BankerNeedsThirdCard := playerThirdCard in [6, 7];
    else BankerNeedsThirdCard := False;
  End;
End;

Procedure PlayRound;
Var
  playerThirdCardValue: Integer;
Begin
  playerThirdCardValue := -1;

  { Vérifier si le joueur a besoin d'une troisième carte }
  If (Game.playerTotal <= 5) and (Game.playerCardCount = 2) Then
  Begin
    DealCard(Game.playerCards[2]);
    Inc(Game.playerCardCount);
    Game.playerTotal := CalculateHandValue(Game.playerCards, Game.playerCardCount);
    playerThirdCardValue := GetCardValue(Game.playerCards[2]);
  End;

  { Vérifier si le banquier a besoin d'une troisième carte }
  If Game.bankerCardCount = 2 Then
  Begin
    If playerThirdCardValue = -1 Then
    Begin
      { Le joueur n'a pas pris de troisième carte }
      If Game.bankerTotal <= 5 Then
      Begin
        DealCard(Game.bankerCards[2]);
        Inc(Game.bankerCardCount);
        Game.bankerTotal := CalculateHandValue(Game.bankerCards, Game.bankerCardCount);
      End;
    End
    Else
    Begin
      { Le joueur a pris une troisième carte }
      If BankerNeedsThirdCard(Game.bankerTotal, playerThirdCardValue) Then
      Begin
        DealCard(Game.bankerCards[2]);
        Inc(Game.bankerCardCount);
        Game.bankerTotal := CalculateHandValue(Game.bankerCards, Game.bankerCardCount);
      End;
    End;
  End;

  { Déterminer le résultat }
  If Game.playerTotal > Game.bankerTotal Then
  Begin
    Game.gameResult := 'Le Joueur gagne!';
    If Game.betType = btPlayer Then
      Game.playerMoney := Game.playerMoney + Game.currentBet;
  End
  Else If Game.bankerTotal > Game.playerTotal Then
  Begin
    Game.gameResult := 'Le Banquier gagne!';
    If Game.betType = btBanker Then
      Game.playerMoney := Game.playerMoney + Round(Game.currentBet * 0.95); { Commission 5% }
  End
  Else
  Begin
    Game.gameResult := 'Egalite!';
    If Game.betType = btTie Then
      Game.playerMoney := Game.playerMoney + (Game.currentBet * 8) { Paiement 8:1 }
    Else If Game.betType in [btPlayer, btBanker] Then
      Game.playerMoney := Game.playerMoney + Game.currentBet; { Remboursement }
  End;

  Game.roundComplete := True;
  Game.needRedraw := True;
End;

Procedure DrawCard(x, y: Integer; card: TCard; faceUp: Boolean);
Var
  suitColor: Integer;
  rankStr: String;
Begin
  { Dessiner le contour de la carte }
  SetColor(15);
  SetLineStyle(0, 0, 1);
  Rectangle(x, y, x + CARD_WIDTH, y + CARD_HEIGHT);

  If faceUp Then
  Begin
    { Fond blanc pour la carte }
    SetColor(15);
    SetFillStyle(1, 15);
    Bar(x+1, y+1, x + CARD_WIDTH-1, y + CARD_HEIGHT-1);

    { Couleur selon la couleur de la carte }
    If card.suit in [0, 1] Then
      suitColor := 4  { Rouge }
    Else
      suitColor := 0; { Noir }

    SetColor(suitColor);
    SetTextStyle(0, 0, 1);

    { Afficher le rang }
    Case card.rank of
      1: rankStr := 'A';
      2..10: rankStr := IntToStr(card.rank);
      11: rankStr := 'V';
      12: rankStr := 'D';
      13: rankStr := 'R';
    End;

    OutTextXY(x + 5, y + 5, rankStr);

    { Dessiner le symbole de la couleur }
    Case card.suit of
      0: OutTextXY(x + 25, y + 35, 'C'); { Coeur }
      1: OutTextXY(x + 25, y + 35, 'K'); { Carreau }
      2: OutTextXY(x + 25, y + 35, 'T'); { Trèfle }
      3: OutTextXY(x + 25, y + 35, 'P'); { Pique }
    End;
  End
  Else
  Begin
    { Dos de la carte }
    SetColor(1);
    SetFillStyle(1, 1);
    Bar(x+1, y+1, x + CARD_WIDTH-1, y + CARD_HEIGHT-1);

    SetColor(15);
    SetTextStyle(0, 0, 1);
    OutTextXY(x + 20, y + 35, '?');
  End;
End;

Procedure DrawTable;
Begin
  { Fond vert de la table }
  SetColor(2);
  SetFillStyle(1, 2);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  { Titre }
  SetColor(15);
  SetTextStyle(0, 0, 3);
  OutTextXY(SCREEN_WIDTH div 2 - 80, 20, 'BACCARAT');

  { Zones de paris }
  SetColor(14);
  SetLineStyle(0, 0, 2);
  Rectangle(50, 60, 150, 100);
  Rectangle(200, 60, 300, 100);
  Rectangle(350, 60, 450, 100);

  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(70, 75, 'JOUEUR');
  OutTextXY(220, 75, 'BANQUIER');
  OutTextXY(375, 75, 'EGALITE');
  OutTextXY(70, 85, '1:1');
  OutTextXY(220, 85, '0.95:1');
  OutTextXY(375, 85, '8:1');

  { Informations du jeu }
  OutTextXY(480, 70, 'Argent: ' + IntToStr(Game.playerMoney));
  OutTextXY(480, 90, 'Mise: ' + IntToStr(Game.currentBet));

  { Indicateur de pari actuel }
  If Game.betType = btPlayer Then
  Begin
    SetColor(12);
    Rectangle(48, 58, 152, 102);
  End
  Else If Game.betType = btBanker Then
  Begin
    SetColor(12);
    Rectangle(198, 58, 302, 102);
  End
  Else If Game.betType = btTie Then
  Begin
    SetColor(12);
    Rectangle(348, 58, 452, 102);
  End;
End;

Procedure DrawCards;
Var
  i: Integer;
Begin
  { Cartes du joueur }
  SetColor(15);
  SetTextStyle(0, 0, 1);
  OutTextXY(50, 150, 'JOUEUR (' + IntToStr(Game.playerTotal) + ')');

  For i := 0 to Game.playerCardCount-1 do
    DrawCard(50 + i * 70, 170, Game.playerCards[i], True);

  { Cartes du banquier }
  OutTextXY(50, 280, 'BANQUIER (' + IntToStr(Game.bankerTotal) + ')');

  For i := 0 to Game.bankerCardCount-1 do
    DrawCard(50 + i * 70, 300, Game.bankerCards[i], True);
End;

Procedure DrawGameInfo;
Begin
  SetColor(15);
  SetTextStyle(0, 0, 1);

  { Instructions }
  OutTextXY(50, 420, 'Commandes:');
  OutTextXY(50, 440, '1-3: Choisir type de pari  +/-: Ajuster mise  ESPACE: Parier  N: Nouveau jeu  ESC: Quitter');

  { Résultat du jeu }
  If Game.roundComplete Then
  Begin
    SetColor(14);
    SetTextStyle(0, 0, 2);
    OutTextXY(350, 200, Game.gameResult);

    SetColor(15);
    SetTextStyle(0, 0, 1);
    OutTextXY(350, 230, 'Appuyez sur ENTREE pour continuer');
  End;
End;

Procedure DrawMainMenu;
Begin
  SetColor(0);
  SetFillStyle(1, 0);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

  SetColor(15);
  SetTextStyle(0, 0, 4);
  OutTextXY(SCREEN_WIDTH div 2 - 120, 100, 'BACCARAT');

  SetTextStyle(0, 0, 1);
  OutTextXY(50, 180, 'Regles du Baccarat:');
  OutTextXY(50, 200, '- Pariez sur la main qui se rapprochera le plus de 9');
  OutTextXY(50, 220, '- As = 1, Figures = 0, autres cartes = valeur faciale');
  OutTextXY(50, 240, '- Seul le chiffre des unites compte (ex: 15 = 5)');
  OutTextXY(50, 260, '- Paiements: Joueur 1:1, Banquier 0.95:1, Egalite 8:1');

  OutTextXY(50, 300, 'Commandes:');
  OutTextXY(50, 320, '1: Parier sur le Joueur');
  OutTextXY(50, 340, '2: Parier sur le Banquier');
  OutTextXY(50, 360, '3: Parier sur l''Egalite');
  OutTextXY(50, 380, '+/-: Ajuster la mise');
  OutTextXY(50, 400, 'ESPACE: Placer le pari');
  OutTextXY(50, 420, 'ESC: Quitter');

  OutTextXY(50, 460, 'Appuyez sur ENTREE pour commencer...');
End;

Procedure Render;
Begin
  If Game.needRedraw Then
  Begin
    Case Game.gameState of
      gsMainMenu: DrawMainMenu;
      gsPlaying, gsBetting:
      Begin
        DrawTable;
        If Game.gameState = gsPlaying Then
          DrawCards;
        DrawGameInfo;
      End;
    End;

    Game.needRedraw := False;
  End;
End;

Procedure HandleInput;
Var
  key: Char;
Begin
  If KeyPressed Then
  Begin
    key := ReadKey;

    Case Game.gameState of
      gsMainMenu:
      Begin
        If key = #13 Then { Enter }
        Begin
          Game.gameState := gsBetting;
          Game.needRedraw := True;
        End
        Else If key = #27 Then { ESC }
          Game.gameState := gsQuit;
      End;

      gsBetting:
      Begin
        Case key of
          '1':
          Begin
            Game.betType := btPlayer;
            Game.needRedraw := True;
          End;
          '2':
          Begin
            Game.betType := btBanker;
            Game.needRedraw := True;
          End;
          '3':
          Begin
            Game.betType := btTie;
            Game.needRedraw := True;
          End;
          '+':
          Begin
            If Game.currentBet < Game.playerMoney Then
            Begin
              Game.currentBet := Game.currentBet + 10;
              Game.needRedraw := True;
            End;
          End;
          '-':
          Begin
            If Game.currentBet > 10 Then
            Begin
              Game.currentBet := Game.currentBet - 10;
              Game.needRedraw := True;
            End;
          End;
          ' ':
          Begin
            If Game.currentBet <= Game.playerMoney Then
            Begin
              Game.playerMoney := Game.playerMoney - Game.currentBet;
              DealInitialCards;
              PlayRound;
              Game.gameState := gsPlaying;
              Game.needRedraw := True;
            End;
          End;
          'n', 'N':
          Begin
            Game.playerMoney := INITIAL_MONEY;
            Game.currentBet := 50;
            Game.gameState := gsBetting;
            Game.needRedraw := True;
          End;
          #27: Game.gameState := gsQuit; { ESC }
        End;
      End;

      gsPlaying:
      Begin
        If key = #13 Then { Enter }
        Begin
          If Game.playerMoney <= 0 Then
          Begin
            Game.gameState := gsGameOver;
          End
          Else
          Begin
            Game.gameState := gsBetting;
            Game.roundComplete := False;
            ShuffleDeck;
          End;
          Game.needRedraw := True;
        End
        Else If key = 'n' Then
        Begin
          Game.playerMoney := INITIAL_MONEY;
          Game.currentBet := 50;
          Game.gameState := gsBetting;
          Game.roundComplete := False;
          ShuffleDeck;
          Game.needRedraw := True;
        End
        Else If key = #27 Then { ESC }
          Game.gameState := gsQuit;
      End;
    End;
  End;
End;

Procedure InitializeGame;
Begin
  Game.gameState := gsMainMenu;
  Game.playerMoney := INITIAL_MONEY;
  Game.currentBet := 50;
  Game.betType := btPlayer;
  Game.roundComplete := False;
  Game.needRedraw := True;
  Game.playerCardCount := 0;
  Game.bankerCardCount := 0;
  Game.playerTotal := 0;
  Game.bankerTotal := 0;
  Game.gameResult := '';

  InitializeDeck;
  ShuffleDeck;
  Randomize;
End;

Procedure GameLoop;
Begin
  While Game.gameState <> gsQuit do
  Begin
    HandleInput;
    Render;
    Delay(50);
  End;
End;

Procedure InitializeGraphics;
Var
  Driver, Mode: Integer;
  ErrCode: Integer;
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
End;

BEGIN
 InitializeGraphics;
 InitializeGame;
 GameLoop;
 CloseGraph;
END.
