; vim: set syntax=6502:

; 8-bit PRNG, based on idea by EternityForsest in
; https://www.electro-tech-online.com/threads/ultra-fast-pseudorandom-number-generator-for-8-bit.124249/

.( ; random module

; unsigned char g_randomState[4];
	.text ; FIXME
	;.bss
+g_randomState
stateX
	.byt 50
stateA
	.byt 173
stateB
	.byt 16
stateC
	.byt 123


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void EntropyRandom(Byte s1, Byte s2, Byte s3) ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
+EntropyRandom
.(
	lda stateA
	eor reg0
	sta stateA

	lda stateB
	eor reg0+1
	sta stateB

	lda stateC
	eor reg1
	sta stateC

	jsr RandomStep

	rts
.)

;;;;;;;;;;;;;;;;;;;;;;;;;
; void RandomStep(void) ;
;;;;;;;;;;;;;;;;;;;;;;;;;
	.text
RandomStep
.(
	inc stateX

	lda stateA
	eor stateC
	eor stateX
	sta stateA

	lda stateB
	clc
	adc stateA
	sta stateB

	lsr stateB
	eor stateA
	clc
	adc stateC
	sta stateC

	rts
.)

;;;;;;;;;;;;;;;;;;;;;
; Byte Random(void) ;
;;;;;;;;;;;;;;;;;;;;;
	.text
+Random
.(
	jsr RandomStep

	lda stateC
	sta reg0
	rts
.)

.) ; random module
