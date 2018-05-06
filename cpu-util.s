; vim: set syntax=6502:

; pushes A onto data stack
	.text
push_a
.(
	; store a
	pha
	; dsp-1 -> dsp
	lda dsp
	beq carry
		dec dsp+1
carry
	dec dsp
	; retrieve a
	pla
	; a -> (dsp)
	ldy #0
	sta (dsp), y
	rts
.)

; pulls A from data stack
	.text
pull_a
.(
	ldx #0
	lda (dsp,x)
	inc dsp
	beq carry
		rts
carry
		inc dsp+1
		rts
.)

; pushes reg0 to data stack
	.text
push_reg0
	; dsp-2 -> dsp
	sec
	lda dsp
	sbc #2
	sta dsp
	lda dsp+1
	sbc #0
	sta dsp+1
	; reg0 -> (dsp)
	ldy #0
	lda reg0
	sta (dsp),y
	lda reg0+1
	iny
	sta (dsp),y
	rts

; pulls reg0 from data stack
	.text
pull_reg0
	; (dsp) -> reg0
	ldy #0
	lda (dsp),y
	sta reg0
	iny
	lda (dsp),y
	sta reg0+1
	; dsp+2 -> dsp
	clc
	lda dsp
	adc #2
	sta dsp
	lda dsp+1
	adc #0
	sta dsp+1
	rts
