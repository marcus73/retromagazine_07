.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor = $2710"
.var picture = LoadBinary("image.kla", KOALA_TEMPLATE)

*=$0801 "Basic Program"

:BasicUpstart(main)

*=$080D
main:

	//carica picture multicolor .koala
	lda #$38 	//% 0011 1000 			bitmap memory by $2000 (8192), screen ram by $0c00 (3072)
	sta $d018

	lda #$d8
	sta $d016	//multicolor mode on

	lda #$3b	
	sta $d011	//bitmap mode on

	lda #0
	sta $d020
	lda #picture.getBackgroundColor()
	sta $d021

	ldx #0
!loop:
	.for (var i=0; i<4; i++) {
	lda colorRam+i*$100,x
	sta $d800+i*$100,x
}
	inx
	bne !loop-

        jmp *

*=$1c00
colorRam: 	
.fill picture.getColorRamSize(), picture.getColorRam(i)
*=$2000		
.fill picture.getBitmapSize(), picture.getBitmap(i)
*=$0c00		
.fill picture.getScreenRamSize(), picture.getScreenRam(i)