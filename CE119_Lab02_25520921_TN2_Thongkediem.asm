.data
    S:          .word   7, 4, 9, 10, 3, 6, 8, 3, 7, 10, 5, 4
    n:          .word   12
    
    # 0(0-3), 1(4-6), 2(7-8), 3(9-10)
    grade_tab:  .byte   0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
    
    .align 2 
    hist:       .word   0, 0, 0, 0

    str_min:    .asciiz "min="
    str_max:    .asciiz " max="
    str_nl:     .asciiz "\n"
    str_g0:     .asciiz "g0="
    str_g1:     .asciiz " g1="
    str_g2:     .asciiz " g2="
    str_g3:     .asciiz " g3="

.text
main:
    # goi stats tim min max
    la      $a0, S
    lw      $a1, n
    jal     stats
    
    # save lai min max de in
    move    $s0, $v0        
    move    $s1, $v1        

    la      $a0, str_min
    li      $v0, 4
    syscall
    move    $a0, $s0
    li      $v0, 1
    syscall
    la      $a0, str_max
    li      $v0, 4
    syscall
    move    $a0, $s1
    li      $v0, 1
    syscall
    la      $a0, str_nl
    li      $v0, 4
    syscall

    # goi histogram
    la      $a0, S
    lw      $a1, n
    la      $a2, grade_tab
    la      $a3, hist
    jal     histogram

    # in hist 0 den 3
    la      $t0, hist 

    la      $a0, str_g0
    li      $v0, 4
    syscall
    lw      $a0, 0($t0)
    li      $v0, 1
    syscall

    la      $a0, str_g1
    li      $v0, 4
    syscall
    lw      $a0, 4($t0)
    li      $v0, 1
    syscall

    la      $a0, str_g2
    li      $v0, 4
    syscall
    lw      $a0, 8($t0)
    li      $v0, 1
    syscall

    la      $a0, str_g3
    li      $v0, 4
    syscall
    lw      $a0, 12($t0)
    li      $v0, 1
    syscall

    li      $v0, 10
    syscall

# --------------------------------
# Thu tuc stats
# tra ve: v0=min, v1=max
stats:
    lw      $v0, 0($a0)
    lw      $v1, 0($a0)
    move    $t0, $a0
    move    $t1, $a1

s_loop:
    beq     $t1, $zero, s_done
    lw      $t2, 0($t0)
    
    bge     $t2, $v0, c_max
    move    $v0, $t2            # update min

c_max:
    ble     $t2, $v1, s_next
    move    $v1, $t2            # update max

s_next:
    addi    $t0, $t0, 4
    addi    $t1, $t1, -1
    j       s_loop

s_done:
    jr      $ra

# --------------------------------
# Thu tuc histogram 
# a2 = arr byte grade, a3 = arr word hist
histogram:
    move    $t0, $a0
    move    $t1, $a1

h_loop:
    beq     $t1, $zero, h_done
    lw      $t2, 0($t0)         
    
    # tra bang diem (s) => lay group id
    add     $t3, $a2, $t2           
    lbu     $t4, 0($t3)         # yeu cau dung lbu
    
    # tang bien dem hist[group_id]
    sll     $t5, $t4, 2         # offset = group_id * 4 byte
    add     $t6, $a3, $t5       
    
    lw      $t7, 0($t6)
    addi    $t7, $t7, 1
    sw      $t7, 0($t6)
    
    addi    $t0, $t0, 4
    addi    $t1, $t1, -1
    j       h_loop

h_done:
    jr      $ra
