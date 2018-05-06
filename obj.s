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

#include "start.s"

#include "cpu-util.s"
#include "string.s"
