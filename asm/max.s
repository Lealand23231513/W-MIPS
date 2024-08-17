.set noreorder
.set noat
.globl __start
.section text


__start:
.text
initialize:
    lui $s0, 0x8040 #s0 = A = 0x80400000
    lui $s1, 0x8070 #s1 = B = 0x80700000
    or $s2, $s0, $0 #s2 = &A[addr]
    lw $t0, 0($s0)
loop:
    lw $t1, 0($s2)
    addu $s2, $s2, 4
    bne $s2, $s1, loop
    mul $t0, $t0, $t1
    sw $t0, 0($s1)
end:
    jr $ra
    nop
