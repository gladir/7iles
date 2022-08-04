{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2022
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal)
}

Program MissileCommand;

Uses Crt,DOS;

Type
 {Palette RVB (RGB) }
 RGB=Record
  R:Byte;                       { (R)ouge ((R)ed) }
  G:Byte;                       { (V)ert  ((G)reen) }
  B:Byte;                       { (B)leu  ((B)lue) }
 End;

Const
 LevelMissile:Array[0..5]of Byte=(10,10,20,50,100,200);
 LevelMaxMissile:Array[0..5]of Byte=(2,4,5,6,10,16);

 DefaultRGB:Array[0..15]of RGB=({ Palette RVB par d,faut }
  (R:$00;G:$00;B:$00), { 00h (0): Palette RVB Noir par d,faut }
  (R:$00;G:$00;B:$70), { 01h (1): Palette RVB Bleu par d,faut }
  (R:$00;G:$70;B:$00), { 02h (2): Palette RVB Vert par d,faut }
  (R:$00;G:$70;B:$70), { 03h (3): Palette RVB Cyan par d,faut }
  (R:$70;G:$00;B:$00), { 04h (4): Palette RVB Rouge par d,faut }
  (R:$70;G:$00;B:$70), { 05h (5): Palette RVB Magenta par d,faut }
  (R:$70;G:$48;B:$00), { 06h (6): Palette RVB Brun par d,faut }
  (R:$C4;G:$C4;B:$C4), { 07h (7): Palette RVB Gris clair par d,faut }
  (R:$34;G:$34;B:$34), { 08h (8): Palette RVB Gris fonc, par d,faut }
  (R:$00;G:$00;B:$FF), { 09h (9): Palette RVB Bleu claire par d,faut }
  (R:$24;G:$FC;B:$24), { 0Ah (10): Palette RVB Vert claire par d,faut }
  (R:$00;G:$FC;B:$FC), { 0Bh (11): Palette RVB Cyan claire par d,faut }
  (R:$FC;G:$14;B:$14), { 0Ch (12): Palette RVB Rouge claire par d,faut }
  (R:$B0;G:$00;B:$FC), { 0Dh (13): Palette RVB Magenta claire par d,faut }
  (R:$FC;G:$FC;B:$24), { 0Eh (14): Palette RVB Jaune par d,faut }
  (R:$FF;G:$FF;B:$FF));{ 0Fh (15): Palette RVB blanc par d,faut }

Var
 MI,ML:Array[0..19]of Byte;
 MX1,MX2:Array[0..19]of Word;
 MaxMissile,Missile2Send:Integer;
 Level:Word;
 MouseFound:Boolean;
 Score:LongInt;
 NmCity:Byte;
 CurrColor:Byte;
 OldMouseX,OldMouseY,OldMouseButton:Word;
 BufMouse:Array[0..32*16-1]of Byte;


Function MouseDriverFound:Boolean;
Var
 Regs:Registers;
Begin
 Regs.AX:=0;
 Intr($33,Regs);
 MouseDriverFound:=Regs.AX=$FFFF;
End;

Procedure SetMouseMoveArea(X1,Y1,X2,Y2:Word);Assembler;ASM
 MOV AX,8
 MOV CX,Y1
 MOV DX,Y2
 INT 033h
 MOV AX,7
 MOV CX,X1
 MOV DX,X2
 INT 033h
END;

Procedure GetMouseSwitch(Var X,Y,Button:Word);
Var
 Regs:Registers;
Begin
 Regs.AX:=$0003;
 Intr($33,Regs);
 Button:=Regs.BX;
 X:=Regs.CX;
 Y:=Regs.DX;
End;

Function GetMouseButton:Word;
Var
 X,Y,Button:Word;
Begin
 GetMouseSwitch(X,Y,Button);
 GetMouseButton:=Button;
End;

Procedure WaitMsBut0;Begin
 While GetMouseButton=0 do Begin
 End;
End;

Function CStr(X:LongInt):String;
Var
 S:String;
Begin
 Str(X,S);
 CStr:=S;
End;

Function WordToStr(X:Word):String;
Var
 S:String;
Begin
 Str(X,S);
 WordToStr:=S;
End;

Procedure GetMouseImage(X1,Y1,X2,Y2:Integer);
Var
 P,J:Integer;
Begin
 P:=0;
 For J:=Y1 to Y2 do Begin
  Move(Mem[SegA000:X1+J*320],BufMouse[P],X2-X1+1);
  Inc(P,X2-X1+1);
 End;
End;

Procedure PutMouseImage(X1,Y1,X2,Y2:Integer);
Var
 P,J:Integer;
Begin
 P:=0;
 For J:=Y1 to Y2 do Begin
  Move(BufMouse[P],Mem[SegA000:X1+J*320],X2-X1+1);
  Inc(P,X2-X1+1);
 End;
End;

Procedure SetColor(Color:Byte);Begin
 CurrColor:=Color;
End;

Procedure SetPixel(X,Y:Integer;Color:Byte);Begin
 Mem[SegA000:X+(Y*320)]:=Color;
End;

Function GetPixel(X,Y:Integer):Byte;Begin
 GetPixel:=Mem[SegA000:X+(Y*320)];
End;

Procedure SetPalRGB(Var P;Start,Num:Word);Assembler;ASM
 MOV AL,Byte Ptr Start
 MOV DX,3C8h
 OUT DX,AL
 CLD
 INC DX
 PUSH DS
  LDS SI,P
  MOV AX,Num
  MOV CX,AX
  ADD CX,AX
  ADD CX,AX
@2:
  LODSB
  {$IFOPT G+}
   SHR AL,2
  {$ELSE}
   SHR AL,1
   SHR AL,1
  {$ENDIF}
  OUT DX,AL
  LOOP @2
 POP DS
END;

Procedure PutLnHor(X1,Y,X2,Kr:Integer);
Var
 I:Integer;
Begin
 If(X1>X2)Then Begin
  I:=X1;
  X1:=X2;
  X2:=I;
 End;
 For I:=X1 to X2 do SetPixel(I,Y,Kr);
End;

Procedure PutFillBox(X1,Y1,X2,Y2,Kr:Integer);
Var
 J:Integer;
Begin
 For J:=Y1 to Y2 do PutLnHor(X1,J,X2,Kr);
End;

Procedure _PutFillBox(X1,Y1,X2,Y2:Integer);Begin
 PutFillBox(X1,Y1,X2,Y2,CurrColor);
End;

Procedure PutLn(X1,Y1,X2,Y2,Kr:Integer);
Var
 D,DX,DY,I,J,Ainc,Binc,Ic:Integer;
Begin
 If(Y2=Y1)Then Begin
  PutLnHor(X1,Y1,X2,Kr);
  Exit;
 End;
 If Abs(X2-X1)<Abs(Y2-Y1)Then Begin
  If(Y1>Y2)Then ASM MOV AX,X1;XCHG AX,X2;MOV X1,AX;MOV AX,Y1;XCHG AX,Y2;MOV Y1,AX;END;
  If(X2>X1)Then Ic:=1 Else Ic:=-1;
  DY:=Y2-Y1;DX:=Abs(X2-X1);D:=(DX shl 1)-DY;Ainc:=(DX-DY)shl 1;Binc:=DX shl 1;J:=X1;
  SetPixel(X1,Y1,Kr);
  I:=Y1+1;
  While(I<=Y2)do Begin
   If D>=0Then Begin Inc(J,Ic);Inc(D,Ainc)End else Inc(D,Binc);
   SetPixel(J,I,Kr);
   Inc(I);
  End;
 End
  else
 Begin
  If(X1>X2)Then ASM MOV AX,X1;XCHG AX,X2;MOV X1,AX;MOV AX,Y1;XCHG AX,Y2;MOV Y1,AX;END;
  If(Y2>Y1)Then Ic:=1 else Ic:=-1;
  DX:=X2-X1;DY:=Abs(Y2-Y1);D:=(DY shl 1)-DX;AInc:=(DY-DX)shl 1;BInc:=DY shl 1;J:=Y1;
  SetPixel(X1,Y1,Kr);
  I:=X1+1;
  While(I<=X2)do Begin
   If D>=0Then Begin Inc(J,Ic);Inc(D,Ainc)End else Inc(D,Binc);
   SetPixel(I,J,Kr);
   Inc(I);
  End;
 End;
End;

Function MaxXTxts:Byte;Begin
 MaxXTxts:=39;
End;

Procedure CopT8Bin(X,Y,Matrix,ForegroundColor:Integer);
Var
 I:Byte;
Begin
 For I:=0 to 7 do Begin
  If(Matrix shl I)and 128=128 Then Begin
   SetPixel(X+I,Y,ForegroundColor);
  End;
 End;
End;

Procedure Copy8Bin(X,Y,Matrix,ForegroundColor,BackgroundColor:Integer);
Var
 I:Byte;
Begin
 For I:=0 to 7 do Begin
  If(Matrix shl I)and 128=128 Then Begin
   SetPixel(X+I,Y,ForegroundColor);
  End
   Else
  Begin
   SetPixel(X+I,Y,BackgroundColor);
  End;
 End;
End;

Procedure PutTxtXY(X,Y:Byte;Msg:String;Attr:Byte);
Type
 Font=Array[0..2047]of Byte;
 PFont=^Font;
Var
 Intr:Array[0..255]of PFont Absolute $0000:$0000;
 I,J:Byte;
Begin
 For J:=1 to Length(Msg)do For I:=0 to 7 do Begin
  Copy8Bin((X+J-1)*8,Y*8+I,Intr[$43]^[Byte(Msg[J])*8+I],Attr and $F,Attr shr 4);
 End;
End;

Procedure BarSpcHor(X1,Y,X2,Attr:Byte);Begin
 PutFillBox(X1*8,Y*8,X2*8+7,Y*8+7,Attr shr 4);
End;

Procedure WaitRetrace;Begin
 Delay(1000 div 60);
End;

Function Canon(I:Byte):Byte;
Var
 S:String;
Begin
 S:=Chr(20*8-3)+Chr(20*8-5)+Chr(20*8-6)+Chr(20*8-7)+Chr(20*8-7)+Chr(20*8-8)+
    Chr(20*8-8)+Chr(20*8-8)+Chr(20*8-8)+Chr(20*8-8)+Chr(20*8-8)+Chr(20*8-7)+
    Chr(20*8-7)+Chr(20*8-6)+Chr(20*8-5)+Chr(20*8-3);
 Canon:=Byte(S[I+1]);
End;

Function XCity(I:Byte):Word;
Var
 S:String;
Begin
 S:=#5#10#15#23#28#33;
 XCity:=Byte(S[I+1])shl 3;
End;

Procedure PtrMs;Assembler;ASM
 DB 11111111b,00000000b,00000000b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 01111111b,11111111b,11111111b,11111110b
 DB 01111111b,11111111b,11111111b,11111110b
 DB 01111111b,11111111b,11111111b,11111110b
 DB 01111111b,11111111b,11111111b,11111110b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,11111111b,11111111b,11111111b
 DB 11111111b,00000000b,00000000b,11111111b

 DB 00000000b,01111100b,00111110b,00000000b
 DB 00000011b,10000000b,00000001b,11000000b
 DB 00001100b,00000000b,00000000b,00110000b
 DB 00110000b,00000000b,00000000b,00001100b
 DB 01000000b,00000000b,00000000b,00000010b
 DB 10000000b,00000001b,10000000b,00000001b
 DB 10000000b,00000001b,10000000b,00000001b
 DB 00000000b,00000111b,11100000b,00000000b
 DB 00000000b,00000111b,11100000b,00000000b
 DB 10000000b,00000001b,10000000b,00000001b
 DB 10000000b,00000001b,10000000b,00000001b
 DB 01000000b,00000000b,00000000b,00000010b
 DB 00110000b,00000000b,00000000b,00001100b
 DB 00001100b,00000000b,00000000b,00110000b
 DB 00000011b,10000000b,00000001b,11000000b
 DB 00000000b,01111100b,00111110b,00000000b
END;

Procedure HideMousePtr;Begin
 PutMouseImage(OldMouseX,OldMouseY,OldMouseX+31,OldMouseY+15);
End;

Procedure ShowMousePtr;
Type
 TPtrMs=Array[0..1,0..15,0..3]of Byte;
Var
 I,J:Integer;
 MousePtr:^TPtrMs;
Begin
 GetMouseImage(OldMouseX,OldMouseY,OldMouseX+31,OldMouseY+15);
 MousePtr:=@PtrMs;
 For J:=0 to 15 do For I:=0 to 3 do Begin
  CopT8Bin(OldMouseX+I*8,OldMouseY+J,MousePtr^[1,J,I],$F);
 End;
End;

Procedure _BackKbd;
Var
 X,Y,Button:Word;
Begin
 GetMouseSwitch(X,Y,Button);
 If(X<>OldMouseX)or(Y<>OldMouseY)Then Begin
  HideMousePtr;
  OldMouseX:=X;
  OldMouseY:=Y;
  ShowMousePtr;
 End;
End;

Function PutMissile(X1,Y1,X2,Y2,Limit,Kr:Integer;Var XOut,YOut:Integer):Byte;
Var
 D,DX,DY,I,J,Ainc,Binc,Ic,OK:Integer;
Begin
 PutMissile:=0;
 If Abs(X2-X1)<Abs(Y2-Y1)Then Begin
  If(Y1>Y2)Then ASM
   MOV AX,X1;
   XCHG AX,X2;
   MOV X1,AX;
   MOV AX,Y1;
   XCHG AX,Y2;
   MOV Y1,AX;
  END;
  If(X2>X1)Then Ic:=1 Else Ic:=-1;
  DY:=Y2-Y1;DX:=Abs(X2-X1);D:=(DX shl 1)-DY;Ainc:=(DX-DY)shl 1;Binc:=DX shl 1;J:=X1;
  SetPixel(X1,Y1,Kr);
  I:=Y1+1;
  While(I<=Y2)do Begin
   If D>=0Then Begin Inc(J,Ic);Inc(D,Ainc)End else Inc(D,Binc);
   OK:=GetPixel(J,I);
   If OK in[1,2,3]Then Begin XOut:=J;PutMissile:=OK;Exit;End;
   SetPixel(J,I,Kr);
   If(I>Limit)Then Begin XOut:=J;YOut:=I;Exit;End;
   Inc(I);
  End;
 End
  else
 Begin
{  If(X1>X2)Then ASM MOV AX,X1;XCHG AX,X2;MOV X1,AX;MOV AX,Y1;XCHG AX,Y2;MOV Y1,AX;END;}
  If(Y2>Y1)Then Ic:=1 else Ic:=-1;
  DX:=Abs(X2-X1);DY:=Abs(Y2-Y1);D:=(DY shl 1)-DX;AInc:=(DY-DX)shl 1;BInc:=DY shl 1;J:=Y1;
  SetPixel(X1,Y1,Kr);
  If(X1>X2)Then Begin
   I:=X1;
   While(I>=X2)do Begin
    If D>=0Then Begin Inc(J);Inc(D,Ainc)End else Inc(D,Binc);
    OK:=GetPixel(I,J);
    If OK in[1,2,3]Then Begin XOut:=I;PutMissile:=OK;Exit;End;
    SetPixel(I,J,Kr);
    If(J>Limit)Then Begin XOut:=I;YOut:=J;Exit;End;
    Dec(I);
   End;
  End
   Else
  Begin
   I:=X1+1;
   While(I<=X2)do Begin
    If D>=0Then Begin J:=J+Ic;Inc(D,Ainc)End else Inc(D,Binc);
    OK:=GetPixel(I,J);
    If OK in[1,2,3]Then Begin XOut:=I;PutMissile:=OK;Exit;End;
    SetPixel(I,J,Kr);
    If(J>Limit)Then Begin XOut:=I;YOut:=J;Exit;End;
    Inc(I);
   End;
  End;
 End;
End;

Function EY(I:Byte):Byte;Near;
Var
 S:String;
Begin
 S:=#0#0#0#0#6#6#2#2#4#4#4#1#5#0#0#0#4#4#2#2#4#0#1;
 EY:=Byte(S[I+1]);
End;

Procedure _PutCity(X:Word);
Var
 I:Byte;
Begin
 For I:=0to 22do PutLn(X+I,20*8+EY(I),X+I,22*8-1,CurrColor)
End;

Procedure PutCity(X:Word);Begin
 SetColor(3);
 _PutCity(X)
End;

Procedure EraseCity(X:Word);
Var
 I:Byte;
Begin
 For I:=0to 5do If(X>=XCity(I))and(X<=XCity(I)+22)Then Break;
 SetColor(0);
 _PutCity(XCity(I));
 For I:=0to 2do Begin
  SetPalRGB(DefaultRGB[15],0,1);WaitRetrace;
  SetPalRGB(DefaultRGB[0],0,1);WaitRetrace
 End;
End;

Procedure InitScr;
Var
 J:Byte;
Begin
 SetColor(1);
 PutFillBox(0,22*8,319,191,1);
 _PutFillBox(0,19*8,15,22*8-1);
 _PutFillBox(38*8,19*8,319,22*8-1);
 For J:=0to 15do PutLn(20*8-4+J,Canon(J),20*8-4+J,20*8-1,2);
 _PutFillBox(19*8,20*8,22*8-1,22*8-1);
 For J:=0to 5do PutCity(XCity(J));
 BarSpcHor(0,24,MaxXTxts,$B0);
 PutTxtXY(1,24,'Pointage:',$B0);
 FillChar(BufMouse,SizeOf(BufMouse),0);
 SetPalRGB(DefaultRGB,0,16);
 SetMouseMoveArea(0,0,319-32,19*8-1);
 GetMouseSwitch(OldMouseX,OldMouseY,OldMouseButton);
End;

Procedure MakeNewMissile(I:Byte);Begin
 MI[I]:=0;ML[I]:=1+Random(Level);
 MX1[I]:=Random(318);MX2[I]:=Random(38*8-34)+16;
End;

Procedure UpDateScore;Begin
 PutTxtXY(11,24,CStr(Score),$B0)
End;

Procedure Play;
Label
 C,Chk,BreakAll;
Var
 Out:Byte;
 XOut,T,YOut:Integer;
 X,Y,B:Word;
 I,J,KM:Integer;
Begin
 FillChar(MI,SizeOf(MI),0);
 FillChar(MX1,SizeOf(MX1),0);
 FillChar(MX2,SizeOf(MX2),0);
 Level:=0;Score:=0;NmCity:=6;
 Repeat
  If Level>5Then I:=5 Else I:=Level;
  MaxMissile:=LevelMaxMissile[I];Missile2Send:=LevelMissile[I];KM:=0;
  PutTxtXY(25,24,'Niveau: '+WordToStr(Level+1),$B0);
  UpDateScore;
  For I:=0to(MaxMissile)do MakeNewMissile(I);
  ShowMousePtr;
  Repeat
   _BackKbd;
   I:=0;
   If(KeyPressed)Then Begin
    ReadKey;
    Exit;
   End;
 C:While(I<=MaxMissile)do Begin
    Out:=PutMissile(MX1[I],0,MX2[I],22*8-1,MI[I],15,XOut,YOut);
    If(Out>0)or(MI[I]>=22*8-1)Then Begin
     {__HideMousePtr;}
     PutMissile(MX1[I],0,MX2[I],22*8-1,MI[I],0,T,T);
     If Out=3Then Begin
      Dec(NmCity);
      EraseCity(XOut);
      If NmCity=0Then Begin
       PutTxtXY(20,11,'TOUTES LES CIT?S SONT D?TRUITES,',$C);
       PutTxtXY(20,13,'PARTIE TERMINER!',$C);
       ReadKey;
       Exit;
      End;
     End;
     ShowMousePtr;
     Goto Chk;
    End
     Else
    Begin
     WaitRetrace;
     If Level<4Then WaitRetrace;
     GetMouseSwitch(X,Y,B);
     If B>0Then Begin
      If(X<=XOut)and(X+31>=XOut)and(Y<=YOut)and(Y+15>=YOut)Then Begin
       Inc(KM);
       HideMousePtr;
       PutMissile(MX1[I],0,MX2[I],22*8-1,MI[I],0,T,T);
       ShowMousePtr;
       Inc(Score,100);
       UpDateScore;
   Chk:If Missile2Send>0Then Begin
        MakeNewMissile(I);
        Dec(Missile2Send);
       End
        Else
       If MaxMissile>0Then Begin
        Repeat
         If(I=MaxMissile)or(MaxMissile=0)Then Break;
         For J:=I to MaxMissile-1do Begin
          MI[J]:=MI[J+1];ML[J]:=ML[J+1];MX1[J]:=MX1[J+1];MX2[J]:=MX2[J+1]
         End;
        Until True;
        Dec(MaxMissile);I:=0;
        Goto C;
       End
        Else
       Goto BreakAll;
      End;
     End;
     Inc(MI[I],ML[I]);
    End;
    Inc(I);
   End;
  Until False;
BreakAll:
  HideMousePtr;
  If KM>0Then For I:=0to(15*NmCity)do Begin
   WaitRetrace;
   WaitRetrace;
   Inc(Score,5);
   UpDateScore;
  End;
  Inc(Level);
  PutTxtXY(20,12,'PRES POUR LE NIVEAU '+WordToStr(Level+1)+'!',$B);
  Repeat
   If GetMouseButton>0Then Break;
  Until KeyPressed;
  If GetMouseButton=0Then ReadKey Else WaitMsBut0;
  PutFillBox(0,0,319,19*8-1,0);
 Until False;
End;

BEGIN
 Randomize;
 ASM
  MOV AX,0013h
  INT 10h
 END;
 MouseFound:=MouseDriverFound;
 If Not MouseFound Then Begin
  WriteLn('Une souris est requise pour jouer a ce jeu');
 End
  Else
 Begin
  InitScr;
  Play;
 End;
 TextMode(CO80);
END.