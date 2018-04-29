" Vim syntax file
" Copy to e.g. ~/.vim/syntax/ to enable

if exists("b:current_syntax")
  finish
endif

syntax case ignore

syn keyword m6502Keywords defined adc and asl bcc bcs beq bit bmi bne bpl brk bvc bvs clc cld cli clv cmp cpx cpy dec dex dey eor inc inx iny jmp jsr lda ldx ldy lsr nop ora pha php pla plp rol ror rti rts sbc sec sed sei sta stx sty tax tay tsx txa txs tya a x y
syn match m6502Keywords "\*"

syn match m6502Number "\<\d\+\>"
syn match m6502Number "\$\x\+\>"
syn match m6502Number "\<0[xX]\x\+\>"
syn match m6502Number "\<[01]\+[bB]\>"

syn region m6502String start=/\v"/ skip=/\v\\./ end=/\v"/
syn match m6502String '\'[^"]\''
syn match m6502String '\'\\.\''


syn keyword m6502Todo contained TODO FIXME XXX NOTE

syn match m6502Comments ';.*$' contains=m6502Todo
syn match m6502Comments '//.*$' contains=m6502Todo
"syn match m6502Comments '/\*.*\*/' contains=m6502Todo
syn match m6502Macro '^#.*$' contains=m6502Todo

let b:current_syntax = "6502"

hi def link m6502Todo Todo
hi def link m6502Comments Comment
hi def link m6502String Constant
hi def link m6502Number Constant
hi def link m6502Keywords Conditional
hi def link m6502Macro Macro
