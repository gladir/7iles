{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
  @description(Mario est un clone du jeu de plateforme de Nintendo. }

Program Mario;

Uses {$IFDEF FPC}
      PtcGraph,Crt,PtcCrt
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const MarioIcon : Array[0..6459] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!!!(('+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'!((!!!!((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!('+
  '(!!!!((!!!!!'+#$FF+#$FF+#$FF+'!!!!((((((((!!!!!'+#$FF+#$FF+'###'+#$FF+
  #$FF+'((((((((!'+#$FF+#$FF+'!#'+#$FF+#$FF+'###'+#$FF+#$FF+'((((((((('+#$FF+
  '###'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'((('+#$FF+#$FF+#$FF+#$FF+#$FF+'((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+
  '@@'+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@'+
  '@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+
  '(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'######'+#$FE+
  #$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##### ######'+#$FE+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+'#####'+#$FE+#$FE+
  #$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+
  '####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'!!((!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'!!!!((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##!!!!((!!!'+
  '!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##!!((##((!!!!'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'##((((###!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'@@@@'+#$FF+'###!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@'+
  '@@@@'+#$FF+'(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+
  '##'+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '##!!!((!!!!((!!!'+#$FF+#$FF+#$FF+#$FF+'##!!!((!!!!((!!!!!'+#$FF+#$FF+
  #$FF+#$FF+'!!!((!!((!!!!!!!!'+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!!!!!##'+#$FF+
  #$FF+#$FF+#$FF+'((!!!!((!!('+#$FF+#$FF+'###'+#$FF+'@@'+#$FF+'((((((((((('+
  '@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@((((((((@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '@@@@((((((((@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!((!!'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+'!!'+#$FF+#$FF+'!!'+#$FF+#$FF+
  '!!!!'+#$FF+#$FF+#$FF+#$FF+'##!!!!!!!!((!!##'+#$FF+#$FF+#$FF+#$FF+'##!'+
  '!!!!!!!((!###'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((((@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!((!!!'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!((!!!!'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##!!!!((!!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'##!!((##((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##((((###!!!'+
  '!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((###!!'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+'(((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+'(((('+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '###'+#$FF+#$FF+#$FF+#$FF+'((!!((!!'+#$FF+#$FF+#$FF+#$FF+#$FF+'##!!!(('+
  '!!!!((!!!!'+#$FF+#$FF+#$FF+'##!!!!!!!!(((!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'!!!!!!((((###'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+
  '((##'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@'+#$FF+#$FF+#$FF+#$FF+
  '@@@@@(((((((((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'###'+
  '###'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##### ##'+
  '####'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+
  '#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+
  #$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!!!!(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'!!!!((!!!('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'###((!!!!('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '##!!!!((@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#!!!((@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!(((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((('+
  '(((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+'@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@'+
  '@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'###'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '###!'+#$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!((((((('+
  '((((('+#$FF+#$FF+#$FF+#$FF+'!!!!'+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+
  #$FF+#$FF+#$FF+'!!!!##### ######'+#$FE+#$FF+#$FF+#$FF+'!!!!'+#$FF+#$FF+
  #$FF+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+
  #$FE+#$FE+#$FE+#$FF+#$FF+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+'!!'+
  '!'+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!!((!!!!((!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!!!'+
  '!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!((!!#'+#$FF+'@@@@'+#$FF+#$FF+
  '!!((!!!(('+#$FF+#$FF+'##'+#$FF+'@@@@((((((!!((@@'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'@@@(((((((('+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((('+#$FF+
  #$FF+'@@@'+#$FF+'@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((('+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FE+#$FF+#$FF+
  #$FF+'##'+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FF+#$FF+'####'+#$FE+#$FE+#$FF+
  #$FF+#$FF+#$FF+'###'+#$FF+#$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'!!!'+#$FF+'((!!!!((!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!(('+
  '!!((!!!!!!'+#$FF+#$FF+#$FF+#$FF+'!!((!!!!((!!'+#$FF+'!!!!!'+#$FF+#$FF+
  #$FF+'!((((((((!!'+#$FF+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+'((((((!!!!####'+
  '##'+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((((('+#$FF+#$FF+'####'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+#$FF+
  #$FF+'(((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+'@@@@@((('+#$FF+
  #$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+
  #$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+
  #$FE+#$FE+#$FE+#$FF+#$FF+'####'+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+'###'+#$FF+
  #$FF+#$FF+#$FF+'#######'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+'((!!'+
  '!!((!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!((!!((!!!!!!'+#$FF+#$FF+#$FF+
  #$FF+'!!((!!!!((!!'+#$FF+'!!!!!'+#$FF+#$FF+#$FF+'!((((((((!!'+#$FF+#$FF+
  '!!!!'+#$FF+#$FF+#$FF+#$FF+'((((((!!!!######'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '((((((((('+#$FF+#$FF+'####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+#$FF+#$FF+'(((((('+#$FF+#$FF+#$FF+
  '##'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@((('+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+
  #$FF+'#'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'#'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'######'+#$FE+#$FE+'##'+#$FE+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'##### ######'+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+'#####'+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FE+#$FE+
  '####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((######'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##!!((!!!!!!((!!'+#$FF+#$FF+#$FF+#$FF+
  '##!!((!!!!!!((!!!!##'+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!!!!!##'+#$FF+#$FF+
  #$FF+#$FF+'((!!!!((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+
  '(((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((('+
  '(((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+#$FF+#$FF+'((((((@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((@@((((@@'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@'+#$FF+#$FF+'@@'+#$FF+
  #$FF+#$FF+#$FF+'(('+#$FF+#$FF+'(('+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(('+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+
  '(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((('+#$FF+#$FF+'('+
  '('+#$FF+#$FF+#$FF+#$FF+'@@@@@@((@@'+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+
  '@@@@@'+#$FF+'@@@@@@(('+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@@'+
  '@@@(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((@@@@(('+#$FF+#$FF+'(('+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+#$FF+#$FF+'((@@(((('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@@@@!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#!!((!!!!!!((!!'+#$FF+#$FF+#$FF+#$FF+'!!!!((!!!!!!((!!!!!!'+#$FF+#$FF+
  #$FF+#$FF+'((!!!!((!!!!!!##'+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((((((((@@'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'(((('+#$FF+#$FF+'((((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'((((@@((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@@'+#$FF+#$FF+'@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+
  '(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((@@((@'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'((((('+#$FF+'((@@((@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@(((((@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@'+
  '@@@@@((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(('+#$FF+
  #$FF+'@@(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((('+
  '((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((!!((!!!!!!((!!'+#$FF+
  #$FF+#$FF+#$FF+'((!!((!!!!!!((!!!!(('+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!!'+
  '!!!(('+#$FF+#$FF+#$FF+#$FF+'((!!!!((!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'((((((((((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+#$FF+#$FF+'('+
  '(((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((@@((((@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@'+#$FF+
  #$FF+'@@'+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+'(('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+
  #$FE+#$FE+#$FE+#$FE+#$FE+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'##'+#$FF+'##'+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'##'+#$FF+'######'+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FE+#$FE+#$FE+#$FE+#$FE+'####'+#$FE+#$FE+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'###'+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+'###'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#'+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+'#!!'+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'#'+#$FF+#$FF+'!!#'+#$FF+#$FF+'#!!!!'+#$FF+'######'+#$FF+'!!!!#'+
  #$FF+#$FF+#$FF+'!!!!!!(!!(!!!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((!!('+
  '!!(!!(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((!!!!((((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'(((((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@@@'+#$FF+#$FF+
  #$FF+'@@@@((('+#$FF+#$FF+'(((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+
  #$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+
  '(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+'##'+#$FF+
  '##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+'####'+
  '##'+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FE+#$FE+#$FE+#$FE+
  #$FE+'####'+#$FE+#$FE+#$FE+#$FE+#$FE+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '###'+#$FE+#$FE+#$FE+#$FE+#$FE+#$FE+'###'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+'######'+#$FF+'!'+
  '!!'+#$FF+#$FF+#$FF+#$FF+'#!!!!!!(!!(!!!!!!#'+#$FF+#$FF+'#!!((!!(!!(!!'+
  '((!!#'+#$FF+#$FF+'#'+#$FF+'(((((!!!!((((('+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+
  '(((((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@@@'+#$FF+#$FF+#$FF+'@@@@((('+#$FF+
  #$FF+'(((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+#$FF+#$FF+'(((((((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'((((((@@(((('+#$FF+'('+#$FF+#$FF+#$FF+#$FF+'('+
  '('+#$FF+#$FF+'@@'+#$FF+'@@'+#$FF+'@@'+#$FF+#$FF+#$FF+'('+#$FF+#$FF+#$FF+
  '('+#$FF+#$FF+'@@'+#$FF+'@@@@@@'+#$FF+'@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'((((@@@@@@(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@((((((((@@'+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!'+#$FF+#$FF+#$FF+'@@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'@@'+#$FF+#$FF+#$FF+'!'+#$FF+#$FF+'#!!'+#$FF+#$FF+'@'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'@'+#$FF+#$FF+'!!#'+#$FF+#$FF+'#!!!!'+#$FF+'@@@@@@'+#$FF+'!'+
  '!!!#'+#$FF+#$FF+#$FF+'!!!!!!(!!(!!!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '((!!(!!(!!(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((!!!!((((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@@@'+#$FF+
  #$FF+#$FF+'@@@@((('+#$FF+#$FF+'(((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'(((('+#$FF+#$FF+
  '(((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((@@(((('+#$FF+'('+#$FF+
  #$FF+#$FF+#$FF+'(('+#$FF+#$FF+'@@'+#$FF+'@@'+#$FF+'@@'+#$FF+#$FF+#$FF+'('+#$FF+
  #$FF+#$FF+'('+#$FF+#$FF+'@@'+#$FF+'@@@@@@'+#$FF+'@@'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'((((@@@@@@(((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+
  '((((((((@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+'@@@@@@'+#$FF+'!!!'+#$FF+#$FF+#$FF+#$FF+'!'+
  '!!!!!!(!!(!!!!!!!'+#$FF+#$FF+'#!!((!!(!!(!!((!!#'+#$FF+#$FF+'#'+#$FF+'('+
  '((((!!!!((((('+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+'(((((((((((((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@('+
  '(((((((((((@@@'+#$FF+#$FF+#$FF+'@@@@((('+#$FF+#$FF+'(((@@@@'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@@@@@@@(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'@@@@@@@@@@(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'(('+#$FF+'(('+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'(('+#$FF+'(((((('+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+
  '@@@((((@@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((@@@@@@((('+#$FF+
  #$FF+#$FF+#$FF+#$FF+'('+#$FF+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '(('+#$FF+#$FF+#$FF+'('+#$FF+#$FF+'#!!'+#$FF+#$FF+'('+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'('+#$FF+#$FF+'!!#'+#$FF+#$FF+'(!!!!'+#$FF+'(((((('+#$FF+'!!!!('+
  #$FF+#$FF+#$FF+'!!!!!!(!!(!!!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((!!('+
  '!!(!!(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((((!!!!((((('+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'(((((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '(((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@@@'+#$FF+#$FF+
  #$FF+'@@@@((('+#$FF+#$FF+'(((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@'+
  '@@@@@@(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@@@'+
  '@@@(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(('+#$FF+'('+
  '('+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(('+#$FF+
  '(((((('+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@@((((@@@@@'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(((@@@@@@((('+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'(('+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+'((((('+
  '('+#$FF+'!!'+#$FF+#$FF+#$FF+#$FF+#$FF+'(!!!!!!(!!(!!!!!!('+#$FF+#$FF+'#'+
  '!!((!!(!!(!!((!!#'+#$FF+#$FF+'('+#$FF+'(((((!!!!((((('+#$FF+'('+#$FF+#$FF+
  #$FF+#$FF+'(((((((((((((('+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'((((((('+
  '((((('+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@((((((((((((@@@'+#$FF+#$FF+#$FF+'@'+
  '@@@((('+#$FF+#$FF+'(((@@@@'+#$FF+#$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'@@@@'+#$FF+#$FF+#$FF+#$FF;

Const TurtleIcon : Array[0..9179] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'"***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+'))))'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""****'+#$FF+#$FF+') ) ) )'+#$FF+#$FF+#$FF+#$FF+
  '""""""")) ))) )))'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'"") ) ) ) ) )'+#$FF+
  #$FF+'""'+#$FF+'""""'+#$FF+'))) ))) )))'+#$FF+#$FF+#$FF+'""""") ) ) ) ) '+
  ') )'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')) ))) ))) ))'+#$FF+#$FF+#$FF+
  '------) ) ) ) ))"'+#$FF+#$FF+'-----""""""'+#$FF+#$FF+'--"""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'**'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""****'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+
  #$FF+#$FF+#$FF+'))))'+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'""'+#$FF+
  ')) ) ) ))'+#$FF+#$FF+#$FF+'"'+#$FF+#$FF+#$FF+#$FF+'"")) ))) ))))'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"") ) ) ) ) )'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'"" ))) ))) ) )'+#$FF+#$FF+'"""""") ) ) ) ) )))'+#$FF+#$FF+#$FF+
  '"""" ) ))) ))) )'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'----) ) ) ) )'+#$FF+
  '"'+#$FF+#$FF+#$FF+'----""""""'+#$FF+#$FF+'-----'+#$FF+'------""""""---'+
  '-"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'""***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+')))))'+#$FF+
  #$FF+#$FF+#$FF+#$FF+'"""****'+#$FF+#$FF+') ) ) ))'+#$FF+#$FF+#$FF+'""""'+
  '""")) ))) )))'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'"") ) ) ) ) ))'+#$FF+'"'+
  '"'+#$FF+'"""" ))) ))) )))'+#$FF+#$FF+#$FF+'""""") ) ) ) ) ) )'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+')) ))) ))) ))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+') ) ) ) )'+#$FF+'"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '""""""'+#$FF+#$FF+'""""-'+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+
  '""""""-'+#$FF+#$FF+#$FF+'------'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'-----'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""***'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+
  #$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'"""****'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+'))))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"""'+#$FF+#$FF+'""'+#$FF+') ))) )))'+#$FF+#$FF+#$FF+'"'+#$FF+#$FF+#$FF+
  #$FF+'"") ) ) ) ) )'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+'))) '+
  '))) )))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"") ) ) ) ) ) )'+#$FF+'""""""'+
  ')) ))) ))) ))'+#$FF+#$FF+#$FF+'"""") ) ) ) )   )'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'"")) ))) )))-'+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+
  #$FF+#$FF+'""""-'+#$FF+#$FF+#$FF+'""""""--'+#$FF+#$FF+'""""""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****""**'+
  '**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+
  '""**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+
  '***""****'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+
  '"""") )'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""""" )))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+') ) )'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')) )))'+#$FF+
  #$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"") ) ) )'+#$FF+#$FF+
  #$FF+'"""""""""" ))) ))'+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""") ) ) )'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+'))) )"""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+#$FF+'---'+
  '---'+#$FF+#$FF+#$FF+#$FF+'-----'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+
  #$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'****""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+
  '""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+') )))""'+#$FF+#$FF+'"""'+
  '")'+#$FF+#$FF+#$FF+#$FF+#$FF+') ) )'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+'""'+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+')))""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+') )'+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'))'+#$FF+#$FF+#$FF+#$FF+')) )"""""""")'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+')'+#$FF+'""""""""))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'""""""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+
  #$FF+'""""""'+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '****""'+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'""""'+#$FF+'**'+#$FF+#$FF+'"")'+
  ')'+#$FF+#$FF+'))'+#$FF+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+')'+#$FF+
  ')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'""""'+#$FF+')'+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+
  ')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'))))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+'"""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+'""""'+
  '""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****""""'+
  '"'+#$FF+'""""'+#$FF+#$FF+'""'+#$FF+#$FF+'"**'+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+
  '""""'+#$FF+#$FF+'"""'+#$FF+'"""""""'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+
  '"""'+#$FF+#$FF+'""""""))'+#$FF+#$FF+'))'+#$FF+#$FF+'))""'+#$FF+#$FF+#$FF+
  '""")'+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+'"'+#$FF+#$FF+
  #$FF+#$FF+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')"'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'))))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'"""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****"""""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****'+#$FF+#$FF+'"""'+#$FF+
  #$FF+#$FF+'"""'+#$FF+#$FF+#$FF+'"'+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+'""'+
  '""'+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""""""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+
  '"""'+#$FF+#$FF+#$FF+'""""))'+#$FF+#$FF+'))'+#$FF+#$FF+'))""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+
  #$FF+'"'+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+
  ')"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))))'+#$FF+')'+#$FF+')'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'***""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+
  '""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+#$FF+'))'+#$FF+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')))'+#$FF+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+
  #$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+
  '))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'))))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***'+
  '"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+
  #$FF+'"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""--""""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'"""""--""--"""""'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+
  '------'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+
  #$FF+'))'+#$FF+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+
  ')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '")))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+
  #$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+'"""""))))'+#$FF+
  ')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'***""***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****""****'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""--""--""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'""""--))'+#$FF+#$FF+'))'+#$FF+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+
  '""'+#$FF+#$FF+')'+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+'--'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+
  #$FF+#$FF+#$FF+'"""-))))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'"""'+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '"""'+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')"""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'""""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '"""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+
  '""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"""--""--""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""--))'+#$FF+
  #$FF+'))'+#$FF+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+')'+#$FF+')))'+
  #$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+'--'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+'"""-))))'+#$FF+
  ')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'))'+#$FF+
  ')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+')'+#$FF+
  ')'+#$FF+')"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '***"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+
  #$FF+'"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""--""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""--""--""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'--))'+#$FF+#$FF+'))'+#$FF+
  #$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')'+
  '))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+'--'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+'"""-))))'+#$FF+
  ')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'))'+#$FF+
  ')))'+#$FF+'))'+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+')'+#$FF+
  ')'+#$FF+')"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '***"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'))"'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""))'+#$FF+'))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'")'+#$FF+')))'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+
  #$FF+'))))'+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'"""--)'+#$FF+')'+#$FF+')))'+#$FF+'))'+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+'""--'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+'--'+#$FF+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'------))'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+'"'+#$FF+#$FF+#$FF+'--------'+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+
  #$FF+'"""--------""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""----"""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+
  '""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'***")))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**))'+#$FF+'))))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"")'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+#$FF+#$FF+'""""--'+#$FF+#$FF+
  ')'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'""""--""))'+#$FF+')'+#$FF+
  ')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'--""--)))'+#$FF+')'+#$FF+')'+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'------'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'--------'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'""""------""""'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""-'+
  '-""""""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+
  '"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"""""")))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+
  #$FF+'))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '""")'+#$FF+')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '""'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'"""--"")'+#$FF+
  ')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+'""""--""))'+#$FF+')))'+#$FF+')'+#$FF+
  ')'+#$FF+#$FF+'""'+#$FF+#$FF+'--"")))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'------))))'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'------)'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '------'+#$FF+#$FF+'))))))'+#$FF+#$FF+#$FF+#$FF+'----------'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""--'+#$FF+#$FF+'--""""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+
  #$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+
  '"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+
  #$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'"'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""--""""'+#$FF+#$FF+')))'+#$FF+
  ')'+#$FF+#$FF+#$FF+'""""--""--))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+'""'+#$FF+
  #$FF+'--""--)'+#$FF+')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'-'+
  '---'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '----)'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '----))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+'------)))'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+'"""--'+#$FF+#$FF+'--))))'+#$FF+
  ')))'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+
  #$FF+')'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '))))))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+
  #$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'"'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'--""""'+#$FF+#$FF+
  ')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""--""))'+#$FF+')'+#$FF+
  ')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""--)'+#$FF+')))'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+'"'+#$FF+#$FF+#$FF+'--"")'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+
  #$FF+'"""----))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+'------'+
  ')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+'"""--'+#$FF+#$FF+'-'+
  '-))))'+#$FF+')))'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+'"")'+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+'""""))))))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+
  #$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'"'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'--"""")))'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""--))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""")'+#$FF+')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+'""""--)'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+'"'+#$FF+
  #$FF+'----))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"""")))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"""'+#$FF+#$FF+#$FF+'))))'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '"'+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""))))))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***"'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '**'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+
  '"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '--)))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""))'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""))))'+#$FF+
  ')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"")'+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '"""))))))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '***""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'**'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+')))'+#$FF+')'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+')'+#$FF+')'+#$FF+')))""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+')))'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))))))""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'*"'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'*"'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'))))'+#$FF+')'+#$FF+'""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '))'+#$FF+')'+#$FF+')))""'+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ')'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')))'+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+')""""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+'""""'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')))'+#$FF+#$FF+#$FF+'"""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+'""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))))))""""'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+#$FF+#$FF+#$FF+'"'+
  '"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+#$FF+
  #$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))))))))))'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  ')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'))'+#$FF+')))'+#$FF+'))'+
  ')'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+'))'+#$FF+')'+#$FF+')'+#$FF+')'+
  #$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""))'+#$FF+')))'+#$FF+
  ')))))'+#$FF+#$FF+#$FF+#$FF+'"""")))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+'""'+
  '""'+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+#$FF+'"""""""'+
  '"'+#$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+'"'+#$FF+#$FF+'""""'+#$FF+#$FF+
  #$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'**'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""****'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+
  #$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'""'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+')))))'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"")'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')))'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""")'+#$FF+')'+#$FF+'))'+#$FF+')'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""))'+#$FF+'))'+#$FF+')'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"")'+#$FF+'))'+#$FF+')))'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+')))'+#$FF+')'+#$FF+
  ')'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+#$FF+')'+#$FF+')'+
  '))'+#$FF+')'+#$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+#$FF+'"")))'+#$FF+')'+#$FF+
  '))'+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+'""'+#$FF+'""")))'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'""""""""")))))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""""""'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+#$FF+
  '**""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"'+
  '"'+#$FF+#$FF+'**""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'"****"'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""***'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+#$FF+#$FF+
  '**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'"""""'+#$FF+
  #$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""""'+
  '"****'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'-'+#$FF+
  #$FF+#$FF+'"""""'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'"""'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'""'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+
  #$FF+#$FF+'---'+#$FF+'""")))'+#$FF+')'+#$FF+')'+#$FF+')))'+#$FF+#$FF+'""""'+
  '"")'+#$FF+')'+#$FF+')))'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+#$FF+#$FF+'"""")'+
  ')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')'+#$FF+')""'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+')))))'+#$FF+')))'+#$FF+')))'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'---'+#$FF+
  ')'+#$FF+')'+#$FF+')'+#$FF+'))'+#$FF+'"'+#$FF+#$FF+#$FF+#$FF+'---"""""'+#$FF+
  #$FF+#$FF+#$FF+'---""'+#$FF+'---""""""'+#$FF+#$FF+#$FF+'---"""'+#$FF;

Const CrabeIcon : Array[0..4079] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'##%'+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+'########'+#$FF+
  #$FF+#$FF+'##'+#$FF+'%%'+#$FF+'%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'###'+#$FF+'%'+
  '%'+#$FF+'%%'+#$FF+'%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'##'+#$FF+'%%%'+#$FF+'%'+
  '%%%'+#$FF+#$FF+'########'+#$FF+#$FF+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%%%%%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%%'+#$FF+'%%%%%%%%%#'+
  '#%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%%%%%%%'+#$FF+#$FF+#$FF+'%%%%%%%%%%'+
  '%%%%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'%%%%%%%%%%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+
  #$FF+#$FF+'%%'+#$FF+'%%'+#$FF+'%%'+#$FF+'%'+#$FF+'%%'+#$FF+#$FF+#$FF+'%%'+#$FF+
  '%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+'%'+#$FF+#$FF+'%'+#$FF+#$FF+'%'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+'%%'+#$FF+'%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+'########'+#$FF+
  #$FF+'##'+#$FF+#$FF+'%%'+#$FF+'%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'##'+#$FF+'%'+
  '%'+#$FF+#$FF+'%%%%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'##%%%'+#$FF+#$FF+'%%%%'+
  #$FF+#$FF+'#######%%%%%'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+'%%%%%%%%##'+#$FF+
  '%%'+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%%%%##%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%'+
  '%%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%'+
  '%%%%%%%%%%'+#$FF+#$FF+'##%%%%%%%%%%%%%%##'+#$FF+'%%'+#$FF+#$FF+#$FF+'%'+
  '%%%%%%%%%'+#$FF+#$FF+'%%'+#$FF+'%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+
  '%%'+#$FF+#$FF+'%'+#$FF+#$FF+'%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+'%%%'+#$FF+
  '%%'+#$FF+#$FF+'%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+
  #$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'###'+#$FF+#$FF+'#%'+#$FF+
  #$FF+#$FF+'##%%'+#$FF+#$FF+'%%##%%##'+#$FF+'%'+#$FF+#$FF+#$FF+'%%###%%##'+
  '#%'+#$FF+'%##'+#$FF+'%%'+#$FF+'%%##'+#$FF+#$FF+'##'+#$FF+#$FF+'##'+#$FF+'%'+
  '%%%%%%%%'+#$FF+'########'+#$FF+'%%%%%'+#$FF+'%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+
  #$FF+'%%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%##'+
  '%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%!!##!!%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'#%%%%%!!##!!%%%'+#$FF+#$FF+#$FF+#$FF+'#%'+#$FF+
  #$FF+'%##!!##!!##%#'+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+
  '%%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+
  '%%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '###'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '#'+#$FF+#$FF+'#%%%##%%'+#$FF+#$FF+'%%##'+#$FF+#$FF+#$FF+'##%%%'+#$FF+'%'+
  '%###%%###%%'+#$FF+#$FF+#$FF+'#%%%'+#$FF+'%##'+#$FF+#$FF+'##'+#$FF+#$FF+
  '##%%'+#$FF+'%%%%%%%%########%'+#$FF+'%%%%'+#$FF+'%%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+
  #$FF+'%%%%'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%'+
  '%%##%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%!!##!!%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%!!##!!%%%'+#$FF+#$FF+#$FF+#$FF+'#%'+#$FF+
  '%%##!!##!!##%%'+#$FF+#$FF+#$FF+'#%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+
  '%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+
  '%%'+#$FF+'%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%#'+
  '#'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%%%%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%'+
  '%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%'+
  '%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+'%%%%%%%%%%'+#$FF+#$FF+#$FF+
  #$FF+'###'+#$FF+#$FF+'%##%%%%##%%%'+#$FF+'#'+#$FF+'#%'+#$FF+#$FF+'%%%%%%%'+
  '%%%%%%%'+#$FF+'#%%%'+#$FF+#$FF+'%%%%%%%%%%%%'+#$FF+#$FF+'%%%%%'+#$FF+#$FF+
  #$FF+#$FF+'%%%%%%'+#$FF+#$FF+#$FF+#$FF+'%%%'+#$FF+'%%%'+#$FF+'%%##%%##%%'+
  #$FF+'%%%'+#$FF+#$FF+#$FF+'%%%##%%%%%%##%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%'+
  '%%%%%%%%%%%%%'+#$FF+#$FF+#$FF+'##%%%%%%%%%%%%%%%%##%%'+#$FF+'##%%%%%%'+
  '%%%%##'+#$FF+'%%%%'+#$FF+'%%%%##%%##%%%%'+#$FF+'%%%%'+#$FF+'%%'+#$FF+#$FF+
  '%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+'%%%%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+
  #$FF+'%%'+#$FF+#$FF+'%%'+#$FF+'%%%%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%'+
  '%'+#$FF+#$FF+'%%'+#$FF+'%%%%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+
  #$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%##'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%##'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+
  '%%%%%%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##%%%%%%%%##'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%##%%%%%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'%%%%%%%%##%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+
  #$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+'##'+#$FF+#$FF+'%'+
  '%'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+
  #$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+'%%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'%%%##%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'##%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%'+#$FF+#$FF+'%%%'+
  '%'+#$FF+#$FF+'%%%%%'+#$FF+'%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+#$FF+#$FF+'%%'+
  '%%'+#$FF+#$FF+'%%##%%'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'%%##%%'+#$FF+'%%'+
  '%########%%%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+
  '##'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%%%########%%%%'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##%%'+#$FF+#$FF+'####'+#$FF+
  #$FF+'%%##'+#$FF+#$FF+#$FF+'##%'+#$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+#$FF+
  '#'+#$FF+#$FF+#$FF+'%##'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%%%%%'+#$FF+
  #$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%##%%%%%%%%%'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'##%%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%'+#$FF+
  #$FF+'%%%%'+#$FF+#$FF+'%%%%%'+#$FF+'%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+#$FF+#$FF+
  '%%%%'+#$FF+#$FF+'%%##%%'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'%%##%%'+#$FF+'%'+
  '%%########%%%'+#$FF+'%%'+#$FF+'%%'+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+
  '##'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%%%########%%%%'+#$FF+#$FF+#$FF+
  #$FF+'%%%%########%%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+
  #$FF+#$FF+'##'+#$FF+#$FF+#$FF+'%%'+#$FF+'%%'+#$FF+'%%%########%%%'+#$FF+'%'+
  '%##%%'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'%%##%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+
  #$FF+#$FF+'%%%%'+#$FF+#$FF+'%%'+#$FF+'%%%%%'+#$FF+#$FF+'%%%%'+#$FF+#$FF+'%'+
  '%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'##%%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%%##%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+
  '%%%%%%'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'##%'+#$FF+#$FF+#$FF+'#'+#$FF+
  #$FF+#$FF+#$FF+'#'+#$FF+#$FF+#$FF+'%##'+#$FF+#$FF+#$FF+'##%%'+#$FF+#$FF+
  '####'+#$FF+#$FF+'%%##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%'+
  '%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%'+
  '%%%%####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%##'+#$FF+
  #$FF+'####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'##'+#$FF+#$FF+'##%%%%####'+#$FF+
  #$FF+#$FF+#$FF+'##'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+
  '%%'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '##%%%%%%%%'+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%%%%%%'+
  '%'+#$FF+#$FF+'##'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%'+#$FF+#$FF+
  '##'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+'##'+#$FF+#$FF+
  #$FF+#$FF+'##'+#$FF+#$FF+'%%%%%%%%####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'#'+
  '#'+#$FF+#$FF+'%%%%%%####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'%%%%'+#$FF+#$FF+'####'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'##%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'##%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'%%##%'+#$FF+'##'+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%'+#$FF+#$FF+#$FF+#$FF+'%#'+#$FF+'%%%'+#$FF+'%#%%%%%%#%'+#$FF+
  '#%%#'+#$FF+'%%%'+#$FF+'%###%%###%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%'+#$FF+'%%'+
  '%#'+#$FF+#$FF+'##'+#$FF+#$FF+'#%'+#$FF+#$FF+'%%'+#$FF+'%'+#$FF+#$FF+'%%%'+
  '########%'+#$FF+'%%%'+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+'%%%%%%%%'+#$FF+#$FF+
  '%%'+#$FF+#$FF+#$FF+#$FF+#$FF+'%%'+#$FF+#$FF+#$FF+'%%%%'+#$FF+#$FF+'%%%'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%%%%%%%%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'%%%%%###%%%'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'%%%%!'+
  '!###!!%%%'+#$FF+#$FF+#$FF+'##%%%##!!###!!##%%##%%'+#$FF+'%%##!!###!!#'+
  '#%'+#$FF+'%%%%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+
  '%%%%'+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+'%%%%'+#$FF+
  '%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+#$FF+'%%'+#$FF+'%%';

Const SauterelleIcon : Array[0..2379] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'*****'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+
  '***'+#$FF+#$FF+'*&&&&****'+#$FF+#$FF+'****&&&*'+#$FF+#$FF+'****&&**&&*'+
  '*&&***'+#$FF+#$FF+#$FF+#$FF+#$FF+'****&&&&&&***'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+'!&&!'+#$FF+'!!'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!'+#$FF+#$FF+'!&&!'+#$FF+#$FF+'!'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&!!&&//&&!!&&'+#$FF+#$FF+#$FF+#$FF+'&&'+
  '&&&&//////&&&&&&'+#$FF+#$FF+'&&'+#$FF+#$FF+'&&//////&&'+#$FF+#$FF+'&&'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'&&&&&&&&&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'/'+#$FF+'&!!!!!!&'+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+
  '//&&!!&&//'+#$FF+'!/!!'+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'!!!!'+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+'&&'+#$FF+#$FF+'&&'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&&&&'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!&&!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+'!&&!'+#$FF+'!!'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'***!'+#$FF+#$FF+'!&&!'+#$FF+#$FF+'!***'+#$FF+#$FF+#$FF+'*'+
  '***!!&&//&&!!****'+#$FF+'***&&&&//////&&&&****&&&&&&//////&&&&&&*'+#$FF+
  '&&'+#$FF+#$FF+'&&&&&&&&&&'+#$FF+#$FF+'&&'+#$FF+#$FF+#$FF+'//'+#$FF+'&&!'+
  '!!!!!&&'+#$FF+#$FF+#$FF+#$FF+#$FF+'!/!'+#$FF+'/'+#$FF+#$FF+'&&!!&&'+#$FF+
  #$FF+'//'+#$FF+#$FF+#$FF+'!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+
  #$FF+#$FF+'!/!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+'&&'+#$FF+#$FF+'&&'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&&&&'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!&&!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+'!&&!'+#$FF+'!!'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!'+#$FF+#$FF+'!&&!'+#$FF+#$FF+'!'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+'!!!&&&&!!!'+#$FF+#$FF+'&&'+#$FF+#$FF+
  '&&&&&&&&//&&&&&&&&'+#$FF+#$FF+#$FF+#$FF+'&&&&//&&//&&&&'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'***&&&&&&&&&&***'+#$FF+#$FF+#$FF+'****&&!!!!!!&&****'+#$FF+'*'+
  '***&!!&&&&&&!!&*****!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'!!!!*'+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!'+
  '!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!!'+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+'!!!!!!'+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+
  #$FF+#$FF+#$FF+'//'+#$FF+#$FF+'&&&&&&'+#$FF+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'//&&&&&&//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '&&&&//////&&&&'+#$FF+#$FF+#$FF+#$FF+'&&&&&&//////&&&&&&'+#$FF+#$FF+'&'+
  '&**!!&&//&&!!**&&'+#$FF+'*****!!!!&&!!!!**********!!'+#$FF+#$FF+'&&'+#$FF+
  #$FF+'!!**********!!'+#$FF+#$FF+'&&'+#$FF+#$FF+'!!********'+#$FF+#$FF+#$FF+
  #$FF+'!!&&!!'+#$FF+#$FF+#$FF+#$FF+'****&&&&&&'+#$FF+#$FF+'&&'+#$FF+#$FF+
  '&&&&&&*'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'!!!!'+#$FF+#$FF+'!!'+#$FF+#$FF+'!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'//!!!!!!//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+
  #$FF+'&&&&&&'+#$FF+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'/'+
  '/&&&&&&//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&&&//////&&&&'+#$FF+
  #$FF+#$FF+#$FF+'&&&&&&//////&&&&&&'+#$FF+#$FF+'&&**!!&&//&&!!**&&'+#$FF+
  '*****!!!!&&!!!!**********!!'+#$FF+#$FF+'&&'+#$FF+#$FF+'!!**********!!'+
  #$FF+#$FF+'&&'+#$FF+#$FF+'!!********'+#$FF+#$FF+#$FF+#$FF+'!!&&!!'+#$FF+
  #$FF+#$FF+#$FF+'****&&&&&&'+#$FF+#$FF+'&&'+#$FF+#$FF+'&&&&&&*'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'**&&&&&'+#$FF+#$FF+'&&'+#$FF+#$FF+'&&&&&*****'+#$FF+#$FF+#$FF+
  #$FF+'!!&&!!'+#$FF+#$FF+#$FF+#$FF+'********!!!!&&!!!!*****'+#$FF+'****!'+
  '!'+#$FF+#$FF+'&&'+#$FF+#$FF+'!!****'+#$FF+#$FF+'****!!!!&&!!!!****'+#$FF+
  #$FF+'&&**!!&&//&&!!**&&'+#$FF+#$FF+#$FF+'&&&&&//////&&&&&'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'&&&&//////&&&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'//'+
  '&&&&&&//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+#$FF+'&&&'+
  '&&&'+#$FF+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+#$FF+#$FF+#$FF+'!!!!'+
  '!!'+#$FF+#$FF+#$FF+#$FF+'//'+#$FF+'!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'******'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '!!'+#$FF+#$FF+#$FF+#$FF+'****&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!'+#$FF+
  #$FF+'&&****&&&&'+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+#$FF+#$FF+'&&******&&'+#$FF+
  #$FF+'//'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&'+#$FF+#$FF+#$FF+#$FF+'!!&&/'+
  '/'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!&&&&&&'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!!!&&////&&'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'!!'+#$FF+#$FF+'!!&&////!!'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&'+
  '&&&&//////!!!!'+#$FF+#$FF+#$FF+#$FF+'!!'+#$FF+#$FF+'!!&&////!!'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'!!!!!!&&////&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'!!!!&&&&&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&!!!!&&&&/'+
  '/'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&******&&'+#$FF+#$FF+'//'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'&&****&&&&'+#$FF+#$FF+#$FF+#$FF+'!!!'+#$FF+
  #$FF+#$FF+#$FF+#$FF+'****&&'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!!!'+#$FF+
  #$FF+'******'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'!!';

Const MoneyIcon : Array[0..3399] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$'+
  '$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$'+
  '$$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$$$$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+
  '$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$$$$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+
  '$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$'+
  '$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++$$++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++$$++'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++$$++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++$$++'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'++$$++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'++++$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'++++$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++$$'+
  '$$$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++$$$$$$++++'+#$FF+#$FF+#$FF+
  #$FF+'$$$$$$$$$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+'++++$$$$$$++++'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'++++$$$$$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'++++$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'+'+
  '+++$$++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '++$$++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '++++++++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++++++++++++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'++++++++++++++'+#$FF+#$FF+#$FF+#$FF+'+++++++'+
  '+$$++++++++'+#$FF+#$FF+'++++$$++,,++$$++++'+#$FF+#$FF+'++++++,,,,,,++'+
  '++++'+#$FF+#$FF+'++++$$,,,,,,$$++++'+#$FF+#$FF+'++++++,,,,,,++++++'+#$FF+
  #$FF+'++++$$++,,++$$++++'+#$FF+#$FF+'++++++++$$++++++++'+#$FF+#$FF+#$FF+
  #$FF+'++++++++++++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++++++++++++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++++++++'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'++++++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$'+
  '$'+#$FF+#$FF+'++++,,++++'+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '++,,,,,,++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++,,,,,,,,,,++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'++,,,,,,,,,,++'+#$FF+#$FF+#$FF+'$'+#$FF+#$FF+
  '++,,,,,,,,,,++'+#$FF+#$FF+'$'+#$FF+#$FF+#$FF+'++,,,,,,,,,,++'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'++,,,,,,,,,,++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'++,,,,,,++'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+'++++,,+'+
  '+++'+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'++++++'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$$$$$$$'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+
  #$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+'$'+
  '$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$$$'+
  '$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '$$'+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'$$'+#$FF+
  #$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'$$$$$$$$$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'$$'+#$FF+#$FF+'$$'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const TornadeIcon : Array[0..3739] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00000'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+
  '0'+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+
  '000'+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'0'+#$FF+'0'+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+
  '0'+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+'00'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000000'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+
  '00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'00'+#$FF+#$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000000'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000000'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000000'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0000'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+
  '000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'0000000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'00000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const BallIcon : Array[0..4079] of Char =
  #$FF+#$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '55555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555555.'+
  '55'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'5555555..55'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'5555...55'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55'+
  '.55555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55..5555555'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55...555555'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'555..5555'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '55...5555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55..55'+
  '55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55..5555555'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555555555'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'5'+
  '5555..55'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'5555555'+
  '..55'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555555.55'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555555.55'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'555555555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'55555'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'33'+#$FF+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+'33'+#$FF+'3'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'32'+#$FF+'2'+#$FF+#$FF+#$FF+'22'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'22'+#$FF+'0023'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+
  #$FF+#$FF+'11'+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+'31'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'111'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'1'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3'+#$FF+#$FF+'01'+#$FF+#$FF+#$FF+'0113'+#$FF+
  '3'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'3000001'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'44'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'42'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'22'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'22'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+#$FF+'2'+#$FF+'40'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'22'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'40000'+#$FF+
  #$FF+'0002'+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'22000'+#$FF+'0'+#$FF+
  '0'+#$FF+'00'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+
  '0000'+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'44'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'44'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'224'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'44'+#$FF+'24'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+'4200'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0'+#$FF+#$FF+#$FF+'40'+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+'02'+#$FF+#$FF+#$FF+#$FF+'2'+
  '0'+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+'2'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'222'+#$FF+#$FF+#$FF+'00'+#$FF+'2'+#$FF+'0'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'000022'+#$FF+#$FF+'2200'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'20'+#$FF+#$FF+'00000'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+'00'+#$FF+'0'+
  '0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'44'+#$FF+
  #$FF+'4'+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+'4'+#$FF+
  '4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'4'+#$FF+#$FF+#$FF+'4'+#$FF+'42'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'42'+#$FF+'44'+#$FF+#$FF+#$FF+'4'+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+'002'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+'0'+#$FF+#$FF+#$FF+'0'+#$FF+
  '04'+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+'2'+#$FF+'2'+#$FF+'0'+#$FF+#$FF+#$FF+
  #$FF+'0224'+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+'42'+#$FF+#$FF+'000'+#$FF+#$FF+#$FF+
  #$FF+'224'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'4'+#$FF+#$FF+#$FF+'2022'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '0'+#$FF+'004'+#$FF+#$FF+#$FF+'2000'+#$FF+'00'+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+'22'+#$FF+'0'+#$FF+
  #$FF+#$FF+'0'+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+'2'+#$FF+
  #$FF+#$FF+'0000'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+
  #$FF+#$FF+#$FF+'00'+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+'2'+#$FF+'4'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '024'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'24'+#$FF+#$FF+'2444'+#$FF+
  '042'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+'0022'+
  #$FF+'4'+#$FF+'004'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00042'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+#$FF+'00'+#$FF+'2222'+#$FF+#$FF+'4'+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+'22'+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '2'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'2'+#$FF+'0'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00'+#$FF+#$FF+
  #$FF+#$FF+'0'+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'0'+#$FF+'4'+#$FF+#$FF+#$FF+'0220'+#$FF+'2'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'22222444'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'0004'+#$FF+'424'+#$FF+'2'+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '00'+#$FF+#$FF+'44'+#$FF+'444'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+'4'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'0'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'4'+#$FF+'0'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'1'+#$FF+
  '4'+#$FF+#$FF+'14'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'441'+#$FF+'11'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'00';

Const NuageIcon : Array[0..1739] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**>'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '****>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+#$FF+
  #$FF+'******>>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'************>>'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'****>'+#$FF+'**>'+#$FF+'****>'+#$FF+#$FF+#$FF+
  #$FF+#$FF+'****>'+#$FF+'**>'+#$FF+'****>>'+#$FF+#$FF+'******>'+#$FF+'**>'+#$FF+
  '*****>'+#$FF+#$FF+'******************>'+#$FF+'******************>'+#$FF+
  '****'+#$FF+#$FF+'**'+#$FF+#$FF+'**'+#$FF+#$FF+'****>'+#$FF+'**'+#$FF+#$FF+
  '**'+#$FF+#$FF+'**'+#$FF+#$FF+'**'+#$FF+#$FF+'**>'+#$FF+'***************'+
  '***>'+#$FF+'******************>'+#$FF+#$FF+#$FF+'**************>>'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**>'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'****>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+
  #$FF+#$FF+'******>>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'************'+
  '>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'****>'+#$FF+'**>'+#$FF+'****>'+#$FF+
  #$FF+#$FF+#$FF+#$FF+'****>'+#$FF+'**>'+#$FF+'****>>'+#$FF+#$FF+'******>'+#$FF+
  '**>'+#$FF+'*****>'+#$FF+#$FF+'******************>'+#$FF+'*************'+
  '*****>'+#$FF+'******************>'+#$FF+'****'+#$FF+#$FF+'**'+#$FF+#$FF+
  '**'+#$FF+#$FF+'****>'+#$FF+'**'+#$FF+#$FF+'**'+#$FF+#$FF+'**'+#$FF+#$FF+
  '**'+#$FF+#$FF+'**>'+#$FF+'******************>'+#$FF+#$FF+#$FF+'*******'+
  '*******>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'>>'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**>'+
  '>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'****>>'+#$FF+#$FF+#$FF+'>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+#$FF+
  #$FF+#$FF+'*'+#$FF+'**'+#$FF+#$FF+'>>>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+
  '***'+#$FF+#$FF+#$FF+#$FF+'****>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '***'+#$FF+#$FF+'**'+#$FF+#$FF+'**'+#$FF+#$FF+'>>'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'*'+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'****>>'+#$FF+#$FF+'****'+#$FF+#$FF+
  #$FF+#$FF+'**'+#$FF+#$FF+#$FF+'***'+#$FF+'>'+#$FF+#$FF+#$FF+'*****'+#$FF+
  #$FF+#$FF+#$FF+#$FF+'*'+#$FF+#$FF+'**'+#$FF+#$FF+'>'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'**'+#$FF+#$FF+'****'+#$FF+#$FF+'**>>****'+#$FF+#$FF+#$FF+
  '***********>>**'+#$FF+#$FF+'**'+#$FF+#$FF+'**********>>*'+#$FF+#$FF+#$FF+
  '****'+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+'>'+#$FF+#$FF+#$FF+
  '****'+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+#$FF+'*'+
  '**'+#$FF+#$FF+#$FF+'****'+#$FF+#$FF+'**>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'>>'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**>>'+#$FF+#$FF+#$FF+
  '**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+#$FF+#$FF+#$FF+#$FF+
  '****'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'>>**'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+#$FF+'>>*'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**>'+#$FF+'**'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+#$FF+#$FF+'>>'+#$FF+
  #$FF+'>>'+#$FF+#$FF+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'*'+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+'*'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'****'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+
  #$FF+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '**'+#$FF+#$FF+#$FF+#$FF+'***'+#$FF+#$FF+#$FF+#$FF+#$FF+'**'+#$FF+'*'+#$FF+
  #$FF+'*'+#$FF+#$FF+'*'+#$FF+#$FF+#$FF+#$FF+'****'+#$FF+#$FF+'**'+#$FF+'**'+
  '*'+#$FF+'>'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'**>'+#$FF+#$FF+#$FF+#$FF+#$FF+'*'+#$FF+#$FF+#$FF+#$FF+#$FF+
  '**'+#$FF+#$FF+#$FF+#$FF+#$FF+'>>'+#$FF+'**'+#$FF+#$FF+'*'+#$FF+#$FF+#$FF+
  '****'+#$FF+#$FF+'**'+#$FF+#$FF+#$FF+#$FF+'4444440000004'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'4444400000444'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'4'+#$FF+'440000444'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  '4'+#$FF+#$FF+'4000444'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'400044'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'0044'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'0044'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'04'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'4'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const BrickIcon : Array[0..1819] of Char =
  'IIIIIIIIIIIIIIHHHHHHHHHHHIIKKHHHHHHHLLIIKKKKHHHLLLLIIKKKKJJJLLLLIIKKJ'+
  'JJJJJJLLIIJJJJJJJJJJJIIIIIIIIIIIIII'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+' VV'+#$FF+'VV VV VV  VV VV VV VV  VV VV VV V'+
  'V  WW WW WW WW  WW WW WW WW  WW WW WW WW  XX XX XX XX  XX XX XX XX '+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'bbbbbbbb'+
  'bbbbbacccccccccccaaaacccccccaaaaaaabbbbbaaaaaaaabbbbbaaaaaaaa     a'+
  'aaaaa         aabbbbbbbbbbbbb'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'IIIIIIIIIIIIIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'+
  'AAAA                                       IIIIIIIIIIIII'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'III'+
  'IIIIIII'+#$FF+'IIAAAAAAAAAAIAAAAAAAAAAAAIAAAAAAAAAAAAI            I '+
  '           '+#$FF+'II          '+#$FF+#$FF+#$FF+'IIIIIIIIII'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'IIIIIIIIII'+#$FF+#$FF+
  #$FF+'AAAAAAAAAAII'+#$FF+'AAAAAAAAAAAAIAAAAAAAAAAAAI            I     '+
  '       I          II'+#$FF+'IIIIIIIIII'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'IIIIIIIIIIIIIAAAAAAAAAA'+
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'+
  'BIIIIIIIIIIIII'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'IIIIIIIIII'+#$FF+'IIAAAAAAAAAAIAAAAAAAAAAAAIAAAAA'+
  'AAAAAAAIBBBBBBBBBBBBIBBBBBBBBBBBB'+#$FF+'IIBBBBBBBBBB'+#$FF+#$FF+#$FF+
  'IIIIIIIIII'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'IIIIIIIIII'+#$FF+#$FF+#$FF+'AAAAAAAAAAII'+#$FF+'AAAAAAAAAAAAIAAAAAAAA'+
  'AAAAIBBBBBBBBBBBBIBBBBBBBBBBBBIBBBBBBBBBBII'+#$FF+'IIIIIIIIII'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ZZZ'+
  'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ[Z\ZZZZ[ZZZZZ[[\'+#$FF+'ZZ[['+
  'Z'+#$FF+'ZZ[\Z\'+#$FF+'Z[[\\'+#$FF+#$FF+'Z[\'+#$FF+#$FF+#$FF+'Z\\'+#$FF+
  #$FF+#$FF+#$FF+'Z'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ZZZZZZZZZZZZZ'+
  'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ[ZZ[Z[[Z'+#$FF+#$FF+'ZZ['+
  'Z\ZZ[\Z\'+#$FF+#$FF+'ZZZ\'+#$FF+#$FF+#$FF+'Z\'+#$FF+#$FF+#$FF+#$FF+#$FF+
  'ZZ'+#$FF+#$FF+#$FF+#$FF+'Z'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'Z'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'+
  'ZZ[ZZZ[[Z\ZZZZZZ\Z\Z[\'+#$FF+'ZZ[Z'+#$FF+'Z\Z\ZZ\'+#$FF+'Z[Z\'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'ZZ\'+#$FF+#$FF+'Z\'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'Z\'+#$FF+
  #$FF+#$FF+'Z'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'Z'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'+
  'Z\ZZZ[Z'+#$FF+'ZZZ[Z\Z'+#$FF+'Z[Z\'+#$FF+#$FF+'Z[[\Z'+#$FF+#$FF+#$FF+#$FF+
  'Z'+#$FF+#$FF+#$FF+'Z[Z\'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'Z\'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'Z'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'+
  'ZZZZZZZZZZZZZZZZZZZZ\ZZZZZZ[\Z[[Z\Z[Z'+#$FF+'Z[Z\[[Z\'+#$FF+'[Z\'+#$FF+
  'Z[\'+#$FF+#$FF+'Z['+#$FF+#$FF+#$FF+'Z'+#$FF+#$FF+'Z\'+#$FF+#$FF+#$FF+'Z'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'Z'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF;

Const GlaceIcon : Array[0..881] of Char =
  #$FF+#$FF+']]]]]]]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]^^]]'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+']]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]]]]]]]]]'+
  #$FF+#$FF+']]]]]]^^]]]'+#$FF+#$FF+#$FF+#$FF+']]]]]^^]]'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+']]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]]]]]]]]'+#$FF+
  #$FF+#$FF+#$FF+']]]]^]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]^^]]]'+#$FF+#$FF+
  #$FF+#$FF+']]]]]^^]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]]]]]'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+']]]]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]'+
  ']'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]]]]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']'+
  ']]]]]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]]]]]'+#$FF+#$FF+#$FF+#$FF+#$FF+
  ']]]]]]_]]'+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]___]'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+']]]]__]]'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]__]'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]_'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'__]]]]]]]^___'+
  #$FF+'___]]]]]]^___'+#$FF+#$FF+#$FF+'__]]]]]^__'+#$FF+#$FF+#$FF+#$FF+#$FF+
  ']]]]]]]__'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]]]]__'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+']]]]_'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  ']]__'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']_'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']_'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'______]]]]]]_'+#$FF+'_____]]]]]___'+#$FF+#$FF+'_'+#$FF+
  '__]]]]___'+#$FF+#$FF+#$FF+'_'+#$FF+#$FF+'_]]]___'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'_]]]__'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'_]]__'+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']]__'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+']_'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'_'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const TuyauxIcon : Array[0..4967] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOO'+
  'OOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOO'+
  'OO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'MMMMMMMMMMMMMMMMMMMMM'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'MMMMMMMMMMMMMMMMMMMMM'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'O'+
  'OOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOO'+
  'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'PPPPPPPPPPPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOO'+
  'OOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOO'+
  'OOPPOMMMMMOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOPPOOOOMOOOOO'+
  'OOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOPPOOOOMOOOOOO'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOPPOOOOMOOOOOOOOOOOO'+
  #$FF+#$FF+#$FF+#$FF+'OOOOPPOOOOMMMMMMMMMMMMM'+#$FF+#$FF+#$FF+#$FF+'OOO'+
  'OPPOOOOOMMMMMMMMMMMM'+#$FF+#$FF+#$FF+#$FF+'OOOOPPOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+#$FF+#$FF+'OOOOOPPOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOPPO'+
  'OOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOPPPOOOOOOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOPPPPPPPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOO'+
  'OOPPPPPPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOO'+
  'OOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOO'+
  'OOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'MMMMMMMMMM'+
  'MMMMMMMMMMM'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'MMMMMMMMMMMMMMMMMMMMM'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOO'+
  'OOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPPPPPPPPPPPP'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOO'+
  'OOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOMMMMMOPPOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOO'+
  'OOOMOOOOPPOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOMOO'+
  'OOPPOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOMOOOOPPOOOO'+#$FF+#$FF+#$FF+
  #$FF+'MMMMMMMMMMMMMOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+'MMMMMMMMMMMMOOOOOP'+
  'POOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOPPOOOO'+#$FF+#$FF+#$FF+#$FF+
  'OOOOOOOOOOOOOOOOPPOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOPPOOOO'+
  'O'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOPPPOOOOO'+#$FF+#$FF+#$FF+#$FF+
  'PPPPPPPPPPPPPPPPPOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPPPPPPPOO'+
  'OOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'OOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'MMMMMMMMMMMMMMMMMMMMMMMMM'+#$FF+
  #$FF+'MMMMMMMMMMMMMMMMMMMMMMMMM'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'PPPPPPPPPPPPPPPPPPPPPPPPP'+#$FF+
  #$FF+'PPPPPPPPPPPPPPPPPPPPPPPPP'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOO'+
  'OOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'MMMMMMMMMMMMMM'+
  'MMMMMMMMMMM'+#$FF+#$FF+'MMMMMMMMMMMMMMMMMMMMMMMMM'+#$FF+#$FF+'OOOOOOO'+
  'OOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'O'+
  'OOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+
  #$FF+'PPPPPPPPPPPPPPPPPPPPPPPPP'+#$FF+#$FF+'PPPPPPPPPPPPPPPPPPPPPPPPP'+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'MMMMMMMMMMMMMMMOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'MMMMMMMMMM'+
  'MMMMMMOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOMMMOOOO'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOMMOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOOOOOOOOOOOOOMOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPOOOO'+
  'OOMOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'PPPPPPPPPPPOOOOOMOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOPPO'+
  'OOOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOPPOOOOMOOOOOO'+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOONNNNNNOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OONOPNOOONMOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ONOOPNOOOONOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ONOOPNNOOONOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ONNNNNNNNNNOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ONOOPNNOOONOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'ONOOPPNOOONOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OONOPPNOONMOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOONNNNNNOMOOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'OOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  'OOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOO'+
  'OOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOO'+
  'OOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOMMMMMMMMMMMMMMM'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOMMMMMMMMMMMMMMMM'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+'OOOOMMMOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOMMOOOOOOOO'+
  'OOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOMOOOOOOOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOMOOOOOOPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+'OOOOOOMOO'+
  'OOOPPPPPPPPPPP'+#$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPPOOOOOOOOOO'+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOMOOOOPPOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOMOOOOPP'+
  'OOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+'OOOOOOMONNNNNNOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOMNOOONPONOO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOONOOOONPOONO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOONOOONNPOONO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOONNNNNNNNNNO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOONOOONNPOONO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOONOOONPPOONO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOMNOONPPONOO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOMONNNNNNOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF;

Const SortieTuyauxIcon : Array[0..1599] of Char =
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOOMMMMMMOOOOOOOOOOOOMMMMMMMMMMMMMMMMMMMMMMMOOOOMMMMMMMMMMMMMMOOOO'+
  'OOOOMOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPP'+
  'PPPPPPPPPOOOOOOOOPPPPPPPPPPPPPPOOOOPPPOOOOOOOOOOPPPPPPPPPPOOOOOOOOO'+
  'OOOPPPPPPOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOMMMMMMOOOOO'+
  'OOOOOOOMMMMMMMMMMOOOOOOOOOOMMMOOOOMMMMMMMMMMMMMMOOOOOOOOMMMMMMMMMMM'+
  'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPOOOOOO'+
  'OOPPPPPPPPPPPPPPOOOOPPPPPPPPPPPPPPPPPPPPPPPOOOOOOOOOOOOPPPPPPOOOOOO'+
  'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOOOOOOOOOOOOOMMMMOOOOOOOOOOOOOOMMMMMMMMOMMMMMMMMMMMMMOOOOMMMMMMMM'+
  'MMMMMMOOOOOOOOMOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OPPPPPPPPPPPOOOOOOOOPPPPPPPPPPPPPPOOOOPPPOOOOOOOOOOOPPPPPPPPOOOOOOO'+
  'OOOOOOOPPPPOOOOOOOOOOOOOOOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'OOOOOOOOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+'OOOOOOOOOOOOOOOOOOOOOOOMMMMOOOOOOOOOOOOOOMMMMMMM'+
  'MOOOOOOOOOOOMMMOOOOMMMMMMMMMMMMMMOOOOOOOOMMMMMMMMMMMOOOOOOOOOOOOOOO'+
  'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOPOOOOOOOOPPPPPPPPPPPPPPOOOOPP'+
  'PPPPPPPPPPPOPPPPPPPPOOOOOOOOOOOOOOPPPPOOOOOOOOOOOOOOOOOOOOOOOOOOOOO'+
  'OOOO'+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const PowIcon : Array[0..1151] of Char =
  #$FF+#$FF+'SSSSSSSSSSSSSSSSSSSS'+#$FF+#$FF+#$FF+'SUUUUUUUUUUUUUUUUUUUUS'+#$FF+
  'SUUUUUUUUUUUUUUUUUUUUUU'+#$FF+'SUUUUUUUUUUUUUUUUUUUUUUSTTTTTT    TTT'+
  'T   T  T  TTTTTTTT  TTTTTT  T  T  TTT    T  TT   T  T  T  TTT    T '+
  ' TT   T  T  T  TTTTTTTT  TT   T  T  T  TTTTTTT   TT   T  T  T  TTT '+
  '      TTTTTT  TTTTTTTTT        TTTT    TTTTT SUUUUUUUUUUUUUUUUUUUUU'+
  'USSUUUUUUUUUUUUUUUUUUUUUUS'+#$FF+'SUUUUUUUUUUUUUUUUUUUUS'+#$FF+#$FF+#$FF+
  'SSSSSSSSSSSSSSSSSSSS'+#$FF+#$FF+#$FF+#$FF+'SSSSSSSSSSSSSSSSSSSS'+#$FF+
  #$FF+#$FF+'SUUUUUUUUUUUUUUUUUUUUS'+#$FF+'SUUUUUUUUUUUUUUUUUUUUUUSTTTTT'+
  'T    TTTT   T  T  TTTTTTTT  TTTTTT  T  T  TTT    T  TT'+#$FF+#$FF+#$FF+
  'T  T  T  TTTTTTT   TT'+#$FF+#$FF+#$FF+'T  T  T  TTT       TT'+#$FF+#$FF+
  #$FF+'T  TTTTTTTTT        TTTT    TTTTT SUUUUUUUUUUUUUUUUUUUUUUS'+#$FF+
  'SUUUUUUUUUUUUUUUUUUUUS'+#$FF+#$FF+#$FF+'SSSSSSSSSSSSSSSSSSSS'+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+'SSS'+
  'SSSSSSSSSSSSSSSSSSS'+#$FF+'SUUUUUUUUUUUUUUUUUUUUUUSTTTTTT    TTTT   '+
  'T  T  TT     T  TT   T  T  T  TTTTTTT   TT   T  T  T  TT         TT'+
  'TT    TTTTT SUUUUUUUUUUUUUUUUUUUUUUS'+#$FF+'SSSSSSSSSSSSSSSSSSSSSS'+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF;

Const BilleIcon : Array[0..107] of Char =
  #$FF+#$1C+#$1E+#$1E+'B'+#$FF+#$1B+#$1B+#$1D+'BCB'+#$19+#$1B+#$1C+#$1D+'B'+#$1E+
  #$18+#$19+'>'+#$1C+#$1E+#$1D+#$17+#$18+#$19+#$1B+#$1C+#$1B+#$FF+#$17+#$17+
  #$18+#$19+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+#$FF+
  #$FF+#$FF+#$FF+#$FF+#$FF;


{ ============================================================
  Boucle de jeu et rendu graphique - Reecrit pour Graph/PtcGraph
  Compatible Turbo Pascal 7 et Free Pascal 3.2 (mode -Mtp).
  Mode VGAHi 640x480x16 (BGI standard, supporte natif TP7+FPC).
  Le monde original 320x200 est mis a l'echelle 2x -> 640x400,
  les 80 pixels du bas servent de zone HUD/score.
  ============================================================ }

Const
 SCALE   = 2;
 SCR_W   = 640;
 SCR_H   = 480;
 W_W     = 320;
 W_H     = 200;

 iMario=1; iTurtle=2; iCrabe=3; iSauterelle=4;
 iNuage=5; iTornade=6; iBall=7; iGlace=8;
 iBrick=9; iMoney=10; iBille=11;

 MAX_SPR = 32;
 NPLATS  = 8;

 KbEsc   = #27;
 KbSpc   = #32;
 KbExt   = #0;
 KbLeft  = #75;
 KbRight = #77;
 KbDn    = #80;
 KbCtrlL = #12;

Type
 TPlatform = Record X1,X2,Y:Integer; End;
 TSprite   = Record
  Active : Boolean;
  Kind   : Byte;
  X,Y    : Integer;
  DX,DY  : Integer;
  Anim   : Integer;
 End;

Const
 Platforms : Array[0..NPLATS-1] of TPlatform = (
  (X1:0;   X2:132; Y:43),  { Haut-Gauche }
  (X1:188; X2:320; Y:43),  { Haut-Droit  }
  (X1:82;  X2:238; Y:95),  { Centre      }
  (X1:0;   X2:48;  Y:100), { Mi-Gauche   }
  (X1:272; X2:320; Y:100), { Mi-Droit    }
  (X1:0;   X2:120; Y:143), { Bas-Gauche  }
  (X1:188; X2:320; Y:143), { Bas-Droit   }
  (X1:0;   X2:320; Y:189)  { Sol         }
 );

Var
 PalMap   : Array[0..255] of ShortInt;
 Sprites  : Array[0..MAX_SPR-1] of TSprite;
 BgBuf    : Array[0..MAX_SPR-1] of Pointer;
 BgX,BgY  : Array[0..MAX_SPR-1] of Integer;
 BgValid  : Array[0..MAX_SPR-1] of Boolean;
 NumSpr   : Integer;
 GameLevel: Byte;
 Frame    : Word;
 Score    : LongInt;

{ ---------------------------------------------------------- }
{ Construit la table 256 codes-palette -> 16 couleurs EGA.    }
{ Codes 0 et 255 = pixel transparent (-1).                    }
{ ---------------------------------------------------------- }
Procedure BuildPalMap;
Var I:Integer;
Begin
 For I:=0 to 255 do PalMap[I]:=0;
 PalMap[0]:=-1; PalMap[255]:=-1;
 PalMap[33]:=Blue;        PalMap[34]:=Green;
 PalMap[35]:=LightRed;    PalMap[36]:=Yellow;
 PalMap[37]:=Brown;       PalMap[38]:=LightGray;
 PalMap[39]:=LightGray;   PalMap[40]:=LightRed;
 PalMap[41]:=LightGreen;  PalMap[42]:=White;
 PalMap[43]:=Brown;       PalMap[44]:=Yellow;
 PalMap[45]:=Green;       PalMap[46]:=LightGray;
 PalMap[47]:=DarkGray;    PalMap[48]:=Blue;
 PalMap[53]:=Brown;       PalMap[64]:=Brown;
 PalMap[65]:=LightCyan;   PalMap[66]:=Blue;
 PalMap[72]:=LightCyan;   PalMap[73]:=Blue;
 PalMap[74]:=Blue;        PalMap[75]:=Blue;
 PalMap[76]:=Blue;        PalMap[77]:=Yellow;
 PalMap[78]:=Blue;        PalMap[79]:=Brown;
 PalMap[80]:=Red;         PalMap[83]:=LightCyan;
 PalMap[84]:=White;       PalMap[85]:=Blue;
 PalMap[86]:=Yellow;      PalMap[87]:=Brown;
 PalMap[88]:=Red;         PalMap[90]:=LightGray;
 PalMap[91]:=LightGray;   PalMap[92]:=DarkGray;
 PalMap[93]:=White;       PalMap[94]:=LightCyan;
 PalMap[95]:=LightCyan;   PalMap[97]:=Brown;
 PalMap[98]:=LightRed;    PalMap[99]:=Yellow;
 PalMap[101]:=DarkGray;   PalMap[102]:=DarkGray;
 PalMap[254]:=DarkGray;
End;

Procedure ZeroFFs(Var Buf;Sz:Word);
Var I:Word;P:^Byte;
Begin
 P:=@Buf;
 For I:=0 To Sz-1 Do Begin
  If P^=255 Then P^:=0;
  Inc(P);
 End;
End;

{ ---------------------------------------------------------- }
{ Trace un pixel-monde (320x200) en bloc 2x2 a l'ecran.       }
{ ---------------------------------------------------------- }
Procedure WPlot(WX,WY:Integer; C:ShortInt);
Var SX,SY:Integer;
Begin
 If C<0 Then Exit;
 SX:=WX*SCALE; SY:=WY*SCALE;
 PutPixel(SX,  SY,   C);
 PutPixel(SX+1,SY,   C);
 PutPixel(SX,  SY+1, C);
 PutPixel(SX+1,SY+1, C);
End;

{ Trace une icone 20x17 a partir des donnees d'icone.         }
{ Frame = index de l'image dans le tableau d'icone.           }
{ Flip = miroir horizontal (deplacement vers la droite).      }
Procedure DrawIcon(WX,WY:Integer; Var IcData; FrameIdx:Word; Flip:Boolean);
Var P:^Byte; Row,Col,FX:Integer; B:Byte;
Begin
 P:=@IcData; Inc(P, FrameIdx*17*20);
 For Row:=0 to 16 do
  For Col:=0 to 19 do Begin
   B:=P^;
   If Flip Then FX:=19-Col Else FX:=Col;
   WPlot(WX+FX, WY+Row, PalMap[B]);
   Inc(P);
  End;
End;

{ ---------------------------------------------------------- }
{ Decor du niveau : plateformes + tuyaux + POW + sol.         }
{ ---------------------------------------------------------- }
Procedure DrawLevel;
Var I:Integer;
Begin
 SetFillStyle(SolidFill, Black);
 Bar(0, 0, SCR_W-1, SCR_H-1);

 { Plafond bleu foncee }
 SetFillStyle(SolidFill, Blue);
 Bar(0, 0, SCR_W-1, 22*SCALE);

 { Tuyaux haut (cotes gauche et droit) }
 SetFillStyle(SolidFill, Green);
 SetColor(LightGreen);
 Bar(0,            0, 50*SCALE-1, 25*SCALE);
 Bar(270*SCALE, 0, SCR_W-1,    25*SCALE);
 SetFillStyle(SolidFill, LightGreen);
 Bar(8*SCALE,  4*SCALE,  44*SCALE,  20*SCALE);
 Bar(276*SCALE,4*SCALE,  312*SCALE, 20*SCALE);

 { Plateformes - briques rouges/orange avec bordure jaune }
 For I:=0 to NPLATS-1 do With Platforms[I] do Begin
  SetFillStyle(SolidFill, Brown);
  Bar(X1*SCALE, Y*SCALE, X2*SCALE-1, (Y+5)*SCALE-1);
  SetColor(Yellow);
  Line(X1*SCALE, Y*SCALE, X2*SCALE-1, Y*SCALE);
  Line(X1*SCALE, (Y+5)*SCALE-1, X2*SCALE-1, (Y+5)*SCALE-1);
 End;

 { Tuyaux de sortie (sortie tuyaux gauche et droit) }
 SetFillStyle(SolidFill, Green);
 Bar(0,             170*SCALE, 20*SCALE,   189*SCALE);
 Bar(300*SCALE,  170*SCALE, SCR_W-1,    189*SCALE);

 { POW block au centre }
 SetFillStyle(SolidFill, LightCyan);
 Bar(148*SCALE, 143*SCALE, 172*SCALE, 159*SCALE);
 SetColor(Blue);
 Rectangle(148*SCALE, 143*SCALE, 172*SCALE, 159*SCALE);
 SetColor(White);
 OutTextXY(152*SCALE, 148*SCALE, 'POW');

 { Sol rouge avec hachures }
 SetFillStyle(SolidFill, LightRed);
 Bar(0, 189*SCALE, SCR_W-1, 199*SCALE);
 SetColor(Black);
 Line(0, 192*SCALE, SCR_W-1, 192*SCALE);
 Line(0, 196*SCALE, SCR_W-1, 196*SCALE);

 { Zone HUD (sous le monde) }
 SetFillStyle(SolidFill, Black);
 Bar(0, 200*SCALE, SCR_W-1, SCR_H-1);
 SetColor(Yellow);
 OutTextXY(8, 410, 'MARIO BROS - Fleches: deplacer  Espace: sauter  Esc: quitter');
End;

{ ---------------------------------------------------------- }
{ Verifie si un point monde se trouve sur le bord superieur   }
{ d'une plateforme (atterrissage).                            }
{ ---------------------------------------------------------- }
Function StandsOn(WX,WY:Integer):Boolean;
Var I:Integer;
Begin
 StandsOn:=False;
 For I:=0 to NPLATS-1 do With Platforms[I] do
  If(WY=Y)And(WX>=X1)And(WX<X2)Then Begin
   StandsOn:=True; Exit;
  End;
End;

{ Renvoie le Y plateforme directement sous (WX,WY), ou 999.   }
Function FloorBelow(WX,WY:Integer):Integer;
Var I,Best:Integer;
Begin
 Best:=999;
 For I:=0 to NPLATS-1 do With Platforms[I] do
  If(WX>=X1)And(WX<X2)And(Y>=WY)And(Y<Best)Then Best:=Y;
 FloorBelow:=Best;
End;

{ ---------------------------------------------------------- }
{ Sauvegarde / restauration de l'arriere-plan sous un sprite. }
{ ---------------------------------------------------------- }
Procedure SaveBg(I:Integer);
Var SX,SY,SX2,SY2:Integer; Sz:LongInt;
Begin
 SX:=Sprites[I].X*SCALE-2;
 SY:=Sprites[I].Y*SCALE-17*SCALE-2;
 SX2:=SX+20*SCALE+3;
 SY2:=SY+18*SCALE+3;
 If SX<0 Then SX:=0; If SY<0 Then SY:=0;
 If SX2>=SCR_W Then SX2:=SCR_W-1;
 If SY2>=SCR_H Then SY2:=SCR_H-1;
 Sz:=ImageSize(SX,SY,SX2,SY2);
 If Sz<=0 Then Begin BgValid[I]:=False; Exit; End;
 If BgBuf[I]<>NIL Then FreeMem(BgBuf[I],0);
 GetMem(BgBuf[I], Sz);
 If BgBuf[I]=NIL Then Begin BgValid[I]:=False; Exit; End;
 GetImage(SX,SY,SX2,SY2, BgBuf[I]^);
 BgX[I]:=SX; BgY[I]:=SY; BgValid[I]:=True;
End;

Procedure RestoreBg(I:Integer);
Begin
 If(Not BgValid[I])Or(BgBuf[I]=NIL)Then Exit;
 PutImage(BgX[I], BgY[I], BgBuf[I]^, NormalPut);
 BgValid[I]:=False;
End;

{ ---------------------------------------------------------- }
{ Trace un sprite a sa position courante.                     }
{ ---------------------------------------------------------- }
Procedure DrawSprite(I:Integer);
Var Flip:Boolean; F:Word; WX,WY:Integer;
Begin
 With Sprites[I] do Begin
  If Not Active Then Exit;
  Flip:=DX>0;
  F:=Anim Shr 1;
  WX:=X; WY:=Y-16;
  Case Kind Of
   iMario     : DrawIcon(WX,WY,MarioIcon,      F,Flip);
   iTurtle    : DrawIcon(WX,WY,TurtleIcon,     F,Flip);
   iCrabe     : DrawIcon(WX,WY,CrabeIcon,      F,Flip);
   iSauterelle: Begin
                 If Anim=0 Then Dec(WY,3);
                 DrawIcon(WX,WY,SauterelleIcon,F,Flip);
                End;
   iMoney     : DrawIcon(WX,WY,MoneyIcon,      F,Flip);
   iTornade   : DrawIcon(WX,WY,TornadeIcon,    F,Flip);
   iNuage     : DrawIcon(WX,WY,NuageIcon,      F,Flip);
   iBall      : DrawIcon(WX,WY,BallIcon,       F,Flip);
  End;
 End;
End;

{ ---------------------------------------------------------- }
{ Spawn d'un nouvel ennemi a gauche ou a droite.              }
{ ---------------------------------------------------------- }
Procedure SpawnEnemy(SideRight:Boolean);
Var I,Slot:Integer; K:Byte;
Begin
 Slot:=-1;
 For I:=1 to MAX_SPR-1 do
  If Not Sprites[I].Active Then Begin Slot:=I; Break; End;
 If Slot<0 Then Exit;
 Case GameLevel Of
  0: K:=iTurtle;
  1: K:=iCrabe;
  2: If Random(2)=1 Then K:=iTurtle Else K:=iCrabe;
  3: K:=iSauterelle;
  4: K:=iMoney;
  Else K:=Byte(Random(4)+2);
 End;
 With Sprites[Slot] do Begin
  Active:=True;
  Kind  :=K;
  Anim  :=0;
  Y     :=22;
  If SideRight Then Begin X:=250; DX:=-1; End
               Else Begin X:=50;  DX:=1;  End;
  DY:=2; { tombe vers la 1ere plateforme }
 End;
 If Slot>=NumSpr Then NumSpr:=Slot+1;
End;

Procedure MakeEnemies;
Var I:Integer; PresL,PresR:Boolean;
Begin
 PresL:=False; PresR:=False;
 For I:=1 to NumSpr-1 do
  With Sprites[I] do
   If Active And(Y<50)Then Begin
    If X<80  Then PresL:=True;
    If X>200 Then PresR:=True;
   End;
 If Not PresL Then SpawnEnemy(False);
 If Not PresR Then SpawnEnemy(True);
End;

{ ---------------------------------------------------------- }
{ Mise-a-jour physique de tous les sprites.                   }
{ ---------------------------------------------------------- }
Procedure UpdateSprites;
Var I,FY:Integer;
Begin
 For I:=0 to NumSpr-1 do
  With Sprites[I] do
   If Active Then Begin
    Inc(X, DX);
    If X<0   Then X:=W_W-1;
    If X>=W_W Then X:=0;

    If DY<>0 Then Begin
     Inc(Y, DY);
     If DY<0 Then Begin { saut }
      If Y<22 Then Begin Y:=22; DY:=2; End
              Else
      If StandsOn(X+10,Y)Then DY:=0;
     End Else Begin { chute }
      FY:=FloorBelow(X+10,Y-DY);
      If(FY<999)And(Y>=FY)Then Begin Y:=FY; DY:=0; Anim:=0; End;
     End;
    End Else Begin
     { au sol : tomber si le pied n'est plus sur une plateforme }
     If Not StandsOn(X+10,Y)Then DY:=2;
    End;

    If(I>0)And(DX<>0)And(DY=0)Then Anim:=(Anim+1)And 7;
    If I=0 Then
     If(DX<>0)And(DY=0)Then Anim:=(Anim+1)And 7;

    { Mario "ecrase" un ennemi qui touche la plateforme par-dessous : }
    { non implemente dans cette version simplifiee.                  }

    { Despawn ennemi qui sort par les tuyaux du bas }
    If(I>0)And(Y>170)Then
     If((DX<0)And(X<30))Or((DX>0)And(X>264))Then Begin
      Active:=False;
      Inc(Score, 100);
     End;
   End;
End;

{ ---------------------------------------------------------- }
{ Affichage du HUD : score et niveau.                         }
{ ---------------------------------------------------------- }
Procedure DrawHUD;
Var S:String[10]; I:Integer; V:LongInt;
Begin
 SetFillStyle(SolidFill, Black);
 Bar(0, 410, 320, 440);
 SetColor(Yellow);
 OutTextXY(8, 420, 'NIVEAU :');
 SetColor(White);
 V:=GameLevel; Str(V, S);
 OutTextXY(80, 420, S);
 SetColor(Yellow);
 OutTextXY(120, 420, 'SCORE :');
 V:=Score; Str(V:6, S);
 SetColor(White);
 OutTextXY(190, 420, S);
End;

{ ---------------------------------------------------------- }
{ Boucle principale.                                          }
{ ---------------------------------------------------------- }
Procedure GameLoop;
Var I:Integer; C,C2:Char;
Begin
 { Etat initial }
 For I:=0 to MAX_SPR-1 do Begin
  Sprites[I].Active:=False;
  BgBuf[I]:=NIL;
  BgValid[I]:=False;
 End;
 NumSpr:=1;
 With Sprites[0] do Begin
  Active:=True;
  Kind  :=iMario;
  X:=160; Y:=189; DX:=0; DY:=0; Anim:=0;
 End;

 DrawLevel;
 DrawHUD;

 Repeat
  { Restaurer arriere-plan sous chaque sprite (positions de la frame)}
  For I:=0 to NumSpr-1 do RestoreBg(I);

  { Mise a jour }
  UpdateSprites;
  If(Frame And $1F)=0 Then MakeEnemies;
  Inc(Frame);

  { Sauvegarde + dessin nouveaux sprites }
  For I:=0 to NumSpr-1 do
   If Sprites[I].Active Then Begin
    SaveBg(I);
    DrawSprite(I);
   End;

  { HUD periodique }
  If(Frame And $7F)=0 Then DrawHUD;

  Delay(40);

  { Lecture clavier non bloquante }
  If KeyPressed Then Begin
   C:=ReadKey;
   If C=KbEsc Then Break;
   If C=KbExt Then Begin
    C2:=ReadKey;
    Case C2 Of
     KbLeft : Sprites[0].DX:=-1;
     KbRight: Sprites[0].DX:=1;
     KbDn   : Begin Sprites[0].DX:=0; Sprites[0].Anim:=0; End;
    End;
   End Else Begin
    Case C Of
     KbSpc:
      If Sprites[0].DY=0 Then Begin
       Sprites[0].Anim:=4;
       Sprites[0].DY:=-2;
      End;
     KbCtrlL: Begin
       Inc(GameLevel);
       If GameLevel>5 Then GameLevel:=0;
       For I:=0 to NumSpr-1 do
        If I<>0 Then Sprites[I].Active:=False;
       DrawLevel; DrawHUD;
      End;
    End;
   End;
  End;
 Until False;
End;

Var GD,GM:Integer;

BEGIN
 Randomize;
 BuildPalMap;

 { Nettoyer les octets 255 de toutes les icones (transparent) }
 ZeroFFs(MarioIcon,        SizeOf(MarioIcon));
 ZeroFFs(TurtleIcon,       SizeOf(TurtleIcon));
 ZeroFFs(CrabeIcon,        SizeOf(CrabeIcon));
 ZeroFFs(SauterelleIcon,   SizeOf(SauterelleIcon));
 ZeroFFs(MoneyIcon,        SizeOf(MoneyIcon));
 ZeroFFs(TornadeIcon,      SizeOf(TornadeIcon));
 ZeroFFs(BallIcon,         SizeOf(BallIcon));
 ZeroFFs(NuageIcon,        SizeOf(NuageIcon));
 ZeroFFs(BrickIcon,        SizeOf(BrickIcon));
 ZeroFFs(GlaceIcon,        SizeOf(GlaceIcon));
 ZeroFFs(TuyauxIcon,       SizeOf(TuyauxIcon));
 ZeroFFs(SortieTuyauxIcon, SizeOf(SortieTuyauxIcon));
 ZeroFFs(PowIcon,          SizeOf(PowIcon));
 ZeroFFs(BilleIcon,        SizeOf(BilleIcon));

 GD:=VGA; GM:=VGAHi;
 InitGraph(GD, GM, '');
 If GraphResult<>grOk Then Begin
  WriteLn('Erreur InitGraph: ', GraphErrorMsg(GraphResult));
  Halt(1);
 End;

 GameLevel:=0;
 Frame:=0;
 Score:=0;
 GameLoop;

 CloseGraph;
END.
