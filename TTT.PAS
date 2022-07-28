{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2022
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program TTT;

Uses CRT;

Var
 Board:Array[0..8]of Byte;
 Beginner:(Human,Computer);

Procedure InitGame;Begin
 ClrScr;
 GotoXY(34,1);
 WriteLn('Tic-Tac-Toe');
 WriteLn;
 TextColor(LightRed);
 Write(' O');
 TextColor(7);
 WriteLn(' = Ordinateur');
 TextColor(LightGreen);
 Write(' X');
 TextColor(7);
 WriteLn(' = Humain (vous)');
 FillChar(Board,SizeOf(Board),0);
End;

Procedure ChoiceBeginner;
Var
 K:Char;
Begin
 GotoXY(1,6);
 Write('Quel joueur commence (O=Moi/X=Vous) ?');
 K:=ReadKey;
 If UpCase(K)='O'Then Beginner:=Computer Else
 If UpCase(K)='X'Then Beginner:=Human;
 GotoXY(1,6);
 ClrEol;
End;

Procedure ShowBoard;
Var
 I,J:Byte;
Begin
 GotoXY(1,6);
 For J:=0 to 2 do Begin
  Write(' ':8,'+');
  For I:=0 to 2 do Begin
   Write('---');
   Write('+');
  End;
  WriteLn;
  Write(' ':8,'|');
  For I:=0 to 2 do Begin
   Write(I+J*3+1:3);
   Write('|');
  End;
  WriteLn;
  Write(' ':8,'|');
  For I:=0 to 2 do Begin
   Case Board[I+J*3]of
    1:Begin
     TextColor(LightGreen);
     Write(' X ');
     TextColor(7);
    End;
    2:Begin
     TextColor(LightRed);
     Write(' O ');
     TextColor(7);
    End;
    Else Write(' ':3);
   End;
   Write('|');
  End;
  WriteLn;
 End;
 Write(' ':8,'+');
 For I:=0 to 2 do Begin
  Write('---');
  Write('+');
 End;
 WriteLn;
End;

Function HumanPlay(P:Byte):Boolean;Begin
 HumanPlay:=False;
 If Board[P]=0 Then Begin
  Board[P]:=1;
  HumanPlay:=True;
 End;
End;

Function ComputerPlay:Boolean;
Var
 ComputerMove,HumanX,ComputerO:Integer;
 I:Byte;
 AllEmpty:Boolean;
Begin
 ComputerMove:=-1;
 ComputerPlay:=False;
 AllEmpty:=True;
 For I:=0 to 8 do If Board[I]<>0Then AllEmpty:=False;
 If(AllEmpty)Then ComputerMove:=2
  Else
 Begin
  ComputerO:=0;
  HumanX:=0;
  For I:=0 to 8 do Begin
   If Board[I]=1 Then Inc(HumanX);
   If Board[I]=2 Then Inc(ComputerO);
  End;
  If(HumanX=1)and(ComputerO=0)Then Begin
   If Board[4]=0 Then ComputerMove:=4;
  End;
   { Recherche une attaque }
  If ComputerMove=-1Then Begin
   If(Board[0]=2)and(Board[1]=2)and(Board[2]=0)Then ComputerMove:=2 Else
   If(Board[0]=2)and(Board[1]=0)and(Board[2]=2)Then ComputerMove:=1 Else
   If(Board[0]=2)and(Board[4]=2)and(Board[8]=0)Then ComputerMove:=8 Else
   If(Board[0]=2)and(Board[4]=0)and(Board[8]=2)Then ComputerMove:=4 Else
   If(Board[0]=2)and(Board[3]=2)and(Board[6]=0)Then ComputerMove:=6 Else
   If(Board[1]=2)and(Board[4]=2)and(Board[7]=0)Then ComputerMove:=7 Else
   If(Board[2]=2)and(Board[4]=2)and(Board[6]=0)Then ComputerMove:=6 Else
   If(Board[2]=2)and(Board[4]=0)and(Board[6]=2)Then ComputerMove:=4 Else
   If(Board[2]=2)and(Board[5]=2)and(Board[8]=0)Then ComputerMove:=8 Else
   If(Board[2]=2)and(Board[5]=0)and(Board[8]=2)Then ComputerMove:=5 Else
   If(Board[3]=2)and(Board[4]=2)and(Board[5]=0)Then ComputerMove:=5 Else
   If(Board[3]=2)and(Board[4]=0)and(Board[5]=2)Then ComputerMove:=4 Else
   If(Board[6]=2)and(Board[5]=2)and(Board[2]=0)Then ComputerMove:=2 Else
   If(Board[6]=2)and(Board[7]=2)and(Board[8]=0)Then ComputerMove:=8 Else
   If(Board[6]=2)and(Board[7]=0)and(Board[8]=2)Then ComputerMove:=7;
  End;
  If ComputerMove=-1Then Begin
   If(Board[2]=2)and(Board[4]=0)and(Board[6]=0)and(ComputerO=1)Then ComputerMove:=6 Else
   If(Board[2]=2)and(Board[6]=2)and(Board[8]=0)and(ComputerO=2)Then ComputerMove:=8 Else
   If(Board[2]=2)and(Board[6]=2)and(Board[0]=0)Then ComputerMove:=0;
  End;
   { Recherche une d‚fense }
  If(ComputerMove=-1)Then Begin
   If(Board[0]=0)and(Board[3]=1)and(Board[6]=1)Then ComputerMove:=0 Else
   If(Board[0]=1)and(Board[3]=0)and(Board[6]=1)Then ComputerMove:=3 Else
   If(Board[0]=1)and(Board[3]=1)and(Board[6]=0)Then ComputerMove:=6 Else
   If(Board[0]=0)and(Board[1]=1)and(Board[2]=1)Then ComputerMove:=0 Else
   If(Board[0]=1)and(Board[1]=0)and(Board[2]=1)Then ComputerMove:=1 Else
   If(Board[0]=1)and(Board[1]=1)and(Board[2]=0)Then ComputerMove:=2 Else
   If(Board[1]=0)and(Board[4]=1)and(Board[7]=1)Then ComputerMove:=1 Else
   If(Board[1]=1)and(Board[4]=0)and(Board[7]=1)Then ComputerMove:=4 Else
   If(Board[1]=1)and(Board[4]=1)and(Board[7]=0)Then ComputerMove:=7 Else
   If(Board[2]=0)and(Board[4]=1)and(Board[6]=1)Then ComputerMove:=2 Else
   If(Board[2]=1)and(Board[4]=0)and(Board[6]=1)Then ComputerMove:=4 Else
   If(Board[2]=1)and(Board[4]=1)and(Board[6]=0)Then ComputerMove:=6 Else
   If(Board[2]=0)and(Board[5]=1)and(Board[8]=1)Then ComputerMove:=2 Else
   If(Board[2]=1)and(Board[5]=0)and(Board[8]=1)Then ComputerMove:=5 Else
   If(Board[2]=1)and(Board[5]=1)and(Board[8]=0)Then ComputerMove:=8 Else
   If(Board[3]=0)and(Board[4]=1)and(Board[5]=1)Then ComputerMove:=3 Else
   If(Board[3]=1)and(Board[4]=0)and(Board[5]=1)Then ComputerMove:=4 Else
   If(Board[3]=1)and(Board[4]=1)and(Board[5]=0)Then ComputerMove:=5 Else
   If(Board[6]=0)and(Board[7]=1)and(Board[8]=1)Then ComputerMove:=6 Else
   If(Board[6]=1)and(Board[7]=0)and(Board[8]=1)Then Computermove:=7 Else
   If(Board[6]=1)and(Board[7]=1)and(Board[8]=0)Then ComputerMove:=8;
  End;
   { Recherche al‚atoire }
  If ComputerMove=-1 Then Begin
   For I:=0 to 8 do If Board[I]=0 Then Begin
    Board[I]:=2;
    Break;
   End;
  End;
 End;
 If ComputerMove<>-1 Then Begin
  If Board[ComputerMove]=0 Then Begin
   Board[ComputerMove]:=2;
   ComputerPlay:=True;
  End;
 End;
End;

Function CheckIfWin:Byte;
Var
 I:Byte;
Begin
 For I:=1 to 2 do Begin
  CheckIfWin:=I;
  If(Board[0]=I)and(Board[1]=I)and(Board[2]=I)Then Exit;
  If(Board[0]=I)and(Board[3]=I)and(Board[6]=I)Then Exit;
  If(Board[1]=I)and(Board[4]=I)and(Board[7]=I)Then Exit;
  If(Board[2]=I)and(Board[5]=I)and(Board[8]=I)Then Exit;
  If(Board[2]=I)and(Board[4]=I)and(Board[6]=I)Then Exit;
  If(Board[0]=I)and(Board[4]=I)and(Board[8]=I)Then Exit;
  If(Board[3]=I)and(Board[4]=I)and(Board[5]=I)Then Exit;
  If(Board[6]=I)and(Board[7]=I)and(Board[8]=I)Then Exit;
 End;
 CheckIfWin:=0;
End;

Function MatchNull:Boolean;
Var
 I:Byte;
Begin
 MatchNull:=False;
 For I:=0 to 8 do If Board[I]=0Then Exit;
 MatchNull:=True;
End;

Procedure RunGame;
Var
 K:Char;
Begin
 If(Beginner=Computer)Then ComputerPlay;
 Repeat
  ShowBoard;
  WriteLn;
  Write('Faites votre choix entre 1 et 9 : ');
  K:=ReadKey;
  Case K of
   '1':If HumanPlay(0)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '2':If HumanPlay(1)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '3':If HumanPlay(2)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '4':If HumanPlay(3)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '5':If HumanPlay(4)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '6':If HumanPlay(5)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '7':If HumanPlay(6)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '8':If HumanPlay(7)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
   '9':If HumanPlay(8)Then Begin
    If CheckIfWin=1 Then Begin
     ShowBoard;
     WriteLn('Vous avez gagne !');
     Exit;
    End;
    ComputerPlay;
    If CheckIfWin=2 Then Begin
     ShowBoard;
     WriteLn('Vous avez perdu !');
     Exit;
    End;
   End;
  End;
  If(MatchNull)Then Begin
   ShowBoard;
   WriteLn('PARTIE NULLE !');
   Exit;
  End;
 Until K=#27;
End;

BEGIN
 Beginner:=Computer;
 InitGame;
 ChoiceBeginner;
 RunGame;
END.