{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program SpaceInvaders; { INVADERS.PAS / SPACEINVADERS.PAS }

{$R-}

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Var
 Finish,BoardCleared:Boolean;
 Score,Lives:LongInt;
 AlienCount,AlienScore:Word;
 Image:Array[0..14]of Pointer;
 BallX:Array[0..19]of Integer;
 BallY:Array[0..19]of Integer;
 AlienBallX:Array[0..3]of Integer;
 AlienBallY:Array[0..3]of Integer;
 LazerAlien:Integer;
 ClearX:Array[0..19]of Integer;
 ClearY:Array[0..19]of Integer;
 MasterAlienX:Integer;
 ScreenBoard:Array[0..59,0..79]of Byte;
 GunnerX,CurrSprite:Byte;
 Direction:ShortInt;

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

Procedure Copy4Bin(X,Y,Matrix,ForegroundColor,BackgroundColor:Integer);
Var
 I:Byte;
Begin
 For I:=0 to 3 do Begin
  If(Matrix shl (I shl 1))and 64=64 Then Begin
   PutPixel(X+I,Y,ForegroundColor);
  End
   Else
  Begin
   PutPixel(X+I,Y,BackgroundColor);
  End;
 End;
End;

Procedure PutImage4Bits(X,Y,Width,Height:Word;ForegroundColor,BackgroundColor:Integer;Var Buffer);
Type
 TByte=Array[0..2048]of Byte;
Var
 I,J:Integer;
 P:Word;
 PByte:TByte Absolute Buffer;
Begin
 If(Width=0)or(Height=0)Then Exit;
 P:=0;
 For J:=0 to Height-1 do For I:=0 to (Width shr 2)-1 do Begin
  Copy4Bin(X+(I shl 2),Y+J,PByte[P],ForegroundColor,BackgroundColor);
  Inc(P);
 End;
End;

Procedure Copy8Bin(X,Y,Matrix,ForegroundColor,BackgroundColor:Integer);
Var
 I:Byte;
Begin
 For I:=0 to 7 do Begin
  If(Matrix shl I)and 128=128 Then Begin
   PutPixel(X+I,Y,ForegroundColor);
  End
   Else
  Begin
   PutPixel(X+I,Y,BackgroundColor);
  End;
 End;
End;

Procedure PutImage8Bits(X,Y,Width,Height:Word;ForegroundColor,BackgroundColor:Integer;Var Buffer);
Type
 TByte=Array[0..2048]of Byte;
Var
 I,J:Integer;
 P:Word;
 PByte:TByte Absolute Buffer;
Begin
 If(Width=0)or(Height=0)Then Exit;
 P:=0;
 For J:=0 to Height-1 do For I:=0 to (Width shr 3)-1 do Begin
  Copy8Bin(X+(I shl 3),Y+J,PByte[P],ForegroundColor,BackgroundColor);
  Inc(P);
 End;
End;

Procedure DrawAlien(Number:Byte;X,Y:Word);
Const
 Data:Array[0..14,1..6*17]of Byte=(
    { 0 }
  ($00,$00,$00,$00,$00,$00,{0}
   $00,$00,$F4,$09,$10,$06,{1}
   $00,$04,$00,$00,$10,$00,{2}
   $00,$01,$00,$00,$40,$00,{3}
   $00,$00,$44,$11,$00,$00,{4}
   $00,$00,$15,$54,$00,$00,{5}
   $00,$00,$55,$55,$00,$00,{6}
   $00,$01,$45,$45,$40,$00,{7}
   $00,$05,$41,$41,$50,$00,{8}
   $00,$55,$55,$55,$55,$00,{9}
   $00,$41,$55,$55,$41,$00,{10}
   $00,$40,$50,$05,$01,$00,{11}
   $00,$41,$51,$45,$41,$00,{12}
   $00,$44,$05,$50,$11,$00,{13}
   $00,$44,$01,$40,$11,$00,{14}
   $00,$41,$00,$00,$41,$00,{15}
   $00,$40,$40,$01,$01,$00),{16}
    { 1 }
  (0,  0,$01,$41,$40,$01,{0}
   $41,$40,$90,$09,$10,$06,{1}
   $01,$40,$04,$10,$01,$40,{2}
   $00,$40,$04,$10,$01,$00,{3}
   $00,$40,$44,$11,$01,$00,{4}
   $00,$40,$15,$54,$01,$00,{5}
   $00,$40,$55,$55,$01,$00,{6}
   $00,$41,$45,$45,$41,$00,{7}
   $00,$45,$41,$41,$51,$00,{8}
   $00,$55,$55,$55,$55,$00,{9}
   $00,$01,$50,$05,$40,$00,{10}
   $00,$00,$50,$05,$00,$00,{11}
   $00,$01,$50,$05,$40,$00,{12}
   $00,$04,$04,$10,$10,$00,{13}
   $00,$04,$04,$10,$10,$00,{14}
   $00,$10,$01,$40,$04,$00,{15}
   $04,$40,$01,$40,$01,$10),{16}
    { 2 }
  (0,  $01,$00,$00,$00,$00,{0}
   $40,$BC,$0D,$0A,$10,$06,{1}
   $00,$40,$00,$00,$01,$00,{2}
   $01,$10,$00,$00,$04,$40,{3}
   $00,$04,$00,$00,$10,$00,{4}
   $00,$01,$05,$50,$40,$00,{5}
   $14,$05,$55,$55,$50,$14,{6}
   $14,$15,$01,$40,$54,$14,{7}
   $14,$55,$41,$50,$55,$14,{8}
   $14,$55,$01,$40,$55,$14,{9}
   $15,$55,$54,$15,$55,$54,{10}
   $05,$55,$50,$05,$55,$50,{11}
   $00,$15,$50,$05,$54,$00,{12}
   $00,$05,$54,$15,$50,$00,{13}
   $00,$05,$05,$50,$50,$00,{14}
   $00,$14,$00,$00,$14,$00,{15}
   $05,$50,$00,$00,$05,$50),{16}
    { 3 }
  ($00,$01,$50,$00,$00,$05,{0}
   $40,$58,$0D,$0A,$10,$06,{1}
   $00,$01,$40,$01,$40,$00,{2}
   $00,$04,$00,$00,$10,$00,{3}
   $00,$04,$00,$00,$10,$00,{4}
   $00,$01,$05,$50,$40,$00,{5}
   $00,$05,$55,$55,$50,$00,{6}
   $00,$15,$55,$55,$54,$00,{7}
   $00,$15,$01,$40,$55,$00,{8}
   $00,$55,$05,$41,$55,$00,{9}
   $05,$55,$01,$40,$55,$50,{10}
   $15,$55,$54,$15,$55,$54,{11}
   $14,$15,$54,$15,$54,$14,{12}
   $14,$05,$55,$55,$50,$14,{13}
   $14,$05,$55,$55,$50,$14,{14}
   $14,$05,$00,$00,$50,$14,{15}
   $00,$01,$40,$01,$40,$00),{16}
    { 4 }
  (0,  0,$00,$00,$54,$15,{0}
   $00,$00,$84,$0B,$10,$06,{1}
   $00,$00,$04,$10,$00,$00,{2}
   $01,$40,$15,$54,$01,$40,{3}
   $05,$50,$55,$55,$05,$50,{4}
   $14,$14,$55,$55,$14,$14,{5}
   $14,$14,$55,$55,$14,$14,{6}
   $05,$55,$55,$55,$55,$50,{7}
   $01,$50,$55,$55,$05,$40,{8}
   $00,$00,$50,$05,$00,$00,{9}
   $00,$00,$10,$04,$00,$00,{10}
   $00,$00,$10,$04,$00,$00,{11}
   $00,$01,$51,$45,$40,$00,{12}
   $00,$15,$55,$55,$54,$00,{13}
   $01,$50,$50,$05,$05,$40,{14}
   $05,$01,$40,$01,$40,$50,{15}
   $14,$05,$00,$00,$50,$14),{16}
    { 5 }
  (0,  0,$50,$14,$00,$00,{0}
   $14,$05,$20,$0B,$10,$06,{1}
   $00,$00,$04,$10,$00,$00,{2}
   $00,$00,$14,$14,$00,$00,{3}
   $00,$00,$55,$55,$00,$00,{4}
   $01,$40,$55,$55,$01,$40,{5}
   $05,$50,$55,$55,$05,$50,{6}
   $15,$54,$55,$55,$15,$54,{7}
   $14,$14,$55,$55,$14,$14,{8}
   $05,$55,$55,$55,$55,$50,{9}
   $01,$50,$55,$55,$05,$40,{10}
   $00,$00,$14,$14,$00,$00,{11}
   $00,$01,$54,$15,$40,$00,{12}
   $00,$05,$55,$55,$50,$00,{13}
   $00,$14,$04,$10,$14,$00,{14}
   $00,$50,$14,$14,$05,$00,{15}
   $00,$40,$10,$04,$01,$00),{16}
    { 6 }
  (0,  0,$00,$50,$14,$14,{0}
   $05,$00,$4C,$0C,$10,$06,{1}
   $00,$10,$01,$40,$04,$00,{2}
   $00,$14,$01,$40,$14,$00,{3}
   $00,$15,$01,$40,$54,$00,{4}
   $00,$11,$41,$41,$44,$00,{5}
   $00,$15,$55,$55,$54,$00,{6}
   $05,$55,$41,$41,$55,$50,{7}
   $15,$55,$51,$45,$55,$54,{8}
   $50,$15,$55,$55,$54,$05,{9}
   $40,$14,$55,$55,$14,$01,{10}
   $50,$50,$50,$05,$05,$05,{11}
   $00,$50,$11,$44,$05,$00,{12}
   $00,$50,$05,$50,$05,$00,{13}
   $00,$50,$01,$40,$05,$00,{14}
   $01,$40,$01,$40,$01,$40,{15}
   $05,$50,$00,$00,$05,$50),{16}
    { 7 }
  (0,  0,$15,$54,$00,$00,{0}
   $15,$54,$E8,$0B,$10,$06,{1}
   $50,$10,$05,$50,$04,$05,{2}
   $40,$14,$01,$40,$14,$01,{3}
   $50,$15,$01,$40,$54,$05,{4}
   $15,$51,$41,$41,$45,$54,{5}
   $05,$55,$55,$55,$55,$50,{6}
   $00,$05,$05,$50,$50,$00,{7}
   $00,$05,$41,$41,$50,$00,{8}
   $00,$15,$55,$55,$54,$00,{9}
   $00,$14,$50,$05,$14,$00,{10}
   $00,$50,$55,$55,$05,$00,{11}
   $00,$50,$55,$55,$05,$00,{12}
   $00,$50,$05,$50,$05,$00,{13}
   $00,$50,$01,$40,$05,$00,{14}
   $00,$14,$00,$00,$14,$00,{15}
   $00,$55,$00,$00,$55,$00),{16}
    { 8 }
  (0,$01,$55,$50,$05,$55,{0}
   $40,$14,$0D,$0A,$10,$06,{1}
   $00,$00,$00,$00,$00,$00,{2}
   $00,$00,$50,$05,$00,$00,{3}
   $00,$01,$54,$15,$40,$00,{4}
   $00,$05,$55,$55,$50,$00,{5}
   $00,$05,$01,$40,$50,$00,{6}
   $00,$15,$11,$44,$54,$00,{7}
   $01,$55,$55,$55,$55,$40,{8}
   $15,$15,$40,$01,$54,$54,{9}
   $14,$05,$41,$41,$50,$14,{10}
   $14,$05,$55,$55,$50,$14,{11}
   $14,$15,$05,$50,$54,$14,{12}
   $14,$14,$01,$40,$14,$14,{13}
   $00,$15,$00,$00,$54,$00,{14}
   $00,$05,$54,$15,$50,$00,{15}
   $00,$01,$54,$15,$40,$00),{16}
    { 9 }
  ( 0,  0,$00,$00,$00,$00,{0}
   00,$00,$B0,$0C,$10,$06,{1}
   $00,$00,$00,$00,$00,$00,{2}
   $14,$00,$50,$05,$00,$14,{3}
   $14,$01,$54,$15,$40,$14,{4}
   $14,$05,$55,$55,$50,$14,{5}
   $14,$05,$11,$44,$50,$14,{6}
   $15,$15,$01,$40,$54,$54,{7}
   $01,$55,$55,$55,$55,$40,{8}
   $00,$15,$50,$05,$54,$00,{9}
   $00,$05,$55,$55,$50,$00,{10}
   $00,$05,$55,$55,$50,$00,{11}
   $00,$15,$05,$50,$54,$00,{12}
   $00,$14,$00,$00,$14,$00,{13}
   $00,$54,$00,$00,$15,$00,{14}
   $15,$50,$00,$00,$05,$54,{15}
   $15,$40,$00,$00,$01,$54),{16}
    { 10 }
  (0,$00,$00,$00,$00,$00,{0}
   $00,$78,$0D,$0A,$10,$06,{1}
   $00,$00,$01,$40,$00,$00,{2}
   $00,$00,$01,$40,$00,$00,{3}
   $00,$00,$05,$50,$00,$00,{4}
   $00,$00,$15,$54,$00,$00,{5}
   $00,$00,$55,$55,$00,$00,{6}
   $55,$55,$55,$55,$55,$55,{7}
   $00,$00,$44,$11,$00,$00,{8}
   $00,$00,$55,$55,$00,$00,{9}
   $00,$00,$55,$55,$00,$00,{10}
   $00,$05,$55,$55,$50,$00,{11}
   $00,$01,$55,$55,$40,$00,{12}
   $00,$01,$55,$55,$40,$00,{13}
   $00,$00,$55,$55,$00,$00,{14}
   $00,$00,$51,$45,$00,$00,{15}
   $00,$00,$51,$45,$00,$00),{16}
    { 11 }
  (0,$00,$00,$51,$45,$00,{0}
   $00,$0D,$0A,$11,$0E,$06,{1}
   $00,$00,$05,$50,$00,$00,{2}
   $00,$00,$10,$04,$00,$00,{3}
   $00,$00,$40,$01,$00,$00,{4}
   $00,$01,$00,$00,$40,$00,{5}
   $00,$04,$00,$00,$10,$00,{6}
   $05,$54,$44,$11,$15,$50,{7}
   $55,$55,$55,$55,$55,$55,{8}
   $00,$50,$10,$14,$01,$00,{9}
   $00,$51,$51,$44,$51,$00,{10}
   $00,$51,$51,$44,$01,$00,{11}
   $00,$51,$51,$44,$55,$00,{12}
   $00,$10,$10,$14,$54,$00,{13}
   $00,$05,$55,$55,$50,$00,{14}
   $00,$00,$00,$00,$00,$00,{15}
   $5F,$11,$0D,$0A,$06,$00),{16}
    { 12 }
  (0,$00,$01,$00,$00,$00,{0}
   $00,$00,$00,$00,$00,$00,{1}
   $00,$00,$05,$40,$00,$00,{2}
   $00,$00,$15,$50,$00,$00,{3}
   $00,$01,$55,$55,$00,$00,{4}
   $01,$55,$44,$44,$54,$50,{5}
   $55,$55,$55,$55,$55,$54,{6}
   $15,$55,$55,$55,$55,$50,{7}
   $00,$01,$55,$55,$00,$00,{8}
   $00,$01,$11,$11,$00,$00,{9}
   $9F,$11,$06,$02,$01,$10,{10}
   $01,$10,$01,$50,$00,$40,{11}
   $00,$40,$00,$40,$AF,$11,{12}
   $0D,$0A,$01,$10,$10,$10,{13}
   $10,$10,$10,$10,$10,$54,{14}
   $44,$00,$00,$00,$F9,$0E,{15}
   $10,$06,$00,$00,$00,$00),{16}
    { 13 }
  (0,  0,  0,  0,$00,$00,{0}
   $00,$00,$00,$00,$00,$40,{1}
   $00,$00,$40,$44,$00,$00,{2}
   $00,$00,$00,$10,$00,$00,{3}
   $00,$05,$15,$01,$00,$00,{4}
   $00,$01,$54,$15,$50,$00,{5}
   $00,$01,$55,$41,$50,$00,{6}
   $00,$15,$05,$45,$40,$00,{7}
   $01,$01,$50,$54,$40,$00,{8}
   $00,$00,$54,$15,$00,$00,{9}
   $00,$45,$05,$41,$51,$10,{10}
   $00,$00,$01,$40,$44,$00,{11}
   $00,$11,$01,$00,$44,$00,{12}
   $04,$50,$00,$00,$40,$00,{13}
   $44,$00,$00,$00,$00,$00,{14}
   $04,$00,$00,$00,$00,$00,{15}
   $95,$0E,$10,$06,$01,$00),{16}
    { 14 }
  (0,  0,  0,  0,$00,$40,{0}
   $00,$41,$04,$00,$00,$00,{1}
   $04,$10,$10,$40,$11,$04,{2}
   $40,$04,$40,$00,$01,$00,{3}
   $00,$01,$00,$04,$41,$11,{4}
   $01,$00,$10,$40,$11,$04,{5}
   $10,$04,$00,$00,$00,$40,{6}
   $00,$00,$50,$00,$05,$45,{7}
   $01,$00,$01,$00,$51,$50,{8}
   $00,$05,$10,$04,$01,$01,{9}
   $10,$00,$00,$00,$10,$44,{10}
   $01,$04,$04,$00,$40,$41,{11}
   $00,$00,$40,$00,$00,$44,{12}
   $00,$41,$10,$10,$10,$40,{13}
   $10,$04,$04,$00,$00,$04,{14}
   $00,$10,$01,$00,$41,$00,{15}
   $00,$40,$C0,$11,$12,$06){16}
 );
Begin
 PutImage4Bits(X,Y,6*4,17,White,Black,Data[Number]);
End;

Procedure ShowAlien(Number:Byte;X,Y:Word);Begin
 PutImage(X,Y,Image[Number]^,NormalPut);
End;

Procedure UnshowAlien(X,Y:Word);Begin
 SetFillStyle(SolidFill,Black);
 Bar(X,Y,X+6*4,Y+16);
End;

Procedure ShowWall(X:Word);
Const
 Data:Array[1..6*17]of Byte=(
   $00,$00,$00,$00,$00,$00,{0}
   $00,$78,$0D,$0A,$10,$06,{1}
   $00,$00,$01,$40,$00,$00,{2}
   $00,$00,$01,$40,$00,$00,{3}
   $00,$00,$05,$50,$00,$00,{4}
   $00,$00,$15,$54,$00,$00,{5}
   $00,$00,$55,$55,$00,$00,{6}
   $55,$55,$55,$55,$55,$55,{7}
   $00,$00,$44,$11,$00,$00,{8}
   $00,$00,$55,$55,$00,$00,{9}
   $00,$00,$55,$55,$00,$00,{10}
   $00,$05,$55,$55,$50,$00,{11}
   $00,$01,$55,$55,$40,$00,{12}
   $00,$01,$55,$55,$40,$00,{13}
   $00,$00,$55,$55,$00,$00,{14}
   $00,$00,$51,$45,$00,$00,{15}
   $00,$00,$51,$45,$00,$00);{16}
Begin
 PutImage4Bits(X,400,6*4,17,Brown,Black,Data);
End;

Procedure _ShowGunner(X,Y:Word);
Const
 Gunner:Array[1..6*17]of Byte=(
   $00,$00,$01,$40,$00,$00,{0}
   $00,$00,$01,$40,$00,$00,{1}
   $00,$00,$01,$40,$00,$00,{2}
   $00,$00,$01,$40,$00,$00,{3}
   $00,$00,$05,$50,$00,$00,{4}
   $00,$00,$15,$54,$00,$00,{5}
   $00,$00,$51,$45,$00,$00,{6}
   $00,$01,$51,$45,$40,$00,{7}
   $00,$15,$11,$44,$54,$00,{8}
   $00,$51,$11,$44,$45,$00,{9}
   $05,$51,$11,$44,$45,$50,{10}
   $45,$54,$55,$55,$15,$51,{11}
   $45,$55,$55,$55,$55,$51,{12}
   $55,$55,$40,$01,$55,$55,{13}
   $40,$05,$00,$00,$50,$01,{14}
   $00,$05,$00,$00,$50,$00,{15}
   $00,$00,$00,$00,$00,$00);{16}
Begin
 PutImage4Bits(X,Y,24,17,White,Black,Gunner);
End;

Procedure ShowGunner;Begin
 _ShowGunner(GunnerX shl 3,440);
End;

Procedure UnshowGunner;Begin
 SetFillStyle(SolidFill,Black);
 Bar(GunnerX shl 3,440,(GunnerX shl 3)+23,440+16);
End;

Function NextAlienDirection:Integer;
Var
 I,J:Integer;
Begin
 NextAlienDirection:=Direction;
 If Direction>0 Then Begin
  For J:=10 to 55 do For I:=79 downto 0 do Begin
   If ScreenBoard[J,I]in[1..5]Then Begin
    If I>=79-4 Then Begin
     NextAlienDirection:=-1;
     Exit;
    End;
   End;
  End;
 End
  Else
 If Direction<0 Then Begin
 For J:=10 to 55 do For I:=0 to 79 do Begin
   If ScreenBoard[J,I]in[1..5]Then Begin
    If I<=4 Then Begin
     NextAlienDirection:=1;
     Exit;
    End;
   End;
  End;
 End;
End;

Function MoveAlien:Boolean;
Var
 I,J,K:Integer;
 Alien:Byte;
 NextDirection:Integer;
Begin
 MoveAlien:=True;
 CurrSprite:=(CurrSprite+1)and 1;
 NextDirection:=NextAlienDirection;
 If(NextDirection<>Direction)Then Begin
  If NextDirection>0 Then Begin
   For J:=55 downto 10 do For I:=79 downto 0 do Begin
    If ScreenBoard[J,I]in[1..5]Then Begin
     If J+4>50 Then Begin
      MoveAlien:=False;
      Exit;
     End;
     UnshowAlien(I*8,J*8);
     Alien:=ScreenBoard[J,I];
     ScreenBoard[J,I]:=0;
     ScreenBoard[J+4,I+1]:=Alien;
     ShowAlien(Alien*2+CurrSprite,(I+1)*8,(J+4)*8);
    End;
   End;
  End
   Else
  Begin
   For J:=55 downto 10 do For I:=0 to 79 do Begin
    If ScreenBoard[J,I]in[1..5]Then Begin
     If J+4>50 Then Begin
      MoveAlien:=False;
      Exit;
     End;
     UnshowAlien(I*8,J*8);
     Alien:=ScreenBoard[J,I];
     ScreenBoard[J,I]:=0;
     ScreenBoard[J+2,I-1]:=Alien;
     ShowAlien(Alien*2+CurrSprite,(I-1)*8,(J+2)*8);
    End;
   End;
  End;
  Direction:=NextDirection;
 End
  Else
 If Direction>0 Then Begin
  For J:=10 to 55 do For I:=79 downto 0 do Begin
   If ScreenBoard[J,I]in[1..5]Then Begin
    UnshowAlien(I*8,J*8);
    Alien:=ScreenBoard[J,I];
    ScreenBoard[J,I]:=0;
    ScreenBoard[J,I+1]:=Alien;
    ShowAlien(Alien*2+CurrSprite,(I+1)*8,J*8);
    If(LazerAlien>0)Then Dec(LazerAlien)
     Else
    Begin
     LazerAlien:=Random(3);
     For K:=0 to 3 do If AlienBallY[K]=0 Then Begin
      AlienBallX[K]:=(I+1)*8;
      AlienBallY[K]:=J*8;
      Break;
     End;
    End;
   End;
  End;
 End
  Else
 Begin
  For J:=10 to 55 do For I:=0 to 79 do Begin
   If ScreenBoard[J,I]in[1..5]Then Begin
    UnshowAlien(I*8,J*8);
    Alien:=ScreenBoard[J,I];
    ScreenBoard[J,I]:=0;
    ScreenBoard[J,I-1]:=Alien;
    ShowAlien(Alien*2+CurrSprite,(I-1)*8,J*8);
    If(LazerAlien>0)Then Dec(LazerAlien)
     Else
    Begin
     LazerAlien:=Random(3);
     For K:=0 to 3 do If AlienBallY[K]=0 Then Begin
      AlienBallX[K]:=(I-1)*8;
      AlienBallY[K]:=J*8;
      Break;
     End;
    End;
   End;
  End;
 End;
End;

Function AlienCollision(X,Y:Integer;Clear:Boolean):Boolean;
Var
 I,J,K:Integer;
Begin
 AlienCollision:=False;
 For J:=55 downto 10 do For I:=79 downto 0 do Begin
  If ScreenBoard[J,I]in[1..5]Then Begin
   If(X>=I*8)and(X<=I*8+23)and(Y>=J*8)and(Y<=J*8+16)Then Begin
    If(Clear)Then Begin
     For K:=0 to 39 do If ClearY[K]=0 Then Begin
      ClearX[K]:=I*8;
      ClearY[K]:=J*8;
     End;
     ShowAlien(14,I*8,J*8);
    End;
    AlienScore:=(5-ScreenBoard[J,I])*10;
    ScreenBoard[J,I]:=0;
    Dec(AlienCount);
    AlienCollision:=True;
    Exit;
   End;
  End;
 End;
End;

Function AlienBallCollision(X,Y:Integer):Boolean;
Var
 I:Integer;
Begin
 AlienBallCollision:=False;
 For I:=0 to 3 do Begin
  If(X>=GunnerX*8)and(X<=GunnerX*8+23)and(Y>=440)and(Y<=460)Then Begin
   AlienBallCollision:=True;
   Exit;
  End;
 End;
End;

Function MasterAlienCollision(X,Y:Integer):Boolean;Begin
 MasterAlienCollision:=False;
 If(X>=MasterAlienX)and(X<=MasterAlienX+23)and(Y>=30)and(Y<=30+16)Then Begin
  MasterAlienCollision:=True;
  AlienScore:=100;
  Exit;
 End;
End;

Procedure AddScore(X:Integer);Begin
 SetColor(Black);
 OutTextXY(20*8,0,'Pointage : '+LongToStr(Score));
 Score:=Score+X;
 SetColor(Yellow);
 OutTextXY(20*8,0,'Pointage : '+LongToStr(Score));
End;

Procedure ShowLives;
Var
 I:Integer;
Begin
 SetColor(White);
 Line(0,460,639,460);
 SetFillStyle(SolidFill,Black);
 Bar(0,462,639,479);
 For I:=1 to Lives do Begin
  _ShowGunner(I*40,462);
 End;
End;

Procedure InitBoard;
Var
 I,J:Integer;
Begin
 FillChar(BallX,SizeOf(BallX),0);
 FillChar(BallY,SizeOf(BallY),0);
 FillChar(AlienBallX,SizeOf(AlienBallX),0);
 FillChar(AlienBallY,SizeOf(AlienBallY),0);
 FillChar(ClearX,SizeOf(ClearX),0);
 FillChar(ClearY,SizeOf(ClearY),0);
 LazerAlien:=Random(3);
 BoardCleared:=False;
 GunnerX:=39;
 CurrSprite:=0;
 Direction:=1;
 AlienCount:=0;
 MasterAlienX:=-1;
 AddScore(0);
 For J:=0 to 4 do For I:=0 to 11 do Begin
  If J=4 Then ScreenBoard[10+J*4,16+I*4]:=4
         Else ScreenBoard[10+J*4,16+I*4]:=J+1;
  ShowAlien(ScreenBoard[10+J*4,16+I*4],(16+I*4)*8,(10+J*4)*8);
  Inc(AlienCount);
 End;
 For I:=0 to 3 do ShowWall((20+I*12)*8);
 ShowLives;
 ShowGunner;
End;

Procedure MakeImage;
Var
 I:Integer;
 Size:Word;
Begin
 For I:=0 to 14 do Begin
  DrawAlien(I,0,0);
  Size:=ImageSize(0,0,6*4-1,17-1);
  GetMem(Image[I],Size);
  GetImage(0,0,6*4-1,17-1,Image[I]^);
 End;
 ClearDevice;
End;

Var
 I:Integer;

BEGIN
 FillChar(ScreenBoard,SizeOf(ScreenBoard),0);
 Finish:=False;
 InitScr;
 MakeImage;
 ClearDevice;
 OutTextXY(150,0,'ЫЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫ  ЫЫЫЫЫ    ЫЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫЫ');
 OutTextXY(150,8,'Ы    ЫЫЫ Ы     ЫЫ Ы   ЫЫ   Ы    ЫЫЫ Ы       ');
 OutTextXY(150,16,'Ы    ЫЫЫ Ы      Ы Ы    Ы   Ы    ЫЫЫ Ы       ');
 OutTextXY(150,24,'Ы        Ы      Ы Ы    Ы   Ы    ЫЫЫ Ы       ');
 OutTextXY(150,32,'Ы        ЫЫ     Ы ЫЫ    Ы  Ы        ЫЫ      ');
 OutTextXY(150,40,'ЫЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫЫ Ы        ЫЫЫЫЫЫ  ');
 OutTextXY(150,48,'     ЫЫЫ ЫЫЫ      ЫЫЫ    Ы Ы        ЫЫЫ     ');
 OutTextXY(150,56,'     ЫЫЫ ЫЫЫ      ЫЫЫ    Ы Ы        ЫЫЫ     ');
 OutTextXY(150,64,'Ы    ЫЫЫ ЫЫЫ      ЫЫЫ    Ы Ы      Ы ЫЫЫ     ');
 OutTextXY(150,72,'Ы    ЫЫЫ ЫЫЫ      ЫЫЫ    Ы Ы      Ы ЫЫЫ     ');
 OutTextXY(150,80,'ЫЫЫЫЫЫЫЫ ЫЫЫ      ЫЫЫ    Ы ЫЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫЫ');
 SetColor(LightRed);
 OutTextXY(50,96,'  Ы   ЫЫЫ    ЫЫ      Ы  ЫЫЫЫЫ ЫЫЫЫЫЫЫ ЫЫЫЫЫЫЫЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫЫ');
 OutTextXY(50,104,'  Ы   Ы  Ы   ЫЫ      Ы  Ы   ЫЫЫЫЫ   ЫЫЫ       Ы    ЫЫ Ы    ЫЫЫ');
 OutTextXY(50,112,'  Ы   Ы   Ы  ЫЫ      Ы  Ы    ЫЫЫЫ    ЫЫ       Ы     Ы Ы    ЫЫЫ');
 OutTextXY(50,120,'  Ы   Ы    Ы ЫЫ      Ы  Ы    ЫЫЫЫ    ЫЫ       Ы     Ы Ы       ');
 OutTextXY(50,128,' ЫЫ   Ы     ЫЫЫ     ЫЫ ЫЫ    ЫЫЫЫ    ЫЫЫ      ЫЫ    ЫЫЫ       ');
 OutTextXY(50,136,'ЫЫЫ   Ы      ЫЫ    ЫЫЫЫЫЫЫЫЫЫЫЫЫЫ    ЫЫЫЫЫЫЫ  ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ');
 OutTextXY(50,144,'ЫЫЫ   Ы      ЫЫ    ЫЫЫЫЫЫ    ЫЫЫЫ    ЫЫЫЫ     ЫЫЫ   ЫЫ     ЫЫЫ');
 OutTextXY(50,152,'ЫЫЫ   Ы      ЫЫ    ЫЫЫЫЫЫ    ЫЫЫЫ    ЫЫЫЫ     ЫЫЫ   ЫЫ     ЫЫЫ');
 OutTextXY(50,160,'ЫЫЫ   Ы  ЫЫ  Ы Ы   ЫЫ ЫЫЫ    ЫЫЫЫ    ЫЫЫЫ     ЫЫЫ   ЫЫЫ    ЫЫЫ');
 OutTextXY(50,168,'ЫЫЫ   Ы  ЫЫ  Ы  Ы  Ы  ЫЫЫ    ЫЫЫЫ    ЫЫЫЫ     ЫЫЫ   ЫЫЫ    ЫЫЫ');
 OutTextXY(50,176,'ЫЫЫ   Ы  ЫЫ  Ы   ЫЫ   ЫЫЫ    ЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫЫ   ЫЫЫЫЫЫЫЫЫЫ');
 SetColor(White);
 OutTextXY(50,280,'Table avanc‚ des pointages :');
 For I:=0 to 3 do Begin
  ShowAlien(I*2,100,300+I*20);
  OutTextXY(130,300+I*20,'='+LongToStr((3-I)*10)+' points');
 End;
 ShowAlien(11,100,380);
 OutTextXY(130,380,'=100 points');
 OutTextXY(0,460,'Presse une touche pour jouer...');
 ReadKey;
 ClearDevice;
 Score:=0;
 Lives:=3;
 InitBoard;
 Repeat
  Repeat
   If MasterAlienX>=0 Then Begin
    UnshowAlien(MasterAlienX,30);
    If MasterAlienX<=0 Then Begin
     MasterAlienX:=-1;
    End
     Else
    Begin
     Dec(MasterAlienX,8);
     ShowAlien(11+CurrSprite,MasterAlienX,30);
    End;
   End
    Else
   Begin
    If Random(30)=1 Then MasterAlienX:=600
                    Else MasterAlienX:=-1;
   End;
   For I:=0 to 19 do If ClearY[I]<>0 Then Begin
    UnshowAlien(ClearX[I],ClearY[I]);
    ClearY[I]:=0;
    ClearX[I]:=0;
   End;
   If Not(MoveAlien)Then Begin
    ClrKbd;
    SetColor(LightRed);
    OutTextXY(300,220,'Vous avez perdu !');
    ReadKey;
    Finish:=True;
    Break;
   End;
   For I:=0 to 19 do If(BallY[I]>0)Then Begin
    PutPixel(BallX[I],BallY[I],Black);
    If BallY[I]>20 Then Begin
     If GetPixel(BallX[I],BallY[I]-5)=Brown Then Begin
      SetColor(Black);
      Line(BallX[I],BallY[I]-5,BallX[I],BallY[I]);
      BallY[I]:=0;
     End
      Else
     Begin
      Dec(BallY[I],5);
      If MasterAlienCollision(BallX[I],BallY[I])Then Begin
       BallY[I]:=0;
       AddScore(AlienScore);
      End
       Else
      If AlienCollision(BallX[I],BallY[I],True)Then Begin
       BallY[I]:=0;
       AddScore(AlienScore);
      End
       Else
      PutPixel(BallX[I],BallY[I],White);
     End;
    End
     Else
    BallY[I]:=0;
   End;
   For I:=0 to 3 do If(AlienBallY[I]<>0)Then Begin
    PutPixel(AlienBallX[I],AlienBallY[I],Black);
    If AlienBallY[I]<=440 Then Begin
     If GetPixel(AlienBallX[I],AlienBallY[I]+5)=Brown Then Begin
      AlienBallX[I]:=0;
      AlienBallY[I]:=0;
     End
      Else
     Begin
      Inc(AlienBallY[I],5);
      If(AlienBallCollision(AlienBallX[I],AlienBallY[I]))Then Begin
       If Lives>0 Then Begin
        Dec(Lives);
        ShowLives;
        SetColor(LightRed);
        OutTextXY(300,220,'Vous avez ‚t‚ touch‚ !');
        ReadKey;
        SetColor(Black);
        OutTextXY(300,220,'Vous avez ‚t‚ touch‚ !');
        SetColor(White);
        FillChar(AlienBallX,SizeOf(AlienBallX),0);
        FillChar(AlienBallY,SizeOf(AlienBallY),0);
        Break;
       End
        Else
       Begin
        ClrKbd;
        SetColor(LightRed);
        OutTextXY(300,220,'Vous avez perdu !');
        ReadKey;
        Finish:=True;
        Break;
       End;
      End
       Else
      PutPixel(AlienBallX[I],AlienBallY[I],LightRed);
     End;
    End
     Else
    Begin
     AlienBallX[I]:=0;
     AlienBallY[I]:=0;
    End;
   End;
   If AlienCount=0 Then Begin
    ClrKbd;
    SetColor(LightGreen);
    OutTextXY(300,220,'Tableau compl‚t‚ !');
    OutTextXY(150,240,'Presse une touche pour acc‚der au niveau suivant...');
    Inc(Lives);
    ReadKey;
    BoardCleared:=True;
   End;
   Delay(200);
  Until(Keypressed)or(BoardCleared);
  Case ReadKey of
   #0:Case ReadKey of
    #75:Begin { Gauche }
     UnshowGunner;
     If GunnerX>0 Then GunnerX:=GunnerX-1;
     ShowGunner;
    End;
    #77:Begin { Droite }
     UnshowGunner;
     If GunnerX<77 Then GunnerX:=GunnerX+1;
     ShowGunner;
    End;
   End;
   #27:Finish:=True;
   #32:Begin
    For I:=0 to 19 do Begin
     If BallY[I]=0 Then Begin
      BallX[I]:=GunnerX*8+12;
      BallY[I]:=439;
      Break;
     End;
    End;
   End;
  End;
  If(BoardCleared)Then Begin
   InitBoard;
  End;
 Until Finish;
END.
