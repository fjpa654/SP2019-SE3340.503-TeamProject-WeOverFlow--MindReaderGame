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
	
	
			#Closes the program
			############################################################
			.macro endGame
				li $v0,10
				syscall
			.end_macro	
			
			
			#Clears the flags for each card; Used for sequential games
			############################################################
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
			############################################################
			.macro Li_La_Sys (%eval, %argument)
				li $v0, %eval
				la $a0, %argument
				syscall
			.end_macro
			
			
			#Shortcut for receiving results from subroutines
			############################################################
			.macro	Branch_If_a0_Equal (%number, %label)
				beq $a0, %number, %label
			.end_macro		
			
			
			#Shortcut to clear specified registers
			############################################################
			.macro  Clear_Reg (%register)
				li %register, 0					# inizialize register with value of "0"
			.end_macro
			
			
			#Formula
			############################################################
			.macro Master_Formula(%register) 	# a($v1) = n + 2^r + 2^r [floor((n)/(2^r))]	
				loop:	
					jal formula
					addi 	%register, %register, 1
					move 	$t2, $v1		
					bgt	$v1, 9, noXtraSpc		# If the elements are <= 9, print an extra space to even the array out
					jal	printSpace
					
				noXtraSpc:
					move	$a0, $t2	
					li	$v0, 1				# Get ready to print an integer
					addi	$t0, $t0, 4			# Go to the next element in the array
					beq	$t0, 132, endFormula		# Has the index reach the end of the array? if true stop loop and go to end
					syscall					# Print integer in $a0	
					
					jal 	printSpace
					bne 	$t1, $t0, skip 			
					jal 	printLine			# PrintLine
				skip:
					j 	loop
					
				formula:	# a($v1) = n + 2^r + 2^r [floor((n)/(2^r))			
					move	$a1, %register
					mtc1 	$a1, $f0 			# Index
					cvt.s.w $f0, $f0 			# Index double		
					li 	$a2, 0				# Clear register
					lw 	$a2, randInt($zero)		# "r"
					li	$t2, 2				# $t2 = base
					li	$t4, 2				# $t4 = 2^1
					li	$t3, 1				# Flag for powers of two if $a2 is not 1 nor 0
					beq	$a2, 0, setToOne		# if $a2 is 0, set $t4 to 1 and go to continue
					beq	$a2, 1, continue		# if $a2 is 1, $t4 stays as 2 and go to continue
	
				power:	# 2 ^ "r"($a2)
					multu 	$t4, $t2			# $t4 * 2 = mflo 
					mflo 	$t4				# $t4 = mflo
					addi 	$t3, $t3, 1 			# add 1 to $t3
					bne  	$a2, $t3, power			# if $t3 ! = $a2(randomInt "r")
					
				continue:	
					mtc1 	$t4, $f1			# $t4(2^r) copy to coprocessor 1
					cvt.s.w $f1, $f1			# (2^r) is a float
					div.s 	$f12, $f0, $f1 			# (n)/(2^r) = ($a1)/($t4)
					floor.w.s $f12, $f12			# floor[(n)/(2^r)] = floor[($a1)/($t4)]
					mfc1 	$t5, $f12			# $t5 = floor[($a1)/($t4)] is int
					mul 	$t5, $t4, $t5			# $t5 = (2^r) * floor[($a1)/($t4)]
					add 	$a1, $a1, $t4			# $a1 = n + (2^r)					
					add 	$v1, $a1, $t5
					jr 	$ra	
											
				setToOne:
					li	$t4, 1
					j continue
					
				endFormula:
			.end_macro
