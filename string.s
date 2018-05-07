; vim: set syntax=6502:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *memset(void *dest, int c, size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
memset
.(
	lda reg0
	sta reg3
	lda reg0+1
	sta reg3+1

	sec
	ldy #0
	; for (; n != 0; --n, ++dest)
	lda reg2
	ora reg2+1
	beq loop_end
loop
	; a -> (dest)
	lda reg1
	sta (reg3), y

	; --n
	ldx reg2
	bne dec_no_carry
	dec reg2+1
dec_no_carry
	dec reg2

	; loop condition
	lda reg2
	ora reg2+1
	beq loop_end

	; ++dest
	inc reg3
	bne loop
	inc reg3+1
	bcs loop
loop_end
	; return dest
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
	sta (reg2),y
	; stop if nul character
	beq loop_end
	; increment pointers, loop
	inc reg2
	bne skip_inc
	inc reg2+1
skip_inc
	inc reg1
	bne loop
	inc reg1+1
	bcs loop
loop_end

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
