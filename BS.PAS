{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program BS; { BUBBLE-SHOOTER.PAS }

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 BubbleWidth=20;
 BubbleHeight=20;

Type
 BubbleRec=Record
  X,Y:Integer;
  Color:Byte;
 End;

Var
 Score:LongInt;
 Phi:Integer;
 NumBubble,NumberBubble:Integer;
 CurrColor:Byte;
 BubbleImage:Pointer;
 BubbleArray,LastBubbleArray:Array[1..500]of BubbleRec;

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
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

Procedure AddScore(X:Integer);Begin
 SetColor(Black);
 OutTextXY(0,440,'Pointage : '+LongToStr(Score));
 Score:=Score+X;
 SetColor(Yellow);
 OutTextXY(0,440,'Pointage : '+LongToStr(Score));
End;

Procedure AddBubble(X,Y:Word;Color:Byte);
Var
 I,CurrBubble:Integer;
Begin
 CurrBubble:=0;
 If NumBubble<High(BubbleArray)Then Begin
  Inc(NumBubble);
  CurrBubble:=NumBubble;
 End
  Else
 For I:=1 to High(BubbleArray)do Begin
  If BubbleArray[I].Color=0 Then Begin
   CurrBubble:=I;
   Break;
  End;
 End;
 If CurrBubble=0 Then Exit;
 Inc(NumberBubble);
 BubbleArray[CurrBubble].X:=X;
 BubbleArray[CurrBubble].Y:=Y;
 BubbleArray[CurrBubble].Color:=Color;
 SetColor(White);
 SetFillStyle(SolidFill,Color);
 FillEllipse(X,Y,BubbleWidth,BubbleHeight);
End;

Procedure RefreshBubble;
Var
 I:Integer;
Begin
 For I:=1 to NumBubble do If BubbleArray[I].Color<>0 Then Begin
  SetColor(White);
  SetFillStyle(SolidFill,BubbleArray[I].Color);
  FillEllipse(BubbleArray[I].X,BubbleArray[I].Y,BubbleWidth,BubbleHeight);
 End;
End;

Procedure UnshowPipe;
Var
 Angle:Real;
 X1,Y1,XMove,YMove:Integer;
Begin
 Angle:=(360-Phi)*0.017453292520;
 X1:=Trunc(Cos(Angle)*22);
 Y1:=Trunc(Sin(Angle)*22);
 XMove:=Trunc(Cos(Angle)*60);
 YMove:=Trunc(Sin(Angle)*60);
 SetColor(Black);
 SetLineStyle(SolidLn,0,ThickWidth);
 Line(320+X1,420+Y1,320+XMove,420+YMove);
 SetLineStyle(SolidLn,0,NormWidth);
End;

Procedure ShowPipe;
Var
 Angle:Real;
 X1,Y1,XMove,YMove:Integer;
Begin
 Angle:=(360-Phi)*0.017453292520;
 X1:=Trunc(Cos(Angle)*22);
 Y1:=Trunc(Sin(Angle)*22);
 XMove:=Trunc(Cos(Angle)*60);
 YMove:=Trunc(Sin(Angle)*60);
 SetColor(CurrColor);
 SetLineStyle(SolidLn,0,ThickWidth);
 Line(320+X1,420+Y1,320+XMove,420+YMove);
 SetLineStyle(SolidLn,0,NormWidth);
End;

Procedure ShowCannon;Begin
 SetColor(White);
 SetFillStyle(SolidFill,CurrColor);
 FillEllipse(320,420,20,20);
 ShowPipe;
End;

Function Collision(x1,y1,h1,w1,x2,y2,h2,w2:Integer):Boolean;
Var
 CX1,CX2,CY1,CY2,Dist,R1,R2:Real;
Begin
 CX1:=X1+W1/2.0;
 CY1:=Y1+H1/2.0;
 CX2:=X2+W2/2.0;
 CY2:=Y2+H2/2.0;
 R1:=H1/2.0;
 R2:=H2/2.0;
 Dist:=Sqrt(Sqr(cx2-cx1)+Sqr(cy2-cy1));
 Collision:=Dist<R1+R2;
End;

Function CheckRemoveBubble(X,Y:Integer;Delete:Boolean):Integer;
Var
 I,NX,NY:Integer;
 R:LongInt;
Begin
 CheckRemoveBubble:=0;
 R:=0;
 For I:=1 to NumBubble do Begin
  If BubbleArray[I].Color<>0 Then Begin
   If(CurrColor=BubbleArray[I].Color)and(Collision(X-20,Y-20,46,46,BubbleArray[I].X-20,BubbleArray[I].Y-20,46,46))Then Begin
    Inc(R);
    NX:=BubbleArray[I].X;
    NY:=BubbleArray[I].Y;
    If(Delete)Then Begin
     SetFillStyle(SolidFill,Black);
     Bar(BubbleArray[I].X-20,BubbleArray[I].Y-20,BubbleArray[I].X+20,BubbleArray[I].Y+20);
     AddScore(10);
    End;
    BubbleArray[I].X:=0;
    BubbleArray[I].Y:=0;
    BubbleArray[I].Color:=0;
    Dec(NumberBubble);
    Inc(R,CheckRemoveBubble(NX,NY,Delete));
   End;
  End;
 End;
 CheckRemoveBubble:=R;
End;

Procedure SendBubble;
Var
 Angle:Real;
 J,I,X1,Y1,RX1,RY1:Integer;
Begin
 GetImage(320-BubbleWidth,420-20,320+BubbleWidth,420+20,BubbleImage^);
 Angle:=(360-Phi)*0.017453292520;
 SetFillStyle(SolidFill,Black);
 Bar(320-BubbleWidth,420-20,320+20,420+20);
 For I:=5 to 150 do Begin
  X1:=Trunc(Cos(Angle)*I*5);
  Y1:=Trunc(Sin(Angle)*I*5);
  RX1:=320-BubbleWidth+X1;
  If RX1<0 Then RX1:=0;
  RY1:=420-20+Y1;
  If RY1<0 Then RY1:=0;
  PutImage(RX1,RY1,BubbleImage^,NormalPut);
  If(RX1<=0)or(RY1<=0)or(RX1+40>=640)Then Begin
   AddBubble(RX1+BubbleWidth,RY1+20,CurrColor);
   Break;
  End;
  For J:=1 to NumBubble do Begin
   If BubbleArray[J].Color<>0 Then Begin
    If Collision(RX1,RY1,40,40,BubbleArray[J].X-BubbleWidth,BubbleArray[J].Y-20,40,40)Then Begin
     Move(BubbleArray,LastBubbleArray,SizeOf(LastBubbleArray));
     If CheckRemoveBubble(RX1+BubbleWidth,RY1+20,False)>=2 Then Begin
      Move(LastBubbleArray,BubbleArray,SizeOf(LastBubbleArray));
      CheckRemoveBubble(RX1+BubbleWidth,RY1+20,True);
      SetColor(Black);
      SetFillStyle(SolidFill,Black);
      Bar(RX1,RY1,RX1+40,RY1+40);
      AddScore(10);
      RefreshBubble;
     End
      Else
     Begin
      Move(LastBubbleArray,BubbleArray,SizeOf(LastBubbleArray));
      AddBubble(RX1+BubbleWidth,RY1+20,CurrColor);
     End;
     Exit;
    End;
   End;
  End;
  Delay(50);
  SetColor(Black);
  SetFillStyle(SolidFill,Black);
  Bar(RX1,RY1,RX1+40,RY1+40);
 End;
End;

Procedure InitGame;
Var
 I,J,X:Integer;
Begin
 GetMem(BubbleImage,ImageSize(320-20,420-20,320+20,420+20));
 FillChar(BubbleArray,SizeOf(BubbleArray),0);
 NumBubble:=0;
 NumberBubble:=0;
 Score:=0;
 Phi:=90;
 For J:=1 to 5 do For I:=0 to 15 do Begin
  X:=20*(J and 1);
  If(I*40+X<>0)Then AddBubble(I*40+X,J*40,Random(8)+4);
 End;
 CurrColor:=Random(8)+4;
 ShowCannon;
 AddScore(0);
End;

Procedure Play;
Var
 Ok:Boolean;
 K:Char;
Begin
 Ok:=False;
 Repeat
  K:=ReadKey;
  Case K of
   #0:Case ReadKey of
    #75:Begin { Gauche }
     UnshowPipe;
     If Phi<170 Then Phi:=Phi+1;
     ShowPipe;
    End;
    #77:Begin { Droite }
     UnshowPipe;
     If Phi>10 Then Phi:=Phi-1;
     ShowPipe;
    End;
   End;
   ' ':Begin
    UnshowPipe;
    SendBubble;
    If NumberBubble<0 Then Begin
     SetColor(White);
     SetLineStyle(0,0,0);
     OutTextXY(5,200,'F‚licitations, vous avez gagnez !');
     ReadKey;
     Exit;
    End;
    CurrColor:=Random(8)+4;
    ShowCannon;
   End;
   #27:Begin
    Ok:=True;
   End;
  End;
 Until Ok;
End;

BEGIN
 InitScr;
 InitGame;
 Play;
END.
