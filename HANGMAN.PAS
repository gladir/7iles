{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2024
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program HANGMAN;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
 WordListBeginner:Array[0..31]of String[8]=(
  'ARBRE','ARGENT','ABRI','BIEN','MAL','BEAU','MOCHE','SALE','OEIL',
  'DENT','BRAS','MAIN','PIED','CUISSE','JAMBE','COU','FLEUR','BEBE',
  'COLLE','SAUT','PAIN','CHANT','MATIN','SOIR','DOS','DEVANT','FACE',
  'LOIN','YEUX','TROIS','DEUX','QUATRE'
 );

 WordListKnight:Array[0..31]of String[15]=(
  'ARGENTINE','MALAISIE','MONACO','PAKISTAN','PARISIEN','SOUMISSION',
  'OMAN','GAMBIE','LAOS','ALBATROS','ALBATOR','AMOURETTE','CABESTAN',
  'BARBARE','BICEPS','MUSCLE','BORDURE','PROCESSEUR','MONITEUR',
  'DISQUE','DISQUETTE','CLAVIER','CARTE','CIRCUIT','ROLLER','MATRICE',
  'PIXEL','INTRODUIT','DICTON','REPAS','CANADA','CANARI'
 );

 WordListKing:Array[0..31]of String[15]=(
  'AORTITE','APEX','APLITE','BAUX','BLUFF','BOURG','CAITYA','CAPRON',
  'CENS','CHIITE','CIMIER','COOLIE','COTIR','DIDYME','DIZAIN','DIZYGOTE',
  'DOUAR','EUTEXIE','FASEYER','FJELD','FUSCINE','GALATE','GLOME',
  'GOY','GUELFE','HERCHER','HOSANNA','JUSANT','LAD','LINTER','LIMAN',
  'LODS'
 );

Var
 Level:(Beginner,Knight,King);
 WordNumber,WordLen,I,LetterFound,Lucky:Integer;
 Found,Finish:Boolean;
 K:Char;
 CurrWord:String;

Const
 DrawS:Integer=4;
 XL:Integer=160;
 YL:Integer=100;

Var
 N:String;
 Mode:(_None_,_NoTrace_,_UnMove_);
 a,b:Integer;
 xc,yc:(NoMove,Add,Sub);

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

Function ExtractNm(S:String):Integer;
Var
 N:String;
 a,b:Integer;
Begin
 N:='';
 While(I<=Length(S))and(S[I] in ['0'..'9'])do Begin
  N:=N+S[I];
  Inc(I);
 End;
 If N=''Then a:=1
Else Val(N,a,b);
 ExtractNm:=a;
End;

Function ExtractNmV(S:String):Integer;Begin
 ExtractNmV:=ExtractNm(S)*(DrawS shr 2)
End;

Procedure Line2(X,Y:Integer);Begin
 If(Mode<>_NoTrace_)Then Begin
  Case(xc)of
   Add:Inc(X,XL);
   Sub:X:=XL-X;
  End;
  Case(yc)of
   Add:Inc(Y,YL);
   Sub:Y:=YL-Y;
  End;
  If(YL=Y)and(X<XL)Then Begin
   MoveTo(X,YL);
   LineTo(XL,Y);
  End
   Else
  Begin
   MoveTo(XL,YL);
   LineTo(X,Y);
  End;
 End;
End;

Procedure SetPos(X,Y:Integer);Begin
 Case(xc)of
  Add:Inc(X,XL);
  Sub:X:=XL-X;
 End;
 Case(yc)of
  Add:Inc(Y,YL);
  Sub:Y:=YL-Y;
 End;
 If(Mode<>_UnMove_)Then Begin
  XL:=X;
  YL:=Y;
 End;
 Mode:=_None_;
 xc:=NoMove;
 yc:=NoMove;
End;


Procedure Draw(S:String);Begin
 I:=1;Mode:=_None_;
 While I<=Length(S)do Begin
  Inc(I);
  Case S[I-1]of
   'B':Mode:=_NoTrace_;
   'C':SetColor(ExtractNm(S));
   'D':Begin
    a:=ExtractNmV(S);
    Line2(XL,YL+a);
    SetPos(XL,YL+a);
   End;
   'E':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL-a);
    SetPos(XL+a,YL-a);
   End;
   'F':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL+a);
    SetPos(XL+a,YL+a);
   End;
   'G':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL+a);
    SetPos(XL-a,YL+a);
   End;
   'H':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL-a);
    SetPos(XL-a,YL-a);
   End;
   'L':Begin
    a:=ExtractNmV(S);
    Line2(XL-a,YL);
    SetPos(XL-a,YL);
   End;
   'M':Begin
    If S[I]in['+','-']Then Begin
     If S[I]='+'Then xc:=Add else xc:=Sub;
     Inc(I);
    End;
    a:=ExtractNm(S);
    If S[I]=','Then Begin
     Inc(I);
     If S[I]in['+','-']Then Begin
      If S[I]='+'Then yc:=Add else yc:=Sub;
      Inc(I);
     End;
     b:=ExtractNm(S);
    End
     Else
    b:=YL;
    Line2(a,b);
    SetPos(a,b);
   End;
   'N':Mode:=_UnMove_;
   'R':Begin
    a:=ExtractNmV(S);
    Line2(XL+a,YL);
    SetPos(XL+a,YL)
   End;
   'U':Begin
    a:=ExtractNmV(S);
    Line2(XL,YL-a);
    SetPos(XL,YL-a)
   End;
' ',';':;{C'est 2 caractSres ne change rien en soit, donc...pas d'arr^t!}
   Else Exit;
  End
 End
End;

Function IntToStr(V:Integer):String;
Var
 S:String;
Begin
 Str(V,S);
 IntToStr:=S;
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

Procedure ShowMan;Begin
 Case Lucky of
  0:Begin
   SetColor(3);
   Circle(244,105,12);
   Circle(238,102,2);
   Circle(250,102,2);
   Circle(244,106,1);
   Draw('C3BM238,109R12BM238,114D7BR10U7');
  End;
  1:Begin
   Draw('C3BM224,122C3M264,122M264,152M224,152M224,122BM245,128M256,128'+
        'M256,136M250,138M245,136M245,128BM245,130M256,130');
  End;
  2:Begin
   Draw('C3BM224,122C3M208,122M208,144BM216,144M216,128M224,128BM204,'+
        '144M218,144M218,148M204,148M204,144BM208,148M208,146BM211,'+
        '148M211,146BM215,148M215,146');
  End;
  3:Begin
   Draw('C3BM264,122R16D22BM264,128R6M272,144BD8R12D4M275,'+
        '148BM271,148M271,146BM274,148L2');
  End;
  4:Begin
   Draw('C3BM240,154D30L16M228,154R12');
  End;
  5:Begin
   Draw('C3BM260,154D30L16M248,154R12');
  End;
 End;
End;

Procedure ShowMessage(Good:Boolean;Msg:String);Begin
 SetFillStyle(SolidFill,Black);
 Bar(0,350,639,370);
 If(Good)Then SetColor(LightGreen)
         Else SetColor(LightRed);
 OutTextXY(0,350,Msg);
End;

BEGIN
 {$IFDEF FPC}
  {$IFDEF WINDOWS}
   SetUseACP(False);
  {$ENDIF}
 {$ENDIF}
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('HANGMAN : Cette commande permet de lancer le jeu ',
                     'HangMan (Bonhomme pendu).');
  WriteLn;
  WriteLn('Syntaxe : HANGMAN [/LEVEL:niveau]');
  WriteLn;
  WriteLn(' /LEVEL:niveau   Niveau du jeu : BEGINNER, KNIGHT ou KING');
 End
  Else
 Begin
  Level:=Beginner;
  If StrToUpper(ParamStr(1))='/LEVEL:BEGINNER'Then Level:=Beginner Else
  If StrToUpper(ParamStr(1))='/LEVEL:KNIGHT'Then Level:=Knight Else
  If StrToUpper(ParamStr(1))='/LEVEL:KING'Then Level:=King;
  InitScr;
  Randomize;
  Finish:=False;
  LetterFound:=0;
  Lucky:=5;
  Case Level of
   King:Begin
    WordNumber:=Random(High(WordListKing));
    CurrWord:=WordListKing[WordNumber];
   End;
   Knight:Begin
    WordNumber:=Random(High(WordListKnight));
    CurrWord:=WordListKnight[WordNumber];
   End;
   Else Begin
    WordNumber:=Random(High(WordListBeginner));
    CurrWord:=WordListBeginner[WordNumber];
   End;
  End;
  WordLen:=Length(CurrWord);
  SetColor(Yellow);
  OutTextXY(250,10,'H A N G M A N');
  SetColor(Blue);
  Case Level of
   King:OutTextXY(200,30,'Niveau : Roi');
   Knight:OutTextXY(200,30,'Niveau : Chevalier');
   Else OutTextXY(200,30,'Niveau : D‚butant');
  End;
  Draw('BM200,180C6D12R116U12NL116L16U112NG16L64'+
       'F16R32D96U16G16L24E40BM316,180H16D8F8BM284,100'+
       'H16R8F8BM244,84D4U12');
  Circle(243,91,3);
  Circle(244,106,14);
  Circle(244,106,18);
  SetColor(White);
  OutTextXY(0,240,'Vous devez trouvez un mot de '+IntToStr(WordLen)+
                 ' lettres sinon ');
  OutTextXY(0,250,'votre bonhomme sera pendu.');
  OutTextXY(0,270,'Entrez une lettre entre A et Z pour trouv‚ le mot ?');
  For I:=1 to WordLen do Begin
   Line(I*8,300,I*8+6,300);
  End;
  Repeat
   K:=UpCase(ReadKey);
   Case K of
    #27:Finish:=True;
    'A'..'Z':Begin
     Found:=False;
     For I:=1 to Length(CurrWord)do Begin
      If CurrWord[I]=K Then Begin
       Found:=True;
       SetColor(LightGreen);
       OutTextXY(I*8,290,CurrWord[I]);
       Inc(LetterFound);
      End;
     End;
     If(Found)Then Begin
      If LetterFound>=Length(CurrWord)Then Begin
       ShowMessage(True,'Vous avez gagn‚ !!!');
       ReadKey;
       Finish:=True;
      End
       Else
      Begin
       ShowMessage(True,'Vous avez trouv‚ une lettre');
      End;
     End
      Else
     If Lucky=0 Then Begin
      ShowMan;
      ShowMessage(False,'Votre bonhomme est pendu ! Vous avez perdu !');
      ReadKey;
      Finish:=True;
     End
      Else
     Begin
      ShowMan;
      ShowMessage(False,'Cette lettre ne figure pas dans le mot');
      Dec(Lucky);
     End;
    End;
   End;
  Until Finish;
 End;
END.