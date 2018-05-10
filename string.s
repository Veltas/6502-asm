; vim: set syntax=6502:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *memset(void *dest, int c, size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+memset
.(
	lda reg0
	sta reg3
	lda reg0+1
	sta reg3+1

	; skip if MSB(n) == 0
	lda reg2+1
	beq fast_loop_end
	ldy #0
	lda reg1
fast_loop
	ldx #32
inner_loop
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	sta (reg3), y
	iny
	dex
	bne inner_loop

	inc reg3+1
	dec reg2+1
	bne fast_loop
fast_loop_end

	; skip if n == 0
	ldy reg2
	beq loop_end
	dey
	beq loop_last
	sec
	lda reg1
loop
	sta (reg3), y
	dey
	bne loop
loop_last
	sta (reg3), y
loop_end
	; return dest
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char *strcpy(char *dest, const char *src) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+strcpy
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
	.text
+memcpy
.(
	; return immediately if n is zero
	lda reg2
	ora reg2+1
	bne not_zero
	rts
not_zero

	lda reg0
	sta reg3
	lda reg0+1
	sta reg3+1

	sec
	ldy #0
loop
	; transfer
	lda (reg1),y
	sta (reg3),y

	; check --n
	lda reg2
	bne no_carry
	dec reg2+1
no_carry
	dec reg2
	lda reg2
	ora reg2+1
	beq loop_end

	; increment reg3 and reg1
	inc reg3
	bne not_zero3
	inc reg3+1
not_zero3
	inc reg1
	bne not_zero4
	inc reg1+1
not_zero4

	; loop
	bcs loop
loop_end
	
	; return original dest
	rts
.)
