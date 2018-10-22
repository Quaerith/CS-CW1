
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
tokens:                 .space 200001   # Maximum number of tokens
        
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

        addi $t0, $0, 0                # iterates on content
        addi $t1, $0, 0                # iterates on token
        addi $t4, $0, 0                # iterates on dictionary
       
        
verify_char:
        lb   $t3, content($t0)         # loads content character in $t3
        beqz $t3, main_end             # if the current character is 0, jump to end
        blt  $t3, 65, punctuation      # checks if the character is a punctuation and jumps to label if that is the case
        beq  $t2, 0, print             # if the character switches from alphabetic to punctuation then go to print
        
alphabetic:
        sb   $t3, token($t1)
        addi $t1, $t1, 1
        addi $t0, $t0, 1
        lb   $t3, content($t0)
        blt  $t3, 65, spell_check
        j verify_char 
        

punctuation:
        sb   $t3, token($t1)
        addi $t1, $t1, 1
        addi $t0, $t0, 1
        addi $t2, $0, 0
        j verify_char

print:
        print_token()
        addi $t1, $0, 0
        addi $t2, $0, 1
        j verify_char

spell_check:
        lb   $t5, dictionary($t4)
        beqz $t5, verify_char        
        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
