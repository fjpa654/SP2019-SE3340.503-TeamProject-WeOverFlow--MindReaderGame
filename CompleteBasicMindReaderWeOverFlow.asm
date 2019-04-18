.data
	clearScrean:	.asciiz 	"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
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
	
			#Evaluates if the card has been shown 
			#Also records cards that user has confirmed has their number
			############################################################
			.macro Card_Number_Evaluation (%cardOffSet, %aNumber, %label)		
				la   $a3, cardFlag
				lw   $s0, %cardOffSet($a3)
				beq  $s0, %aNumber, %label
				li   $s0, %aNumber
				sw   $s0, %cardOffSet($a3)
				li   $v0, %aNumber
				move $t9, $ra
				addi $t8, $t8, 1
				move $ra, $t9
				jr   $ra
			.end_macro
			
			
			#Counts how many times a card has been evaluated; Should only be evaluated once
			###############################################################################
			.macro count			
			addi $t8, $t8, 1
			.end_macro
	
			#Closes the program
			###################
			.macro endGame
				li $v0,10
				syscall
			.end_macro	
			
			#Clears the flags for each card; Used for sequential games
			##########################################################
			.macro Clear_All_Flags
				sw $zero , cardFlag($zero)	
				sw $zero , cardFlag+4($zero)	
				sw $zero , cardFlag+8($zero)	
				sw $zero , cardFlag+12($zero)	
				sw $zero , cardFlag+16($zero)	
				sw $zero , cardFlag+20($zero)	
				sw $zero , result($zero)
			.end_macro
			
			#Shortcut for syscalls
			######################
			.macro Li_La_Sys (%eval, %argument)
				li $v0, %eval
				la $a0, %argument
				syscall
			.end_macro
			
			#Shortcut for receiving results from subroutines
			################################################
			.macro	Branch_If_a0_Equal (%number, %label)
				beq $a0, %number, %label
			.end_macro		
			
			#Shortcut to clear specified registers
			######################################
			.macro  Clear_Reg (%register)
				li %register, 0
			.end_macro
			
.text
main:
	Clear_Reg($a0)
	Li_La_Sys (50, instructions)	# Prompts user to begin game
	
	Branch_If_a0_Equal (1, main)	# If Yes, Proceed with game
	Branch_If_a0_Equal (2, end)	# If No, Loop back to main
	Branch_If_a0_Equal (-1, end)	# If exit, Close game
	
	Clear_Reg ($t8)			# Clearing register
	Clear_Reg ($s7) 		# Clearing register
	Clear_All_Flags			# Clears all flags
random:	
	#random integer from 0 - 5
	li	$a1, 6			# Loads Upper bound for Random Int Generation
	li	$v0, 42			# Prompts system to generate random integer
	syscall
	
	
	sw	$a0, randInt($zero)	# Store random integer
	
	jal checkCard			# Check if random int has already been generated
	Clear_Reg ($s6)			# Clear s6 to input checkCard result
	move	$s6, $v0		# Hold the value of the card in saved register	
	
	jal arrayElementCalculator	# Print the array
Question:	
	jal	printLine			# Jump to printLine
	Li_La_Sys (50, askUser)		# Initiates question dialog
	
	Branch_If_a0_Equal (1, no)	# If user input no	
	Branch_If_a0_Equal (2, end)	# If user inputs cancel
	Clear_Reg ($t7)			# Clear for result	
	lw	$t7, result($zero)	# Load result
	add	$t7, $t7, $s6		# Acumulate result
	sw	$t7, result($zero)	# Save result in RAM
	
	beq	$t8, 6, finalResult	# If count is 7 go to final result
	j random			# Jump to random
no:
	bne 	$t8, 6, random		# If total of cards displayed not equal to 6 go to random
		
finalResult:
	li $v0, 56
	la $a0, yourNumber	# Presents result dialog
	lw 	$a1, result($zero)	# Loads result into number space
	syscall
	
	li $v0, 4
	la $a0, clearForNewgame
	syscall 
	
	Li_La_Sys (50, playAgain)	# Asks user if they want to play again
	beq	$a0, 0, main		# Loop back to start
end:	
	endGame				# End program
#################################################################
arrayElementCalculator:	
	Clear_Reg ($t0)				# $t0 clear
	Clear_Reg ($t1)
	addi	$t1, $t1, 32			# End of row index counter
loop:	
	lw	$a1, baseArray($t0)			# Place first address value into $a0 (get ready to print)	
	jal formula
	move 	$t2, $v1		
	bgt	$v1, 9, noXtraSpc			# If the elements are <= 9, print an extra space to even the array out
	jal	printSpace
noXtraSpc:
	move	$a0, $t2	
	li	$v0, 1				# Get ready to print an integer
	addi	$t0, $t0, 4			# Go to the next element in the array
	beq	$t0, 132, Question		# Has the index reach the end of the array? if true stop loop and go to end
	syscall					# Print integer in $a0	
	jal 	printSpace
	bne 	$t1, $t0, skip 			
	jal printLine				# PrintLine
skip:
	j 	loop					# Go to loop label
################################################################################
formula: # a($v1) = n + 2^r + 2^r [floor((n)/(2^r))]		
	mtc1 	$a1, $f0 				# Index
	cvt.s.w $f0, $f0 			# Index double		
	Clear_Reg ($a2)				# Clear register
	lw 	$a2, randInt($zero)			# "r"
	li	$t2, 2				# $t2 = base
	li	$t4, 2				# $t4 = 2^1
	li	$t3, 1				# Flag for powers of two if $a2 is not 1 nor 0
	beq	$a2, 0, setToOne		# if $a2 is 0, set $t4 to 1 and go to continue
	beq	$a2, 1, continue		# if $a2 is 1, $t4 stays as 2 and go to continue
power:	# 2 ^ "r"($a2)
	multu 	$t4, $t2				# $t4 * 2 = mflo 
	mflo 	$t4				# $t4 = mflo
	addi 	$t3, $t3, 1 			# add 1 to $t3
	bne  	$a2, $t3, power			# if $t3 ! = $a2(randomInt "r")
continue:	
	mtc1 	$t4, $f1				# $t4(2^r) copy to coprocessor 1
	cvt.s.w $f1, $f1			# (2^r) is a float
	div.s 	$f12, $f0, $f1 			# (n)/(2^r) = ($a1)/($t4)
	floor.w.s $f12, $f12			# floor[(n)/(2^r)] = floor[($a1)/($t4)]
	mfc1 	$t5, $f12				# $t5 = floor[($a1)/($t4)] is int
	mul 	$t5, $t4, $t5			# $t5 = (2^r) * floor[($a1)/($t4)]
	add 	$a1, $a1, $t4			# $a1 = n + (2^r)
	add 	$v1, $a1, $t5			# $v1 = {n + (2^r)} + {(2^r) * floor[($a1)/($t4)]}			
	jr 	$ra
########################################
checkCard:
	#Clear_Reg ($t7)				# Clear this register
	#Clear_Reg ($s0)				# Clear this register
	lw 	$t7, randInt($zero)			# Get the random Int
	bnez $t7, card1	
	# card 0
	Card_Number_Evaluation (0, 1, random)
		
	card1:
	bgt 	$t7, 1, card2			# Next card if is not 1 not allowed through gate 1
	Card_Number_Evaluation (4, 2, random)   #***Needs documentation*** 
	
	card2:
	bgt 	$t7, 2, card3
	Card_Number_Evaluation (8, 4, random)
		
	card3:
	bgt 	$t7, 3, card4
	Card_Number_Evaluation (12, 8, random)
	
	card4:
	bgt 	$t7, 4, card5
	Card_Number_Evaluation (16, 16, random)
	
	card5:
	Card_Number_Evaluation (20, 32, done)
done:
	j 	random				# Jumps to random
	
##########################################################
printSpace:
	Li_La_Sys (4, space)			# Print space
	#syscall				# Print space
	jr 	$ra	
##########################################################
printLine:
	Li_La_Sys (4, newLine) 			# Print a line
	addi 	$t1, $t1, 32			# Add 32 to $t1
	jr 	$ra					# Go back
###########################################################
setToOne:
	li	$t4, 1
	j continue
