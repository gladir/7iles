{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal, Free Pascal)
}

Program Anagram;

Const
 AnagramList:Array[0..73,0..4]of String[20]=(
  ('Alimenter','Terminale','','',''),
  ('Ami','Mai','','',''),
  ('Ange','Nage','','',''),
  ('Anticiper','Praticien','','',''),
  ('Arbre','Barre','','',''),
  ('Argent','GÇrant','Garent','Ganter','Gerant'),
  ('Art','Rat','','',''),
  ('Aspirine','Parisien','','',''),
  ('Avec','Cave','','',''),
  ('Cas','Sac','','',''),
  ('Certain','Crainte','Criante','',''),
  ('Chien','Chine','Niche','',''),
  ('Cigare','Cirage','','',''),
  ('Clientäle','êtincelle','','',''),
  ('Combien','Combine','','',''),
  ('Connaitre','Actionner','','',''),
  ('Contre','Conter','','',''),
  ('CrÇation','Canotier','','',''),
  ('Destiner','Dentiers','','',''),
  ('Enfant','Fanent','','',''),
  ('Entier','Inerte','','',''),
  ('Entre','Rente','','',''),
  ('Esprit','Pister','Pitres','',''),
  ('Est','Tes','','',''),
  ('Fois','Soif','','',''),
  ('Garde','Grade','','',''),
  ('Garder','Regard','','',''),
  ('Guide','Digue','','',''),
  ('Lequel','Quelle','','',''),
  ('Ligne','Linge','','',''),
  ('Maison','Aimons','','',''),
  ('Marche','Charme','MÉcher','Macher',''),
  ('Mien','Mine','','',''),
  ('Mienne','Ennemi','','',''),
  ('Ministre','IntÇrims','','',''),
  ('Minute','Mutine','','',''),
  ('Nom','Mon','','',''),
  ('Obtenir','Robinet','','',''),
  ('Parmi','Prima','','',''),
  ('Partie','Pirate','','',''),
  ('PÇdalier','DÇplaire','','',''),
  ('Peur','Pure','','',''),
  ('Pirate','Partie','','',''),
  ('Point','Piton','','',''),
  ('Pointure','Çruption','êruption','eruption',''),
  ('Porte','Opter','','',''),
  ('Pouce','Coupe','','',''),
  ('Poule','Loupe','','',''),
  ('Praticien','Anticiper','','',''),
  ('Premier','Empire','PÇrimer','Perimer',''),
  ('Prendre','Reprend','','',''),
  ('PrÇsent','Serpent','','',''),
  ('PrÇsenter','Serpenter','','',''),
  ('PrÇsident','PrÇdisent','Predisent','',''),
  ('Pure','Peur','','',''),
  ('Rame','Mare','','',''),
  ('RÇalitÇ','Atelier','','',''),
  ('RÇsultat','Lutteras','','',''),
  ('Regard','Garder','','',''),
  ('Robinet','Obtenir','','',''),
  ('Rose','Oser','','',''),
  ('Samedi','Admise','','',''),
  ('Service','Viscere','Viscäre','',''),
  ('Semaine','Animes','','',''),
  ('Signe','Singe','','',''),
  ('Sombre','Ombres','','',''),
  ('Sorte','Store','','',''),
  ('Stade','Dates','','',''),
  ('Sure','Ruse','','',''),
  ('Terminale','Alimenter','','',''),
  ('Tir','Tri','','',''),
  ('Train','Riant','','',''),
  ('Une','Nue','','',''),
  ('Votre','Voter','','','')
 );

Var
 NombreDeBonneReponse,NombreDeMauvaiseReponse:Integer;
 I,J:Integer;
 Find:Boolean;
 Reponse:String;

Function StrToUpper(S:String):String;
Var
 I:Byte;
Begin
 For I:=1 to Length(S)do Begin
  If S[I] in['a'..'z']Then S[I]:=Chr(Ord(S[I])-32);
 End;
 StrToUpper:=S;
End;

BEGIN
 WriteLn('                                                        ');
 WriteLn('                                                        ');
 WriteLn('   ##                                                   ');
 WriteLn('   ##                                                   ');
 WriteLn('  # ##                                                  ');
 WriteLn('  # ##  ## ####  #####   #### #### ###   #####  # ## ## ');
 WriteLn(' #   ##  ##   ##     ## ##   ##  ##  ##      ## ## ## ##');
 WriteLn(' ######  ##   ## ###### ##   ##  ##      ###### ## ## ##');
 WriteLn('#     ## ##   ####   ##  #####   ##     ##   ## ## ## ##');
 WriteLn('#     ## ##   ####   ## ##       ##     ##   ## ## ## ##');
 WriteLn('##   #######  ## #### ## ###### ####     #### #### ## ##');
 WriteLn('                        ##    ##                        ');
 WriteLn('                         ######                         ');
 WriteLn('                                                        ');
 WriteLn('                                                        ');
 WriteLn;
 WriteLn('JEU - ANAGRAM');
 WriteLn;
 WriteLn('Le but du jeu est trouvÇ un mot connu ayant le màme que le ');
 WriteLn('mot indiquÇ. Ainsi, il faut dÇplacer les lettres d''un mot ');
 WriteLn('afin de trouvÇ un autre mot.');
 WriteLn;
 NombreDeBonneReponse:=0;
 NombreDeMauvaiseReponse:=0;
 For I:=0 to High(AnagramList)do Begin
  WriteLn('Trouver un anagramme du mot Æ',AnagramList[I,0],'Ø (Tapez QUIT pour terminer le jeu) ?');
  ReadLn(Reponse);
  If StrToUpper(Reponse)='QUIT'Then Break;
  Find:=False;
  For J:=1 to 4 do If StrToUpper(Reponse)=StrToUpper(AnagramList[I,J])Then Begin
   Find:=True;
   Break;
  End;
  If(Find)Then Begin
   Inc(NombreDeBonneReponse);
   WriteLn('Bonne rÇponse !');
  End
   Else
  Begin
   Inc(NombreDeMauvaiseReponse);
   WriteLn('Mauvaise rÇponse !');
  End;
 End;
 WriteLn('Vous avez ',NombreDeBonneReponse,' bonne rÇponse !');
 WriteLn('Vous avez ',NombreDeMauvaiseReponse,' mauvaise rÇponse !');
END.
