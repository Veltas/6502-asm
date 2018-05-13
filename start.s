; vim: set syntax=6502:

; Startup code, wherever that needs to go
	.text
	* = PROG_START
startup
	; DSP_START -> dsp
	lda #< DSP_START
	sta dsp
	lda #> DSP_START
	sta dsp+1

	; Initializers
	jsr InitAlloc

	; call main
	jsr main

	; end
	rts
