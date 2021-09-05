Program PacMan;

Uses CRT;

Const
 {Code de touche clavier renvoyee par ReadKey}
 kbNoKey=0;{Pas de touche}
 kbEsc=$011B;{Escape}
 kbUp=$4800;{Up}
 kbLeft=$4B00;{Fleche de gauche (Left)}
 kbKeypad5=$4CF0;{5 du bloc numerique}
 kbRight=$4D00;{Fleche de droite (Right)}
 kbDn=$5000;{Fleche du bas (Down)}

Type
 ScreenArray=Array[0..23] of Array[0..30] of Byte;

Const
 InitialScreen:ScreenArray = (
  (00,00,07,03,03,03,03,03,03,03,03,03,03,03,03,16,03,03,03,03,03,03,03,03,03,03,03,03,08,00,00),
  (00,00,04,01,01,01,01,01,01,01,01,01,01,01,01,04,01,01,01,01,01,01,01,01,01,01,01,01,04,00,00),
  (00,00,04,01,07,03,03,08,01,07,03,03,03,08,01,04,01,07,03,03,03,08,01,07,03,03,08,01,04,00,00),
  (00,00,04,02,05,03,03,06,01,05,03,03,03,06,01,12,01,05,03,03,03,06,01,05,03,03,06,02,04,00,00),
  (00,00,04,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,04,00,00),
  (00,00,04,01,09,03,03,10,01,11,01,09,03,03,03,16,03,03,03,10,01,11,01,09,03,03,10,01,04,00,00),
  (00,00,04,01,01,01,01,01,01,04,01,01,01,01,01,04,01,01,01,01,01,04,01,01,01,01,01,01,04,00,00),
  (00,00,05,03,03,03,03,08,01,14,03,03,03,10,00,12,00,09,03,03,03,13,01,07,03,03,03,03,06,00,00),
  (00,00,00,00,00,00,00,04,01,04,00,00,00,00,00,00,00,00,00,00,00,04,01,04,00,00,00,00,00,00,00),
  (00,00,00,00,00,00,00,04,01,04,00,07,03,03,10,17,09,03,03,08,00,04,01,04,00,00,00,00,00,00,00),
  (09,03,03,03,03,03,03,06,01,12,00,04,00,00,00,00,00,00,00,04,00,12,01,05,03,03,03,03,03,03,10),
  (00,00,00,00,00,00,00,00,01,00,00,04,00,00,00,00,00,00,00,04,00,00,01,00,00,00,00,00,00,00,00),
  (09,03,03,03,03,03,03,08,01,11,00,04,00,00,00,00,00,00,00,04,00,11,01,07,03,03,03,03,03,03,10),
  (00,00,00,00,00,00,00,04,01,04,00,05,03,03,03,03,03,03,03,06,00,04,01,04,00,00,00,00,00,00,00),
  (00,00,00,00,00,00,00,04,01,04,00,00,00,00,00,00,00,00,00,00,00,04,01,04,00,00,00,00,00,00,00),
  (00,00,07,03,03,03,03,06,01,12,00,09,03,03,03,16,03,03,03,10,00,12,01,05,03,03,03,03,08,00,00),
  (00,00,04,01,01,01,01,01,01,01,01,01,01,01,01,04,01,01,01,01,01,01,01,01,01,01,01,01,04,00,00),
  (00,00,04,01,09,03,03,08,01,09,03,03,03,10,01,12,01,09,03,03,03,10,01,07,03,03,10,01,04,00,00),
  (00,00,04,02,01,01,01,04,01,01,01,01,01,01,01,00,01,01,01,01,01,01,01,04,01,01,01,02,04,00,00),
  (00,00,14,03,03,10,01,12,01,11,01,09,03,03,03,16,03,03,03,10,01,11,01,12,01,09,03,03,13,00,00),
  (00,00,04,01,01,01,01,01,01,04,01,01,01,01,01,04,01,01,01,01,01,04,01,01,01,01,01,01,04,00,00),
  (00,00,04,01,09,03,03,03,03,15,03,03,03,10,01,12,01,09,03,03,03,15,03,03,03,03,10,01,04,00,00),
  (00,00,04,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,04,00,00),
  (00,00,05,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,03,06,00,00)
);

Type
 DirectionType=(pLeft,pRight,pUp,pDown);

Var
 MouthOpen:Boolean;
 Screen:ScreenArray;
 ChaseTimer:Byte;
 ChaseGhost:Byte;
 CountPilule:Byte;
 Level,Live,Score,HiScore:LongInt;
 PlayerX,PlayerY:Byte;
 PlayerDirection:DirectionType;
 Ghosts:Array[0..3]of Record
  X,Y:Byte;
  Direction:DirectionType;
  Status:(Scatter,Chase);
  IsFrightened:Boolean;
  IsHome:Boolean;
  DotCount:Boolean;
  Speed:Byte;
 End;

Procedure InitData;
Var
 I:Byte;
Begin
 Score:=0;
 PlayerX:=15;
 PlayerY:=18;
 PlayerDirection:=pLeft;
 Ghosts[0].X:=15;Ghosts[0].Y:=12;Ghosts[0].DotCount:=False;
 Ghosts[1].X:=10;Ghosts[1].Y:=14;Ghosts[1].DotCount:=True;
 Ghosts[2].X:=10;Ghosts[2].Y:=16;Ghosts[2].DotCount:=True;
 Ghosts[3].X:=10;Ghosts[3].Y:=9;Ghosts[3].DotCount:=True;
 For I:=0 to 3 do Begin
  Ghosts[I].Direction:=pLeft;
  Ghosts[I].Status:=Scatter;
  Ghosts[I].IsFrightened:=False;
  Ghosts[I].IsHome:=True;
 End;
End;

Function Distance(X1,Y1,X2,Y2:Byte):Byte;
Var
 A,B:Byte;
Begin
 A:=Abs(X1-X2);
 B:=Abs(Y1-Y2);
 Distance:=Byte(Trunc(Sqrt(A*A+B*B)));
End;

Function AvailableLeft(X,Y:Byte):Boolean;Begin
 AvailableLeft:=Screen[Y,X-1]<=2;
End;

Function AvailableRight(X,Y:Byte):Boolean;Begin
 AvailableRight:=Screen[Y,X+1]<=2;
End;

Function AvailableUp(X,Y:Byte):Boolean;Begin
 AvailableUp:=Screen[Y-1,X]<=2;
End;

Function AvailableDown(X,Y:Byte):Boolean;Begin
 AvailableDown:=Screen[Y+1,X]<=2;
End;

Procedure FindDirection(I:Byte);Begin
 If PlayerX < Ghosts[I].X Then Begin
  If AvailableLeft(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pLeft
   Else
  Begin
   If PlayerY < Ghosts[I].Y Then Begin
    If AvailableUp(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pUp Else
    If AvailableDown(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pDown
                                             Else Ghosts[I].Direction:=pRight
   End;
  End;
 End
  Else
 If PlayerX > Ghosts[I].X Then Begin
  If AvailableRight(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pRight
   Else
  Begin
   If PlayerY < Ghosts[I].Y Then Begin
    If AvailableUp(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pUp Else
    If AvailableDown(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pDown
                                             Else Ghosts[I].Direction:=pLeft;
   End;
  End;
 End
  Else
 If PlayerY < Ghosts[I].Y Then Begin
  If AvailableUp(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pUp
   Else
  Begin
   If PlayerX < Ghosts[I].X Then Begin
    If AvailableLeft(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pLeft Else
    If AvailableRight(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pRight
                                              Else Ghosts[I].Direction:=pDown;
   End;
  End;
 End
  Else
 Begin
  If AvailableDown(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pDown
   Else
  Begin
   If PlayerX < Ghosts[I].X Then Begin
    If AvailableLeft(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pLeft Else
    If AvailableRight(Ghosts[I].X,Ghosts[I].Y)Then Ghosts[I].Direction:=pRight
                                             Else Ghosts[I].Direction:=pUp;
   End;
  End;
 End;
End;

Procedure RemovePacMan;Begin
 GotoXY(1+PlayerX,1+PlayerY);
 Write(' ');
End;

Procedure RemoveGhost(I:Byte);Begin
 GotoXY(1+Ghosts[I].X,1+Ghosts[I].Y);
 Case Screen[Ghosts[I].Y,Ghosts[I].X]of
  1:Begin
   TextColor(12);
   Write('.');
  End;
  2:Begin
   TextColor(13);
   Write('O');
  End;
  Else Write(' ');
 End;
End;

Function CheckCell:Boolean;
Var
 I:Byte;
Begin
 CheckCell:=False;
 Case Screen[PlayerY,PlayerX]of
  1:Begin
   Inc(Score,10);
   Inc(CountPilule);
   If CountPilule>=212Then CheckCell:=True;
  End;
  2:Begin
   Inc(Score,50);
   For I:=0 to 3do Ghosts[I].Status:=Chase;
   ChaseTimer:=100;
   ChaseGhost:=0;
  End;
 End;
 Screen[PlayerY,PlayerX]:=0;
 GotoXY(1,25);
 TextColor(15);
 Write('Niveau : ',Level,' Pointage : ',Score,' Vie : ',Live);
 If ChaseTimer>0Then Write('Temps : ',ChaseTimer,' Attraper : ',ChaseGhost);
 ClrEol;
End;

Procedure DisplayNewBoard;
Var
 X,Y:Byte;
Begin
 TextBackground(0);
 For Y:=0 to 23 do Begin
  For X:=0 to 30 do Begin
   GotoXY(X+1,Y+1);
   Case Screen[Y,X]of
    1:Begin
     TextColor(12);
     Write('.');
    End;
    2:Begin
     TextColor(13);
     Write('O');
    End;
    3:Begin
     TextColor((8+Level)and $F);
     Write('=');
    End;
    4:Begin
     TextColor((8+Level)and $F);
     Write('I');
    End;
    5..16:Begin
     TextColor((8+Level)and $F);
     Write('+');
    End;
    17:Begin
     TextColor(15);
     Write('-');
    End;
    Else Write(' ');
   End;
  End;
 End;
End;

Procedure Play;
Var
 K:Word;
 I:Byte;
Begin
 GotoXY(1+PlayerX,1+PlayerY);
 TextColor(14);
 Write(')');
 Repeat
  Repeat
   If ChaseTimer>0Then Dec(ChaseTimer);
   Case PlayerDirection of
    pUp:If AvailableUp(PlayerX,PlayerY)Then Begin
     RemovePacman;
     PlayerY:=PlayerY-1;
     If CheckCell Then Begin
      CountPilule:=0;
      Write('NIVEAU COMPLETE !!');
      Delay(2000);
      Inc(Level);
      Screen:=InitialScreen;
      InitData;
      DisplayNewBoard;
     End;
     GotoXY(1+PlayerX,1+PlayerY);
     If ChaseTimer>0Then TextBackground(10)
                    Else TextBackground(0);
     TextColor(14);
     MouthOpen:=Not MouthOpen;
     If(MouthOpen)Then Write('U')
                  Else Write('o');
     TextBackground(0);
    End;
    pDown:If AvailableDown(PlayerX,PlayerY)Then Begin
     RemovePacman;
     PlayerY:=PlayerY+1;
     If CheckCell Then Begin
      CountPilule:=0;
      Write('NIVEAU COMPLETE !!');
      Delay(2000);
      Inc(Level);
      Screen:=InitialScreen;
      InitData;
      DisplayNewBoard;
     End;
     GotoXY(1+PlayerX,1+PlayerY);
     If ChaseTimer>0Then TextBackground(10)
                    Else TextBackground(0);
     TextColor(14);
     MouthOpen:=Not MouthOpen;
     If(MouthOpen)Then Write('A')
                  Else Write('o');
     TextBackground(0);
    End;
    pLeft:If AvailableLeft(PlayerX,PlayerY)Then Begin
     RemovePacman;
     If PlayerX<2 Then PlayerX:=28
                  Else PlayerX:=PlayerX-1;
     If CheckCell Then Begin
      CountPilule:=0;
      Write('NIVEAU COMPLETE !!');
      Delay(2000);
      Inc(Level);
      Screen:=InitialScreen;
      InitData;
      DisplayNewBoard;
     End;
     If ChaseTimer>0Then TextBackground(10)
                    Else TextBackground(0);
     GotoXY(1+PlayerX,1+PlayerY);
     TextColor(14);
     MouthOpen:=Not MouthOpen;
     If(MouthOpen)Then Write(')')
                  Else Write('o');
     TextBackground(0);
    End;
    pRight:If AvailableRight(PlayerX,PlayerY)Then Begin
     RemovePacman;
     If PlayerX>28 Then PlayerX:=2
                   Else PlayerX:=PlayerX+1;
                        If ChaseTimer>0Then TextBackground(10)
                    Else TextBackground(0);
     If CheckCell Then Begin
      CountPilule:=0;
      Write('NIVEAU COMPLETE !!');
      Delay(2000);
      Inc(Level);
      Screen:=InitialScreen;
      InitData;
      DisplayNewBoard;
     End;
     GotoXY(1+PlayerX,1+PlayerY);
     TextColor(14);
     MouthOpen:=Not MouthOpen;
     If(MouthOpen)Then Write('(')
                  Else Write('o');
     TextBackground(0);
    End;
   End;
   For I:=0 to 3 do Begin
    Case Ghosts[I].Direction of
     pLeft:If AvailableLeft(Ghosts[I].X,Ghosts[I].Y)Then Begin
      RemoveGhost(I);
      Ghosts[I].X:=Ghosts[I].X-1;
      {CheckCellGhost;}
      GotoXY(1+Ghosts[I].X,1+Ghosts[I].Y);
      TextColor(10+I);
      Write('f');
     End
      Else
     FindDirection(I);
     pRight:If AvailableRight(Ghosts[I].X,Ghosts[I].Y)Then Begin
      RemoveGhost(I);
      Ghosts[I].X:=Ghosts[I].X+1;
      {CheckCellGhost;}
      GotoXY(1+Ghosts[I].X,1+Ghosts[I].Y);
      TextColor(10+I);
      Write('f');
     End
      Else
     FindDirection(I);
     pUp:If AvailableUp(Ghosts[I].X,Ghosts[I].Y)Then Begin
      RemoveGhost(I);
      Ghosts[I].Y:=Ghosts[I].Y-1;
      {CheckCellGhost;}
      GotoXY(1+Ghosts[I].X,1+Ghosts[I].Y);
      TextColor(10+I);
      Write('f');
     End
      Else
     FindDirection(I);
     pDown:If AvailableDown(Ghosts[I].X,Ghosts[I].Y)Then Begin
      RemoveGhost(I);
      Ghosts[I].Y:=Ghosts[I].Y+1;
      {CheckCellGhost;}
      GotoXY(1+Ghosts[I].X,1+Ghosts[I].Y);
      TextColor(10+I);
      Write('f');
     End
      Else
     FindDirection(I);
    End;
    If(Ghosts[I].X=PlayerX)and(Ghosts[I].Y=PlayerY)Then Begin
     If ChaseTimer>0 Then Begin
      Inc(ChaseGhost);
      Inc(Score,200*ChaseGhost);
      Ghosts[I].X:=18;
      Ghosts[I].Y:=9;
     End
      Else
     If Live=1Then Begin
      Write('PARTIE TERMINER !');
      Exit;
     End
      Else
     Begin
      Write('ATTRAPPER !');
      Delay(2000);
      Dec(Live);
      InitData;
      DisplayNewBoard;
     End;
    End;
   End;
   Delay(250);
  Until Keypressed;
  K:=Byte(ReadKey);
  If K=0Then K:=K or (Byte(ReadKey)shl 8);
  If Chr(Lo(K))='2'Then K:=kbDn;
  If Chr(Lo(K))='4'Then K:=kbLeft;
  If Chr(Lo(K))='6'Then K:=kbRight;
  If Chr(Lo(K))='8'Then K:=kbUp;
  Case K of
   kbUp:If AvailableUp(PlayerX,PlayerY)Then PlayerDirection:=pUp;
   kbDn:If AvailableDown(PlayerX,PlayerY)Then PlayerDirection:=pDown;
   kbLeft:If AvailableLeft(PlayerX,PlayerY)Then PlayerDirection:=pLeft;
   kbRight:If AvailableRight(PlayerX,PlayerY)Then PlayerDirection:=pRight;
  End;
 Until(K=kbEsc)or(Chr(Lo(K))in['q','Q']);
End;

BEGIN
 ClrScr;
 Screen:=InitialScreen;
 HiScore:=0;
 Live:=4;
 Level:=1;
 CountPilule:=0;
 InitData;
 DisplayNewBoard;
 Play;
END.