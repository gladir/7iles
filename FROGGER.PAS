{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Frogger;

{$R-}

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Label _Break3,_Break4;

Const
 {Code de touche clavier renvoy‚e par ReadKey}
 kbNoKey=0;{Pas de touche}
 kbEsc=$001B;{Escape}
 kbUp=$4800;{Up}
 kbLeft=$4B00;{FlŠche de gauche (Left)}
 kbRight=$4D00;{FlŠche de droite (Right)}
 kbDn=$5000;{FlŠche du bas (Down)}
 kbHome=$4700;{Home}
 kbTab=$0F09;{Tabulation}
 kbEnd=$4F00;{End}
 kbEnter=$000D;{Enter}
 kbF10=$4400;{F10}

Var
 CarX:Array[0..3,0..9]of Integer;
 CarKr:Array[0..3,0..9]of Byte;
 BileauX:Array[0..3,0..9]of Integer;
 WaitCar,WaitBileau,NmWait,Timer:Word;
 FroggerX,FroggerY:Integer;
 Traverser,Accident,Life:Byte;
 K:Word;

Const
 DrawS:Integer=4;
 XL:Integer=160;
 YL:Integer=100;

Var
 I:Byte;
 N:String;
 Mode:(_None_,_NoTrace_,_UnMove_);
 a,b:Integer;
 xc,yc:(NoMove,Add,Sub);

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
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure WaitRetrace;Begin
 Delay(10*15);
End;

Function ExtractNm(S:String):Integer;
Var
 N:String;
 a,b:Integer;
Begin
 N:='';
 While(I<=Length(S))and(S[I] in ['0'..'9'])do Begin
  N:=N+S[I];
  Inc(I);
 End;
 If N=''Then a:=1
Else Val(N,a,b);
 ExtractNm:=a;
End;

Function ExtractNmV(S:String):Integer;Begin
 ExtractNmV:=ExtractNm(S)*(DrawS shr 2)
End;

Procedure Line2(X,Y:Integer);Begin
 If(Mode<>_NoTrace_)Then Begin
  Case(xc)of
   Add:Inc(X,XL);
   Sub:X:=XL-X;
  End;
  Case(yc)of
   Add:Inc(Y,YL);
   Sub:Y:=YL-Y;
  End;
  If(YL=Y)and(X<XL)Then Begin
   MoveTo(X,YL);
   LineTo(XL,Y);
  End
   Else
  Begin
   MoveTo(XL,YL);
   LineTo(X,Y);
  End;
 End;
End;

Procedure SetPos(X,Y:Integer);Begin
 Case(xc)of
  Add:Inc(X,XL);
  Sub:X:=XL-X;
 End;
 Case(yc)of
  Add:Inc(Y,YL);
  Sub:Y:=YL-Y;
 End;
 If(Mode<>_UnMove_)Then Begin
  XL:=X;
  YL:=Y;
 End;
 Mode:=_None_;
 xc:=NoMove;
 yc:=NoMove;
End;


Procedure Draw(S:String);Begin
 I:=1;Mode:=_None_;
 While I<=Length(S)do Begin
  Inc(I);
  Case S[I-1]of
   'B':Mode:=_NoTrace_;
   'C':SetColor(ExtractNm(S));
   'D':Begin
    a:=ExtractNmV(S);
    Line2(XL,YL+a);
    SetPos(XL,YL+a);
   End;
   'E':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL-a);
    SetPos(XL+a,YL-a);
   End;
   'F':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL+a);
    SetPos(XL+a,YL+a);
   End;
   'G':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL+a);
    SetPos(XL-a,YL+a);
   End;
   'H':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL-a);
    SetPos(XL-a,YL-a);
   End;
   'L':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL);
    SetPos(XL-a,YL);
   End;
   'M':Begin
    If S[I]in['+','-']Then Begin
     If S[I]='+'Then xc:=Add else xc:=Sub;
     Inc(I);
    End;
    a:=ExtractNm(S);
    If S[I]=','Then Begin
     Inc(I);
     If S[I]in['+','-']Then Begin
      If S[I]='+'Then yc:=Add else yc:=Sub;
      Inc(I);
     End;
     b:=ExtractNm(S);
    End
     Else
    b:=YL;
    Line2(a,b);
    SetPos(a,b);
   End;
   'N':Mode:=_UnMove_;
   'R':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL);
    SetPos(XL+a,YL)
   End;
   'U':Begin
    a:=ExtractNmV(S);
    Line2(XL,YL-a);
    SetPos(XL,YL-a)
   End;
' ',';':;{C'est 2 caractŠres ne change rien en soit, donc...pas d'arrˆt!}
   Else Exit;
  End
 End
End;

Procedure _PutFrogger(X,Y:Integer);
Begin
 SetPos(X+8,Y); {Affiche la grenouille}
 Draw('RFL3BL3L0BL2R0BR11R0BR2DL2BL2L5BL2L2FBR3R5BR3GL0BL2L5BL2FR7GL5R5BFBRL0BL2L5BL2DR9DBL3L3BL3DL2BR11R2');
End;

Procedure PutFrogger(X,Y:Integer);Begin
 SetColor(LightGreen);
 _PutFrogger(X,Y);
End;

Procedure UnputFrogger(X,Y:Integer);
Var
 Kr:Byte;
Begin
 Case(Y)of
  3*12..10*12-1:Kr:=Blue;
  10*12..11*12-1:Kr:=Green;
  11*12..15*12-1:Kr:=LightGray;
  Else Kr:=Green;
 End;
 SetFillStyle(SolidFill,Kr);
 SetColor(Kr);
 Bar(X,Y,X+15,Y+11);
{ _PutFrogger(X,Y);}
End;

Procedure PutFeuille(X,Y:Integer);Begin
 SetPos(X+8,Y); {Affiche la feuille}
 Draw('C3F3DFD2GDGL2H2UE2G3HBD2D0GBU2LHU2E4RE');
End;

Procedure PutBillot(X,Y:Integer);Begin
 SetViewPort(0,0,239,199,True);
 SetPos(X+48,Y); {Billot}
 Draw('C6L45G2DGD2FDF2R46E2UEU2HUH2G2DGD2FDF2');
 SetPos(X+40,Y+5); {Tiret b–che}
 Draw('C14BU3L3BD3L1BH2L2BG1BL4L3BH3L5BD3BG2R3BG3R5BR4R3BE2BR3R2');
 SetViewport(0,0,319,199,False);
End;

Procedure UnputBillot(X,Y:Integer);Begin
 SetViewport(0,0,239,199,True);
 SetColor(Blue);
 SetFillStyle(SolidFill,Blue);
 Bar(X,Y,X+56,Y+11);
 SetViewport(0,0,319,199,False);
End;

Procedure PutCarRight(X,Y,Kr:Integer);Begin
 SetPos(X+8,Y); {Automobile vers la droite}
 SetColor(Kr);
 Draw('R5FL8GRBR5R0BR4DBL4L0BL5LGR2BR5R0BR5R2FRL17GR19FL21DR21BDBLL4BL10L4BFBR2L2BR14R2BR2BE10');
End;

Procedure PutCarLeft(X,Y,Color:Integer);Begin
 SetPos(X+8,Y); {Automobile vers la gauche}
 SetColor(Color);
 Draw('L5GR8FLBL5L0BL4DBR4R0BR5RFL2BL5L0BL5L2GLR17FL19GR21DL21BDBRR4BR10R4BGBL2R2BL14L2BR26BE10');
End;

Procedure UpdateTraverser;
Var
 S:String;
Begin
 SetBkColor(LightGreen);
 SetColor(LightGray);
 Str(Traverser,S);
 OutTextXY(1*8,2*8,'Traverser : '+S);
End;

Function RunBillot:Boolean;
Label _Break,_Break2;
Const Largeur=56;
Var
 I,J,K:Byte;
 BileauFound:Boolean;
 SurLeBileau:Boolean;
 MoveFrogger:Boolean;
Begin
 RunBillot:=True;
 MoveFrogger:=False;
 SurLeBileau:=False;
 For J:=0to 1do For I:=0to 9do Begin
  If BileauX[J,I]=-1Then Begin
   BileauFound:=False;
   For K:=0to 9do Begin
    If BileauX[J,K]in[204..239]Then Begin
	 BileauFound:=True;
	 Goto _Break;
	End;
   End;
_Break:
   If Not(BileauFound)Then Begin
    If WaitBileau=0Then Begin
     WaitBileau:=Random(NmWait);
     BileauX[J,I]:=204+J*12;
     PutBillot(BileauX[J,I],(6+J)*12);
    End
     Else
    Dec(WaitBileau);
   End;
  End
   Else
  Begin
   UnputBillot(BileauX[J,I],(6+J)*12);
   If BileauX[J,I]<24Then BileauX[J,I]:=-1
    Else
   Begin
    Dec(BileauX[J,I],24);
    PutBillot(BileauX[J,I],(6+J)*12);
   End;
  End;
  If(FroggerY=(6+J)*12)Then Begin
   If Not(MoveFrogger)Then Begin
    If(FroggerX > 0)Then Begin
     Dec(FroggerX,24);
	 MoveFrogger:=True;
    End;
   End;
   If((FroggerX-BileauX[J,I])in[0..Largeur-1])Then Begin
    SurLeBileau:=True;
    PutFrogger(FroggerX,FroggerY);
   End;
  End;
 End;
 For J:=2to 3do For I:=0to 9do Begin
  If BileauX[J,I]=-1Then Begin
   BileauFound:=False;
   For K:=0to 9do Begin
    If BileauX[J,K]in[0..Largeur-1]Then Begin
	 BileauFound:=True;
	 Goto _Break2;
	End;
   End;
_Break2:
   If Not(BileauFound)Then Begin
    If WaitBileau=0Then Begin
     WaitBileau:=Random(NmWait);
     BileauX[J,I]:=(J-2)*12;
     PutBillot(BileauX[J,I],(6+J)*12);
    End
     Else
    Dec(WaitBileau);
   End;
  End
   Else
  Begin
   UnputBillot(BileauX[J,I],(6+J)*12);
   Inc(BileauX[J,I],24);
   If BileauX[J,I]>(240-Largeur)Then BileauX[J,I]:=-1
   Else PutBillot(BileauX[J,I],(6+J)*12);
  End;
  If(FroggerY=(6+J)*12)Then Begin
   If Not(MoveFrogger)Then Begin
    If(FroggerX <= 239)Then Begin
	 Inc(FroggerX,24);
	 MoveFrogger:=True;
	End;
   End;
   If((FroggerX-BileauX[J,I])in[0..Largeur-1])Then Begin
    SurLeBileau:=True;
    PutFrogger(FroggerX,FroggerY);
   End;
  End;
 End;
 If(SurLeBileau)Then RunBillot:=False
		Else RunBillot:=FroggerY<=108;
End;

Function RunCar:Boolean;
Label _Break,_Break2;
Var
 I,J,K:Byte;
 CarFound:Boolean;
Begin
 RunCar:=True;
 For J:=0to 1do For I:=0to 9do Begin
  If CarX[J,I]=-1Then Begin
   CarFound:=False;
   For K:=0to 9do Begin
    If CarX[J,K]in[204..239]Then Begin
	 CarFound:=True;
	 Goto _Break;
	End;
   End;
_Break:
   If Not(CarFound)Then Begin
    If WaitCar=0Then Begin
     WaitCar:=Random(NmWait);
     CarX[J,I]:=204+J*12;CarKr[J,I]:=Random(15);
     If(CarKr[J,I]=LightGray)Then CarKr[J,I]:=LightRed;
     PutCarLeft(CarX[J,I],(11+J)*12,CarKr[I,J]);
    End
     Else
    Dec(WaitCar);
   End;
  End
   Else
  Begin
   PutCarLeft(CarX[J,I],(11+J)*12,LightGray);
   If CarX[J,I]<24Then CarX[J,I]:=-1
    Else
   Begin
    Dec(CarX[J,I],24);
    PutCarLeft(CarX[J,I],(11+J)*12,CarKr[I,J]);
   End;
  End;
  If(FroggerY=(11+J)*12)and((FroggerX-CarX[J,I])in[0..23])Then Exit;
 End;
 For J:=2to 3do For I:=0to 9do Begin
  If CarX[J,I]=-1Then Begin
   CarFound:=False;
   For K:=0to 9do Begin
    If CarX[J,K]in[0..23]Then Begin
	 CarFound:=True;
	 Goto _Break2;
	End;
   End;
_Break2:
   If Not(CarFound)Then Begin
    If WaitCar=0Then Begin
     WaitCar:=Random(NmWait);
     CarX[J,I]:=(J-2)*12;CarKr[J,I]:=Random(15);
     If(CarKr[J,I]=LightGray)Then CarKr[J,I]:=LightRed;
     PutCarRight(CarX[J,I],(11+J)*12,CarKr[I,J]);
    End
     Else
    Dec(WaitCar);
   End;
  End
   Else
  Begin
   PutCarRight(CarX[J,I],(11+J)*12,LightGray);
   Inc(CarX[J,I],24);
   If CarX[J,I]>(240-24)Then CarX[J,I]:=-1
   Else PutCarRight(CarX[J,I],(11+J)*12,CarKr[I,J]);
  End;
  If(FroggerY=(11+J)*12)and((FroggerX-CarX[J,I])in[0..23])Then Exit;
 End;
 RunCar:=False;
End;

Procedure PutTimer;
Var
 S:String;
Begin
 SetColor(LightRed);
 Str(Timer,S);
 OutTextXY(34*8,23*8,S+'  ');
End;

Procedure PutLife;
Var
 J:Byte;
Begin
 SetColor(LightGreen);
 For J:=0to 3do Begin
  If(Life-1<J)Then SetColor(Black);
  _PutFrogger(272,10+40*J);
 End;
End;

BEGIN
 Randomize;
 InitScr;
 Life:=4;NmWait:=64;Traverser:=0;
 Repeat
  SetColor(Green);
  SetFillStyle(SolidFill,Green);
  Bar(0,0,239,35);
  SetColor(Blue);
  SetFillStyle(SolidFill,Blue);
  Bar(0,3*12,239,10*12-1);
  SetColor(Green);
  SetFillStyle(SolidFill,Green);
  Bar(0,10*12,239,11*12-1);
  SetColor(LightGray);
  SetFillStyle(SolidFill,LightGray);
  Bar(0,11*12,239,15*12-1);
  SetColor(Green);
  SetFillStyle(SolidFill,Green);
  Bar(0,15*12,239,199);
  SetColor(LightRed);
  SetFillStyle(SolidFill,LightRed);
  Bar(244,0,315,199);
  SetColor(LightRed);
  OutTextXY(32*8,21*8,'Horloge:');
  PutLife;
  UpdateTraverser;
  FillChar(CarX,SizeOf(CarX),$FF);
  FillChar(BileauX,SizeOf(Bileaux),$FF);
  WaitCar:=0;WaitBileau:=0;FroggerX:=120;FroggerY:=180;Timer:=400;Accident:=0;
  SetColor(LightGreen);
  _PutFrogger(FroggerX,FroggerY);
  PutTimer;
  Repeat
   Repeat
    If(RunCar)Then Begin
     Accident:=1;
     Goto _Break3;
    End;
    If(RunBillot)Then Begin
     Accident:=3;
     Goto _Break3;
    End;
    WaitRetrace;
    Dec(Timer);
    PutTimer;
    If Timer=0Then Begin
	 Accident:=2;
	 Goto _Break4;
	End;
   Until KeyPressed;
_Break4:
   If Accident>0Then Goto _Break3;
   K:=Byte(ReadKey);
   If K=0Then K:=K or (Byte(ReadKey)shl 8);
   Case(K)of
    kbLeft:If FroggerX>0Then Begin
     UnputFrogger(FroggerX,FroggerY);
     Dec(FroggerX,12);
     PutFrogger(FroggerX,FroggerY);
    End;
    kbRight:If FroggerX<239-24Then Begin
     UnputFrogger(FroggerX,FroggerY);
     Inc(FroggerX,12);
     PutFrogger(FroggerX,FroggerY);
    End;
    kbUp:If FroggerY>47Then Begin
     UnputFrogger(FroggerX,FroggerY);
     Dec(FroggerY,12);
     If FroggerY<48 Then Begin
      Inc(Traverser);
      If Traverser>3 Then Begin
       SetColor(Green);
       SetFillStyle(SolidFill,Green);
       Bar(0,0,239,7);
       SetColor(LightGreen);
       OutTextXY(0,0,'Vous avez gagn‚, vous avez fait travers‚ 4 grenouilles sans qu''ils soient ‚cras‚ !');
       Exit;
      End
       Else
      Begin
       Goto _Break3;
      End;
     End;
     PutFrogger(FroggerX,FroggerY);
    End;
    kbDn:If FroggerY<180Then Begin
     UnputFrogger(FroggerX,FroggerY);
     Inc(FroggerY,12);
     PutFrogger(FroggerX,FroggerY);
    End;
    kbEsc:Exit;
   End;
  Until False;
_Break3:
  {ClrKbd;}
  Case(Accident)of
   1:Begin
    SetColor(Green);
    SetFillStyle(SolidFill,Green);
    Bar(0,0,239,7);
    SetColor(LightRed);
    OutTextXY(0,0,'cras‚ par une voiture!');
	If (ReadKey=#0)Then;
    Dec(Life);
   End;
   2:Begin
    SetColor(Green);
    SetFillStyle(SolidFill,Green);
    Bar(0,0,239,7);
    SetColor(LightRed);
    OutTextXY(0,0,'Manque de temps!');
    If (ReadKey=#0)Then;
    Dec(Life);
   End;
   3:Begin
    SetColor(Green);
    SetFillStyle(SolidFill,Green);
    Bar(0,0,239,7);
    SetColor(LightRed);
    OutTextXY(0,0,'A ‚t‚ tu‚ du billot !');
    If (ReadKey=#0)Then;
    Dec(Life);
   End;
  End;
 Until Life=0;
END.
