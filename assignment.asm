.data
input_file: .asciiz "D:/MAIN COURSE/BASIC COURSES/COMPUTER ARCHITECTURE/input_matrix.txt"

image: .double 0:49
kernel: .double 0:16
out: .double 0:49
space: .asciiz "		"
newline: .asciiz "\n"
N: .word 0
M: .word 0
p: .word 0
s: .word 0

content: .space 256

number0: .double 0.0
number1: .double 1.0
number10: .double 10.0
.text
main:
	#open file
	li $v0, 13
	la $a0, input_file
	li $a1, 0
	syscall
	move $s1, $v0
	
	#read line 1
	li $v0, 14
	move $a0, $s1
	la $a1, content
	la $a2, 256
	syscall
	
	jal read_line1
	#bit 7 is carriage feed, bit 8 is line feed
	#line 2 start from bit 9
	la $s0, content
	addi $s0, $s0, 9
	
	j read_line2
finish_line2:
#	jal display_matrix
	addi $s0, $s0, 1
	j read_line3
finish_line3:
#	jal display_matrix
	
finish_assignment:
	li $v0, 10
	syscall
################################################
read_line1:
	la $t1, content
	lb $t2, 0($t1)
	addi $t2, $t2, -48
	sw $t2, N
	
	lb $t2, 2($t1)
	addi $t2, $t2, -48
	sw $t2, M
	
	lb $t2, 4($t1)
	addi $t2, $t2, -48
	sw $t2, p
	
	lb $t2, 6($t1)
	addi $t2, $t2, -48
	sw $t2, s
	
	jr $ra
	
################################################
ascii2double:
#	ldc1 $f0, number0	#result store in f0
#	ldc1 $f2, number1	#f2 is unit
	ldc1 $f4, number10
	
	lb $t0, ($s0)
	sub $t0, $t0, 48
	mtc1 $t0, $f0
	cvt.d.w $f0, $f0
	
	addi $s0, $s0, 1
	lb $t0, ($s0)
	sub $t0, $t0, 48
int_part:
	beq $t0, -2, dec_part	#46(dot) - 48
	mul.d $f0, $f0, $f4
	
	mtc1 $t0, $f6
	cvt.d.w $f6, $f6
	
	add.d $f0, $f0, $f6	
	
	addi $s0, $s0, 1
	lb $t0, ($s0)
	sub $t0, $t0, 48
	
	j int_part
	
dec_part:
	addi $s0, $s0, 1
	lb $t0, ($s0)
	sub $t0, $t0, 48

	mtc1 $t0, $f6
	cvt.d.w $f6, $f6
	
	div.d $f6, $f6, $f4
	add.d $f0, $f0, $f6
	
	jr $ra

################################################
read_line2:
	lw $t7, N
	lw $t8, p
	la $s2, image
	mul $t2, $t8, 2
	add $t1, $t7, $t2
	move $t9, $t1
	mult $t9, $t9
	mflo $t9
	#t7 now store new size of image, $t8 store padding, t9 store total entries

	li $t1, 0
	li $t2, 0
	li $t3, 0
loop_line2:
	beq $t3, $t9, finish_line2
	
	slt $t4, $t1, $t8
	beq $t4, 1, add0
	
	slt $t4, $t2, $t8
	beq $t4, 1, add0
	
	jal ascii2double
	sdc1 $f0, ($s2)
	
	addi $s0, $s0, 2
	addi $s2, $s2, 8
	addi $t3, $t3, 1
	
	div $t3, $t7
	mflo $t2
	mfhi $t1
	
	j loop_line2	
add0:
	ldc1 $f0, number0
	sdc1 $f0, ($s2)
	
	addi $s0, $s0, 2
	addi $s2, $s2, 8
	addi $t3, $t3, 1

	div $t3, $t7
	mflo $t2
	mfhi $t1
	
	j loop_line2
################################################
read_line3:
	lw $t7, M
	la $s2, kernel

	mult $t7, $t7
	mflo $t9
	#t7 now store new size of kernel, t9 store total entries
	li $t3, 0
loop_line3:
	beq $t3, $t9, finish_line3
	
	jal ascii2double
	sdc1 $f0, ($s2)
	
	addi $s0, $s0, 2
	addi $s2, $s2, 8
	addi $t3, $t3, 1
	
	j loop_line3	

################################################
display_matrix:
	lw $t7, M
	mul $t9, $t7, $t7
	
	la $s3, kernel
	li $t1, 0
	li $t2, 0
	li $t3, 0
	
display_loop:
	beq $t3, $t9, display_finish
	ldc1 $f0, ($s3)
	
	li $v0, 3
	mov.d $f12, $f0
	syscall
	
	addi $t3, $t3, 1
	addi $s3, $s3, 8
	
	div $t3, $t7
	mflo $t2
	mfhi $t1
	
	addi $t6, $t7, -1
	beq $t1, $t6, display_newline
	
	li $v0, 4
	la $a0, space
	syscall
	
	j display_loop
display_newline:
	li $v0, 4
	la $a0, newline
	syscall

	j display_loop
display_finish:
	jr $ra
