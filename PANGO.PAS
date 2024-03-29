{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program PANGO;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 Tab:Array[1..16,0..10,0..16]of Byte=(
  (($00,$00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00),
   ($01,$01,$00,$01,$01,$01,$00,$03,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$01,$00,$03,$00,$01,$00,$01,$00,$00,$00),
   ($01,$01,$01,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$03,$01,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$01,$00,$00,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$00,$01,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00),
   ($01,$01,$01,$01,$00,$01,$01,$00,$01,$00,$01,$01,$01,$01,$00,$01,$00),
   ($00,$01,$00,$00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$01,$01,$01,$00,$03,$01,$00,$00,$01,$03,$01,$01,$01,$00,$01,$01),
   ($00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$01,$01,$01,$01,$00,$01),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$00,$01,$00,$01,$00,$01),
   ($00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00)),

  (($00,$01,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00),
   ($00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00),
   ($00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$03,$01,$01,$00,$01,$00),
   ($00,$01,$01,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$01,$00,$01,$01,$01,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$03,$00,$01,$00,$01,$01,$01),
   ($00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00)),

  (($01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$00,$00,$00,$00),
   ($01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00),
   ($01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00),
   ($00,$00,$01,$00,$03,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$00,$00),
   ($00,$01,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$01,$01),
   ($00,$00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$01,$01,$01,$00,$01,$00,$01,$00,$01,$03,$01,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$00,$01,$00,$01,$01,$00,$00,$00,$00,$01,$00,$00),
   ($00,$01,$01,$00,$01,$00,$01,$00,$00,$01,$00,$01,$01,$00,$01,$01,$00),
   ($00,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00),
   ($00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00)),

  (($00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00,$01,$00,$00,$01,$01,$01),
   ($00,$03,$01,$01,$00,$01,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00),
   ($01,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00),
   ($01,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00),
   ($01,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$01),
   ($00,$01,$01,$01,$00,$01,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00,$01),
   ($00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00,$01,$00,$01),
   ($00,$01,$01,$01,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00)),

  (($00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$00,$00,$01,$01,$01,$01,$01,$00,$01,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$01,$00,$01,$00,$00,$00,$01,$00,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00),
   ($00,$01,$01,$01,$01,$00,$03,$00,$01,$00,$01,$00,$00,$00,$00,$01,$00),
   ($00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00),
   ($01,$00,$00,$00,$01,$00,$01,$01,$01,$01,$01,$00,$01,$00,$01,$01,$00),
   ($01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$01,$00,$00),
   ($00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$01,$00,$01),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$00,$00,$00,$01,$01,$00,$01),
   ($00,$00,$00,$00,$00,$01,$00,$01,$01,$00,$01,$01,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$01,$00,$00,$00),
   ($00,$01,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$01,$03,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00,$01,$01),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$00,$00,$00,$00,$00,$01,$01,$00,$01,$01,$01,$00,$01,$00),
   ($01,$01,$00,$03,$00,$01,$01,$00,$00,$01,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$00,$01,$00,$00,$01,$00,$00,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$00,$01,$01,$01,$01,$00,$01,$00),
   ($00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$01,$01,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$00,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$01,$01,$01),
   ($01,$01,$00,$03,$01,$01,$03,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$01,$01,$01,$01,$01,$01,$00,$01,$00,$01,$01,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00),
   ($00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$00,$00,$01,$00,$03,$00,$00,$00,$00,$00,$00,$00),
   ($00,$00,$00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$01,$01,$00,$01,$00),
   ($01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00),
   ($00,$00,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$03,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$00),
   ($00,$01,$01,$01,$00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00),
   ($00,$01,$01,$01,$00,$01,$01,$01,$01,$00,$01,$00,$01,$01,$01,$03,$00),
   ($00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$01,$00,$01,$00,$01,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00),
   ($01,$01,$01,$01,$00,$01,$01,$01,$00,$00,$01,$00,$01,$00,$01,$01,$01),
   ($00,$00,$00,$01,$00,$00,$01,$01,$00,$00,$01,$00,$03,$00,$00,$00,$00),
   ($00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$00,$01,$00,$01,$01,$00),
   ($00,$01,$01,$00,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$01,$01,$00,$00,$00,$00,$01,$00,$01,$01,$00,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$01,$00,$01,$01,$01,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00),
   ($00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$01,$01,$01,$01,$01,$03,$00,$01,$00,$01,$00,$00,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$01,$00),
   ($01,$01,$00,$01,$00,$01,$01,$01,$00,$03,$00,$00,$00,$00,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$01,$01),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$01,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01,$01,$01,$01,$00),
   ($00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00)),

  (($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$03,$01,$00,$01,$00,$01,$01,$01,$00),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00),
   ($00,$00,$00,$01,$01,$01,$00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$00),
   ($01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$01,$00,$00,$01,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$00,$01,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$00,$03,$00,$01,$01,$01,$00,$01,$00,$00),
   ($00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01),
   ($00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$01,$01,$00,$00,$00,$01)),

  (($00,$00,$01,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$01,$00),
   ($01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$01,$00,$01,$00),
   ($01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00),
   ($01,$00,$00,$00,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$01,$00),
   ($01,$00,$01,$01,$01,$00,$01,$00,$01,$01,$00,$01,$00,$01,$00,$00,$00),
   ($00,$00,$00,$00,$01,$00,$01,$00,$00,$01,$00,$01,$00,$01,$00,$01,$01),
   ($00,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01),
   ($00,$01,$01,$00,$01,$00,$01,$01,$01,$01,$00,$03,$00,$01,$01,$00,$00),
   ($00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01),
   ($01,$00,$01,$00,$01,$01,$03,$00,$01,$01,$00,$01,$00,$01,$01,$00,$01),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$01)),

  (($00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$00,$00),
   ($00,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$01),
   ($00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01),
   ($01,$00,$01,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$01),
   ($01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$00),
   ($01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01),
   ($00,$00,$00,$00,$03,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01),
   ($00,$01,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$00,$00,$00),
   ($00,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$01,$00),
   ($01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($01,$00,$01,$01,$00,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$00)),

  (($01,$01,$01,$01,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$03,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$01,$01,$01),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00,$00,$00,$00,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$01,$01,$00,$01,$00,$03,$00,$01,$01,$01,$00,$01,$00,$01,$00),
   ($00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($01,$01,$01,$01,$00,$00,$00,$01,$01,$01,$00,$01,$01,$01,$00,$01,$01)),

  (($00,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00),
   ($00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$03,$01,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$00,$00,$01,$01,$01,$01,$01,$00,$01,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$01),
   ($00,$01,$01,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$00,$00),
   ($00,$00,$00,$00,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00,$01,$00),
   ($00,$01,$00,$03,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$01,$00),
   ($00,$01,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$00,$01,$00),
   ($00,$01,$00,$01,$00,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00),
   ($00,$00,$00,$01,$00,$00,$00,$00,$00,$01,$00,$01,$01,$01,$01,$01,$00)));

Type
 DirectionType=(pLeft,pRight,pUp,pDown);

Var
 XPango,YPango,Level:Byte;
 Score,Live:LongInt;
 XBee,YBee:Array[0..10]of ShortInt;
 BeeDirection:Array[0..10]of DirectionType;
 Bee:Integer;
 PangoVertDir,PangoHoriDir:ShortInt;
 CurrTab:Array[0..10,0..16]of Byte;

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

Procedure PutEntity(X,Y:Word;Num:Byte);
Var
 Box:Array[1..8]of PointType;
 Diamand:Array[1..4]of PointType;
Begin
 Case Num of
  $00:Begin
   SetColor(Black);
   SetFillStyle(SolidFill,Black);
   Bar(X,Y,X+23,Y+23);
  End;
  $01:Begin
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Box[1].X:=X;
   Box[1].Y:=Y+3;
   Box[2].X:=X+3;
   Box[2].Y:=Y;
   Box[3].X:=X+18;
   Box[3].Y:=Y;
   Box[4].X:=X+22;
   Box[4].Y:=Y+3;
   Box[5].X:=X+22;
   Box[5].Y:=Y+19;
   Box[6].X:=X+18;
   Box[6].Y:=Y+22;
   Box[7].X:=X+3;
   Box[7].Y:=Y+22;
   Box[8].X:=X;
   Box[8].Y:=Y+18;
   FillPoly(8,Box);
   SetColor(Red);
   SetFillStyle(SolidFill,Red);
   Box[1].X:=X;
   Box[1].Y:=Y+3;
   Box[2].X:=X+3;
   Box[2].Y:=Y;
   Box[3].X:=X+18;
   Box[3].Y:=Y;
   Box[4].X:=X+20;
   Box[4].Y:=Y+2;
   Box[5].X:=X+20;
   Box[5].Y:=Y+20;
   Box[6].X:=X+2;
   Box[6].Y:=Y+20;
   Box[7].X:=X;
   Box[7].Y:=Y+18;
   FillPoly(7,Box);
   SetColor(Yellow);
   Line(X+10-2,Y+10,X+10+2,Y+10);
   Line(X+10,Y+10-2,X+10,Y+10+2);
  End;
  $03:Begin { Diamant }
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Box[1].X:=X;
   Box[1].Y:=Y+3;
   Box[2].X:=X+3;
   Box[2].Y:=Y;
   Box[3].X:=X+18;
   Box[3].Y:=Y;
   Box[4].X:=X+22;
   Box[4].Y:=Y+3;
   Box[5].X:=X+22;
   Box[5].Y:=Y+19;
   Box[6].X:=X+18;
   Box[6].Y:=Y+22;
   Box[7].X:=X+3;
   Box[7].Y:=Y+22;
   Box[8].X:=X;
   Box[8].Y:=Y+18;
   FillPoly(8,Box);
   SetFillStyle(SolidFill,Red);
   Bar(X,Y,X+20,Y+20);
   SetFillStyle(SolidFill,Yellow);
   Diamand[1].X:=X+10;
   Diamand[1].Y:=Y;
   Diamand[2].X:=X+20;
   Diamand[2].Y:=Y+10;
   Diamand[3].X:=X+10;
   Diamand[3].Y:=Y+20;
   Diamand[4].X:=X;
   Diamand[4].Y:=Y+10;
   FillPoly(4,Diamand);
  End;
  $80:Begin { Pinguouin }
   SetColor(Green);
   SetFillStyle(SolidFill,Green);
   Box[1].X:=X+5;
   Box[1].Y:=Y+7;
   Box[2].X:=X+8;
   Box[2].Y:=Y+4;
   Box[3].X:=X+13;
   Box[3].Y:=Y+4;
   Box[4].X:=X+17;
   Box[4].Y:=Y+7;
   Box[5].X:=X+17;
   Box[5].Y:=Y+15;
   Box[6].X:=X+13;
   Box[6].Y:=Y+18;
   Box[7].X:=X+8;
   Box[7].Y:=Y+18;
   Box[8].X:=X+5;
   Box[8].Y:=Y+14;
   FillPoly(8,Box);
   SetFillStyle(SolidFill,Yellow);
   Bar(X+12,Y+8,X+14,Y+10);
   PutPixel(X+13,Y+9,0);
   Box[1].X:=X+10;
   Box[1].Y:=Y+14;
   Box[2].X:=X+10;
   Box[2].Y:=Y+20;
   Box[3].X:=X+14;
   Box[3].Y:=Y+20;
   Box[4].X:=X+14;
   Box[4].Y:=Y+18;
   Box[5].X:=X+12;
   Box[5].Y:=Y+18;
   Box[6].X:=X+12;
   Box[6].Y:=Y+14;
   FillPoly(6,Box);
  End;
  $90:Begin { Bee }
   SetColor(Yellow);
   SetFillStyle(SolidFill,Yellow);
   Box[1].X:=X+2;
   Box[1].Y:=Y+7;
   Box[2].X:=X+7;
   Box[2].Y:=Y+2;
   Box[3].X:=X+14;
   Box[3].Y:=Y+2;
   Box[4].X:=X+19;
   Box[4].Y:=Y+7;
   Box[5].X:=X+19;
   Box[5].Y:=Y+14;
   Box[6].X:=X+14;
   Box[6].Y:=Y+19;
   Box[7].X:=X+7;
   Box[7].Y:=Y+19;
   Box[8].X:=X+2;
   Box[8].Y:=Y+14;
   FillPoly(8,Box);
   SetColor(LightGreen);
   SetFillStyle(SolidFill,LightGreen);
   Bar(X+7,Y+7,X+9,Y+9);
   PutPixel(X+8,Y+8,0);
   PutPixel(X+7,Y+9,0);
   PutPixel(X+8,Y+9,0);
   Bar(X+12,Y+7,X+14,Y+9);
   PutPixel(X+13,Y+8,0);
   PutPixel(X+14,Y+9,0);
   PutPixel(X+13,Y+9,0);
  End;
 End;
End;

Procedure UnshowPango;Begin
 PutEntity(100+XPango*24,32+YPango*24,$00);
End;

Procedure ShowPango;Begin
 PutEntity(100+XPango*24,32+YPango*24,$80);
End;

Procedure UnshowBee(I:Byte);Begin
 PutEntity(100+XBee[I]*24,32+YBee[I]*24,$00);
End;

Procedure ShowBee(I:Byte);Begin
 PutEntity(100+XBee[I]*24,32+YBee[I]*24,$90);
End;

Procedure ShowBees;
Var
 I:Integer;
Begin
 For I:=1 to 5 do Begin
  If(I<=Bee)Then PutEntity(50,315-I*24,$90)
            Else PutEntity(50,315-I*24,0);
 End;
End;

Procedure AddScore(X:Integer);Begin
 SetColor(Black);
 OutTextXY(540,0,'Pointage : ');
 OutTextXY(548,8,LongToStr(Score));
 Score:=Score+X;
 SetColor(Yellow);
 OutTextXY(540,0,'Pointage : ');
 OutTextXY(548,8,LongToStr(Score));
End;

Procedure DeleteBee(X,Y:Integer);
Var
 I:Integer;
Begin
 For I:=0 to 10 do If(X=XBee[I])and(Y=YBee[I])Then Begin
  CurrTab[Y,X]:=0;
  XBee[I]:=-1;
  YBee[I]:=-1;
  Dec(Bee);
  AddScore(400);
  ShowBees;
 End;
End;

Function AvailableLeft(X,Y:Byte):Boolean;Begin
 If X>0 Then AvailableLeft:=CurrTab[Y,X-1]=0
        Else AvailableLeft:=False;
End;

Function AvailableRight(X,Y:Byte):Boolean;Begin
 If X<16 Then AvailableRight:=CurrTab[Y,X+1]=0
         Else AvailableRight:=False;
End;

Function AvailableUp(X,Y:Byte):Boolean;Begin
 If Y>0 Then AvailableUp:=CurrTab[Y-1,X]=0
        Else AvailableUp:=False;
End;

Function AvailableDown(X,Y:Byte):Boolean;Begin
 If Y<10 Then AvailableDown:=CurrTab[Y+1,X]=0
         Else AvailableDown:=False;
End;

Procedure FindDirection(I:Byte);Begin
 If XPango<XBee[I] Then Begin
  If AvailableLeft(XBee[I],YBee[I])Then BeeDirection[I]:=pLeft
   Else
  Begin
   If YPango<YBee[I] Then Begin
    If AvailableUp(XBee[I],YBee[I])Then BeeDirection[I]:=pUp Else
    If AvailableDown(XBee[I],YBee[I])Then BeeDirection[I]:=pDown Else
    If(BeeDirection[I]=pRight)Then BeeDirection[I]:=pLeft
                              Else BeeDirection[I]:=pRight
   End
    Else
   If BeeDirection[I]=pUp Then BeeDirection[I]:=pDown Else
   If BeeDirection[I]=pDown Then BeeDirection[I]:=pUp Else
   If BeeDirection[I]=pLeft Then BeeDirection[I]:=pRight
                            Else BeeDirection[I]:=pLeft;
  End;
 End
  Else
 If XPango>XBee[I] Then Begin
  If AvailableRight(XBee[I],YBee[I])Then BeeDirection[I]:=pRight
   Else
  Begin
   If YPango<YBee[I] Then Begin
    If AvailableUp(XBee[I],YBee[I])Then BeeDirection[I]:=pUp Else
    If AvailableDown(XBee[I],YBee[I])Then BeeDirection[I]:=pDown Else
    If(BeeDirection[I]=pLeft)Then BeeDirection[I]:=pRight
                             Else BeeDirection[I]:=pLeft;
   End
    Else
   If BeeDirection[I]=pUp Then BeeDirection[I]:=pDown Else
   If BeeDirection[I]=pDown Then BeeDirection[I]:=pUp Else
   If BeeDirection[I]=pLeft Then BeeDirection[I]:=pRight
                            Else BeeDirection[I]:=pLeft;
  End;
 End
  Else
 If YPango<YBee[I] Then Begin
  If AvailableUp(XBee[I],YBee[I])Then BeeDirection[I]:=pUp
   Else
  Begin
   If XPango<XBee[I] Then Begin
    If AvailableLeft(XBee[I],YBee[I])Then BeeDirection[I]:=pLeft Else
    If AvailableRight(XBee[I],YBee[I])Then BeeDirection[I]:=pRight Else
    If(BeeDirection[I]=pDown)Then BeeDirection[I]:=pUp
                             Else BeeDirection[I]:=pDown;
   End
    Else
   If BeeDirection[I]=pUp Then BeeDirection[I]:=pDown Else
   If BeeDirection[I]=pDown Then BeeDirection[I]:=pUp Else
   If BeeDirection[I]=pLeft Then BeeDirection[I]:=pRight Else
   If(BeeDirection[I]=pLeft)Then BeeDirection[I]:=pRight
                            Else BeeDirection[I]:=pLeft;
  End;
 End
  Else
 Begin
  If AvailableDown(XBee[I],YBee[I])Then BeeDirection[I]:=pDown
   Else
  Begin
   If XPango<XBee[I] Then Begin
    If AvailableLeft(XBee[I],YBee[I])Then BeeDirection[I]:=pLeft Else
    If AvailableRight(XBee[I],YBee[I])Then BeeDirection[I]:=pRight Else
    If(BeeDirection[I]=pUp)Then BeeDirection[I]:=pDown
                           Else BeeDirection[I]:=pUp;
   End
    Else
   If BeeDirection[I]=pUp Then BeeDirection[I]:=pDown Else
   If BeeDirection[I]=pDown Then BeeDirection[I]:=pUp Else
   If BeeDirection[I]=pLeft Then BeeDirection[I]:=pRight
                            Else BeeDirection[I]:=pLeft;
  End;
 End;
End;

Procedure ShowLives;
Var
 I:Integer;
Begin
 For I:=1 to 10 do Begin
  If(I<=Live)Then PutEntity(50,16+I*24,$80)
             Else PutEntity(50,16+I*24,0);
 End;
End;

Procedure ShowLevel(X:Integer);Begin
 SetColor(Black);
 OutTextXY(540,40,'Niveau : ');
 OutTextXY(548,48,LongToStr(Level));
 Level:=Level+X;
 SetColor(Yellow);
 OutTextXY(540,40,'Niveau : ');
 OutTextXY(548,48,LongToStr(Level));
End;

Procedure InitData;Begin
 Move(Tab[Level,0,0],CurrTab,SizeOf(CurrTab));
 XPango:=8;
 YPango:=5;
 PangoHoriDir:=1;
 PangoVertDir:=1;
 CurrTab[1,16]:=$90;
 XBee[0]:=16;
 YBee[0]:=1;
 BeeDirection[0]:=pLeft;
 FindDirection(0);
 CurrTab[10,3]:=$90;
 XBee[1]:=3;
 YBee[1]:=10;
 BeeDirection[0]:=pDown;
 FindDirection(1);
End;

Procedure DisplayNewBoard;
Var
 I,J:Integer;
Begin
 For J:=0 to 10 do For I:=0 to 16 do Begin
  PutEntity(100+I*24,32+J*24,CurrTab[J,I]);
 End;
 ShowPango;
End;

Procedure InitGame;
Var
 I,J:Integer;
Begin
 Score:=0;
 Level:=1;
 Bee:=2;
 Live:=3;
 FillChar(XBee,SizeOf(XBee),$FF);
 FillChar(YBee,SizeOf(YBee),$FF);
 InitData;
 For I:=76 to 530 do Begin
  If I and 1=1 Then SetColor(Yellow)
               Else SetColor(LightGreen);
  Line(I,0,I,31);
  Line(I,296,I,315);
 End;
 For I:=76 to 98 do Begin
  If I and 1=1 Then SetColor(Yellow)
               Else SetColor(LightGreen);
  Line(I,32,I,295);
 End;
 For I:=508 to 530 do Begin
  If I and 1=1 Then SetColor(Yellow)
               Else SetColor(LightGreen);
  Line(I,32,I,295);
 End;
 AddScore(0);
 ShowLevel(0);
 ShowLives;
 ShowBees;
 DisplayNewBoard;
End;

Procedure PlayGame;
Var
 Terminated:Boolean;
 I,J:Integer;
 CellValue:Byte;
Begin
 Terminated:=False;
 Repeat
  Repeat
   For I:=0 to 10 do Begin
    If XBee[I]<>-1 Then Case BeeDirection[I] of
     pLeft:If AvailableLeft(XBee[I],YBee[I])Then Begin
      UnshowBee(I);
      CurrTab[YBee[I],XBee[I]]:=0;
      XBee[I]:=XBee[I]-1;
      CurrTab[YBee[I],XBee[I]]:=$90;
      ShowBee(I);
     End
      Else
     FindDirection(I);
     pRight:If AvailableRight(XBee[I],YBee[I])Then Begin
      UnshowBee(I);
      CurrTab[YBee[I],XBee[I]]:=0;
      XBee[I]:=XBee[I]+1;
      CurrTab[YBee[I],XBee[I]]:=$90;
      ShowBee(I);
     End
      Else
     FindDirection(I);
     pUp:If AvailableUp(XBee[I],YBee[I])Then Begin
      UnshowBee(I);
      CurrTab[YBee[I],XBee[I]]:=0;
      YBee[I]:=YBee[I]-1;
      CurrTab[YBee[I],XBee[I]]:=$90;
      ShowBee(I);
     End
      Else
     FindDirection(I);
     pDown:If AvailableDown(XBee[I],YBee[I])Then Begin
      UnshowBee(I);
      CurrTab[YBee[I],XBee[I]]:=0;
      YBee[I]:=YBee[I]+1;
      CurrTab[YBee[I],XBee[I]]:=$90;
      ShowBee(I);
     End
      Else
     FindDirection(I);
    End;
    If((XBee[I]-1=XPango)and(YBee[I]=YPango))or
      ((XBee[I]+1=XPango)and(YBee[I]=YPango))or
      ((XBee[I]=XPango)and(YBee[I]-1=YPango))or
      ((XBee[I]=XPango)and(YBee[I]+1=YPango))or
      ((XBee[I]=XPango)and(YBee[I]=YPango))Then Begin
     If Live=1Then Begin
      ClrKbd;
      SetColor(LightRed);
      OutTextXY(300,220,'PARTIE TERMINER !');
      ReadKey;
      Exit;
     End
      Else
     Begin
      ClrKbd;
      Dec(Live);
      ShowLives;
      SetColor(LightRed);
      OutTextXY(300,220,'Vous avez ‚t‚ attrap‚ !');
      ReadKey;
      SetColor(Black);
      OutTextXY(300,220,'Vous avez ‚t‚ attrap‚ !');
      SetColor(White);
      InitData;
      DisplayNewBoard;
     End;
    End;
   End;
   Delay(250);
  Until Keypressed;
  Case ReadKey of
   #0:Case ReadKey of
    #72:Begin { Haut }
     PangoVertDir:=-1;
     If YPango>0 Then Begin
      If CurrTab[YPango-1,XPango]=0 Then Begin
       UnshowPango;
       YPango:=YPango-1;
       ShowPango;
      End
       Else
      PangoHoriDir:=0;
     End
      Else
     PangoHoriDir:=0;
    End;
    #75:Begin { Gauche }
     PangoHoriDir:=-1;
     If XPango>0 Then Begin
      If CurrTab[YPango,XPango-1]=0 Then Begin
       UnshowPango;
       XPango:=XPango-1;
       ShowPango;
      End
       Else
      PangoVertDir:=0;
     End
      Else
     PangoVertDir:=0;
    End;
    #77:Begin { Droite }
     PangoHoriDir:=1;
     If XPango<16 Then Begin
      If CurrTab[YPango,XPango+1]=0 Then Begin
       UnshowPango;
       XPango:=XPango+1;
       ShowPango;
      End
       Else
      PangoVertDir:=0;
     End
      Else
     PangoVertDir:=0;
    End;
    #80:Begin { Bas }
     PangoVertDir:=1;
     If YPango<10 Then Begin
      If CurrTab[YPango+1,XPango]=0 Then Begin
       UnshowPango;
       YPango:=YPango+1;
       ShowPango;
      End
       Else
      PangoHoriDir:=0;
     End
      Else
     PangoHoriDir:=0;
    End;
   End;
   #27:Terminated:=True;
   #32:Begin { Barre d'espacement }
    If(PangoVertDir<>0)and(YPango+PangoVertDir>=0)and
    (YPango+PangoVertDir<=10)and(CurrTab[YPango+PangoVertDir,XPango]<>0)Then Begin
     If PangoVertDir>0 Then Begin
      CellValue:=CurrTab[YPango+PangoVertDir,XPango];
      For J:=YPango+PangoVertDir to 10-1 do Begin
       If CurrTab[J+1,XPango]=$90 Then DeleteBee(XPango,J+1);
       If CurrTab[J+1,XPango]<>0 Then Break;
       PutEntity(100+XPango*24,32+J*24,0);
       CurrTab[J,XPango]:=0;
       CurrTab[J+1,XPango]:=CellValue;
       PutEntity(100+XPango*24,32+(J+1)*24,CellValue);
       Delay(100);
      End;
     End
      Else
     Begin
      CellValue:=CurrTab[YPango+PangoVertDir,XPango];
      For J:=YPango+PangoVertDir downto 0+1 do Begin
       If CurrTab[J-1,XPango]=$90 Then DeleteBee(XPango,J-1);
       If CurrTab[J-1,XPango]<>0 Then Break;
       PutEntity(100+XPango*24,32+J*24,0);
       CurrTab[J,XPango]:=0;
       CurrTab[J-1,XPango]:=CellValue;
       PutEntity(100+XPango*24,32+(J-1)*24,CellValue);
       Delay(100);
      End;
     End;
    End
     Else
    If(PangoHoriDir<>0)and(XPango+PangoHoriDir>=0)and
      (XPango+PangoHoriDir<=16)and(CurrTab[YPango,XPango+PangoHoriDir]<>0)Then Begin
     If PangoHoriDir>0 Then Begin
      CellValue:=CurrTab[YPango,XPango+PangoHoriDir];
      For I:=XPango+PangoHoriDir to 16-1 do Begin
       If CurrTab[YPango,I+1]=$90 Then DeleteBee(I+1,YPango);
       If CurrTab[YPango,I+1]<>0 Then Break;
       PutEntity(100+I*24,32+YPango*24,0);
       CurrTab[YPango,I]:=0;
       CurrTab[YPango,I+1]:=CellValue;
       PutEntity(100+(I+1)*24,32+YPango*24,CellValue);
       Delay(100);
      End;
     End
      Else
     Begin
      CellValue:=CurrTab[YPango,XPango+PangoHoriDir];
      For I:=XPango+PangoHoriDir downto 0+1 do Begin
       If CurrTab[YPango,I-1]=$90 Then DeleteBee(I-1,YPango);
       If CurrTab[YPango,I-1]<>0 Then Break;
       PutEntity(100+I*24,32+YPango*24,0);
       CurrTab[YPango,I]:=0;
       CurrTab[YPango,I-1]:=CellValue;
       PutEntity(100+(I-1)*24,32+YPango*24,CellValue);
       Delay(100);
      End;
     End;
    End;
   End;
  End;
  If Bee<=0 Then Begin
   If Level<16 Then Begin
    ClrKbd;
    ShowLevel(1);
    Bee:=2;
    ShowBees;
    InitData;
    DisplayNewBoard;
    ReadKey;
   End;
  End;
 Until Terminated;
End;

BEGIN
 InitScr;
 InitGame;
 PlayGame;
END.
