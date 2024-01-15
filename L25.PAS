{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program L25;

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Label
 Gagne,10,20,13,560;
Const
 StartX=115;
Var
 Finish,PlayNow:Boolean;
 XPosition:Byte;
 YPosition:Byte;
 A,B:Byte;
 Erreur:Integer;
 TypeCase:Byte;
 Quitte:Boolean;
 Nombre:Byte;
 K:Char;
 TableauL25:Packed Array[1..5,1..5] of Byte;
 TableauCase:Packed Array[0..2000] of Byte;
 Touche:Word;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function Dupl(C:String;Num:LongInt):String;
Var
 I:LongInt;
 S:String;
Begin
 S:='';
 For I:=1 to Num do S:=S+C;
 Dupl:=S;
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

Procedure AfficheCase(XPosition,YPosition,Couleur:Byte);
Var
 X1,Y1,X2,Y2,XR,YR,XC,YC:Word;
Begin
 If((Couleur=0)and(((XPosition + YPosition * 5) Mod 2)=0))Then Couleur := 3;
 SetColor(Couleur);
 X1:=StartX+3+16*XPosition;
 Y1:=53+16*YPosition;
 X2:=StartX+12+16*XPosition;
 Y2:=62+16*YPosition;
 XR:=((X2-X1) shr 1)+1;
 YR:=((Y2-Y1) shr 1)+1;
 XC:=X1+XR;
 YC:=Y1+YR;
 FillEllipse(XC,YC,XR,YR);
End;

BEGIN { Main L 2 5 }
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('L25 : Cette commande permet de lancer le jeu ',
                     'L25.');
  WriteLn;
  WriteLn('Syntaxe : L25 [/PLAY]');
  WriteLn;
  WriteLn(' /PLAY   Permet de jouer imm‚diatement');
 End
  Else
 Begin
  Finish:=False;
  PlayNow:=False;
  If(StrToUpper(ParamStr(1))='/PLAY')Then PlayNow:=True;
  Repeat
   If(PlayNow)Then Begin
    K:='2';
   End
    Else
   Begin
    TextMode(C80);
    ClrScr;
    TextColor(Yellow);
    WriteLn(' ':30,'þþþ      þþþþþþ   þþþþþþ');
    WriteLn(' ':30,'þþ      þ     þþ þ      ');
    WriteLn(' ':30,'þþ            þþþ       ');
    WriteLn(' ':30,'þþ           þþ þþþþþþ  ');
    WriteLn(' ':30,'þþ          þþ       þþ ');
    WriteLn(' ':30,'þþ         þþ         þþ');
    WriteLn(' ':30,'þþ     þ  þþ          þþ');
    WriteLn(' ':30,'þþ    þþ þþ    þþþ   þþ ');
    WriteLn(' ':30,'þþþþþþþþþþþþþþþþ þþþþþ  ');
    TextColor(7);
    WriteLn;
    WriteLn;
    WriteLn(' ':30,Dupl(#254,24));
    WriteLn(' ':30,'1 - Instructions');
    WriteLn(' ':30,'2 - Jouer … L25');
    WriteLn(' ':30,'3 - Quitter');
    WriteLn(' ':30,Dupl(#254,24));
    Write('Entrez votre choix : ');
    K:=UpCase(ReadKey);
    If K=#0 Then ReadKey;
    WriteLn(K);
   End;
   Case K of
    '1':Begin
      { Instruction }
     ClrScr;
     TextColor(White);
     WriteLn(' ':38,'L 2 5');
     WriteLn;
     WriteLn;
     WriteLn;
     TextColor(7);
     WriteLn('Le but du jeu est de remplir 25 cases (5 x 5) en se ');
     WriteLn;
     WriteLn('d‚pla‡ant comme un cheval au ‚chec sans jamais touch‚s ');
     WriteLn;
     WriteLn('deux fois la mˆme case.');
     WriteLn;
     WriteLn;
     WriteLn('Vous pouvez d‚placer le curseur sur le prochain coup en ');
     WriteLn;
     WriteLn('utilisant les touche de flŠches :');
     WriteLn;
     TextBackground(7);TextColor(0);
     Write(' ',#27,' ');
     TextBackground(0);TextColor(7);
     Write(' pour d‚placer … gauche et utiliser la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#26,' ');
     TextBackground(0);TextColor(7);
     WriteLn(' pour aller');
     WriteLn;
     Write('… droite, la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#24,' ');
     TextBackground(0);TextColor(7);
     Write(' pour monter et la touche ');
     TextBackground(7);TextColor(0);
     Write(' ',#25,' ');
     TextBackground(0);TextColor(7);
     WriteLn(' pour');
     WriteLn;
     WriteLn('descendre.');
     WriteLn;
     Write('Ensuite, vous cliquez sur la touche ');
     TextBackground(7);TextColor(0);
     Write(' ','ENTER',' ');
     TextBackground(0);TextColor(7);
     WriteLn('.');
     WriteLn;
     WriteLn;
     Write('Presse une touche pour continuer...');
     If ReadKey=#0 Then ReadKey;
    End;
    '2','P':Begin
     InitScr;
     For A := 1 to 5 do For B := 1 to 5 do TableauL25[A,B] := 0;
     SetColor(5);
     OutTextXY(16*8,1*8,'L 2 5');
     TypeCase := 0;
     For XPosition := 0 to 4 do Begin
      For YPosition := 0 to 4 do Begin
       If(TypeCase=0)Then Begin
        SetColor(3);
        Rectangle(StartX+XPosition*16,50+YPosition*16,StartX+15+XPosition*16,65+YPosition*16);
        SetColor(1);
        Rectangle(StartX+XPosition*16,50+YPosition*16,StartX+15+XPosition*16,65+YPosition*16);
       End
        Else
       Begin
        SetColor(0);
        Rectangle(StartX+XPosition*16,50+YPosition*16,StartX+15+XPosition*16,65+YPosition*16);
       End;
       TypeCase:=(TypeCase + 1) and 1;
      End;
     End;
     Quitte:=False;
     XPosition:=0;
     YPosition:=0;
     Nombre:=1;
     A:=0;
     B:=0;
     TableauL25[1,1]:=1;
     TypeCase:=0;
     AfficheCase(0,0,1);
     Repeat
      Repeat
       GetImage(StartX+XPosition*16,50+YPosition*16,StartX+15+XPosition*16,65+YPosition*16,TableauCase);
       Erreur:=0;
       Repeat
        Erreur := (Erreur + 1) and $F;
        If(Erreur=1)Then Begin
         PutImage(StartX+XPosition*16,50+YPosition*16,TableauCase,NotPut);
        End;
        If(Erreur=$8)Then Begin
         PutImage(StartX+XPosition*16,50+YPosition*16,TableauCase,NormalPut);
        End;
        If((TypeCase > 0)and(Erreur=$F))Then Begin
         Inc(TypeCase);
         If(TypeCase=6)Then Begin
          TypeCase := 0;
         End;
        End;
        Delay(10);
       Until KeyPressed;
       Touche:=Byte(ReadKey);
       If Touche=0 Then Touche:=Byte(ReadKey) shl 8;
       PutImage(StartX+XPosition*16,50+YPosition*16,TableauCase,NormalPut);
       TypeCase:=1;
       Case Hi(Touche) of
        72: If(YPosition>0)Then Dec(YPosition) else YPosition := 4;
        75: If(XPosition>0)Then Dec(XPosition) else XPosition := 4;
        77: If(XPosition<4)Then Inc(XPosition) else XPosition := 0;
        80: If(YPosition<4)Then Inc(YPosition) else YPosition := 0;
       End;
       If(Lo(Touche)=27)Then Begin
        SetColor(5);
        OutTextXY(1*8,24*8,'Vous avez abandonne!');
        Halt(0);
       End;
    13:If(Lo(Touche)=13)Then Begin
        If(TableauL25[XPosition+1,YPosition+1]=1)Then Touche := 0;
        If Not((((A+1=XPosition+1-1)or(A+1=XPosition+1+1))and((B+1=YPosition+1-2)or(B+1=YPosition+1+2)))or
        (((A+1=XPosition+1-2)or(A+1=XPosition+1+2))and((B+1=YPosition+1-1)or(B+1=YPosition+1+1))))Then Touche := 0;
      End;
     Until Lo(Touche) = 13;
     If((XPosition+1=1)and(YPosition+1=1)AND(TableauL25[2,3]=1)AND(TableauL25[3,2]=1))Then Goto 560;
     If((XPosition+1=1)and(YPosition+1=2)AND(TableauL25[3,1]=1)AND(TableauL25[3,3]=1)AND(TableauL25[2,4]=1))THEN Goto 560;
     If((XPosition+1=1)and(YPosition+1=3)AND(TableauL25[2,1]=1)AND(TableauL25[2,5]=1)AND
        (TableauL25[3,2]=1)AND(TableauL25[3,4]=1))THEN Goto 560;
     If((XPosition+1=1)and(YPosition+1=4)AND(TableauL25[2,2]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[3,5]=1))THEN Goto 560;
     If((XPosition+1=1)and(YPosition+1=5)AND(TableauL25[2,3]=1)AND(TableauL25[3,4]=1))THEN Goto 560;
     If((XPosition+1=2)and(YPosition+1=1)AND(TableauL25[1,3]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[4,2]=1))Then Goto 560;
     If((XPosition+1=2)and(YPosition+1=2)AND(TableauL25[1,4]=1)AND(TableauL25[3,4]=1)AND
       (TableauL25[4,1]=1)AND(TableauL25[4,3]=1))Then Goto 560;
     If((XPosition+1=2)and(YPosition+1=3)AND(TableauL25[1,1]=1)AND(TableauL25[1,5]=1)AND
       (TableauL25[3,1]=1)AND(TableauL25[3,5]=1)AND(TableauL25[4,2]=1)AND(TableauL25[4,4]=1))THEN Goto 560;
     If((XPosition+1=2)and(YPosition+1=4)AND(TableauL25[1,2]=1)AND(TableauL25[3,2]=1)AND
       (TableauL25[4,3]=1)AND(TableauL25[4,5]=1))Then Goto 560;
     If((XPosition+1=2)and(YPosition+1=5)AND(TableauL25[1,3]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[4,4]=1))Then Goto 560;
     If((XPosition+1=3)and(YPosition+1=1)AND(TableauL25[1,2]=1)AND(TableauL25[2,3]=1)AND
       (TableauL25[4,3]=1)AND(TableauL25[5,2]=1))Then Goto 560;
     If((XPosition+1=3)and(YPosition+1=2)AND(TableauL25[1,1]=1)AND(TableauL25[1,3]=1)AND
       (TableauL25[2,4]=1)AND(TableauL25[4,4]=1)AND(TableauL25[5,1]=1)AND(TableauL25[5,3]=1))THEN Goto 560;
     If((XPosition+1=3)and(YPosition+1=3)AND(TableauL25[1,2]=1)AND(TableauL25[1,4]=1)AND
       (TableauL25[2,1]=1)AND(TableauL25[2,5]=1)AND(TableauL25[4,1]=1)AND
       (TableauL25[4,5]=1)AND(TableauL25[5,2]=1)AND(TableauL25[5,4]=1))THEN Goto 560;
     If((XPosition+1=3)and(YPosition+1=4)AND(TableauL25[1,3]=1)AND(TableauL25[1,5]=1)AND
       (TableauL25[2,2]=1)AND(TableauL25[4,2]=1)AND(TableauL25[5,3]=1)AND(TableauL25[5,5]=1))THEN Goto 560;
     If((XPosition+1=3)and(YPosition+1=5)AND(TableauL25[1,4]=1)AND(TableauL25[2,3]=1)AND
       (TableauL25[4,3]=1)AND(TableauL25[5,4]=1))THEN Goto 560;
     If((XPosition+1=4)and(YPosition+1=1)AND(TableauL25[2,2]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[5,3]=1))Then Goto 560;
     If((XPosition+1=4)and(YPosition+1=2)AND(TableauL25[2,1]=1)AND(TableauL25[2,3]=1)AND
       (TableauL25[3,4]=1)AND(TableauL25[5,4]=1))THEN Goto 560;
     If((XPosition+1=4)and(YPosition+1=3)AND(TableauL25[2,2]=1)AND(TableauL25[2,4]=1)AND
       (TableauL25[3,1]=1)AND(TableauL25[3,5]=1)AND(TableauL25[5,1]=1)AND(TableauL25[5,5]=1))THEN Goto 560;
     If((XPosition+1=4)and(YPosition+1=4)AND(TableauL25[2,3]=1)AND(TableauL25[2,5]=1)AND
       (TableauL25[3,2]=1)AND(TableauL25[5,2]=1))THEN Goto 560;
     If((XPosition+1=4)and(YPosition+1=5)AND(TableauL25[2,4]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[5,3]=1))Then Goto 560;
     If((XPosition+1=5)and(YPosition+1=1)AND(TableauL25[3,2]=1)AND(TableauL25[4,3]=1))THEN Goto 560;
     If((XPosition+1=5)and(YPosition+1=2)AND(TableauL25[3,1]=1)AND(TableauL25[3,3]=1)AND
       (TableauL25[4,4]=1))Then Goto 560;
     If((XPosition+1=5)and(YPosition+1=3)AND(TableauL25[3,2]=1)AND(TableauL25[3,4]=1)AND
       (TableauL25[4,1]=1)AND(TableauL25[4,5]=1))THEN Goto 560;
     If((XPosition+1=5)and(YPosition+1=4)AND(TableauL25[3,3]=1)AND(TableauL25[3,5]=1)AND
       (TableauL25[4,2]=1))Then Goto 560;
     If((XPosition+1=5)and(YPosition+1=5)AND(TableauL25[3,4]=1)AND(TableauL25[4,3]=1))Then Goto 560;
     Inc(Nombre);
     AfficheCase(A,B,1);
     AfficheCase(XPosition,YPosition,2);
     TableauL25[XPosition+1,YPosition+1] := 1;
     A := XPosition;
     B := YPosition;
     If(Nombre>24)Then Begin
Gagne:
      SetColor(5);
      OutTextXY(1*8,24*8,'Tu as gagner!');
      Halt(1);
     End;
    Until (Quitte);
560:
     AfficheCase(A,B,1);
     AfficheCase(XPosition,YPosition,2);
     If(Nombre = 24)Then Goto Gagne;
     SetColor(5);
     OutTextXY(1*8,24*8,'Vous avez perdue.');
     If ReadKey=#0Then ReadKey;
     Finish:=True;
    End;
    '3','Q',#27:Finish:=True;
   End;
  Until Finish;
  TextMode(C80);
  ClrScr;
 End;
END.
