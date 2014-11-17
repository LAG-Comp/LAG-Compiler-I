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
%token _INT _CHAR _BOOL _DOUBLE _FLOAT _STRING
%token _GLOBAL _ARRAY _ARRAY2D
%token _REFERENCE _COPY
%token _LOAD _INPUT _OUTPUT
%token _EXECUTE_FUNCTION _WITH
%token _IF _EXECUTE_IF _ELSE _ELSE_IF
%token _WHILE _REPEAT _DO
%token _FOR _FROM _TO _DO_FOR
%token _PRINT
%token _MOD
%token _GT _LT _ET _DF _GE _LE _OR _AND _NOT
%token _STARTING_UP _END_OF_FILE

%left '='
%left _OR
%left _AND
%left _NOT
%nonassoc _ET _DF _GT _GE _LT _LE
%left _MOD
%left '+' '-'
%left '*' '/'

%%

START : LIST_VAR FUNCTIONS { cout << $1.c << "\n\n" << $2.c << endl; }
      ;

FUNCTIONS : FUNCTION FUNCTIONS { $$.c = $1.c + "\n\n" + $2.c; }
          | { $$.c = ""; }
          ;

FUNCTION : _LOAD _ID _INPUT ARGUMENTS _OUTPUT TYPE _ID BLOCK 
{ $$.c = $1.v + " " + $2.v + "\n" + $3.v + " " + $4.c + "\n" + $5.v + " " + $6.t.name + " " + $7.v + "\n" + $8.c; }
         | _LOAD _ID _INPUT ARGUMENTS BLOCK
{ $$.c = $1.v + " " + $2.v + "\n" + $3.v + " " + $4.c + "\n" + $5.c; }
		 ;

ARGUMENTS : ARGUMENT ',' ARGUMENTS { $$.c = $1.c + $2.v + " " + $3.c; }
 		  | ARGUMENT
 		  ;

ARGUMENT : TYPE _COPY _ID 		{ $$.c = $1.t.name + $2.v + " " + $3.v; }
		 | TYPE _REFERENCE _ID  { $$.c = $1.t.name + $2.v + " " + $3.v; }
		 ;

BLOCK : '{' LIST_VAR COMMANDS '}' { $$.c = $1.v + "\n" + $2.c + $3.c + "\n" + $4.v; }
	  ;

COMMANDS : COMMAND COMMANDS { $$.c = $1.c + "\n\n" + $2.c; }
         | { $$.c = ""; }
         ;

COMMAND : CALL_FUNCTION
        ;

CALL_FUNCTION : _EXECUTE_FUNCTION _ID _WITH PARAMETERS ';' 
{ $$.c = $1.v + " " + $2.v + " " + $3.v + " " + $4.c + $5.v; }
              | _EXECUTE_FUNCTION _ID ';' { $$.c = $1.v + " " + $2.v + $3.v; }
              ;

PARAMETERS : PARAMETER ',' PARAMETERS { $$.c = $1.c + $2.v + $3.c; }
           | PARAMETER
           ;

PARAMETER : E
          ;

LIST_VAR : VAR ';' LIST_VAR 	{ $$.c = $1.c + $2.v + "\n" + $3.c; }
         | ATR ';' LIST_VAR 	{ $$.c = $1.c + $2.v + "\n" + $3.c; }
         | 						{ $$.c = ""; }
         ;

VAR : VAR ',' _ID  		{ $$.c = $1.c + $2.v + " " +  $3.v; }
    | TYPE _ID     		{ $$.c = $1.t.name + " " + $2.v; }
    | _GLOBAL TYPE _ID 	{ $$.c = $1.v + " " + $2.t.name + " " + $3.v; }
    ;

ATR : _ID '=' E { $$.c = $1.v + " " + $2.v + " " + $3.c; }
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
  | F 		 { $$.c = $1.v; }
  ;

F : _ID
  | _CTE_INT
  | _CTE_DOUBLE
  | _CTE_TRUE
  | _CTE_FALSE
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
