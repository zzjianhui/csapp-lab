.global asm_call
.code64
.section .text


asm_call:
    lea -24(%rsp),%rdi
    movq $0x4018fa,(%rsp)
    retq
