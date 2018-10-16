/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description: 
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker 
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C 
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }   
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];
char token[MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!

int match[2049];

// Appends a '_' to the beginning and the end of an n-character string

void append(int t, int c) {
	int j = 1;
	int n = c;
	// print_int(n);
	char temp[c + 3];
	temp[0] = '_';
	temp[c + 2] = '_';
	output(temp);
	print_int(c);

	while (c > 0) {
		temp[j] = tokens[t][j - 1];
		++j;
		--c;
	}
	for (j = 0; j < n + 3; ++j) {
		tokens[t][j] = temp[j];
	}
	
}

// Task B
void spell_checker() {

  // t is the token number
  int t;
  for (t = 0; t < tokens_number; t++) {

	  // c is the current character of the token
	  int c = 0;

	  // i is the index of the current character of the dictionary
	  int i = 0;

	  // match[t] is 1 if the token doesn't match any word in the dictionary
	  // match[t] is 0 if the token matches a word in the dictionary
	  //match[t] = 1;

	  if (tokens[t][c] >= 'A' && tokens[t][c] <= 'Z' || tokens[t][c] >= 'a' && tokens[t][c] <= 'z') {
		  do {
			  if (dictionary[i] == '\n') {
				  ++i;
			  }
			  if (tokens[t][c] == '\0' && dictionary[i] != '\n') {
				  match[t] = 1;
				  break;
			  }
			  if (dictionary[i] == '\0') {
				  break;
			  }
			  if (tokens[t][c] == dictionary[i] || tokens[t][c] == dictionary[i] - 32) {
				  ++i;
				  ++c;
				  match[t] = 0;
			  }
			  else do {
				  c = 0;
				  match[t] = 1;
				  ++i;
			  } while (dictionary[i] != '\n');
			  
			  
			  if (tokens[t][c] == '\0' && dictionary[i] != '\n') {
				  match[t] = 1;
			  }

		  } while (tokens[t][c] != '\0');
		  
		  

	  }
	  else match[t] = 0;

  }
  return;
}

// Task B
void output_tokens() {

	int i;

	

	for (i = 0; i < tokens_number; ++i) {
		if (match[i] == 0)

		    output(tokens[i]);

		else {
			print_char('_');
			output(tokens[i]);
			print_char('_');
		}

		//output(" ");
	}
	//print_int(match);

	return;
}

//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer(){
  char c;

  // index of content 
  int c_idx = 0;
  c = content[c_idx];
  do {

    // end of content
    if(c == '\0'){
      break;
    }

    // if the token starts with an alphabetic character
    if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {
      
      int token_c_idx = 0;
      // copy till see any non-alphabetic character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with one of punctuation marks
    } else if(c == ',' || c == '.' || c == '!' || c == '?') {
      
      int token_c_idx = 0;
      // copy till see any non-punctuation mark character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ',' || c == '.' || c == '!' || c == '?');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;

      // if the token starts with space
    } else if(c == ' ') {
      
      int token_c_idx = 0;
      // copy till see any non-space character
      do {
        tokens[tokens_number][token_c_idx] = c;

        token_c_idx += 1;
        c_idx += 1;

        c = content[c_idx];
      } while(c == ' ');
      tokens[tokens_number][token_c_idx] = '\0';
      tokens_number += 1;
    }
  } while(1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main (void)
{


  /////////////Reading dictionary and input files//////////////
  ///////////////Please DO NOT touch this part/////////////////
  int c_input;
  int idx = 0;
  
  // open input file 
  FILE *input_file = fopen(input_file_name, "r");
  // open dictionary file
  FILE *dictionary_file = fopen(dictionary_file_name, "r");

  // if opening the input file failed
  if(input_file == NULL){
    print_string("Error in opening input file.\n");
    return -1;
  }

  // if opening the dictionary file failed
  if(dictionary_file == NULL){
    print_string("Error in opening dictionary file.\n");
    return -1;
  }

  // reading the input file
  do {
    c_input = fgetc(input_file);
    // indicates the the of file
    if(feof(input_file)) {
      content[idx] = '\0';
      break;
    }
    
    content[idx] = c_input;

    if(c_input == '\n'){
      content[idx] = '\0'; 
    }

    idx += 1;

  } while (1);

  // closing the input file
  fclose(input_file);

  idx = 0;

  // reading the dictionary file
  do {
    c_input = fgetc(dictionary_file);
    // indicates the end of file
    if(feof(dictionary_file)) {
      dictionary[idx] = '\0';
      break;
    }
    
    dictionary[idx] = c_input;
    idx += 1;
  } while (1);

  // closing the dictionary file
  fclose(dictionary_file);
  //////////////////////////End of reading////////////////////////
  ////////////////////////////////////////////////////////////////

  tokenizer();
  
  spell_checker();
  
  output_tokens();

  return 0;
}
