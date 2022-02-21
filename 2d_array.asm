.data 
    array: 
            .word 1, 2, 9
            .word 1, 6, 2
            .word 1, 3, 2
            .word 1, 12, 2

    row_size: .word 4
    column_size: .word 3 

    convention: .asciiz "Convention Check\n"
    newline:    .asciiz "\n"
    space: .asciiz " "
    
.text

main: 
    jal print_2D

    la $a1, row_size
    lw $a1, 0($a1) 	# a1 stores row_size
    la $a2, column_size
    lw $a2, 0($a2) 	# a2 stores column_size 
    la $a0, array 	# a0 stores array address
    jal sort_by_row
    
    jal print_2D
    j Exit

ConventionCheck:
    addi    $t0, $0, -1
    addi    $t1, $0, -1
    addi    $t2, $0, -1
    addi    $t3, $0, -1
    addi    $t4, $0, -1
    addi    $t5, $0, -1
    addi    $t6, $0, -1
    addi    $t7, $0, -1
    ori     $v0, $0, 4
    la      $a0, convention
    syscall
    addi    $v0, $zero, -1
    addi    $v1, $zero, -1
    addi    $a0, $zero, -1
    addi    $a1, $zero, -1
    addi    $a2, $zero, -1
    addi    $a3, $zero, -1
    addi    $k0, $zero, -1
    addi    $k1, $zero, -1
    jr      $ra
    
Exit:
    ori     $v0, $0, 10
    syscall

print_2D: 
    li $t0, 0 	# row counter
    li $t1, 0 	# column counter 

    la $t2, row_size
    lw $t2, 0($t2) 	# t2 stores row_size
    la $t3, column_size
    lw $t3, 0($t3) 	# t3 stores column_size 

    la $t4, array 	# t4 stores array address

    iterate_row:
        #   reset column counter
        li $t1, 0 

        iterate_col:
            #   offset  =  ((colSize * curRow) + curCol) * 4
            mult $t3, $t0  
            mflo $t5
            add $t5, $t5, $t1
            sll $t5, $t5, 2
            add $t5, $t4, $t5 # add offset with array 
            
            #   start printing word at position 
            li $v0, 1
            lw $a0, 0($t5)
            syscall 

            li $v0, 4
            la $a0, space
            syscall 

            #   increment column counter
            addi $t1, $t1, 1
            blt $t1, $t3, iterate_col

        #   increment row counter
        addi $t0, $t0, 1

        # add new line 
        li $v0, 4
        la $a0, newline
        syscall

        blt $t0, $t2, iterate_row
    
    jr $ra 

average_row:
    # a0 stores row address return average of row in $v0

    move $t0, $a0

    la $t1, column_size
    lw $t1, 0($t1)

    li $t2, 0 	# $t2 is loop counter 
    li $t3, 0 	# total sum 
    sum_row_loop: 
        #   offset = loop counter * 4
        sll $t4, $t2, 2
        add $t4, $t4, $t0 
        lw $t4, 0($t4)

        add $t3, $t3, $t4

        #   increment loop counter 
        add $t2, $t2, 1 
        blt $t2, $t1, sum_row_loop
    
    div $t3, $t1
    mflo $v0 

    jr $ra 

swap_rows: #takes in the address of the rows you want to swap and swaps them.
    addi $sp, $sp, -20
    sw $s0, 0($sp) 
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    move $s0, $a0 # address of row1
    move $s1, $a1 # address of row2

    la $s2, column_size
    lw $s2, 0($s2)

    li $s3, 0 # counter 

    swap_iterate: 
        sll $t0, $s3, 2 
        add $t1, $t0, $s0 
        add $t2, $t0, $s1

        # swap elements in array 
        lw $t3, 0($t1)
        lw $t4, 0($t2)
        sw $t3, 0($t2)
        sw $t4, 0($t1)

        # increment loop counter
        addi $s3, $s3, 1
        blt $s3, $s2, swap_iterate 

    jal ConventionCheck

    lw $s0, 0($sp) 
    lw $s1, 4($sp) 
    lw $s2, 8($sp) 
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    
    jr $ra

# COPYFROMHERE - DO NOT REMOVE THIS LINE
sort_by_row: 
    # a0 stores the array address, a1 and a2 store the size of row and column respectively
    
    move $t0, $a0     # $t0 = array address

    addi $sp, $sp, -20
    sw $s0, 0($sp) 
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    li $t1, 0         # $t1 = i
    li $t2, 0         # $t2 = j
LoopOuter:
    li $t2, 0 #reset j

LoopInner:
    mult $t2, $a2 
    mflo $t4              
    sll $t4, $t4, 2       
    add $t4, $t4, $t0     # first row
    sll $t6, $a2, 2
    add $t6, $t4, $t6     # next row

    move $s0, $t0   # SAVE
    move $s1, $t1
    move $s2, $t2
    move $s3, $t3
    move $s4, $t4
    move $s5, $a1
    move $s6, $t6
    move $s7, $a2
    move $a0, $t4   # Set Up Parameters
    jal average_row 
    move $t5 $v0    # Average of first row
    move $a0, $t6   # Set Up Parameters
    jal average_row 
    move $t7, $v0   # Average of next row
    move $t0, $s0   # RESTORE
    move $t1, $s1
    move $t2, $s2
    move $t3, $s3
    move $t4, $s4
    move $a1, $s5
    move $t6, $s6
    move $a2, $s7

    ble $t5, $t7 ELSE

    move $s0, $t0   # SAVE
    move $s1, $t1
    move $s2, $t2
    move $s3, $t3
    move $s4, $t4
    move $s5, $a1
    move $s6, $t6
    move $s7, $a2
    move $a0, $t4   # Set Up Parameters
    move $a1, $t6   # Set Up Parameters
    jal swap_rows   # SWAPPED
    move $t0, $s0   # RESTORE
    move $t1, $s1
    move $t2, $s2
    move $t3, $s3
    move $t4, $s4
    move $a1, $s5
    move $t6, $s6
    move $a2, $s7

ELSE:
    sub $t3, $a1, $t1
    addi $t3, $t3, -1
    addi $t2, $t2, 1
    blt $t2, $t3, LoopInner

    # LoopOuter Again
    addi $t1, $t1, 1      #iterate i
    addi $t9, $a1, -1 
    blt $t1, $t9, LoopOuter
            
    lw $s0, 0($sp) 
    lw $s1, 4($sp) 
    lw $s2, 8($sp) 
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    # Do not remove this line
    jr $ra