{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2025
  @website(https://www.gladir.com/7iles)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Program MAHJONG;

Uses {$IFDEF FPC}
      Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Graph
     {$ENDIF};

Const
  TILES = 52;          { Nombre total de tuiles }
  BOARD_WIDTH = 8;     { Largeur du plateau }
  BOARD_HEIGHT = 8;    { Hauteur du plateau }
  BOARD_DEPTH = 3;    { Nombre de niveaux }
  TILE_WIDTH = 40;     { Largeur d'une tuile }
  TILE_HEIGHT = 50;    { Hauteur d'une tuile }
  TILE_DEPTH = 5;     { Profondeur de l'effet 3D }

Type
  TTile = Record
    Value: Integer;    { Valeur de la tuile (1-26) }
    Visible: Boolean;  { Si la tuile est visible }
    Active: Boolean;   { Si la tuile est encore en jeu }
    Z: Integer;       { Niveau de la tuile }
  End;

  TPoint = record
    x, y: Integer;
  end;

Var
  Board: Array[1..BOARD_WIDTH, 1..BOARD_HEIGHT, 1..BOARD_DEPTH] of TTile;
  CursorX, CursorY: Integer;
  GraphDriver, GraphMode: Integer;
  FirstSelect: Boolean;
  FirstX, FirstY, FirstZ: Integer;
  RemainingTiles: Integer;
  QuitGame: Boolean;  { Nouvelle variable }

Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
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

Procedure ShowTileA(X,Y:Word;Inverse:Boolean);
Const
 NumXPixels=40;
 NumYPixels=50;
 BitsPerPixel=4;
 BytesPerLine=20;
 BitmapData:Array[0..999]of Byte=(
  $02,$24,
  $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,
  $44,$42,$20,$00,$00,$25,$67,$99,$99,$99,$99,$99,$99,
  $99,$99,$99,$99,$99,$99,$99,$99,$77,$62,$20,$00,$46,
  $77,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,
  $99,$99,$77,$75,$20,$00,$47,$79,$9B,$BB,$BB,$BB,$BB,
  $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BA,$97,$75,$22,$00,
  $57,$99,$BD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD,
  $DD,$DD,$DC,$A9,$95,$22,$00,$59,$9B,$DF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,
  $00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,
  $22,$00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,
  $95,$22,$00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$C9,$77,
  $AE,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,$DF,
  $FF,$FF,$FF,$F7,$44,$44,$44,$44,$45,$CF,$FF,$FF,$FD,
  $B9,$95,$22,$00,$59,$9B,$DF,$FF,$FF,$F7,$44,$7D,$FF,
  $FF,$FF,$75,$45,$EF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,
  $DF,$FF,$FF,$54,$9F,$A5,$44,$44,$45,$7F,$A4,$4C,$FF,
  $FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,$D4,$4D,$A4,$45,
  $AC,$DC,$A5,$44,$7F,$54,$AF,$FD,$B9,$95,$22,$00,$59,
  $9B,$DF,$FF,$44,$F7,$47,$55,$7F,$FF,$95,$57,$45,$F7,
  $4D,$FD,$B9,$95,$22,$00,$59,$9B,$DF,$F5,$4F,$54,$A1,
  $57,$17,$F9,$16,$61,$94,$5F,$54,$FD,$B9,$95,$22,$00,
  $59,$9B,$DF,$C4,$C7,$4C,$75,$FF,$B1,$B1,$9F,$F6,$5E,
  $45,$F4,$7D,$B9,$95,$22,$00,$59,$9B,$DF,$55,$D4,$AF,
  $75,$FF,$F5,$13,$FF,$F5,$5F,$C4,$C7,$4E,$B9,$95,$22,
  $00,$59,$9B,$DF,$0C,$54,$FF,$E1,$BF,$FF,$1B,$FF,$E1,
  $9F,$F5,$4F,$49,$B9,$95,$22,$00,$59,$9B,$D7,$4F,$4A,
  $FF,$E6,$3F,$FF,$CF,$FF,$63,$EF,$FD,$4D,$55,$B9,$95,
  $22,$00,$59,$9B,$D5,$5C,$4E,$51,$11,$19,$A4,$44,$7B,
  $11,$11,$5E,$47,$74,$B9,$95,$22,$00,$59,$9B,$D5,$59,
  $45,$1B,$EE,$EC,$47,$EA,$4A,$EE,$EB,$53,$57,$A4,$B9,
  $95,$22,$00,$59,$9B,$D4,$77,$41,$9F,$FF,$FA,$49,$15,
  $55,$FF,$FF,$E1,$55,$C4,$C9,$95,$22,$00,$59,$9B,$D4,
  $77,$45,$7E,$FF,$FA,$4B,$39,$47,$EF,$FE,$91,$55,$C4,
  $B9,$95,$22,$00,$59,$9B,$D5,$5A,$4B,$15,$55,$59,$44,
  $74,$4B,$55,$55,$17,$57,$74,$B9,$95,$22,$00,$59,$9B,
  $D5,$5F,$4C,$E7,$53,$1E,$F7,$55,$EF,$11,$56,$BF,$4A,
  $54,$B9,$95,$22,$00,$59,$9B,$DC,$4F,$47,$FF,$F1,$7F,
  $FF,$7F,$FF,$91,$EF,$FA,$4F,$47,$B9,$95,$22,$00,$59,
  $9B,$DF,$49,$A4,$DF,$91,$FF,$F9,$17,$FF,$F5,$7F,$F4,
  $5C,$0C,$B9,$95,$22,$00,$59,$9B,$DF,$74,$F4,$5F,$65,
  $FF,$F1,$51,$EF,$F6,$5E,$74,$F5,$5D,$B9,$95,$22,$00,
  $59,$9B,$DF,$F4,$7D,$47,$91,$BF,$51,$F5,$3F,$E1,$79,
  $4A,$A4,$CD,$B9,$95,$22,$00,$59,$9B,$DF,$FA,$4A,$A4,
  $56,$11,$1B,$FE,$11,$15,$74,$7C,$47,$FD,$B9,$95,$22,
  $00,$59,$9B,$DF,$FF,$74,$AD,$44,$7C,$FF,$FF,$FB,$74,
  $4A,$C4,$5F,$FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,$F7,
  $47,$F7,$44,$45,$55,$44,$47,$FA,$45,$FF,$FD,$B9,$95,
  $22,$00,$59,$9B,$DF,$FF,$FF,$A4,$49,$FC,$77,$57,$7C,
  $FC,$44,$7F,$FF,$FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,
  $FF,$FE,$74,$45,$77,$A9,$75,$44,$5C,$FF,$FF,$FD,$B9,
  $95,$22,$00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$95,$44,$44,
  $45,$7F,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,$DF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,
  $B9,$95,$22,$00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,$9B,
  $DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
  $FD,$B9,$95,$22,$00,$59,$9B,$DF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$59,
  $9A,$CE,$EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE,
  $EE,$EC,$B9,$95,$22,$00,$57,$99,$AC,$CC,$CC,$CC,$CC,
  $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC,$CB,$99,$75,$22,$00,
  $47,$79,$9A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,
  $AA,$AA,$A9,$97,$75,$22,$00,$26,$67,$99,$99,$99,$99,
  $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$77,$76,$62,
  $00,$22,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,
  $66,$66,$66,$66,$65,$57,$96,$00,$02,$22,$22,$22,$22,
  $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$26,$99,
  $99,$60,$00,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,
  $22,$22,$22,$22,$22,$22,$69,$99,$91,$00,$20,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $05,$99,$51,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$11,$00
);
Var
 I,J:Word;
Begin
 If(Inverse)Then Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,Not(BitmapData[BytesPerLine*J+I]shr 4)and$FF);
   PutPixel(X+(I shl 1)+1,Y+J,Not(BitmapData[BytesPerLine*J+I]and $F)and$FF);
  End;
 End
  Else
 Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,BitmapData[BytesPerLine*J+I]shr 4);
   PutPixel(X+(I shl 1)+1,Y+J,BitmapData[BytesPerLine*J+I]and $F);
  End;
 End;
End;

Procedure ShowTileB(X,Y:Word;Inverse:Boolean);
Const
 NumXPixels=40;
 NumYPixels=50;
 BitsPerPixel=4;
 BytesPerLine=20;
 BitmapData:Array[0..999]of Byte=(
  $22,$24,$44,$44,$44,$44,$44,$44,
  $44,$44,$44,$44,$44,$44,$44,$44,$42,$20,$00,$10,$25,
  $67,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,
  $99,$99,$77,$62,$20,$02,$46,$77,$99,$99,$99,$99,$99,
  $99,$99,$99,$99,$99,$99,$99,$99,$99,$77,$75,$20,$02,
  $47,$79,$9B,$BB,$BB,$BB,$BB,$BB,$A7,$79,$BB,$BB,$BB,
  $BB,$BB,$BA,$97,$75,$22,$01,$47,$99,$BD,$DD,$DD,$DD,
  $DC,$54,$45,$55,$44,$7D,$DD,$DD,$DD,$DC,$A9,$95,$22,
  $00,$49,$9B,$DF,$FF,$FF,$FF,$74,$9C,$75,$55,$9F,$54,
  $AF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,
  $F5,$5C,$54,$79,$A7,$54,$7C,$49,$FF,$FF,$FD,$B9,$95,
  $22,$00,$49,$9B,$DF,$FF,$FF,$55,$A4,$74,$4C,$F7,$45,
  $54,$D4,$AF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,
  $FA,$4A,$4C,$4D,$A4,$A4,$D9,$47,$5C,$4F,$FF,$FD,$B9,
  $95,$22,$00,$49,$9B,$DF,$FF,$F4,$A4,$AC,$4F,$F5,$4C,
  $FC,$4F,$57,$57,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,
  $FF,$D4,$75,$FF,$4A,$FF,$7F,$F5,$7F,$D4,$C4,$FF,$FD,
  $B9,$95,$22,$00,$49,$9B,$DF,$FF,$75,$57,$75,$44,$D5,
  $47,$A0,$55,$A4,$C4,$FF,$FD,$B9,$95,$22,$00,$49,$9B,
  $DF,$FF,$57,$45,$5E,$FF,$57,$94,$AF,$FC,$45,$74,$CF,
  $FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$57,$45,$AF,$FF,
  $47,$47,$7F,$FF,$55,$74,$CF,$FD,$B9,$95,$22,$00,$49,
  $9B,$DF,$FF,$77,$47,$45,$57,$55,$74,$95,$55,$45,$94,
  $CF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$95,$57,$C7,
  $55,$F7,$5C,$D4,$77,$D4,$D4,$FF,$FD,$B9,$95,$22,$00,
  $49,$9B,$DF,$FF,$D4,$C4,$FF,$4D,$FC,$5F,$F7,$7F,$A4,
  $A5,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$F5,$75,
  $7A,$5F,$F4,$47,$FD,$4F,$4A,$4A,$FF,$FD,$B9,$95,$22,
  $00,$49,$9B,$DF,$FF,$FC,$4C,$49,$47,$55,$C4,$95,$55,
  $77,$4F,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,
  $74,$C4,$55,$5F,$FA,$55,$47,$A4,$DF,$FF,$FD,$B9,$95,
  $22,$00,$49,$9B,$DF,$FF,$FF,$F7,$4C,$74,$45,$55,$44,
  $A7,$4C,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,
  $FF,$FF,$A4,$5A,$CA,$7A,$C7,$45,$DF,$FF,$FF,$FD,$B9,
  $95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$75,$44,$44,
  $45,$CF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,
  $B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FC,$77,
  $57,$9F,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,
  $DF,$FF,$FF,$FF,$F9,$44,$57,$77,$54,$5C,$FF,$FF,$FF,
  $FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$55,$CA,
  $55,$45,$5C,$94,$7F,$FF,$FF,$FD,$B9,$95,$22,$00,$49,
  $9B,$DF,$FF,$FF,$F4,$7A,$45,$AC,$DC,$74,$5D,$47,$FF,
  $FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$57,$74,
  $54,$4A,$F5,$44,$74,$C4,$7F,$FF,$FD,$B9,$95,$22,$00,
  $49,$9B,$DF,$FF,$F7,$59,$4C,$4F,$C4,$74,$FC,$4A,$4D,
  $4E,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$F4,$C4,
  $DD,$4F,$F7,$4D,$FC,$4F,$75,$77,$FF,$FD,$B9,$95,$22,
  $00,$49,$9B,$DF,$FF,$C4,$75,$FF,$59,$FF,$9F,$F4,$AF,
  $F4,$C4,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$75,
  $59,$54,$44,$C4,$45,$A4,$44,$75,$C4,$EF,$FD,$B9,$95,
  $22,$00,$49,$9B,$DF,$FF,$57,$45,$7F,$FF,$47,$55,$7F,
  $FD,$45,$74,$CF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,
  $57,$45,$9F,$FF,$47,$47,$7F,$FF,$55,$74,$CF,$FD,$B9,
  $95,$22,$00,$49,$9B,$DF,$FF,$77,$49,$45,$55,$74,$54,
  $95,$54,$45,$A4,$DF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,
  $FF,$A5,$77,$FA,$57,$FC,$7D,$F4,$9C,$F4,$D4,$FF,$FD,
  $B9,$95,$22,$00,$49,$9B,$DF,$FF,$E4,$C4,$FF,$4E,$FA,
  $4F,$F7,$5F,$A4,$75,$FF,$FD,$B9,$95,$22,$00,$49,$9B,
  $DF,$FF,$F5,$75,$5A,$5F,$F4,$57,$FD,$4D,$4C,$4C,$FF,
  $FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$4C,$57,$45,
  $47,$E4,$74,$74,$75,$5F,$FF,$FD,$B9,$95,$22,$00,$49,
  $9B,$DF,$FF,$FF,$A4,$C5,$47,$9F,$FD,$75,$47,$74,$FF,
  $FF,$FD,$B9,$95,$22,$00,$49,$9A,$CE,$EE,$EE,$EA,$47,
  $A4,$44,$44,$45,$C5,$4D,$EE,$EE,$EC,$B9,$95,$22,$00,
  $47,$99,$AC,$CC,$CC,$CC,$A5,$45,$CC,$AC,$95,$47,$CC,
  $CC,$CC,$CB,$99,$75,$22,$00,$47,$79,$9A,$AA,$AA,$AA,
  $AA,$95,$44,$44,$47,$AA,$AA,$AA,$AA,$A9,$97,$75,$22,
  $00,$26,$67,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,
  $99,$99,$99,$99,$77,$76,$62,$00,$22,$66,$66,$66,$66,
  $66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,$65,$57,
  $96,$00,$02,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,
  $22,$22,$22,$22,$22,$26,$99,$99,$60,$02,$22,$22,$22,
  $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,
  $69,$99,$91,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$05,$99,$50,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$11,$00
);
Var
 I,J:Word;
Begin
 If(Inverse)Then Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,Not(BitmapData[BytesPerLine*J+I]shr 4)and$FF);
   PutPixel(X+(I shl 1)+1,Y+J,Not(BitmapData[BytesPerLine*J+I]and $F)and$FF);
  End;
 End
  Else
 Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,BitmapData[BytesPerLine*J+I]shr 4);
   PutPixel(X+(I shl 1)+1,Y+J,BitmapData[BytesPerLine*J+I]and $F);
  End;
 End;
End;

Procedure ShowTileC(X,Y:Word;Inverse:Boolean);
Const
 NumXPixels=40;
 NumYPixels=50;
 BitsPerPixel=4;
 BytesPerLine=20;
 BitmapData:Array[0..999]of Byte=(
  $22,
  $24,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$44,
  $44,$44,$42,$20,$00,$02,$25,$67,$99,$99,$99,$99,$99,
  $99,$99,$99,$99,$99,$99,$99,$99,$99,$77,$62,$20,$00,
  $47,$77,$99,$99,$75,$55,$59,$99,$99,$99,$99,$99,$99,
  $99,$99,$99,$77,$75,$20,$02,$47,$79,$9B,$A5,$57,$77,
  $75,$5B,$BB,$BB,$BB,$BB,$BB,$BB,$BB,$BA,$97,$75,$22,
  $02,$47,$99,$BA,$57,$55,$A9,$55,$75,$DD,$DD,$DD,$DD,
  $DD,$DD,$DD,$DC,$A9,$95,$22,$00,$49,$9B,$D5,$75,$55,
  $75,$55,$57,$5F,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,
  $22,$00,$49,$9B,$77,$5C,$7F,$57,$F5,$D5,$5F,$FF,$FF,
  $FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9A,$57,$A7,
  $4C,$79,$75,$75,$77,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,
  $95,$22,$00,$49,$9B,$57,$4A,$A5,$55,$9A,$74,$75,$FF,
  $FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$57,
  $59,$A5,$74,$9A,$74,$75,$FF,$FF,$FF,$FF,$FF,$FF,$FD,
  $B9,$95,$22,$00,$49,$9A,$57,$A7,$4D,$57,$75,$75,$77,
  $FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,
  $77,$5C,$7F,$57,$F5,$D5,$5F,$FF,$FF,$FF,$FF,$FF,$FF,
  $FD,$B9,$95,$22,$00,$49,$9B,$D5,$75,$55,$75,$55,$57,
  $5F,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,
  $9B,$DC,$57,$57,$A9,$55,$75,$FF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$C5,$57,$77,$75,
  $7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,
  $49,$9B,$DF,$FF,$C7,$55,$7D,$FF,$FF,$FF,$FF,$FF,$FF,
  $FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,
  $00,$49,$9B,$DF,$FF,$FF,$FF,$F9,$77,$77,$77,$FF,$FF,
  $FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,
  $FF,$79,$97,$77,$79,$8B,$FF,$FF,$FF,$FF,$FD,$B9,$95,
  $22,$00,$49,$9B,$DF,$FF,$FF,$F7,$98,$87,$F9,$78,$98,
  $EF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,
  $FF,$99,$89,$9B,$87,$F8,$79,$7F,$FF,$FF,$FF,$FD,$B9,
  $95,$22,$00,$49,$9B,$DF,$FF,$FF,$79,$BE,$7F,$9F,$B9,
  $F8,$7E,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,
  $FF,$FF,$77,$77,$89,$77,$97,$88,$99,$FF,$FF,$FF,$FD,
  $B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$77,$8F,$F7,$86,
  $EE,$B8,$99,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,
  $DF,$FF,$FF,$77,$97,$89,$78,$97,$88,$99,$FF,$FF,$FF,
  $FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$79,$BE,$7F,
  $9F,$B9,$F8,$7E,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,$49,
  $9B,$DF,$FF,$FF,$99,$89,$9B,$87,$F8,$79,$7F,$FF,$FF,
  $FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$F7,$98,
  $87,$F9,$88,$98,$EF,$FF,$FF,$FF,$FD,$B9,$95,$22,$00,
  $49,$9B,$DF,$FF,$FF,$FF,$79,$97,$88,$79,$8B,$FF,$FF,
  $FF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,
  $F9,$77,$77,$77,$EF,$FF,$FF,$FF,$FF,$FD,$B9,$95,$22,
  $00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,
  $CA,$DF,$FF,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FA,$55,$55,$55,$7F,$FD,$B9,$95,
  $22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$75,
  $75,$55,$55,$75,$FD,$B9,$95,$22,$00,$49,$9B,$DF,$FF,
  $FF,$FF,$FF,$FF,$FF,$FA,$55,$55,$7C,$55,$57,$5D,$B9,
  $95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$F5,
  $77,$5F,$74,$D7,$95,$79,$B9,$95,$22,$00,$49,$9B,$DF,
  $FF,$FF,$FF,$FF,$FF,$FF,$A7,$5F,$7A,$F9,$F5,$F9,$75,
  $B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,
  $79,$55,$57,$55,$75,$55,$55,$B9,$95,$22,$00,$49,$9B,
  $DF,$FF,$FF,$FF,$FF,$FF,$FF,$79,$4A,$FA,$55,$5F,$F5,
  $55,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,$FF,
  $FF,$77,$55,$55,$55,$A4,$57,$55,$B9,$95,$22,$00,$49,
  $9B,$DF,$FF,$FF,$FF,$FF,$FF,$FF,$C5,$5F,$5D,$C5,$F5,
  $C7,$75,$B9,$95,$22,$00,$49,$9B,$DF,$FF,$FF,$FF,$FF,
  $FF,$FF,$F5,$75,$5D,$55,$A5,$75,$5C,$B9,$95,$22,$00,
  $49,$9A,$CE,$EE,$EE,$EE,$EE,$EE,$EE,$ED,$57,$45,$AE,
  $54,$57,$7C,$B9,$95,$22,$00,$47,$99,$AC,$CC,$CC,$CC,
  $CC,$CC,$CC,$CC,$A5,$75,$55,$57,$57,$CB,$99,$75,$22,
  $00,$47,$79,$9A,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$55,
  $55,$55,$9A,$A9,$97,$75,$22,$00,$26,$67,$99,$99,$99,
  $99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$99,$77,$76,
  $62,$00,$02,$66,$66,$66,$66,$66,$66,$66,$66,$66,$66,
  $66,$66,$66,$66,$66,$65,$57,$96,$00,$02,$22,$22,$22,
  $22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$22,$26,
  $99,$99,$60,$02,$22,$22,$22,$22,$22,$22,$22,$22,$22,
  $22,$22,$22,$22,$22,$22,$22,$69,$99,$91,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$05,$99,$50,$00,$00,$00,$00,$00,$00,$00,$00,$00,
  $00,$00,$00,$00,$00,$00,$00,$00,$00,$11,$10
);
Var
 I,J:Word;
Begin
 If(Inverse)Then Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,Not(BitmapData[BytesPerLine*J+I]shr 4)and$FF);
   PutPixel(X+(I shl 1)+1,Y+J,Not(BitmapData[BytesPerLine*J+I]and $F)and$FF);
  End;
 End
  Else
 Begin
  For J:=0 to 49 do For I:=0 to 19 do Begin
   PutPixel(X+(I shl 1),Y+J,BitmapData[BytesPerLine*J+I]shr 4);
   PutPixel(X+(I shl 1)+1,Y+J,BitmapData[BytesPerLine*J+I]and $F);
  End;
 End;
End;

Procedure InitializeBoard;
Var
 i,j,k,z,v:Integer;
Begin
 Randomize;
 RemainingTiles:=TILES;

  { Initialiser toutes les tuiles comme inactives }
 For i:=1 To BOARD_WIDTH Do
  For j:=1 To BOARD_HEIGHT Do
    For z:=1 To BOARD_DEPTH Do
     Board[i,j,z].Active:=False;

  { Placer les tuiles alÃ©atoirement sur diffÃ©rents niveaux }
 k := 0;
 While k<TILES do Begin
  i := Random(BOARD_WIDTH) + 1;
  j := Random(BOARD_HEIGHT) + 1;
  z := Random(BOARD_DEPTH) + 1;
  If Not Board[i,j,z].Active Then Begin
   Board[i,j,z].Active := True;
   Board[i,j,z].Visible := True;
   Board[i,j,z].Value := (k Div 2) + 1;
   Board[i,j,z].Z := z;
   Inc(k);
  End;
 End;
End;

Function IsTileBlocked(x, y, z: Integer): Boolean;
Var
  i: Integer;
Begin
  IsTileBlocked := False;
  { VÃ©rifie si une tuile active existe au-dessus }
  For i := z + 1 To BOARD_DEPTH Do
    If Board[x,y,i].Active Then
    Begin
      IsTileBlocked := True;
      Exit;
    End;
End;

Function GetVisibleTileLevel(x,y:Integer):Integer;
Var
 z:Integer;
Begin
 GetVisibleTileLevel:=0;
 For z:=BOARD_DEPTH downto 1 do If Board[x,y,z].Active Then Begin
  GetVisibleTileLevel := z;
  Exit;
 End;
End;

Function Point(x,y:Integer):TPoint;Begin
 Point.x:=x;
 Point.y:=y;
End;

Procedure DrawTile(x, y, z: Integer; highlighted: Boolean);
Var
 baseX,baseY:Integer;
 points:Array[0..3] of TPoint;
Begin
 If Board[x,y,z].Active Then Begin
  baseX := (x-1) * TILE_WIDTH + 10 + (z * 5);
  baseY := (y-1) * TILE_HEIGHT + 10 - (z * 5);
   { Remplir le fond de la tuile }
  SetFillStyle(SolidFill, LightGray);
  Bar(baseX, baseY, baseX + TILE_WIDTH, baseY + TILE_HEIGHT);
  If highlighted Then SetColor(Yellow)
                 Else SetColor(White);
    { Face avant }
  Rectangle(
   baseX,
   baseY,
   baseX + TILE_WIDTH,
   baseY + TILE_HEIGHT
  );

    { Face sup‚rieure 3D avec remplissage }
  points[0] := Point(baseX, baseY);
  points[1] := Point(baseX + TILE_DEPTH, baseY - TILE_DEPTH);
  points[2] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY - TILE_DEPTH);
  points[3] := Point(baseX + TILE_WIDTH, baseY);
  SetFillStyle(SolidFill, LightGray);
  FillPoly(4, points);

    { Face lat‚rale 3D avec remplissage }
  points[0] := Point(baseX + TILE_WIDTH, baseY);
  points[1] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY - TILE_DEPTH);
  points[2] := Point(baseX + TILE_WIDTH + TILE_DEPTH, baseY + TILE_HEIGHT - TILE_DEPTH);
  points[3] := Point(baseX + TILE_WIDTH, baseY + TILE_HEIGHT);
  If Board[x,y,z].Visible Then Begin
   Case Board[x,y,z].Value of
    1:ShowTileA(baseX+(TILE_WIDTH div 4),baseY+(TILE_HEIGHT div 3),highlighted);
    2:ShowTileB(baseX+(TILE_WIDTH div 4),baseY+(TILE_HEIGHT div 3),highlighted);
    3:ShowTileC(baseX+(TILE_WIDTH div 4),baseY+(TILE_HEIGHT div 3),highlighted);
    Else Begin
     SetFillStyle(SolidFill, DarkGray);
     FillPoly(4, points);
     SetTextStyle(DefaultFont, HorizDir, 2);  { Taille de police augmentÃ©e }
     SetColor(Blue);
     OutTextXY(
      baseX + (TILE_WIDTH div 4),
      baseY + (TILE_HEIGHT div 3),    { AjustÃ© pour centrer dans la tuile plus haute }
      Chr(Board[x,y,z].Value + 64)
     );
    End;
   End;
  End;
 End;
End;

Procedure DrawBoard;
Var
  i, j, z: Integer;
Begin
  ClearDevice;
  For z := 1 To BOARD_DEPTH Do
    For i := 1 To BOARD_WIDTH Do
      For j := 1 To BOARD_HEIGHT Do
        If Board[i,j,z].Active Then
          DrawTile(i, j, z, (i = CursorX) And (j = CursorY));
End;

Procedure MoveCursor(Var x, y: Integer);
Var
  ch: Char;
  visibleZ: Integer;
Begin
  ch := ReadKey;
  Case ch Of
    #27: QuitGame := True;  { ESC key }
    #0: Case ReadKey Of
      #72: If y > 1 Then Dec(y);           { Up }
      #80: If y < BOARD_HEIGHT Then Inc(y); { Down }
      #75: If x > 1 Then Dec(x);           { Left }
      #77: If x < BOARD_WIDTH Then Inc(x);  { Right }
    End;
    #13: Begin { Enter }
      visibleZ := GetVisibleTileLevel(x, y);
      If (visibleZ > 0) And Not IsTileBlocked(x, y, visibleZ) Then
      Begin
        If Not FirstSelect Then
        Begin
          FirstX := x;
          FirstY := y;
          FirstZ := visibleZ;
          FirstSelect := True;
        End
        Else Begin
          If (Board[FirstX,FirstY,FirstZ].Value = Board[x,y,visibleZ].Value) And
             ((FirstX <> x) Or (FirstY <> y)) And
             Not IsTileBlocked(x, y, visibleZ) Then
          Begin
            Board[FirstX,FirstY,FirstZ].Active := False;
            Board[x,y,visibleZ].Active := False;
            Dec(RemainingTiles, 2);
          End;
          FirstSelect := False;
        End;
      End;
    End;
  End;
End;

BEGIN
 InitializeGraphics;
 InitializeBoard;
 CursorX := 1;
 CursorY := 1;
 FirstSelect := False;
 QuitGame := False;  { Initialisation }
 Repeat
  DrawBoard;
  MoveCursor(CursorX, CursorY);
 Until (RemainingTiles = 0) Or QuitGame;
 CloseGraph;
 If RemainingTiles=0 Then WriteLn('F‚licitations! Vous avez gagn‚!')
                     Else WriteLn('Jeu termin‚!');
END.
