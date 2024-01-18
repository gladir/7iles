{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program ASTEROIDS;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 TopY=20;

Var
 Lives,Score:LongInt;
 Finish,North,South,East,West:Boolean;
 ShipAngle:Real;
 ShipX,ShipY:Integer;
 BallX:Array[0..19]of Integer;
 BallY:Array[0..19]of Integer;
 BallDelta:Array[0..19]of Integer;
 BallAngle:Array[0..19]of Real;
 AsteroidX:Array[0..19]of Integer;
 AsteroidY:Array[0..19]of Integer;
 AsteroidDelta:Array[0..19]of Integer;
 AsteroidAngle:Array[0..19]of Real;
 AsteroidRadius:Array[0..19]of Integer;

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

Function FindY(X,Y:Integer):Integer;Begin
 FindY:=ShipY+Round(Y*Sin(ShipAngle)+X*Cos(ShipAngle));
End;

Function FindX(X,Y:Integer):Integer;Begin
 FindX:=ShipX+Round(Y*Cos(ShipAngle)-X*Sin(ShipAngle));
End;

Procedure Ship(Show:Boolean);
Var
 X:Array[0..9]of Integer;
Begin
 FillChar(X,SizeOf(X),0);
 X[0]:=FindX(0,12);
 X[1]:=FindY(0,12);
 X[2]:=FindX(-6,0);
 X[3]:=FindY(-6,0);
 X[4]:=FindX(6,0);
 X[5]:=FindY(6,0);
 X[6]:=X[0];
 X[7]:=X[1];
 If(Show)Then Begin
  SetColor(LightGreen);
  SetFillStyle(SolidFill,Green);
 End
  Else
 Begin
  SetColor(Black);
  SetFillStyle(SolidFill,Black);
 End;
 FillPoly(4,X);
End;

Function FindBallY(Ball,X,Y:Integer):Integer;Begin
 FindBallY:=BallY[Ball]+Round(Y*Sin(BallAngle[Ball])+X*Cos(BallAngle[Ball]));
End;

Function FindBallX(Ball,X,Y:Integer):Integer;Begin
 FindBallX:=BallX[Ball]+Round(Y*Cos(BallAngle[Ball])-X*Sin(BallAngle[Ball]));
End;

Function FindAsteroidY(Asteroid,X,Y:Integer):Integer;Begin
 FindAsteroidY:=AsteroidY[Asteroid]+Round(Y*Sin(AsteroidAngle[Asteroid])+
                X*Cos(AsteroidAngle[Asteroid]));
End;

Function FindAsteroidX(Asteroid,X,Y:Integer):Integer;Begin
 FindAsteroidX:=AsteroidX[Asteroid]+Round(Y*Cos(AsteroidAngle[Asteroid])-
                X*Sin(AsteroidAngle[Asteroid]));
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

Function AsteroidCollision(Asteroid,X,Y:Integer):Boolean;Begin
 AsteroidCollision:=Collision(X-1,Y-1,3,3,
                              AsteroidX[Asteroid]-AsteroidRadius[Asteroid],
                              AsteroidY[Asteroid]-AsteroidRadius[Asteroid],
                              AsteroidRadius[Asteroid] shl 1,
                              AsteroidRadius[Asteroid] shl 1);
End;

Function ShipCollision:Boolean;
Var
 I:Integer;
Begin
 ShipCollision:=False;
 For I:=0 to 19 do Begin
  If Collision(ShipX-6,ShipY-6,12,12,
                          AsteroidX[I]-AsteroidRadius[I],
                          AsteroidY[I]-AsteroidRadius[I],
                          AsteroidRadius[I] shl 1,
                          AsteroidRadius[I] shl 1)Then Begin
   ShipCollision:=True;
   Exit;
  End;
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
 SetFillStyle(SolidFill,Black);
 Bar(0,0,639,19);
 For I:=1 to Lives do Begin
  ShipAngle:=(PI/2)*3;
  ShipX:=I*20;
  ShipY:=10;
  Ship(True);
 End;
End;

Procedure ResetBoard;Begin
 SetColor(Black);
 SetFillStyle(SolidFill,Black);
 Bar(0,TopY,639,479);
 FillChar(BallX,SizeOf(BallX),0);
 FillChar(BallY,SizeOf(BallY),0);
 FillChar(BallDelta,SizeOf(BallDelta),0);
 FillChar(BallAngle,SizeOf(BallAngle),0);
 FillChar(AsteroidX,SizeOf(AsteroidX),0);
 FillChar(AsteroidY,SizeOf(AsteroidY),0);
 FillChar(AsteroidDelta,SizeOf(AsteroidDelta),0);
 FillChar(AsteroidAngle,SizeOf(AsteroidAngle),0);
 FillChar(AsteroidRadius,SizeOf(AsteroidRadius),0);
 AddScore(0);
 ShipX:=320;
 ShipY:=240;
 ShipAngle:=(PI/2)*3;
 Ship(True);
End;

Var
 I,J:Integer;

BEGIN
 InitScr;
 OutTextXY(0,8,'   תת                                              תת       תתת         ');
 OutTextXY(0,16,'   תת              ת                               תת        תת         ');
 OutTextXY(0,24,'  ת תת            תת                                         תת         ');
 OutTextXY(0,32,'  ת תת   תתתת ת תתתתתת    תתתתת תת תתת   תתתתת    תתת    תתת תת  תתתת ת ');
 OutTextXY(0,40,' ת   תת תת   תת   תת     תת   תת תת  תת תת   תת    תת   תת  תתת תת   תת ');
 OutTextXY(0,48,' תתתתתת  תתת      תת     תתתתתתת תת     תת   תת    תת   תת   תת  תתת    ');
 OutTextXY(0,56,'ת     תת   תתת    תת     תת      תת     תת   תת    תת   תת   תת    תתת  ');
 OutTextXY(0,64,'ת     תתתת   תת   תת  ת  תת    ת תת     תת   תת    תת   תת   תת תת   תת ');
 OutTextXY(0,72,'תת   תתתת תתתת     תתת    תתתתת תתתת     תתתתת    תתתת   תתתת תתת תתתת  ');
 ShipX:=100;
 ShipY:=300;
 ShipAngle:=(PI/180)*350;
 Ship(True);
 BallX[0]:=FindX(0,12);
 BallY[0]:=FindY(0,12);
 BallDelta[0]:=12;
 BallAngle[0]:=ShipAngle;
 For I:=0 to 5 do Begin
  Inc(BallDelta[0],5);
  BallX[0]:=FindBallX(0,0,BallDelta[0]);
  BallY[0]:=FindBallY(0,0,BallDelta[0]);
  PutPixel(BallX[0],BallY[0],LightRed);
 End;
 SetColor(White);
 Circle(400,250,25);
 OutTextXY(0,460,'Presse une touche pour jouer...');
 ReadKey;
 ClearDevice;
 Finish:=False;
 Score:=0;
 Lives:=3;
 ShowLives;
 ResetBoard;
 Repeat
  Repeat
   For I:=0 to 19 do Begin
    If AsteroidDelta[I]<>0 Then Begin
     SetColor(Black);
     Circle(AsteroidX[I],AsteroidY[I],AsteroidRadius[I]);
     Inc(AsteroidDelta[I],1);
     AsteroidX[I]:=FindAsteroidX(I,0,AsteroidDelta[I]);
     AsteroidY[I]:=FindAsteroidY(I,0,AsteroidDelta[I]);
     If(AsteroidX[I]<0)or(AsteroidY[I]<0)or(AsteroidX[I]>639)or(AsteroidY[I]>479)Then Begin
      AsteroidX[I]:=0;
      AsteroidY[I]:=0;
      AsteroidDelta[I]:=0;
      SetColor(Black);
      Circle(AsteroidX[I],AsteroidY[I],AsteroidRadius[I]);
     End
      Else
     Begin
      SetColor(White);
      Circle(AsteroidX[I],AsteroidY[I],AsteroidRadius[I]);
     End;
    End;
   End;
   For I:=0 to 19 do Begin
    If AsteroidDelta[I]=0 Then Begin
     AsteroidAngle[I]:=Random*(PI*2);
     AsteroidRadius[I]:=10+Random(3)*5;
     North:=False;South:=False;East:=False;West:=False;
     If AsteroidAngle[I]<PI Then North:=True
                            Else South:=True;
     If(AsteroidAngle[I]>=0.0)and(AsteroidAngle[I]<=PI/2)Then East:=True Else
     If(AsteroidAngle[I]>=2*PI/(3/4))and(AsteroidAngle[I]<=(PI/2))Then East:=True;
     If Not(East)Then West:=True;
     If(North)Then Begin
      AsteroidX[I]:=Random(640);
      AsteroidY[I]:=479;
     End
      Else
     If(East)Then Begin
      AsteroidX[I]:=0;
      AsteroidY[I]:=Random(480);
     End
      Else
     If(West)Then Begin
      AsteroidX[I]:=639;
      AsteroidY[I]:=Random(480);
     End
      Else
     Begin { South }
      AsteroidX[I]:=Random(640);
      AsteroidY[I]:=TopY;
     End;
     AsteroidDelta[I]:=5;
     Break;
    End;
   End;
   For I:=0 to 19 do Begin
    If BallDelta[I]<>0 Then Begin
     PutPixel(BallX[I],BallY[I],Black);
     Inc(BallDelta[I],5);
     BallX[I]:=FindBallX(I,0,BallDelta[I]);
     BallY[I]:=FindBallY(I,0,BallDelta[I]);
     For J:=0 to 19 do Begin
      If AsteroidCollision(J,BallX[I],BallY[I])Then Begin
       SetColor(Black);
       Circle(AsteroidX[J],AsteroidY[J],AsteroidRadius[J]);
       AsteroidX[J]:=0;
       AsteroidY[J]:=0;
       AsteroidDelta[J]:=0;
       AddScore(10);
      End;
     End;
     If(BallX[I]<=0)or(BallY[I]<=TopY)or(BallX[I]>639)or(BallY[I]>479)Then Begin
      BallX[I]:=0;
      BallY[I]:=0;
      BallDelta[I]:=0;
     End
      Else
     Begin
      PutPixel(BallX[I],BallY[I],LightRed);
     End;
    End;
   End;
   If(ShipCollision)Then Begin
    If Lives>0 Then Begin
     Dec(Lives);
     ShowLives;
     SetColor(LightRed);
     OutTextXY(300,220,'Vous avez ‚t‚ touch‚ !');
     ReadKey;
     SetColor(Black);
     OutTextXY(300,220,'Vous avez ‚t‚ touch‚ !');
     SetColor(White);
     ResetBoard;
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
   End;
   Delay(200);
  Until Keypressed;
  Case ReadKey of
   #0:Case ReadKey of
    #75:Begin
     Ship(False);
     ShipAngle:=ShipAngle-(PI/180)*20;
     Ship(True);
    End;
    #77:Begin
     Ship(False);
     ShipAngle:=ShipAngle+(PI/180)*20;
     Ship(True);
    End;
   End;
   #27:Finish:=True;
   #32:Begin
    For I:=0 to 19 do Begin
     If BallDelta[I]=0 Then Begin
      BallX[I]:=FindX(0,12);
      BallY[I]:=FindY(0,12);
      BallDelta[I]:=12;
      BallAngle[I]:=ShipAngle;
      Break;
     End;
    End;
   End;
  End;
  ClrKbd;
 Until Finish;
END.
