{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2011
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program BLOX;

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Const
 {Code de touche clavier renvoyee par ReadKey}
 kbNoKey=0;{Pas de touche}
 kbEsc=$011B;{Escape}
 kbUp=$4800;{Up}
 kbLeft=$4B00;{Fleche de gauche (Left)}
 kbKeypad5=$4CF0;{5 du bloc numerique}
 kbRight=$4D00;{Fleche de droite (Right)}
 kbDn=$5000;{Fleche du bas (Down)}

 HomeX=15;
 HomeY=3;

Var
 IsGraph:Boolean;
 Mode:(tmNone,tmStart,tmPlay,tmGameOver);
 Level,CurrAttr:Byte;
 Score:LongInt;
 _Bar,SLevel:Word;
 Tbl:Array[0..20,0..9]of Boolean;
 Form,_Move,X,Y,Sleep:Byte;
 Touch,Ok:Boolean;
 SleepDelay:Byte;
 FBar:Word;
 UpDate:Boolean;

{$IFNDEF FPC}
 Procedure CursorOff;
 Var
  Regs:Registers;
 Begin
  Regs.AH:=1;
  Regs.CH:=32;
  Regs.CL:=0;
  Intr($10,Regs);
 End;

 Procedure CursorOn;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0100;
  Regs.CX:=(7 shl 8)+9;
  Intr($10,Regs);
 End;
{$ENDIF}

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function LongToStr(X:LongInt):String;
Var
 S:String;
Begin
 Str(X,S);
 LongToStr:=S;
End;

Procedure InitScr;
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
 InitGraph(Driver,Mode,'');
 ErrCode:=GraphResult;
 If ErrCode=grOk Then Begin
  IsGraph:=True;
  SetColor(White);
  SetLineStyle(0,0,1);
 End;
End;

Procedure WaitRetrace;Begin
 Delay(1000 div 60);
End;

Procedure MoveRight(Const Source;Var Dest;_Length:LongInt);Begin
 Move(Source,Dest,_Length);
End;

Procedure TextAttr(Attr:Byte);Begin
 CurrAttr:=Attr;
 TextColor(Attr and $F);
 TextBackground(Attr shr 4);
End;

Procedure ScrollWindowDown(X1,Y1,X2,Y2:Integer);
Var
 Size:Word;
 P:Pointer;
 J:Integer;
Begin
 Size:=ImageSize(X1*8,Y1*8,(X2+1)*8-1,(Y1+1)*8-1);
 GetMem(P,Size);
 For J:=Y1+1 to Y2 do Begin
  GetImage(X1*8,J*8,(X2+1)*8-1,(J+1)*8-1,P^);
  PutImage(X1*8,(J-1)*8,P^,NormalPut);
 End;
 FreeMem(P,Size);
 SetFillStyle(SolidFill,Black);
 Bar(X1*8,Y2*8,(X2+1)*8-1,(Y2+1)*8-1);
End;

Procedure ScrollWindowUp(X1,Y1,X2,Y2:Integer);
Var
 Size:Word;
 P:Pointer;
 J:Integer;
Begin
 Size:=ImageSize(X1*8,Y1*8,(X2+1)*8-1,(Y1+1)*8-1);
 GetMem(P,Size);
 For J:=Y2-1 downto Y1 do Begin
  GetImage(X1*8,J*8,(X2+1)*8-1,(J+1)*8-1,P^);
  PutImage(X1*8,(J+1)*8,P^,NormalPut);
 End;
 FreeMem(P,Size);
 SetFillStyle(SolidFill,Black);
 Bar(X1*8,Y1*8,(X2+1)*8-1,(Y1+1)*8-1);
End;

Procedure MoveText(X1,Y1,X2,Y2,X3,Y3:Byte);Begin
 If(IsGraph)Then Begin
  If(Y3>Y1)Then Begin
   ScrollWindowUp(X1,Y1,X2,Y2+1);
  End
   Else
  ScrollWindowDown(X1,Y1,X2,Y2+1);
 End
  Else
 Begin
  Window(X1,Y1,X2,Y2+1);
  If(Y3>Y1)Then Begin
   GotoXY(1,1);
   InsLine;
  End
   Else
  Begin
   GotoXY(1,1);
   DelLine;
  End;
  Window(1,1,40,25);
 End;
End;

Procedure BarSpcHor(X1,Y,X2:Byte);Begin
 If(IsGraph)Then Begin
  SetColor(CurrAttr shr 4);
  SetFillStyle(SolidFill,CurrAttr shr 4);
  Bar(X1*8,Y*8,X2*8+7,Y*8+7);
 End
  Else
 Begin
  Window(X1,Y,X2,Y);
  ClrScr;
  Window(1,1,40,25);
 End;
End;

Function InitGame:Boolean;Begin
 Mode:=tmStart;
 Level:=1;
 Score:=0;
 _Bar:=0;
 SLevel:=0;
 FillChar(Tbl,SizeOf(Tbl),0);
 Form:=0;
 _Move:=0;
 X:=0;
 Y:=0;
 Sleep:=0;
 Touch:=False;
 Ok:=False;
 SleepDelay:=0;
 FBar:=0;
 UpDate:=False;
End;

Procedure Box(X1,Y1,X2,Y2:Byte);Begin
 SetColor(White);
 Rectangle(X1*8-1,Y1*8-1,X2*8+8,Y2*8+8);
 Line(X1*8,Y1*8-2,X2*8+7,Y1*8-2);
 Line(X1*8,Y2*8+9,X2*8+7,Y2*8+9);
 Line(X1*8-2,Y1*8-1,X1*8-2,Y2*8+8);
 Line(X2*8+9,Y1*8-1,X2*8+9,Y2*8+8);
 SetColor(Black);
 SetFillStyle(SolidFill,Black);
 Bar(X1*8,Y1*8,X2*8+7,Y2*8+7);
End;

Procedure AddBlock;
Var
 I:Byte;
Begin
 For I:=1 to (Level+1)*10 do Begin
  Tbl[15+Random(5),Random(10)]:=True;
 End;
End;

Procedure StartGame;
Var
 I:Byte;
Begin
 FillChar(Tbl,SizeOf(Tbl),0);
 FillChar(Tbl[20],SizeOf(Tbl[20]),Byte(True));
 Score:=0;_Bar:=0;SleepDelay:=25;Level:=SLevel;
 For I:=0to(SLevel)do If SleepDelay>6Then Dec(SleepDelay,2);
 FBar:=Level shl 4;
 Mode:=tmStart;
End;

Procedure RefreshGame;
Var
 I,J,Attr:Byte;
Begin
 If(IsGraph)Then Begin
  SetColor(LightGray);
  SetFillStyle(SolidFill,LightGray);
  Bar(0,0,639,479);
  Box(2,4,HomeX-2,12);
  SetColor(White);
  OutTextXY(3*8,7*8,'Niveau');
  If Level=0 Then OutTextXY(4*8,8*8,'1')
             Else OutTextXY(4*8,8*8,LongToStr(Level));
  OutTextXY(3*8,4*8,'Pointage');
  OutTextXY(4*8,5*8,'0');
  OutTextXY(3*8,10*8,'Ligne');
  OutTextXY(4*8,11*8,LongToStr(_Bar));
  Box(HomeX,HomeY,HomeX+9,HomeY+19);
  If(Mode)in[tmPlay,tmGameOver]Then Begin
   For J:=0to 19do For I:=0to 9do If Tbl[J,I]Then Begin
    Attr:=$70+(1+Random(6));
    SetColor(Attr shr 4);
    SetFillStyle(SolidFill,Attr shr 4);
    Bar((HomeX+I)*8,(HomeY+J)*8,(HomeX+I)*8+7,(HomeY+J)*8+7);
    SetColor(Attr and $F);
    OutTextXY((HomeX+I)*8,(HomeY+J)*8,#254);
   End;
  End;
 End
  Else
 Begin
  TextBackground(1+Level);
  ClrScr;
  GotoXY(3,7);Write('Niveau :');
  GotoXY(4,8);Write(Level);
  GotoXY(3,4);Write('Pointage :');
  GotoXY(4,5);Write('0');
  GotoXY(3,10);Write('Ligne :');
  GotoXY(4,11);Write(_Bar);
  Window(HomeX,HomeY,HomeX+9,HomeY+19);
  TextBackground(Black);
  ClrScr;
  Window(1,1,40,25);
  If(Mode)in[tmPlay,tmGameOver]Then Begin
   For J:=0to 19do For I:=0to 9do If Tbl[J,I]Then Begin
    GotoXY(HomeX+I,HomeY+J);Write(#254);
   End;
  End;
 End;
End;

Function PlayGame:Word;
Label _Exit;
Const
      BlkHeight:Array[0..6,0..3]of Byte=(
       (4,1,4,1), { Barre }
       (2,2,2,2), { Boite }
       (3,2,3,2), { V }
       (3,2,3,2), { L gauche }
       (3,2,3,2), { L droite }
       (3,2,3,2), { Serpent romain }
       (3,2,3,2));{ Serpent arabe }
      BlkLength:Array[0..6,0..3]of Byte=( {Largeur des objets:}
       (1,4,1,4), { Barre }
       (2,2,2,2), { Boite }
       (2,3,2,3), { V }
       (2,3,2,3), { L gauche }
       (2,3,2,3), { L droite }
       (2,3,2,3), { Serpent romain }
       (2,3,2,3));{ Serpent arabe }
      BlkFormat:Array[0..6,0..3,0..3]of Record X,Y:Byte;End=(
       (((X:0;Y:0),(X:0;Y:1),(X:0;Y:2),(X:0;Y:3)),   { ____ }
        ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:3;Y:0)),
        ((X:0;Y:0),(X:0;Y:1),(X:0;Y:2),(X:0;Y:3)),
        ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:3;Y:0))),
       (((X:0;Y:0),(X:1;Y:0),(X:0;Y:1),(X:1;Y:1)),   { __ }
        ((X:0;Y:0),(X:1;Y:0),(X:0;Y:1),(X:1;Y:1)),   { __ }
        ((X:0;Y:0),(X:1;Y:0),(X:0;Y:1),(X:1;Y:1)),
        ((X:0;Y:0),(X:1;Y:0),(X:0;Y:1),(X:1;Y:1))),
       (((X:1;Y:0),(X:0;Y:1),(X:1;Y:1),(X:1;Y:2)),   { ___ }
        ((X:1;Y:0),(X:0;Y:1),(X:1;Y:1),(X:2;Y:1)),   { _ }
        ((X:0;Y:0),(X:0;Y:1),(X:1;Y:1),(X:0;Y:2)),
        ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:1;Y:1))),
       (((X:0;Y:0),(X:0;Y:1),(X:0;Y:2),(X:1;Y:2)),
        ((X:0;Y:1),(X:1;Y:1),(X:2;Y:1),(X:2;Y:0)),   { _ }
        ((X:0;Y:0),(X:1;Y:0),(X:1;Y:1),(X:1;Y:2)),   { _ }
        ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:0;Y:1))),  { __ }
       (((X:1;Y:0),(X:1;Y:1),(X:1;Y:2),(X:0;Y:2)),
        ((X:0;Y:1),(X:1;Y:1),(X:2;Y:1),(X:0;Y:0)),   { _ }
        ((X:1;Y:0),(X:0;Y:0),(X:0;Y:1),(X:0;Y:2)),   { _ }
        ((X:0;Y:0),(X:1;Y:0),(X:2;Y:0),(X:2;Y:1))),  { __ }
       (((X:0;Y:0),(X:0;Y:1),(X:1;Y:1),(X:1;Y:2)),
        ((X:1;Y:0),(X:2;Y:0),(X:0;Y:1),(X:1;Y:1)),
        ((X:0;Y:0),(X:0;Y:1),(X:1;Y:1),(X:1;Y:2)),
        ((X:1;Y:0),(X:2;Y:0),(X:0;Y:1),(X:1;Y:1))),
       (((X:1;Y:0),(X:0;Y:1),(X:1;Y:1),(X:0;Y:2)),
        ((X:0;Y:0),(X:1;Y:0),(X:1;Y:1),(X:2;Y:1)),
        ((X:1;Y:0),(X:0;Y:1),(X:1;Y:1),(X:0;Y:2)),   {__ }
        ((X:0;Y:0),(X:1;Y:0),(X:1;Y:1),(X:2;Y:1)))); { __ }
Var
 I,J,H,XT:Byte;
 XJ,YJ,K:Word;
 Touch,Ok,NoAction:Boolean;

 Procedure PutForm(Clr:Boolean);
 Var
  _Chr:Char;
  I,Attr:Byte;
 Begin
  If(Clr)Then Begin
   _Chr:=' ';
   Attr:=7;
  End
   Else
  Begin
   _Chr:=#254;
   Attr:=$71+Form;
  End;
  For I:=0to 3do Begin
   If(IsGraph)Then Begin
    SetColor(Attr shr 4);
    SetFillStyle(SolidFill,Attr shr 4);
    Bar((HomeX+X+BlkFormat[Form,_Move,I].X)*8,
        (HomeY+Y+BlkFormat[Form,_Move,I].Y)*8,
        (HomeX+X+BlkFormat[Form,_Move,I].X)*8+7,
        (HomeY+Y+BlkFormat[Form,_Move,I].Y)*8+7);
    SetColor(Attr and $F);
    OutTextXY((HomeX+X+BlkFormat[Form,_Move,I].X)*8,
              (HomeY+Y+BlkFormat[Form,_Move,I].Y)*8,_Chr);
   End
    Else
   Begin
    GotoXY(HomeX+X+BlkFormat[Form,_Move,I].X,
                             HomeY+Y+BlkFormat[Form,_Move,I].Y);
    TextAttr(Attr);
    Write(_Chr);
    TextAttr(7);
   End;
  End;
 End;

 Procedure Init;Begin
  Form:=Random(6);
  If Form=5Then Inc(Form,Random(2));
  X:=5;Y:=0;
  _Move:=0;Sleep:=0;
  PutForm(False);
 End;

 Function UpDateData:Boolean;
 Var
  H,I,J,JK:Byte;
  Bonus:Byte;
  LnChk:Boolean;
 Begin
  UpDateData:=True;Sleep:=0;
  PutForm(False);
  Touch:=False;Ok:=False;
  PutForm(True);
  Inc(Y);
  For I:=0to 3do Begin
   Touch:=Touch or Tbl[Y+BlkFormat[Form,_Move,I].Y,X+BlkFormat[Form,_Move,I].X];
  End;
  If(Touch)Then Dec(Y);
  PutForm(False);
  If(Touch)Then Begin
   While(Sleep>SleepDelay)do Dec(Sleep);
   Sleep:=0;Ok:=True;
   For I:=0to 3do Tbl[Y+BlkFormat[Form,_Move,I].Y,X+BlkFormat[Form,_Move,I].X]:=True;
   If Level>7Then Begin
    Inc(Score,LongInt(5)*Level);
    GotoXY(4,6);Write(Score);
   End;
   Bonus:=0;
   For J:=0to 19do Begin
    Touch:=True;
    For I:=0to 9do Touch:=Touch and Tbl[J,I];
    If(Touch)Then Inc(Bonus);
   End;
   If Bonus>0Then Dec(Bonus);
   Touch:=False;
   For JK:=0to 7do Begin
    For J:=0to 19do Begin
     LnChk:=True;
     For I:=0to 9do LnChk:=LnChk and Tbl[J,I];
     If(LnChk)Then Begin
      If Not(Touch)Then Begin
       Touch:=True;
      End;
      If JK and 1=0Then TextAttr($FF)
                   Else TextAttr(7);
      BarSpcHor(HomeX,HomeY+J,HomeX+9);
     End;
    End;
    WaitRetrace;WaitRetrace;WaitRetrace;
   End;
   For J:=0to 19do Begin
    Touch:=True;
    For I:=0to 9do Touch:=Touch and Tbl[J,I];
    If(Touch)Then Begin
     MoveRight(Tbl[0,0],Tbl[1,0],10*J);
     FillChar(Tbl[0,0],10,0);
     MoveText(HomeX,HomeY,HomeX+9,HomeY+J-1,HomeX,HomeY+1);
     Inc(Score,LongInt(5)+(Bonus*4)*(Level+1)+10*Level);
     Inc(_Bar);
     If(IsGraph)Then Begin
      TextAttr($7);
      BarSpcHor(4,5,12);
      SetColor(White);
      OutTextXY(4*8,5*8,LongToStr(Score));
      BarSpcHor(4,11,12);
      SetColor(White);
      OutTextXY(4*8,11*8,LongToStr(_Bar));
     End
      Else
     Begin
      GotoXY(4,5);
      Write(Score);
      GotoXY(4,11);
      Write(_Bar);
     End;
     I:=(_Bar+FBar)shr 4;
     If(Level<>I)Then Begin
      Level:=I;
      If(IsGraph)Then Begin
       AddBlock;
       RefreshGame;
       TextAttr($7);
       BarSpcHor(4,8,12);
       OutTextXY(4*8,8*8,LongToStr(Level+1));
      End
       Else
      Begin
       GotoXY(4,8);
       Write(Level+1);
      End;
      If SleepDelay>6Then Dec(SleepDelay,2);
     End;
    End;
   End;
   If Y<=1Then Begin
    UpDateData:=False;
    Exit;
   End;
   Init;
  End;
 End;

 Function GameOver:Word;Begin
  If(IsGraph)Then Begin
   OutTextXY(10*8,7*8,'Partie Terminer');
  End
   Else
  Begin
   GotoXY(10,7);
   Write('Partie Terminer');
  End;
  If(UpDate)Then Begin
   UpDate:=False;
  End;
  GameOver:=kbEsc;
 End;

Begin
 TextMode(CO40);
 CursorOff;
 RefreshGame;
 K:=0;
 Repeat
  Case(Mode)of
   tmStart:Begin
    StartGame;
    AddBlock;
    Mode:=tmPlay;
    RefreshGame;
    Init;
    UpDate:=True;
   End;
   tmPlay:Repeat
    Begin
     Repeat
      If(Sleep>SleepDelay)Then If Not(UpDateData)Then Begin
       Mode:=tmGameOver;
       Goto _Exit;
      End;
      WaitRetrace;
      Inc(Sleep);
     Until KeyPressed;
     K:=Byte(ReadKey);
     If K=0Then K:=K or (Byte(ReadKey)shl 8);
    End;
    If Chr(Lo(K))='2'Then K:=kbDn;
    If Chr(Lo(K))='4'Then K:=kbLeft;
    If Chr(Lo(K))='6'Then K:=kbRight;
    NoAction:=False;
    Case(K)of
     kbLeft:If X>0Then Begin
      Touch:=False;
      For I:=0to 3do Touch:=Touch or Tbl[Y+BlkFormat[Form,_Move,I].Y,X+BlkFormat[Form,_Move,I].X-1];
      If Not(Touch)Then Begin
       PutForm(True);
       Dec(X);
       PutForm(False);
      End;
     End;
     kbRight:If X+BlkLength[Form,_Move]-1<9Then Begin
      Touch:=False;
      For I:=0to 3do Touch:=Touch or Tbl[Y+BlkFormat[Form,_Move,I].Y,X+BlkFormat[Form,_Move,I].X+1];
      If Not(Touch)Then Begin
       PutForm(True);
       Inc(X);
       PutForm(False);
      End;
     End;
     kbDn:While(True)do Begin
      If Not(UpDateData)Then Begin
       Mode:=tmGameOver;
       Goto _Exit;
      End;
      If(Ok)Then Break;
     End;
     Else NoAction:=True;
    End;
    If(NoAction)Then Begin
     If(K=kbKeyPad5)or(Char(K)in[' ','5'])Then Begin
      Touch:=False;
      For I:=0to 3do Begin
       XT:=X+BlkFormat[Form,(_Move+1)and 3,I].X; Touch:=Touch or(XT>9);
       Touch:=Touch or Tbl[Y+BlkFormat[Form,(_Move+1)and 3,I].Y,XT];
      End;
      If Not(Touch)Then Begin
       PutForm(True);
       _Move:=(_Move+1)and 3;
       PutForm(False)
      End
       Else
      Begin
       Touch:=False;
       For I:=0to 3do Begin
        XT:=X;
        If XT>0Then Dec(XT);
        Inc(XT,BlkFormat[Form,(_Move+1)and 3,I].X); Touch:=Touch or(XT>9);
        Touch:=Touch or Tbl[Y+BlkFormat[Form,(_Move+1)and 3,I].Y,XT];
       End;
       If Not(Touch)Then Begin
        PutForm(True);
        Dec(X);
        _Move:=(_Move+1)and 3;
        PutForm(False);
       End;
      End;
     End
      Else
     Break;
    End;
   Until(K=kbEsc)or(Chr(Lo(K))='Q');
   tmGameOver:K:=GameOver;
  End;
_Exit:
  If K<>0Then Break;
 Until False;
 PlayGame:=K;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('BLOX : Cette commande permet de lancer le jeu BLOX.');
  WriteLn;
  WriteLn('Syntaxe : BLOX [/TEXT]');
  WriteLn;
  WriteLn(' /TEXT        Force le mode texte');
  WriteLn;
 End
  Else
 Begin
  IsGraph:=False;
  If StrToUpper(ParamStr(1))<>'/TEXT'Then InitScr;
  InitGame;
  PlayGame;
 End;
END.
