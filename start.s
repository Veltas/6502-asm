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
