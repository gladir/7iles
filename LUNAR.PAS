{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program LUNAR;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 KrExplos:Array[0..3]of Byte=(8,$C,$E,7);
 DrawS:Integer=4;
 XL:Integer=160;
 YL:Integer=100;

Var
 Finish,PlayNow:Boolean;
 K:Char;
 Bac,Cur:Array[0..200]of Byte;
 I:Integer;
 N:String;
 Mode:(_None_,_NoTrace_,_UnMove_);
 a,b:Integer;
 xc,yc:(NoMove,Add,Sub);

Procedure ClrKbd;Begin
 While(Keypressed)do ReadKey;
End;

Function Dupl(C:String;Num:LongInt):String;
Var
 I:LongInt;
 S:String;
Begin
 S:='';
 For I:=1 to Num do S:=S+C;
 Dupl:=S;
End;

Function IntToStr(V:Integer):String;
Var
 S:String;
Begin
 Str(V,S);
 IntToStr:=S;
End;

Function IntToStrDef(V:Integer;Num:Byte):String;
Var
 S:String;
Begin
 Str(V:Num,S);
 IntToStrDef:=S;
End;

Function TrimL(S:String):String;
Var
 I:Byte;
Begin
 For I:=1to Length(S)do Begin
  If S[I]<>' 'Then Begin
   TrimL:=Copy(S,I,255);
   Exit;
  End;
 End;
 TrimL:=S;
End;

Function RealToStrDef(R:Real;Num1,Num2:Byte):String;
Var
 S:String;
Begin
 Str(R:Num1:Num2,S);
 RealToStrDef:=S;
End;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
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
' ',';':;{C'est 2 caractres ne change rien en soit, donc...pas d'arrˆt!}
   Else Exit;
  End
 End
End;

Procedure InitVideo;
Var
 Driver,Mode:Integer;
 ErrCode:Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGALo;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGALo;
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

Procedure Paint(X,Y,Kr:Word);
Var
 I,J:Word;
Begin
 For I:=0to 319do For J:=189downto 0do If(GetPixel(I,J)<>Kr)Then PutPixel(I,J,15)Else Break;
End;

Procedure InitScr;
Var
 I:Byte;
Begin
 ClearDevice;
 SetViewPort(160,0,160+320-1,200-1,True);
 GetImage(0,0,8,8,Bac);
 For I:=1to 25do PutPixel(Random(319),Random(150),9);
 SetColor(15);
 Line(3,7,0,8);
 Line(5,7,8,8);
 Circle(4,4,4);
 SetColor(7);
 Rectangle(3,3,5,5);
 SetColor(15);
 GetImage(0,0,8,8,Cur);
 Draw('BM0,165M+10,+15R10M+10,-7R2F10E2M+10,+5R18M+5,+2E6M+5,-2M+5,-2F6M+5,'+
      '-2R15M+4,+3R3E1R5R1E3M+4,-3R35E3R6R15M+6,+2R6F3R20M+14,+3F3R14E3M+14,'+
      '-10R10E10M+10,-5M319,165');
 Line(0,190,319,190);
 Paint(188,188,15);
 SetColor(2);
 Bar(0*8,24*8,39*8+7,24*8+7);
 Draw('C0BM43,183F5BM98,184G6BM292,173F10R15');
 SetColor(14);
 Line(155,170,155,178);
 Line(165,170,165,178);
 SetColor(2);
 OutTextXY(13*8,24*8,'Temps:');
 OutTextXY(25*8,24*8,'Carburant: 50');
End;

Procedure Play;
Var
 PX,PY,AX,AY,VX,VY,CX,CY,Gravity,Time,Tinc,A:Real;
 AS,AW,Fuel,X,Y,D:Integer;
 Q,W,PR,PS:Array[0..20]of Real;
Begin
 FillChar(Q,SizeOf(Q),0);
 FillChar(W,SizeOf(W),0);
 FillChar(PR,SizeOf(PR),0);
 FillChar(PS,SizeOf(PS),0);
 VX:=0.0;VY:=0.0;Time:=0.0;CX:=4.0;CY:=4.0;AS:=0;AW:=0;AX:=0.0;AY:=0.0;
 Fuel:=50;Gravity:=0.2;Tinc:=0.3;
 ClrKbd;
 While(AS<15)and(AW<15)do Begin
  Time:=Time+Tinc;
  PX:=CX;PY:=CY;CX:=CX+VX;CY:=CY+VY;VX:=VX+AX;VY:=VY+AY+Gravity*Tinc;
  SetColor($F);
  OutTextXY(0*8,24*8,Dupl(#219,5));
  SetColor(8);
  OutTextXY(0*8,24*8,RealToStrDef(VY,2,2));
  SetColor($F);
  OutTextXY(20*8,24*8,Dupl(#219,3));
  SetColor(9);
  OutTextXY(20*8,24*8,TrimL(RealToStrDef(Time,3,0)));
  AX:=0.0;AY:=0.0;VX:=VX-VX*0.05*Tinc;
  If CX<4.0Then Begin
   CX:=4.0;
   VX:=-VX;
  End
   Else
  If CX>315Then Begin
   CX:=315.0;
   VX:=-VX;
  End;
  If CY<4.0Then Begin
   CY:=4.0;
   VY:=-VY/2;
  End
   Else
  If CY>185Then CY:=185.0;
  PutImage(Trunc(PX)-4,Trunc(PY)-4,Bac,NormalPut);
  GetImage(Trunc(CX)-4,Trunc(CY)-4,Trunc(CX)-4+8,Trunc(CY)-4+8,Bac);
  PutImage(Trunc(CX)-4,Trunc(CY)-4,Cur,NormalPut);
  Delay(100);
  While(KeyPressed)do Begin
   Fuel:=Trunc(Fuel-1.0*Tinc);
   SetColor($F);
   OutTextXY(36*8,24*8,Dupl(#219,2));
   SetColor(1);
   OutTextXY(36*8,24*8,IntToStrDef(Fuel,2));
   If Fuel<=0Then Begin
    {If Fuel<=0Then Begin
     Sound(150);
     Delay(Trunc(3*18.2)):
    End;}
    Break;
   End;
{   If Fuel<5 Then Begin
    Sound(1100);
    Delay(Trunc(1*18.2));
    Sound(1400);
    Delay(Trunc(2*18.2));
   End;}
   Case ReadKey of
    #0:Case ReadKey of
     #72:AY:=AY-1.0*Tinc;
     #80:AY:=AY+1.0*Tinc;
     #75:AX:=AX-1.0*Tinc;
     #77:AX:=AX+1.0*Tinc;
    End;
    #27:Exit;
   End;
  End;
  AS:=GetPixel(Trunc(CX)-4,Trunc(CY)+5);AW:=GetPixel(Trunc(CX)+4,Trunc(CY)+5);
 End;
 If(VY<=1.0)and(CX<=170.0)and(CX>=150.0)Then Begin
  SetColor(0);
  OutTextXY(12*8,6*8,Dupl(#219,15));
  SetColor(15);
  OutTextXY(12*8,6*8,'Pointage: '+IntToStr(Trunc(500000/Time)));
 End
  Else
 Begin
  If(CX>170.0)or(CX<150.0)Then Begin
   SetColor($C);
   OutTextXY(16*8,6*8,'Manquer!!');
  End;
  If VY>2Then Begin
   SetColor($C);
   OutTextXY(16*8,8*8,'KAA BOOM!!!');
  End
   Else
  If VY>1Then Begin
   SetColor($C);
   OutTextXY(16*8,8*8,'BOOM!!!');
  End;
  PutImage(Trunc(CX)-4,Trunc(CY)-4,Bac,NormalPut);
  For Y:=1to 20do Begin A:=Random(314)/100;D:=Random(4);Q[Y]:=Sin(A)*D;W[Y]:=Cos(A)*D;End;
  For X:=1to 10do For Y:=1 to 20do Begin
   PR[Y]:=PR[Y]+W[Y];PS[Y]:=PS[Y]+Q[Y];
   SetColor(KrExplos[Y and 3]);
   Line(Trunc(CX),Trunc(CY)+4,Trunc(CX+PR[Y]),Trunc(CY-PS[Y]));
  End;
 End;
End;

Function YesNo(Msg:String):Boolean;Begin
 SetColor($C);
 OutTextXY(40,95,Msg);
 YesNo:=UpCase(ReadKey)='O';
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 Finish:=False;
 PlayNow:=False;
 If(StrToUpper(ParamStr(1))='/PLAY')Then PlayNow:=True;
 Repeat
  If(PlayNow)Then Begin
   K:='2';
  End
   Else
  Begin
   TextMode(C80);
   ClrScr;
   TextColor(LightBlue);
   WriteLn('  ת     ת      תתתת    ת  תתתתת תתתתתת  ');
   WriteLn('  ת     ת      תת  ת   ת  ת   תתת    תת ');
   WriteLn('  ת     ת      תת   ת  ת  ת    תת     ת ');
   WriteLn('  ת     ת      תת    ת ת  ת    תת     ת ');
   WriteLn(' תת     ת     תתת     תת תת    תתת    תת');
   WriteLn('תתת     ת    תתתת      תתתתתתתתתתתתתתתתת');
   WriteLn('תתת     ת    תתתת      תתתת    תתתת   תת');
   WriteLn('תתת     ת    תתתת  תת  תתתת    תתתת   תת');
   WriteLn('תתת     תת   תתתת  תת  תתתת    תתתת   תת');
   WriteLn('תתתתתתתת תתתתתתתת  תת  תתתת    תתתת   תת');
   TextColor(White);
   WriteLn(' ':12,'  ת       תתתתת תתת    תתתתתתתת תתתתתתתתתתתתתת  ');
   WriteLn(' ':12,'  ת       ת   תתת  ת   תתתת   תתת       ת    תת ');
   WriteLn(' ':12,'  ת       ת    תת   ת  תתתת    תת       ת     ת ');
   WriteLn(' ':12,'  ת       ת    תת    ת תתתת    תת       ת     ת ');
   WriteLn(' ':12,' תת      תת    תת     תתתתת    תתת      תת    תת');
   WriteLn(' ':12,'תתת     תתתתתתתתת      תתתת    תתתתתתת  תתתתתתתת');
   WriteLn(' ':12,'תתת     תתת    תת      תתתת    תתתת     תתת   תת');
   WriteLn(' ':12,'תתת     תתת    תת  תת  תתתת    תתתת     תתת   תת');
   WriteLn(' ':12,'תתתתתתתתתתת    תת  תת  תתתתתתתתתתתתתתתתתתתת   תת');
   TextColor(7);
   WriteLn(' ':30,Dupl(#254,24));
   WriteLn(' ':30,'1 - Instructions');
   WriteLn(' ':30,'2 - Jouer … Lunar Lander');
   WriteLn(' ':30,'3 - Quitter');
   WriteLn(' ':30,Dupl(#254,24));
   Write('Entrez votre choix : ');
   K:=UpCase(ReadKey);
   If K=#0 Then ReadKey;
   WriteLn(K);
  End;
  Case K of
   '1':Begin
      { Instruction }
     ClrScr;
     TextColor(White);
     WriteLn(' ':30,'Lunar Lander');
     WriteLn;
     TextColor(7);
     WriteLn('La synopsie du jeu est la suivante : ®Vous ˆtes le commandant');
     WriteLn;
     WriteLn('de l''USS COLUMBIA et vous devez le faire atterrir : en toute');
     WriteLn;
     WriteLn('s‚curit‚ sur la lune.¯');
     WriteLn;
     WriteLn;
     WriteLn('Vous pouvez contr“ler votre vaisseau en utilisant la touche');
     WriteLn;
     TextBackground(7);TextColor(0);
     Write(' ',#27,' ');
     TextBackground(0);TextColor(7);
     Write(' pour d‚placer … gauche et utiliser la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#26,' ');
     TextBackground(0);TextColor(7);
     WriteLn(' pour aller');
     WriteLn;
     Write('… droite, la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#24,' ');
     TextBackground(0);TextColor(7);
     Write(' pour monter et la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#25,' ');
     TextBackground(0);TextColor(7);
     WriteLn(' pour');
     WriteLn;
     WriteLn('descendre.');
     WriteLn;
     WriteLn;
     Write('Presse une touche pour continuer...');
     If ReadKey=#0 Then ReadKey;
   End;
   '2','P':Begin
    Randomize;
    InitVideo;
    Repeat
     InitScr;
     Play;
     ClrKbd;
    Until Not YesNo('Une nouvelle partie (O/N) ?');
    Finish:=True;
   End;
   '3','Q',#27:Finish:=True;
  End;
 Until Finish;
 TextMode(C80);
 ClrScr;
END.
