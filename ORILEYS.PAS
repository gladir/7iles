{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program ORILEYS;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Var
 Level,Lives,Score,Tresor:LongInt;
 XMan,YMan,XScreen:Byte;
 Board,TmpBoard:Array[0..21,0..160]of Byte;
 XDynamit,YDynamit,TimerDynamit:Array[0..40]of Byte;

Function LongToStr(X:LongInt):String;
Var
 S:String;
Begin
 Str(X,S);
 LongToStr:=S;
End;

Procedure ClrKbd;Begin
 While(Keypressed)do ReadKey;
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

Procedure PutEntity(X,Y:Word;Num:Byte);
Var
 Losange:Array[1..4]of PointType;
Begin
 Case Num of
  0:Begin
   SetColor(Black);
   SetFillStyle(SolidFill,Black);
   Bar(X,Y,X+7,Y+15);
  End;
  1:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
  End;
  2:Begin
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Bar(X,Y,X+7,Y+15);
  End;
  3:Begin
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y,X+7,Y+3);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Bar(X,Y+4,X+7,Y+7);
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y+8,X+7,Y+11);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Bar(X,Y+12,X+7,Y+15);
  End;
  4,7:Begin
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y,X+7,Y+15);
  End;
  5:Begin
   SetColor(LightGray);
   SetFillStyle(SolidFill,Brown);
   Bar(X,Y,X+7,Y+3);
   SetColor(Yellow);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y+4,X+7,Y+7);
   SetColor(LightGray);
   SetFillStyle(SolidFill,Brown);
   Bar(X,Y+8,X+7,Y+11);
   SetColor(Yellow);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y+12,X+7,Y+15);
  End;
  6:Begin
   SetColor(Brown);
   SetFillStyle(SolidFill,Brown);
   Bar(X,Y,X+7,Y+15);
  End;
  $13:Begin { Diamant }
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y,X+7,Y+15);
   SetColor(White);
   SetFillStyle(SolidFill,White);
   Losange[1].X:=X+4;
   Losange[1].Y:=Y;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+8;
   Losange[3].X:=X+4;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X;
   Losange[4].Y:=Y+8;
   FillPoly(4,Losange)
  End;
  $23:Begin { Huile }
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y,X+7,Y+15);
   SetColor(Black);
   OutTextXY(X,Y,#176);
  End;
  $33:Begin { Rubis }
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y,X+7,Y+15);
   SetColor(LightRed);
   SetFillStyle(SolidFill,LightRed);
   Losange[1].X:=X+4;
   Losange[1].Y:=Y;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+8;
   Losange[3].X:=X+4;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X;
   Losange[4].Y:=Y+8;
   FillPoly(4,Losange)
  End;
  $7B:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Losange[1].X:=X+7;
   Losange[1].Y:=Y;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+15;
   Losange[3].X:=X;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X+7;
   Losange[4].Y:=Y;
   FillPoly(4,Losange)
  End;
  $7C:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Losange[1].X:=X;
   Losange[1].Y:=Y;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+15;
   Losange[3].X:=X;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X;
   Losange[4].Y:=Y;
   FillPoly(4,Losange)
  End;
  $7D:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Losange[1].X:=X;
   Losange[1].Y:=Y;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+7;
   Losange[3].X:=X+7;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X;
   Losange[4].Y:=Y+15;
   FillPoly(4,Losange)
  End;
  $7E:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Losange[1].X:=X;
   Losange[1].Y:=Y+8;
   Losange[2].X:=X+7;
   Losange[2].Y:=Y+15;
   Losange[3].X:=X;
   Losange[3].Y:=Y+15;
   Losange[4].X:=X;
   Losange[4].Y:=Y+8;
   FillPoly(4,Losange)
  End;
  $7F:Begin
   SetColor(LightBlue);
   SetFillStyle(SolidFill,LightBlue);
   Bar(X,Y,X+7,Y+15);
   SetColor(White);
   Line(X,Y,X+7,Y);
   Line(X,Y,X,Y+15);
   Line(X+7,Y,X+7,Y+15);
   Line(X+7,Y,X,Y+7);
   Line(X,Y+8,X+7,Y+8);
   Line(X,Y+8,X+7,Y+15);
  End;
  $80:Begin { Homme }
   SetColor(Black);
   SetFillStyle(SolidFill,Black);
   Bar(X,Y,X+7,Y+15);
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X+2,Y+1,X+5,Y+3);
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X,Y+4,X+7,Y+4);
   SetColor(Blue);
   SetFillStyle(SolidFill,Blue);
   Bar(X+2,Y+4,X+5,Y+12);
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X+2,Y+13,X+5,Y+14);
  End;
  $90:Begin { Dynamite }
   SetColor(Black);
   SetFillStyle(SolidFill,Black);
   Bar(X,Y,X+7,Y+15);
   SetColor(LightGray);
   SetFillStyle(SolidFill,LightGray);
   Bar(X+2,Y+1,X+3,Y+2);
   Bar(X+4,Y+3,X+5,Y+4);
   SetColor(Brown);
   SetFillStyle(SolidFill,Brown);
   Bar(X+2,Y+5,X+3,Y+15);
   SetColor(DarkGray);
   SetFillStyle(SolidFill,DarkGray);
   Bar(X+4,Y+5,X+5,Y+15);
  End;
  $A0:Begin { Eau }
   SetColor(Blue);
   SetFillStyle(SolidFill,Blue);
   Bar(X,Y,X+7,Y+15);
  End;
 End;
End;

Procedure HideMan;Begin
 PutEntity(XMan*8,YMan*16,Board[YMan,XMan+XScreen]);
End;

Procedure ShowMan;Begin
 PutEntity(XMan*8,YMan*16,$80);
End;

Procedure RefreshEntity(X,Y:Byte);Begin
 PutEntity(X*8,Y*16,Board[Y,X+XScreen]);
End;

Procedure RefreshBoard;
Var
 I,J:Integer;
Begin
 For J:=0 to 20 do For I:=0 to 79 do Begin
  PutEntity(I*8,J*16,Board[J,I+XScreen]);
 End;
End;

Procedure AddDynamit(X,Y:Byte);
Var
 I:Byte;
Begin
 Board[Y,X]:=$90;
 For I:=0 to 40 do If YDynamit[I]=0 Then Begin
  XDynamit[I]:=X;
  YDynamit[I]:=Y;
  TimerDynamit[I]:=50;
  Break;
 End;
End;

Procedure ShowLives;
Var
 I:Integer;
Begin
 For I:=1 to 10 do Begin
  If(I<=Lives)Then PutEntity(312+I*8,360,$80)
              Else PutEntity(312+I*8,360,0);
 End;
End;

Procedure AddScore(X:Integer);Begin
 SetColor(Black);
 OutTextXY(8,360,'Comptant : $ '+LongToStr(Score));
 Score:=Score+X;
 SetColor(Yellow);
 OutTextXY(8,360,'Comptant : $ '+LongToStr(Score));
End;

Procedure ShowLevel(X:Integer);Begin
 SetColor(Black);
 OutTextXY(320,344,'Niveau : '+LongToStr(Level));
 Level:=Level+X;
 SetColor(Yellow);
 OutTextXY(320,344,'Niveau : '+LongToStr(Level));
End;

Procedure AddTresor;Begin
 Board[10+Random(4),10+Random(150)]:=$13+Random(3)*$10;
 Inc(Tresor);
End;

Procedure InitData;
Var
 I,J:Integer;
Begin
 Tresor:=0;
 XScreen:=40;
 XMan:=40;
 YMan:=5;
 FillChar(Board,SizeOf(Board),0);
 FillChar(XDynamit,SizeOf(XDynamit),0);
 FillChar(YDynamit,SizeOf(YDynamit),0);
 FillChar(TimerDynamit,SizeOf(TimerDynamit),0);
 For J:=0 to 3 do For I:=0 to 159 do Board[J,I]:=1;
 For J:=4 to 8 do For I:=0 to 159 do Board[J,I]:=2;
 For I:=0 to 159 do Board[9,I]:=3;
 For J:=10 to 14 do For I:=0 to 159 do Board[J,I]:=4;
 For I:=0 to 159 do Board[15,I]:=5;
 For J:=16 to 19 do For I:=0 to 159 do Board[J,I]:=6;
 For I:=0 to 159 do Board[20,I]:=7;
 Board[3,72]:=$7B;
 Board[2,73]:=$7B;
 Board[3,73]:=2;
 Board[2,74]:=$7C;
 Board[3,74]:=2;
 Board[2,75]:=$7B;
 Board[3,75]:=2;
 Board[2,76]:=$7C;
 Board[3,76]:=2;
 Board[3,77]:=$7D;
 Board[3,78]:=$7E;
 Board[3,80]:=$7F;
 Board[3,85]:=$7B;
 Board[2,86]:=$7B;
 Board[3,86]:=2;
 Board[2,87]:=$7C;
 Board[3,87]:=2;
 Board[2,88]:=$7B;
 Board[3,88]:=2;
 Board[2,89]:=$7D;
 Board[3,89]:=2;
 Board[2,90]:=$7E;
 Board[3,90]:=2;
 Board[3,91]:=$7C;
 For J:=4 to 18 do Board[J,80]:=0;
 For I:=1 to 10 do AddTresor;
 AddDynamit(80,19);
End;

Procedure InitGame;Begin
 Score:=0;
 Level:=1;
 Lives:=3;
 InitData;
 RefreshBoard;
 AddScore(0);
 ShowLevel(0);
 ShowLives;
 ShowMan;
End;

Procedure ExpandWater;
Var
 I,J:Integer;
Begin
 For J:=4 to 20 do For I:=0 to 159 do Begin
  If Board[J,I]=$A0 Then Begin
   If(I>0)and(Board[J,I-1]=0)Then Begin
    Board[J,I-1]:=$A0;
    If(I>XScreen)Then RefreshEntity(I-1-XScreen,J);
    Break;
   End
    Else
   If(I<159)and(Board[J,I+1]=0)Then Begin
    Board[J,I+1]:=$A0;
    If(I>XScreen)Then RefreshEntity(I+1-XScreen,J);
    Break;
   End
    Else
   If(J<20)and(Board[J+1,I]=0)Then Begin
    Board[J+1,I]:=$A0;
    If(I>XScreen)Then RefreshEntity(I-XScreen,J+1);
    Break;
   End
    Else
   If(J>4)and(Board[J-1,I]=0)Then Begin
    Board[J-1,I]:=$A0;
    If(I>XScreen)Then RefreshEntity(I-XScreen,J-1);
    Break;
   End;
  End;
 End;
End;

Procedure ClearEntity;Begin
 Case Board[YMan,XMan+XScreen] of
  $10..$1F:AddScore(4000);
  $20..$2F:AddScore(1500);
  $30..$3F:AddScore(2500);
 End;
 If Board[YMan,XMan+XScreen]in[$10..$3F]Then Inc(Tresor);
 Board[YMan,XMan+XScreen]:=0;
End;

Procedure PlayGame;
Var
 Terminated,StartWater:Boolean;
 WaterState:Byte;
 I:Byte;
Begin
 StartWater:=False;
 Terminated:=False;
 WaterState:=0;
 Repeat
  Repeat
   If(StartWater)Then Begin
    If WaterState=0 Then ExpandWater;
    WaterState:=(WaterState+1)and 3;
   End;
   For I:=0 to 40 do If YDynamit[I]<>0 Then Begin
    If TimerDynamit[I]>0 Then Begin
     Dec(TimerDynamit[I]);
    End
     Else
    Begin
     If(XDynamit[I]=80)and(YDynamit[I]=19)Then Begin
      StartWater:=True;
      WaterState:=0;
      Board[YDynamit[I],XDynamit[I]]:=$A0;
      RefreshEntity(XDynamit[I]-XScreen,YDynamit[I]);
     End
      Else
     Begin
      Board[YDynamit[I],XScreen+XDynamit[I]]:=0;
      RefreshEntity(XDynamit[I]-XScreen,YDynamit[I]);
     End;
     XDynamit[I]:=0;
     YDynamit[I]:=0;
    End;
   End;
   If Board[YMan,XScreen+XMan]=$A0 Then Begin
    If Lives=1Then Begin
     ClrKbd;
     SetColor(LightRed);
     OutTextXY(300,220,'PARTIE TERMINER !');
     ReadKey;
     Exit;
    End
     Else
    Begin
     ClrKbd;
     Dec(Lives);
     ShowLives;
     SetColor(LightRed);
     OutTextXY(300,220,'Vous avez ‚t‚ noy‚ !');
     ReadKey;
     SetColor(Black);
     OutTextXY(300,220,'Vous avez ‚t‚ noy‚ !');
     SetColor(White);
     InitData;
     RefreshBoard;
    End;
   End;
   Delay(50);
  Until Keypressed;
  Case ReadKey of
   #0:Case ReadKey of
    #72:Begin { Haut }
     If YMan>4 Then Begin
      HideMan;
      YMan:=YMan-1;
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      ShowMan;
     End;
    End;
    #75:Begin { Gauche }
     If XMan>0 Then Begin
      HideMan;
      XMan:=XMan-1;
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      ShowMan;
     End
      Else
     If XScreen>0 Then Begin
      Dec(XScreen);
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      RefreshBoard;
      ShowMan;
     End;
    End;
    #77:Begin { Droite }
     If XMan<79 Then Begin
      HideMan;
      XMan:=XMan+1;
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      ShowMan;
     End
      Else
     If XScreen<79 Then Begin
      Inc(XScreen);
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      RefreshBoard;
      ShowMan;
     End;
    End;
    #80:Begin { Bas }
     If YMan<20 Then Begin
      HideMan;
      YMan:=YMan+1;
      If Board[YMan,XMan+XScreen]<$80 Then ClearEntity;
      ShowMan;
     End;
    End;
   End;
   #27:Terminated:=True;
  End;
  If Tresor<=0 Then Begin
   ClrKbd;
   SetColor(LightGreen);
   OutTextXY(300,220,'Tableau compl‚t‚ !');
   ReadKey;
   Inc(Level);
   InitData;
   RefreshBoard;
  End;
 Until Terminated;
End;

BEGIN
 InitScr;
 InitGame;
 PlayGame;
END.