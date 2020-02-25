.include		"Mind_Reader-Algebraic_MACROS-WeOverFlow.asm"
.include		"midiLibrary.asm"
.data
	clearScreen:	.asciiz		"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	instructions:	.asciiz		"\nThink about a WHOLE NUMBER LESS OR EQUAL THAN 63, and answer the questions.\n Are you ready?\n"
	askUser:	.asciiz 	"\nIs your number shown in the last set of numbers? \n"	
	yourNumber:	.asciiz		"\nYour number is: "
	playAgain:	.asciiz		"\nWant to play again?\n "
	space:		.asciiz		" "
	newLine:	.asciiz		"\n"				
	cardFlag: 	.word		0,0,0,0,0,0			
	randInt:	.word		0
	result:		.word 		0
			
.text
main:	
	li $v0, 4			# to print string
	la $a0, clearScreen		# fill the screen with new lines 
	syscall
	
	Clear_Reg($a0)			# set $a0 = 0
	Li_La_Sys (50, instructions)	# Prompts user to begin game	
	Branch_If_a0_Equal (1, main)	# If Yes, Proceed with game
	Branch_If_a0_Equal (2, end)	# If No, Loop back to main
	Branch_If_a0_Equal (-1, end)	# If exit, Close game	
	intro_Song(82)			# Begins intro song		
	Clear_Reg ($t8)			# set $t8 = 0 counter 
	Clear_Reg ($s7) 		# set $t7 = 0
	Clear_All_Flags			# set all flags = 0
random:	
	# random integer from 0 - 5
	li	$a1, 6			# Loads Upper bound for Random Int Generation
	li	$v0, 42			# Prompts system to generate random integer
	syscall	
	
	sw	$a0, randInt($zero)	# Store random integer	
	jal 	checkCard			# Check if random int has already been generated
	Clear_Reg ($s6)			# Set $t6 = 0 to input checkCard result
	move	$s6, $v0		# Hold the value of the card in saved register $s6		
	jal arrayElementCalculator	# Print the array
Question:	
	jal	printLine		# Jump to printLine
	Li_La_Sys (50, askUser)		# Initiates question dialog. ask user if number is in current card (last set of numbers)	
	Branch_If_a0_Equal (1, no)	# If user input no	
	Branch_If_a0_Equal (2, end)	# If user inputs cancel
	Branch_If_a0_Equal (-1, end)	# If user inputs "exit"
	Clear_Reg ($t7)			# set $t7 = 0	
	lw	$t7, result($zero)	# Load result
	add	$t7, $t7, $s6		# Acumulate result
	sw	$t7, result($zero)	# Save result in RAM	
	beq	$t8, 6, finalResult	# If count is 7 go to final result
	j random			# Jump to random
no:
	bne 	$t8, 6, random		# If total of cards displayed not equal to 6 go to random		
finalResult:
	li 	$v0, 56			# to output dialog box
	la 	$a0, yourNumber		# Prompt for the result on dialog box
	lw 	$a1, result($zero)	# Loads result into number space	
	syscall
	
	Li_La_Sys (50, playAgain)	# Asks user if they want to play again
	beq	$a0, 0, main		# Loop back to start
end:	
	endGame				# End program
#################################################################
arrayElementCalculator:	
	Clear_Reg ($t0)			# set $t0 = 0
	Clear_Reg ($t1)			# set $t1 = 0
	addi	$t1, $t1, 32		# End of row index counter
	li $t6, 0
	Master_Formula($t6)		# $t6 = whole number less than 6. Calculate card $t6 (number) 
	j Question			# go to question to ask the user if the last set of numbers(card #[$t6]) contains the number 
#################################################################
checkCard:
	lw 	$t7, randInt($zero)		# Get the random Int from RAM
	card0:
	bnez 	$t7, card1			# skip card 0		
	Card_Number_Evaluation (0, 1, random)	# if card 0 has been displayed, branch to "random" ; else display card.
		
	card1:						
	bgt 	$t7, 1, card2			# skip card 1
	Card_Number_Evaluation (4, 2, random)   # if card 1 has been displayed, branch to "random" ; else display card.
	
	card2:
	bgt 	$t7, 2, card3			# skip card 2
	Card_Number_Evaluation (8, 4, random)	# if card 2 has been displayed, branch to "random" ; else display card.
		
	card3:
	bgt 	$t7, 3, card4			# skip card 3
	Card_Number_Evaluation (12, 8, random)	# if card 3 has been displayed, branch to "random" ; else display card.
	
	card4:
	bgt 	$t7, 4, card5			# skip card 4
	Card_Number_Evaluation (16, 16, random) # if card 4 has been displayed, branch to "random" ; else display card.
	
	card5:	
	Card_Number_Evaluation (20, 32, done)	# if card 5 has been displayed, branch to "done" ; else display card.
done:
	j 	random				# Jumps to random	
#################################################################
printSpace:
		li	$v0, 4			# print a String 
		la	$a0, space		# print a string space			
		syscall				
		
		jr 	$ra			# jump back to called address		
#################################################################
printLine:
		li	$v0, 4			# print a String 
		la	$a0, newLine		# print a string new line "/n"
		
		syscall
		addi 	$t1, $t1, 32		# Add 32 to $t1
		jr 	$ra			# jump back to called address	
