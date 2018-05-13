; vim: set syntax=6502:

#include "atmos/addrs.inc"

.( ; alloc module

; freesStart/freesEnd forms the sentinel link for the circular list of free blocks
	.text ; FIXME
freesStart
	.word HEAP_START
freesEnd
	.word HEAP_START

; Keeps track of amount of free space
	.text ; FIXME
freeSpace
	.word HEAP_SIZE

;;;;;;;;;;;;;;;;;;;;;;;;
; void InitAlloc(void) ;
;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+InitAlloc
.(
	lda #<HEAP_START
	sta reg0
	lda #>HEAP_START
	sta reg0+1
	lda #<HEAP_SIZE
	sta reg1
	lda #>HEAP_SIZE
	sta reg1+1
	lda #0
	sta reg2
	jsr SetBorder

	lda #<HEAP_START
	sta reg0
	lda #>HEAP_START
	sta reg0+1
	ldy #4
	lda #<(freesStart-2)
	sta (reg0), y
	ldy #6
	sta (reg0), y
	ldy #5
	lda #>(freesStart-2)
	sta (reg0), y
	ldy #7
	sta (reg0), y

	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void SetBorder(void *block, size_t n, Byte isUsed) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
SetBorder
.(
	lda reg1
	sta reg3
	lda reg2
	beq is_free
	lda reg1+1
	ora #$80
	sta reg3+1
	bne is_free_skip
is_free
	lda reg1+1
	sta reg3+1
is_free_skip

	ldy #0
	lda reg3
	sta (reg0), y
	iny
	lda reg3+1
	sta (reg0), y

	lda reg1
	sec
	sbc #2
	sta reg1
	lda reg1+1
	sbc #0
	sta reg1+1

	lda reg0
	clc
	adc reg1
	sta reg0
	lda reg0+1
	adc reg1+1
	sta reg0+1

	ldy #0
	lda reg3
	sta (reg0), y
	iny
	lda reg3+1
	sta (reg0), y

	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *GetFree(size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
GetFree
.(
	; reg1 = freesStart, reg2 = NEXT(freesStart-2)
	lda #<freesStart
	sta reg1
	lda #>freesStart
	sta reg1+1
	ldy #0
	lda (reg1), y
	sta reg2
	iny
	lda (reg1), y
	sta reg2+1

loop
	; if reg2 == freesStart-2 return NULL
	lda reg2
	cmp #<(freesStart-2)
	bne not_equal
	lda reg2+1
	cmp #>(freesStart-2)
	bne not_equal
	lda #0
	sta reg0
	sta reg0+1
	rts
not_equal

	; if BLOCK_SIZE(reg2) >= n return reg2
	ldy #1
	lda (reg2), y
	cmp reg0+1
	bcc bad_size
	dey
	lda (reg2),y
	cmp reg0
	bcc bad_size
	lda reg2
	sta reg0
	lda reg2+1
	sta reg0+1
	rts
bad_size

	; reg2 = NEXT(reg2)
	lda reg2
	sta reg1
	lda reg2+1
	sta reg1+1
	ldy #2
	lda (reg1), y
	sta reg2
	iny
	lda (reg1), y
	sta reg2+1

	; continue loop
	bcc loop
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *RemoveFree(void *block) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
RemoveFree
.(
.)

; For a block, returns the location of the contiguous free block if this becomes
; free, size of the overall contiguous free block, and removes free blocks on
; the sides of this block if they are free (adding them to this overall
; contiguous free block).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; [void *, size_t] AddFreeDims(void *block) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
AddFreeDims
.(
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *AddFree(void *block) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
AddFree
.(
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *malloc(size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+malloc
.(
	; If n == 0, return NULL
	lda reg0
	ora reg0+1
	bne not_zero
	rts
not_zero

	; reg0 = n+4
	lda reg0
	clc
	adc #4
	sta reg0
	bcc no_carry
	inc reg0+1
no_carry

	; reg0 = GetFree(n+4)
	jsr GetFree
	; if reg0 == 0 return NULL
	lda reg0
	ora reg0+1
	bne free_found
	rts
free_found
	; reg0 = RemoveFree(reg0)
	jsr RemoveFree

	; reg0 = reg0 + 2
	lda reg0
	clc
	adc #2
	sta reg0
	bcc no_carry2
	inc reg0+1
no_carry2

	; return reg0
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;
; void free(void *d) ;
;;;;;;;;;;;;;;;;;;;;;;
	.text
+free
.(
	; if d == NULL return
	lda reg0
	ora reg0+1
	bne not_null
	rts
not_null

	; reg0 = reg0 - 2
	lda reg0
	sec
	sbc #2
	sta reg0
	bcs no_borrow
	dec reg0+1
no_borrow

	; AddFree(reg0)
	jsr AddFree

	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *realloc(void *d, size_t n) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+realloc
.(
	; if n == 0 free(d), return NULL
	lda reg1
	ora reg1+1
	bne not_zero
	jsr free
	lda #0
	sta reg0
	sta reg0+1
	rts
not_zero

	; if d == 0 return malloc(n)
	lda reg0
	ora reg0+1
	bne not_null
	lda reg1
	sta reg0
	lda reg1+1
	sta reg0+1
	jsr malloc
	rts
not_null

	; reserve stack space
	; +0: word, d
	; +2: word, result
	; +4: word, n
	lda dsp
	sec
	sbc #6
	sta dsp
	bcs no_borrow
	dec dsp+1
no_borrow

	; store d
	lda reg0
	ldy #0
	sta (dsp), y
	lda reg0+1
	iny
	sta (dsp), y

	; store n
	lda reg1
	ldy #4
	sta (dsp), y
	lda reg1+1
	iny
	sta (dsp), y

	; reg0 = malloc(n)
	lda reg1
	sta reg0
	lda reg1+1
	sta reg0+1
	jsr malloc

	; if reg0 == NULL return NULL
	lda reg0
	ora reg0+1
	beq early_exit

	; reg1 = d
	ldy #0
	lda (dsp), y
	sta reg1
	iny
	lda (dsp), y
	sta reg1+1

	; reg2 = MIN(BLOCK_SIZE(d), n)
	ldy #0
	lda (reg1), y
	sta reg2
	iny
	lda (reg1), y
	and #$7F
	sta reg2+1
	ldy #5
	cmp (dsp), y
	bcc n_larger
	lda reg2
	dey
	cmp (dsp), y
	bcc n_larger
	ldy #4
	lda (dsp), y
	sta reg2
	iny
	lda (dsp), y
	sta reg2+1
n_larger

	; reg0 = memcpy(reg0, d, reg2)
	jsr memcpy

	; store reg0 in result
	lda reg0
	ldy #2
	sta (dsp), y
	lda reg0+1
	iny
	sta (dsp),y

	; free(d)
	ldy #0
	lda (dsp), y
	sta reg0
	iny
	lda (dsp), y
	sta reg0+1
	jsr free

	; return result
	ldy #2
	lda (dsp), y
	sta reg0
	iny
	lda (dsp), y
	sta reg0+1
early_exit
	lda dsp
	clc
	adc #6
	sta dsp
	bcc no_carry
	inc dsp+1
no_carry
	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void *calloc(size_t n, size_t m) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+calloc
.(
	; reg2 = n*m, reg0 = 0, reg1 = 0
	lda #0
	sta reg2
	sta reg2+1
	ldx #16
multiply_loop
	lsr reg1+1
	ror reg1
	bcc no_carry
	lda reg2
	clc
	adc reg0
	sta reg2
	lda reg2+1
	adc reg0+1
	sta reg2+1
no_carry
	asl reg0
	rol reg0+1
	dex
	bne multiply_loop

	; reserve stack
	; +0: word, n*m
	lda dsp
	sec
	sbc #2
	sta dsp
	bcs no_borrow
	dec dsp+1
no_borrow

	; reg0 = malloc(reg2)
	lda reg2
	sta reg0
	ldy #0
	sta (dsp), y
	lda reg2+1
	sta reg0+1
	iny
	sta (dsp), y
	jsr malloc

	; return memset(reg0, 0, n*m)
	lda #0
	sta reg1
	ldy #0
	lda (dsp), y
	sta reg2
	iny
	lda (dsp), y
	sta reg2+1
	jsr memset
	; restore stack
	lda dsp
	clc
	adc #2
	sta dsp
	bcc no_carry2
	adc #0
no_carry2
	rts
.)

.) ; alloc module
