; vim: set syntax=6502:

#include "atmos/graphics.inc"

.( ; main module

;;;;;;;;;;;;;;;;;;
; int main(void) ;
;;;;;;;;;;;;;;;;;;
	.text
+main
.(
	; Reserve stack
	; 0 word: row address
	sec
	lda dsp
	sbc #2
	sta dsp
	lda dsp+1
	sbc #0
	sta dsp+1

	; Clear the screen with set-black-paper
	lda #16
	sta reg0
	jsr TxClear

	; Randomly choose squares
loop
	; Choose row
	jsr Random
	lda reg0
	and #$1F
	cmp #28
	bcc not_less
	and #$0F
not_less
	sta reg0
	jsr TxGetRow
	lda reg0
	ldy #0
	sta (dsp),y
	lda reg0+1
	iny
	sta (dsp),y

	; Choose column
	jsr Random
	lda reg0
	and #$3F
	cmp #40
	bcc not_less2
	and #$1F
not_less2
	ldy #0
	clc
	adc (dsp),y
	sta (dsp),y
	iny
	lda (dsp),y
	adc #0
	sta (dsp),y

	; Choose color
	jsr Random
	lda reg0
	and #7
	ora #$10
	sta reg1
	ldy #0
	lda (dsp),y
	sta reg0
	iny
	lda (dsp),y
	sta reg0+1
	lda reg1
	ldy #0
	sta (reg0),y

	; continue loop
	jmp loop

	; Restore stack and return
	clc
	lda dsp
	adc #2
	sta dsp
	lda dsp+1
	adc #0
	sta dsp+1
	rts
.)

.) ; main module
