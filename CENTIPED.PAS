{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program CENTIPED; { CENTIPEDE.PAS }

{$R-}

Uses Crt,DOS;

Const
 CharCannon=#127;
 CharCannonBase=#219;
 CharBall=#250;
 CharCent=#15;
 ScreenRow=23;
 ScreenCol=40;

 InitMoveWhen=12;
 InitNumMushs=25;

Type
 PtrSegmentRec=^SegmentRec;
 SegmentRec=Record
  Prev,Next:PtrSegmentRec;
  Row,Col:Integer;
 End;

 PtrHeadTailRec=^HeadTailRec;

 HeadTailRec=Record
  Prev,Next:PtrHeadTailRec;
  Head:PtrSegmentRec;
  Tail:PtrSegmentRec;
  RelCol:Integer;
 End;

 ScreenObjects=(Blank,WeakMushroom,StrongMushroom,WeakMushSeg,
                StrongMushSeg,Cannon,Wall,Earth,Cent,Shot);

Var
 Screen:Array[1..ScreenRow] of Array[1..ScreenCol] of ScreenObjects;
 YouX,NumMoves:Integer;
 ShotGoing:Boolean;
 Score,Lives,NumMush,NumCent,MoveWhen:Integer;
 SpiderY,SpiderX,SpiderDX,SpiderDY,ShotY,ShotX:Integer;
 Finish:Boolean;
 CentList:PtrHeadTailRec;
 Move:Integer;

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

Function PadRight(S:String;Space:Byte):String;
Var
 I:Byte;
Begin
 If Length(S)<Space Then For I:=Length(S)+1 to Space do S:=S+' ';
 PadRight:=S;
End;

Function Dupl(C:Char;Num:Integer):String;
Var
 I:Byte;
 S:String;
Begin
 S:='';
 For I:=1 to Num do S:=S+C;
 Dupl:=S;
End;

Function Random(lb,ub:Integer):Integer;Begin
 Random:=lb+Trunc(System.Random*(ub-lb+1));
End;

Procedure DeleteSegment(Var ShotY,ShotX:Integer);
Var
 CentSegment:PtrSegmentRec;
 NewCent,CentSearch:PtrHeadTailRec;
 Found:Boolean;
Begin
 GotoXY(ShotX,ShotY);
 Write('O');
 Screen[ShotY,ShotX]:=StrongMushSeg;
 Found:=False;
 CentSearch:=CentList;
 While(Not Found)and(CentSearch<>NIL)do Begin
  With CentSearch^ do If(ShotY=Head^.Row)and(ShotX=Head^.Col)Then Begin
   If Head^.Next=NIL Then Begin
    If CentList=CentSearch Then Begin
     Dispose(Head);
     CentList:=CentList^.next;
     Dispose(CentSearch);
     Found:=True;
    End
     Else
    Begin
     Dispose(Head);
     CentSearch^.Prev^.Next:=CentSearch^.Next;
     If(CentSearch^.Next <> NIL)Then CentSearch^.next^.Prev:=CentSearch^.Prev;
     Dispose(CentSearch);
     Found:=True;
    End;
   End
    Else
   Begin
    CentSegment:=Head;
    Head:=Head^.Next;
    Head^.Prev:=NIL;
    Dispose(CentSegment);
   End;
  End
   Else
  If(ShotX=Tail^.Col)and(ShotY=Tail^.Row)Then Begin
   CentSegment:=Tail;
   Tail:=Tail^.Prev;
   Tail^.Next:=NIL;
   Dispose(CentSegment);
  End
   Else
  Begin
   CentSegment:=Head^.Next;
   While(CentSegment<>NIL)and(Not Found) do Begin
    If(CentSegment^.Row=ShotY )and(CentSegment^.Col=ShotX)Then Begin
     MoveWhen:=MoveWhen-1;
     If MoveWhen<=1 Then MoveWhen:=2;
     Found:=True;
     New(NewCent);
     NewCent^.Next:=CentSearch^.Next;
     NewCent^.Prev:=CentSearch;
     CentSearch^.Next:=NewCent;
     If NewCent^.Next<>NIL Then NewCent^.Next^.Prev:=NewCent;
     NewCent^.Head:=CentSegment^.Next;
     NewCent^.Head^.Prev:=NIL;
     NewCent^.Tail:=CentSearch^.Tail;
     If Screen[NewCent^.Head^.Row,NewCent^.Head^.Col+1]=StrongMushroom Then NewCent^.RelCol:=1
                                                                        Else NewCent^.RelCol:=-1;
     CentSearch^.Tail:=CentSegment^.Prev;
     CentSearch^.Tail^.Next:=NIL;
     Dispose(CentSegment);
    End
     Else
    CentSegment:=CentSegment^.Next;
   End;
  End;
  CentSearch:=CentSearch^.Next;
 End;
End;

Procedure MoveCentipede;
Const
 BaseHeadX=39;
 BaseHeadY=2;
 InitLenCent=12;
Var
 PrevSegment,New_Head,Segment:PtrSegmentRec;
 CentToMove:PtrHeadTailRec;
 Cnt,LenCent:Integer;

 Procedure AddHead(Row,Col:Integer);
 Var
  Segment:PtrSegmentRec;
 Begin
  New(Segment);
  With CentToMove^ Do Begin
   Segment^.Row:=Row;
   Segment^.Col:=Col;
   Segment^.Next:=Head;
   Head^.Prev:=Segment;
   Segment^.Prev:=NIL;
   Head:=Head^.Prev;
   Screen[Tail^.Row,Tail^.Col]:=Blank;
   GotoXY(Tail^.Col,Tail^.Row);
   Write('~');
   Segment:=Tail;
   Tail:=Tail^.Prev;
   Tail^.Next:=NIL;
   Dispose(Segment);
   GotoXY(Head^.Col,Head^.Row);
   Write(CharCent);
   Screen[Head^.Row,Head^.Col]:=Cent;
  End;
 End;

 Procedure MoveThisCent(Var CentToMove:PtrHeadTailRec);
 Var
  Dir:Integer;
 Begin
  With CentToMove^ do Begin
   Case Screen[Head^.Row,Head^.Col+RelCol] of
    Blank:AddHead(Head^.Row, Head^.Col+RelCol);
    Wall,Cent,WeakMushSeg,StrongMushSeg,WeakMushroom,StrongMushroom:Begin
     Case Screen[Head^.Row+1,Head^.Col] Of
      WeakMushSeg,StrongMushSeg,WeakMushroom,StrongMushroom:Begin
       If Screen[Head^.Row+1,Head^.Col+RelCol]=Blank Then AddHead(Head^.Row+1,Head^.Col+RelCol)
        Else
       Begin
        RelCol:=RelCol*(-1);
        If Screen[Head^.Row+1,Head^.Col+RelCol]=Blank Then AddHead(Head^.Row+1,Head^.Col+RelCol)
   	  Else
        Begin
         Case Random(1,3)of
          1:Dir:=1;
          2:Dir:=-1;
          3:Dir:=0;
 	 End;
         If Screen[Head^.Row+1,Head^.Col+Dir]in[StrongMushroom,
            WeakMushroom,WeakMushSeg,StrongMushSeg] Then Begin
          If Screen[Head^.Row+1,Head^.Col+Dir]in[StrongMushroom,WeakMushroom]Then
           NumMush:=NumMush-1;
          AddHead( Head^.Row+1,Head^.Col+Dir);
         End;
        End;
       End;
      End;
      Blank:Begin
       RelCol:=RelCol*(-1);
       AddHead(Head^.Row+1,Head^.Col);
      End;
      Cannon,Earth:Finish:=True;
     End;
    End;
    Cannon,Earth:Finish:=True;
   End;
  End;
 End;

Begin
 If CentList=NIL Then Begin
  New(CentList);
  With CentList^ do Begin
   NumCent:=NumCent+1;
   MoveWhen:=InitMoveWhen-NumCent;
   If MoveWhen<=1 Then MoveWhen:=2;
   LenCent:=InitLenCent+NumCent;
   If LenCent>=BaseHeadX Then LenCent:=BaseHeadX-2;
   Next:=NIL;
   Head:=NIL;
   Prev:=NIL;
   Tail:=NIL;
   RelCol:=-1;
   PrevSegment:=NIL;
   For Cnt:=1 to LenCent do Begin
    New(Segment);
    If Head=NIL Then Begin
     Head:=Segment;
    End;
    With Segment^ do Begin
     Row:=BaseHeadY;
     Col:=BaseHeadX-LenCent+Cnt-1;
     Screen[Row,Col]:=Cent;
     GotoXY(Col,Row);
     Write(CharCent);
     Segment^.Next:=NIL;
     Segment^.Prev:=PrevSegment;
     If PrevSegment<>NIL Then PrevSegment^.Next:=Segment;
    End;
    PrevSegment:=Segment;
   End;
   Tail:=Segment;
  End
 End
  Else
 Begin
  CentToMove:=CentList;
  While CentToMove<>NIL do Begin
   Cnt:=0;
   While(Cnt<(NumMoves mod MoveWhen))and(CentToMove<>NIL)do Begin
    CentToMove:=CentToMove^.Next;
    Cnt:=Cnt+1;
   End;
   If(CentToMove<>NIL)Then Begin
    MoveThisCent(CentToMove);
    While(Cnt<MoveWhen)and(CentToMove<>NIL) do Begin
     CentToMove:=CentToMove^.Next;
     Cnt:=Cnt+1;
    End;
   End;
  End;
 End;
End;

Procedure SetUp;
Var
 Len,Cnt,Row,Col:Integer;
Begin
 ClrScr;
 Score:=50;
 Lives:=3;
 NumMoves:=1;
 NumCent:=0;
 WriteLn(#218+Dupl(#196,38)+#191);
 For Col:=1 to ScreenCol do Begin
  Screen[1,Col]:=Wall;
  Screen[ScreenRow,Col]:=Earth;
 End;
 For Row:=2 to ScreenRow-1 do begin
  Screen[Row,1]:=Wall;
  Screen[Row,ScreenCol]:=Wall;
  For Col:=2 to ScreenCol-1 do Screen[Row,Col]:=Blank;
  WriteLn(#179,Dupl('~',38),#179);
 End;
 WriteLn(#192+Dupl(#196,38)+#217);
 GotoXY(2,24);
 Write(Dupl(#127,Lives));
 GotoXY(21,24);
 Write('Pointage : ',Score);
 For Cnt:=1 to InitNumMushs do Begin
  Row:=Random(2,ScreenRow-2);
  Col:=Random(2,ScreenCol-1);
  Screen[Row,Col]:=StrongMushroom;
  GotoXY(Col,Row);
  Write('O');
 End;
 YouX:=20;
 GotoXY(YouX,ScreenRow-1);
 Write(CharCannon);
 GotoXY(YouX,ScreenRow);
 Write(CharCannonBase);
 Screen[ScreenRow-1,YouX]:=Cannon;
 SpiderY:=2;
 SpiderX:=10;
 SpiderDY:=1;
 SpiderDX:=1;
 GotoXY(10,2);
 Write('*');
 NumMush:=InitNumMushs;
End;

Procedure AddScore(Num:Integer);Begin
 Score:=Score+Num;
 GotoXY(21,24);
 Write('Pointage : ',Score);
End;

Procedure MoveShot;
Const
 Speed_Shot=2;
Var
 Cnt:Integer;
Begin
 For Cnt:=1 to Speed_Shot do If ShotGoing Then Begin
  If Screen[ShotY,ShotX]=Shot Then Begin
   Screen[ShotY,ShotX]:=Blank;
   GotoXY(ShotX,ShotY);
   Write('~');
  End;
  ShotY:=ShotY-1;
  Case Screen[ShotY,ShotX] of
   Blank:Begin
    Screen[ShotY,ShotX]:=Shot;
    GotoxY(ShotX,ShotY);
    Write(CharBall);
   End;
   WeakMushSeg:Begin
    Screen[ShotY,ShotX]:=Blank;
    GotoXY(ShotX,ShotY);
    Write('~');
    ShotGoing:=False;
    AddScore(10);
   End;
   WeakMushroom:Begin
    NumMush:=NumMush-1;
    Screen[ShotY,ShotX]:=Blank;
    GotoXY(ShotX,ShotY);
    Write('~');
    ShotGoing:=False;
    AddScore(10);
   End;
   StrongMushroom:Begin
    Screen[ShotY,ShotX]:=WeakMushroom;
    ShotGoing:=False;
   End;
   StrongMushSeg:Begin
    Screen[ShotY,ShotX]:=WeakMushSeg;
    ShotGoing:=False;
   End;
   Cent:Begin
    AddScore(100);
    DeleteSegment(ShotY,ShotX);
    ShotGoing:=False;
   End;
   Else ShotGoing:=False;
  End;
 End;
End;

Procedure LooseLife;Begin
 Lives:=Lives-1;
 If Lives>0 Then Begin
  GotoXY(2,24);
  Write(PadRight(Dupl(CharCannon,Lives),10));
  SpiderY:=2;
  SpiderX:=10;
  SpiderDY:=1;
  SpiderDX:=1;
  GotoXY(10,2);
  Write('*');
  Delay(1000);
 End
  Else
 Finish:=True;
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 ClrScr;
 WriteLn(' ooooo o                           oo                       ooo         ');
 WriteLn('oo    oo                   o       oo                        oo         ');
 WriteLn('o      o                  oo                                 oo         ');
 WriteLn('o         ooooo oo oooo oooooo    ooo   oo oooo   ooooo  ooo oo   ooooo ');
 WriteLn('o        oo   oo oo   oo  oo       oo    oo   oo oo   oooo  ooo  oo   oo');
 WriteLn('o        ooooooo oo   oo  oo       oo    oo   oo ooooooooo   oo  ooooooo');
 WriteLn('o      o oo      oo   oo  oo       oo    oo   oo oo     oo   oo  oo     ');
 WriteLn('oo    o  oo    o oo   oo  oo  o    oo    ooo  oo oo    ooo   oo  oo    o');
 WriteLn(' ooooo    ooooo oooo  oo   ooo    oooo   oo ooo   ooooo  oooo oo  ooooo ');
 WriteLn('                                         oo                             ');
 WriteLn('                                        oooo                            ');
 WriteLn;
 WriteLn('Empˆchez le mille-pattes de descendre sur terre. Tirez-lui ');
 WriteLn('dessus, faites attention … ne pas le diviser. M‚fiez-vous de ');
 WriteLn('l''araign‚e : elle ne peut pas ˆtre tu‚e mais peut d‚truire ');
 WriteLn('votre canon au contact.');
 WriteLn;
 Write('Presse une touche pour jouer...');
 ReadKey;
 WriteLn;
 CursorOff;
 SetUp;
 While Not Finish do Begin
  NumMoves:=NumMoves+1;
  MoveCentipede;
  If Odd(NumMoves)Then Begin
   Case Screen[SpiderY,SpiderX] of
    Cent:Begin
     GotoXY(SpiderX,SpiderY);
     Write(CharCent);
    End;
    StrongMushSeg,WeakMushSeg,StrongMushroom,WeakMushroom:Begin
     GotoXY(SpiderX,SpiderY);
     Write('O');
    End;
    Blank:Begin
     If(SpiderY<ScreenRow-1)and(SpiderY>(ScreenRow div 3))and
       (NumMush<InitNumMushs)Then Begin
      If(Random(1,ScreenRow-SpiderY)=1)Then Begin
       Screen[SpiderY,SpiderX]:=StrongMushroom;
       GotoXY(SpiderX,SpiderY);
       Write('O');
       NumMush:=NumMush+1;
      End
       Else
      Begin
       GotoXY(SpiderX,SpiderY);
       Write('~');
      End;
     End
      Else
     Begin
      GotoXY(SpiderX,SpiderY);
      Write('~');
     End;
    End;
    Cannon:LooseLife;
   End;
   Case Screen[SpiderY+SpiderDY,SpiderX+SpiderDX] of
    Cent,StrongMushSeg,WeakMushSeg,StrongMushroom,WeakMushroom,Blank:Begin
     SpiderY:=SpiderY+SpiderDY;
     SpiderX:=SpiderX+SpiderDX;
     GotoXY(SpiderX,SpiderY);
     Write('*');
    End;
    Wall,Earth:Begin
     If(SpiderY+SpiderDY=ScreenRow)or(SpiderY+SpiderDY=1)Then SpiderDY:=SpiderDY*(-1);
     If(SpiderX+SpiderDX=ScreenCol)or(SpiderX+SpiderDX=1)Then SpiderDX:=SpiderDX*(-1);
    End;
    Cannon:LooseLife;
   End;
  End;
  Move:=0;
  If(Keypressed)Then Case ReadKey of
   #0:Case ReadKey of
    #75:Move:=-1;
    #77:Move:=1;
   End;
   '1','<',',':Move:=-1;
   '3','>','.':Move:=1;
   '4':Move:=-2;
   '6':Move:=2;
   '7':Move:=-3;
   '9':Move:=3;
   'e','E','q','Q':Finish:=True;
   '2','5','8',' ':If Not(ShotGoing)Then Begin
    ShotGoing:=True;
    ShotY:=ScreenRow-1;
    ShotX:=YouX;
    Score:=Score-2;
   End;
  End;
  If Move<>0 Then If(YouX+Move>1)and(YouX+Move<ScreenCol)Then Begin
   GotoXY(YouX,ScreenRow-1);
   Write('~');
   GotoXY(YouX,ScreenRow);
   Write(#196);
   Screen[ScreenRow-1,YouX]:=Blank;
   Screen[ScreenRow,YouX]:=Earth;
   YouX:=YouX+Move;
   Screen[ScreenRow,YouX]:=Cannon;
   Screen[ScreenRow-1,YouX]:=Cannon;
   GotoXY(YouX,ScreenRow-1);
   Write(CharCannon);
   GotoXY(YouX,ScreenRow);
   Write(CharCannonBase);
  End;
  If(ShotGoing)Then MoveShot;
  Delay(50);
 End;
 Delay(1000);
 CursorOn;
END.