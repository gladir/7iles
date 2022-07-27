{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2011
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program BOWLING;

Uses Crt;

Var
 Screen:Array[0..25,0..40]of Char;
 S,T:Array[0..4]of Integer;
 NA:Array[0..4]of String;
 A,B1,J,PS1,J1,Q,Score,T_,X1,X2,Z9:Integer;
 PS,Terminated:Boolean;

Function Left(Const Str:String;Num:Byte):String;Begin
 Left:=Copy(Str,1,Num);
End;

Function PadRight(S:String;Space:Byte):String;
Var
 I:Byte;
Begin
 If Length(S)<Space Then For I:=Length(S)+1 to Space do S:=S+' ';
 PadRight:=S;
End;

Procedure InitGame;
Var
 I:Byte;
 K:Char;
 Nom:String;
Begin
 FillChar(Screen,SizeOf(Screen),#0);
 Terminated:=False;
 A:=1;
 For I:=0 to 4 do NA[I]:='';
 TextMode(CO80);
 TextBackground(4);
 TextColor(15);
 ClrScr;
 GotoXY(37,8);
 WriteLn('BOWLING');
 GotoXY(7,13);
 Write('Combien de quilleurs doivent jouer (entre 1 et 4) ? ');
 Repeat
  K:=ReadKey;
  Case K of
   #27:Halt;
   '1'..'4':Begin
    A:=Ord(K)-Ord('0');
    Break;
   End;
  End;
 Until False;
 For I:=1 to A do Begin
  GotoXY(8,15+I);
  Write('Entrez le nom du quilleur #',I,' : ');
  ReadLn(Nom);
  NA[I-1]:=Left(Nom,8);
 End;
End;

Procedure DrawGameScreen;
Var
 I:Byte;
Begin
 TextMode(CO40);
 TextBackground(4);
 TextColor(15);
 ClrScr;
 GotoXY(10,1);
 Write('1  2  3  4  5  6  7  8  9  10');
 GotoxY(10,2);
 For J:=1 to 31 do Write({$IFDEF FPC}'-'{$ELSE}Chr(196){$ENDIF});
 For I:=1 to A do Begin
  GotoXY(1,2*I+1);
  TextColor(I+1);
  Write(PadRight(NA[I-1],11));
  J:=12;
  While J<=36 do Begin
   Write({$IFDEF FPC}'|'{$ELSE}Chr(179){$ENDIF},'  ');
   Inc(J,3);
  End;
  GotoXY(10,2*I+2);
  For J:=1 to 31 do Write({$IFDEF FPC}'-'{$ELSE}Chr(196){$ENDIF});
 End;
 GotoXY(1,12);
 For I:=0 to A-1 do Begin
  If I=2 Then GotoXY(1,14);
  TextColor(I+2);
  Write(NA[I],' :',' ':19-Length(NA[I]));
 End;
 GotoXY(1,15);
 For I:=1 to 39 do Write({$IFDEF FPC}'-'{$ELSE}Chr(196){$ENDIF});
 GotoXY(1,25);
 For I:=1 to 39 do Write({$IFDEF FPC}'-'{$ELSE}Chr(196){$ENDIF});
End;

Procedure InitScore;
Var
 I:Byte;
Begin
 For I:=0 to A-1 do S[I]:=1;
End;

Procedure RollBall;
Var
 G,H,V,D:Integer;
 K:Char;
Begin
 H:=1;V:=24;D:=-1;
 TextColor(0);
 TextBackground(Z9+2);
 While Not Keypressed do Begin
  GotoXY(H,V);
  Write(' ');
  V:=V+D;
  GotoXY(H,V);
  Write('O');
  Delay(200);
  If V in[16,24]Then D:=-D;
 End;
 If ReadKey=#27 Then Terminated:=True;
 For H:=2 to 35 do Begin
  GotoXY(H-1,V);
  Write(' O');
  Delay(100);
 End;
 J:=0;
 While H<40 do Begin
  If Screen[V,H]=#234 Then Begin
   J:=J+1;
   D:=-1;
   While D<=1 do Begin
    X1:=V;X2:=H;
    Repeat
     X1:=X1+D;
     X2:=X2+1;
     If Screen[X1,X2]=#234 Then Begin
      GotoXY(X2,X1);
      Screen[X1,X2]:=#32;
      Write(' ');
      J:=J+1;
     End
      Else
     Break;
    Until False;
    D:=D+2;
   End;
  End;
  GotoXY(H-1,V);
  Write(' O');
  H:=H+1;
 End;
 J1:=J1+J;
 GotoXY(7+3*Q+B1,2*Z9+3);
 TextColor(Abs(-(2+Z9)*Byte(B1=0)));
 TextBackground(Abs(-(2+Z9)*Byte(B1<>0)));
 G:=J+48;
 If J1=10 Then If PS Then G:=88 Else G:=47;
 Write(Chr(G));
 TextColor(0);
 TextBackground(2+Z9);
 GotoXY(H-1,V);
 Write(' ');
End;

Procedure FirstBall;
Const
 PC:Array[1..31]of Byte=(
  234,31,29,29,234,31,29,29,234,28,
  234,31,29,29,29,29,234,28,234,31,
  29,29,234,28,234,31,29,29,234,31,234
 );
Var
 I:Byte;
Begin
 GotoXY(39,17);
 TextColor(0);
 For I:=1 to 31 do Begin
  Case PC[I]of
   28:GotoXY(WhereX+1,WhereY);
   29:GotoXY(WhereX-1,WhereY);
   31:GotoXY(WhereX,WhereY+1);
   Else Begin
    Screen[WhereY,WhereX]:=Chr(PC[I]);
    Write(Chr(PC[I]));
   End;
  End;
 End;
 PS1:=1;J1:=0;
 RollBall;
 T_:=T[Z9];Score:=S[Z9];T_:=T_+J;
 Case S[Z9]of
  0:Begin
   If J1=10 Then If PS Then Score:=2 Else Score:=5;
  End;
  1:Begin
   T_:=T_+J;
   If J=10 Then Score:=3 Else Score:=4;
  End;
  2:Begin
   T_:=T_+J*2;
   If J<>10 Then Score:=4;
  End;
  3:Begin
   T_:=T_+J;
   If J1=10 Then Score:=5 Else Score:=1;
  End;
  4:Begin
   T_:=T_+J;
   If J=10 Then Score:=2 Else Score:=1;
  End;
 End;
 T[Z9]:=T_;S[Z9]:=Score;
 TextColor(Z9+2);
 TextBackground(0);
 GotoXY(31-Byte((Z9/2)=Trunc(Z9/2))*20,14-Byte(Z9<2)*2);
 Write(T[Z9]);
 TextColor(0);
 TextBackground(Z9+2);
End;

Procedure SecondBall;Begin
 PS:=False;
 RollBall;
 T_:=T[Z9];
 Score:=S[Z9];
 T_:=T_+J;
 Case S[Z9]of
  0:Begin
   If J1=10 Then If PS Then Score:=2 Else Score:=5;
  End;
  1:Begin
   T_:=T_+J;
   If J=10 Then Score:=3 Else Score:=4;
  End;
  2:Begin
   T_:=T_+J*2;
   If J<>10 Then Score:=4;
  End;
  3:Begin
   T_:=T_+J;
   If J1=10 Then Score:=5 Else Score:=1;
  End;
  4:Begin
   T_:=T_+J;
   If J=10 Then Score:=2 Else Score:=1;
  End;
 End;
 T[Z9]:=T_;S[Z9]:=Score;
 TextColor(Z9+2);
 TextBackground(0);
 GotoXY(31-Byte((Z9/2)=Trunc(Z9/2))*20,14-Byte(Z9<2)*2);
 Write(T[Z9]);
 TextColor(0);
 TextBackground(Z9+2);
End;

Procedure ExtraBalls;Begin
 GotoXY(1,20);
 Write('Jouez deux autres boules,',NA[Z9]);
 Delay(1000);
 GotoXY(1,WhereY);
 Write(' ':29);
 S[Z9]:=Score-1;
 B1:=1;
 FirstBall;
 If J<>10 Then Begin
  S[Z9]:=1;
  B1:=2;
  SecondBall;
 End
  Else
 Begin
  S[Z9]:=1;
  B1:=2;
  FirstBall;
 End;
End;

Procedure MainLoop;
Var
 I:Integer;
 K:Char;
Begin
 For Q:=1 to 10 do For Z9:=0 to A-1 do Begin
  If Terminated Then Break;
  TextBackground(Z9+2);
  For I:=16 to 24 do Begin
   GotoXY(1,I);
   Write(' ':39);
  End;
  B1:=0;
  FirstBall;
  If J1<>10 Then Begin
   B1:=1;
   SecondBall;
  End;
  If Q=10 Then Begin
   Case Score of
    0:;
    1,2:ExtraBalls;
    3:;
    4:Begin
     GotoXY(1,20);
     Write('Jouez une autre boule, ',NA[Z9]);
     Delay(1000);
     GotoXY(1,WhereY);
     Write(' ':28);
     S[Z9]:=1;B1:=2;
     FirstBall;
    End;
   End;
  End;
 End;
 GotoXY(3,16);
 Write('Voulez-vous encore jouer (O ou N) ?');
 If UpCase(ReadKey)='O'Then Terminated:=False
                       Else Terminated:=True;
End;

BEGIN
 InitGame;
 DrawGameScreen;
 InitScore;
 Repeat
  MainLoop;
 Until Terminated;
END.