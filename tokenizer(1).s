
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
content:                .space 2049     # Maximun size of input_file + NULL


# You can add your data here!
punctuations: 		 .byte ',', '.', '!', '?'
tokens : 		 .space 4198401 # Maximum size of tokens matrix


        
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
	
	addi $t0, $0, 0			# iterating on content array
	addi $t3, $0, 0			# verifying if punctuation
	addi $t4, $0, 0			# iterating on tokens
	la $s0, punctuations
	la $s1, tokens
	
# $t1 and $t2 are flags to see if the read char changes from punctuation to alphabetic or vice versa
# s2 holds the current char from content array

verify_char: 
	addi $t2, $t1, 0
	lb $s2, content($t0)
	lb $t3, 0($s0)
	beq $s2, $t3, punctuation
	lb $t3, 1($s0)
	beq $s2, $t3, punctuation
	lb $t3, 2($s0)
	beq $s2, $t3, punctuation
	lb $t3, 3($s0)
	beq $s2, $t3, punctuation
	
alphabetic:
	addi $t1, $0, 1
	beq $s2, 32, new_line
	bne $t1, $t2, new_line
	j print

punctuation:
	addi $t1, $0, 0
	beq $s2, 32, new_line
	bne $t1, $t2, new_line
	j print
	
new_line:
	addi $t5, $0, 1
	#bnez $t5, iterate
	la $v0, 4
	la $a0, newline
	syscall
	
print:
	la $v0, 11
	lb $a0, content($t0)	

iterate:
	addi $t0, $t0, 1
	beq $a0, 32, verify_char
	syscall
	beq $t0, 2049, main_end
	j verify_char
	
store:
	
        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
