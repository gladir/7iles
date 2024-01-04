{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program SODOKU;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 CaseWidth=40;
 GridX=(640-9*CaseWidth) shr 1;
 GridY=(480-9*CaseWidth) shr 1;

Var
 Win:Boolean;
 I,J:Integer;
 S:String;
 CursorX,CursorY:Integer;
 SolutionGrid:Array[1..9,1..9] of Integer;
 UserGrid:Array[1..9,1..9,1..2] of Integer;
 B:Char;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function Left(Const Str:String;Num:Byte):String;Begin
 Left:=Copy(Str,1,Num);
End;

Procedure DelChrAt(Var S:String;P:Byte);Begin
 If P=1Then S:=Copy(S,2,255)
       Else S:=Left(S,P-1)+Copy(S,P+1,255)
End;

Function VerticalFound(X,YMax,Number:Integer):Boolean;
Var
 J:Integer;
Begin
 VerticalFound:=False;
 For J:=1 to YMax do Begin
  If(SolutionGrid[J,X]=Number)Then Begin
   VerticalFound:=True;
   Exit;
  End;
 End;
End;

Function FindZero:Boolean;
Var
 I,J:Integer;
Begin
 FindZero:=False;
 For J:=1 to 9 do For I:=1 to 9 do Begin
  If SolutionGrid[J,I]=0 Then Begin
   FindZero:=True;
  End;
 End;
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

Procedure DrawGrid;Begin
 For I:=0 to 9 do Begin
  If I in[0,3,6,9]Then SetLineStyle(0,$C3,3)
                  Else SetLineStyle(0,$C3,1);
  Line(GridX,GridY+i*CaseWidth,GridX+9*CaseWidth,GridY+i*CaseWidth);
  Line(GridX+i*CaseWidth,GridY,GridX+i*CaseWidth,GridY+9*CaseWidth);
 End;
 SetTextStyle(0,0,0);
End;

Procedure FindSolution;
Var
 Base:String;
 I,J,K,L:Integer;
 R,P:Integer;
Begin
 Randomize;
 For K:=1 to 5000 do Begin
  For J:=1 to 9 do Begin
   Base[0]:=#9;
   For I:=1 to 9 do Base[I]:=Chr(I);
   For I:=1 to 9 do Begin
    R:=Random(Length(Base))+1;
    If VerticalFound(I,J,Byte(Base[R]))Then Begin
     For L:=1 to Length(Base)do Begin
      If Not VerticalFound(I,J,Byte(Base[L]))Then Begin
       SolutionGrid[J,I]:=Byte(Base[L]);
       DelChrAt(Base,L);
       Break;
      End;
     End;
    End
     Else
    Begin
     SolutionGrid[J,I]:=Byte(Base[R]);
     DelChrAt(Base,R);
    End;
   End;
  End;
  If Not FindZero Then Break;
 End;
End;

Procedure FindBegin;Begin
 UserGrid[1,2,1]:=SolutionGrid[1,2];
 UserGrid[1,2,2]:=1;
 UserGrid[1,4,1]:=SolutionGrid[1,4];
 UserGrid[1,4,2]:=1;
 UserGrid[1,5,1]:=SolutionGrid[1,5];
 UserGrid[1,5,2]:=1;
 UserGrid[1,6,1]:=SolutionGrid[1,6];
 UserGrid[1,6,2]:=1;
 UserGrid[1,7,1]:=SolutionGrid[1,7];
 UserGrid[1,7,2]:=1;
 UserGrid[2,2,1]:=SolutionGrid[2,2];
 UserGrid[2,2,2]:=1;
 UserGrid[2,6,1]:=SolutionGrid[2,6];
 UserGrid[2,6,2]:=1;
 UserGrid[2,9,1]:=SolutionGrid[2,9];
 UserGrid[2,9,2]:=1;
 UserGrid[3,5,1]:=SolutionGrid[3,5];
 UserGrid[3,5,2]:=1;
 UserGrid[3,7,1]:=SolutionGrid[3,7];
 UserGrid[3,7,2]:=1;
 UserGrid[3,9,1]:=SolutionGrid[3,9];
 UserGrid[3,9,2]:=1;
 UserGrid[4,1,1]:=SolutionGrid[4,1];
 UserGrid[4,1,2]:=1;
 UserGrid[4,3,1]:=SolutionGrid[4,3];
 UserGrid[4,3,2]:=1;
 UserGrid[4,6,1]:=SolutionGrid[4,6];
 UserGrid[4,6,2]:=1;
 UserGrid[4,7,1]:=SolutionGrid[4,7];
 UserGrid[4,7,2]:=1;
 UserGrid[4,8,1]:=SolutionGrid[4,8];
 UserGrid[4,8,2]:=1;
 UserGrid[5,2,1]:=SolutionGrid[5,2];
 UserGrid[5,2,2]:=1;
 UserGrid[5,4,1]:=SolutionGrid[5,4];
 UserGrid[5,4,2]:=1;
 UserGrid[5,6,1]:=SolutionGrid[5,6];
 UserGrid[5,6,2]:=1;
 UserGrid[5,8,1]:=SolutionGrid[5,8];
 UserGrid[5,8,2]:=1;
 UserGrid[6,2,1]:=SolutionGrid[6,2];
 UserGrid[6,2,2]:=1;
 UserGrid[6,3,1]:=SolutionGrid[6,3];
 UserGrid[6,3,2]:=1;
 UserGrid[6,4,1]:=SolutionGrid[6,4];
 UserGrid[6,4,2]:=1;
 UserGrid[6,7,1]:=SolutionGrid[6,7];
 UserGrid[6,7,2]:=1;
 UserGrid[6,9,1]:=SolutionGrid[6,9];
 UserGrid[6,9,2]:=1;
 UserGrid[7,1,1]:=SolutionGrid[7,1];
 UserGrid[7,1,2]:=1;
 UserGrid[7,3,1]:=SolutionGrid[7,3];
 UserGrid[7,3,2]:=1;
 UserGrid[7,5,1]:=SolutionGrid[7,5];
 UserGrid[7,5,2]:=1;
 UserGrid[8,1,1]:=SolutionGrid[8,1];
 UserGrid[8,1,2]:=1;
 UserGrid[8,4,1]:=SolutionGrid[8,4];
 UserGrid[8,4,2]:=1;
 UserGrid[8,8,1]:=SolutionGrid[8,8];
 UserGrid[8,8,2]:=1;
 UserGrid[9,3,1]:=SolutionGrid[9,3];
 UserGrid[9,3,2]:=1;
 UserGrid[9,4,1]:=SolutionGrid[9,4];
 UserGrid[9,4,2]:=1;
 UserGrid[9,5,1]:=SolutionGrid[9,5];
 UserGrid[9,5,2]:=1;
 UserGrid[9,6,1]:=SolutionGrid[9,6];
 UserGrid[9,6,2]:=1;
 UserGrid[9,8,1]:=SolutionGrid[9,8];
 UserGrid[9,8,2]:=1;
End;

Procedure WriteUserGrid;Begin
 SetTextJustify(CenterText,CenterText);
 SetTextStyle(1,HorizDir,3);
 For i:=1 to 9 do For j:=1 to 9 do If UserGrid[i,j,1]<>0 Then Begin
  Str(UserGrid[i,j,1],S);
  SetColor(Black);
  OutTextXY(GridX+CaseWidth*(2*i-1) div 2,GridY+CaseWidth*(2*j-1) div 2,Chr(219));
  If UserGrid[i,j,2]=1 Then SetColor(Yellow)
                       Else SetColor(White);
  OutTextXY(GridX+CaseWidth*(2*i-1) div 2,GridY+CaseWidth*(2*j-1) div 2,S);
 End
  Else
 Begin
  SetColor(Black);
  OutTextXY(GridX+CaseWidth*(2*i-1) div 2-1,GridY+CaseWidth*(2*j-1) div 2,Chr(219));
 End;
 SetTextJustify(LeftText,BottomText);
 SetTextStyle(0,0,0);
End;

Function Instruction:Boolean;Begin
 Instruction:=False;
 ClearDevice;
 SetColor(White);
 outtextxy(20,20,'1. Le jeu Sodoku un gros carr‚ divis‚ en 9 carr‚s.');
 outtextxy(20,40,'   et dans ses 9 carr‚s, il contiennent 9 cases compos‚es de 3 lignes et 3 colonnes.');
 outtextxy(20,60,'2. Sur chaque ligne vous devez placer les chiffres de 1 … 9 sans les r‚p‚ter.');
 outtextxy(20,80,'3. Sur chaque colonne vous devez placer les chiffres de 1 … 9 sans les r‚p‚ter.');
 outtextxy(20,120,'4. Dans chaque r‚gion de 9 cases, vous devez placer les chiffres de 1 … 9');
 outtextxy(20,140,'   sans les r‚p‚ter.');
 outtextxy(20,160,'5. Un truc tres pratique est d''eliminer les cases ou votre chiffre...');
 outtextxy(20,180,'   ne peut se trouver.');
 outtextxy(20,200,'6. Pour gagner du temps vous pouvez commencer par les chiffres les plus nombreux');
 outtextxy(20,220,'7. Attention a ce que vos chiffres ne se repetent pas dans une meme ligne.');
 outtextxy(20,240,'   ni dans un mˆme carr‚');
 outtextxy(20,260,'8. Les nombres ecrits en jaune sont ceux que l''ordinateur vous donne');
 outtextxy(20,280,'9. Vous ne pouvez pas ‚crire par dessus les chiffres jaunes.');
 outtextxy(20,300,'10. Pour ‚crire un chiffre, d‚placez le curseur a l''aide des 4 flŠches.');
 outtextxy(20,320,'    et appuyer sur un nombre');
 outtextxy(20,340,'11. Si vous voulez effacer un nombre que vous avez inscrit (pas ceux en jaune).');
 outtextxy(20,360,'    vous devez appuyer sur la touche E pour effacer votre valeur');
 outtextxy(20,380,'12. Pour quitter le jeu appuyer sur la touche <Q>');
 outtextxy(250,400,'amusez-vous! en appuyant sur <2> maintenant');
 outtextxy(20,440,' Pour revenir au menu appuyez sur la touche <Enter>');
 If ReadKey='2'Then Instruction:=True;
End;

Procedure Play;
Var
 Key:Char;
Begin
 FillChar(UserGrid,SizeOf(UserGrid),0);
 FillChar(SolutionGrid,SizeOf(SolutionGrid),0);
 ClearDevice;
 OutTextXY(20,20,'Q=Quitter');
 OutTextXY(20,40,'E=Effacer');
 OutTextXY(20,60,'S=Solution');
 DrawGrid;
 FindSolution;
 FindBegin;
 WriteUserGrid;
 CursorX:=1;
 CursorY:=1;
 Repeat
  SetColor(White);
  Line(GridX+(CaseWidth shr 2)+CaseWidth*(CursorX-1),GridY+CaseWidth*CursorY-3,
       GridX+3*CaseWidth div 4+CaseWidth*(CursorX-1),GridY+CaseWidth*CursorY-3);
  Key:=ReadKey;
  SetColor(black);
  Line(GridX+CaseWidth div 4+CaseWidth*(CursorX-1),GridY+CaseWidth*CursorY-3,
       GridX+3*CaseWidth div 4+CaseWidth*(CursorX-1),GridY+CaseWidth*CursorY-3);
  Case UpCase(Key) of
   #75:if CursorX>1 Then Dec(CursorX);
   #77:if CursorX<9 Then Inc(CursorX);
   #72:if CursorY>1 Then dec(CursorY);
   #80:if CursorY<9 Then inc(CursorY);
   'E':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=0;
   '1':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=1;
   '2':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=2;
   '3':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=3;
   '4':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=4;
   '5':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=5;
   '6':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=6;
   '7':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=7;
   '8':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=8;
   '9':if UserGrid[CursorX,CursorY,2]<>1 Then UserGrid[CursorX,CursorY,1]:=9;
   'S':Begin
    For i:=1 to 9 do For j:=1 to 9 do Begin
     UserGrid[i,j,1]:=SolutionGrid[i,j];
    End;
    WriteUserGrid;
    If ReadKey=#0 Then ReadKey;
   End;
  End;
  WriteUserGrid;
  Win:=True;
  For i:=1 to 9 do For j:=1 to 9 do If UserGrid[i,j,1]<>SolutionGrid[i,j]Then Win:=False;
  If(Win)Then Begin
   ClearDevice;
   SetColor(White);
   SetLineStyle(0,0,0);
   OutTextXY(5,200,'F‚licitations, vous avez r‚ussie !');
   If ReadKey=#0 Then ReadKey;
   Key:=#27;
  End;
 Until UpCase(Key) in[#27,'Q','X'];
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('SODOKU : Cette commande permet de lancer le jeu SODOKU.');
  WriteLn;
  WriteLn('Syntaxe : SODOKU [/PLAY]');
  WriteLn;
  WriteLn(' /PLAY   Permet de jouer imm‚diatement');
  WriteLn;
 End
  Else
 Begin
  InitScr;
  If StrToUpper(ParamStr(1))='/PLAY'Then Play Else
  Repeat
   ClearDevice;
   ClearViewPort;
   SetColor(Blue);
   SetTextStyle(0,0,11);
   OutTextXY(100,20,'Sudoku');
   SetColor(White);
   SetTextStyle(0,0,0);
   OutTextXY(150,300,'1 - Consulter les instructions');
   OutTextXY(150,315,'2 - Jouer au jeu Sudoku');
   OutTextXY(150,330,'X - Quitter');
   B:=UpCase(ReadKey);
   Case B of
    '1':If(Instruction)Then Play;
    '2':Play;
   End;
  Until B in[#27,'Q','X'];
 End;
END.
