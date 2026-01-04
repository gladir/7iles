{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @first version by: Goupil Brother
  @website(http://goupilbrother.free.fr)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program PIPE;

Uses {$IFDEF FPC}
      Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};

Const MaxX=8;
      MaxLevel=10;

 {0:Tuyau droit 1:Coude}
 Tab:Array[1..MaxLevel,0..MaxX] of String[MaxX+1]=((
   { 001 }
  '         ',
  '         ',
  '000000001',
  '        0',
  '        0',
  '        0',
  '        1',
  '         ',
  '         '
 ),
   { 002 }
 ('         ',
  '         ',
  '00000001 ',
  '       11',
  '        0',
  '        0',
  '        1',
  '         ',
  '         '
 ),
   { 003 }
 ('         ',
  '         ',
  '00001    ',
  '    0    ',
  '    0    ',
  '   11    ',
  '   100000',
  '         ',
  '         '
 ),
   { 004 }
 ('         ',
  '         ',
  '00000001 ',
  '    1001 ',
  '    0    ',
  '    0    ',
  '    0   1',
  '    10001',
  '         '
 ),
   { 005 }
 ('         ',
  '         ',
  '110001   ',
  '11   1001',
  '        0',
  '        0',
  '        1',
  '         ',
  '         '
 ),
   { 006 }
 ('100000001',
  '0       0',
  '1  100001',
  '   0     ',
  '   0     ',
  '   0     ',
  '   100000',
  '         ',
  '         '
 ),
   { 007 }
 ('         ',
  '         ',
  '1        ',
  '0  100001',
  '0  0    0',
  '0  1001 0',
  '0     0 1',
  '0     0  ',
  '1000001  '
 ),
   { 008 }
 ('  101    ',
  '  0 0    ',
  '001 101  ',
  '      0  ',
  '      101',
  '        0',
  '        1',
  '         ',
  '         '
 ),
   { 009 }
 ('100000001',
  '0       0',
  '1       0',
  '0       0',
  '0       0',
  '0       0',
  '0       1',
  '0       0',
  '100000001'
 ),
   { 010 }
 ('   101   ',
  '   0 0   ',
  '1  0 0   ',
  '0  0 0   ',
  '0  0 0   ',
  '0  0 0   ',
  '1001 0 10',
  '     0 0 ',
  '     101 '
 ));


Var
 PipeValue:Array[0..MaxX,0..MaxX]of Byte;
 Won:Array[0..MaxX,0..MaxX]of Boolean;
 Level,XPipe,YPipe:Byte;

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

Procedure ShowLevel(Win:Boolean);
Var
 I,J:Byte;
Begin
  TextColor(1);
  TextBackground(0);
  If Win Then TextBackground(2);
  GotoXY(1,5);
  Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
  GotoXY(MaxX+3,MaxX+1);
  Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
  For I:=0 to MaxX do
  Begin
   For J:=0 to MaxX do
   Begin
    TextColor(1);
    TextBackground(0);
    If (I=XPipe) and (J=YPipe) then TextBackground(2);
    If Win Then
     If Won[I,J] Then
      TextBackground(2)
     Else
      TextBackground(0);
    GotoXY(I+2,J+3);
    Case PipeValue[I,J] of
    0:Write({$IFDEF FPC}'º'{$ELSE}Chr(186){$ENDIF});
    1:Write({$IFDEF FPC}'»'{$ELSE}Chr(187){$ENDIF});
    2:Write({$IFDEF FPC}'¼'{$ELSE}Chr(188){$ENDIF});
    3:Write({$IFDEF FPC}'È'{$ELSE}Chr(200){$ENDIF});
    4:Write({$IFDEF FPC}'É'{$ELSE}Chr(201){$ENDIF});
    5:Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
    End;
   End;
  End;
End;

Function CheckWin:Boolean;
Var
 Good:Boolean;
 Direction, {0:Droite 1:Bas 2:Gauche 3:Haut}
 Value:Byte;
 NextX,NextY,I,J:Integer;
Begin
 CheckWin:=False;
 For I:=0 to MaxX Do
  For J:=0 to MaxX Do
   Won[I,J]:=False;
 NextX:=-1;
 NextY:=2;
 Value:=5;
 Direction:=0;
 Good:=True;
 While Good Do
 Begin
  Case Direction of
   0:Inc(NextX);
   1:Inc(NextY);
   2:Dec(NextX);
   3:Dec(NextY);
  End;
  If (NextX<0) or (NextY<0) or (NextX>MaxX) or (NextY>MaxX) Then Good:=False;
  If Good then
  Begin
   Won[NextX,NextY]:=True;
   Value:=PipeValue[NextX,NextY];
   Case Direction of
    0:Case Value of
       1:Direction:=1;
       2:Direction:=3;
       5:Begin End;
       Else Good:=False;
      End;
    1:Case Value of
       2:Direction:=2;
       3:Direction:=0;
       0:Begin End;
       Else Good:=False;
      End;
    2:Case Value of
       3:Direction:=3;
       4:Direction:=1;
       5:Begin End;
       Else Good:=False;
      End;
    3:Case Value of
       4:Direction:=0;
       1:Direction:=2;
       0:Begin End;
       Else Good:=False;
      End;
   End;
  End;
 End;
 If (NextX=MaxX+1) and (NextY=MaxX-2) Then CheckWin:=True;
End;


Procedure Randomize_Game;
Var
 I,J:Integer;
Begin
 Repeat
  For I:=0 to MaxX do
   For J:=0 to MaxX do
    Case Tab[Level,J][I+1] of
     ' ':PipeValue[I,J]:=Random(6);
     '0':PipeValue[I,J]:=Random(2)*5;
     '1':PipeValue[I,J]:=Random(4)+1;
    End;
 Until not CheckWin;
End;

Procedure Head_Game;
Begin
 TextMode(CO40);
 ClrScr;
 CursorOff;
 GotoXY(8,1);
 Write('Jeu de tuyaux (Pipe Game)');
 GotoXY(10,2);
 Write('Niveau ',Level);
End;

Procedure InitGame;
Var
 I,J:Integer;
Begin
 XPipe:=0;
 YPipe:=0;
 Level:=1;
 Randomize;
End;

Procedure PlayGame;
Var
 K,K2:Char;
 I:Integer;
Begin

 Repeat
  Head_Game;
  Randomize_Game;
  ShowLevel(False);
  Repeat
   Repeat Until Keypressed;
   K:=ReadKey;
   K2:=Char(0);
   Case K of
    ' ':Case PipeValue[XPipe,YPipe] of
         0:PipeValue[XPipe,YPipe]:=5;
         1:PipeValue[XPipe,YPipe]:=2;
         2:PipeValue[XPipe,YPipe]:=3;
         3:PipeValue[XPipe,YPipe]:=4;
         4:PipeValue[XPipe,YPipe]:=1;
         5:PipeValue[XPipe,YPipe]:=0;
        End;
    #0:Begin
        K2:=ReadKey;
        Case K2 of
         #72:If YPipe>0 Then Dec(YPipe);
         #75:If XPipe>0 Then Dec(XPipe);
         #77:If XPipe<MaxX Then Inc(XPipe);
         #80:If YPipe<MaxX Then Inc(YPipe);
        End;
       End;
   End;
   ShowLevel(False);
  Until (K=#27) or ((K=' ') and CheckWin);

  If K<>#27 Then
   Begin
    ShowLevel(True);
    TextColor(7);
    TextBackground(0);
    GotoXY(15,MaxX+5);
    Write('Victoire');
    GotoXY(15,MaxX+6);
    Inc(Level);
    If Level>MaxLevel Then
     Writeln('FIN')
    Else
     Write('Et Maintenant, Niveau ',Level);
    Delay(3000);
   End;

 Until (K=#27) or (Level>MaxLevel);

 GotoXY(15,MaxX+6);
 Write;

End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 InitGame;
 PlayGame;
 CursorOn;
END.

