{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program Yahtzee;

Uses Crt;

Const
 NUM_DICE=5;

Var
 Finish,PlayNow:Boolean;
 ScoreBoard:Array[1..6,0..12] of Integer;
 BonusBoard:Array[1..6]of Integer;
 TotalBoard:Array[1..6]of Integer;
 Dices:Array[0..NUM_DICE] of Integer;
 Total,Bonus,Rounds,I,J,H:Integer;
 Err:Word;
 Input:String;
 K:Char;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function ExtractWord(Pos:Integer;S:String):String;
Var
 I:Integer;
 CurrPos:Integer;
 CurrStr:String;
Begin
 ExtractWord:='';
 CurrStr:='';
 CurrPos:=1;
 For I:=1 to Length(S)do Begin
  If S[I]=' 'Then Begin
   If(CurrPos=Pos)Then Begin
    ExtractWord:=CurrStr;
    Exit;
   End;
   Inc(CurrPos);
   CurrStr:='';
  End
   Else
  CurrStr:=CurrStr+S[I];
 End;
 If(CurrPos=Pos)Then Begin
  ExtractWord:=CurrStr;
 End;
End;

Function Dupl(C:String;Num:Integer):String;
Var
 I:Integer;
 S:String;
Begin
 S:='';
 For I:=1 to Num do S:=S+C;
 Dupl:=S;
End;

Function PadLeft(S:String;Space:Byte):String;Begin
 While Length(S)<Space do S:=' '+S;
 PadLeft:=S;
End;

Function PadRight(S:String;Space:Byte):String;
Var
 I:Byte;
Begin
 If Length(S)<Space Then For I:=Length(S)+1 to Space do S:=S+' ';
 PadRight:=S;
End;

Function Compare(a,b:Integer):Integer;Begin
 Compare:= a-b;
End;

Procedure QuickSort(Var FList:Array of Integer;L,R:Integer);
Var
 I,J,P:LongInt;
 T:Integer;
Begin
 Repeat
  I:=L;
  J:=R;
  P:=(L+R) div 2;
  Repeat
   While Compare(FList[P],FList[i])>0 do I:=I+1;
   While Compare(FList[P],FList[J])<0 do J:=J-1;
   If I <= J Then Begin
    T:=FList[I];
    Flist[I]:=FList[J];
    FList[J]:=T;
    If P=I Then P:=J Else
    If P=J Then P:=I;
    I:=I+1;
    J:=J-1;
   End;
  Until I>J;
  If L<J Then QuickSort(FList,L,J);
  L:=I;
 Until I>=R;
End;

Function RandomDice:Integer;Begin
 RandomDice:=Random(6)+1;
End;

Function CalculateUpper(Choice:Integer):Boolean;
Var
 Points,i:Integer;
Begin
 Points:=0;
 If ScoreBoard[H,choice-1] >= 0 Then Begin
  CalculateUpper:=False;
  Exit;
 End;
 For I:=0 to NUM_DICE-1 do Begin
  If Dices[i]=Choice Then Points:=Points+Choice;
 End;
 ScoreBoard[H,Choice-1]:=Points;
 CalculateUpper:=True;
End;

Function Check_of_a_kind(Number:Integer;Var Dices:Array of Integer):Boolean;
Var
 Index,Points,Count,I,J:Integer;
Begin
 Index:=0;
 Points:=0;
 Count:=0;
 If Number=3 Then Index:=6 Else
 If Number=4 Then Index:=7
             Else Index:=11;
 If ScoreBoard[H,Index]>=0 Then Begin
  Check_of_a_kind:=False;
  Exit;
 End;
 For I:=1 to 6 do Begin
  For J:=0 to NUM_DICE-1 do Begin
   If Dices[J]=I Then Inc(count);
  End;
  If Count>=Number Then Begin
   For J:=0 to NUM_DICE-1 do Points:=Points+Dices[j];
   If Number=5 Then Points:=50;
   ScoreBoard[H,Index]:=Points;
   Check_of_a_kind:=True;
   Exit;
  End;
  Count:=0;
 End;
 ScoreBoard[H,Index]:=0;
 Check_of_a_kind:=True;
End;

Function Check_full_house(Var Dices:Array of Integer):Boolean;
Var
 Points,I,Count1,Count2:Integer;
Begin
 Points:=0;
 Count1:=0;
 Count2:=0;
 If ScoreBoard[H,8]>=0 then Begin
  Check_full_house:=False;
  Exit;
 End;
 QuickSort(dices, 0,NUM_DICE);
 For I:=0 to 2 do Begin
  If Dices[0]=Dices[I]Then Inc(Count1);
 End;
 For I:=NUM_DICE-1 downto 3 do Begin
  If Dices[NUM_DICE-1]=Dices[I]Then Inc(Count2);
 End;
 If Count1+Count2=5 Then Points:=25;
 ScoreBoard[H,8]:=Points;
 Check_full_house:=True;
End;

Function Check_straight(Choice:Integer;Var Dices:Array of Integer):Boolean;
Var
 Points,I,J,Straight,RepeatFlag,Index,Length:Integer;
Begin
 Points:=0;
 If Choice=4 Then Begin
  Index:=9;
  Length:=3;
 End
  Else
 Begin
  Index:=10;
  Length:=4;
 End;
 If ScoreBoard[H,Index]>=0 Then Begin
  Check_Straight:=False;
  Exit;
 End;
 QuickSort(Dices,0,NUM_DICE);
 For I:=0 to 2 do Begin
  Straight:=1;
  RepeatFlag:=0;
  For J:=0 to Length-1 do Begin
   If(Dices[j]-Dices[j+1])<>-1 Then Begin
    If(Dices[j]=Dices[j+1])and(RepeatFlag=0)Then Begin
     RepeatFlag := 1;
     Continue;
    End
     Else
    Begin
     Straight:=0;
     Break;
    End;
   End;
  End;
  If Straight<>0 Then Begin
   If Choice=4 Then Points:=30
               Else Points:=40;
  End;
 End;
 ScoreBoard[H,Index]:=Points;
 Check_straight:=True;
End;

Procedure ShowDice(X,Y,Dice:Integer);
Var
 OldX,OldY:Integer;
Begin
 OldX:=WhereX;
 OldY:=WhereY;
 TextBackground(7);
 TextColor(0);
 Case Dice of
  1:Begin
   GotoXY(X,Y);
   Write(' ','   ',' ');
   GotoXY(X,Y+1);
   Write(' ',' ',#254,' ',' ');
   GotoXY(X,Y+2);
   Write(' ','   ',' ');
  End;
  2:Begin
   GotoXY(X,Y);
   Write(' ',#254,'  ',' ');
   GotoXY(X,Y+1);
   Write(' ','   ',' ');
   GotoXY(X,Y+2);
   Write(' ','  ',#254,' ');
  End;
  3:Begin
   GotoXY(X,Y);
   Write(' ',#254,'  ',' ');
   GotoXY(X,Y+1);
   Write(' ',' ',#254,' ',' ');
   GotoXY(X,Y+2);
   Write(' ','  ',#254,' ');
  End;
  4:Begin
   GotoXY(X,Y);
   Write(' ',#254,' ',#254,' ');
   GotoXY(X,Y+1);
   Write(' ','   ',' ');
   GotoXY(X,Y+2);
   Write(' ',#254,' ',#254,' ');
  End;
  5:Begin
   GotoXY(X,Y);
   Write(' ',#254,' ',#254,' ');
   GotoXY(X,Y+1);
   Write(' ',' ',#254,' ',' ');
   GotoXY(X,Y+2);
   Write(' ',#254,' ',#254,' ');
  End;
  6:Begin
   GotoXY(X,Y);
   Write(' ',#254,' ',#254,' ');
   GotoXY(X,Y+1);
   Write(' ',#254,' ',#254,' ');
   GotoXY(X,Y+2);
   Write(' ',#254,' ',#254,' ');
  End;
 End;
 TextBackground(0);
 TextColor(7);
 GotoXY(OldX,OldY);
End;

Procedure PrintScores(Rounds:Integer);
Var
 I,J,Total,Bonus:Integer;
Begin
 ClrScr;
 TextColor(7);
 Total:=0;
 Bonus:=0;
 For I:=0 to 12 do Begin
  If ScoreBoard[H,I]>0 Then Total:=Total+ScoreBoard[H,I];
 End;
 If ScoreBoard[H,0]+ScoreBoard[H,1]+ScoreBoard[H,2]+
    ScoreBoard[H,3]+ScoreBoard[H,4]+ScoreBoard[H,5]>=63 Then Bonus:=35
                                                        Else Bonus:=0;
 BonusBoard[H]:=Bonus;
 GotoXY(60,2);
 Write('TOUR : ',Rounds+1);
 GotoXY(60,3);
 Write('PARTIE : ',H);
 GotoXY(1,1);
 WriteLn(#201,Dupl(#205,30),#209,Dupl(#205,2),#209,Dupl(#205,2),#209,
              Dupl(#205,2),#209,Dupl(#205,2),#209,Dupl(#205,2),#209,
              Dupl(#205,2),#187);
 WriteLn(#186,PadRight('SECTION SUPERIEUR',30),#186,'1 ',#179,'2 ',#179,
         '3 ',#179,'4 ',#179,'5 ',#179,'6 ',#186);
 WriteLn(#204,Dupl(#205,30),#206,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#216,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#185);
 Write(#186,PadRight('Les as ',29),'1',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,0]>=0 Then Write(ScoreBoard[J,0]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'1');
 Write(#186,PadRight('Les deux',29),'2',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,1]>=0 Then Write(ScoreBoard[J,1]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'2');
 Write(#186,PadRight('Les trois',29),'3',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,2]>=0 Then Write(ScoreBoard[J,2]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'3');
 Write(#186,PadRight('Les quatres',29),'4',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,3]>=0 Then Write(ScoreBoard[J,3]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'4');
 Write(#186,PadRight('Les cinq',29),'5',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,4]>=0 Then Write(ScoreBoard[J,4]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'5');
 Write(#186,PadRight('Les six',29),'6',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,5]>=0 Then Write(ScoreBoard[J,5]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'6');
 Write(#186,PadRight('Section sup‚rieure de prime',30),#186);
 For J:=1 to 6 do Begin
  If BonusBoard[J]>=0 Then Write(Bonus:2)
                      Else Write(0:2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186);
 WriteLn(#204,Dupl(#205,30),#206,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#216,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#185);
 WriteLn(#186,PadRight('SECTION INFERIEUR',30),#186,'1 ',#179,'2 ',#179,
         '3 ',#179,'4 ',#179,'5 ',#179,'6 ',#186);
 WriteLn(#204,Dupl(#205,30),#206,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#216,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#185);
 Write(#186,PadRight('Brelan (3)',29),'7',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,6]>=0 Then Write(ScoreBoard[J,6]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'7');
 Write(#186,PadRight('Carr‚ (4)',29),'8',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,7]>=0 Then Write(ScoreBoard[J,7]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'8');
 Write(#186,PadRight('Petite suite',29),'9',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,8]>=0 Then Write(ScoreBoard[J,8]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'9');
 Write(#186,PadRight('Grande suite',29),'A',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,9]>=0 Then Write(ScoreBoard[J,9]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'A');
 Write(#186,PadRight('Full',29),'B',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,10]>=0 Then Write(ScoreBoard[J,10]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'B');
 Write(#186,PadRight('Yahtzee',29),'C',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,11]>=0 Then Write(ScoreBoard[J,11]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'C');
 Write(#186,PadRight('Chance',29),'D',#186);
 For J:=1 to 6 do Begin
  If ScoreBoard[J,12]>=0 Then Write(ScoreBoard[J,12]:2)
                        Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186,'D');
 WriteLn(#204,Dupl(#205,30),#206,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#216,Dupl(#205,2),#216,Dupl(#205,2),#216,
              Dupl(#205,2),#185);
 Write(#186,PadRight('Total g‚n‚ral',30),#186);
 TotalBoard[H]:=Total;
 For J:=1 to 6 do Begin
  If TotalBoard[J]>=0 Then Write(TotalBoard[J]:2)
                      Else Write(' ':2);
  If J<6 Then Write(#179);
 End;
 WriteLn(#186);
 WriteLn(#200,Dupl(#205,30),#202,Dupl(#205,2),#207,Dupl(#205,2),#207,
              Dupl(#205,2),#207,Dupl(#205,2),#207,Dupl(#205,2),#207,
              Dupl(#205,2),#188);
End;

Var
 Num_of_reroll,Index,Selection,Choice:Integer;
 Token:String;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('YATHZEE : Cette commande permet de lancer le jeu ',
                     'Yathzee (jeu de d‚s).');
  WriteLn;
  WriteLn('Syntaxe : YATHZEE [/PLAY]');
  WriteLn;
  WriteLn(' /PLAY   Permet de jouer imm‚diatement');
 End
  Else
 Begin
  Finish:=False;
  If(StrToUpper(ParamStr(1))='/PLAY')Then PlayNow:=True;
  Repeat
   If(PlayNow)Then Begin
    K:='2';
   End
    Else
   Begin
    ClrScr;
    TextColor(LightBlue);
    WriteLn(' ':12,'                                                        ');
    WriteLn(' ':12,'ÛÛ    Û                   Û                             ');
    WriteLn(' ':12,'ÛÛ    Û            Û     Û Û                            ');
    WriteLn(' ':12,' Û    Û            Û     Û Û                            ');
    WriteLn(' ':12,' Û    Û            Û     ÛÛ                             ');
    WriteLn(' ':12,' Û    Û          ÛÛÛÛÛ   Û                              ');
    WriteLn(' ':12,' Û   ÛÛ   ÛÛÛÛ     Û     Û ÛÛÛ   ÛÛÛÛÛ    ÛÛÛÛ    ÛÛÛÛ  ');
    WriteLn(' ':12,' Û  Û Û  Û    Û   ÛÛ     ÛÛ   Û Û     Û  Û    Û  Û    Û ');
    WriteLn(' ':12,'  ÛÛ  Û Û     Û  Û Û     Û    Û    ÛÛÛ  Û   ÛÛ  Û   ÛÛ  ');
    WriteLn(' ':12,'      ÛÛÛ     Û Û  Û    ÛÛ    Û       Û Û ÛÛ    Û ÛÛ    ');
    WriteLn(' ':12,'      Û Û    ÛÛÛ   Û   Û Û    ÛÛ    ÛÛÛÛÛÛ     ÛÛÛ     Û');
    WriteLn(' ':12,'     ÛÛ  ÛÛÛÛ Û     ÛÛÛ  Û    Û    Û  Û  ÛÛÛÛÛÛ  ÛÛÛÛÛÛ ');
    WriteLn(' ':12,'    Û Û                           Û  Û                  ');
    WriteLn(' ':12,'    ÛÛ                            ÛÛÛ                   ');
    WriteLn(' ':12,'                                                        ');
    WriteLn(' ':12,'                                                        ');
    TextColor(7);
    WriteLn;
    WriteLn(' ':30,Dupl(#196,20));
    WriteLn;
    WriteLn(' ':30,'1 - Instructions');
    WriteLn;
    WriteLn(' ':30,'2 - Jouer … Yathzee');
    WriteLn;
    WriteLn(' ':30,'3 - Quitter');
    WriteLn;
    WriteLn(' ':30,Dupl(#196,20));
    WriteLn;
    Write('Entrez votre choix : ');
    K:=UpCase(ReadKey);
    If K=#0 Then ReadKey;
    WriteLn(K);
   End;
   Case K of
    '1':Begin
      { Instruction }
     ClrScr;
     GotoXY(32,1);
     TextColor(Yellow);
     WriteLn('Y A H T Z E E');
     TextColor(White);
     WriteLn;
     WriteLn('Explications de la feuille de pointage :');
     WriteLn;
     WriteLn('Partie sup‚rieure');
     WriteLn;
     TextColor(7);
     WriteLn(' As :     Total de tous les d‚s de valeur 1 (exemple 1-2-2-4-6 = 1 points ');
     WriteLn('          ou 1-1-1-3-5 = 3 points).');
     WriteLn(' Deux :   Total de tous les d‚s … 2 valeurs (exemple 2-1-5-3-5 = 2 points ');
     WriteLn('          ou 2-2-2-2-4 = 8 points).');
     WriteLn(' Trois :  Total de tous les d‚s … 3 valeurs (exemple 3-1-1-4-5 = 3 points ');
     WriteLn('          ou 3-3-3-2-4 = 9 points).');
     WriteLn(' Quatre : Total de tous les d‚s … 4 valeurs (exemple 4-1-3-2-5 = 4 points ');
     WriteLn('          ou 4-4-3-2-5 = 8 points).');
     WriteLn(' Cinq :   Total de tous les d‚s … 5 valeurs (exemple 5-1-3-2-6 = 5 points ou ');
     WriteLn('          5-5-5-2-1 = 15 points).');
     WriteLn(' Six :    Total de tous les d‚s … 6 valeurs (exemple 6-1-2-3-4 = 6 points ou ');
     WriteLn('          6-6-6-6-1 = 24 points).');
     WriteLn(' [automatique] Bonus As-Six : gagnez un bonus de 35 si vous obtenez au moins ');
     WriteLn('                          63 au total dans le reste de la section sup‚rieure.');
     TextColor(White);
     WriteLn('Partie inf‚rieure');
     TextColor(7);
     WriteLn;
     WriteLn(' Brelan : Gagnez des points ‚gaux … la somme des valeurs des d‚s si vous en ');
     WriteLn('          poss‚dez au moins 3 de mˆme valeur (exemple 1-1-1-2-2 = 7 points ');
     WriteLn('          ou 5-5-5-2-2 = 19 points).');
     WriteLn(' Carr‚ :  Gagnez des points ‚gaux … la somme des valeurs des d‚s si vous en ');
     WriteLn('          poss‚dez au moins 4 de mˆme valeur (exemple 1-1-1-1-2 = 6 points ou ');
     WriteLn('          5-5-5-5-2 = 22 points).');
     WriteLn(' Full :   Gagnez 25 points si vous obtenez 2 d''une valeur et 3 d''une autre ');
     WriteLn('          valeur (exemple 1-1-2-2-2 ou 3-3-5-5-5 ou 6-6-2-2-2).');
     WriteLn(' Petite suite : Gagnez 30 points si vous obtenez une suite de 4 (exemple ');
     WriteLn('                1-2-3-4-* ou 2-3-4-5-* ou 3-4-5-6-*)');
     WriteLn(' Grande suite : Gagnez 40 points si vous obtenez une s‚rie de 5 (exemple ');
     WriteLn('                1-2-3-4-5 ou 2-3-4-5-6)');
     WriteLn(' Yahtzee :Gagnez 50 points si vous obtenez 5 de mˆme valeur (exemple 1-1-1-1-1 ');
     WriteLn('          ou 2-2-2-2-2)');
     WriteLn(' Chance : Gagnez des points ‚gaux … la somme des valeurs des d‚s (exemple ');
     WriteLn('          1-1-1-1-1 = 5 points ou 1-2-3-4-5 = 15 points ou 5-5-5-6-6 = ');
     WriteLn('          27 points)');
     WriteLn('[automatique] Bonus Yahtzee : gagnez un bonus de 100 pour chaque Yahtzee lanc‚ ');
     WriteLn('                              aprŠs avoir d‚j… marqu‚ un Yahtzee de 50 points');
     WriteLn('[automatique] Total : votre score total calcul‚ … la fin de la partie');
     WriteLn;
     Write('Presse une touche pour retourner au menu');
     If ReadKey=#0 Then ReadKey;
    End;
    'P','2':Begin
     Randomize;
     Rounds:=0;
     For J:=1 to 6 do Begin
      BonusBoard[J]:=-1;
      TotalBoard[J]:=-1;
      For I:=0 to 12 do ScoreBoard[J,I]:=-1;
     End;
     H:=1;
     PrintScores(Rounds);
     For H:=1 to 6 do While Rounds<>13 do Begin
      For I:=0 to NUM_DICE-1 do Dices[i]:=RandomDice;
      For I:=0 to NUM_DICE-1 do Begin
       GotoXY(58,I*4+6);
       Write(I+1);
       ShowDice(60,I*4+5,Dices[I]);
      End;
      GotoXY(1,24);
      Num_of_reroll:=0;
      For I:=0 to 1 do Begin
       Write('Quel d‚s relancer (1 … 5) ? ');
       ReadLn(Input);
       If(Input='0')or(Input='Q')or(Input='QUIT')Then Begin
        Halt;
       End;
       Token:=ExtractWord(1,Input);
       While Token<>'' do Begin
        Val(Token,Index,Err);
        Dec(Index);
        If Index=-1 Then Break;
        If Index>4 Then Break;
        Inc(Num_Of_Reroll);
        Dices[Index]:=RandomDice;
        Token:=ExtractWord(2,Input);
        Input:='';
       End;
       If Num_of_reroll=0 Then Break;
       GotoXY(1,24);
       If I=0 Then Write('Votre deuxiŠme lanc‚ :')
              Else Write('Votre troisiŠme lanc‚ :');
       ClrEol;
       For J:=0 to NUM_DICE-1 do ShowDice(60,I*4+5,Dices[J]);
      End;
      GotoXY(1,24);
      Write('S‚lection (1 … 9 ou A … D) ? ');
      Case UpCase(ReadKey)of
       '1':CalculateUpper(1);
       '2':CalculateUpper(2);
       '3':CalculateUpper(3);
       '4':CalculateUpper(4);
       '5':CalculateUpper(5);
       '6':CalculateUpper(6);
       '7':Check_of_a_kind(3,Dices);
       '8':Check_of_a_kind(4,Dices);
       '9':Check_full_house(Dices);
       'A':Check_straight(4,Dices);
       'B':Check_straight(5,Dices);
       'C':Check_of_a_kind(5,Dices);
       'D':Begin
        If ScoreBoard[H,12]>=0 Then Break
         Else
        Begin
         ScoreBoard[H,12]:=0;
         For I:=0 to NUM_DICE-1 do ScoreBoard[H,12]:=ScoreBoard[H,12]+Dices[i];
        End;
       End;
       'Q':Halt;
      End;
      Total:=0;
      For I:=0 to 12 do Begin
       If ScoreBoard[H,I]>0 Then Total:=Total+ScoreBoard[H,I];
      End;
      PrintScores(Rounds);
      Inc(Rounds);
     End;
    End;
    '3','Q',#27:Finish:=True;
   End;
  Until Finish;
  ClrScr;
 End;
END.