.data
    # chuoi test P (4 cap ngoac long nhau)
    str:    .asciiz "([{()}])"

.text
main:
    # truyen dia chi chuoi vao a0 va goi check_brackets
    la      $a0, str
    jal     check_brackets

    # save v0, v1 lai de in
    move    $s0, $v0
    move    $s1, $v1

    # in v0 (vi tri loi)
    move    $a0, $s0
    li      $v0, 1
    syscall

    # in dau cach
    li      $a0, ' '
    li      $v0, 11
    syscall

    # in v1 (ma loi)
    move    $a0, $s1
    li      $v0, 1
    syscall

    # exit
    li      $v0, 10
    syscall

# Thu tuc: check_brackets

check_brackets:
    move    $t9, $sp        # save sp goc de lat check rong voi restore
    li      $t0, 1          # pos = 1
    move    $t1, $a0        # ptr chuoi

cb_loop:
    lbu     $t2, 0($t1)
    beq     $t2, $zero, cb_end_str  # gap \0 thi dung

    # check ngoac mo -> push
    li      $t4, '('
    beq     $t2, $t4, cb_push
    li      $t4, '['
    beq     $t2, $t4, cb_push
    li      $t4, '{'
    beq     $t2, $t4, cb_push

    # check ngoac dong -> pop
    li      $t4, ')'
    beq     $t2, $t4, cb_check_close
    li      $t4, ']'
    beq     $t2, $t4, cb_check_close
    li      $t4, '}'
    beq     $t2, $t4, cb_check_close

    j       cb_next         # ky tu thuong thi bo qua

cb_push:
    addi    $sp, $sp, -4
    sw      $t2, 0($sp)
    j       cb_next

cb_check_close:
    beq     $sp, $t9, err_empty_stack # stack dang rong -> loi 2

    lw      $t3, 0($sp)     # pop ra vao t3
    addi    $sp, $sp, 4

    # check match
    li      $t4, ')'
    bne     $t2, $t4, cb_try_square
    li      $t5, '('
    bne     $t3, $t5, err_mismatch
    j       cb_next

cb_try_square:
    li      $t4, ']'
    bne     $t2, $t4, cb_try_curly
    li      $t5, '['
    bne     $t3, $t5, err_mismatch
    j       cb_next

cb_try_curly:
    li      $t5, '{'
    bne     $t3, $t5, err_mismatch
    j       cb_next

cb_next:
    addi    $t1, $t1, 1     # ptr++
    addi    $t0, $t0, 1     # pos++
    j       cb_loop

cb_end_str:
    bne     $sp, $t9, err_leftover  # het chuoi ma stack con do -> loi 3
    
    # done, hop le
    li      $v0, 0
    li      $v1, 0
    j       cb_exit

err_mismatch:               # loi 1: sai loai
    move    $v0, $t0
    li      $v1, 1
    j       cb_exit

err_empty_stack:            # loi 2: du ngoac dong
    move    $v0, $t0
    li      $v1, 2
    j       cb_exit

err_leftover:               # loi 3: du ngoac mo (t0 dang la len+1 san roi)
    move    $v0, $t0        
    li      $v1, 3
    j       cb_exit

cb_exit:
    move    $sp, $t9        # fix stack ve nguyen trang truoc khi return
    jr      $ra