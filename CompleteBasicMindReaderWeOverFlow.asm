.include		"MacrosWOF420.asm"
.data
	clearScreen:	.asciiz		 "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	instructions:	.asciiz		"\nThink about a WHOLE NUMBER LESS OR EQUAL THAN 63, and answer the questions.\n Are you ready?\n"
	askUser:	.asciiz 	"\nIs your number shown in the last array? \n"	
	yourNumber:	.asciiz		"\nYour number is: "
	playAgain:	.asciiz		"\nWant to play again?\n "
	space:		.asciiz		" "
	newLine:	.asciiz		"\n"				
	cardFlag: 	.word		0,0,0,0,0,0			
	randInt:	.word		0
	result:		.word 		0
			
.text
main:
	
	li $v0, 4
	la $a0, clearScreen
	syscall
	
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
	lw $a1, result($zero)	# Loads result into number space
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
	li $t6, 0
	Master_Formula($t6)
	j Question
########################################
checkCard:
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
		li	$v0, 4
		la	$a0, space
					
		syscall					# Print space
		jr 	$ra	
##########################################################
printLine:
		li	$v0, 4
		la	$a0, newLine
		
		syscall
		addi 	$t1, $t1, 32			# Add 32 to $t1
		jr 	$ra				# Go back	
