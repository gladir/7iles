{ @author:      Sylvain Maltais (support@gladir.com)
  @website:     https://www.gladir.com/7iles
  @version:     1.1bis
  @creation:    2026
  @author:      Goupil Brother
  @website:     http://goupilbrother.free.fr
  @target:      Turbo Pascal 7, Free Pascal 3.2
  @description: Creez un chemin entre les deux extremites.
}



{$R+}

Program PIPE;

Uses {$IFDEF FPC}
      Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};


Const MaxX=8;
      MaxLevel=50;

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
 ),
   { 011 }
 ('11       ',
  '001000001',
  '100     0',
  ' 0101   0',
  ' 0  0   0',
  ' 1001   0',
  '        1',
  '         ',
  '         '
 ),
   { 012 }
 ('         ',
  '         ',
  '1  100001',
  '0  100010',
  '0      00',
  '0      00',
  '0      01',
  '0      0 ',
  '10000001 '
 ),
   { 013 }
 ('   1001  ',
  '   0  0  ',
  '0001  0  ',
  '    101  ',
  '10001    ',
  '100000001',
  '        1',
  '         ',
  '         '
 ),
   { 014 }
 (' 1000001 ',
  ' 0     0 ',
  '01     0 ',
  '       11',
  '       11',
  '       0 ',
  '       10',
  '         ',
  '         '
 ),
   { 015 }
 ('         ',
  '         ',
  '0001     ',
  '   0     ',
  '1001     ',
  '100001   ',
  '     1001',
  '         ',
  '         '
 ),
   { 016 }
 (' 100001  ',
  ' 0    0  ',
  '10    0  ',
  '011   0  ',
  '0 0   0  ',
  '101   0  ',
  '      0 1',
  '      0 0',
  '      101'
 ),
   { 017 }
 ('   10001 ',
  '   0   0 ',
  '1  10010 ',
  '0     00 ',
  '0     00 ',
  '0     00 ',
  '0     010',
  '0     0  ',
  '1000001  '
 ),
   { 018 }
 ('         ',
  '         ',
  '1        ',
  '0        ',
  '100000001',
  '100000001',
  '100000000',
  '         ',
  '         '
 ),
   { 019 }
 ('100001   ',
  '1001 0   ',
  '0001 0   ',
  '     0   ',
  '     0   ',
  '     0   ',
  '     0  1',
  '     0  0',
  '     1001'
 ),
   { 020 }
 ('         ',
  '         ',
  '000000001',
  '        0',
  '   100001',
  '   11    ',
  '    11  1',
  '     0  0',
  '     1001'
 ),
   { 021 }
 ('         ',
  '         ',
  '1 101    ',
  '0 0 0    ',
  '0 011    ',
  '0 0101   ',
  '0 0  1000',
  '101      ',
  '         '
 ),
   { 022 }
 ('         ',
  '         ',
  '01       ',
  ' 11      ',
  ' 11      ',
  ' 11      ',
  ' 11     1',
  ' 10000001',
  '         '
 ),
   { 023 }
 ('  10001  ',
  '  0   0  ',
  '1 10010  ',
  '0    00  ',
  '0    00  ',
  '0    00  ',
  '0    0100',
  '0    0   ',
  '100001   '
 ),
   { 024 }
 ('101      ',
  '110      ',
  '010      ',
  '  0 10001',
  '  0 101 0',
  '  0   0 0',
  '  0   0 1',
  '  0   0  ',
  '  10001  '
 ),
   { 025 }
 ('         ',
  '         ',
  '001      ',
  '  0 10001',
  '101 10010',
  '100000010',
  '        1',
  '         ',
  '         '
 ),
   { 026 }
 ('  101    ',
  '  0 0    ',
  '1 0 0    ',
  '0 0 0    ',
  '101 0    ',
  '    0    ',
  ' 10011000',
  ' 0   0   ',
  ' 10001   '
 ),
   { 027 }
 ('         ',
  '         ',
  '00001    ',
  ' 1001101 ',
  '11   0 0 ',
  '100001 0 ',
  '       10',
  '         ',
  '         '
 ),
   { 028 }
 ('1001     ',
  '0  0     ',
  '1  0     ',
  '   0     ',
  '   0     ',
  '1001     ',
  '0   10000',
  '0   0    ',
  '10001    '
 ),
   { 029 }
 ('      101',
  '     11 0',
  '01   0  0',
  '11   0 11',
  '100001 0 ',
  '       0 ',
  '       01',
  '       00',
  '       11'
 ),
   { 030 }
 ('100000001',
  '0       0',
  '1       0',
  '  1000001',
  '  0      ',
  '  0      ',
  '  0     1',
  '  0     0',
  '  1000001'
 ),
   { 031 }
 ('         ',
  '         ',
  '00000001 ',
  ' 11    0 ',
  ' 0100001 ',
  ' 1001    ',
  '    0   1',
  '    0   0',
  '    10001'
 ),
   { 032 }
 ('         ',
  '         ',
  '1        ',
  '0        ',
  '0        ',
  '0        ',
  '11      1',
  ' 0      0',
  ' 10000001'
 ),
   { 033 }
 ('101    11',
  '011    00',
  '10     00',
  ' 0     00',
  ' 0     00',
  ' 0 100010',
  ' 0 101  1',
  ' 0   0   ',
  ' 10001   '
 ),
   { 034 }
 ('100000001',
  '10001   0',
  '00001   0',
  '        0',
  '       11',
  '       0 ',
  '       10',
  '         ',
  '         '
 ),
   { 035 }
 ('         ',
  '         ',
  '01       ',
  '11       ',
  '0    1001',
  '0    0101',
  '0    0010',
  '0    0011',
  '100001101'
 ),
   { 036 }
 (' 11      ',
  ' 00      ',
  '011001   ',
  ' 0   0   ',
  ' 0   1001',
  ' 0      0',
  ' 0      1',
  ' 0      0',
  ' 10000001'
 ),
   { 037 }
 ('         ',
  '         ',
  '1        ',
  '11   0   ',
  ' 0   0   ',
  ' 0   0   ',
  ' 0   1000',
  ' 0   0   ',
  ' 10001   '
 ),
   { 038 }
 ('         ',
  '         ',
  '0001     ',
  '  111    ',
  '  0 0    ',
  '  0 0  11',
  '  0 10011',
  '  0      ',
  '  1000001'
 ),
   { 039 }
 ('         ',
  '         ',
  '000000001',
  '        0',
  '100000001',
  '0        ',
  '100000000',
  '         ',
  '         '
 ),
   { 040 }
 ('     1001',
  '  1111  0',
  '00111   0',
  '        0',
  '        0',
  '        0',
  '        1',
  '         ',
  '         '
 ),
   { 041 }
 ('100001   ',
  '0    0   ',
  '1    0   ',
  '11   0   ',
  '11   0   ',
  '0    0   ',
  '0    1001',
  '0    0   ',
  '100001   '
 ),
   { 042 }
 ('         ',
  '         ',
  '0001     ',
  '   10001 ',
  '     101 ',
  '     0   ',
  '     0  1',
  '     1010',
  '       11'
 ),
   { 043 }
 ('         ',
  '         ',
  '1        ',
  '0        ',
  '0        ',
  '0        ',
  '1001  100',
  '   0  0  ',
  '   1001  '
 ),
   { 044 }
 ('101      ',
  '0 0  1001',
  '1 0  0101',
  '  0  00  ',
  '  0  00  ',
  '  0  00  ',
  '  0  0101',
  '  0  0   ',
  '  1001   '
 ),
   { 045 }
 ('101      ',
  '0 0100001',
  '1 00    0',
  '  00    0',
  '  0010001',
  '10100    ',
  '101010000',
  '1010     ',
  '1001     '
 ),
   { 046 }
 ('100000001',
  '0   11110',
  '1   00000',
  '  1010000',
  '  0  0011',
  '  0  11  ',
  '  0     1',
  '  0     0',
  '  1000001'
 ),
   { 047 }
 ('    1 101',
  '    0 0 0',
  '00001 0 0',
  '    0 0 0',
  '    0 0 0',
  '    0 0 0',
  '10001 0 1',
  '1000001  ',
  '         '
 ),
   { 048 }
 ('  10001  ',
  '  10010  ',
  '1100010  ',
  '11    0  ',
  '      0  ',
  '     11  ',
  '     1000',
  '         ',
  '         '
 ),
   { 049 }
 ('         ',
  '         ',
  '1        ',
  '1001  101',
  '   0  0 0',
  '   0  0 0',
  '   1001 1',
  '         ',
  '         '
 ),
   { 050 }
 ('10001    ',
  '0   0    ',
  '1   0    ',
  '    0    ',
  '    0    ',
  '    0    ',
  '10001 100',
  '0     101',
  '100000001'
 )

 );


Var
 PipeValue:Array[0..MaxX,0..MaxX]of Byte;
 Won,WonFD:Array[0..MaxX,0..MaxX]of Boolean;
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
  GotoXY(1+18-Maxx div 2,5+10-Maxx div 2);
  Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
  GotoXY(MaxX+3+18-Maxx div 2,MaxX+1+10-Maxx div 2);
  Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
  For I:=0 to MaxX do
  Begin
   For J:=0 to MaxX do
   Begin
    TextColor(1);
    TextBackground(0);
    If (I=XPipe) and (J=YPipe) Then TextBackground(2);
    If Win Then
     If Won[I,J] Then
      TextBackground(2)
     Else
      TextBackground(0);
    GotoXY(I+2+18-Maxx div 2,J+3+10-Maxx div 2);
    Case PipeValue[I,J] of
    0:Write({$IFDEF FPC}'º'{$ELSE}Chr(186){$ENDIF});
    1:Write({$IFDEF FPC}'»'{$ELSE}Chr(187){$ENDIF});
    2:Write({$IFDEF FPC}'¼'{$ELSE}Chr(188){$ENDIF});
    3:Write({$IFDEF FPC}'È'{$ELSE}Chr(200){$ENDIF});
    4:Write({$IFDEF FPC}'É'{$ELSE}Chr(201){$ENDIF});
    5:Write({$IFDEF FPC}'Í'{$ELSE}Chr(205){$ENDIF});
    6:Write(' ');
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





Function CheckWin_FreeDir:Boolean;
var proofs:Array[0..MaxX,0..MaxX]of Byte;
    CheckWin_FreeDir2:boolean;


 Procedure Next_FreeDir(X,Y,Direction,{0:Droite 1:Bas 2:Gauche 3:Haut}
                        proof:Integer);
 var value:integer;
     i,j:integer;
 Begin

  If CheckWin_FreeDir2 Then exit Else
   If (x=MaxX+1) and (y=MaxX-2) Then
    Begin
     CheckWin_FreeDir2:=true;
     exit;
    End;

  If Not ((x=-1) And (y=2)) Then
   Begin
    If (X<0) Or (Y<0) Or (X>MaxX) Or (Y>MaxX) Then exit;
    If proofs[x,y]=0 Then
     proofs[x,y]:=proof
    Else exit;
   End;

    value:=5;
    If not ((x=-1) and (y=2)) Then value:=pipevalue[x,y];
    If value=6 Then Exit;

    Case Direction of
     0:case value of {droite}
        0,5:Next_FreeDir(x+1,y,0,proof+1);
        Else Begin
              Next_FreeDir(x,y-1,3,proof+1);
              Next_FreeDir(x,y+1,1,proof+1);
             End;
       end;
     1:case value of {bas}
        0,5:Next_FreeDir(x,y+1,1,proof+1);
        Else Begin
              Next_FreeDir(x-1,y,2,proof+1);
              Next_FreeDir(x+1,y,0,proof+1);
             End;
       end;
     2:case value of {gauche}
        0,5:Next_FreeDir(x-1,y,2,proof+1);
        Else Begin
              Next_FreeDir(x,y-1,3,proof+1);
              Next_FreeDir(x,y+1,1,proof+1);
             End;
       end;
     3:case value of {haut}
        0,5:Next_FreeDir(x,y-1,3,proof+1);
        Else Begin
              Next_FreeDir(x-1,y,2,proof+1);
              Next_FreeDir(x+1,y,0,proof+1);
             End;
       End;
    End;
    If Not ((x=-1) And (y=2)) Then proofs[x,y]:=0;

 End;

Var i,j:integer;

Begin
 CheckWin_FreeDir2:=False;
 For I:=0 to MaxX Do
  For J:=0 to MaxX Do
   proofs[I,J]:=0;
 Next_FreeDir(-1,2,0,0);
 CheckWin_FreeDir:=CheckWin_FreeDir2;
end;


Procedure Generate_FreeDir;
Var
 I,J,K:Integer;
Begin
 Repeat
  For I:=0 to MaxX do
   For J:=0 to MaxX do
    Begin
     K:=Random(7);
     If K>6 Then K:=6;
     PipeValue[I,J]:=K;
    End;
 Until CheckWin_FreeDir;
End;




Procedure Randomize_Game;
Var
 I,J:Integer;
Begin

 If Level<>0 Then
  Repeat
   For I:=0 to MaxX do
    For J:=0 to MaxX do
     Case Tab[Level,J][I+1] of
      ' ':PipeValue[I,J]:=Random(7);
      '0':PipeValue[I,J]:=Random(2)*5;
      '1':PipeValue[I,J]:=Random(4)+1;
     End;
  Until not CheckWin;

End;

Procedure Cadre;
Var I,J:Integer;
Begin
 TextMode(CO40);
 ClrScr;
 CursorOff;
 GotoXY(14,1);
 TextBackground(Red);
 TextColor(Black);
 Write('²±° PIPE °±²');
 GotoXY(18,2);
 TextBackground(Black);
 TextColor(DarkGray);
 Write('    Spc Esk G');
 TextBackground(Black);
 TextColor(DarkGray);
 GotoXY(5,2);
 If Level<>0 Then Write('Level ',Level);

 TextColor(Black);
 TextBackground(Red);
 For I:=-1 To MaxX+1 Do
  For J:=-1 To MaxX+1 Do
  Begin
   Gotoxy(I+2+18-MaxX div 2,J+1+12-MaxX div 2);
   Write(' ');
  End;
End;



Procedure Init_Game;
Begin
 XPipe:=0;
 YPipe:=0;
 Level:=0;
 Randomize;
End;


Procedure Play_Game;
Label GotoLevel;
Var
 K,K2:Char;
 I,code:Integer;
Begin


 Level:=1;


 CursorOff;

 TextBackground(Black);
 TextColor(White);

 Writeln;
 Write('Enter Level (1-50)? ');

 Repeat
  Repeat Until Keypressed;
  K:=ReadKey;
  K2:=Char(0);
  If K=#0 Then K2:=ReadKey;
 Until (K=#27) or (K in ['1','2','3','4','5','6','7','8','9']);

 If K=#27 Then Exit;

 Write(K);Val(K,Level,code);

 Repeat
  Repeat Until Keypressed;
  K:=ReadKey;
  K2:=Char(0);
  If K=#0 Then K2:=ReadKey;
 Until (K=#27) or (K=#13) or (K in ['0','1','2','3','4','5','6','7','8','9']);

 If K=#27 Then Exit;

 If K<>#13 Then
  Begin
   Write(K);
   Val(K,i,code);
   Level:=i+Level*10;
   Repeat
    Repeat Until Keypressed;
    K:=ReadKey;
    K2:=Char(0);
    If K=#0 Then K2:=ReadKey;
   Until (K=#27) or (K=#13);
  End;

 If Level>50 Then Level:=50;

 TextMode(CO40);
GotoLevel:
 Clrscr;
 CursorOff;


  If Level=0 Then Generate_FreeDir;

  Repeat
   Cadre;
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
     'g','G': (* generate level *)
             Begin Level:=0;Goto GotoLevel;End;
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
     GotoXY(16,25);
     TextBackground(Black);
     TextColor(Red);
     Write('Victory ');
     If Level<>0 Then Write(Level,'/',MaxLevel);
     Repeat
      Repeat Until Keypressed;
      K:=ReadKey;
      If K=#0 Then K2:=ReadKey;
     Until (K=#27) Or (K=#13) Or (K=' ');
     If Level<>0 Then Inc(Level);
     If (Level=MaxLevel+1) Or (K=#27) then Exit;
     Goto GotoLevel;
    End;

  Until K=#27;

End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 Init_Game;
 Play_Game;
 Clrscr;
 CursorOn;
END.
