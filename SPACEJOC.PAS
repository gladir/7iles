{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2022
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program SpaceJocker;

Uses Crt,DOS;

Var
 Score,Live:LongInt;
 XShip,YShip,BK:Byte;
 XShipBall,YShipBall:Array[0..7]of Byte;
 XAlien,YAlien,AlienType:Array[0..3]of Byte;

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

Procedure ShowLive;Begin
 TextColor(Black);
 TextBackground(6);
 GotoXY(1,24);
 ClrEol;
 Write('Vie : ',Live);
 GotoXY(1,25);
 ClrEol;
End;

Procedure InitGame;
Begin
 TextMode(CO40);
 TextBackground(Black);
 ClrScr;
 CursorOff;
 Live:=3;
 BK:=0;
 XShip:=4;
 YShip:=12;
 Score:=0;
 FillChar(XShipBall,SizeOf(XShipBall),0);
 FillChar(YSHipBall,SizeOf(YShipBall),0);
 FillChar(XAlien,SizeOf(XAlien),0);
 FillChar(YAlien,SizeOf(YAlien),0);
 FillChar(AlienType,SizeOf(AlienType),0);
 ShowLive;
End;

Procedure ShowGround;
Var
 I:Byte;
Begin
 GotoXY(1,23);
 TextColor(6);
 TextBackground(0);
 For I:=1 to 40 do Begin
  Case(BK)of
   0,1,2:Write(' ');
   3:Write(Chr(220));
   4,5,6:Write(Chr(219));
   7:Write(Chr(220));
  End;
  BK:=(BK+1) and 7;
 End;
End;

Procedure ShowScore;Begin
 GotoXY(20,1);
 TextBackground(0);
 TextColor(LightBlue);
 Write(Score);
End;

Procedure ShowAlien(N:Byte);Begin
 GotoXY(XAlien[N],YAlien[N]);
 TextColor(Cyan);
 Case AlienType[N]of
  1:Write({$IFDEF FPC}
           ' ( ) '
          {$ELSE}
           ' ('+Chr(219)+') '
          {$ENDIF}); { Ballon }
  2:Write('  /  '); { Avion }
  3:Write('/---\'); { Maison }
  4:Write({$IFDEF FPC}
           '--+--'
          {$ELSE}
           Chr(196)+Chr(196)+Chr(194)+Chr(196)+Chr(196)
          {$ENDIF}); { HÇlicoptäre }
  5:Write({$IFDEF FPC}
           ' --+ '
          {$ELSE}
           ' '+Chr(205)+Chr(205)+Chr(184)+' '
          {$ENDIF}); { Tank }
 End;
 GotoXY(XAlien[N],YAlien[N]+1);
 Case AlienType[N]of
  1:Write(' \|/ ');
  2:Write('-<--/');
  3:Write({$IFDEF FPC}
           '+-+-+'
          {$ELSE}
           Chr(218)+Chr(196)+Chr(194)+Chr(196)+Chr(191)
          {$ENDIF});
  4:Write('<-+-+');
  5:Write('---- ');
 End;
 GotoXY(XAlien[N],YAlien[N]+2);
 Case AlienType[N]of
  1:Write('  U');
  2:Write('  \  ');
  3:Write(
    {$IFDEF FPC}
     '+-+-+'
    {$ELSE}
     Chr(212)+Chr(205)+Chr(207)+Chr(205)+Chr(190)
    {$ENDIF});
  4:Write('  T  ');
  5:Write('-ooo ');
 End;
End;

Procedure HideAlien(N:Byte);Begin
 GotoXY(XAlien[N],YAlien[N]);
 Write(' ':5);
 GotoXY(XAlien[N],YAlien[N]+1);
 Write(' ':5);
 GotoXY(XAlien[N],YAlien[N]+2);
 Write(' ':5);
End;

Procedure ShowShip;Begin
 GotoXY(XShip,YShip);
 TextBackground(Black);
 TextColor(LightCyan);
 Write({$IFDEF FPC}'+---+'{$ELSE}' '+Chr(220)+Chr(219)+Chr(220)+' '{$ENDIF});
 GotoXY(XShip,YShip+1);
 TextBackground(Cyan);
 TextColor(Black);
 Write(' - - ');
 GotoXY(XShip,YShip+2);
 TextBackground(Black);
 TextColor(LightCyan);
 Write({$IFDEF FPC}'+-'{$ELSE}' '+Chr(223){$ENDIF});
 TextBackground(Red);
 TextColor(LightCyan);
 Write({$IFDEF FPC}'='{$ELSE}Chr(223){$ENDIF});
 TextBackground(Black);
 TextColor(LightCyan);
 Write({$IFDEF FPC}'-+'{$ELSE}Chr(223)+' '{$ENDIF});
End;

Procedure HideShip;Begin
 TextBackground(Black);
 GotoXY(XShip,YShip);
 Write(' ':5);
 GotoXY(XShip,YShip+1);
 Write(' ':5);
 GotoXY(XShip,YShip+2);
 Write(' ':5);
End;

Procedure AddShipBall;
Var
 I:Byte;
Begin
 For I:=0 to 7 do If XShipBall[I]=0 Then Begin
  XShipBall[I]:=XShip+5;
  YShipBall[I]:=YShip+1;
  Break;
 End;
End;

Function AlienCollision(N:Byte):Boolean;Begin
 AlienCollision:=False;
 If(XAlien[N]<=XShip+5)and
   (YAlien[N]>=YShip)and(YAlien[N]<=YShip+2)Then AlienCollision:=True;
End;

Function BallCollision(Ball,N:Byte):Boolean;Begin
 BallCollision:=False;
 IF(AlienType[N]=0)Then Exit;
 If(XShipBall[Ball]>=XAlien[N])and
   (YShipBall[Ball]>=YAlien[N])and
   (YShipBall[Ball]<=(YAlien[N]+2))Then BallCollision:=True;
End;

Procedure RunGame;
Var
 I,J:Byte;
 K:Char;
 NewAlien:Boolean;
Begin
 ShowScore;
 ShowShip;
 Repeat
  Repeat
   NewAlien:=True;
   ShowGround;
   BK:=(BK+1)and 7;
   For I:=0 to 7 do Begin
    If XShipBall[I]<>0 Then Begin
     GotoXY(XShipBall[I],YShipBall[I]);
     Write(' ');
     Inc(XShipBall[I]);
     For J:=0 to 3 do Begin
      If BallCollision(I,J)Then Begin
       Score:=Score+50;
       ShowScore;
       HideAlien(J);
       XAlien[J]:=0;
       YAlien[J]:=0;
       AlienType[J]:=0;
       XShipBall[I]:=0;
       YShipBall[I]:=0;
      End;
     End;
     If XShipBall[I]>40 Then Begin
      XShipBall[I]:=0;
      YShipBall[I]:=0;
     End
      Else
     If XShipBall[I]>0Then Begin
      GotoXY(XShipBall[I],YShipBall[I]);
      TextColor(White);
      Write('-');
     End;
    End;
   End;
   For I:=0 to 2 do Begin
    If AlienType[I]=0 Then Begin
     AlienType[I]:=Random(6);
     XAlien[I]:=35;
     If AlienType[I]in[3,5]Then YAlien[I]:=20
                           Else YAlien[I]:=Random(5)*3+2;
     NewAlien:=False;
     Break;
    End;
   End;
   For I:=0 to 3 do Begin
    If AlienType[I]<>0 Then Begin
     HideAlien(I);
     Dec(XAlien[I]);
     If AlienCollision(I)Then Begin
      GotoXY(15,12);
      TextColor(LightRed);
      If Live=0 Then Begin
       Write('PARTIE TERMINER !');
       If ReadKey=#0Then ReadKey;
       Exit;
      End;
      Dec(Live);
      Write('BOOM !!! COLLISION');
      If ReadKey=#0 Then ReadKey;
      BK:=0;
      XShip:=4;
      YShip:=12;
      FillChar(XShipBall,SizeOf(XShipBall),0);
      FillChar(YSHipBall,SizeOf(YShipBall),0);
      FillChar(XAlien,SizeOf(XAlien),0);
      FillChar(YAlien,SizeOf(YAlien),0);
      FillChar(AlienType,SizeOf(AlienType),0);
      TextBackground(Black);
      ClrScr;
      ShowLive;
      ShowGround;
      ShowScore;
      ShowShip;
      Break;
     End;
     If XAlien[I]=0Then Begin
      YAlien[I]:=0;
      AlienType[I]:=0;
     End
      Else
     ShowAlien(I);
    End;
   End;
   Delay(100);
  Until Keypressed;
  K:=ReadKey;
  Case K of
   #0:Case ReadKey of
    #72:If YShip>2 Then Begin { Up }
     HideShip;
     YShip:=YShip-1;
     ShowShip;
    End;
    #80:If YShip+2<22 Then Begin { Down }
     HideShip;
     YShip:=YShip+1;
     ShowShip;
    End;
   End;
   ' ':AddShipBall; { Tir ? }
  End;
 Until K=#27;
End;

BEGIN
 InitGame;
 RunGame;
 TextMode(C80);
 CursorOn;
 TextBackground(Black);
 TextColor(7);
 ClrScr;
END.