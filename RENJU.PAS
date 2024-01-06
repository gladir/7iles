{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program RENJU;

{$R-}

Uses Crt;

Const
 N=15;
 AttackFactor=4;
 Weight:Array[0..6] of Integer = (0,0,4,20,100,500,0);
 NormalColor:Integer=White;
 BorderColor:Integer=Yellow;
 BoardColor:Integer=Cyan;
 HeadingColor:Integer=Brown;

Type

 TypeOfWin=(Null,Horiz,DownLeft,DownRight,Vert);
 BoardType=(Empty,Cross,Nought);
 ColorType=Cross..Nought;
 IndexType=1..N;
 NumberType=0..5;
 LineType=Array[ColorType] of NumberType;
 ValueType=Array[ColorType] of Integer;

Const
 PieceChar:Array[ColorType] of Char=('X','O');
 PieceColor:Array[ColorType] of Byte=(White,LightGreen);

Var
 I:Integer;
 Board:Array[IndexType,IndexType]of BoardType;
 Player:ColorType;
 TotalLines:Integer;
 GameWon:Boolean;
 FileRead:Boolean;
 Line:Array[0..3,IndexType,IndexType] of LineType;
 Value:Array[IndexType,IndexType] of ValueType;
 X,Y:IndexType;
 Command:Char;
 AutoPlay:Boolean;

Procedure SetUpScreen;

 Procedure WriteBoard(N:Integer;Top,Middle,Bottom:String);
 Var
  I,J:IndexType;

  Procedure WriteLetters;
  Var
   I:IndexType;
  Begin
   TextColor(BorderColor);
   Write('  ');
   For I:=1 to N do Write(Chr(Ord('A')+I-1):2);
   WriteLn;
  End;

  Procedure WriteBoardLine(J:Integer;S:String);
  Var
   i:IndexType;
  Begin
   TextColor(BorderColor);
   Write(J:2, ' ');
   TextColor(BoardColor);
   Write(s[1]);
   For i:=2 to N-1 do Write(S[2], S[3]);
   Write(S[4],S[5]);
   TextColor(BorderColor);
   WriteLn(' ', J:2);
  End;

 Begin
  GotoXY(1,1);
  WriteLetters;
  WriteBoardLine(N,Top);
  for J:=N-1 downto 2 do WriteBoardLine(J,Middle);
  WriteBoardLine(1,Bottom);
  WriteLetters;
 End;

Begin
 WriteBoard(N, '⁄ƒ¬ƒø',
               '√ƒ≈ƒ¥',
               '¿ƒ¡ƒŸ');
 TextColor(NormalColor);
End;

Procedure GotoSquare(X,Y:IndexType);Begin
 GotoXY(2+X*2,N+2-Y);
End;

Procedure PrintMove(Piece:ColorType;X,Y:IndexType);Begin
 TextColor(PieceColor[Piece]);
 GotoXY(49,9);
 Write(PieceChar[Piece],Chr(Ord('A')+X-1):2,Y);
 ClrEOL;
 GotoSquare(X,Y);
 Write(PieceChar[Piece]);
 GotoSquare(X,Y);
 TextColor(NormalColor);
End;

Procedure ClearMove;Begin
 GotoXY(49,9);
 ClrEOL;
End;

Procedure PrintMsg(Str:String);Begin
 TextColor(NormalColor);
 GotoXY(1,23);
 Write(Str);
End;

Procedure ClearMsg;Begin
 GotoXY(1,23);
 ClrEOL;
End;

Procedure WriteHelp(S:String;HiLen:Byte);Begin
 TextBackground(NormalColor);
 TextColor(Black);
 Write(Copy(S,1,HiLen));
 TextBackground(Black);
 TextColor(NormalColor);
 Write(Copy(S,HiLen+1,Length(S)-HiLen));
End;

Procedure Finish;Begin
 TextColor(White);
 TextBackground(Black);
 LowVideo;
 Window(1,1,80,25);
 GotoXY(1,24);
 Halt;
End;

Procedure Help;
Const
 MaxLines=37;
 FirstCol=50;
 FirstRow=8;
 LastCol=75;
 LastRow=21;
 HelpText:Array[1..37]of String[25]=(
 'OBJECTIF DU JEU',
  '',
  'Ce programme joue Ö un ',
  'träs vieux jeux japonais',
  'appelÇ Renju est une variante ',
  'du jeu GOMOKU Le ',
  'plateau comporte 15x15 ',
  'carrÇs. Obtenez 5 pierres',
  'd''affilÇe et vous gagnez !',
  '',
  'COMMENT SE DêPLACER',
  '',
  'Utilisez les touches du ',
  'clavier pour dÇplacez le ',
  'curseur :',
  '',
  '  Home '+#$18+' Page PgUp',
  '',
  '    '+#$11+#$C4+' '+#$C4+#$10,
  '',
  ' End  '+#$19' PgDn',
  '',
  'Utiliser les touches <RETURN> ',
  'ou <SPACE> pour faire votre ',
  'coup.',
  '',
  'UTILISER LE MENU',
  '',
  'Utilisez le menu ci-dessus ',
  'pour exÇcuter ces commandes',
  '(tapez la premiäre lettre) :',
  '',
  'N - Commencer une nouvelle partie',
  'Q - Quitter le programme',
  'A - Le programme joue seul',
  'J - Changer de cìtÇ',
  'H - Obtenez un indice'
 );
Var
 BorderTop,BorderBottom,
 BorderLeft,BorderRight:Byte;

 Procedure DrawBorder;
 Const
  VerticalBorder=#186;
  HorizontalBorder=#205;
  UpLeft=#201;
  UpRight=#187;
  DownLeft=#200;
  DownRight=#188;
 Var
  Row,Col:Integer;
 Begin
  BorderTop:=1;
  BorderBottom:=16;
  BorderLeft:=1;
  BorderRight:=29;
  ClrScr;
  TextColor(NormalColor-8);
  GotoXY(BorderLeft,BorderTop);
  Write(UpLeft);
  For Col:=BorderLeft+1 to BorderRight-22 do Write(HorizontalBorder);
  TextColor(NormalColor);
  Write(' AIDE RENJU ');
  TextColor(NormalColor-8);
  For Col:=BorderLeft+20 to BorderRight-1 do Write(HorizontalBorder);
  Write(UpRight);
  For Row:=BorderTop+1 to BorderBottom-1 do Begin
   GotoXY(BorderLeft, Row);
   Write(VerticalBorder);
   GotoXY(BorderRight, Row);
   Write(VerticalBorder);
  End;
  GotoXY(BorderLeft, BorderBottom);
  Write(DownLeft);
  For Col:=BorderLeft+1 to BorderRight-1 do Write(HorizontalBorder);
  Write(DownRight);
 End;

 Procedure DisplayHelp;
 Const
  PgDn=#81;
  PgUp=#73;
  ScrlDn=#80;
  ScrlUp=#72;
 Var
  TopLine,BottomLine,MaxRows:Integer;
  PgCommand:Char;

  Procedure DisplayPage(TopLine,BottomLine:Integer);
  Var
   Row:Integer;
  Begin
   ClrScr;
   For Row:=TopLine to BottomLine do Begin
    If Row<>BottomLine Then WriteLn(HelpText[Row])
                       Else Write(HelpText[Row]);
   End;
   GotoXY(1,LastRow);
  End;

 Begin
  MaxRows:=LastRow-FirstRow+1;
  TopLine:=1;
  If MaxRows>MaxLines Then BottomLine:=MaxLines
                      Else BottomLine:=MaxRows;
  DisplayPage(TopLine,BottomLine);
  Repeat
   PgCommand:=ReadKey;
   PgCommand:=UpCase(PgCommand);
   If PgCommand in[#3,'Q']Then Finish;
   If(PgCommand=#0)Then Begin
    PgCommand:=ReadKey;
    PgCommand:=UpCase(PgCommand);
    Case PgCommand of
     PgDn:Begin
      If BottomLine+1<=MaxLines Then Begin
       If(BottomLine+MaxRows)>MaxLines Then BottomLine:=MaxLines
                                       Else BottomLine:=BottomLine+MaxRows;
       If(BottomLine-MaxRows+1)>=1 Then TopLine:=(BottomLine-MaxRows+1)
                                   Else TopLine:=1;
       DisplayPage(TopLine,BottomLine);
      End;
     End;
     PgUp:Begin
      If TopLine>1 Then Begin
       If(TopLine-MaxRows)>1 Then TopLine:=TopLine-MaxRows
                             Else TopLine:=1;
       If(TopLine+MaxRows-1)>MaxLines Then BottomLine:=MaxLines
                                      Else BottomLine:=TopLine+MaxRows-1;
       DisplayPage(TopLine,BottomLine);
      End;
     End;
     ScrlDn:Begin
      If BottomLine<MaxLines Then Begin
       TopLine:=TopLine+1;
       BottomLine:=BottomLine+1;
       GotoXY(1,1);
       DelLine;
       GotoXY(1,MaxRows);
       InsLine;
       Write(HelpText[BottomLine]);
       GotoXY(1,MaxRows);
      End;
     End;
     ScrlUp:Begin
      If TopLine>1 Then Begin
       If(BottomLine-TopLine+1)> MaxRows Then BottomLine:=BottomLine-1;
       TopLine:=TopLine-1;
       GotoXY(1,MaxRows);
       DelLine;
       GotoXY(1,1);
       InsLine;
       Write(HelpText[TopLine]);
       GotoXY(1,MaxRows);
      End;
     End;
    End;
   End;
  Until(PgCommand=#27);
 End;

Begin
 GotoXY(49, 5);
 WriteHelp('ESC-Sortie de l''aide', 3);
 Window(FirstCol-2,FirstRow-1,LastCol+1,LastRow+2);
 GotoXY(1,1);
 DrawBorder;
 GotoXY(BorderLeft+1,BorderBottom+1);
 WriteHelp(#24+#196,1);
 WriteHelp(#25+#196+'DÇfile  ',1);
 WriteHelp('PgUp' + #196, 4);
 WriteHelp('PgDn' + #196 + 'Page',4);
 Window(FirstCol, FirstRow, LastCol,LastRow);
 GotoXY(1,1);
 DisplayHelp;
 Window(FirstCol-2,FirstRow-1,LastCol+1,LastRow+2);
 GotoXY(1,1);
 ClrScr;
 Window(1,1,80,25);
 GotoXY(1,1);
 GotoXY(49,5);
 WriteHelp('?-Pour l''aide    ',1);
End;

Procedure WriteCommand(S:String);Begin
 TextColor(NormalColor);
 Write(S[1]);
 TextColor(NormalColor-8);
 Write(Copy(S,2,Length(s)-1));
End;

Procedure ResetGame(FirstGame:Boolean);
Var
 I,J:IndexType;
 D:0..3;
 C:ColorType;
Begin
 SetUpScreen;
 If FirstGame Then Begin
  TextColor(HeadingColor);
  GotoXY(49, 1);
  Write('R E N J U');
  GotoXY(49,3);
  WriteCommand('Nouvelle partie ');
  WriteCommand('Quitte ');
  GotoXY(49,4);
  WriteCommand('Auto ');
  WriteCommand('Jouer ');
  WriteCommand('Indice');
  GotoXY(49,5);
  WriteHelp('?-pour Aide   ', 1);
  FirstGame := false;
 End
  Else
 Begin
  ClearMsg;
  ClearMove;
 End;
 For I:=1 to N do For J:=1 to N do Begin
  Board[I,J]:=Empty;
  For C:=Cross to Nought do Begin
   Value[I,J,C]:=0;
   For D:=0 to 3 do Line[D,I,J,C]:=0;
  End;
 End;
 Player:=Cross;
 TotalLines:=2*2*(N*(N-4)+(N-4)*(N-4));
 GameWon:=False;
End;

Function OpponentColor(Player:ColorType):ColorType;Begin
 If Player=Cross Then OpponentColor:=Nought
                 Else OpponentColor:=Cross;
End;

Procedure BlinkWinner(Piece:ColorType;X,Y:IndexType;WinningLine:TypeOfWin);
Var
 XHold,YHold:Integer;
 Dx,Dy:Integer;

 Procedure BlinkRow(X,Y,Dx,Dy:Integer);
 Var
  I:Integer;
 Begin
  TextColor(PieceColor[Piece]+Blink);
  For I:=1 to 5 do Begin
   GotoSquare(X,Y);
   Write(PieceChar[Piece]);
   X:=X-Dx;
   Y:=Y-Dy;
  End;
 End;

Begin
 TextColor(PieceColor[Piece]);
 GotoXY(49, 9);
 Write(PieceChar[Piece],Chr(Ord('A')+X-1):2,Y);
 ClrEOL;
 XHold:=X;
 YHold:=Y;
 Case WinningLine of
  Horiz:Begin
   Dx:=1;
   Dy:=0;
  End;
  DownLeft:Begin
   Dx:=1;
   Dy:=1;
  End;
  Vert:Begin
   Dx:=0;
   Dy:=1;
  End;
  DownRight:Begin
   Dx:=-1;
   Dy:=1;
  End;
 End;
 While((X+Dx)>=1)and((X+Dx)<=n)and((Y+DY)>=1)and((Y+DY)<=n)and
      (Board[X+Dx,Y+Dy]<>Empty)and(Board[X+Dx,Y+Dy]=Piece )do Begin
  X:=X+Dx;
  Y:=Y+Dy;
 End;
 BlinkRow(X,Y,Dx,Dy);
 X:=XHold;
 Y:=YHold;
 GotoSquare(X,Y);
 TextColor(NormalColor);
End;

Procedure MakeMove(X,Y:IndexType);
Var
 Opponent:ColorType;
 X1,Y1:Integer;
 K,L:NumberType;
 WinningLine:TypeOfWin;

 Procedure Add(Var Num:NumberType);Begin
  Num:=Num+1;
  If Num=1 Then TotalLines:=TotalLines-1;
  If Num =5 Then GameWon:=True;
 End;

 Procedure Update(L:LineType;Var V:ValueType);Begin
  If L[Opponent]=0 Then V[Player]:=V[Player]+Weight[L[Player]+1]-Weight[L[Player]] Else
  If L[Player]=1 Then V[Opponent]:=V[Opponent]-Weight[L[Opponent]+1];
 End;

Begin
 WinningLine:=Null;
 Opponent:=OpponentColor(Player);
 GameWon:=False;
 For K:=0 to 4 do Begin
  X1:=X-K;
  Y1:=Y;
  If(1<=X1)and(X1<=N-4)Then Begin
   Add(Line[0,X1,Y1,Player]);
   If GameWon and (WinningLine=Null)Then WinningLine:=Horiz;
   For L:=0 to 4 do Update(Line[0,X1,Y1],Value[X1+L,Y1]);
  End;
 End;
 For K:=0 to 4 do Begin
  X1:=X-K;
  Y1:=Y-K;
  If(1<=X1)and(X1<=N-4)and(1<=Y1)and(Y1<=N-4)Then Begin
   Add(Line[1,X1,Y1,Player]);
   If GameWon and (WinningLine=Null)Then WinningLine:=DownLeft;
   For L:=0 to 4 do Update(Line[1,X1,Y1],Value[X1+L,Y1+L]);
  End;
 End;
 For K:=0 to 4 do Begin
  X1:=X+K;
  Y1:=Y-K;
  If(5<=X1)and(X1<=N)and(1<=Y1)and(Y1<=N-4)Then Begin
   Add(Line[3,X1,Y1,Player]);
   If GameWon and (WinningLine=Null)Then WinningLine:=DownRight;
   For L:=0 to 4 do Update(Line[3,X1,Y1],Value[X1-L,Y1+L]);
  End;
 End;
 For K:=0 to 4 do Begin
  X1:=X;
  Y1:=Y-K;
  If(1<=Y1)and(Y1<=N-4)Then Begin
   Add(Line[2,X1,Y1,Player]);
   If GameWon and(WinningLine=Null)Then WinningLine:=Vert;
   For L:=0 to 4 do Update(Line[2,X1,Y1],Value[X1,Y1+L]);
  End;
 End;
 Board[X,Y]:=Player;
 If GameWon Then BlinkWinner(Player,X,Y,WinningLine)
            Else PrintMove(Player,X,Y);
 Player:=Opponent;
End;

Function GameOver:Boolean;Begin
 GameOver:=GameWon or (TotalLines<=0);
End;

Procedure FindMove(Var X,Y:IndexType);
Var
 Opponent:ColorType;
 I,J:IndexType;
 Max,Valu:Integer;
Begin
 Opponent:=OpponentColor(Player);
 Max:=-MaxInt;
 X:=(N+1) shr 1;
 Y:=(N+1) shr 1;
 If Board[X,Y]=Empty Then Max:=4;
 For I:=1 to N do For J:=1 to N do If Board[I,J]=Empty Then Begin
  Valu:=Value[I,J,Player]*(16+AttackFactor) div 16+Value[I,J,Opponent]+Random(4);
  If Valu>Max Then Begin
   X:=I;
   Y:=J;
   Max:=Valu;
  End;
 End;
End;

Procedure ClearBuffer;
Var
 Ch:Char;
Begin
 While KeyPressed do Ch:=ReadKey;
End;

Procedure ReadCommand(X,Y:IndexType;Var Command:Char);
Var
 ValidCommand:Boolean;
Begin
 Repeat
  ValidCommand:=True;
  GotoSquare(X,Y);
  Command:=UpCase(ReadKey);
  Case Command of
   '?':Help;
   #3:Command:='Q';
   #13,#32:Command:='E';
   #0:Begin
    Command:=UpCase(ReadKey);
    Case Command of
     #59:Help;
     'K':Command:='L';
     'M':Command:='R';
     'P':Command:='D';
     'H':Command:='U';
     'G':Command:='7';
     'I':Command:='9';
     'O':Command:='1';
     'Q':Command:='3';
     Else Begin
      ValidCommand:=False;
      ClearBuffer;
     End;
    End;
   End;
   #27:If GameOver Then command:='P'
    Else
   Begin
    ValidCommand:=False;
    ClearBuffer;
   End;
   'N','Q','A','P','H','J':;
   Else Begin
    ValidCommand:=False;
    ClearBuffer;
   End;
  End;
 Until ValidCommand;
End;

Procedure InterpretAction(Command:Char);
Var
 Temp:Integer;
Begin
 Case Command of
  'N':Begin
   ResetGame(false);
   X:=(N+1) shr 1;
   Y:=X;
  End;
  'H':FindMove(X, Y);
  'L':X:=(X+N-2) mod N+1;
  'R':X:=X mod N+1;
  'D':Y:=(Y+N-2) mod N+1;
  'U':Y:=Y mod N + 1;
  '7':Begin
   If(X=1)or(Y=N)Then Begin
    Temp:=X;
    X:=Y;
    Y:=Temp;
   End
    Else
   Begin
    X:=X-1;
    Y:=Y+1;
   End;
  End;
  '9':Begin
   If X=N Then Begin
    X:=(N-Y)+1;
    Y:=1;
   End
   Else If Y=N Then Begin
    Y:=(N-X)+1;
    X:=1;
   End
   Else Begin
    X:=X+1;
    Y:=Y+1;
   End
  End;
  '1':Begin
   If Y=1 Then Begin
    Y:=(N-X)+1;
    X:=N;
   End
   Else If X=1 Then Begin
    X:=(N-Y)+1;
    Y:=N;
   End
    Else
   Begin
    X:=X-1;
    Y:=Y-1;
   End;
  End;
  '3':Begin
   If(X=N)or(Y=1)Then Begin
    Temp:=X;
    X:=Y;
    Y:=Temp;
   End
    Else
   Begin
    X:=X+1;
    Y:=Y-1;
   End;
  End;
  'A':AutoPlay:=True;
 End;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 ClrScr;
 Randomize;
 AutoPlay:=False;
 FileRead:=False;
 ResetGame(True);
 X:=(N+1) shr 1;
 Y:=X;
 For I:=1 to 3 do Begin
  FindMove(X,Y);
  MakeMove(X,Y);
 End;
 Repeat
  ReadCommand(X,Y,Command);
  If(GameOver)Then Begin
   If Command<>'Q'Then Command:='N';
  End;
  InterpretAction(Command);
  If Command='E'Then Begin
   If Board[X,Y]=Empty Then Begin
    MakeMove(X,Y);
    If(GameWon)Then PrintMsg('FÇlications, vous gagnez !');
    Command:='P';
   End;
  End;
  If Command in ['P','J','A']Then Begin
   Repeat
    If KeyPressed Then ClearBuffer;
    If(GameOver)Then Begin
     AutoPlay:=False;
     If(Command<>'Q')and(Not GameWon)Then PrintMsg('Match nul!');
    End
     Else
    Begin
     FindMove(X,Y);
     MakeMove(X,Y);
     If GameWon Then PrintMsg('Je gagne !');
    End;
   Until AutoPlay=False;
  End;
 Until Command in ['Q',#3];
 Finish;
END.
