{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program MATCHING;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Var
 NumberCard:Integer;
 CardValue:Array[1..16]of Byte;
Function Left(Const Str:String;Num:Byte):String;Begin
 Left:=Copy(Str,1,Num);
End;

Procedure DelChrAt(Var S:String;P:Byte);Begin
 If P=1Then S:=Copy(S,2,255)
       Else S:=Left(S,P-1)+Copy(S,P+1,255)
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

Procedure PutCard(X,Y,Num:Word);
Const
 CardWidth=50;
 CardHeight=80;
Var
 TailleAngle:Real;
 I,J:Integer;
 XMove,YMove:Integer;
 Rayon,XCenter,YCenter:Word;
 Triangle:Array[1..3]of PointType;
 Pentagone:Array[1..5]of PointType;
 Hexagone:Array[1..6]of PointType;
 Heptagone:Array[1..7]of PointType;
 Octogone:Array[1..8]of PointType;
Begin
 SetColor(White);
 Rectangle(X,Y,X+CardWidth-1,Y+CardHeight-1);
 XCenter:=X+(CardWidth shr 1);
 YCenter:=Y+(CardHeight shr 1);
 Case Num of
  $80:Begin
   SetFillStyle(SolidFill,White);
   Bar(X,Y,X+CardWidth-1,Y+CardHeight-1);
   Exit;
  End;
  $FF:Begin
   SetFillStyle(SolidFill,Black);
   Bar(X,Y,X+CardWidth-1,Y+CardHeight-1);
   Exit;
  End;
 End;
 If Num>0 Then Begin
  SetFillStyle(SolidFill,White);
  Bar(X+3,Y+3,X+CardWidth-3,Y+CardHeight-3);
 End;
 Case Num of
  0:Begin { Dos de la carte }
   SetFillStyle(XHatchFill,Blue);
   Bar(X+3,Y+3,X+CardWidth-3,Y+CardHeight-3);
  End;
  1:Begin { Cercle }
   SetFillStyle(SolidFill,Green);
   FillEllipse(XCenter,YCenter,15,15);
  End;
  2:Begin { Ligne }
   SetFillStyle(SolidFill,Magenta);
   Bar(XCenter-15,YCenter-15,XCenter-5,YCenter+15);
   Bar(XCenter+5,YCenter-15,XCenter+15,YCenter+15);
  End;
  3:Begin { Triangle }
   SetFillStyle(SolidFill,Cyan);
   Triangle[1].X:=XCenter;
   Triangle[1].Y:=YCenter-15;
   Triangle[2].X:=XCenter-15;
   Triangle[2].Y:=YCenter+15;
   Triangle[3].X:=XCenter+15;
   Triangle[3].Y:=YCenter+15;
   FillPoly(3,Triangle);
  End;
  4:Begin { Carr‚ }
   SetFillStyle(SolidFill,Yellow);
   Bar(XCenter-15,YCenter-15,XCenter+15,YCenter+15);
  End;
  5:Begin { Pentagone }
   TailleAngle:=(360/5)*0.017453292520;
   For J:=1 to 5 do Begin
    Rayon:=J*4;
    For I:=1 to 5 do Begin
     XMove:=Trunc(Cos(TailleAngle*I)*Rayon);
     YMove:=Trunc(Sin(TailleAngle*I)*Rayon);
     Pentagone[I].X:=XCenter+XMove;
     Pentagone[I].Y:=YCenter+YMove;
    End;
    SetFillStyle(SolidFill,Brown);
    FillPoly(5,Pentagone);
   End;
  End;
  6:Begin { Hexagone }
   TailleAngle:=(360/6)*0.017453292520;
   For J:=1 to 6 do Begin
    Rayon:=J*3;
    For I:=1 to 6 do Begin
     XMove:=Trunc(Cos(TailleAngle*I)*Rayon);
     YMove:=Trunc(Sin(TailleAngle*I)*Rayon);
     Hexagone[I].X:=XCenter+XMove;
     Hexagone[I].Y:=YCenter+YMove;
    End;
    SetFillStyle(SolidFill,Blue);
    FillPoly(6,Hexagone);
   End;
  End;
  7:Begin { Heptagone }
   TailleAngle:=(360/7)*0.017453292520;
   For J:=1 to 7 do Begin
    Rayon:=J*3;
    For I:=1 to 7 do Begin
     XMove:=Trunc(Cos(TailleAngle*I)*Rayon);
     YMove:=Trunc(Sin(TailleAngle*I)*Rayon);
     Heptagone[I].X:=XCenter+XMove;
     Heptagone[I].Y:=YCenter+YMove;
    End;
    SetFillStyle(SolidFill,LightGreen);
    FillPoly(7,Heptagone);
   End;
  End;
  8:Begin { Octogone }
   Octogone[1].X:=XCenter-5;
   Octogone[1].Y:=YCenter-15;
   Octogone[2].X:=XCenter-15;
   Octogone[2].Y:=YCenter-5;
   Octogone[3].X:=XCenter-15;
   Octogone[3].Y:=YCenter+5;
   Octogone[4].X:=XCenter-5;
   Octogone[4].Y:=YCenter+15;
   Octogone[5].X:=XCenter+5;
   Octogone[5].Y:=YCenter+15;
   Octogone[6].X:=XCenter+15;
   Octogone[6].Y:=YCenter+5;
   Octogone[7].X:=XCenter+15;
   Octogone[7].Y:=YCenter-5;
   Octogone[8].X:=XCenter+5;
   Octogone[8].Y:=YCenter-15;
   SetFillStyle(SolidFill,LightGray);
   FillPoly(8,Octogone);
  End;
 End;
End;

Procedure AnonymousCard(Pos:Word);
Var
 I,J:Byte;
Begin
 I:=(Pos-1) and 3;
 J:=(Pos-1) shr 2;
 PutCard(I*100,J*100+16,0);
End;

Procedure HideCard(Pos:Word);
Var
 I,J:Byte;
Begin
 I:=(Pos-1) and 3;
 J:=(Pos-1) shr 2;
 PutCard(I*100,J*100+16,$FF);
End;

Procedure ShowCard(Pos:Word);
Var
 I,J:Byte;
Begin
 I:=(Pos-1) and 3;
 J:=(Pos-1) shr 2;
 PutCard(I*100,J*100+16,CardValue[(I+J*4)+1]);
End;

Procedure FlashCard(Pos:Word);
Var
 I,J:Byte;
Begin
 I:=(Pos-1) and 3;
 J:=(Pos-1) shr 2;
 PutCard(I*100,J*100+16,$80);
End;

Procedure InitBoard;
Var
 I,J:Byte;
 C:Char;
Begin
 C:='A';
 For J:=0 to 3 do For I:=0 to 3 do Begin
  PutCard(I*100,J*100+16,0);
  OutTextXY(I*100+20,J*100+82+16,C);
  C:=Succ(C);
 End;
End;

Procedure InitGame;
Var
 I,Pos:Integer;
 S:String;
Begin
 Randomize;
 FillChar(S,SizeOf(S),#0);
 FillChar(CardValue,SizeOf(CardValue),0);
 S[0]:=#16;
 For I:=1 to 8 do Begin
  S[I]:=Chr(I);
  S[I+8]:=Chr(I);
 End;
 NumberCard:=16;
 For I:=1 to 16 do Begin
  Pos:=1+Random(Length(S));
  CardValue[I]:=Byte(S[Pos]);
  DelChrAt(S,Pos);
 End;
 OutTextXY(50,0,'Jeu de m‚moire par paires (Matching Pairs Memory Game)');
End;

Procedure PlayGame;
Var
 Terminated:Boolean;
 K:Char;
 Choice1,Choice2:Byte;
 I:Integer;
Begin
 Terminated:=False;
 Choice1:=0;
 Choice2:=0;
 Repeat
  K:=UpCase(ReadKey);
  Case K of
   'A'..'P':Begin
    If Choice1=0 Then Begin
     Choice1:=Ord(K)-Ord('@');
     If CardValue[Choice1]<>0 Then ShowCard(Choice1)
                              Else Choice1:=0;
    End
     Else
    Begin
     Choice2:=Ord(K)-Ord('@');
     If Choice1=Choice2 Then Begin
      Choice2:=0;
     End
      Else
     If CardValue[Choice2]=0 Then Begin
      Choice2:=0;
     End
      Else
     Begin
      ShowCard(Choice2);
      If CardValue[Choice1]=CardValue[Choice2]Then Begin
       For I:=1 to 5 do Begin
        FlashCard(Choice1);
        FlashCard(Choice2);
        Delay(100);
        ShowCard(Choice1);
        ShowCard(Choice2);
        Delay(100);
       End;
       CardValue[Choice1]:=0;
       CardValue[Choice2]:=0;
       Dec(NumberCard,2);
       HideCard(Choice1);
       HideCard(Choice2);
       If NumberCard<=0 Then Begin
        ClearDevice;
        SetColor(White);
        SetLineStyle(0,0,0);
        OutTextXY(5,200,'F‚licitations, vous avez gagnez !');
        ReadKey;
        Terminated:=True;
        End;
       End
       Else
      Begin
       Delay(1000);
       AnonymousCard(Choice1);
       AnonymousCard(Choice2);
      End;
      Choice1:=0;
      Choice2:=0;
     End;
    End;
   End;
   #27:Terminated:=True;
  End;
 Until Terminated;
End;

BEGIN
 InitScr;
 InitGame;
 InitBoard;
 PlayGame;
END.