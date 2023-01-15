.const KOALA_TEMPLATE = "C64FILE, Bitmap=$0000, ScreenRam=$1f40, ColorRam=$2328, BackgroundColor = $2710"
.var picture = LoadBinary("image.kla", KOALA_TEMPLATE)

*=$1c01 "Basic Program"
:BasicUpstart(main)

*=$1300
main:

	//carica picture multicolor .koala

	lda #$78	// set bit map @ $2000
	sta $0A2D	// set video matrix @ 7168 ($1C00)
	
	lda $D8
	ora #%10100000
	sta $D8		// select bit map mode

	lda #0
	sta $d020
	lda #picture.getBackgroundColor()
	sta $d021

	//////////////////////////////

	ldx #$00
loop:
	lda $1400,x
	sta $1c00,x
	
	lda $1500,x
	sta $1d00,x

	lda $1600,x
	sta $1e00,x

	lda $16E8,x
	sta $1eE8,x
	inx              //Increment accumulator until 256 bytes read
	bne loop	

	/////////////////////////////

	lda #$FF
	sta $D8

      lda $01
	and #$FE
	sta $01

	/////////////////////////////

	ldx #0
!loop:
	.for (var i=0; i<4; i++) {
	lda colorRam+i*$100,x
	sta $d800+i*$100,x
}
	inx
	bne !loop-

      jmp *

*=$1800
colorRam: 	
.fill picture.getColorRamSize(), picture.getColorRam(i)
*=$2000		
.fill picture.getBitmapSize(), picture.getBitmap(i)
*=$1400		
.fill picture.getScreenRamSize(), picture.getScreenRam(i)