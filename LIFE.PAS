{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @first version: Goupil Brother
  @website(http://goupilbrother.free.fr)
  @original concept: John Conway (1937-2020)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description: Une cellule survit si elle a 2 ou 3 voisins.
                Elle peut prendre naissance si elle a 3 voisins
                sinon elle meurt.
}

Program LIFE;

Uses {$IFDEF FPC}
      Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};

Var
 LifeValue,LifeValue2:Array[0..23,0..23] of Byte; {0:dead 1:alive}
 Step,XLife,YLife:Byte;

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

Procedure Body_of_Game;
Var
 I,J:Byte;
Begin

 CursorOff;
 TextBackground(Black);
 TextColor(White);
 GotoXY(8,1);
 Write('Jeu de la Vie (Game of Life)');
  For I:=0 to 23 do
   For J:=0 to 23 do
   Begin
    GotoXY(I+1,J+2);
    TextBackground(Black);
    TextColor(White);
    If LifeValue[I,J]<>0 Then
    Begin
     TextBackground(White);
     TextColor(Black);
    End;
    Write(' ');
   End;
 TextBackground(White);
 TextColor(Black);
 GotoXY(26,6);
 Write('Fleches');
 GotoXY(26,8);
 Write('Espace');
 GotoXY(26,10);
 Write('Entree');
 GotoXY(26,17);
 Write('Echap');
 GotoXY(26,13);
 Write('C');
 GotoXY(26,15);
 Write('R');
 TextBackground(Black);
 TextColor(White);
 GotoXY(27,13);
 Write('lear');
 GotoXY(27,15);
 Write('andom');
 GotoXY(27,11);
 Write('1 cycle');
 GotoXY(XLife+1,YLife+2);

End;

Procedure Life_Cycle;
Var
 I,J,K,L,Voisins:Integer;
Begin

 For I:=0 to 23 do
  For J:=0 to 23 do
   LifeValue2[I,J]:=LifeValue[I,J];

 For I:=0 to 23 do
  For J:=0 to 23 do
   Begin
    Voisins:=0;
    For K:=0 to 2 Do
     For L:=0 to 2 Do
      If not ((K=1) and (L=1)) Then
       If (I+K-1)>=0 Then
       If (I+K-1)<24 Then
       If (J+L-1)>=0 Then
       If (J+L-1)<24 Then
       If LifeValue2[I+K-1,J+L-1]=1 Then
        Inc(Voisins);
    Case Voisins of
     2:Begin End;
     3:LifeValue[I,J]:=1;
     Else LifeValue[I,J]:=0;
    End;
   End;

End;

Procedure Clear_Game;
Var
 I,J:Integer;
Begin
 XLife:=12;
 YLife:=11;
 For I:=0 to 23 do
  For J:=0 to 23 do
   LifeValue[I,J]:=0;
End;

Procedure Random_Game;
Var
 I,J:Integer;
Begin
 XLife:=12;
 YLife:=11;
 For I:=0 to 23 do
  For J:=0 to 23 do
   LifeValue[I,J]:=Random(2);
End;

Procedure Init_Game;
Begin
 TextMode(BW40);
 ClrScr;
 Clear_Game;
End;


Procedure Play_Game;
Var
 K,K2:Char;
 I:Integer;
Begin

 Repeat

  Repeat

   Body_of_Game;
   CursorOn;
   Repeat Until Keypressed;

   K:=ReadKey;
   K2:=Char(0);
   Case K of
    'c','C':Clear_Game;
    'r','R':Random_Game;
    ' ':{Space}
        Case LifeValue[XLife,YLife] of
         0:LifeValue[XLife,YLife]:=1;
         1:LifeValue[XLife,YLife]:=0;
        End;
    #0:Begin
        K2:=ReadKey;
        Case K2 of {Up Left Right Down}
         #72:If YLife>0 Then Dec(YLife);
         #75:If XLife>0 Then Dec(XLife);
         #77:If XLife<23 Then Inc(XLife);
         #80:If YLife<23 Then Inc(YLife);
        End;
       End;
   End;
  Until (K=#27) or (K=#13);

  If K=#13 Then{Enter}
   Begin
    Life_Cycle;
    Body_of_Game;
    K:=#33;K2:=#33;
   End;

 Until K=#27; {Eskape}

End;

Var OrigMode:Integer;

BEGIN
 OrigMode:=LastMode;
 Init_Game;
 Play_Game;
 CursorOff;
 CursorOn;
 TextMode(OrigMode);
END.
