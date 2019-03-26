.data
	instructions:	.asciiz		"\nThink about a WHOLE NUMBER LESS OR EQUAL THAN 63, and answer the questions.\n Are you ready?\n"
	askUser:	.asciiz 	"\nIs your number shown in the last array? \n"	
	yourNumber:	.asciiz		"\nYour number is: "
	playAgain:	.asciiz		"\nWant to play again?\n "
	space:		.asciiz		" "
	newLine:	.asciiz		"\n"	
	
	baseArray:	.word		00, 01, 02, 03, 04, 05, 06, 07
			.word		08, 09, 10, 11, 12, 13, 14, 15
			.word		16, 17, 18, 19, 20, 21, 22, 23
			.word		24, 25, 26, 27, 28, 29, 30, 31	
			
	cardFlag: 	.word		0,0,0,0,0,0			
	rowLimit:	.word		32
	randInt:	.word		0
	result:		.word 		0
	
	
			.macro count
			addi $t8, $t8, 1
			.end_macro
	
			.macro endGame
				li $v0,10
				syscall
			.end_macro	
			
			.macro Clear_All_Flags
				sw $zero , cardFlag($zero)	
				sw $zero , cardFlag+4($zero)	
				sw $zero , cardFlag+8($zero)	
				sw $zero , cardFlag+12($zero)	
				sw $zero , cardFlag+16($zero)	
				sw $zero , cardFlag+20($zero)	
				sw $zero , result($zero)
			.end_macro
			
			.macro Li_La_Sys (%eval, %argument)
				li $v0, %eval
				la $a0, %argument
				syscall
			.end_macro
			
			.macro	Branch_If_a0_Equal (%number, %label)
				beq $a0, %number, %label
			.end_macro
			
			.macro	Branch_If_Equal (%number, %label)
				beq $s0, %number, %label
			.end_macro
			
			.macro	Branch_If_Equal (%register, %number, %label)
				beq %register, %number, %label
			.end_macro			
			
			.macro Load_Imm (%register)
				li %register, 0
			.end_macro
			
			.macro Load_Imm (%register, %value)
				li %register, %value
			.end_macro
.text
main:
	Li_La_Sys (50, instructions)
	
	Branch_If_a0_Equal (1, main)
	Branch_If_a0_Equal (2, end)	
	
	Load_Imm ($t8)		# clearing register
	Load_Imm ($s7) 		# clearing register
	Clear_All_Flags
random:	
	#random integer from 0 - 5
	Load_Imm ($a1, 6)
	Load_Imm ($v0, 42)
	syscall
	
	move $t7, $a0			# copy random int
	sw $t7, randInt($zero)		# store random integer
	
	jal checkCard			# Check if random int has already been generated
	Load_Imm ($s6)			# clear s6 to input checkCard result
	move $s6, $v0			# hold the value of the card in saved register	
	
	jal arrayElementCalculator	# print the array
Question:	
	jal printLine
	Li_La_Sys (50, askUser)
	
	Branch_If_a0_Equal (1, no)	# if user input no	
	Branch_If_a0_Equal (2, end)	# if user inputs cancel
	Load_Imm ($t7)			# clear for result	
	lw $t7, result($zero)		# load result
	add  $t7, $t7, $s6		# acumulate result
	sw $t7, result($zero)		# save result in RAM
	
	Branch_If_Equal ($t8, 6, finalResult)	# if count is 7 go to final result
	j random
no:
	bne $t8, 6, random		# if total of cards displayed not equal to 6 go to random
		
finalResult:
	Load_Imm ($v0, 56)
	la $a0, yourNumber
	lw $a1, result($zero)
	syscall
	
	Li_La_Sys (50, playAgain)
	Branch_If_Equal ($a0, 0, main)
end:	
	endGame		# end program
#################################################################
arrayElementCalculator:	
	Load_Imm ($t0)	# $t0 clear
	Load_Imm ($t1)
	addi  $t1, $t1, 32	# end of row index counter
loop:	
	lw $a1, baseArray($t0)	# place first address value into $a0 (get ready to print)	
	jal formula
	move $t2, $v1		
	bgt  $v1, 9, noXtraSpc	# if the elements are <= 9, print an extra space to even the array out
	jal printSpace
noXtraSpc:
	move $a0, $t2	
	Load_Imm ($v0, 1)			# get ready to print an integer
	addi $t0, $t0, 4			# go to the next element in the array
	Branch_If_Equal ($t0, 132, Question)	# has the index reach the end of the array? if true stop loop and go to end
	syscall					# print integer in $a0	
	jal printSpace
	bne $t1, $t0, skip 			
	jal printLine				# printLine
skip:
	j loop					# go to loop label
################################################################################
formula: # a($v1) = n + 2^r + 2^r [floor((n)/(2^r))]		
	mtc1 $a1, $f0 		#index
	cvt.s.w $f0, $f0 	#index double		
	Load_Imm ($a2)		# clear register
	lw $a2, randInt($zero)	# "r"
	Load_Imm ($t2, 2)	# $t2 = base
	Load_Imm ($t4, 2)	# $t4 = 2^1
	Load_Imm ($t3, 1)	# flag for powers of two if $a2 is not 1 nor 0
	Branch_If_Equal ($a2, 0, setToOne)	# if $a2 is 0, set $t4 to 1 and go to continue
	Branch_If_Equal ($a2, 1, continue)	# if $a2 is 1, $t4 stays as 2 and go to continue
power:	# 2 ^ "r"($a2)
	multu $t4, $t2		# $t4 * 2 = mflo 
	mflo $t4		# $t4 = mflo
	addi $t3, $t3, 1 	# add 1 to $t3
	bne  $a2, $t3, power	# if $t3 ! = $a2(randomInt "r")
continue:	
	mtc1 $t4, $f1		# $t4(2^r) copy to coprocessor 1
	cvt.s.w $f1, $f1	# (2^r) is a float
	div.s $f12, $f0, $f1 	# (n)/(2^r) = ($a1)/($t4)
	floor.w.s $f12, $f12	# floor[(n)/(2^r)] = floor[($a1)/($t4)]
	mfc1 $t5, $f12		# $t5 = floor[($a1)/($t4)] is int
	mul $t5, $t4, $t5	# $t5 = (2^r) * floor[($a1)/($t4)]
	add $a1, $a1, $t4	# $a1 = n + (2^r)
	add $v1, $a1, $t5	# $v1 = {n + (2^r)} + {(2^r) * floor[($a1)/($t4)]}			
	jr $ra
########################################
checkCard:
	Load_Imm ($t7)			# clear this register
	Load_Imm ($s0)			# clear this register
	lw $t7, randInt($zero)		# get the random Int
	
	bnez $t7, card1			# next card if not zero, not allowed through get zero
	lw $s0 , cardFlag($zero)
	Branch_If_Equal (1, random)	# next card if s0 1, gate is close
	Load_Imm ($s0, 1)		# close gate, s0 conatins value of 1
	sw $s0, cardFlag($zero)
	Load_Imm ($v0, 1)		#store result
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
	
	card1:
	bgt $t7, 1, card2		# next card if is not 1 not allowed through gate 1
	lw $s0 , cardFlag+4($zero)
	Branch_If_Equal (2, random)		# next card if s1 = 2, gate is close
	Load_Imm ($s0, 2)			# close gate, s1 contains the value of 2
	sw $s0, cardFlag+4($zero)
	Load_Imm ($v0, 2)
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
	
	card2:
	bgt $t7, 2, card3
	lw $s0 , cardFlag+8($zero)
	Branch_If_Equal (4, random)
	Load_Imm ($s0, 4) 	# card 2
	sw $s0 , cardFlag+8($zero)
	Load_Imm ($v0, 4)
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
	
	card3:
	bgt $t7, 3, card4
	lw $s0 , cardFlag+12($zero)
	Branch_If_Equal (8, random)
	Load_Imm ($s0, 8)	# card 3
	sw $s0 , cardFlag+12($zero)
	Load_Imm ($v0, 8)
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
	
	card4:
	bgt $t7, 4, card5
	lw $s0 , cardFlag+16($zero)
	Branch_If_Equal (16, random)
	Load_Imm ($s0, 16)	# card 4
	sw $s0 , cardFlag+16($zero)
	Load_Imm ($v0, 16)
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
	
	card5:
	lw $s0 , cardFlag+20($zero)
	Branch_If_Equal (32, done)
	addi $s7, $s7, 1
	Load_Imm ($s0, 32)	# card 5
	sw $s0 , cardFlag+20($zero)
	Load_Imm ($v0, 32)
	move $t9, $ra
	count
	move $ra, $t9 
	jr $ra
done:
	j random
	
##########################################################
printSpace:
	Li_La_Sys (4, space)	# print space
	#syscall		# print space
	jr $ra	
##########################################################
printLine:
	Li_La_Sys (4, newLine) 	# print a line
	addi $t1, $t1, 32	# add 32 to $t1
	jr $ra			# go back
###########################################################
setToOne:
	Load_Imm ($t4, 1)
	j continue	