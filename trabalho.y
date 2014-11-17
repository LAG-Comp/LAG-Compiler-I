%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

struct Type {
  string name;
  
  Type() {}
  Type( string name ) {
    this->name = name;
  }
};

struct Attribute {
  string v;  // Value
  Type   t;  // type
  string c;  // code
  
  Attribute() {}  // initialized automatic to empty ""
  Attribute( string v, string t = "", string c = "" ) {
    this->v = v;
    this->t.name = t;
    this->c = c;
  }
};

#define YYSTYPE Attribute

int yylex();
int yyparse();
void yyerror(const char*);

%}

%start START

%token _CTE_INT _CTE_CHAR _CTE_DOUBLE _CTE_STRING _ID _CTE_TRUE _CTE_FALSE
%token _INT _CHAR _BOOL _DOUBLE _FLOAT _STRING _VOID
%token _GLOBAL _ARRAY _MATRIX
%token _OF_SIZE _BY
%token _REFERENCE _COPY
%token _LOAD _INPUT _OUTPUT
%token _EXECUTE_FUNCTION _WITH
%token _IF _EXECUTE _ELSE _ELSE_IF
%token _WHILE _REPEAT _DO
%token _FOR _FROM _TO _DO_FOR
%token _CASE _CASE_EQUALS _CASE_NOT
%token _INTERVAL_FROM _FILTER_X _FIRST_N _LAST_N _SORT _FOR_EACH_X
%token _PRINT
%token _MOD
%token _GT _LT _ET _DF _GE _LE _OR _AND _NOT
%token _STARTING_UP _END_OF_FILE

%left _OR
%left _AND
%left _NOT
%nonassoc _ET _DF _GT _GE _LT _LE
%left _MOD
%left '+' '-'
%left '*' '/'

%%

START : LIST_VAR FUNCTIONS MAIN { cout << $1.c << "\n\n" << $2.c << "\n\n" << $3.c <<  endl; }
      ;

MAIN : _STARTING_UP COMMANDS _END_OF_FILE { $$.c = $1.v + "\n" + $2.c + "\n" + $3.v; }
     ;

FUNCTIONS : FUNCTION FUNCTIONS { $$.c = $1.c + "\n\n" + $2.c; }
          | { $$.c = ""; }
          ;

FUNCTION : _LOAD _ID _INPUT ARGUMENTS _OUTPUT TYPE _ID BLOCK 
{ $$.c = $1.v + " " + $2.v + "\n" + $3.v + " " + $4.c + "\n" + $5.v + " " + $6.t.name + " " + $7.v + "\n" + $8.c; }
         | _LOAD _ID _INPUT ARGUMENTS _OUTPUT _VOID BLOCK
{ $$.c = $1.v + " " + $2.v + "\n" + $3.v + " " + $4.c + $5.v + " " + $6.t.name + "\n" + $7.c; }
		 ;

ARGUMENTS : ARGUMENT ',' ARGUMENTS { $$.c = $1.c + $2.v + " " + $3.c; }
 		  | ARGUMENT
 		  ;

ARGUMENT : TYPE _COPY _ID 		{ $$.c = $1.t.name + $2.v + " " + $3.v; }
		 | TYPE _REFERENCE _ID  { $$.c = $1.t.name + $2.v + " " + $3.v; }
		 | _VOID 				{ $$.c = $1.t.name; }
		 ;

BLOCK : '{' COMMANDS '}' { $$.c = $1.v + "\n" + $2.c + "\n" + $3.v; }
	  ;

COMMANDS : COMMAND COMMANDS { $$.c = $1.c + "\n\n" + $2.c; }
         | { $$.c = ""; }
         ;

COMMAND : CALL_FUNCTION ';' { $$.c = $1.c + $2.v; }
		| VAR ';' 			{ $$.c = $1.c + $2.v; }
        | ATR ';'			{ $$.c = $1.c + $2.v; }
        | PRINT ';'			{ $$.c = $1.c + $2.v; }
        | CMD_IF
        | CMD_WHILE
        | CMD_DOWHILE ';'	{ $$.c = $1.c + $2.v; }
        | CMD_FOR
        | CMD_SWITCH
        ;
        

PRINT : _PRINT E { $$.c = $1.v + " " + $2.c; }
      ;

CMD_IF : _IF E _EXECUTE BLOCK
		{ $$.c = $1.v + " " + $2.c + " " + $3.v + "\n" + $4.c; }
       | _IF E _EXECUTE BLOCK ELSE_IFS _ELSE BLOCK
		{ $$.c = $1.v + " " + $2.c + " " + $3.v + "\n" + $4.c + $5.c + "\n" + $6.v + "\n" + $7.c; }
       ;

ELSE_IFS : _ELSE_IF E _EXECUTE BLOCK ELSE_IFS
		{ $$.c = $1.v + " " + $2.c + " " + $3.v + "\n" + $4.c + "\n" + $5.c; }
         | { $$.c = ""; }
         ;

CMD_WHILE : _WHILE E _REPEAT BLOCK
		{ $$.c = $1.v + " " + $2.c + " " + $3.v + "\n" + $4.c; }
          ;

CMD_DOWHILE : _DO BLOCK _WHILE E
		{ $$.c = $1.v + "\n" + $2.c + "\n" + $3.v + " " + $4.c; }
            ;

CMD_FOR : _FOR _ID _FROM E _TO E _EXECUTE BLOCK
		{ $$.c = $1.v + " " + $2.v + " " + $3.v + " " + $4.c + " " + $5.v + " " + $6.c + " " + $7.v + " " + $8.c; }
        ;

CMD_SWITCH : _CASE _ID SIWTCH_BLOCK { $$.c = $1.v + " " + $2.v + "\n" + $3.c; }
           ;

SIWTCH_BLOCK : _CASE_EQUALS F ':' BLOCK SIWTCH_BLOCK { $$.c = $1.v + " " + $2.v + $3.v + "\n" + $4.c + $5.c; }
             | _CASE_NOT ':' BLOCK 					 { $$.c = $1.v + $2.v + "\n" + $3.c; }
             | { $$.c = ""; }
             ;

CALL_FUNCTION : _EXECUTE_FUNCTION _ID _WITH '(' PARAMETERS ')' 
{ $$.c = $1.v + " " + $2.v + " " + $3.v + $4.v + " " + $5.c + " " + $6.v; }
              | _EXECUTE_FUNCTION _ID '(' ')' { $$.c = $1.v + " " + $2.v + $3.v + $4.v; }
              ;

LIST_ARRAY : '{' PARAMETERS '}' ',' LIST_ARRAY { $$ = $1.v + " " + $2.c + " " + $3.v + $4.v + $5.c; }
   		   | '{' PARAMETERS '}' { $$ = $1.v + " " + $2.c + " " + $3.v; }
   		   ;

PARAMETERS : PARAMETER ',' PARAMETERS { $$.c = $1.c + $2.v + $3.c; }
           | PARAMETER
           ;

PARAMETER : E
          ;

LIST_VAR : _GLOBAL VAR ';' LIST_VAR 	{ $$.c = $1.v + " " + $2.c + $3.v + "\n" + $4.c; }
         | ATR ';' LIST_VAR 	{ $$.c = $1.c + $2.v + "\n" + $3.c; }
         | 						{ $$.c = ""; }
         ;

VAR : VAR ',' _ID  		{ $$.c = $1.c + $2.v + " " +  $3.v; }
    | TYPE _ID     		{ $$.c = $1.t.name + " " + $2.v; }
    | _GLOBAL TYPE _ID 	{ $$.c = $1.v + " " + $2.t.name + " " + $3.v; }
    | _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    { $$.c = $1.v + " " + $2.t.name + " " + $3.v + " " + $4.v + " " + $5.v; }
    | _GLOBAL _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    { $$.c = $1.v + " " + $2.v + " " + $3.t.name + " " + $4.v + " " + $5.v + " " + $6.v; }
    | _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    { $$.c = $1.v + " " + $2.t.name + " " + $3.v + " " + $4.v + " " + $5.v + " " + $6.v; }
    | _GLOBAL _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    { $$.c = $1.v + " " + $2.v + " " + $3.t.name + " " + $4.v + " " + $5.v + " " + $6.v + " " + $7.v + " " + $8.v; }
    ;

ATR : _ID '=' E { $$.c = $1.v + " " + $2.v + " " + $3.c; }
    | _ID '=' '{' PARAMETERS '}' { $$.c = $1.v + " " + $2.v + $3.v + " " + $4.c + " " + $5.v; }
    | _ID '=' '{' LIST_ARRAY '}' { $$.c = $1.v + " " + $2.v + $3.v + " " + $4.c + " " + $5.v; }
    | _ID '(' E ')' '=' E 		 
    { $$.c = $1.v + $2.v + " " + $3.c + " " + $4.v + " " + $5.v + " " + $6.c; }
    | _ID '(' E ',' E ')' '=' E
    { $$.c = $1.v + $2.v + " " + $3.c + $4.v + " " + $5.c + " " + $6.v + " " + $7.v + " " + $8.c; }
    ;

PIPE : '[' PIPE_LIST ']' { $$.c = $1.v + " " + $2.c + " " + $3.v; }
     ;

PIPE_LIST : PIPE_CMD '|' PIPE_LIST { $$.c = $1.c + " " + $2.v + " " + $3.c; }
          | PIPE_CMD 
          ;

PIPE_CMD : _INTERVAL_FROM _CTE_INT _TO _CTE_INT { $$.c = $1.v + " " + $2.v + " " + $3.v + " " + $4.v; }
         | _FILTER_X E 							{ $$.c = $1.v + " " + $2.c; }
         | _FIRST_N _CTE_INT 					{ $$.c = $1.v + " " + $2.v; }
         | _LAST_N _CTE_INT 					{ $$.c = $1.v + " " + $2.v; }
         | _SORT 								{ $$.c = $1.v; }
         | _FOR_EACH_X CALL_FUNCTION			{ $$.c = $1.v + " " + $2.c; }
         ;

    
TYPE : _INT
     | _CHAR
     | _BOOL
     | _DOUBLE
     | _FLOAT
     | _STRING
     ;

E : E '+' E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E '-' E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E '*' E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E '/' E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _MOD E { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _AND E { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _OR E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _ET E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _DF E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _GT E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _GE E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _LT E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | E _LE E  { $$.c = $1.c + " " + $2.v + " " + $3.c; }
  | '(' E ')'{ $$.c = $1.v + " " + $2.c + " " + $3.v; }
  | _NOT E 	 { $$.c = $1.v + " " + $2.c; }
  | _ID '(' E ')' 		// return one element of the array on a given position
  { $$.c = $1.v + $2.v + " " + $3.c + " " + $4.v; }
  | _ID '(' E ',' E ')'		// return one element of the matrix on a given position
  { $$.c = $1.v + $2.v + " " + $3.c + $4.v + " " + $5.c + " " + $6.v; }
  | CALL_FUNCTION
  | PIPE
  | _ID		 { $$.c = $1.v; }
  | F 		 { $$.c = $1.v; }
  ;

F : _CTE_INT
  | _CTE_DOUBLE
  | _CTE_TRUE
  | _CTE_FALSE
  | _CTE_STRING
  ;

%%

int nline = 1;

#include "lex.yy.c"

void yyerror( const char* st )
{
   puts( st ); 
   printf(  "Line: %d\nNear of: '%s'\n", nline, yytext );
}

int main(int argc, char **argv){

	yyparse();
  	cout << endl << "Sintaxe ok!" << endl;
	return 0;
}
