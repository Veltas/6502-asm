" Copyright (c) 2018 Christopher Leonard

" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the 'Software'), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:

" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.

" THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.


"================================================================
" Vim 6502 syntax file, based on xa65 specific assembler syntax
" Copy to e.g. ~/.vim/syntax/ to enable
"================================================================

if exists("b:current_syntax")
  finish
endif

syntax case ignore

syn keyword m6502Keywords defined adc and asl bcc bcs beq bit bmi bne bpl brk
syn keyword m6502Keywords bvc bvs clc cld cli clv cmp cpx cpy dec dex dey eor
syn keyword m6502Keywords inc inx iny jmp jsr lda ldx ldy lsr nop ora pha php
syn keyword m6502Keywords pla plp rol ror rti rts sbc sec sed sei sta stx sty
syn keyword m6502Keywords tax tay tsx txa txs tya a x y
syn match m6502Keywords "\*"

" 65c02 and 65816 opcodes
syn keyword m6502Keywords mvp mvn txy tyx bra brl cop tsb trb stz pea pei per
syn keyword m6502Keywords phb phd phk phx phy plb pld plx ply rep rtl sep stp
syn keyword m6502Keywords tcd tcs tdc tsb tsc wai xba xce

syn match m6502Pseudo "\.byt\>"
syn match m6502Pseudo "\.asc\>"
syn match m6502Pseudo "\.aasc\>"
syn match m6502Pseudo "\.word\>"
syn match m6502Pseudo "\.dsb\>"
syn match m6502Pseudo "\.bin\>"
syn match m6502Pseudo "\.as\>"
syn match m6502Pseudo "\.al\>"
syn match m6502Pseudo "\.xs\>"
syn match m6502Pseudo "\.xl\>"
syn match m6502Pseudo "\.align\>"
syn match m6502Pseudo "\.fopt\>"

syn match m6502Special "\.("
syn match m6502Special "\.)"

syn match m6502Page "\.text\>"
syn match m6502Page "\.data\>"
syn match m6502Page "\.bss\>"
syn match m6502Page "\.zero\>"

syn match m6502Number "\<\d\+\>"
syn match m6502Number "\$\x\+\>"
syn match m6502Number "\<0[xX]\x\+\>"
syn match m6502Number "\<[01]\+[bB]\>"
syn match m6502Number "&[0-7]\+\>"
syn match m6502Number "%[01]\+\>"

syn region m6502String start=/\v"/ skip=/\v\\./ end=/\v"/
syn match m6502String '\'[^"]\''
syn match m6502String '\'\\.\''


syn keyword m6502Todo contained TODO FIXME XXX NOTE

syn region m6502Comments start="\/\*" end="\*\/" contains=m6502Todo
syn match m6502Comments ';.*$' contains=m6502Todo
syn match m6502Comments '//.*$' contains=m6502Todo

syn region m6502Macro start="^#" skip="\\$" end="$" contains=m6502Todo

let b:current_syntax = "6502"

hi def link m6502Todo Todo
hi def link m6502Comments Comment
hi def link m6502String Constant
hi def link m6502Special Special
hi def link m6502Page Special
hi def link m6502Pseudo Conditional
hi def link m6502Number Constant
hi def link m6502Keywords Conditional
hi def link m6502Macro Macro
