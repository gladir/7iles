{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program DRMARIO;

Uses Crt;

Const
 HomeX=15;
 HomeY=2;

 ColorMicrobeBlue=1;
 ColorMicrobeRed=2;
 ColorMicrobeYellow=3;

 _Vert=0;
 _Hori=1;

Type
 CoordMicro=Record
  X,Y:Byte;
  Color:Byte;
  Present:Boolean;
 End;

Var
 Level:Byte;
 Score,Bar:LongInt;
 PillX,PillY:Byte;
 PillColor:Array[0..1]of Byte;
 PillDir:Byte;
 MicrobeCount:Integer;
 Tbl:Array[0..20,0..9]of Boolean;
 TblColor:Array[0..20,0..9]of Byte;
 MicrobeList:Array[0..20]of CoordMicro;

Procedure SetPillColor(Color:Byte);Begin
 Case Color of
  ColorMicrobeBlue:TextColor(Blue);
  ColorMicrobeRed:TextColor(Red);
  ColorMicrobeYellow:TextColor(Yellow);
 End;
End;

Procedure UpdateMicrobe;Begin
 TextBackground(1+Level);
 TextColor(7);
 GotoXY(4,9);
 Write(MicrobeCount);
 TextBackground(Black);
End;

Function RemoveMicrobe(X,Y:Byte):Boolean;
Var
 I:Integer;
Begin
 RemoveMicrobe:=False;
 For I:=0 to High(MicrobeList)do Begin
  If(MicrobeList[I].X=X)and(MicrobeList[I].Y=Y)and
    (MicrobeList[I].Present)Then Begin
   MicrobeList[I].X:=0;
   MicrobeList[I].Y:=0;
   MicrobeList[I].Present:=False;
   MicrobeList[I].Color:=0;
   RemoveMicrobe:=True;
   Dec(MicrobeCount);
   UpdateMicrobe;
  End;
 End;
End;


Function NewPill:Boolean;Begin
 NewPill:=False;
 PillX:=5;PillY:=0;
 PillDir:=_Hori;
 If Not(Tbl[PillY,PillX])and Not(Tbl[PillY,PillX+1])Then Begin
  PillColor[0]:=1+Random(3);
  PillColor[1]:=1+Random(3);
  NewPill:=True;
 End;
End;

Procedure NewLevel;
Var
 I:Integer;
Begin
 FillChar(Tbl,SizeOf(Tbl),0);
 FillChar(Tbl[20],SizeOf(Tbl[20]),Byte(True));
 FillChar(TblColor,SizeOf(TblColor),0);
 FillChar(MicrobeList,SizeOf(MicrobeList),0);
 MicrobeCount:=0;
 For I:=0 to (Level*3)-1 do Begin
  MicrobeList[I].X:=Random(10);
  MicrobeList[I].Y:=10+Random(10);
  MicrobeList[I].Color:=1+Random(3);
  MicrobeList[I].Present:=True;
  Tbl[MicrobeList[I].Y,MicrobeList[I].X]:=True;
  TblColor[MicrobeList[I].Y,MicrobeList[I].X]:=MicrobeList[I].Color;
  Inc(MicrobeCount);
 End;
 NewPill;
End;

Procedure InitGame;Begin
 Randomize;
 Level:=1;
 Bar:=0;
 Score:=0;
 PillDir:=_Hori;
 NewLevel;
End;

Procedure AddScore(NewScore:Word);
Var
 S:String;
Begin
 TextBackground(1+Level);
 TextColor(7);
 Inc(Score,NewScore);
 Str(Score,S);
 GotoXY(4,6);
 Write(S);
 TextBackground(Black);
End;

Procedure Refresh;
Var
 I,J,K:Integer;
 Microbe:Boolean;
Begin
 TextBackground(1+Level);
 ClrScr;
 GotoXY(3,2);
 Write('Niveau :');
 GotoXY(4,3);
 Write(Level);
 GotoXY(3,5);
 Write('Pointage :');
 AddScore(0);
 TextBackground(1+Level);
 GotoXY(3,8);
 Write('M‚chant :');
 UpdateMicrobe;
 Window(HomeX,HomeY,HomeX+9,HomeY+19);
 TextBackground(Black);
 ClrScr;
 Window(1,1,40,25);
 For J:=0to 19do For I:=0to 9do If Tbl[J,I]Then Begin
  GotoXY(HomeX+I,HomeY+J);
  SetPillColor(TblColor[J,I]);
  TextColor(TblColor[J,I]);
  Microbe:=False;
  For K:=0 to High(MicrobeList)do Begin
   If(J=MicrobeList[K].Y)and(I=MicrobeList[K].X)Then Begin
    Microbe:=True;
    Break;
   End;
  End;
  If(Microbe)Then Write(#1)
             Else Write(#219);
 End;
End;

Procedure SetPill;Begin
 Tbl[PillY,PillX]:=True;
 TblColor[PillY,PillX]:=PillColor[0];
 If(PillDir=_Hori)Then Begin
  Tbl[PillY,PillX+1]:=True;
  TblColor[PillY,PillX+1]:=PillColor[1];
 End
  Else
 Begin
  Tbl[PillY+1,PillX]:=True;
  TblColor[PillY+1,PillX]:=PillColor[1];
 End;
End;

Procedure ShowPill;Begin
 GotoXY(HomeX+PillX,HomeY+PillY);
 If(PillDir=_Hori)Then Begin
  SetPillColor(PillColor[0]);
  Write(#219);
  SetPillColor(PillColor[1]);
  Write(#219);
 End
  Else
 Begin
  SetPillColor(PillColor[0]);
  Write(#219);
  GotoXY(HomeX+PillX,HomeY+PillY+1);
  SetPillColor(PillColor[1]);
  Write(#219);
 End;
End;

Procedure HidePill;Begin
 GotoXY(HomeX+PillX,HomeY+PillY);
 If(PillDir=_Hori)Then Write('  ')
  Else
 Begin
  Write(' ');
  GotoXY(HomeX+PillX,HomeY+PillY+1);
  Write(' ');
 End;
End;

Procedure CheckFullPill;
Var
 I,J,K:Integer;
Begin
  { Recherche horizontale }
 For J:=0 to 19 do Begin
  For I:=0 to 6 do If TblColor[J,I]<>0 Then Begin
   If(TblColor[J,I]=TblColor[J,I+1])and
     (TblColor[J,I]=TblColor[J,I+2])and
     (TblColor[J,I]=TblColor[J,I+3])Then Begin
    Tbl[J,I]:=False;
    TblColor[J,I]:=0;
    RemoveMicrobe(I,J);
    Tbl[J,I+1]:=False;
    TblColor[J,I+1]:=1;
    RemoveMicrobe(I+1,J);
    Tbl[J,I+2]:=False;
    TblColor[J,I+2]:=2;
    RemoveMicrobe(I+2,J);
    Tbl[J,I+3]:=False;
    TblColor[J,I+3]:=3;
    RemoveMicrobe(I+3,J);
    Inc(Bar);
    For K:=0 to 5 do Begin
     If Odd(K)Then TextBackground(0)
              Else TextBackground(7);
     GotoXY(HomeX+I,HomeY+J);
     Write('    ');
     Delay(100);
    End;
    AddScore(25);
   End;
  End;
 End;
  { Recherche verticale }
 For J:=0 to 16 do Begin
  For I:=0 to 9 do If TblColor[J,I]<>0 Then Begin
   If(TblColor[J,I]=TblColor[J+1,I])and
     (TblColor[J,I]=TblColor[J+2,I])and
     (TblColor[J,I]=TblColor[J+3,I])Then Begin
    Tbl[J,I]:=False;
    TblColor[J,I]:=0;
    RemoveMicrobe(I,J);
    Tbl[J+1,I]:=False;
    TblColor[J+1,I]:=1;
    RemoveMicrobe(I,J+1);
    Tbl[J+2,I]:=False;
    TblColor[J+2,I]:=2;
    RemoveMicrobe(I,J+2);
    Tbl[J+3,I]:=False;
    TblColor[J+3,I]:=3;
    RemoveMicrobe(I,J+3);
    Inc(Bar);
    For K:=0 to 5 do Begin
     If Odd(K)Then TextBackground(0)
              Else TextBackground(7);
     GotoXY(HomeX+I,HomeY+J);
     Write(' ');
     GotoXY(HomeX+I,HomeY+J+1);
     Write(' ');
     GotoXY(HomeX+I,HomeY+J+2);
     Write(' ');
     GotoXY(HomeX+I,HomeY+J+3);
     Write(' ');
     Delay(100);
    End;
    AddScore(25);
   End;
  End;
 End;
End;

Function MovePill:Boolean;Begin
 MovePill:=True;
 If PillY<20 Then Begin
  If(PillDir=_Hori)Then Begin
   If Not(Tbl[PillY+1,PillX])and Not(Tbl[PillY+1,PillX+1])Then Begin
    HidePill;
    Inc(PillY);
    ShowPill;
   End
    Else
   Begin
    SetPill;
    CheckFullPill;
    MovePill:=NewPill;
   End;
  End
   Else
  Begin { _Vert }
   If Not(Tbl[PillY+2,PillX])Then Begin
    HidePill;
    Inc(PillY);
    ShowPill;
   End
    Else
   Begin
    SetPill;
    CheckFullPill;
    MovePill:=NewPill;
   End;
  End;
 End
  Else
 Begin
  SetPill;
  CheckFullPill;
  MovePill:=NewPill;
 End;
End;

Procedure Run;
Var
 Terminated:Boolean;
 C:Char;
Begin
 Terminated:=False;
 ShowPill;
 Repeat
  Repeat
   Delay(300);
   If(MovePill)Then Begin
    If MicrobeCount=0 Then Begin
     Inc(Level);
     AddScore(400);
     NewLevel;
     Refresh;
    End;
   End
    Else
   Terminated:=True;
  Until Keypressed;
  C:=ReadKey;
  Case C of
   #0:Case ReadKey of
    #75:Begin { Gauche }
     If PillX>0 Then Begin
      If Not Tbl[PillY,PillX-1]Then Begin
       HidePill;
       Dec(PillX);
       ShowPill;
      End;
     End;
    End;
    #77:Begin { Droite }
     If PillX<9-PillDir Then Begin
      If Not Tbl[PillY,PillX+1+PillDir]Then Begin
       HidePill;
       Inc(PillX);
       ShowPill;
      End;
     End;
    End;
   End;
   #27:Terminated:=True;
   #32,'5':Begin
    If(PillDir=_Hori)Then Begin
     If Not Tbl[PillY+1,PillX]Then Begin
      HidePill;
      PillDir:=_Vert;
      ShowPill;
     End;
    End
     Else
    Begin
     If Not Tbl[PillY,PillX+1]Then Begin
      HidePill;
      PillDir:=_Hori;
      ShowPill;
     End;
    End;
   End;
  End;
 Until Terminated;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 TextMode(CO40);
 InitGame;
 Refresh;
 Run;
END.