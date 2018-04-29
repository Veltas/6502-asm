; vim: set syntax=6502:

	.zero

	; 8 16-bit pseudo-registers
reg0
	.dsb 2
reg1
	.dsb 2
reg2
	.dsb 2
reg3
	.dsb 2
reg4
	.dsb 2
reg5
	.dsb 2
reg6
	.dsb 2
reg7
	.dsb 2

	; 8-bit register reserved for use by pseudo-instructions
tmp
	.dsb 1

	; 16-bit Data Stack Pointer
dsp
	.dsb 2

	; 16-bit Data stack Base Pointer
dbp
	.dsb 2

	.text
	* = 512
startup
	; transfer reg0 to reg1
	lda #<reg0: jsr push_a
	lda #<reg1: jsr push_a
	jsr transfer16_zero
	jsr inc2_dsp

; pushes A onto data stack
	.text
push_a
	.(
	pha
	lda #$FF
	dec dsp
	cmp dsp
	bne no_carry
		dec dsp+1
no_carry
	ldx #0
	pla
	sta (dsp,x)
	rts
	.)

; pulls A from data stack
	.text
pull_a
	.(
	ldx #0
	lda (dsp,x)
	inc dsp
	bne no_carry
		inc dsp+1
no_carry
	rts
	.)

; pushes reg0 to data stack
	.text
push_reg0
	.(
	lda #$FF
	dec dsp
	cmp dsp
	bne no_carry1
		dec dsp+1
		dec dsp
		bne no_carry2
no_carry1
		dec dsp
		cmp dsp
		bne no_carry2
			dec dsp+1
no_carry2
	ldy #0
	lda reg0
	sta (dsp),y
	lda reg0+1
	iny
	sta (dsp),y
	rts
	.)

; pulls reg0 from data stack
	.text
pull_reg0
	.(
	ldy #0
	lda (dsp),y
	sta reg0
	iny
	lda (dsp),y
	sta reg0+1
	inc dsp
	bne no_carry1
		inc dsp+1
		inc dsp
		rts
no_carry1
		inc dsp
		bne no_carry2
			inc dsp+1
no_carry2
	rts
	.)

; decrement data stack pointer
	.text
dec_dsp
	.(
	dec dsp
	lda #$FF
	cmp dsp
	bne no_carry
		dec dsp+1
no_carry
	rts
	.)

; decrement data stack pointer by two
	.text
dec2_dsp
	.(
	dec dsp
	lda #$FF
	cmp dsp
	bne no_carry
		dec dsp+1
		dec dsp
		rts
no_carry1
		dec dsp
		cmp dsp
		bne no_carry
			dec dsp+1
no_carry2
	rts
	.)

; increment data stack pointer
	.text
inc_dsp
	.(
	inc dsp
	bne no_carry
		inc dsp+1
no_carry
	rts
	.)

; increment data stack pointer by two
	.text
inc2_dsp
	.(
	inc dsp
	bne no_carry1
		inc dsp+1
		inc dsp
		rts
no_carry1
		inc dsp
		bne no_carry2
			inc dsp+1
no_carry2
	rts
	.)

; transfers 16-bit contents of zero page $1 to zero page $2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void transfer16_zero(Byte r1, Byte r2) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
transfer16_zero
	ldx #0
	ldy dsp,x   ; load source address
	lda $0, y   ; load first byte
	inx
	sta (dsp,x) ; store first result value
	lda $0+1, y ; load second byte
	ldy dsp,x   ; load dest address
	sta $0+1,y  ; store second result value
	rts
