{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2022
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program BREAKOUT;

Uses Crt,DOS;

Var
 IllimitedBalls,ShowBricks:Boolean;
 XCursor1,XCursor2:Integer;
 XBall,YBall,Balls:Integer;
 XDirection,YDirection:Integer;
 Score,NumberBricks:Integer;
 Bricks:Array[0..6,0..19]of Boolean;

{$IFNDEF FPC}
 Procedure CursorOff;
 Var
  Regs:Registers;
 Begin
  Regs.AH:=1;
  Regs.CH:=32;
  Regs.CL:=0;
  Intr($10,Regs);
 End;

 Procedure CursorOn;
 Var
  Regs:Registers;
 Begin
  Regs.AX:=$0100;
  Regs.CX:=(7 shl 8)+9;
  Intr($10,Regs);
 End;
{$ENDIF}

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Procedure InitStateBricks;
Var
 J,I:Byte;
Begin
 For J:=1 to 6 do For I:=1 to 19 do Bricks[J,I]:=True;
End;

Procedure UpdateScore;Begin
 GotoXY(1,1);
 TextColor(7);
 Write('Pointage : ',Score);
End;

Function BrickCollision(X,Y:Byte):Boolean;
Var
 TempX:Byte;
Begin
 BrickCollision:=False;
 If Y in[5..10]Then Begin
  TempX:=(X-1)shr 1;
  If Bricks[Y-4,TempX]Then Begin
   Case Y of
    5,6:Inc(Score,7);
    7,8,9:Inc(Score,4);
    10:Inc(Score,1);
   End;
   UpdateScore;
   GotoXY((TempX shl 1),Y);
   TextBackground(0);
   TextColor(7);
   Write('  ');
   Dec(NumberBricks);
   Bricks[Y-4,TempX]:=False;
   BrickCollision:=True;
   If(ShowBricks)Then Begin
    GotoXY(1,25);
    Write('Nombre de briques : ',NumberBricks,'  ');
   End;
  End;
 End;
End;

Procedure InitGame;Begin
 Score:=0;
 XCursor1:=18;
 XCursor2:=22;
 If(IllimitedBalls)Then Balls:=30000
                   Else Balls:=5;
 NumberBricks:=19*6;
 XBall:=20;
 YBall:=20;
 XDirection:=1;
 YDirection:=-1;
 InitStateBricks;
End;

Procedure UpdateBalls;Begin
 GotoXY(26,1);
 TextColor(7);
 Write('Balles : ',Balls,'    ');
End;

Procedure ShowWall;
Var
 I,J:Byte;
Begin
 TextBackground(Black);
 ClrScr;
 GotoXY(1,1);
 WriteLn;
 GotoXY(1,2);
 TextBackground(7);
 WriteLn(' ':40);
 GotoXY(1,3);
 Write(' ');
 TextBackground(0);
 Write(' ':38);
 TextBackground(7);
 Write(' ');
 TextBackground(0);
 WriteLn;
 GotoXY(1,4);
 TextBackground(7);
 Write(' ');
 TextBackground(0);
 Write(' ':38);
 TextBackground(7);
 Write(' ');
 TextBackground(0);
 WriteLn;
 For J:=1 to 6 do Begin
  GotoXY(1,4+J);
  TextBackground(7);
  Write(' ');
  Case J of
   1:TextBackground(Red);
   2:TextBackground(Red);
   3:TextBackground(6);
   4,5:TextBackground(Green);
   6:TextBackground(Blue);
  End;
  For I:=1 to 19 do Write(' |');
  TextBackground(7);
  Write(' ');
  TextBackground(0);
 End;
 For J:=1 to 14 do Begin
  GotoXY(1,10+J);
  TextBackground(7);
  Write(' ');
  TextBackground(0);
  Write(' ':38);
  TextBackground(7);
  Write(' ');
  TextBackground(0);
 End;
End;

Procedure ShowCursor;Begin
 GotoXY(XCursor1,24);
 TextBackground(Red);
 Write(' ':(XCursor2-XCursor1+1));
 TextBackground(0);
End;

Procedure HideCursor;Begin
 GotoXY(XCursor1,24);
 TextBackground(0);
 Write(' ':(XCursor2-XCursor1+1));
End;

Procedure ClrKbd;
Var
 K:Char;
Begin
 While KeyPressed do K:=ReadKey;
End;

Procedure CursorLeft;Begin
 If XCursor1>2 Then Begin
  HideCursor;
  Dec(XCursor1);
  Dec(XCursor2);
  ShowCursor;
 End;
 ClrKbd;
End;

Procedure CursorRight;Begin
 If XCursor2<39 Then Begin
  HideCursor;
  Inc(XCursor1);
  Inc(XCursor2);
  ShowCursor;
 End;
 ClrKbd;
End;

Procedure RunBall;
Var
 K:Char;
Begin
 Repeat
  ShowCursor;
  Repeat
   GotoXY(XBall,YBall);
   TextColor(Red);
   Write('o');
   Delay(200);
   GotoXY(XBall,YBall);
   Write(' ');
   If XBall>=39 Then XDirection:=-1 Else
   If XBall<=2 Then XDirection:=1;
   XBall:=XBall+XDirection;
   If BrickCollision(XBall,YBall)Then {XDirection:=-XDirection};
   If YBall>=23 Then Begin
    If(XBall>=XCursor1)and(XBall<=XCursor2)Then YDirection:=-1;
    If YBall>=24 Then Begin
     GotoXY(15,11);
     TextColor(Red);
     Write('Balle perdu !');
     ClrKbd;
     ReadKey;
     GotoXY(15,11);
     TextColor(7);
     Write(' ':20);
     If Balls>0 Then Begin
      Dec(Balls);
      UpdateBalls;
      HideCursor;
      XCursor1:=18;
      XCursor2:=22;
      XBall:=20;
      YBall:=20;
      Case Random(3)of
       1:XDirection:=1;
       Else XDirection:=-1;
      End;
      YDirection:=-1;
     End
      Else
     Begin
      GotoXY(10,12);
      TextColor(Red);
      WriteLn('Partie terminer !');
      ClrKbd;
      ReadKey;
      Exit;
     End;
    End;
   End
    Else
   If BrickCollision(XBall,YBall)Then Begin
    YDirection:=-YDirection
   End
    Else
   If YBall<=3 Then YDirection:=1;
   YBall:=YBall+YDirection;
   If BrickCollision(XBall,YBall)Then YDirection:=-YDirection;
   If NumberBricks=0 Then Begin
    GotoXY(15,11);
    TextColor(Green);
    Write('Tableau complete !');
    ClrKbd;
    ReadKey;
    InitStateBricks;
    Inc(Balls); { Bonus d'une balle }
    NumberBricks:=19*6;
    XCursor1:=18;
    XCursor2:=22;
    XBall:=20;
    YBall:=20;
    XDirection:=1;
    YDirection:=-1;
    ShowWall;
    UpdateScore;
    UpdateBalls;
   End;
  Until Keypressed;
  K:=ReadKey;
  Case K of
   #0:Case ReadKey of
    #75:CursorLeft;
    #77:CursorRight;
   End;
   '4':CursorLeft;
   '6':CursorRight;
  End;
 Until K=#27;
End;

Var
 I:Integer;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('BREAKOUT : Cette commande permet de lancer le jeu BREAKOUT.');
  WriteLn;
  WriteLn('Syntaxe : BREAKOUT [/FULLBALLS] [SHOWBRICKS]');
  WriteLn;
  WriteLn(' /FULLBALLS        Nombre de balles illimit‚s');
  WriteLn(' /SHOWBRICKS       Affiche les briques restantes');
  WriteLn;
 End
  Else
 Begin
  IllimitedBalls:=False;
  For I:=1 to ParamCount do Begin
   If StrToUpper(ParamStr(I))='/FULLBALLS'Then IllimitedBalls:=True Else
   If StrToUpper(ParamStr(I))='/SHOWBRICKS'Then ShowBricks:=True;
  End;
  TextMode(CO40);
  CursorOff;
  InitGame;
  ShowWall;
  UpdateScore;
  UpdateBalls;
  RunBall;
  CursorOn;
 End;
END.