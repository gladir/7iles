{ @author: Sylvain Maltais (support@gladir.com)
  @website(https://www.gladir.com/7iles)
  @version: 1.1
  @creation: 2026
  @first version by: Goupil Brother
  @website(http://goupilbrother.free.fr)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program PIPE;

{$R-}

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
    If (I=XPipe) and (J=YPipe) Then TextBackground(2);
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

Procedure Show_Head;
Begin
 TextMode(CO40);
 ClrScr;
 CursorOff;
 GotoXY(8,1);
 Write('Jeu de tuyaux (Pipe Game)');
End;

Procedure Show_Head_Level;
Begin
 GotoXY(10,2);
 Write('Niveau ',Level);
End;

Procedure Init_Game;
Begin
 XPipe:=0;
 YPipe:=0;
 Level:=0;
 Randomize;
End;

Procedure Generate_FreeDir;
Var
 I,J:Integer;
Begin
 Repeat
  For I:=0 to MaxX do
   For J:=0 to MaxX do
    PipeValue[I,J]:=Random(6);
 Until CheckWin_FreeDir;
End;

Procedure Show_Keys;
Begin
  TextBackground(White);
  TextColor(Black);
  GotoXY(24,9);
  Write('Espace');
  GotoXY(24,11);
  Write('Echap');
  GotoXY(24,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(24){$ENDIF});
  GotoXY(26,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(25){$ENDIF});
  GotoXY(28,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(26){$ENDIF});
  GotoXY(30,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(27){$ENDIF});
  TextBackground(Black);
  TextColor(White);
End;

Procedure Play_Game;
Var
 K,K2:Char;
 I:Integer;
 Temp_Level,Selection:Byte;
Begin


 Clrscr;

 { Debut de: Menu }

 Repeat

  Show_Head;
  Init_Game;
  Temp_Level:=1;
  Selection:=0;
  TextBackground(White);
  TextColor(Black);
  GotoXY(24,9);
  Write('Espace');
  GotoXY(24,11);
  Write('Echap');
  GotoXY(24,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(24){$ENDIF});
  GotoXY(26,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(25){$ENDIF});
  GotoXY(28,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(26){$ENDIF});
  GotoXY(30,7);
  Write({$IFDEF FPC}''{$ELSE}Chr(27){$ENDIF});
  TextBackground(Black);
  TextColor(White);
  GotoXY(10,5);
  Write('par niveau:1');
  GotoXY(8,4+Selection);
  Write({$IFDEF FPC}''{$ELSE}Chr(16){$ENDIF},' par hasard');

  Repeat (* Menu de selection *)
   Repeat Until Keypressed;
   K:=ReadKey;
   K2:=Char(0);
   Case K of
    #0:Begin
        K2:=ReadKey;
        Case K2 of
         #72:Selection:=0;
         #80:Selection:=1;
         #75:If Selection=1 Then If Temp_Level>1 Then Dec(Temp_Level);
         #77:If Selection=1 Then If Temp_Level<MaxLevel Then Inc(Temp_Level);
        End;
       End;
   End;
   GotoXY(8,4);
   Write(' ');
   GotoXY(8,5);
   Write(' ');
   GotoXY(8,4+Selection);
   Write({$IFDEF FPC}''{$ELSE}Chr(16){$ENDIF});
   GotoXY(21,5);
   Write(Temp_Level,'   ');
  Until (K=#27) or (K=' ');

  If (K=#27) Then (* Fin du jeu *)
   Begin
    Clrscr;
    Exit;
   End;

  Level:=Temp_Level;
  If Selection=0 Then Level:=0;
  If Level=0 Then Generate_FreeDir;

  { Debut de: Jeu }

  Repeat
   Show_Head;
   If Level<>0 Then Show_Head_Level;
   Randomize_Game;
   ShowLevel(False);
   Show_Keys;
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
      If Level=1 Then
       Level:=MaxLevel+1
      Else
       Write('Et Maintenant, Niveau ',Level);
     Delay(3000);
    End;

  Until (K=#27) or (Level>MaxLevel) or (Level=0);

 { Fin de: Jeu }


 Until 0=1;
 { Fin de: Menu }


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
