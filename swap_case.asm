# Data Area
.data
    buffer: .space 100
    input_prompt:   .asciiz "Enter string:\n"
    output_prompt:   .asciiz "Output:\n"
    convention: .asciiz "Convention Check\n"
    newline:    .asciiz "\n"

.text

main:
    la $a0, input_prompt    # prompt user for string input
    li $v0, 4
    syscall

    li $v0, 8       # take in input
    la $a0, buffer
    li $a1, 100
    syscall
    move $s0, $a0   # save string to s0

    ori $s1, $0, 0
    ori $s2, $0, 0
    ori $s3, $0, 0
    ori $s4, $0, 0
    ori $s5, $0, 0
    ori $s6, $0, 0
    ori $s7, $0, 0

    move $a0, $s0
    jal Swap_Case

    add $s1, $s1, $s2
    add $s1, $s1, $s3
    add $s1, $s1, $s4
    add $s1, $s1, $s5
    add $s1, $s1, $s6
    add $s1, $s1, $s7
    add $s0, $s0, $s1

    la $a0, output_prompt    # give Output prompt
    li $v0, 4
    syscall

    move $a0, $s0
    jal DispString

    j Exit

DispString:
    # addi $a0, $a0, 0
    li $v0, 4
    syscall
    jr $ra

ConventionCheck:
    addi    $t0, $0, -1
    addi    $t1, $0, -1
    addi    $t2, $0, -1
    addi    $t3, $0, -1
    addi    $t4, $0, -1
    addi    $t5, $0, -1
    addi    $t6, $0, -1
    addi    $t7, $0, -1
    addi    $t8, $0, -1
    addi    $t9, $0, -1
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

# COPYFROMHERE - DO NOT REMOVE THIS LINE

Swap_Case:
    #TODO: write your code here, $a0 stores the address of the string
    move $s0, $a0

    #Convention
    addiu $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $ra, 20($sp)
    
    li $s1, 0
    move $s3, $a0
    add $s2, $s1, $s3
    lbu $s0, 0($s2)
    li $s4, 4

loop:
    #bgt $s1, $s4, loopEnd
    beq $s0, $zero loopEnd #reach null

    #If Upper Case Letter
    li $t3, 65       # set t3 = 'A'
    li $t4, 90       # set t4 = 'Z'
    sge $t5, $s0, $t3         # if (c >= 'A') $t5 = 1
    sle $t6, $s0, $t4         # if (c <= 'Z') $t6 = 1
    and $t7, $t5, $t6,        # if ($t5 && $t6) $t7 = 1
    bne $t7, $zero, isUpper     # if ($t7 != 0) goto isUpper
    
    #If Lower Case Letter
    li $t3, 97       # set t3 = 'a'
    li $t4, 122       # set t4 = 'z'
    sge $t5, $s0, $t3         # if (c >= 'a') $t5 = 1
    sle $t6, $s0, $t4         # if (c <= 'z') $t6 = 1
    and $t7, $t5, $t6,        # if ($t5 && $t6) $t7 = 1
    bne $t7, $zero, isLower     # if ($t7 != 0) goto isLower

notLetter:
    j afterBranch

isUpper:
    li $v0 11
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    addiu $s0, $s0, 32
    sb $s0, 0($s2) #store new character 
    li $v0 11
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    jal ConventionCheck
    j afterBranch

isLower:
    li $v0 11
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    addiu $s0, $s0, -32
    sb $s0, 0($s2) #store new character 
    li $v0 11
    move $a0, $s0
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    jal ConventionCheck
    j afterBranch

afterBranch:
    addi $s1, $s1, 1
    add $s2, $s1, $s3
    lbu $s0, 0($s2)
    j loop
    
loopEnd:
    # Do not remove this line
    #Convention
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $ra, 20($sp)
    addiu $sp, $sp, 32
    jr $ra