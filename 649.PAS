{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Lotto649;

Uses {$IFDEF FPC}
      Windows,PtcMouse,PtcGraph,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  SCREEN_WIDTH = 640;
  SCREEN_HEIGHT = 480;
  MAX_TICKETS = 5;
  MAX_NUMBERS = 6;
  MIN_NUMBER = 1;
  MAX_NUMBER = 49;

Type
  TTicket = Array[1..MAX_NUMBERS] of Integer;
  TTicketArray = Array[1..MAX_TICKETS] of TTicket;

Var
  Tickets: TTicketArray;
  NumTickets: Integer;
  CurrentTicket: Integer;
  CurrentNumber: Integer;
  WinningNumbers: TTicket;
  GameState: Integer; { 0=Selection, 1=Playing, 2=Results }
  
Function ReadNumber: Integer;
Var
  Key: Char;
  Num: Integer;
  NumStr: String;
  ErrorCode: Integer;
Begin
  NumStr := '';
  { Effacer d'abord la zone de saisie }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(20, 450, 500, 470);
  
  SetColor(Yellow);
  OutTextXY(20, 450, 'Entrez un numero (1-49) puis ENTREE: ');
  
  { Zone de saisie séparée }
  SetColor(White);
  SetFillStyle(SolidFill, White);
  Bar(320, 448, 370, 465);
  SetColor(Black);
  Rectangle(320, 448, 370, 465);
  
  Repeat
    Key := ReadKey;
    If (Key >= '0') And (Key <= '9') And (Length(NumStr) < 2) Then Begin
      NumStr := NumStr + Key;
      { Effacer d'abord la zone de saisie }
      SetColor(White);
      SetFillStyle(SolidFill, White);
      Bar(321, 449, 369, 464);
      { Afficher le numéro centré dans la zone }
      SetColor(Black);
      SetTextStyle(DefaultFont, HorizDir, 1);
      If Length(NumStr) = 1 Then
        OutTextXY(340, 452, NumStr)
      Else
        OutTextXY(335, 452, NumStr);
    End Else If (Key = #8) And (Length(NumStr) > 0) Then Begin
      { Backspace }
      Delete(NumStr, Length(NumStr), 1);
      { Effacer la zone de saisie }
      SetColor(White);
      SetFillStyle(SolidFill, White);
      Bar(321, 449, 369, 464);
      { Réafficher ce qui reste }
      If Length(NumStr) > 0 Then Begin
        SetColor(Black);
        If Length(NumStr) = 1 Then
          OutTextXY(340, 452, NumStr)
        Else
          OutTextXY(335, 452, NumStr);
      End;
    End;
  Until (Key = #13) Or (Key = #27);
  
  If (Key = #27) Or (NumStr = '') Then Begin
    ReadNumber := -1;
  End Else Begin
    Val(NumStr, Num, ErrorCode);
    If (ErrorCode = 0) And (Num >= MIN_NUMBER) And (Num <= MAX_NUMBER) Then
      ReadNumber := Num
    Else
      ReadNumber := -1;
  End;
  
  { Effacer toute la ligne de saisie }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(20, 450, 500, 470);
End;
  
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

Procedure DrawBackground;
Begin
  { Fond dégradé bleu }
  SetColor(Blue);
  SetFillStyle(SolidFill, Blue);
  Bar(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
  
  { Bordure principale }
  SetColor(White);
  SetLineStyle(SolidLn, 0, ThickWidth);
  Rectangle(10, 10, SCREEN_WIDTH - 10, SCREEN_HEIGHT - 10);
  
  { Titre }
  SetColor(Yellow);
  SetTextStyle(DefaultFont, HorizDir, 4);
  OutTextXY(SCREEN_WIDTH div 2 - 100, 20, 'LOTTO 6/49');
  
  { Ligne décorative }
  SetColor(White);
  Line(50, 70, SCREEN_WIDTH - 50, 70);
End;

Function NumberExists(Var Ticket: TTicket; Num: Integer; Count: Integer): Boolean;
Var
  I: Integer;
Begin
  NumberExists := False;
  For I := 1 to Count do Begin
    If Ticket[I] = Num Then Begin
      NumberExists := True;
      Exit;
    End;
  End;
End;

Procedure SortTicket(Var Ticket: TTicket);
Var
  I, J, Temp: Integer;
Begin
  For I := 1 to MAX_NUMBERS - 1 do Begin
    For J := I + 1 to MAX_NUMBERS do Begin
      If Ticket[I] > Ticket[J] Then Begin
        Temp := Ticket[I];
        Ticket[I] := Ticket[J];
        Ticket[J] := Temp;
      End;
    End;
  End;
End;

Procedure GenerateRandomTicket(Var Ticket: TTicket);
Var
  I, Num: Integer;
Begin
  For I := 1 to MAX_NUMBERS do Begin
    Repeat
      Num := Random(MAX_NUMBER) + 1;
    Until Not NumberExists(Ticket, Num, I - 1);
    Ticket[I] := Num;
  End;
  SortTicket(Ticket);
End;

Procedure DrawTicket(X, Y: Integer; Var Ticket: TTicket; Count: Integer; IsSelected: Boolean);
Var
  I, NumX, NumY: Integer;
  NumStr: String;
Begin
  { Fond du billet }
  If IsSelected Then
    SetColor(Yellow)
  Else
    SetColor(LightGray);
  SetFillStyle(SolidFill, LightGray);
  Bar(X, Y, X + 280, Y + 40);
  
  { Bordure du billet }
  If IsSelected Then
    SetColor(Red)
  Else
    SetColor(Black);
  SetLineStyle(SolidLn, 0, NormWidth);
  Rectangle(X, Y, X + 280, Y + 40);
  
  { Numéros }
  SetTextStyle(DefaultFont, HorizDir, 2);
  For I := 1 to MAX_NUMBERS do Begin
    NumX := X + 10 + (I - 1) * 43;
    NumY := Y + 12;
    
    { Cercle pour le numéro }
    If I <= Count Then Begin
      SetColor(White);
      SetFillStyle(SolidFill, White);
      FillEllipse(NumX + 15, NumY + 8, 15, 12);
      
      SetColor(Black);
      Circle(NumX + 15, NumY + 8, 15);
      
      { Afficher le numéro }
      Str(Ticket[I], NumStr);
      If Ticket[I] < 10 Then
        OutTextXY(NumX + 10, NumY, NumStr)
      Else
        OutTextXY(NumX + 6, NumY, NumStr);
    End Else Begin
      { Cercle vide }
      SetColor(DarkGray);
      SetFillStyle(SolidFill, DarkGray);
      FillEllipse(NumX + 15, NumY + 8, 15, 12);
      
      SetColor(Black);
      Circle(NumX + 15, NumY + 8, 15);
    End;
  End;
End;

Procedure DrawNumberPad;
Var
  I, J, X, Y, Num: Integer;
  NumStr: String;
  TicketToCheck: Integer;
Begin
  SetTextStyle(DefaultFont, HorizDir, 1);
  
  { Déterminer quel billet vérifier }
  If (CurrentTicket <= NumTickets) Then
    TicketToCheck := CurrentTicket
  Else
    TicketToCheck := NumTickets;
  
  { Grille de numéros 1-49 }
  For I := 0 to 6 do Begin
    For J := 0 to 6 do Begin
      Num := I * 7 + J + 1;
      If Num <= MAX_NUMBER Then Begin
        X := 350 + J * 35;
        Y := 120 + I * 35;
        
        { Vérifier si le numéro est déjà sélectionné dans le billet actuel }
        If (TicketToCheck >= 1) And (TicketToCheck <= NumTickets) And
           NumberExists(Tickets[TicketToCheck], Num, MAX_NUMBERS) Then
          SetColor(Red)
        Else
          SetColor(LightGray);
        
        SetFillStyle(SolidFill, LightGray);
        Bar(X, Y, X + 30, Y + 25);
        
        SetColor(Black);
        Rectangle(X, Y, X + 30, Y + 25);
        
        { Afficher le numéro }
        Str(Num, NumStr);
        If Num < 10 Then
          OutTextXY(X + 12, Y + 8, NumStr)
        Else
          OutTextXY(X + 8, Y + 8, NumStr);
      End;
    End;
  End;
End;

Procedure DrawStatistics;
Var
  Chances: Real;
  StatStr: String;
Begin
  SetColor(Cyan);
  SetTextStyle(DefaultFont, HorizDir, 1);
  
  { Calcul des chances (approximation) }
  { Chances de gagner le 6/49 = 1 sur 13,983,816 }
  { Avec plusieurs billets, les chances augmentent proportionnellement }
  
  If NumTickets > 0 Then Begin
    Chances := NumTickets / 13983816.0;
    
    OutTextXY(20, 380, 'Statistiques:');
    
    Str(NumTickets, StatStr);
    OutTextXY(20, 395, 'Nombre de billets: ' + StatStr);
    
    Str(Chances * 100:0:6, StatStr);
    OutTextXY(20, 410, 'Chances de gagner le gros lot: ' + StatStr + '%');
    
    { Autres prix }
    OutTextXY(370, 395, 'Chances 5/6: ' + Chr(126) + ' 1 sur 55,492');
    OutTextXY(370, 410, 'Chances 4/6: ' + Chr(126) + ' 1 sur 1,033');
  End;
End;

Procedure DrawSelectionScreen;
Var
  I: Integer;
  StatStr: String;
Begin
  DrawBackground;
  
  { Instructions }
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(20, 90, 'Selectionnez vos numeros pour chaque billet:');
  
  { Afficher les billets }
  For I := 1 to NumTickets do Begin
    DrawTicket(20, 110 + (I - 1) * 50, Tickets[I], MAX_NUMBERS, I = CurrentTicket);
  End;
  
  { Grille de sélection }
  If (CurrentTicket <= NumTickets) And (CurrentNumber <= MAX_NUMBERS) Then Begin
    Str(CurrentTicket, StatStr);
    SetColor(Yellow);
    OutTextXY(350, 100, 'Billet ' + StatStr + ' - Numero ' + Chr(Ord('0') + CurrentNumber) + ':');
    DrawNumberPad;
  End Else Begin
    { Afficher un message quand tous les billets sont complets }
    SetColor(LightGreen);
    OutTextXY(130, 360, 'Tous les billets sont complets!');
    OutTextXY(130, 375, 'Appuyez sur T pour le tirage');
    { Afficher quand même la grille du dernier billet pour référence }
    If NumTickets > 0 Then Begin
      SetColor(Yellow);
      OutTextXY(350, 100, 'Grille de reference (dernier billet):');
      DrawNumberPad;
    End;
  End;
  
  { Statistiques }
  DrawStatistics;
  
  { Instructions de contrôle }
  SetColor(LightGray);
  OutTextXY(20, 420, '1-9=Numeros rapides, N=Saisir numero, A=Auto, T=Tirage, +/-=Billets, R=Reset, ESC=Quitter');
End;

Function GetClickedNumber(X, Y: Integer): Integer;
Var
  GridX, GridY, Num: Integer;
Begin
  GetClickedNumber := 0;
  
  If (X >= 350) And (X <= 350 + 7 * 35) And (Y >= 120) And (Y <= 120 + 7 * 35) Then Begin
    GridX := (X - 350) div 35;
    GridY := (Y - 120) div 35;
    Num := GridY * 7 + GridX + 1;
    
    If (Num >= MIN_NUMBER) And (Num <= MAX_NUMBER) Then
      GetClickedNumber := Num;
  End;
End;

Procedure DrawResults;
Var
  I, J, Matches: Integer;
  StatStr: String;
Begin
  DrawBackground;
  
  { Titre des résultats }
  SetColor(Yellow);
  SetTextStyle(DefaultFont, HorizDir, 2);
  OutTextXY(SCREEN_WIDTH div 2 - 100, 90, 'RESULTATS DU TIRAGE');
  
  { Numéros gagnants }
  SetColor(White);
  SetTextStyle(DefaultFont, HorizDir, 1);
  OutTextXY(20, 130, 'Numeros gagnants:');
  DrawTicket(20, 145, WinningNumbers, MAX_NUMBERS, False);
  
  { Vos billets et résultats }
  OutTextXY(20, 200, 'Vos billets:');
  For I := 1 to NumTickets do Begin
    DrawTicket(20, 220 + (I - 1) * 50, Tickets[I], MAX_NUMBERS, False);
    
    { Compter les correspondances }
    Matches := 0;
    For J := 1 to MAX_NUMBERS do Begin
      If NumberExists(WinningNumbers, Tickets[I][J], MAX_NUMBERS) Then
        Inc(Matches);
    End;
    
    { Afficher le nombre de correspondances }
    SetColor(Yellow);
    Str(Matches, StatStr);
    OutTextXY(320, 235 + (I - 1) * 50, StatStr + '/6 correspondances');
    
    { Prix }
    SetColor(LightGreen);
    Case Matches of
      6: OutTextXY(450, 235 + (I - 1) * 50, 'GROS LOT!');
      5: OutTextXY(450, 235 + (I - 1) * 50, '2e prix');
      4: OutTextXY(450, 235 + (I - 1) * 50, '3e prix');
      3: OutTextXY(450, 235 + (I - 1) * 50, 'Lot de consolation');
      Else Begin
        SetColor(Red);
        OutTextXY(450, 250 + (I - 1) * 50, 'Aucun gain');
      End;
    End;
  End;
  
  { Instructions }
  SetColor(LightGray);
  OutTextXY(20, 450, 'Appuyez sur une touche pour continuer...');
End;

Procedure HandleInput;
Var
  Key: Char;
  I, J, Num: Integer;
  Found: Boolean;
Begin
  If KeyPressed Then Begin
    Key := ReadKey;
    
    { Si on est dans l'écran des résultats, toute touche retourne à l'écran principal }
    If GameState = 2 Then Begin
      GameState := 0;
      CurrentTicket := 1;
      CurrentNumber := 1;
      NumTickets := 1;
      FillChar(Tickets, SizeOf(Tickets), 0);
      Exit;
    End;
    
    Case UpCase(Key) of
      '1'..'9': Begin { Sélection directe d'un numéro 1-9 }
        If (CurrentTicket <= NumTickets) And (CurrentNumber <= MAX_NUMBERS) Then Begin
          Num := Ord(Key) - Ord('0');
          If Not NumberExists(Tickets[CurrentTicket], Num, CurrentNumber - 1) Then Begin
            Tickets[CurrentTicket][CurrentNumber] := Num;
            Inc(CurrentNumber);
            If CurrentNumber > MAX_NUMBERS Then Begin
              SortTicket(Tickets[CurrentTicket]);
              If CurrentTicket < NumTickets Then Begin
                Inc(CurrentTicket);
                CurrentNumber := 1;
              End Else Begin
                CurrentNumber := MAX_NUMBERS + 1;
              End;
            End;
            { Redessiner immédiatement pour voir le changement }
            DrawSelectionScreen;
          End;
        End;
      End;
      'N': Begin { Saisie manuelle d'un numéro 1-49 }
        If (CurrentTicket <= NumTickets) And (CurrentNumber <= MAX_NUMBERS) Then Begin
          Num := ReadNumber;
          If (Num >= MIN_NUMBER) And (Num <= MAX_NUMBER) Then Begin
            If Not NumberExists(Tickets[CurrentTicket], Num, CurrentNumber - 1) Then Begin
              Tickets[CurrentTicket][CurrentNumber] := Num;
              Inc(CurrentNumber);
              If CurrentNumber > MAX_NUMBERS Then Begin
                SortTicket(Tickets[CurrentTicket]);
                If CurrentTicket < NumTickets Then Begin
                  Inc(CurrentTicket);
                  CurrentNumber := 1;
                End Else Begin
                  CurrentNumber := MAX_NUMBERS + 1;
                End;
              End;
              { Redessiner immédiatement pour voir le changement }
              DrawSelectionScreen;
            End;
          End;
        End;
      End;
      'A': Begin { Auto-sélection }
        If (CurrentTicket <= NumTickets) And (CurrentNumber <= MAX_NUMBERS) Then Begin
          GenerateRandomTicket(Tickets[CurrentTicket]);
          { Passer au billet suivant ou indiquer que tous sont terminés }
          If CurrentTicket < NumTickets Then Begin
            Inc(CurrentTicket);
            CurrentNumber := 1;
          End Else Begin
            { Tous les billets sont maintenant complets }
            Inc(CurrentTicket); { CurrentTicket devient > NumTickets }
          End;
          { Redessiner immédiatement pour voir le changement }
          DrawSelectionScreen;
        End;
      End;
      'T': Begin { Tirage }
        If (CurrentTicket > NumTickets) Or 
           ((CurrentTicket = NumTickets) And (CurrentNumber > MAX_NUMBERS)) Then Begin
          GenerateRandomTicket(WinningNumbers);
          GameState := 2;
        End;
      End;
      '+': Begin { Ajouter un billet }
        If NumTickets < MAX_TICKETS Then Begin
          Inc(NumTickets);
          { Initialiser le nouveau billet }
          For I := 1 to MAX_NUMBERS do
            Tickets[NumTickets][I] := 0;
          { Se positionner sur le nouveau billet }
          CurrentTicket := NumTickets;
          CurrentNumber := 1;
          { Redessiner immédiatement pour voir le changement }
          DrawSelectionScreen;
        End;
      End;
      '-': Begin { Retirer un billet }
        If NumTickets > 1 Then Begin
          Dec(NumTickets);
          If CurrentTicket > NumTickets Then Begin
            CurrentTicket := NumTickets;
            CurrentNumber := 1;
          End;
          { Redessiner immédiatement pour voir le changement }
          DrawSelectionScreen;
        End;
      End;
      'R': Begin { Reset du billet actuel }
        If (CurrentTicket <= NumTickets) Then Begin
          For I := 1 to MAX_NUMBERS do
            Tickets[CurrentTicket][I] := 0;
          CurrentNumber := 1;
          { Redessiner immédiatement pour voir le changement }
          DrawSelectionScreen;
        End;
      End;
      #13: Begin { Entrée - Nouvelle partie }
        GameState := 0;
        CurrentTicket := 1;
        CurrentNumber := 1;
        NumTickets := 1;
        FillChar(Tickets, SizeOf(Tickets), 0);
      End;
      #27: Begin { Échap }
        CloseGraph;
        Halt;
      End;
    End;
  End;
End;

BEGIN
  Randomize;
  InitScreen;
  
  { Initialisation }
  NumTickets := 1;
  CurrentTicket := 1;
  CurrentNumber := 1;
  GameState := 0;
  FillChar(Tickets, SizeOf(Tickets), 0);
  
  { Boucle principale }
  Repeat
    Case GameState of
      0, 1: DrawSelectionScreen;
      2: DrawResults;
    End;
    
    HandleInput;
    
    Delay(50);
  Until False;
END.
