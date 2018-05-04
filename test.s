; vim: set syntax=6502:

	.zero

	*= $50

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

#define DSP_START  $9800

; Startup code, wherever that needs to go
	.text
	* = PROG_START
startup
	; DSP_START -> dsp
	lda #< DSP_START
	sta dsp
	lda #> DSP_START
	sta dsp+1

	; clear a line on the screen
	; memset($BBD0, ' ', 40)
	lda #< $BBD0
	sta reg0
	lda #> $BBD0
	sta reg0+1
	lda # " "
	sta reg1
	lda #< 40
	sta reg2
	lda #> 40
	sta reg2+1
	jsr memset

	; write "Hello, world!" to screen
	; memcpy($BBD2, hello_world, 13)
	lda #< $BBD2
	sta reg0
	lda #> $BBD2
	sta reg0+1
	lda #< hello_world
	sta reg1
	lda #> hello_world
	sta reg1+1
	lda #< 13
	sta reg2
	lda #> 13
	sta reg2+1
	jsr memcpy

	; end
	rts

	.text
hello_world
	.asc "Hello, world!"

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
	sec
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char *strcpy(char *dest, const char *src) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
strcpy
.(
	lda reg0
	sta reg2
	lda reg0+1
	sta reg2+1

	ldy #0
	sec
loop
	; transfer character
	lda (reg1),y
	sta (reg0),y
	; stop if nul character
	beq loop_end
	; increment pointers, loop
	inc reg0
	bne skip_inc
	inc reg0+1
skip_inc
	inc reg1
	bne loop
	inc reg1+1
	bcs loop
loop_end

	lda reg2
	sta reg0
	lda reg2+1
	sta reg0+1
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *memcpy(void *dest, const void *src, size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memcpy
.(
	; return immediately if n is zero
	lda reg2
	bne not_zero
	lda reg2+1
	bne not_zero
	rts
not_zero

	; save original dest
	lda reg0
	sta reg3
	lda reg0+1
	sta reg3+1

	sec
	ldy #0
loop
	; transfer
	lda (reg1),y
	sta (reg0),y

	; check --n
	lda reg2
	sbc #1
	sta reg2
	lda reg2+1
	sbc #0
	sta reg2+1
	bne not_zero2
	lda reg2
	beq loop_end
not_zero2

	; increment reg0 and reg1
	inc reg0
	bne not_zero3
	inc reg0+1
not_zero3
	inc reg1
	bne not_zero4
	inc reg1+1
not_zero4

	; loop
	bcs loop
loop_end
	
	; return original dest
	lda reg3
	sta reg0
	lda reg3+1
	sta reg0+1
	rts
.)
