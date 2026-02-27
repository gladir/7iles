{ @author: Sylvain Maltais (support@gladir.com)
  @website(https://www.gladir.com/7iles)
  @version: 1.2
  @creation: 2026
  @author2: Goupil Brother
  @website(http://goupilbrother.free.fr)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program PIPE;

{$R+}

Uses {$IFDEF FPC}
      Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};


Const {$IFDEF FPC}
       V2:String[6]='∫ªº»…Õ';
      {$ELSE}
       V2:Array[0..5] Of Byte=(186,187,188,200,201,205);
      {$ENDIF}
      NextPipe:Array[0..5] Of Byte=(5,2,3,4,1,0);

Var
 PipeValue:Array[0..39,0..24]of Byte;
 Won:Array[0..39,0..24]of Boolean;
 MaxSize,XPipe,YPipe:Byte;


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
 I,J,V:Byte;
Begin

  TextColor(DarkGray);
  TextBackground(LightGray);
  If Win Then TextBackground(Blue);
  GotoXY(1,5);
  Write({$IFDEF FPC}'Õ'{$ELSE}Chr(205){$ENDIF});
  GotoXY(MaxSize+3,MaxSize+1);
  Write({$IFDEF FPC}'Õ'{$ELSE}Chr(205){$ENDIF});

  For I:=0 To MaxSize Do
   For J:=0 To MaxSize Do
   Begin
    TextColor(LightGray);
    TextBackground(Black);
    If (I=XPipe) and (J=YPipe) Then TextBackground(Green);
    If Win Then
     If Won[I,J] Then
      TextBackground(Blue)
     Else
      TextBackground(Black);
    GotoXY(I+2,J+3);
    V:=PipeValue[I,J];
    Write({$IFDEF FPC}V2[v]{$ELSE}Chr(V2[v]){$ENDIF});
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
 For I:=0 to MaxSize Do
  For J:=0 to MaxSize Do
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
  If (NextX<0) or (NextY<0) or (NextX>MaxSize) or (NextY>MaxSize) Then Good:=False;
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
 If (NextX=MaxSize+1) and (NextY=MaxSize-2) Then CheckWin:=True;
End;







Function CheckWin_FreeDir:Boolean;
var proofs:Array[0..39,0..23]of Byte;
    CheckWin_FreeDir2:boolean;


 Procedure Next_FreeDir(X,Y,Direction:Integer);{0:Droite 1:Bas 2:Gauche 3:Haut}

 var value:integer;
     i,j:integer;
 Begin

  If CheckWin_FreeDir2 Then exit Else
   If (x=MaxSize+1) and (y=MaxSize-2) Then
    Begin
     CheckWin_FreeDir2:=true;
     exit;
    End;

  If Not ((x=-1) And (y=2)) Then
   Begin
    If (X<0) Or (Y<0) Or (X>MaxSize) Or (Y>MaxSize) Then Exit;
    If proofs[x,y]=0 Then
     proofs[x,y]:=1
    Else exit;
   End;

    value:=5;
    If not ((x=-1) and (y=2)) Then value:=pipevalue[x,y];

    Case Direction of
     0:case value of {droite}
        0,5:Next_FreeDir(x+1,y,0);
        Else Begin
              Next_FreeDir(x,y-1,3);
              Next_FreeDir(x,y+1,1);
             End;
       end;
     1:case value of {bas}
        0,5:Next_FreeDir(x,y+1,1);
        Else Begin
              Next_FreeDir(x-1,y,2);
              Next_FreeDir(x+1,y,0);
             End;
       end;
     2:case value of {gauche}
        0,5:Next_FreeDir(x-1,y,2);
        Else Begin
              Next_FreeDir(x,y-1,3);
              Next_FreeDir(x,y+1,1);
             End;
       end;
     3:case value of {haut}
        0,5:Next_FreeDir(x,y-1,3);
        Else Begin
              Next_FreeDir(x-1,y,2);
              Next_FreeDir(x+1,y,0);
             End;
       End;
    End;
    If Not ((x=-1) And (y=2)) Then proofs[x,y]:=0;

 End;

Var i,j:integer;

Begin
 CheckWin_FreeDir2:=False;
 For I:=0 To 39 Do For J:=0 To 23 Do proofs[I,J]:=0;
 Next_FreeDir(-1,2,0);
 CheckWin_FreeDir:=CheckWin_FreeDir2;
end;

(*
Function CheckWin_FreeDir:Boolean;
var proofs:Array[0..39,0..23]of Byte;
    CheckWin_FreeDir2:boolean;


 Procedure Next_FreeDir(X,Y,Direction,{0:Droite 1:Bas 2:Gauche 3:Haut}
                        proof:Integer);
 var value:integer;
     i,j:integer;
 Begin

  If CheckWin_FreeDir2 Then exit Else
   If (x=MaxSize+1) and (y=MaxSize-2) Then
    Begin
     CheckWin_FreeDir2:=true;
     exit;
    End;

  If Not ((x=-1) And (y=2)) Then
   Begin
    If (X<0) Or (Y<0) Or (X>MaxSize) Or (Y>MaxSize) Then Exit;
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
 For I:=0 To 39 Do For J:=0 To 23 Do proofs[I,J]:=0;
 Next_FreeDir(-1,2,0,0);
 CheckWin_FreeDir:=CheckWin_FreeDir2;
end;
*)






Procedure Generate_FreeDir;
Var
 I,J:Integer;
Begin
 Randomize;
 Repeat
  For I:=0 to 39 do For J:=0 to 23 do PipeValue[I,J]:=Random(6);
 Until CheckWin_FreeDir;
End;


Procedure Play_Game;
Var
 K,K2:Char;
 I:Integer;
Begin

 XPipe:=0;
 YPipe:=0;
 MaxSize:=8;

 { Menu }

 Writeln;
 TextBackground(Red);
 TextColor(Black);
 Write(
  {$IFDEF FPC}'≤±∞ PIPE ∞±≤€'
  {$ELSE}
   Chr(178),Chr(177),Chr(176),' PIPE ',Chr(176),Chr(177),Chr(178),Chr(219)
  {$ENDIF});
 TextBackground(White);
 Writeln(
  {$IFDEF FPC}'€€€€ Space € Eskape '
  {$ELSE}Chr(24),Chr(219),
         Chr(25),Chr(219),
         Chr(26),Chr(219),
         Chr(27),Chr(219),
         ' Space ',Chr(219),
         ' Eskape '{$ENDIF});
 TextBackground(Black);
 TextColor(Black);
 Writeln;
 Write('Level? ');
 TextBackground(White);
 TextColor(Black);
 Writeln(
 {$IFDEF FPC}'1€2€3€4€5'
 {$ELSE}'1',Chr(219),
        '2',Chr(219),
        '3',Chr(219),
        '4',Chr(219),
        '5',Chr(219){$ENDIF});
 TextBackground(Black);
 TextColor(Black);

 Repeat
  Repeat Until Keypressed;
  K:=ReadKey;
  K2:=Char(0);
  If K=#0 Then K2:=ReadKey;
 Until (K=#27) or (K in ['1','2','3','4','5']);

 { Fin de Menu }

 If K=#27 Then Exit;

 MaxSize:=8;
 Case K Of
 '2':MaxSize:=10;
 '3':MaxSize:=12;
 '4':MaxSize:=16;
 '5':MaxSize:=18;
 End;

 Generate_FreeDir;

 TextMode(CO40);
 CursorOff;
 ClrScr;

 ShowLevel(False);
 Repeat
    Repeat Until Keypressed;
    K:=ReadKey;
    K2:=Char(0);
    Case K of
     ' ':PipeValue[XPipe,YPipe]:=NextPipe[PipeValue[XPipe,YPipe]];
     #0:Begin
         K2:=ReadKey;
         Case K2 of
          #72:If YPipe>0 Then Dec(YPipe);
          #75:If XPipe>0 Then Dec(XPipe);
          #77:If XPipe<MaxSize Then Inc(XPipe);
          #80:If YPipe<MaxSize Then Inc(YPipe);
         End;
        End;
    End;
    ShowLevel(False);
 Until (K=#27) or ((K=' ') and CheckWin);

 If K<>#27 Then
    Begin
     ShowLevel(True);
     Repeat Until Keypressed;
    End;

End;


Var OrigMode:Integer;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 OrigMode:=LastMode;
 CursorOff;
 Play_Game;
 TextMode(OrigMode);
 CursorOn;
 Clrscr;
END.
