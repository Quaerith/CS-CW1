
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

tokens:                 .space 411849   # Maximum number of tokens
match:                  .space 2049     # Each element is 1 or 0, depending on the token matching a word in the dictionary
punctuations:           .byte ',', '.', '!', '?'    # Stores the possible punctuation marks as bytes

        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text


#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------
do1:
    mul  $t3, $t0, 201                  # do {
    add  $t3, $t3, $t1                  #
    lb   $t4, tokens($t3)               #
    lb   $t5, dictionary($t2)           #   if (dictionary[i] == '\0')
    beqz $t5, jump                      #     break;
    beqz $t4, do1_5                     #
    bne  $t5, 10, do1_1                 #   if (dictionary[i] == '\n')
    addi $t2, $t2, 1                    #     ++i;
    lb   $t5, dictionary($t2)           #
    
do1_1:
    bne  $t4, $t5, do1_2                #   if (tokens[t][c] == dictionary[i]) {
    addi $t2, $t2, 1                    #     ++i;
    addi $t1, $t1, 1                    #     ++c;
    sb   $0, match($t0)                 #     match[t] = 0;
    j do1_4                             #   }

do1_2:
    addi $t7, $t5, -32                  # 
    bne  $t4, $t7, do1_3                #   if (tokens[t][c] == dictionary[i] - 32) {
    addi $t2, $t2, 1                    #     ++i;
    addi $t1, $t1, 1                    #     ++c;
    sb   $0, match($t0)                 #     match[t] = 0;
    j do1_4                             #   }
     
    
do1_3:
    beq  $t5, 10, do1_4                 #   while (dictionary[i] != '\n'){
    addi $t1, $0, 0                     #     c = 0;  
    addi $t7, $0, 1                     #
    sb   $t7, match($t0)                #     match[t] = 1; 
    addi $t2, $t2, 1                    #     ++i;
    lb   $t5, dictionary($t2)           #     if (dictionary[i] == '\0')
    beqz $t5, jump                      #       break;
    j do1_3                             #   }

do1_4:
    beqz $t4, do1_5                     #   if (tokens[t][c] == '\0') {
    j do1

do1_5:
    beq  $t5, 10, jump                  #     if (dictionary[i] == '\n') break; 
    addi $t7, $0, 1                     #     else {  
    sb   $t7, match($t0)                #       match[t] = 1; 
    addi $t1, $0, 0                     #       c = 0; 
    mul  $t3, $t0, 201                  #     }
    add  $t3, $t3, $t1                  #
    lb   $t4, tokens($t3)               # 
    bne  $t5, 10, do1_3                 # Jump back to start checking the next dictionary word
                                        # if the current dictionary character is not a newline
    j do1                               # Otherwise go back to the beginning of the loop
    
jump:
    jr $ra                              # } while (tokens[t][c] != '\0');
    
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


    addi $t0, $0, 0                     # will be used as a counter for iterating on content array
    addi $t3, $0, 0                     # will be used for storing each byte in the punctuation array
    addi $t4, $0, 0                     # iterating on "columns" of tokens array
    addi $t6, $0, 0                     # iterating on "rows" of tokens array
    la   $s0, punctuations              # store punctuations array address in $s0
    addi $s3, $0, 0                     # store null character
    addi $s4, $0, 0                     # will hold the number of tokens
    
    
# $t1 and $t2 are flags to see if the read char changes from punctuation to alphabetic or vice versa
# $t1 holds the code for the current character

    j verify_char
    
# Resets the space counter and "prints" n spaces 
# on a new "row" of the tokens array

reset_space: 
    beqz $t5, continue
    mul  $t4, $t6, 201
    addi $t6, $t6, 1
    addi $s4, $s4, 1                    # tokens number increases
    loop:
    addi $a0, $0, 32
    sb   $a0, tokens($t4)
    addi $t4, $t4, 1
    addi $t5, $t5, -1
    beqz $t5, end
    j loop
    end: 
    mul  $t4, $t6, 201
    addi $t6, $t6, 1
    addi $s4, $s4, 1                    # tokens number increases
    addi $t5, $0, 0                     # resetting the space counter
    j continue                                                   

# Check the type of character (alphabetic, punctuation, space or null)

verify_char: 
    addi $t2, $t1, 0                    # update the code stored in $t2        
    lb   $s2, content($t0)              # s2 holds the current char from content array
    beq  $s2, $s3, label                # check if you reached the end of the content array
    bne  $s2, 32, reset_space           # check that the current character is not a space
                                        # if so, reset the space counter

# Compare the current character with the punctuation marks (stored in the first 4 bytes of $s0)
# If so, jump to the punctuation label
# Otherwise, continue to the alphabetic label

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
    addi $t1, $0, 1                     # the code for an alphabetic character is 1                                   
    beq  $s2, 32, space                 # jump to the space label if the current character is a space
    bne  $t1, $t2, new_line             # jump to the new_line label if the preceding character was a punctuation mark
    j store                             # otherwise just print the character next to the previous one


punctuation:
    addi $t1, $0, 0                     # the code for a punctuation mark is 0
    beq  $s2, 32, space                 # jump to space label if the current character is a space
    bne  $t1, $t2, new_line             # jump to the new_line label if the preceding character was an alphabetic one
    j store                             # otherwise just print the character next to the previous one
    

space:
    addi $t5, $t5, 1                    # update the space counter
    j store
    
# Prints a "new line" in the tokens array

new_line:
    mul  $t4, $t6, 201
    addi $t6, $t6, 1
    addi $s4, $s4, 1

# Stores a character in tokens array (eventually)

store:
    lb   $a0, content($t0) 
    addi $t0, $t0, 1                    # iterates content here
    
    beq  $a0, 32, verify_char           # if the character is a space go back to verify the next character in the array
    sb   $a0, tokens($t4)               # stores character here
    addi $t4, $t4, 1                    # iterates tokens array here
    j verify_char                       # jump back to verify the next character in the content array
    

label:
    addi $t0, $0, 0                     # index of current token number ("row" number == t)
    addi $t1, $0, 0                     # index of current character of the token ("column" number == c)
    addi $t2, $0, 0                     # index of current character of the dictionary (i)
    addi $t3, $0, 0                     # index of current character of tokens array
    addi $t4, $0, 0                     # current character of tokens array (tokens[t][c])
    addi $t5, $0, 0                     # current character of the dictionary (dictionary[i])
    
spell_check:
    beq  $t0, $s4, init                 # if the current token index reaches the tokens number
                                        # reinitialize registers for printing
    mul  $t3, $t0, 201                  # these two lines give the index of the current char of the tokens array
    add  $t3, $t3, $t1                  # index = row * max_word_size + col
    lb   $t4, tokens($t3)               # loads the current character in the $t4 register
    lb   $t5, dictionary($t2)           # loads the first character of the dictionary in $t5
    blt  $t4, 65, match_0               # if the first character of the token is not alphabetical
                                        # then match[t] = 0
    
    jal do1                             # otherwise, check to see if the word is spelled correctly 

# Prepares for iterating on the next "row" of the tokens array
# Dictionary will be checked from the first character
        
for:
    addi $t0, $t0, 1
    addi $t1, $0, 0
    addi $t2, $0, 0
    addi $t5, $0, 0
    j spell_check

match_0:
    sb   $0, match($t0)                 # match[t] = 0;
    j for                                             
    
# Reinitializez some registers for printing the spell checked string
                            
init:
    addi $t0, $0, 0                     # index of current token number ("row" number == t)
    addi $t1, $0, 0                     # current value of match
                                        # 1 if the token doesn't match a word in the dictionary
                                        # 0 if it does
    addi $t2, $0, 0                     # index of start of "row"
    addi $t3, $0, 0                     # index of current character of tokens array
    addi $t4, $0, 0                     # current character of tokens array (tokens[t][c])
    addi $t5, $0, 0                     # current character of the dictionary (dictionary[i])
   
# Prints the spell-checked tokens accordingly
                        
output_tokens:
    mul  $t2, $t0, 201                  # go to the first character of the current token  
    beq  $t0, $s4, main_end             # while (i < tokens_number) {
    lb   $t1, match($t0)                # set $t1 to the current value of match
    addi $t0, $t0, 1                    #    ++i;
    bnez $t1, output_tokens_1           #    if (match[i] == 0) {
    li   $v0, 4                         #       
    la   $a0, tokens($t2)               #       output(tokens[i]);
    syscall                             #
    j output_tokens                     #    }

output_tokens_1:                        #    else {
    li   $v0, 11                        #     
    addi $a0, $0, 95                    #       print_char('_');
    syscall                             #
    li   $v0, 4                         #
    la   $a0, tokens($t2)               #
    syscall                             #       output(tokens[i]);
    li   $v0, 11                        #
    addi $a0, $0, 95                    #
    syscall                             #       print_char('_');
    j output_tokens                     #    }
                                        # }
                                        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
