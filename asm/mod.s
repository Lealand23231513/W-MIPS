.set noreorder
.set noat
.globl __start
.section text


__start:
.text
initialize:
    lui $s0, 0x8040 #s0 = A = 0x80400000
    lui $s1, 0x8050 #s1 = B = 0x80500000
    lui $s2, 0x8060 #s2 = C = 0x80600000
    or  $s3, $s0, $0 #s3=&A[addr]
    or  $s4, $s1, $0 #s4=&B[addr]
    or  $s5, $s2, $0 #s5=&C[addr]
    lui $t0, 0x8000 #t0=t
loop:
    lw $t1, 0($s4)# t1=b
    lui $v0, 0x0 #v0=ishigh
    ori $t2, $0, 0x0 #t2=q_l
    ori $t3, $0, 0x1 #t3=q_h
    addiu $s4, $s4, 4
    lw $t4, 0($s3) #t4=a
    addiu $s3, $s3, 4
    or $v1, $t1, $0 #v1 tmp_store b
find_q_h:
    and $v0, $t0, $t1
    bne $v0, $0, find_q_h_end
    nop
    sll $t1, $t1, 1 # otherwise b shift for 1 more time
    beq $0, $0, find_q_h
    sll $t3, $t3, 1
find_q_h_end: #v0 release
    sltu $v0, $t4, $t1 #a<b?1:0
    bne $v0, $0, ab_branch_end
    nop
    subu $t4, $t4, $t1
ab_branch_end:
    or $t1, $v1, $0
find_q_loop:
    addiu $v0, $t3, -1
    sltu $v0, $t2, $v0 #q_l<q_h-1?1:0
    beq $v0, $0, find_q_loop_end
    subu $t5, $t3, $t2
    srl $t5, $t5, 1
    addu $t5, $t5, $t2
    mul $v1, $t1, $t5# v1= bq(tmp)
    sltu $v0, $t4, $v1# 0 branch
    beq $v0, $0, bq_large_branch
    nop
    beq $0, $0, bq_judge_branch_end
    or $t3, $t5, $0
bq_large_branch:
    or $t2, $t5, $0
bq_judge_branch_end:
    beq $0, $0, find_q_loop
    nop
find_q_loop_end:
    mul $v0, $t1, $t2
    subu $v0, $t4, $v0
    sw $v0, 0($s5)
    bne $s3, $s1, loop
    addiu $s5, $s5, 4
end:    
    jr $ra
    nop
