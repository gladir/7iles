{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2011
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Free Pascal)
}

Program Hanois;

Uses Crt;

Procedure Main;
Const
 C:Array[1..7]of Char='=======';
 XD:Array[1..3]of Byte=(9,25,41);
Var
 A:Array[1..3,0..8]of Byte;
 I:Byte;
 T,F,N:Integer;
 K:Word;

Procedure Update;
Var
 J,X,Y,Z:Byte;
Begin
 I:=0;
 For Y:=15downto 8do Begin
  Inc(I);
  For X:=1to 3do Begin
   Z:=A[X,I];
   If Z=0Then Begin
    GotoXY(XD[X]-7,Y); Write(' ':7,'I',' ':7);
   End
    Else
   For J:=XD[X]-Z to XD[X]+Z do Begin
    GotoXY(J,Y);
    Write(C[Z]);
   End;
  End;
 End;
End;

Function ChkOk(R:Byte):Boolean;Begin
 ChkOk:=True; I:=Byte(K)-Byte('0');
 If I in [1..3]Then Begin
  If R=1Then F:=I Else T:=I;
  Write(Char(K));
  GotoXY(10,20);
  Write(' ':30);
 End
  Else
 Begin
  GotoXY(10,20);
  Write('R‚pondre 1, 2 ou 3 S.V.P.');
  ChkOk:=False;
 End;
End;

Begin
 FillChar(A,SizeOf(A),0);
 N:=1; A[2,0]:=7; For I:=1to 7do A[2,I]:=8-I;
 TextMode(CO80);
 TextColor(7);
 TextBackground(0);
 ClrScr;
 GotoXY(13,1);
 Write('Tours d''Hanois');
 TextColor(0);
 TextBackground(2);
 GotoXY(1,16);
 WriteLn(' ':8,'1',' ':15,'2',' ':15,'3',' ':8);
 TextBackground(0);
 TextColor(7);
 Repeat
  Update;
  GotoXY(1,18);
  Write('Coup:',N);
  ClrEol;
  GotoXY(12,18);
  Write('Votre Jeu - De:');
  Repeat
   K:=Byte(ReadKey);
   If K=0Then K:=(K shl 8) or Byte(ReadKey);
   If K=27Then Exit;
  Until ChkOk(1);
  GotoXY(30,18);
  Write(' .:');
  Repeat
   K:=Byte(ReadKey);
   If K=0Then K:=(K shl 8) or Byte(ReadKey);
   If K=27Then Exit;
  Until ChkOk(2);
  GotoXY(10,20);
  If A[T,0]<>0Then Begin
   If Not((A[F,0]>0)and(A[F,A[F,0]]<A[T,A[T,0]]))Then Begin
    Write('Coup ill‚gal! Recommencez');
    Continue;
   End;
  End
   Else
  Write(' ':30);
  Inc(A[T,0]); A[T,A[T,0]]:=A[F,A[F,0]];
  A[F,A[F,0]]:=0; Dec(A[F,0]); Inc(N);
  If(A[1,0]=7)or(A[3,0]=7)Then Begin
   Update;
   GotoXY(1,19);
   Write('F‚licitations - Il t''a fallu ',N-1,' coups');
   Exit;
  End;
 Until False;
End;

BEGIN
 Main;
END.