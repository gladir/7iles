{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Cannonball;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 g=-9.81;
 x0=0;
 v0=50;
 dt=0.1;
 StartX=200;

Var
 Phi:Integer;
 Ok,Finish:Boolean;
 HumanSaved,HumanDead:Integer;
 K:Char;
 TabX:Integer;
 T:real;
 XB,PX,PY,XT,YT,V,Y0:Integer;

Function IntToStr(V:Integer):String;
Var
 S:String;
Begin
 Str(V,S);
 IntToStr:=S;
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

Procedure UnshowTab;Begin
 SetColor(Blue);
 SetFillStyle(SolidFill,Blue);
 Bar(TabX-10,396,TabX+10,399);
End;

Procedure ShowTab;Begin
 SetColor(White);
 SetFillStyle(SolidFill,White);
 Bar(TabX-10,396,TabX+10,399);
End;

Procedure ShowHumanSaved;Begin
 SetColor(Blue);
 OutTextXY(100,2,'Humain sauvÇ : '+#219+#219+#219);
 OutTextXY(250,2,'Humain ÇcrasÇ : '+#219+#219+#219);
 SetColor(Brown);
 OutTextXY(100,2,'Humain sauvÇ : '+IntToStr(HumanSaved));
 OutTextXY(250,2,'Humain ÇcrasÇ : '+IntToStr(HumanDead));
End;

Procedure UnshowPipe;
Var
 Angle:Real;
 X1,Y1,XMove,YMove:Integer;
Begin
 Angle:=(360-Phi)*0.017453292520;
 X1:=Trunc(Cos(Angle)*51);
 Y1:=Trunc(Sin(Angle)*51);
 XMove:=Trunc(Cos(Angle)*135);
 YMove:=Trunc(Sin(Angle)*135);
 SetFillStyle(SolidFill,Blue);
 Bar(115+X1,398+Y1,115+XMove,398+YMove);
End;

Procedure ShowPipe;
Var
 Angle:Real;
 XMove,YMove:Integer;
Begin
 Angle:=(360-Phi)*0.017453292520;
 XMove:=Trunc(Cos(Angle)*130);
 YMove:=Trunc(Sin(Angle)*130);
 SetColor(Brown);
 SetLineStyle(SolidLn,0,ThickWidth);
 Line(115,398,115+XMove,398+YMove);
 SetLineStyle(SolidLn,0,NormWidth);
 XB:=115+XMove;
 Y0:=Abs(YMove);
End;

Procedure ShowCannon;Begin
 SetColor(Brown);
 SetFillStyle(SolidFill,Brown);
 FillEllipse(115,398,50,50);
 ShowPipe;
End;

Procedure ShowAngle;Begin
 SetFillStyle(SolidFill,Blue);
 Bar(100,20,250,29);
 OutTextXY(100,20,'Angle : '+IntToStr(Phi)+#248);
End;

Procedure ShowMessage(Msg:String);Begin
 SetFillStyle(SolidFill,Green);
 Bar(0,420,639,440);
 SetColor(Black);
 OutTextXY(0,420,Msg);
End;

Function Rad(Alpha:Integer):Real;Begin
 Rad:=(alpha/180)*pi;
End;

BEGIN
 HumanSaved:=0;
 HumanDead:=0;
 XB:=0;
 y0:=100;
 Finish:=False;
 InitScr;
  { PrÇsentation }
 SetColor(Brown);
 OutTextXY(0,20,'                                                                                ');
 OutTextXY(0,30,'  ˛˛˛  ˛                                           ˛˛              ˛˛      ˛˛   ');
 OutTextXY(0,40,' ˛   ˛˛                                           ˛ ˛             ˛ ˛     ˛ ˛   ');
 OutTextXY(0,50,'˛   ˛  ˛                                          ˛ ˛             ˛ ˛     ˛ ˛   ');
 OutTextXY(0,60,'˛    ˛˛                                           ˛ ˛             ˛ ˛     ˛ ˛   ');
 OutTextXY(0,70,'˛                                                 ˛ ˛             ˛˛      ˛˛    ');
 OutTextXY(0,80,'˛         ˛˛˛˛   ˛ ˛˛˛   ˛ ˛˛˛    ˛˛˛˛   ˛ ˛˛˛    ˛˛      ˛˛˛˛    ˛       ˛     ');
 OutTextXY(0,90,'˛        ˛    ˛  ˛˛   ˛  ˛˛   ˛  ˛  ˛ ˛  ˛˛   ˛   ˛  ˛   ˛    ˛   ˛       ˛     ');
 OutTextXY(0,100,'˛       ˛     ˛  ˛    ˛  ˛    ˛ ˛    ˛ ˛ ˛    ˛  ˛˛  ˛˛ ˛     ˛  ˛˛      ˛˛     ');
 OutTextXY(0,110,'˛       ˛     ˛ ˛˛    ˛ ˛˛    ˛ ˛     ˛˛˛˛    ˛ ˛ ˛  ˛ ˛˛     ˛ ˛ ˛     ˛ ˛     ');
 OutTextXY(0,120,' ˛     ˛˛    ˛˛˛ ˛    ˛˛ ˛    ˛˛˛     ˛  ˛    ˛˛  ˛  ˛  ˛    ˛˛˛  ˛    ˛  ˛    ˛');
 OutTextXY(0,130,'  ˛˛˛˛˛  ˛˛˛˛ ˛  ˛    ˛  ˛    ˛  ˛˛˛˛˛   ˛    ˛    ˛˛    ˛˛˛˛ ˛    ˛˛˛˛    ˛˛˛˛ ');
 Phi:=40+Random(20);
 PX:=0; PY:=0;
 T:=0; V:=V0; YT:=1;
 TabX:=400;
 ShowCannon;
 SetFillStyle(SolidFill,Black);
 Bar(0,400,639,479);
 While (Not Finish)and(yt>=0) do Begin
  XT:=X0+Round(v0*Cos(Rad(phi))*t);
  YT:=Y0+Round(v*Sin(Rad(phi))*t+0.5*g*t*t);
  PutPixel(XB+XT,398-YT,White);
  PX:=xt; PY:=YT;
  t:=t+dt;
 End;
 SetColor(Yellow);
 OutTextXY(120,440,'Presse une touche pour commencer Ö jouer...');
 ReadKey;
  { Jouer }
 Repeat
  Phi:=40+Random(20);
  PX:=0; PY:=0;
  T:=0; V:=V0; YT:=1;
  TabX:=400;
  SetFillStyle(SolidFill,Blue);
  Bar(0,0,639,399);
  ShowCannon;
  SetFillStyle(SolidFill,Green);
  Bar(0,400,639,479);
  SetColor(Brown);
  ShowAngle;
  OutTextXY(100,30,'MPH : '+IntToStr(Trunc(dt*250)));
  ShowHumanSaved;
  ShowTab;
  ShowMessage('Utiliser les fläches pour aligner le canon ou '+
             '<ESPACE> pour commencer la partie');
  Ok:=False;
  Repeat
   K:=ReadKey;
   Case K of
    #0:Case ReadKey of
     #75:Begin { Gauche }
      UnshowPipe;
      If Phi<80 Then Phi:=Phi+1;
      ShowPipe;
      ShowAngle;
     End;
     #77:Begin { Droite }
      UnshowPipe;
      If Phi>10 Then Phi:=Phi-1;
      ShowPipe;
      ShowAngle;
     End;
    End;
    ' ':Ok:=True;
    #27:Begin
     Ok:=True;
     Finish:=True;
    End;
   End;
  Until Ok;
  ShowMessage('Utiliser les fläches pour aligner attraper la '+
              'l''humain avec le filet.');
  While (Not Finish)and(yt>=0) do Begin
  If(Keypressed)Then Begin
    K:=ReadKey;
    Case(K)of
     #0:Case ReadKey of
      #75:Begin { Gauche }
       UnshowTab;
       If TabX>250 Then TabX:=TabX-4;
       ShowTab;
      End;
      #77:Begin { Droite }
       UnshowTab;
       If TabX<620 Then TabX:=TabX+4;
       ShowTab;
      End;
     End;
     #27:Finish:=True;
    End;
   End;
   Delay(100);
   PutPixel(XB+PX,398-PY,Blue);
   XT:=X0+Round(v0*Cos(Rad(phi))*t);
   YT:=Y0+Round(v*Sin(Rad(phi))*t+0.5*g*t*t);
   PutPixel(XB+XT,398-YT,White);
   PX:=xt; PY:=YT;
   t:=t+dt;
  End;
  If Not(Finish)Then Begin
   If(XB+XT>=TabX-10)and(XB+XT<=TabX+10)Then Begin
    Inc(HumanSaved);
    ShowHumanSaved;
    ShowMessage('L''humain a ÇtÇ attraper !');
   End
    Else
   Begin
    Inc(HumanDead);
    ShowHumanSaved;
    ShowMessage('DÇsolÇ, l''humain s''est ÇcrasÇ !');
   End;
   If ReadKey=#27 Then Finish:=True;
  End;
 Until Finish;
 TextMode(LastMode);
END.