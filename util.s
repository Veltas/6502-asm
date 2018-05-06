; vim: set syntax=6502:

#define HASH_START 5381

; Based on DJB2, Dan Bernstein's hashing algorithm, taken from
; http://www.cse.yorku.ca/~oz/hash.html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned HashString(const char *str) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.(
	.text
+HashString
	; reg0 is $str, reg1 is hash, reg2 stores input character
	lda #< HASH_START
	sta reg1
	lda #> HASH_START
	sta reg1+1

	ldy #0
	lda (reg0),y
	beq loop_end
loop
	inc reg0
	bne no_carry
	inc reg0+1
no_carry

	sta reg2

	lda reg1
	sta reg3
	lda reg1+1
	sta reg3+1

	ldx #5
shift_loop
	lda reg3
	asl
	sta reg3
	lda reg3+1
	rol
	sta reg3+1
	dex
	bne shift_loop

	clc
	lda reg3
	adc reg1
	sta reg1
	lda reg3+1
	adc reg1+1
	sta reg1+1

	lda reg1
	eor reg2
	sta reg1

	lda (reg0),y
	bne loop
loop_end

	lda reg1
	sta reg0
	lda reg1+1
	sta reg0+1
	rts
.)
