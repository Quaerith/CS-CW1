
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
content:                .space 2049                # Maximun size of input_file + NULL


# You can add your data here!
punctuations:          .byte ',', '.', '!', '?'    # Stores the possible punctuation marks as bytes



        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text


#=========================================================================
# MACROS
#=========================================================================

macros: 

# prints a space on a new line

  .macro printsln()
    la   $v0, 4
    la   $a0, newline
    syscall
    la   $v0, 11
    addi $a0, $0, 32
    syscall
  .end_macro
  
# prints a space

  .macro prints()
    la   $v0, 11
    addi $a0, $0, 32
    syscall
  .end_macro

# prints a newline
    
  .macro println()
    la $v0, 4
    la $a0, newline
    syscall
  .end_macro
  
# prints n spaces on a newline

  .macro printsnln()
    beqz $t5, continue
    println()
    loop:
    prints()
    addi $t5, $t5, -1
    beqz $t5, end
    j loop
    end: println()
  .end_macro
  


#=========================================================================
# END_MACROS
#=========================================================================



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
    
    addi $t0, $0, 0                                   # will be used as a counter for iterating on content array
    addi $t3, $0, 0                                   # will be used for storing each byte in the punctuation array
    addi $t4, $0, 0                                   # iterating on tokens
    la   $s0, punctuations                            # store punctuations array address in $s0
    la   $s1, tokens                                  # store tokens array
    addi $s3, $0, 0                                   # store null character
    
    
# $t1 and $t2 are flags to see if the read char changes from punctuation to alphabetic or vice versa
# $t1 holds the code for the current character

    j verify_char

reset_space: 
    printsnln()
    addi $t5, $0, 0                                   # reseting the space counter
    j continue                                                   

# check the type of character (alphabetic, punctuation, space or null)

verify_char: 
    addi $t2, $t1, 0                                  # update the code stored in $t2        
    lb   $s2, content($t0)                            # s2 holds the current char from content array
    beq  $s2, $s3, main_end                           # check if you reached the end of the content array
    bne  $s2, 32, reset_space                         # check that the current character is not a space
                                                      # if so, reset the space counter

# compare the current character with the punctuation marks (stored in the first 4 bytes of $s0)
# if so, jump to the punctuation label
# otherwise, continue to the alphabetic label

continue:
    lb   $t3, 0($s0)
    beq  $s2, $t3, punctuation
    lb   $t3, 1($s0)
    beq  $s2, $t3, punctuation
    lb   $t3, 2($s0)
    beq  $s2, $t3, punctuation
    lb   $t3, 3($s0)
    beq  $s2, $t3, punctuation


alphabetic:
    addi $t1, $0, 1                                   # the code for an alphabetic character is 1                                   
    beq  $s2, 32, space                               # jump to the space label if the current character is a space
    bne  $t1, $t2, new_line                           # jump to the new_line label if the preceding character was a punctuation mark
    j print                                           # otherwise just print the character next to the previous one


punctuation:
    addi $t1, $0, 0                                   # the code for a punctuation mark is 0
    beq  $s2, 32, space                               # jump to space label if the current character is a space
    bne  $t1, $t2, new_line                           # jump to the new_line label if the preceding character was an alphabetic one
    j print                                           # otherwise just print the character next to the previous one
    

space:
    addi $t5, $t5, 1                                  # update the space counter
    j print
    
# prints a new line

new_line:
    println()

# prints a character (eventually)

print:
    la   $v0, 11
    lb   $a0, content($t0) 
    addi $t0, $t0, 1                                  # iterates here
    beq  $a0, 32, verify_char                         # if the character is a space go back to verify the next character in the array
    syscall                                           # prints the character here
    j verify_char                                     # jump back to verify the next character in the array
    

    
        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
