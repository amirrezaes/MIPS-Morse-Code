# a2-morse-encode.asm
#
# For UVic CSC 230, Spring 2022
#
# Original file copyright: Mike Zastre, Amirreza Esmaeili
#

.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	#jal save_our_souls

	## flash_one_symbol test for part B
	#addi $a0, $zero, 0x37   # dot dot dash dot
	#jal flash_one_symbol
	
	## flash_one_symbol test for part B
	# addi $a0, $zero, 0x37   # dash dash dash
	# jal flash_one_symbol
		
	## flash_one_symbol test for part B
	# addi $a0, $zero, 0x32  	# dot dash dot
	# jal flash_one_symbol
			
	## flash_one_symbol test for part B
	# addi $a0, $zero, 0x11   # dash
	# jal flash_one_symbol	
	
	# display_message test for part C
	#la $a0, test_buffer
	#jal display_message
	
	# char_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	#addi $a0, $zero, 'P'
	#jal char_to_code
	
	# char_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	#addi $a0, $zero, 'A'
	#jal char_to_code
	
	# char_to_code test for part D
	# the space' is properly encoded as 0xff
	#addi $a0, $zero, ' '
	#jal char_to_code
	
	# encode_text test for part E
	# The outcome of the procedure is here
	# immediately used by display_message
	la $a0, long_message
	la $a1, buffer01
	jal encode_text
	la $a0, buffer01
	jal display_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall


dot:				# simulates a dot signal
        addi $sp,$sp,-4	# open stack space for one word
        sw   $ra,0($sp)	# pushe $31 content to stack
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	lw   $ra,0($sp)		# load previous jump address from stack
	addi $sp,$sp,4		# shrink stack
	jr $ra
dash:				# simulates a dash signal
        addi $sp,$sp,-4	# open stack space for one word
        sw   $ra,0($sp)	# pushe $31 content to stack
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	lw   $ra,0($sp)		# load previous jump address from stack
	addi $sp,$sp,4		# shrink stack
	jr $ra

exit:	# all exit labels reffer to this
	lw   $ra,0($sp)		# load previous jump address from stack
	addi $sp,$sp,4		# shrink stack
	jr   $ra

###########
# PROCEDURE
save_our_souls:
	addi $sp,$sp,-4		# open stack space for one word
	sw   $ra,0($sp)		# pushe $31 content to stack
	jal dot			# S.O.S in morse
	jal dot
	jal dot
	jal dash
	jal dash
	jal dash
	jal dot
	jal dot
	jal dot
	b   exit


# PROCEDURE
flash_one_symbol:
	addi $sp,$sp,-4		# open stack space for one word
	sw   $ra,0($sp)		# pushe $31 content to stack
	beq  $a0, 0xff, edgecase # edge case
	srl  $t3, $a0, 4	# upper half of the input word
	la   $ra, reverseRead	# base address of the loop
	la   $t5, ($sp)		# base stack pointer adress
stackup:
	beq  $t3, $zero, reverseRead	# if stacking done, reload from stack in reverse order
	add  $t3, $t3, -1	# one number in sequence will be consumed
	andi $t4, $a0, 1	# getting the right-most bit
	srl  $a0, $a0, 1	# shifting sequence to right so we can get the next number
	addi $sp,$sp,-4		# open stack space for one word
	sw   $t4,0($sp)		# pushe $t4 content to stack
	b stackup

reverseRead:
	beq  $sp, $t5, exit	# if stack shrinks back to base point then exit
	lw   $t4,0($sp)		# load digit from stack
	addi $sp,$sp,4		# shrink stack
	beq  $t4, 1, dash	# if right most digit is 1 then call dash func
	b    dot		# else call dot

edgecase:
	jal delay_long
	jal delay_long
	jal delay_long
	b exit

###########
# PROCEDURE
display_message:
	addi $sp,$sp,-4		# open stack space for one word
	sw   $ra,0($sp)		# pushe $31 content to stack
	la   $t6, ($a0)		# storing address in $t6  so we can use $a0

read:
	lbu  $a0, 0($t6)	# reading the byte that will be presented
	beqz $a0, exit		# exit if arg is null
	jal  flash_one_symbol	# call fucntion
	addi $t6, $t6, 1	# now $t6 points to next byte
	jal  delay_long		# 600ms delay between each letter
	b    read		# loop back
	
	
###########
# PROCEDURE
char_to_code:
	la   $s0, codes		# points to the beginning of array
	beq  $a0, ' ', space	# if input is space
	addi $t0, $a0, -65	# the distance between input letter and 'A'
	li   $t2, 8		# lenght of each element
	mult $t0, $t2		# the differnce of char with 'A' on mem, result is an 8 bit number 
	mflo $t0
	add  $t0, $t0, $s0	# the address of the char on mem
	addi $t0, $t0, 1	# skipping first element
	add  $t2, $zero, $zero # the lower half of the result
	add  $t3, $zero, $zero # the higher half of the result


encode_char:
	lb   $t4, ($t0)		# loading a byte from address
	beqz $t4, return	# if we hit a zero then go for adjusting low and then returning
	add  $t5, $zero, $zero	# dash or dot indicator
	slti $t5, $t4, '.'	# if $t4 is dash then set $t4, based on ascii order of dash and dot
	sll  $t2, $t2, 1	# adjusting lower half
	add  $t2, $t2, $t5	# incrementing lower half
	addi $t3, $t3, 16	# incrementing & adusting upper half
	addi $t0, $t0, 1	# decrementing address by 1 byte
	b encode_char		# loop back
	
space:
	addiu $v0, $zero, 0xff
	jr    $ra
	
return:
	add  $v0, $t2, $t3	# write return value
	jr   $ra
	


###########
# PROCEDURE
encode_text:
	addi $sp,$sp,-4		# open stack space for one word
	sw   $ra,0($sp)		# pushe $31 content to stack
	la   $t7, ($a0)		# getting rid of $a0
write_text:
	lb   $t0, ($t7)		# getting a byte
	beqz $t0, custom_exit	# if its zero then exit
	add  $a0, $t0, $zero	# setting function arg
	jal  char_to_code	# calling func
	sb   $v0, ($a1)		# writing in buffer
	add  $a1, $a1, 1	# incrementing the buffer
	add  $t7, $t7, 1	# incrementing the mem address
	b write_text		# loop back

custom_exit:
	add  $a0, $zero, $zero	# setting the null terminator
	jal  char_to_code	# calling func
	sb   $v0, ($a1)		# writing in buffer
	lw   $ra,0($sp)		# load previous jump address from stack
	addi $sp,$sp,4		# shrink stack
	jr   $ra

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "A A A"
message02:	.asciiz "SOS"
message03:	.asciiz "WATERLOO"
message04:	.asciiz "DANCING QUEEN"
message05:	.asciiz "CHIQUITITA"
message06:	.asciiz "THE WINNER TAKES IT ALL"
message07:	.asciiz "MAMMA MIA"
message08:	.asciiz "TAKE A CHANCE ON ME"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x00    # This is SOS
long_message:   .ascii "GUILT IS LIKE A BAG OF FUCKIN BRICKS ALL YA GOTTA DO IS SET IT DOWN"