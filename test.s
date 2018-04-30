; vim: set syntax=6502:

	.zero

; reg0-reg3: scratch registers
reg0	.dsb 2
reg1	.dsb 2
reg2	.dsb 2
reg3	.dsb 2

; reg4-reg7: preserved by calls?
reg4	.dsb 2
reg5	.dsb 2
reg6	.dsb 2
reg7	.dsb 2

; 8-bit register reserved for use by pseudo-instructions?
tmp	.dsb 1

; 16-bit Data Stack Pointer
dsp	.dsb 2

; 16-bit Data stack Base Pointer, preserved by calls ?
dbp	.dsb 2

; Calling convention:
; ===================
; Receiving a call, arguments will be in-order given in reg0-reg3, 8-bit
; arguments are packed but 16-bit arguments always fit into an actual register,
; so: reg0 = AA, reg1 = BC, reg2 = D-, reg3 = EE is the correct arrangement for
; arguments: (16-bit A, 8-bit B, 8-bit C, 8-bit D, 16-bit E). This arrangement
; shows the actual byte order in zero-page memory, so reg2 contains D in its
; LSB.
;
; Arguments that won't fit in a register are available on the stack in-order.
; When registers are exhausted by arguments the remaining arguments are
; available on the stack in-order.
;
; Caller is responsible for cleaning stack after a call with stack arguments.
;
; The convention changes if the function has runtime dynamic argument count
; (variadic): the first argument is given as normal, e.g. in a register or on
; stack if larger than 2 bytes, then the rest of arguments are given on the
; stack. Also, the callee is responsible for cleaning the stack.
;
; Return value:
; void          - No convention needed.
; 8-bit/16-bit  - Stored in reg0, MSB is indeterminate on 8-bit return.
; 24-bit/32-bit - Stored in reg0+reg1, MSB of reg1 is indet. on 24-bit return.
; larger        - If non-variadic & stack-passed params are large enough, store
;                 at the end of (top of) stack param space.
;               - If non-variadic & stack-passed params are not large enough,
;                 increase stack-passed area to match size of return value and
;                 store there.
;               - If variadic, callee cleans stack then puts result on stack.

#define PROG_START $200
#define DSP_START  $8000

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

	; transfer16_zp(reg4, reg5)
	lda #reg4
	sta reg0
	lda #reg5
	sta reg0+1
	jsr transfer16_zp

	; memset($30d2, 0, 32)
	lda #< $30d2
	sta reg0
	lda #> $30d2
	sta reg0+1
	lda #0
	sta reg1
	sta reg1+1
	lda #< 32
	sta reg2
	lda #> 32
	sta reg2+1

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void transfer16_zp(Byte r1, Byte r2) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
transfer16_zp
	ldx reg0 ; load source ZP address
	ldy reg0+1 ; load dest ZP address
	lda 0, x
	sta 0, y
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *memset(void *dest, int c, size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
memset
.(
	; store dest
	jsr push_reg0

	; for (; n != 0; --n, ++dest)
	; on first loop:
	; 0 -> y
	; c -> a
	lda reg2
	bne not_zero
	lda reg2+1
	beq loop_end
not_zero
	ldy #0
	lda reg1
loop_start
		; a -> (dest)
		sta (reg0), y

		; --n
		ldx reg2
		bne dec_no_carry
		dec reg2+1
dec_no_carry
		dec reg2

		; loop condition
		bne loop_cont
		ldx reg2+1
		beq loop_end
loop_cont

		; ++dest
		inc reg0
		bne loop_start
		inc reg0+1
		bne loop_start
loop_end
	; return dest
	jsr pull_reg0
	rts
.)
