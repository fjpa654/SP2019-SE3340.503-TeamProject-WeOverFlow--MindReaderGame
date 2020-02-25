			# Evaluates if the card has been shown 
			# Also records cards that user has confirmed has their number
			############################################################
			.macro Card_Number_Evaluation (%cardOffSet, %aNumber, %label)		
				la   $a3, cardFlag		# load the address cardFlag into $a3
				lw   $s0, %cardOffSet($a3)	# the flag of this card is load into $s0
				beq  $s0, %aNumber, %label	# if $s0 = to value "%aNumber", this value has been evaluated already, so branch to the label
				li   $s0, %aNumber		# load "%aNumber" into $s0
				sw   $s0, %cardOffSet($a3)	# store the value of $s0 into the respective card flag
				li   $v0, %aNumber		# load "%aNumber" into $v0. It could be needed for total result (we have not displayed the card to the user yet!)
				move $t9, $ra			# safe link address into $t9
				addi $t8, $t8, 1		# add 1 to counter
				move $ra, $t9			# move back address to %ra
				jr   $ra			# go back
			.end_macro	
	
			# Closes the program
			############################################################
			.macro endGame
					li 	$v0,10
					syscall
			.end_macro				
			
			# Clears the flags for each card; Used for sequential games
			############################################################
			.macro Clear_All_Flags
					sw 	$zero , cardFlag($zero)	
					sw 	$zero , cardFlag+4($zero)	
					sw 	$zero , cardFlag+8($zero)	
					sw 	$zero , cardFlag+12($zero)	
					sw 	$zero , cardFlag+16($zero)	
					sw 	$zero , cardFlag+20($zero)	
					sw 	$zero , result($zero)
			.end_macro			
			
			#Shortcut for syscalls
			############################################################
			.macro Li_La_Sys (%eval, %argument)
					li 	$v0, %eval
					la 	$a0, %argument
					syscall
			.end_macro			
			
			# Shortcut for receiving results from subroutines
			############################################################
			.macro	Branch_If_a0_Equal (%number, %label)
					beq 	$a0, %number, %label
			.end_macro					
			
			# Shortcut to clear specified registers
			############################################################
			.macro  Clear_Reg (%register)
					li 	%register, 0				# inizialize register with value of "0"
			.end_macro
			
			# Formula
			############################################################
			.macro Master_Formula(%register) 					
					li 	$t0, 0					# Clear $t0 
					li 	$t2, 0					# Clear $t2
					li 	$t3, 0					# $t3 = counter					
					addi 	$t1, $zero, 1				# save $t1  as 1 to maniputlate 
					sllv 	$t1, $t1, %register			# Register contains random number(0~5). Shift $t1 with amount of random number.
				loop:
					or	$t2, $t0, $t1				# $t2 = $t0(0) OR $t1(random)
					bge  	$t2, 64, Question			# last number of the card has been printed, go to ask question.
					addi 	$t3, $t3, 1				# counter "$t3" ++
					li 	$v0, 1					# print integer
					la 	$a0, ($t2)				# print $t2 
					syscall

					beq 	$t3, 8, Line				# brach to "Newline" to print newline after 8 elements 
					jal 	printSpace				# print " "
				adding:
					add 	$t2, $t2, 1				# $t2+1
					move 	$t0, $t2				# move $t2+1 into $t0,
					j 	loop					# go loop again 				
				Line: 
					jal 	printLine				# "\n"
					j 	adding					# Jump to adding 
			.end_macro
