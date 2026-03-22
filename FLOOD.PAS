{ @author:      Sylvain Maltais (support@gladir.com)
  @website:     https://www.gladir.com/7iles
  @version:     1.3
  @creation:    2026
  @author:      Goupil Brother
  @website:     http://goupilbrother.free.fr
  @target:      Turbo Pascal 7, Free Pascal 3.2
  @description: Remplissez toutes les cases vides.
  @hint:        G pour generer un tableau puis S pour voir la solution
}



Program FLOOD;

{$R+}

Uses {$IFDEF FPC}
      Crt,PtcCrt
     {$ELSE}
      DOS,Crt
     {$ENDIF};



Const Tab:Array[0..100] of String[27]=(
('            b  bgb      b'),
('    b        bg bbbb     '),
('bbb        b   bg   b    '),
(' bg                 bb  b'),
('b                b   bb g'),
('  gb   b    b b          '),
('b bbb   gb               '),
('  bb           bgb  b   b'),
('    b bbgb     bb        '),
('b    bgbb   b        b   '),
('   b    b           bb gb'),
('    b    bb   bg   b     '),
('     b  b bbgb    b      '),
('bbb              b   gb b'),
('       b    b   b b gb   '),
('bbg         b          b '),
('    bbgb  b  b          b'),
('   bg     b     bb      b'),
('      b        b   b  bgb'),
('        b b    b   bbg   '),
('b          b    g    b  b'),
('b b    bg    b          b'),
('        bb        b    bg'),
('       b  b   bg   bb    '),
('        b b    bgb       '),
('        bg  bbb        b '),
('       b    b    g  b b  '),
(' b      b   b  g b  b    '),
('     gb      b  b    b  b'),
('          b b  bgb       '),
('b   b  b b         g  b b'),
('  b  b b  b    g        b'),
('     bg   bb            b'),
('      b    bbb    g   bb '),
('    b  b      g b  b     '),
('       bb bgb    b  b    '),
('b b      g    b  b       '),
('       b  bgb       b    '),
(' b gb    b  b   b        '),
('bbg               b    b '),
(' bb   b            bbb  g'),
('    bbg   bb             '),
('    b  b        bg  bbb  '),
('b b        b        bg   '),
('       b  b g   bb      b'),
('   gb b  b        b    bb'),
('g         bb   bb   b    '),
('b bbg      b    b        '),
('   b  b    bb   bg       '),
('      b   bg b          b'),
('    b      bbb  g    bb  '),
('           b  bbg   b    '),
('     bb          b gb   b'),
('    bb    b  b     g    b'),
('             bbgb   b    '),
('           bb    g  b b  '),
('b          bg   bb    b  '),
('    b   bb   gbb    b    '),
('g  bb          b  b      '),
('   bg   b b  b       b  b'),
('b        b  bgb  b       '),
('  bb   gb      b    b    '),
('b bbb  g    b    b       '),
('  bbb            bgbb    '),
('b gb b          bbb      '),
('g           bb       bb  '),
('b   bb       b  b g    b '),
('   b      b b  g b    b  '),
('   b      b b  g b    b  '),
('      b       g  b b  b  '),
('  b         bb b  g b  b '),
('b gb b                b  '),
('    b    bbb gb   b      '),
('  b  b g    bb  b        '),
('        bb        b    bg'),
('b           b    b b  g  '),
('  b  b     gbb  b        '),
('   gb    b  b  b      b  '),
('       b    b g    bb    '),
('  b g bb           b    b'),
('           bb    g  b b  '),
('   bb  gb   b            '),
('  b b    b bb g          '),
('              b    gbb bb'),
('       bgb    b     b    '),
('   g  b b bb             '),
(' bg                 bb  b'),
('  b    b         gb   b  '),
('  bbbb    g  b  b        '),
('        b b      bgb   bb'),
('bb    b          b  bg  b'),
('  b              bgbb    '),
('b      b  bbg     b      '),
('    b bb   b  b b  g     '),
('       gb bbb        b   '),
('      bbb  gb        b   '),
('    b  bgbb  b    b      '),
('      bbgb bb       b    '),
('            b bbg  bbb   '),
('     b gb   bb      b    '),
('            bb  b g    b '));




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

Const Characters:String[12]='º»¼ÈÉÍ*Û';
      Spriteref:Array[0..19] Of Integer=
       (5,5,7,13,8,10,9,10,8,13,5,13,6,5,9,10,6,13,7,10);

Var AKey,AKeysolution:Array[0..40*25] Of Integer;
    Bloxx,Bloxy:Array[0..40*25] Of Integer;
    Xpos,Ypos,AKeys,AKeyssolution,Bloxs,XMax,YMax,Level:Integer;

Procedure Show_Level(Refresh_screen:Boolean);
var Xpos2,Ypos2,Value,Old,I:Integer;
Begin

    Xpos2:=Xpos;
    Ypos2:=Ypos;
    Old:=0;
    Value:=0;

    If Akeys>0 Then
     For i:=0 To Akeys-1 Do
      Begin
       Value:=Spriteref[(Akey[I]-1)*5+Old];
       GotoXY(Xpos2+1+20-Xmax div 2,Ypos2+1+12-YMax div 2);

       Case Value Of
        5..11:Begin
              TextBackground(Green);
              TextColor(LightGreen);
              Write(Characters[Value]);
             End;
        12:Begin
              TextColor(Red);
              Write(Characters);
           End;
       End;

       Case Akey[I] Of
        1:Dec(Ypos2);
        2:Inc(Xpos2);
        3:Inc(Ypos2);
        4:Dec(Xpos2);
       End;

       Old:=Akey[I];

      End;

    GotoXY(Xpos2+1+20-Xmax div 2,Ypos2+1+12-YMax div 2);
    TextBackground(Green);
    TextColor(LightGreen);
    If Refresh_screen Then
     Begin
      TextBackground(Black);
      TextColor(Black);
     End;
    Value:=11;
    Write(Characters[Value]);

End;



Function Check:Boolean;
Var Xpos2,Ypos2,Xpos3,Ypos3,I,J:Integer;
    Check2:Boolean;
Begin
    Check2:=True;
    Xpos2:=Xpos;
    Ypos2:=Ypos;
    Xpos3:=Xpos;
    Ypos3:=Ypos;

    For I:=0 To Akeys Do
      Case Akey[I] Of
        1:Dec(Ypos2);
        2:Inc(Xpos2);
        3:Inc(Ypos2);
        4:Dec(Xpos2);
      End;

    If (Xpos2<0)Or(Ypos2<0)Or(Xpos2>XMax)Or(Ypos2>YMax)Or
       ((Xpos2=39)And(Ypos2=24)) Then Check2:=False;

    For I:=0 To Akeys Do
     If Check2 Then
      Begin
       If (Xpos3=Xpos2) And (Ypos3=Ypos2) Then Check2:=False;
       Case Akey[I] Of
        1:Dec(Ypos3);
        2:Inc(Xpos3);
        3:Inc(Ypos3);
        4:Dec(Xpos3);
       End;
      End;

    If Check2 Then
       If Bloxs>0 Then
        For J:=0 To Bloxs-1 Do
         If (Xpos2=Bloxx[J]) And (Ypos2=Bloxy[J]) Then Check2:=False;

    Check:=Check2;

End;




Procedure Init_Game;
var i,j:Integer;
Begin
 Bloxs:=0;

 Xmax:=4;Ymax:=4;
 For I:=0 To 4 Do
  For J:=0 To 4 Do
   Begin
    Case Tab[Level][I+j*5+1] Of
     'b':Begin
          Bloxx[Bloxs]:=I;
          Bloxy[Bloxs]:=J;
          Inc(Bloxs);
         End;
     'g':Begin
          Xpos:=I;Ypos:=J;
         End;
    End;
   End;
 AKeys:=0;

End;




Procedure Cadre;
Var I:Integer;
Begin
 GotoXY(14,1);
 TextBackground(Red);
 TextColor(Black);
 Write('²±° FlOOD °±²');
 GotoXY(18,2);
 TextBackground(Black);
 TextColor(DarkGray);
 Write('    Spc Esk G S');
 TextBackground(Black);
 TextColor(DarkGray);
 GotoXY(5,2);
 If Level<>0 Then Write('Level ',Level);
 TextColor(Black);
 TextBackground(Red);
 If XMax<39 Then
  For I:=0 To YMax Do
  If I+1<=24 Then
  Begin
   Gotoxy(XMax+2+20-Xmax div 2,I+1+12-YMax div 2);
   Write(' ');
   Gotoxy(20-Xmax div 2,I+1+12-YMax div 2);
   Write(' ');
  End;
 If YMax<24 Then
  For I:=-1 To XMax+1 Do
   If I+1<40 Then
   Begin
    Gotoxy(I+1+20-Xmax div 2,YMax+2+12-YMax div 2);
    Write(' ');
    Gotoxy(I+1+20-Xmax div 2,12-YMax div 2);
    Write(' ');
   End;
 If Bloxs>0 Then
  For I:=0 To Bloxs-1 Do
   Begin
    Gotoxy(Bloxx[I]+1+20-Xmax div 2,Bloxy[I]+1+12-YMax div 2);
    Write('±');
   End;
End;





Procedure Generate_;
Var I,J,tentatives:Integer;
    Xpos2,Ypos2,Xpos3,Ypos3:Integer;
    tableau:Array[0..39,0..24] Of Byte;
Begin
        Xmax:=15;Ymax:=10;


        For I:=0 To 39 Do
         For J:=0 To 24 Do
          tableau[i,j]:=0;


        randomize;
        tentatives:=0;

        AKeys:=0;
        Bloxs:=0;
        i:=random(4);
        case i of
           0:begin xpos:=0;ypos:=random(6);end;
           1:begin xpos:=9;ypos:=random(6);end;
           2:begin ypos:=0;xpos:=random(10);end;
           3:begin ypos:=5;xpos:=random(10);end;
        end;

        Repeat

          AKeys:=0;
          J:=0;
          Repeat
           I:=random(4)+1;
           AKey[AKeys]:=i;
           If Check Then begin j:=0;Inc(AKeys);end else inc(j);
          Until j>20; (* on arrete au bout de 20 erreurs de suite *)
          inc(tentatives);

        Until (Akeys>=(XMax+1)*(YMax+1)*2 div 3) or (tentatives>1000);
        Xpos2:=Xpos;
        Ypos2:=Ypos;
        tableau[xpos2,ypos2]:=1;

        For I:=0 To Akeys-1 Do
         Begin
          Case Akey[I] Of
           1:Dec(Ypos2);
           2:Inc(Xpos2);
           3:Inc(Ypos2);
           4:Dec(Xpos2);
          End;
          tableau[xpos2,ypos2]:=1;
         End;


        For I:=0 To XMax Do
         For J:=0 To YMax Do
          If tableau[i,j]=0 Then
           Begin
            Bloxx[Bloxs]:=I;
            Bloxy[Bloxs]:=J;
            Inc(Bloxs);
           End;

        For I:=0 To Akeys-1 Do
         Akeysolution[I]:=Akey[I];
        AKeyssolution:=AKeys;

        AKeys:=0; (*!*)

        TextColor(Black);
        TextBackground(Black);
        clrscr;
        Cadre;
        Show_Level(False);

End;



(*********************************************)

Procedure Play_Game;
Var
 K,K2:Char;
 I,code:Integer;
Label GotoLevel;

Begin


 Level:=1;


 CursorOff;

 TextBackground(Black);
 TextColor(White);

 Writeln;
 Write('Enter Level (1-99)? ');

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


 TextMode(CO40);
 Clrscr;
 CursorOff;



GotoLevel:

 TextColor(Black);
 TextBackground(Black);
 ClrScr;
 If Level=0 Then Generate_ Else Init_Game;

 Cadre;
 For I:=0 To 500 Do If Keypressed Then Readkey;

 Show_Level(False);

 Repeat

  Repeat Until Keypressed;
  K:=ReadKey;
  K2:=Char(0);
  Case K of
   #0:Begin
       K2:=ReadKey;
       Case K2 of
        #72:Begin AKey[AKeys]:=1;If Check Then Inc(AKeys);End;
        #77:Begin AKey[AKeys]:=2;If Check Then Inc(AKeys);End;
        #80:Begin AKey[AKeys]:=3;If Check Then Inc(AKeys);End;
        #75:Begin AKey[AKeys]:=4;If Check Then Inc(AKeys);End;
       End;
       Show_Level(False);
      End;
   ' ':Begin Show_Level(True);If AKeys>0 Then Dec(AKeys);Show_Level(False);End;

   'g','G': (* generate level *)
     Begin Level:=0;Goto GotoLevel;End;

   's','S': (* show solution (generated level only) *)
    If Level=0 Then
     Begin
        AKeys:=AKeyssolution;
        For I:=0 To Akeys-1 Do
         Akey[I]:=Akeysolution[I];
        TextColor(Black);
        TextBackground(Black);
        clrscr;
        Cadre;
        Show_Level(False);
     End;

  End;

  If K<>#27 Then If Not (K In ['s','S']) Then
   If Akeys+Bloxs+1=(XMax+1)*(YMax+1) Then
    Begin
     AKeys:=0;
     GotoXY(16,25);
     TextBackground(Black);
     TextColor(Red);
     Write('Victory ');
     If Level<>0 Then Write(Level,'/100');
     Repeat
      Repeat Until Keypressed;
      K:=ReadKey;
      If K=#0 Then K2:=ReadKey;
     Until (K=#27) Or (K=#13) Or (K=' ');
     If Level<>0 Then Inc(Level);
     If (Level=101) Or (K=#27) then Exit;
     Goto GotoLevel;
    End;

 Until K=#27; {Eskape}

End;



(*********************************************)

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
 CursorOn;
 Clrscr;
END.
