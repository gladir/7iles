{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2022
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program PegLeap;

Uses Crt;

Label 40,360,410,690,_Continue1,_Continue2;

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

Function MultChr(Chr:Char;Len:Byte):String;
Var
 I:Byte;
 S:String;
Begin
 S:='';
 For I:=1 to Len do S:=S+Chr;
 MultChr:=S;
End;

Procedure WaitRetrace;Begin
 Delay(10);
End;

Procedure Instruction;
Label Break;
Var
 J:Byte;
 K:Word;
 CK:Char Absolute K;
Begin
 TextBackground(0);
 TextColor(6);
 ClrScr;
 Write(MultChr('Û',80));
 For J:=1 to 21 do Begin
  GotoXY(1,J+1);
  Write('Û');
  GotoXY(80,J+1);
  Write('Û');
 End;
 GotoXY(1,23);
 Write(MultChr('Û',80));
 GotoXY(34,3);
 TextColor(11);
 Write('P E G    L E A P');
 TextColor(15);
 GotoXY(22,8);
 Write('Voulez-vous les instructions ? <O/N>');
 TextColor(3);
 Repeat
  K:=Byte(ReadKey);
  If K=0Then K:=K or (Byte(ReadKey)shl 8);
  Case(CK)of
   'n','N':GOTO Break;
   'o','O':Begin
    GotoXY(21,7);
	Write('  Il s''agit d''un jeu fort simple qui res-');
    GotoXY(21,8);
	Write('  semble aux dames. Le but du jeu est');
    GotoXY(21,9);
	Write('  d''enlever le plus de jetons possible du');
    GotoXY(21,10);
	Write('  en sautant par dessus chaque jeton avec');
    GotoXY(21,11);
	Write('  un autre. Vous ne pouvez sauter diagonale-');
    GotoXY(21,12);
	Write('  ment. Le jeton saut‚ sera enlev‚ du jeu.');
    GotoXY(21,14);
	Write('  D''abord place le curseur sous le jeton');
    GotoXY(21,15);
	Write('  qui saute et pŠse <ENTER>.');
    GotoXY(21,17);
	Write('  Ensuite place le curseur dans l''espace');
    GotoXY(21,18);
	Write('  libre o— sauter et pŠse encore <ENTER>.');
    GotoXY(28,25);
	TextColor(15);
	Write('Presse une touche pour continuer');
    If(ReadKey<>#0)Then;
    GOTO Break;
   End;
  End;
 Until False;
Break:
 ClrScr;
End;

Const Data:Array[0..32]of Byte=(13,14,15,
				22,23,24,
			  29,30,31,32,33,34,35,
			  38,39,40,41,42,43,44,
			  47,48,49,50,51,52,53,
				58,59,60,
				67,68,69);
DataPtr:Byte=0;

Var
 Pegs,Holes,Contents:String;
 B:Array[0..70]of LongInt;
 T,XY:Array[0..9,0..9]of LongInt;
 XLin,XPos,XSave,YSave,XCoord,YCoord,ZXSave,ZYSave,ZXCoord,ZYCoord:Integer;
 A,_B,F,P,R,C,W,X,Y,Z,_T:Integer;
 K:Word;
 CK:Char Absolute K;

Procedure ExitMsg;Begin
 GotoXY(25,25);
 TextColor(7);
 Write(' Presse <F10> pour abandonner ce Jeu ');
 TextColor(3);
 GotoXY(1,1);
End;

Procedure Restore;Begin
 DataPtr:=0;
End;

Function XCur:Integer;Begin
 XCur:=WhereX;
End;

Function YCur:Integer;Begin
 YCur:=WhereY;
End;

Procedure ChoicePeace;
Var
 Ok:Boolean;
Begin
{ SimpleCur;}
 Ok:=False;
 Repeat
  K:=Byte(ReadKey);
  If K=0Then K:=K or (Byte(ReadKey)shl 8);
  Case(K)of
   kbUp:If YCur>=6Then Begin
    If Not((YCur<12)and(XCur in[0..33,48..255]))Then Begin
     GotoXY(WhereX,WhereY-3);
    End;
   End;
   kbLeft:If XCur>=28Then Begin
    If Not((YCur in[0..8,16..255])and(XCur<40))Then Begin
	 GotoXY(WhereX-6,WhereY);
    End;
   End;
   kbRight:If XCur<=53Then Begin
    If Not((YCur in[0..8,16..255])and(XCur>41))Then Begin
	 GotoXY(WhereX+6,WhereY);
    End;
   End;
   kbDn:If YCur<=20Then Begin
    If Not((YCur>12)and(XCur in[0..33,48..255]))Then Begin
	 GotoXY(WhereX,WhereY+3);
    End;
   End;
   kbEnter,kbEsc,kbF10:Ok:=True;
  End;
  If CK=' 'Then Begin
   K:=kbEnter;
   Ok:=True;
  End;
 Until Ok;
 {CloseCur;}
 XSave:=XCur;XCoord:=(XSave-10)div 6;
 YSave:=YCur;YCoord:=(YSave div 3)+1;
End;

Function IsOK:Boolean;
Label 1140,1160;
Begin
 IsOk:=False;C:=1;
 For X:=1 to 9do For Y:=1to 9do Begin
  If(C<>Z)Then Goto 1160;
  If(C+2=P)Then Begin
   If T[X,Y+1]=0Then Exit;
   T[X,Y+2]:=5;T[X,Y+1]:=0;B[C+1]:=-3;
   Goto 1140
  End;
  If(C+18=P)Then Begin
   If T[X+1,Y]=0Then Exit;
   T[X+2,Y]:=5;T[X+1,Y]:=0;B[C+9]:=-3;
   Goto 1140
  End;
  If(C-2=P)Then Begin
   If T[X,Y-1]=0Then Exit;
   T[X,Y-2]:=5;T[X,Y-1]:=0;B[C-1]:=-3;
   Goto 1140;
  End;
  If(C-18=P)Then Begin
   If T[X-1,Y]=0Then Exit;
   T[X-2,Y]:=5;T[X-1,Y]:=0;B[C-9]:=-3;B[Z]:=-3;B[P]:=-7;
1140:B[Z]:=-3;B[P]:=-7;T[X,Y]:=0;
   IsOk:=True;
   Exit;
  End;
1160:Inc(C);
 End;
 IsOk:=True;
End;

Procedure UpDate;Var XOffset,YOffset:Integer;Begin
 CONTENTS:=HOLES;
 If T[ZYCOORD,ZXCOORD]=5Then Contents:=Pegs;
 GotoXY(ZXSave,ZYSave);
 Write(Contents);
 Contents:=Holes;
 If T[YCoord,XCoord]=5Then Contents:=Pegs;
 GotoXY(XSAVE,YSAVE);
 Write(Contents);
 YOFFSET:=ZYCOORD-YCOORD;
 XOFFSET:=ZXCOORD-XCOORD;
 If YOFFSET>0Then YOFFSET:=1;
 If XOFFSET>0Then XOFFSET:=1;
 If YOFFSET<0Then YOFFSET:=-1;
 If XOFFSET<0Then XOFFSET:=-1;
 CONTENTS:=HOLES;
 GotoXY(XSAVE+(XOFFSET*6),YSAVE+(YOFFSET*3));
 Write(Contents);
End;

Procedure _Halt;Begin
 XLIN:=WhereX;
 XPOS:=WhereY;
 GotoXY(1,25);
 Write(' ':80);
 GotoXY(21,24);
 Write('Voulez-vous abandonner ce Jeu ? <O/N>');
 Repeat
  K:=Byte(ReadKey);
  If K=0Then K:=K or (Byte(ReadKey)shl 8);
  If CK in['O','o']Then Halt;
 Until CK in['n','N'];
 ExitMsg;
End;

BEGIN
 TextMode(C80);
 ClrScr;
 Instruction;
 PEGS:='o';HOLES:=' ';
40:
 ClrScr;
 XLIN:=0;XPOS:=0;
 ExitMsg;
 FillChar(R,SizeOf(R),0);
 FillChar(C,SizeOf(C),0);
 FillChar(XY,SizeOf(XY),0);
 For R:=1to 9do For C:=1to 9do Begin
  If(((R-4)*(R-5)*(R-6)=0)or((C-4)*(C-5)*(C-6)=0))and Not((R-1)*(C-1)*(R-9)*(C-9)=0)Then Begin
    T[R,C]:=5;XY[R,C]:=Data[DataPtr];
	Inc(DataPtr)
  End
   Else
  T[R,C]:=-5;
 End;
 T[5,5]:=0;
 GotoXY(1,2);
 WriteLn(' ':32,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':32,'³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':32,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':32,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':32,'³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':32,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':20,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':20,'³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':20,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':20,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':20,'³ o ³ ³ o ³ ³ o ³ ³   ³ ³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':20,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':20,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':20,'³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':20,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':32,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':32,'³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':32,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 WriteLn(' ':32,'ÚÄÄÄ¿ ÚÄÄÄ¿ ÚÄÄÄ¿');
 WriteLn(' ':32,'³ o ³ ³ o ³ ³ o ³');
 WriteLn(' ':32,'ÀÄÄÄÙ ÀÄÄÄÙ ÀÄÄÄÙ');
 Restore;
 For W:=1to 33do Begin
  B[Data[DataPtr]]:=-7;
  Inc(DataPtr)
 End;
 B[41]:=-3;
360:YSave:=12;XSave:=41;
 GotoXY(1,25);
 Write(' ':24,'Place le curseur et presse <ENTER>.');
 ClrEol;
 GotoXY(32,24);
 Write('  Quelle piece ?   ');
 ClrEol;
 GotoXY(XSave,YSave);
410:ChoicePeace;
 If(K=kbEsc)or(K=kbF10)Then _Halt;
 ZYSAVE:=YSAVE;ZXSAVE:=XSAVE;ZYCOORD:=YCOORD;ZXCOORD:=XCOORD;Z:=XY[YCOORD,XCOORD];
 If B[Z]<>-7Then Begin
690:CONTENTS:=HOLES;
  If T[ZYCOORD,ZXCOORD]=5THEN CONTENTS:=PEGS;
  GotoXY(ZXSave,ZYSave);
  Write(CONTENTS);
  CONTENTS:=HOLES;
  If T[YCOORD,XCOORD]=5THEN CONTENTS:=PEGS;
  GotoXY(XSave,YSave);
  Write(CONTENTS);
  GotoXY(1,20);
  Write('Invalide...recommence.');
  WaitRetrace;WaitRetrace;WaitRetrace;WaitRetrace;WaitRetrace;
  WaitRetrace;WaitRetrace;WaitRetrace;WaitRetrace;WaitRetrace;
  GotoXY(1,20);
  Write(' ':27);
  {SetPos(XSave-1,YSave-1);
  SetCurPos(XSave-1,YSave-1);}
  Goto 360;
 End;
 GotoXY(33,23);
 Write('      Ou?       ');
 GotoXY(XSave,YSave);
 TextColor(7);
 TextBackground(8);
 Write(PEGS);
 TextBackground(0);
 GotoXY(XSave,YSave);
 ChoicePeace;
 If(K=kbEsc)or(K=kbF10)Then _Halt;
 P:=XY[YCOORD,XCOORD];
 If(B[P]=0)or(B[P]=-7)Then Goto 690;
 If(Z=P)Then Goto 360;
 If (Z+P)and 1=1Then Goto 690;
 If(ABS(Z-P)-2)*(ABS(Z-P)-18)<>0 THEN Goto 690;
 If Not(IsOK)Then Goto 690;
 UpDate;
 F:=0;
 For R:=2to 8do Begin
  For C:=2to 8do Begin
   If T[R,C]=5Then Begin
    Inc(F);
    For A:=R-1to R+1do Begin
     _T:=0;For _B:=C-1to C+1do Inc(_T,T[A,_B]);
     If _T<>10Then Goto _Continue1;
     If T[A,C]<>0Then Goto 360;
_Continue1:	
    End;
    For X:=C-1to C+1do Begin
     _T:=0;For Y:=R-1to R+1do Inc(_T,T[Y,X]);
     If _T<>10Then Goto _Continue2;
     If T[R,X]<>0Then Goto 360;
_Continue2:		
    End;
   End;
  End;
 End;
 GotoXY(1,22);
 Write('Il ne vous reste que ',F,' piŠces.');
 GotoXY(1,24);
 Write(' ':80);
 Case(F)of
  1:Begin
   GotoXY(1,21);
   Write('BRAVO !');
   GotoXY(1,23);
   Write('Parfait !');
   If T[5,5]=5Then Begin
    GotoXY(1,23);
	Write('Dans le centre ! Vous etes un G‚nie !');
   End;
  End;
  2:Begin
   GotoXY(1,21);
   Write('EXECELLENT !');
   GotoXY(3,21);
   Write('Essaie encore.');
  End;
  3,4:Begin
   GotoXY(1,21);
   Write('TrŠs bien !');
   GotoXY(1,23);
   Write('N''abandonnez pas!');
  End;
  5..7:Begin
   GotoXY(1,21);
   Write('PAS PIRE');
   GotoXY(1,23);
   Write('Essaie encore.');
  End;
 End;
 If Not(F<8)Then Begin
  If F>24Then Begin
   GotoXY(1,21);
   Write('Ce n''est pas le but du jeu');
   GotoXY(1,23);
   Write('Lisser les instructions !');
  End
   Else
  Begin
   GotoXY(1,21);
   Write('OUCH!');
   GotoXY(1,22);
   Write('Il ne reste que ',F,' piŠces.');
   GotoXY(1,23);
   Write('Ce n''est pas votre journ‚e!');
  End;
 End;
 GotoXY(1,24);
 Write('Aimeriez-vous jouer encore ? <O/N>');
 Repeat
  K:=Byte(ReadKey);
  If K=0Then K:=K or (Byte(ReadKey)shl 8);
  If(CK in['n','N'])or(K=kbEsc)Then Halt;
 Until CK in['o','O'];
 Restore;
 Goto 40;
END.
