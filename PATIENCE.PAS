{ @author: Sylvain Maltais (support@gladir.com)
  @created: 1992
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program Patience;

Uses Crt,Strings;

Function Left(Const Str:String;Num:Byte):String;Begin
 Left:=Copy(Str,1,Num);
End;

Procedure DelChrAt(Var S:String;P:Byte);Begin
 If P=1Then S:=Copy(S,2,255)
       Else S:=Left(S,P-1)+Copy(S,P+1,255)
End;

Procedure StrDel(Str:PChar;Start,Len:Word);
Var
 SL:Word;
Begin
 SL:=StrLen(Str);
 If(SL=0)or(Start>SL)Then Exit;
 If SL=1Then Str[0]:=#0
  Else
 Begin
  If(Start<>SL)Then Move(Str[Start+Len],Str[Start],SL-Start);
  Str[SL]:=#0;
 End;
End;

Procedure Play;
Const
 HomeX=4; HomeY=3;
 CardImg:Array[0..52,0..4]of String[5]=(
  ('     ','     ','     ','     ','     '),
  ('A    ','     ','  '#3'  ','     ','    A'),
  ('2 '#3'  ',#3'    ','     ','    '#3,'  '#3' 2'),
  ('3 '#3'  ',#3'    ','  '#3'  ','    '#3,'  '#3' 3'),
  ('4    ',' '#3' '#3' ','     ',' '#3' '#3' ','    4'),
  ('5    ',' '#3' '#3' ','  '#3'  ',' '#3' '#3' ','    5'),
  ('6    ',' '#3' '#3' ',' '#3' '#3' ',' '#3' '#3' ','    6'),
  ('7    ',' '#3' '#3' ',' '#3#3#3' ',' '#3' '#3' ','    7'),
  ('8    ',' '#3#3#3' ',' '#3#3#3' ',' '#3' '#3' ','    8'),
  ('9    ',' '#3#3#3' ',' '#3#3#3' ',' '#3#3#3' ','    9'),
  ('10   ',#3#3#3#3#3,'     ',#3#3#3#3#3,'   10'),
  ('J    ',#3'UUU ',' UUU ',' UUU'#3,'    J'),
  ('Q    ',#3'UUU ',' UUU ',' UUU'#3,'    Q'),
  ('K    ',#3'UUU ',' UUU ',' UUU'#3,'    K'),
  ('A    ','     ','  '#6'  ','     ','    A'),
  ('2 '#6'  ',#6'    ','     ','    '#6,'  '#6' 2'),
  ('3 '#6'  ',#6'    ','  '#6'  ','    '#6,'  '#6' 3'),
  ('4    ',' '#6' '#6' ','     ',' '#6' '#6' ','    4'),
  ('5    ',' '#6' '#6' ','  '#6'  ',' '#6' '#6' ','    5'),
  ('6    ',' '#6' '#6' ',' '#6' '#6' ',' '#6' '#6' ','    6'),
  ('7    ',' '#6' '#6' ',' '#6#6#6' ',' '#6' '#6' ','    7'),
  ('8    ',' '#6#6#6' ',' '#6#6#6' ',' '#6' '#6' ','    8'),
  ('9    ',' '#6#6#6' ',' '#6#6#6' ',' '#6#6#6' ','    9'),
  ('10   ',#6#6#6#6#6,'     ',#6#6#6#6#6,'   10'),
  ('J    ',#6'UUU ',' UUU ',' UUU'#6,'    J'),
  ('Q    ',#6'UUU ',' UUU ',' UUU'#6,'    Q'),
  ('K    ',#6'UUU ',' UUU ',' UUU'#6,'    K'),
  ('A    ','     ','  '#4'  ','     ','    A'),
  ('2 '#4'  ',#4'    ','     ','    '#4,'  '#4' 2'),
  ('3 '#4'  ',#4'    ','  '#4'  ','    '#4,'  '#4' 3'),
  ('4    ',' '#4' '#4' ','     ',' '#4' '#4' ','    4'),
  ('5    ',' '#4' '#4' ','  '#4'  ',' '#4' '#4' ','    5'),
  ('6    ',' '#4' '#4' ',' '#4' '#4' ',' '#4' '#4' ','    6'),
  ('7    ',' '#4' '#4' ',' '#4#4#4' ',' '#4' '#4' ','    7'),
  ('8    ',' '#4#4#4' ',' '#4#4#4' ',' '#4' '#4' ','    8'),
  ('9    ',' '#4#4#4' ',' '#4#4#4' ',' '#4#4#4' ','    9'),
  ('10   ',#4#4#4#4#4,'     ',#4#4#4#4#4,'   10'),
  ('J    ',#4'UUU ',' UUU ',' UUU'#4,'    J'),
  ('Q    ',#4'UUU ',' UUU ',' UUU'#4,'    Q'),
  ('K    ',#4'UUU ',' UUU ',' UUU'#4,'    K'),
  ('A    ','     ','  '#5'  ','     ','    A'),
  ('2 '#5'  ',#5'    ','     ','    '#5,'  '#5' 2'),
  ('3 '#5'  ',#5'    ','  '#5'  ','    '#5,'  '#5' 3'),
  ('4    ',' '#5' '#5' ','     ',' '#5' '#5' ','    4'),
  ('5    ',' '#5' '#5' ','  '#5'  ',' '#5' '#5' ','    5'),
  ('6    ',' '#5' '#5' ',' '#5' '#5' ',' '#5' '#5' ','    6'),
  ('7    ',' '#5' '#5' ',' '#5#5#5' ',' '#5' '#5' ','    7'),
  ('8    ',' '#5#5#5' ',' '#5#5#5' ',' '#5' '#5' ','    8'),
  ('9    ',' '#5#5#5' ',' '#5#5#5' ',' '#5#5#5' ','    9'),
  ('10   ',#5#5#5#5#5,'     ',#5#5#5#5#5,'   10'),
  ('J    ',#5'UUU ',' UUU ',' UUU'#5,'    J'),
  ('Q    ',#5'UUU ',' UUU ',' UUU'#5,'    Q'),
  ('K    ',#5'UUU ',' UUU ',' UUU'#5,'    K'));
 BackKr=$2B;
Var
 Card:String;
 H,I,J,Y,StackPos:Byte;
 Stack4:Array[0..3,0..2]of Byte;
 Bank4:Array[0..3,0..13]of Byte;
 Stack:Array[0..39]of Byte;
 K:Char;
 B:Word;
 MX,MY:Byte;

 Function XtrkCard:Byte;Var R:Byte;Begin
  R:=Random(Length(Card))+1;
  XtrkCard:=Byte(Card[R]);
  DelChrAt(Card,R);
 End;

 Procedure PutCard(X,Y:Byte;Card:Byte);Var J,Kr:Byte;Begin
  If Card>52Then Begin Card:=0; Kr:=$10;End Else
  If Card=0Then Kr:=BackKr Else
  If Card in[1..13,27..39]Then Kr:=$FC Else Kr:=$F0;
  For J:=0to 4do Begin
   TextBackground(Kr shr 4);
   TextColor(Kr and $F);
   GotoXY(HomeX+X,HomeY+Y+J);
   Write(CardImg[Card,J]);
  End;
 End;

 Function Sort(Card:Byte):Byte;Begin
  If Card=0Then Sort:=$FF Else Sort:=(Card-1)div 13;
 End;

 Function Num(Card:Byte):Byte;Begin
  If Card=0Then Num:=$FF Else Num:=(Card-1)mod 13;
 End;

 Procedure UpDateStack4;Begin
  Stack4[Y,I]:=0;
  If I>0Then Dec(I);
  PutCard(2,Y*6,Stack4[Y,I]);
 End;

 Procedure Stack42Bank4;Var H:Byte;Begin
  H:=0; While Bank4[J,H]<>0do Inc(H);
  Bank4[J,H]:=Stack4[Y,I];
  PutCard(10+H*4,J*6,Bank4[J,H]);
  UpdateStack4;
 End;

 Procedure UpdateStack;Var I,J:Byte;Begin
  If StackPos<3Then J:=0 Else J:=StackPos-3;
  For I:=0to 2do PutCard(27+I shl 2,25,Stack[J+I]);
  If I<2Then Begin
   TextBackground(BackKr shr 4);
   Window(HomeX+28+(I+1)shl 2,HomeY+25,79,HomeY+30);
   ClrScr;
   Window(1,1,Lo(WindMax),Hi(WindMax));
  End;
 End;

 Procedure Stack2Bank4;Var H:Byte;Begin
  H:=0; While Bank4[J,H]<>0do Inc(H);
  Bank4[J,H]:=Stack[I];
  StrDel(@Stack,I,1);
  PutCard(10+H*4,J*6,Bank4[J,H]);
  If StackPos>0Then Dec(StackPos);
  UpdateStack;
 End;

Begin
 Card[0]:=#52;
 For I:=1to 52do Card[I]:=Char(I);
 For J:=0to 2do For I:=0to 3do Stack4[I,J]:=XtrkCard;
 FillChar(Bank4,SizeOf(Bank4),0);
 Bank4[0,0]:=XtrkCard;
 StackPos:=0;
 For I:=0to 38do Stack[I]:=XtrkCard;
 Stack[39]:=0;
 GotoXY(30,1);
 TextColor($F);
 Write('Aux Cartes - La Patience');
 TextBackground(BackKr shr 4);
 Window(1+0,1+2,1+Lo(WindMax),1+Hi(WindMax)-7);
 ClrScr;
 Window(1,1,Lo(WindMax),Hi(WindMax));
 For I:=0to 3do Begin
  TextBackground(BackKr shr 4);
  GotoXY(HomeX,HomeY+2+I*6);
  Write(Chr(I+49));
  PutCard(2,I*6,Stack4[I,2]);
 End;
 PutCard(10,0,Bank4[0,0]);
 PutCard(20,25,$FF);
 For I:=0to 1do Begin
  TextBackground(BackKr shr 4);
  GotoXY(HomeX+22+I*7,HomeY+32);
  Write(Chr(I+53));
 End;
 Repeat
  K:=ReadKey;
  Case K of
   '1'..'4':Begin
    Y:=Byte(K)-49;
    For I:=2downto 0do If Stack4[Y,I]<>0Then Break;
    If Stack4[Y,I]<>0Then Begin
    If Num(Stack4[Y,I])=Num(Bank4[0,0])Then Begin
     For J:=0to 3do If Bank4[J,0]=0Then Begin
      Bank4[J,0]:=Stack4[Y,I];
      PutCard(10,J*6,Bank4[J,0]);
      UpdateStack4;
      Break;
     End;
    End
     Else
    Begin
     For J:=0to 3do If Sort(Bank4[J,0])=Sort(Stack4[Y,I])Then Begin
      If J=0Then Stack42Bank4 Else
      For H:=0to 12do If Num(Bank4[J-1,H])=Num(Stack4[Y,I])Then Begin
       Stack42Bank4;
       Break;
      End;
     End;
    End;
    End;
   End;
   '5':Begin
    If Stack[StackPos]=0Then StackPos:=0;
    For I:=0to 2do Begin
     If Stack[StackPos]=0Then Break;
     PutCard(27+I shl 2,25,Stack[StackPos]);
     Inc(StackPos);
    End;
    If I<2Then Begin
     TextBackground(0);
     TextColor(7);
     Window(HomeX+28+(I+1)shl 2,HomeY+25,79,HomeY+30);
     ClrScr;
     Window(1,1,Lo(WindMax),Hi(WindMax));
    End;
   End;
   '6':Begin
    I:=StackPos;
    If I>0Then Dec(I);
    If Stack[I]<>0Then Begin
    If Num(Stack[I])=Num(Bank4[0,0])Then Begin
     For J:=0to 3do If Bank4[J,0]=0Then Begin
      Bank4[J,0]:=Stack[I];
      StrDel(@Stack,I,1);
      PutCard(10,J*6,Bank4[J,0]);
      If StackPos>0Then Dec(StackPos);
      UpdateStack;
      Break;
     End;
    End
     Else
    Begin
     For J:=0to 3do If Sort(Bank4[J,0])=Sort(Stack[I])Then Begin
      If J=0Then Stack2Bank4 Else
      For H:=0to 12do If Num(Bank4[J-1,H])=Num(Stack[I])Then Begin
       Stack2Bank4;
       Break;
      End;
     End;
    End;
    End;
   End;
  End;
  If(Bank4[0,12]>0)and(Bank4[1,12]>0)and(Bank4[2,12]>0)and(Bank4[3,12]>0)Then Begin
   GotoXY(24,24);
   Write('Vous avez gagnez!!!!!!!!');
   Break;
  End;
 Until K in[#27,'q','Q'];
End;

BEGIN
 TextMode(C80+Font8x8);
 Randomize;
 ClrScr;
 Play;
END.
