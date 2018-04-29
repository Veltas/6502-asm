" Vim syntax file
" Copy to e.g. ~/.vim/syntax/ to enable

if exists("b:current_syntax")
  finish
endif

syntax case ignore

syn keyword z80Keywords defined adc and asl bcc bcs beq bit bmi bne bpl brk bvc bvs clc cld cli clv cmp cpx cpy dec dex dey eor inc inx iny jmp jsr lda ldx ldy lsr nop ora pha php pla plp rol ror rti rts sbc sec sed sei sta stx sty tax tay tsx txa txs tya a x y
syn match z80Keywords "\*"

syn match z80Number "\<\d\+\>"
syn match z80Number "\<[+-]\?0[xX]\x\+\>"
syn match z80Number "\<[+-]\?[01]\+[bB]\>"

syn region z80String start=/\v"/ skip=/\v\\./ end=/\v"/
syn match z80String '\'[^"]\''
syn match z80String '\'\\.\''


syn keyword z80Todo contained TODO FIXME XXX NOTE

syn match z80Comments ';.*$' contains=z80Todo
syn match z80Comments '//.*$' contains=z80Todo
"syn match z80Comments '/\*.*\*/' contains=z80Todo
syn match z80Macro '^#.*$' contains=z80Todo

let b:current_syntax = "6502"

hi def link z80Todo Todo
hi def link z80Comments Comment
hi def link z80String Constant
hi def link z80Number Constant
hi def link z80Keywords Conditional
hi def link z80Macro Macro
