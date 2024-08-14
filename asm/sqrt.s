.set noreorder
.set noat
.globl __start
.section text


__start:
.text
initialize:
    lui $s0, 0x8040 #s0 = A = 0x80400000
    lui $s2, 0x8050 #s2 = B = 0x80500000
    lui $s1, 0x0004 #s1=40000
    ori $s5, 0xffff #s5=max of sq_max-1
    ori $t0, 0
    or $t1, $0, $s0 
# write_test_data:
# 	sw  $t0, 0($t1)
# 	addiu $t1, $t1, 4
# 	bne $t0, $s1, write_test_data
# 	addiu $t0, $t0, 1
# write_test_data_end:
    lui $s4, 0x8040
    sll $v0, $s1, 2
    addu $s4, $s4, $v0 #s4=A_end
    or $t5, $s0, $0 # t5=&A[offset]
    or $t6, $s2, $0 # t6=&B[offset]
loop:
    lw $a0, 0($t5) # a0=n
    or $t1, $0, $0 # t1=sq_min
    srl $t2, $a0, 1
    addiu $t2, $t2, 2# t2=sq_max
    sltu $v0, $s5, $t2
    beq $v0, $0, sq_max_judge_end
    nop 
    lui $t2, 0x1
sq_max_judge_end:
    addu $t3, $t1, $t2
    srl $t3, $t3, 1 # t3=sq=(sq_min+sq_max)/2
    mul $t4, $t3, $t3 # t4=sq2
find_sq_loop:
    beq $t1, $t2, find_sq_loop_end
    sltu $v0, $a0, $t4
    beq $v0, $0, sq2small
    nop
sq2big:
    beq $0, $0, sq2_b_end
    or $t2, $t3, $0
sq2small:
    or $t1, $t3, $0
sq2_b_end:
    addu $t3, $t1, $t2
    srl $t3, $t3, 1 # t3=sq=(sq_min+sq_max)/2
    bne $t3, $t1, find_sq_loop
    mul $t4, $t3, $t3
find_sq_loop_end:
    sw $t1, 0($t6)
    addiu $t6, $t6, 4
    bne $t5, $s4, loop
    addiu $t5, $t5, 4
end:
    jr $ra
    nop
