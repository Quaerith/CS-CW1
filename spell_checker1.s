
#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
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
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!

token:                  .space 2049     # Maximum token size
tokens:                 .space 411849   # Maximum number of tokens
punctuations:           .byte ',', '.', '!', '?'    # Stores the possible punctuation marks as bytes

        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text


#=========================================================================
# MACROS
#=========================================================================

_macros:

     .macro print_token()
        li $v0, 4
        la $a0, token
        syscall
     .end_macro     
     
     .macro mark()
        li $v0, 11
        lb $a0, 95
        syscall
        print_token()
        li $v0, 11
        lb $a0, 95
        syscall
     .end_macro

# loads a space into a byte of tokens array
          
  .macro prints()
    addi $a0, $0, 32
    sb   $a0, tokens($t4)
    addi $t4, $t4, 1
  .end_macro
     
# starts populating the next "line" of tokens array
    
  .macro println()
    mul  $t4, $t6, 201
    addi $t6, $t6, 1
  .end_macro
  
# populates a "line" of tokens with n spaces

  .macro printsnln()
    beqz $t5, continue
    println()
    addi $s4, $s4, 1                                  # tokens number increases
    loop:
    prints()
    addi $t5, $t5, -1
    beqz $t5, end
    j loop
    end: 
    println()
    addi $s4, $s4, 1                                  # tokens number increases
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
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)               
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------




# You can add your code here!

# Main idea: if the token is a word, store it in the token array and check against dictionary
# Consider all other characters between two words a token and just print it out
# Try extracting each word from the dictionary and doing an xor with the alphabetic token
# Don't forget to empty the token array before repopulating it
# 160 bits allocated per token

    addi $t0, $0, 0                                   # will be used as a counter for iterating on content array
    addi $t3, $0, 0                                   # will be used for storing each byte in the punctuation array
    addi $t4, $0, 0                                   # iterating on "lines" of tokens
    addi $t6, $0, 0                                   # iterating on "columns" of tokens
    la   $s0, punctuations                            # store punctuations array address in $s0
    la   $s1, tokens                                  # store tokens array
    addi $s3, $0, 0                                   # store null character
    addi $s4, $0, 0                                   # will hold the number of tokens
    
    
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
    beq  $s2, $s3, spell_check                        # check if you reached the end of the content array
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
    j store                                           # otherwise just print the character next to the previous one


punctuation:
    addi $t1, $0, 0                                   # the code for a punctuation mark is 0
    beq  $s2, 32, space                               # jump to space label if the current character is a space
    bne  $t1, $t2, new_line                           # jump to the new_line label if the preceding character was an alphabetic one
    j store                                           # otherwise just print the character next to the previous one
    

space:
    addi $t5, $t5, 1                                  # update the space counter
    j store
    
# prints a "new line" in the tokens array

new_line:
    mul  $t4, $t6, 201
    addi $t6, $t6, 1
    addi $s4, $s4, 1

# stores a character in tokens array (eventually)

store:
    lb   $a0, content($t0) 
    addi $t0, $t0, 1                                  # iterates content here
    
    beq  $a0, 32, verify_char                         # if the character is a space go back to verify the next character in the array
    sb   $a0, tokens($t4)                             # stores character here
    addi $t4, $t4, 1                                  # iterates tokens array here
    j verify_char                                     # jump back to verify the next character in the content array
    
spell_check:
   li   $v0, 4
   la   $a0, tokens+402
   syscall       
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
