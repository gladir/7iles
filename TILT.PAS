{ @author:      Goupil Brother
  @website:     https://www.gladir.com/7iles
  @website:     http://goupilbrother.free.fr
  @version:     1
  @creation:    2026
  @target:      Turbo Pascal 7, Free Pascal 3.2
  @description: Faire disparaitre les jetons verts, pas les bleus.
}


Program TILT;

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



Const Tab:Array[1..36] Of String[25]=(
'gx          h         x  ',
'xgb         h            ',
'bgx         h       bg   ',
'x   g       h       b   g',
'bgb  bxg    h            ',
' xb g x   xxh           g',
'x xx        h  g    b    ',
'g x  gxx  bxh  b    b    ',
'            hbb  xxx   bg',
'bx   ggx x  h            ',
' x    gxg   hx       x   ',
'xxx   xx    h       gg  b',
'            h    xx   bg ',
' b  b    g  h x          ',
'x  x g x  b h            ',
'           xh       xgb  ',
'bx   b  x xxhx g         ',
'  xgg  bbb  h   x        ',
'xb   g x  b h    x    x  ',
'x x x      xh    x g  x b',
'  xgb x  g  h           b',
'  x  g    x h       xb  x',
'x      xgg  hxx   bb     ',
'x        x  hxg  xbg   bb',
'x x         h    bbb  xgb',
'xx     x  b h  xx   bg   ',
' xb b xb g  hxb xxx      ',
'xbgbx xx    h        bx  ',
' xx        xh  xbx  bgb x',
' xx         h   gxb  xbg ',
'xx  xgg   b h         x  ',
'            hx   xgbx xxg',
'  xbg x bg xh    x       ',
'xbx  g    g h x    x  x  ',
'x xgg   bx  hx   x       ',
'x   gg x bb hx   x   x   ');


 Jeton:Array[0..4,0..4] Of Integer=(
 (0,0,1,0,0),(0,1,2,1,0),(1,2,2,2,1),(0,1,2,1,0),(0,0,1,0,0));
 Jeton2:Array[0..4] Of Array[0..4,0..4] Of Integer=(
((0,0,1,0,0),(0,1,2,1,0),(1,2,2,2,1),(0,1,2,1,0),(0,0,1,0,0)),
((0,0,0,0,0),(0,1,1,1,0),(0,1,2,1,0),(0,1,1,1,0),(0,0,0,0,0)),
((0,0,0,0,0),(0,0,1,0,0),(0,1,2,1,0),(0,0,1,0,0),(0,0,0,0,0)),
((0,0,0,0,0),(0,0,0,0,0),(0,0,1,0,0),(0,0,0,0,0),(0,0,0,0,0)),
((0,0,0,0,0),(0,0,0,0,0),(0,0,1,0,0),(0,0,0,0,0),(0,0,0,0,0)));



var win,lose:boolean;
    level:integer;
    tableau,moving:Array[0..4,0..4] of Integer;
    print:Array[1..25,1..25] Of Integer;



Procedure Draw(mstep:integer);
Var i,j,k,l,m,n,o,value:Integer;


Begin


 For i:=1 To 25 Do For j:=1 To 25 Do print[i,j]:=0;

 TextBackground(Red);  TextColor(Black);
 Gotoxy(28,1);         Write('²±° TILTY °±²');
 Gotoxy(28,3);         Write(level);

 For i:=1 To 25 Do
  Begin
    Gotoxy(26,i);
    Write('±');
  End;

 For i:=1 To 5 Do
  Begin
    print[15,i+10]:=1;
    print[i+10,15]:=1;
    print[11,i+10]:=1;
    print[i+10,11]:=1;
  End;

 TextBackground(Black);
 TextColor(White);


 For i:=0 to 4 Do
  For j:=0 to 4 Do
    Begin
      Case tableau[i,j] Of
        1,2:Begin
             For k:=0 To 4 Do For l:=0 To 4 Do
              If jeton[k,l]<>0 Then
               Begin
                Case tableau[i,j] Of
                 1:Case jeton[k,l] Of
                   1:value:=2;
                   2:value:=3;
                   End;
                 2:Case jeton[k,l] Of
                   1:value:=4;
                   2:value:=5;
                   End;
                End;
                m:=i*5+k+1;
                n:=j*5+l+1;
                If (i=2) And (j=2) Then
                 Begin
                  o:=mstep mod 10;
                  If jeton2[o,k,l]<>0 Then
                    print[m,n]:=value;
                 End
                Else
                 Begin
                  If mstep<>0 Then
                   If moving[i,j]=1 Then
                    Begin
                     If mstep in [0,1,2,3,4] Then m:=m+4-mstep-5;{gauche}
                     If mstep in [10,11,12,13,14] Then m:=m+mstep-10;{droite}
                     If mstep in [20,21,22,23,24] Then n:=n+24-mstep-5;{haut}
                     If mstep in [30,31,32,33,34] Then n:=n+mstep-30;{bas}
                    End;
                  print[m,n]:=value;
                 End;
               End;
            End;
        3:For k:=0 To 4 Do For l:=0 To 4 Do
           If (k=l) or ((4-k)=l) Then
            Begin
             m:=i*5+k+1;
             n:=j*5+l+1;
             print[m,n]:=6;
            End;
      End;

    End;



 For i:=1 To 25 Do
  For j:=1 To 25 Do
   Begin
    TextBackground(Black);
    Gotoxy(i,j);
    Case print[i,j] Of
    0:Begin TextColor(Black);Write('±');End;
    1:Begin TextBackground(Red);TextColor(Black);Write('±');End;
    2:Begin TextColor(green);Write('O');End;
    3:Begin TextColor(lightgreen);Write('O');End;
    4:Begin TextColor(Blue);Write('O');End;
    5:Begin TextColor(lightblue);Write('O');End;
    6:Begin TextColor(darkgray);Write('X');End;
    End;
   End;


End;






Procedure Anim(side:integer);{0:g 1:d 2:h 3:b}
Const delai=50;
Label Boucle;
Var stepp,i,j,cpt:Integer;
    something,vide:Boolean;
Begin



Boucle:


   For i:=0 to 4 Do For j:=0 to 4 Do moving[i,j]:=0;
   something:=False;

   Case side of
   0: {gauche}
     Begin
       For j:=0 to 4 Do
        Begin
         vide:=(Tableau[0,j]=0);
         For i:=0 To 3 Do
          Begin
           If vide Then If tableau[i+1,j] in [1,2] Then
            Begin something:=True;moving[i+1,j]:=1;End;
           Case tableau[i+1,j] Of
            0:vide:=True;
            1..2:If moving[i+1,j]=1 Then vide:=True;
            3:vide:=False;
           End;
          End;
        End;
     End;
   1: {droite}
     Begin
       For j:=0 to 4 Do
        Begin
         vide:=(Tableau[4,j]=0);
         For i:=4 Downto 1 Do
          Begin
           If vide Then If tableau[i-1,j] in [1,2] Then
            Begin something:=True;moving[i-1,j]:=1;End;
           Case tableau[i-1,j] Of
            0:vide:=True;
            1..2:If moving[i-1,j]=1 Then vide:=True;
            3:vide:=False;
           End;
          End;
        End;
     End;
   2: {haut}
     Begin
       For i:=0 to 4 Do
        Begin
         vide:=(Tableau[i,0]=0);
         For j:=0 To 3 Do
          Begin
           If vide Then If tableau[i,j+1] in [1,2] Then
            Begin something:=True;moving[i,j+1]:=1;End;
           Case tableau[i,j+1] Of
            0:vide:=True;
            1..2:If moving[i,j+1]=1 Then vide:=True;
            3:vide:=False;
           End;
          End;
        End;
     End;
   3: {bas}
     Begin
       For i:=0 to 4 Do
        Begin
         vide:=(Tableau[i,4]=0);
         For j:=4 Downto 1 Do
          Begin
           If vide Then If tableau[i,j-1] in [1,2] Then
            Begin something:=True;moving[i,j-1]:=1;End;
           Case tableau[i,j-1] Of
            0:vide:=True;
            1..2:If moving[i,j-1]=1 Then vide:=True;
            3:vide:=False;
           End;
          End;
        End;
     End;
   End;

   If tableau[2,2]<>0 Then Begin moving[2,2]:=1;something:=True;End;

   If not something Then
    Begin
     While keypressed Do Readkey;
     Repeat Until not keypressed;
     If lose Then Exit;

     cpt:=0;
     For i:=0 to 4 Do For j:=0 to 4 Do If Tableau[i,j]=1 Then Inc(cpt);
     If cpt=0 Then Begin win:=true;Exit;End;

     Exit;
    End;

   Case side Of
    0:Begin {gauche}
       For stepp:=0 To 4 Do Begin Draw(stepp);Delay(delai);End;
       If moving[2,2]=1 Then
        Begin
         If tableau[2,2]=2 Then Lose:=True;
         tableau[2,2]:=0;
        End;
       For j:=0 To 4 Do For i:=1 To 4 Do
         If moving[i,j]=1 Then
          Begin
           If not ((i=2) And (j=2)) Then tableau[i-1,j]:=tableau[i,j];
           tableau[i,j]:=0;
          End;
      End;
    1:Begin {droite}
       For stepp:=10 To 14 Do Begin Draw(stepp);Delay(delai);End;
       If moving[2,2]=1 Then
        Begin
         If tableau[2,2]=2 Then Lose:=True;
         tableau[2,2]:=0;
        End;
       For j:=0 To 4 Do For i:=3 Downto 0 Do
         If moving[i,j]=1 Then
          Begin
           If not ((i=2) And (j=2)) Then tableau[i+1,j]:=tableau[i,j];
           tableau[i,j]:=0;
          End;
      End;
    2:Begin {haut}
       For stepp:=20 To 24 Do Begin Draw(stepp);Delay(delai);End;
       If moving[2,2]=1 Then
        Begin
         If tableau[2,2]=2 Then Lose:=True;
         tableau[2,2]:=0;
        End;
       For i:=0 To 4 Do For j:=1 To 4 Do
         If moving[i,j]=1 Then
          Begin
           If not ((i=2) And (j=2)) Then tableau[i,j-1]:=tableau[i,j];
           tableau[i,j]:=0;
          End;
      End;
    3:Begin {bas}
       For stepp:=30 To 34 Do Begin Draw(stepp);Delay(delai);End;
       If moving[2,2]=1 Then
        Begin
         If tableau[2,2]=2 Then Lose:=True;
         tableau[2,2]:=0;
        End;
       For i:=0 To 4 Do For j:=3 Downto 0 Do
         If moving[i,j]=1 Then
          Begin
           If not ((i=2) And (j=2)) Then tableau[i,j+1]:=tableau[i,j];
           tableau[i,j]:=0;
          End;
      End;
   End;

   Draw(0);

 Goto Boucle;



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


 Writeln;
 Write('1-36 ? ');
 Readln(str2);
 level:=1;
 val(str2,level,code);
 If not (level in [1..36]) Then level:=1;

 TextMode(CO40);
 CursorOff;

Newlevel:


 win:=false;
 lose:=false;

 For i:=0 to 4 Do For j:=0 to 4 Do
  Case Tab[level][i+j*5+1] Of
   ' ','h':tableau[i,j]:=0;
   'g':tableau[i,j]:=1;
   'b':tableau[i,j]:=2;
   'x':tableau[i,j]:=3;
  End;

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
          #72:Anim(2);
          #75:Anim(0);
          #77:Anim(1);
          #80:Anim(3);
         End;
        End;
    End;

 Until (K=#27) or win or lose;

 If (K=#27) Then Exit;

 While keypressed Do ReadKey;
 Repeat Until not Keypressed;

 If lose Then
    Begin
     TextBackground(Red);
     TextColor(Black);
     for i:=1 to 25 do
      begin
       Gotoxy(i,i);Write('±');
       Gotoxy(26-i,i);Write('±');
      end;
    End;

 If win Then
    Begin
     Trophee(30,5);
     Inc(level);
     If level=37 Then Trophee(30,16);
    End;

 Repeat
    Repeat Until Keypressed;
    K:=ReadKey;
 Until (K=#27) or (K=#10) or (K=#13) or (K=' ');

 If level=37 Then Exit;

 Goto Newlevel;

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

