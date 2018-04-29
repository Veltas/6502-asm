; vim: set syntax=6502:

	.zero

; 8 16-bit pseudo-registers
reg0:
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

#define PROG_START $200
#define DSP_START  $FF00

; Startup code, wherever that needs to go
	.text
	* = PROG_START
startup
	; DSP_START -> dsp
	ldx #0
	lda #< DSP_START
	sta dsp, x
	lda #> DSP_START
	inx
	sta dsp, x

	; transfer16_zp(reg0, reg1)
	lda #< reg0
	jsr push_a
	lda #< reg1
	jsr push_a
	jsr transfer16_zero
	jsr inc2_dsp

	; don't exit
	jmp *

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
	clc
	lda dsp
	adc #2
	sta dsp
	lda dsp+1
	adc #0
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

; decrement data stack pointer
	.text
dec_dsp
.(
	lda dsp
	beq carry
		dec dsp
		rts
carry
		dec dsp
		dec dsp+1
		rts
.)

; decrement data stack pointer by two
	.text
dec2_dsp
	clc
	lda dsp
	sbc #2
	sta dsp
	lda dsp+1
	sbc #0
	sta dsp+1
	rts

; increment data stack pointer
	.text
inc_dsp
.(
	inc dsp
	beq carry
		rts
carry
		inc dsp+1
		rts
.)

; increment data stack pointer by two
	.text
inc2_dsp
	clc
	lda dsp
	adc #2
	sta dsp
	lda dsp+1
	adc #0
	sta dsp+1
	rts

; transfers 16-bit contents of zero page $1 to zero page $2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void transfer16_zp(Byte r1, Byte r2) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
transfer16_zp
	ldy #0
	lda (dsp), y ; load source ZP address
	tax
	iny
	lda (dsp), y ; load dest ZP address
	tay
	lda #0, x
	sta #0, y
	rts
