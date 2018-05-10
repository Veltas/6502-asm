; vim: set syntax=6502:

; These Oric Atmos graphics functions are prefixed with Tx and Hr for TEXT mode
; and HIRES mode.

#include "atmos/graphics.inc"

.( ; graphics module

; Clear the TEXT mode screen with the given value
;;;;;;;;;;;;;;;;;;;;;;;;;;
; void TxClear(Byte val) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+TxClear
.(
	lda reg0
	sta reg1
	lda #0
	sta reg1+1
	lda #< TX_SCREEN
	sta reg0
	lda #> TX_SCREEN
	sta reg0+1
	lda #< TX_SCREEN_SIZE
	sta reg2
	lda #> TX_SCREEN_SIZE
	sta reg2+1
	jsr memset
	rts
.)

; Gets the address of the text row
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Byte *TxGetRow(Byte row) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+TxGetRow
.(
	lda reg0
	asl
	tax
	lda rowLookup,x
	sta reg0
	lda rowLookup+1,x
	sta reg0+1
	rts

	.text
rowLookup
	.word $BB80+ 0*40
	.word $BB80+ 1*40
	.word $BB80+ 2*40
	.word $BB80+ 3*40
	.word $BB80+ 4*40
	.word $BB80+ 5*40
	.word $BB80+ 6*40
	.word $BB80+ 7*40
	.word $BB80+ 8*40
	.word $BB80+ 9*40
	.word $BB80+10*40
	.word $BB80+11*40
	.word $BB80+12*40
	.word $BB80+13*40
	.word $BB80+14*40
	.word $BB80+15*40
	.word $BB80+16*40
	.word $BB80+17*40
	.word $BB80+18*40
	.word $BB80+19*40
	.word $BB80+20*40
	.word $BB80+21*40
	.word $BB80+22*40
	.word $BB80+23*40
	.word $BB80+24*40
	.word $BB80+25*40
	.word $BB80+26*40
	.word $BB80+27*40
.)

.) ; graphics module
