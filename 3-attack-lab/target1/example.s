.global asm_call
.code64
.section .text


asm_call:
    movq $0x0000000059b997fa,%rdi
    movq $0x00000000004017ec,(%rsp)
    retq
