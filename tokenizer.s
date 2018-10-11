
#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
punctuations:		 .byte ',', '.', '!', '?'  #Valid punctuation marks
tokens: 		 .space 4198401		   # tokens matrix
#tokens_number: 		 .word 0 	 #Number of tokens in input file
content:                .space 2049     # Maximun size of input_file + NULL

# You can add your data here!
        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
        
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  content($t0)

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------



# You can add your code here!

	la $a1, content
	la $a2, punctuations
	li $s1, 0 			# initial tokens number
	j tokenizer
	
	
output_tokens: 
	bnez $t0, print
	li $v0, 11
	syscall
	la $t3, ($t4)
	j verify_char

print: 
	bne $t3, $t4, new_line
	li $v0, 11
	syscall
	j verify_char
	
new_line:
	la $t3, ($t4)
	la $t6, 0($a0)
	la $a0, newline
	li $v0, 11
	syscall
	la $a0, 0($t6)
	syscall	
	j verify_char		
	
	
	
tokenizer:
	li $t0, 0
	
	
verify_char:
	li $t4, 0
	lb $a0, content($t0)
	beq $a0, '\0', main_end
	lb $t5, 0($a2)
	beq $a0, $t5, punctuation
	lb $t5, 1($a2)
	beq $a0, $t5, punctuation
	lb $t5, 2($a2)
	beq $a0, $t5, punctuation
	lb $t5, 3($a2)
	beq $a0, $t5, punctuation
flag:	li $t4, 1
	
alphabetic:
	addi $t0, $zero, 1
	j output_tokens
	
	

punctuation: 
	addi $t0, $zero, 1
	j output_tokens
	
	


        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
