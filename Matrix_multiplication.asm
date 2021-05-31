# Author - Eyal

.data
   A: .space 1024
   B: .space 1024
   C: .space 1024
.asciiz
	msg1_A:	"\nEnter number of A rows: "
	msg1_B:	"Enter number of B rows: "
	msg2_A: "Enter number of A columns: "
	msg2_B:	"Enter number of B columns: "
	enter_nums: " = X. Enter X numbers,\n"
	ERROR: "ERROR!\n"
	mes_A: "\nA:\n"
	mes_B: "\nB:\n"
	mes_C: "\nC:\n"

.word
	Ac: -1
	Ar: -1
	Bc: -1
	Br: -1
	Cc: -1
	Cr: -1

.text 
main:
	jal A_input
	jal B_input
	jal print_A
	jal print_B
	jal check_valid
	jal mult_mat
	jal print_C
	j finish


mult_mat:
	sub $sp, $sp, 4
	sw $t2, 0($sp)
	sub $sp, $sp, 4
	sw $t1, 0($sp)
	sub $sp, $sp, 4
	sw $t0, 0($sp)
	
	la $t0, Ar
	lw $t0, 0($t0)
	la $t1, Br # we know that Ac == Br
	lw $t1, 0($t1)
	la $t2, Bc
	lw $t2, 0($t2)
	
	la $t3, A
	la $t4, B
	la $t5, C
	
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0
	li $s5, 0
	li $s6, 4
	li $s7, 0


	# $t0 = Ar
	# $t1 = Ac = Br
	# $t2 = Bc
	# $t3 = A
	# $t4 = B
	# $t5 = C
	# $t6 = 0
	# $t7 = 0
	# $t8 = 0
	# $t9 = 0
	# $s0 = $s1 = $s2 = 0
	# $s3 = $s4 = $s5 = 0
	# $s6 = 4
	# $s7 = 0

	# Initializing elements of C to 0.
mult $t0, $t2
mflo $s3
mult $s3, $s6
mflo $s3
add $s0, $s0, $t5
add $s3, $s3, $s0

loop:
	sw $zero, 0($s0) # Put 0 in C
	addi $s0, $s0, 4
	bne $s3, $s0, loop


# we have a dubble nested loop:
li $s3, 0
li $s0, 0
loop1: # $s0

	li $s1, 0
	loop2: # $s1
		li $s2, 0
		loop3: # $s2
			
			# For C
			mult $s0, $t2
			mflo $s3
			add $s3, $s3, $s1
			mult $s3, $s6
			mflo $s3


			# For A
			mult $s0, $t1
			mflo $s4
			add $s4, $s4, $s2
			mult $s4, $s6
			mflo $s4


			# For B
			mult $s2, $t2
			mflo $s5
			add $s5, $s5, $s1
			mult $s5, $s6
			mflo $s5

			
			add $t8, $s4, $t3
			lw $t8, 0($t8) # Element in A
			
			add $t9, $s5, $t4
			lw $t9, 0($t9) # Element in B
			
			mult $t8, $t9
			mflo $s7
			
			add $t7, $s3, $t5
			
			add $t6, $t6, $s7

			
			addi $s2, $s2, 1
			bne $t1, $s2, loop3
			
		sw $t6, 0($t7) # Put in C
		li $t6, 0
		addi $s1, $s1, 1
		bne $t2, $s1, loop2
	addi $s0, $s0, 1
	bne $t0, $s0, loop1

lw $t0, 0($sp)
add $sp, $sp, 4
lw $t1, 0($sp)
add $sp, $sp, 4
lw $t2, 0($sp)
add $sp, $sp, 4
	
jr $ra
	
	
	

check_valid:

	la $t1, Br
	lw $t1, 0($t1)
	# $t1 = B Rows
	la $t2, Bc
	lw $t2, 0($t2)
	# $t2 = B Columns
	la $t3, Ar
	lw $t3, 0($t3)
	# $t3 = A Rows
	la $t0, Ac
	lw $t0, 0($t0)
	# $t0 = A Columns
	bne $t0, $t1, not_valid

	# check that they not negetive:
	sle $t4, $t1, $zero
	bne $zero, $t4, not_valid
	sle $t4, $t2, $zero
	bne $zero, $t4, not_valid
	sle $t4, $t3, $zero
	bne $zero, $t4, not_valid
	
	# if it pass all the tests: (valid)
	la $t0, Cr
	sw $t3, 0($t0)
	# C Rows = A Rows
	la $t0, Cc
	sw $t2, 0($t0)
	# C Columns = B Columns
	jr $ra

not_valid:
	# if not valid:
	la $a0, ERROR 
	li $v0, 4
	# print "ERROR"
	syscall 
	j main

	
	
A_input:
	# we save all the registrs we use them

	sub $sp, $sp, 4
	sw $t2, 0($sp)
	sub $sp, $sp, 4
	sw $t1, 0($sp)
	sub $sp, $sp, 4
	sw $t0, 0($sp)
	
	li $v0, 4
	la $a0, msg1_A 
	# print "Enter number of A rows:"
	syscall 
	li $v0, 5 
	syscall
	la $s0, Ar
	sw $v0, 0($s0)
	# Ar = A Rows
	li $v0, 4                        
	la $a0, msg2_A
	
	# print Enter number of A columns:
	syscall 
	li $v0, 5
	syscall 
	la $s0, Ac
	sw $v0, 0($s0)
	# Ac = A Columns
	addi $t0, $v0, 0

	la $t0, Ar
	lw $t0, 0($t0)
	# $t0 = A Rows
	la $t1, Ac
	lw $t1, 0($t1)
	# $t1 = A Columns

	mult $t0, $t1
	mflo $t0
	# $t0 = Ac * Ar
	li $v0, 1
	add $a0, $t0, $zero
	syscall
	# print Ac * Ar
	
	li $v0, 4
	la $a0, enter_nums
	syscall
	

	
	la $t1, A
	# $t1 = addrass of A
	
A_values:
	# Now We read A values:

	li $v0 5
	syscall
	
	sw $v0, 0($t1)	                
	# save current value
	addi $t1, $t1, 4
	addi $t0, $t0 ,-1
	sge $t3, $zero, $t0
	beq $t3, $zero, A_values
	

	lw $t2, 0($sp)
	add $sp, $sp, 4
	lw $t1, 0($sp)
	add $sp, $sp, 4
	lw $t0, 0($sp)
	add $sp, $sp, 4

	jr $ra
	
	
B_input:
	# we save all the registrs we use them

	sub $sp, $sp, 4
	sw $t2, 0($sp)
	sub $sp, $sp, 4
	sw $t1, 0($sp)
	sub $sp, $sp, 4
	sw $t0, 0($sp)

	
	li $v0, 4
	la $a0, msg1_B
	# print "Enter number of B rows:"
	syscall 
	li $v0, 5 
	syscall
	la $s0, Br
	sw $v0, 0($s0)
	# Br = B Rows
	li $v0, 4
	la $a0, msg2_B
	
	# print Enter number of B columns:
	syscall 
	li $v0 5
	syscall 
	la $s0, Bc
	sw $v0, 0($s0)
	# Bc = B Columns
	addi $t0, $v0, 0

	la $t0, Br
	lw $t0, 0($t0)
	# $t0 = B Rows
	la $t1, Bc
	lw $t1, 0($t1)
	# $t1 = B Columns

	mult $t0, $t1
	mflo $t0
	# $t0 = Bc * Br
	li $v0, 1
	add $a0, $t0, $zero
	syscall
	# print Bc * Br
	
	li $v0, 4
	la $a0, enter_nums
	syscall
	

	
	la $t1, B
	# $t1 = addrass of B
	
B_values:
	# Now We read B values:

	li $v0, 5
	syscall
	
	sw $v0, 0($t1)
	# save current value
	addi $t1, $t1, 4
	addi $t0, $t0, -1

	sge $t3, $zero, $t0
	beq $t3, $zero, B_values
	
	lw $t2, 0($sp)
	add $sp, $sp, 4
	lw $t1, 0($sp)
	add $sp, $sp, 4
	lw $t0, 0($sp)
	add $sp, $sp, 4

	jr $ra
	
	



print_A:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	la $t1, Ar
	lw $t1, 0($t1)
	la $t0, Ac
	lw $t0, 0($t0)
	la $t2, A
	
	li $v0, 4                        
	la $a0, mes_A
	# print 'A:'
	syscall 
	jal print_Mat
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	
print_B:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	la $t1, Br
	lw $t1, 0($t1)
	la $t0, Bc
	lw $t0, 0($t0)
	la $t2, B
	
	li $v0, 4
	la $a0, mes_B
	# print 'B:'
	syscall 
	jal print_Mat
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra
	

print_C:
	sub $sp, $sp, 4
	sw $ra, 0($sp)
	
	la $t0, Bc
	lw $t0, 0($t0)
	la $t1, Ar
	lw $t1, 0($t1)
	la $t2, C
	
	li $v0, 4
	la $a0, mes_C
	# print 'C:'
	syscall 
	jal print_Mat
	
	lw $ra, 0($sp)
	add $sp, $sp, 4
	
	jr $ra



print_Mat: 
	# printing the matrix starting in address $t2
	# $t1 is the Rows
	# $t0 is the Columns

	sub $sp, $sp, 4
	sw $t2, 0($sp)
	sub $sp, $sp, 4
	sw $t1, 0($sp)
	sub $sp, $sp, 4
	sw $t0, 0($sp)
	
	print_one_row:
		lw $a0, 0($t2)
		li $v0, 1
		syscall 
		# print the current value
		li $v0, 11
		li $a0, 9
		syscall 
		# print TAB
		addi $t2, $t2, 4 
		addi $t0, $t0, -1
		bne $t0, $zero, print_one_row
		
	lw $t0, 0($sp) # $t0 = Rows
	addi $sp, $sp, 4
	sub $sp, $sp, 4
	sw $t0, 0($sp)

	li $v0, 11
	li $a0, '\n'
	syscall # print new line 
	addi $t1, $t1, -1
	bne $t1, $zero, print_one_row
	
	lw $t0, 0($sp)
	add $sp, $sp, 4
	lw $t1, 0($sp)
	add $sp, $sp, 4
	lw $t2, 0($sp)
	add $sp, $sp, 4

	jr $ra # return

finish:

   
