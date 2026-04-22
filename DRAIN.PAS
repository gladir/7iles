{ @author:      Goupil Brother
  @website:     https://www.gladir.com/7iles
  @website:     http://goupilbrother.free.fr
  @version:     1
  @creation:    2026    
  @target:      Turbo Pascal 7, Free Pascal 3.2
  @description: Reproduire le schema.
}


Program DRAIN;

{$R+}

Uses {$IFDEF FPC}
      DOS,Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};

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



Const Tab:Array[1..40,0..35] Of Integer=(
(0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,0,0,1,1,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,1,1,0,0,0,0,1,1,0,0,0,0,2,2,0,0,0,0,2,2,0,0,0,0,1,1,0,0,0,0,1,1,0,0),
(0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,1,1,1,1,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,2,2,0,0,1,1,2,2,0,0,2,2,1,1,0,0,2,2,1,1,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,2,2,0,0,1,1,2,2,0,0,0,0,1,1,0,0,0,0,1,1,0,0,0,0,0,0,0),
(0,0,1,1,0,0,0,0,1,1,0,0,0,0,2,2,0,0,0,0,2,2,0,0,0,0,1,1,0,0,0,0,1,1,0,0),
(0,0,0,0,0,0,0,1,1,2,2,0,0,1,1,2,2,0,0,2,2,1,1,0,0,2,2,1,1,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,0,0,0,0,1,1,2,2,1,1,1,1,2,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,2,2,0,0,1,1,2,2,0,0,2,2,1,1,0,0,2,2,1,1,0,0,0,0,0,0,0),
(0,0,1,1,0,0,0,0,1,1,0,0,0,0,2,2,0,0,0,0,2,2,0,0,0,0,3,3,0,0,0,0,3,3,0,0),
(0,0,0,0,0,0,0,0,1,1,0,0,1,1,1,1,2,2,1,1,2,2,2,2,0,0,2,2,0,0,0,0,0,0,0,0),
(1,1,0,0,0,0,1,1,0,0,0,0,2,2,0,0,0,0,2,2,0,0,0,0,1,1,2,2,1,1,1,1,2,2,1,1),
(1,1,2,2,1,1,1,1,2,2,1,1,2,2,0,0,2,2,2,2,0,0,2,2,1,1,0,0,1,1,1,1,0,0,1,1),
(1,1,2,2,1,1,1,1,2,2,1,1,0,0,3,3,0,0,0,0,3,3,0,0,0,0,1,1,0,0,0,0,1,1,0,0),
(0,0,1,1,0,0,0,0,1,1,0,0,2,2,3,3,2,2,2,2,3,3,2,2,0,0,1,1,0,0,0,0,1,1,0,0),
(1,1,0,0,0,0,1,1,0,0,0,0,2,2,3,3,2,2,2,2,3,3,2,2,0,0,0,0,1,1,0,0,0,0,1,1),
(1,1,2,2,1,1,1,1,2,2,1,1,3,3,0,0,3,3,3,3,0,0,3,3,1,1,2,2,1,1,1,1,2,2,1,1),
(1,1,0,0,2,2,1,1,0,0,2,2,2,2,3,3,1,1,2,2,3,3,1,1,1,1,0,0,2,2,1,1,0,0,2,2),
(1,1,2,2,3,3,1,1,2,2,3,3,0,0,3,3,0,0,0,0,3,3,0,0,3,3,2,2,1,1,3,3,2,2,1,1),
(0,1,1,2,2,0,0,1,1,2,2,0,2,2,3,3,1,1,2,2,3,3,1,1,0,0,4,4,0,0,0,0,4,4,0,0),
(0,0,1,2,0,0,0,0,1,2,0,0,0,0,1,2,0,0,0,0,2,1,0,0,0,0,2,1,0,0,0,0,2,1,0,0),
(0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,1,0,0,1,2,3,1,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,2,1,2,0,0,1,2,1,2,0,0,2,1,2,1,0,0,2,1,2,1,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,1,1,0,0,2,2,2,2,0,0,1,1,1,1,0,0,2,2,2,2,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,1,1,0,0,2,2,2,2,0,0,3,3,3,3,0,0,4,4,4,4,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,2,2,0,0,2,2,1,1,0,0,1,1,3,3,0,0,3,3,1,1,0,0,0,0,0,0,0),
(0,0,1,2,0,0,0,0,1,2,0,0,0,0,1,2,0,0,0,0,3,4,0,0,0,0,3,4,0,0,0,0,3,4,0,0),
(0,0,0,0,0,0,0,1,2,1,3,0,0,1,2,1,3,0,0,2,1,3,1,0,0,2,1,3,1,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,3,4,0,0,1,2,3,4,0,0,0,0,0,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,1,1,1,1,0,0,1,2,2,1,0,0,1,2,2,1,0,0,1,1,1,1,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,1,1,0,0,2,2,3,3,2,2,3,3,1,1,3,3,0,0,2,2,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,1,2,0,0,0,0,1,2,0,0,0,0,1,2,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,1,1,1,0,0,1,1,2,1,0,0,1,2,1,1,0,0,1,1,1,0,0,0,0,0,0,0,0),
(0,0,0,0,0,0,0,0,1,2,0,0,0,1,1,2,2,0,0,2,2,1,1,0,0,0,2,1,0,0,0,0,0,0,0,0),
(0,0,1,2,0,0,0,0,1,2,0,0,1,1,1,2,2,2,2,2,2,1,1,1,0,0,2,1,0,0,0,0,2,1,0,0),
(1,1,2,2,1,1,1,1,2,2,1,1,2,2,0,0,3,3,2,2,0,0,3,3,1,1,3,3,1,1,1,1,3,3,1,0),
(0,0,1,1,0,0,0,0,2,1,0,0,0,0,2,2,0,0,0,0,3,3,0,0,1,1,3,4,2,2,1,1,4,4,2,2),
(1,1,2,2,3,3,1,1,2,2,3,3,0,0,3,3,2,2,0,1,3,3,2,0,0,1,2,2,0,0,0,1,2,0,0,0),
(0,0,0,0,1,2,0,0,0,0,1,2,0,0,0,0,1,2,0,0,0,0,1,2,3,3,3,3,1,2,4,4,4,4,4,2));







var level,x,y,cpt:integer;
    print:Array[1..25,1..25] Of Integer;
    tableau:Array[0..5,0..5] Of Integer;


Procedure Draw(mstep:Integer);
Var i,j,k,l,m,n,o:Integer;


Begin


 For i:=1 To 25 Do For j:=1 To 25 Do print[i,j]:=0;

 TextBackground(Red);  TextColor(Black);
 Gotoxy(28,1);         Write('²±° DRAIN °±²');
 Gotoxy(28,3);         Write(level);

 For i:=1 To 25 Do
  Begin
    Gotoxy(26,i);
    Write('±');
  End;


 TextBackground(Black);
 Textcolor(Red);
 For i:=-1 To 6 Do For j:=-1 To 6 Do
  If (i=-1) Or (j=-1) Or (i=6) Or (j=6) Then
  Begin
    Gotoxy(30+i,6+j);
    Write('±');
  End;

 TextBackground(Black);
 For i:=0 To 5 Do For j:=0 To 5 Do
  Begin
   Gotoxy(30+i,6+j);
   Case Tab[level,i+6*j] Of
    1:Begin Textcolor(Red);Write('');End;
    2:Begin Textcolor(Green);Write('');End;
    3:Begin Textcolor(Brown);Write('');End;
    4:Begin Textcolor(Blue);Write('');End;
   End;
  End;

(* 567
   8 8
   A69 *)

 For i:=0 to 8 Do
   For j:=0 to 8 Do
    If (j=0) Or (j=8) Or (i=0) Or (i=8) Then
      Begin
        k:=8;
        If (j=0) Or (j=8) Then k:=6;
        print[x*4+i+1,y*4+j+1]:=k;
      End;

 print[x*4+1,y*4+1]:=5;
 print[x*4+1+8,y*4+1]:=7;
 print[x*4+1+8,y*4+1+8]:=9;
 print[x*4+1,y*4+1+8]:=10;

 For i:=0 To 5 Do For j:=0 To 5 Do
   For k:=0 To 2 Do For l:=0 To 2 Do
    Begin
     print[i*4+2+k,j*4+2+l]:=Tableau[i,j];
    End;

 If mstep<>0 Then
  Begin

   For i:=1 to 7 Do
     For j:=1 to 7 Do
        print[x*4+i+1,y*4+j+1]:=0;
   For k:=0 To 2 Do For l:=0 To 2 Do
    Begin
      print[x*4+2+k+mstep,y*4+2+l]:=Tableau[x,y];
      print[(x+1)*4+2+k-mstep,(y+1)*4+2+l]:=Tableau[x+1,y+1];
      print[(x+1)*4+2+k,y*4+2+l+mstep]:=Tableau[x+1,y];
      print[x*4+2+k,(y+1)*4+2+l-mstep]:=Tableau[x,y+1];
    End;
  End;

 TextBackground(Black);
 TextColor(White);




 For i:=1 To 25 Do
  For j:=1 To 25 Do
   Begin
    TextBackground(Black);
    Gotoxy(i,j);
    Case print[i,j] Of
     0:Begin TextColor(Black);Write('±');End;
     1:Begin Textcolor(Red);Write('');End;
     2:Begin Textcolor(Green);Write('');End;
     3:Begin Textcolor(Brown);Write('');End;
     4:Begin Textcolor(Blue);Write('');End;
     5:Begin TextColor(Magenta);Write('É');End;
     6:Begin TextColor(Magenta);Write('Í');End;
     7:Begin TextColor(Magenta);Write('»');End;
     8:Begin TextColor(Magenta);Write('º');End;
     9:Begin TextColor(Magenta);Write('¼');End;
     10:Begin TextColor(Magenta);Write('È');End;
    End;
   End;


End;


Procedure Rotate;
Var i:Integer;
Begin
          i:=tableau[x+1,y];
          tableau[x+1,y]:=tableau[x,y];
          tableau[x,y]:=tableau[x,y+1];
          tableau[x,y+1]:=tableau[x+1,y+1];
          tableau[x+1,y+1]:=i;
End;


Function Disponible(x,y:Integer):Boolean;
Begin
   If (tableau[x,y]<>0) And (tableau[x+1,y]<>0) And
      (tableau[x,y+1]<>0) And (tableau[x+1,y+1]<>0) Then
    Disponible:=True else Disponible:=False;

End;



Procedure Mix;
Label recommencer;
Var i,j,k,l,cpt,tour:Integer;

   Procedure Mix2;
   Var m,n,o:Integer;
   Begin
     k:=random(cpt);
     l:=0;
     For m:=0 To 4 Do For n:=0 To 4 Do
      If Disponible(n,m) Then
       Begin
        if l=k Then
         Begin
          x:=n;y:=m;
          For o:=1 to 3 Do
            Begin Draw(o);Delay(50);End;
          Rotate;
         End;
        Inc(l);
       End;

   End;

Begin

recommencer:
 cpt:=0;
 For j:=0 To 4 Do For i:=0 To 4 Do
  If Disponible(i,j) Then Inc(cpt);

 For tour:=0 to Level div 4+1 Do Mix2;

 k:=0;
 For i:=0 To 5 Do For j:=0 To 5 Do
     If tableau[i,j]<>tab[level,i+6*j] then inc(k);
 If k<5 Then Goto recommencer;

End;


Procedure Trophee(x,y:Integer);
Const Troph:Array[0..8,0..8] Of Integer=(
 (1,0,1,1,1,1,1,0,1),
 (1,0,1,1,1,1,1,0,1),
 (0,1,1,1,1,1,1,1,0),
 (0,0,1,1,1,1,1,0,0),
 (0,0,0,1,1,1,0,0,0),
 (0,0,0,0,1,0,0,0,0),
 (0,0,0,0,1,0,0,0,0),
 (0,0,0,1,1,1,0,0,0),
 (0,0,1,1,1,1,1,0,0));
Var i,j:Integer;
Begin
   TextBackground(Red);
   TextColor(Green+128);
   For i:=0 to 8 Do
    For j:=0 to 8 Do
     If Troph[j,i]<>0 Then
     Begin
      Gotoxy(x+i,y+j);
      Write('V');
     End;
End;



Procedure Play_Game;
Label Newlevel;
Var
 K,K2:Char;
 str2:string;
 i,j,code:Integer;
Begin

 level:=1;

 Writeln;
 Write('1-40 ? ');
 Readln(str2);
 val(str2,level,code);
 If not (level in [1..40]) Then level:=1;

 TextMode(CO40);
 CursorOff;

Newlevel:


 x:=0;y:=0;

 For i:=0 to 5 Do For j:=0 to 5 Do
   tableau[i,j]:=tab[level,i+6*j];
 Mix;

 For j:=4 Downto 0 Do For i:=4 Downto 0 Do
  If Disponible(i,j) Then Begin x:=i;y:=j;End;

 TextBackground(Black);
 TextColor(Black);
 Clrscr;

 draw(0);

 Repeat
    Repeat Until Keypressed;
    K:=ReadKey;
    K2:=Char(0);
    Case K of
     #0:Begin
         K2:=ReadKey;
         Case K2 of
          #72:If y>0 Then If Disponible(x,y-1) Then Dec(y);
          #75:If x>0 Then If Disponible(x-1,y) Then Dec(x);
          #77:If x<4 Then If Disponible(x+1,y) Then Inc(x);
          #80:If y<4 Then If Disponible(x,y+1) Then Inc(y);
         End;
         Draw(0);
        End;
     ' ':Begin
          For i:=1 to 3 Do
            Begin Draw(i);Delay(50);End;
          Rotate;
          Draw(0);

          cpt:=0;

          For i:=0 To 5 Do
            For j:=0 To 5 Do
              If tableau[i,j]=tab[level,i+6*j] Then inc(cpt);

          If cpt=36 Then
            Begin

             While keypressed Do ReadKey;
             Repeat Until not Keypressed;
             Trophee(29,15);
             Inc(level);

             Repeat
                   Repeat Until Keypressed;
                   K:=ReadKey;
             Until (K=#27) or (K=#10) or (K=#13) or (K=' ');

             If level=41 Then Exit;

             Goto Newlevel;
            End;

         End;
    End;

 Until K=#27;


End;





Var OrigMode:Integer;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 OrigMode:=LastMode;
 Play_Game;
 TextMode(OrigMode);
 Clrscr;
 CursorOn;
END.

