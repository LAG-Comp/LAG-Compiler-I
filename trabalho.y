%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

const int MAX_STR = 256;

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

typedef map< string, Type > ST;
ST st; // Tabela de simbolos

string pipeActive; // Tipo do pipe ativo

string toStr( int n );
string generateTemporaryDeclaration();
bool fetchVariableST( ST& st, string nameVar, Type* typeVar );
void generateMainCode( Attribute* SS, const Attribute& cmds );
void generateVariableDeclaration( Attribute* SS, const Attribute& typeVar, const Attribute& id );
void insertVariableST( ST& st, string nameVar, Type typeVar );
void err( string msg );
void initializeOperationResults();

#define YYSTYPE Attribute

int yylex();
int yyparse();
void yyerror(const char*);

%}

%start START

%token _CTE_INT _CTE_CHAR _CTE_DOUBLE _CTE_STRING _ID _CTE_TRUE _CTE_FALSE _X
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
%token _INTERVAL_FROM _FILTER _FIRST_N _LAST_N _SORT _FOR_EACH
%token _PRINT
%token _MOD
%token _GT _LT _ET _DF _GE _LE _OR _AND _NOT
%token _STARTING_UP _END_OF_FILE 
%token _CRESCENT _DECRESCENT
%token _CRITERION _MERGE _SPLIT

%left _OR
%left _AND
%left _NOT
%nonassoc _ET _DF _GT _GE _LT _LE
%left _MOD
%left '+' '-'
%left '*' '/'

%%

START : LIST_VAR FUNCTIONS MAIN 
		{ cout << "#include <stdio.h>\n"
               "#include <stdlib.h>\n"
               "#include <string.h>\n\n"
            << $1.c << $2.c << $3.c << endl; }
      ;
      
START : LIST_VAR FUNCTIONS { cout << $1.c << "\n\n" << $2.c << "\n\n" << endl; }
      ;

MAIN : _STARTING_UP COMMANDS _END_OF_FILE
	 { generateMainCode( &$$, $2 ); }
     ;

FUNCTIONS : FUNCTION FUNCTIONS 
          | 
          ;

FUNCTION : _LOAD _ID _INPUT ARGUMENTS _OUTPUT TYPE _ID BLOCK 
         | _LOAD _ID _INPUT ARGUMENTS _OUTPUT _VOID BLOCK
		 ;

ARGUMENTS : ARGUMENT ',' ARGUMENTS 
 		  | ARGUMENT
 		  ;

ARGUMENT : TYPE _COPY _ID 		
		 | TYPE _REFERENCE _ID  
		 | _VOID 				
		 ;

BLOCK : '{' COMMANDS '}' 
	  ;

COMMANDS : COMMAND COMMANDS 
         | PIPE ';' COMMANDS 
         | COMMAND_COMMA ';' COMMANDS 
         |
         ;

COMMAND_COMMA : CALL_FUNCTION
			  | VAR		
        	  | ATR			
              | PRINT
        	  | CMD_DOWHILE
        	  ;

COMMAND : CMD_IF
        | CMD_WHILE	
        | CMD_FOR
        | CMD_SWITCH
        ;

COMMAND_TO_PIPE : COMMAND
				| COMMAND_COMMA
				;

PRINT : _PRINT E 
      ;

CMD_IF : _IF E _EXECUTE BLOCK
       | _IF E _EXECUTE BLOCK ELSE_IFS _ELSE BLOCK
       ;

ELSE_IFS : _ELSE_IF E _EXECUTE BLOCK ELSE_IFS
         | 
         ;

CMD_WHILE : _WHILE E _REPEAT BLOCK
          ;

CMD_DOWHILE : _DO BLOCK _WHILE E
            ;

CMD_FOR : _FOR _ID _FROM E _TO E _EXECUTE BLOCK
        ;

CMD_SWITCH : _CASE _ID SIWTCH_BLOCK 
           ;

SIWTCH_BLOCK : _CASE_EQUALS F ':' BLOCK SIWTCH_BLOCK 
             | _CASE_NOT ':' BLOCK 					 
             | 
             ;

CALL_FUNCTION : _EXECUTE_FUNCTION _ID _WITH '(' PARAMETERS ')' 
              | _EXECUTE_FUNCTION _ID '(' ')' 
              ;

LIST_ARRAY : '{' PARAMETERS '}' ',' LIST_ARRAY 
   		   | '{' PARAMETERS '}' 
   		   ;

PARAMETERS : PARAMETER ',' PARAMETERS 
           | PARAMETER
           ;

PARAMETER : E
          ;

LIST_VAR : _GLOBAL VAR ';' LIST_VAR 	
         | ATR ';' LIST_VAR 	
         | 						
         ;

VAR : VAR ',' _ID
    | TYPE _ID
    { insertVariableST( st, $2.v, $1.t );
      generateVariableDeclaration( &$$, $1, $2 ); }  		
    | _GLOBAL TYPE _ID 	
    | _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    | _GLOBAL _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    | _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    | _GLOBAL _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    ;

ATR : _ID '=' E 
    | _ID '=' '{' PARAMETERS '}' 
    | _ID '=' '{' LIST_ARRAY '}' 
    | _ID '(' E ')' '=' E 		 
    | _ID '(' E ',' E ')' '=' E
    ;

PIPE : '[' PIPE_SOURCE '|' PIPE_PROCESSORS '|' PIPE_CONSUMER ']'
     ;

PIPE_SOURCE : _ID
			| _INTERVAL_FROM _CTE_INT _TO _CTE_INT
			;

PIPE_CONSUMER : _FOR_EACH _X '(' COMMAND_TO_PIPE ')'
			  ;

PIPE_PROCESSORS : PIPE_PROCESSORS '|' PIPE_PROCESSOR
			    | PIPE_PROCESSOR
			    ;

PIPE_PROCESSOR : _FILTER _X E
			   | _FIRST_N _CTE_INT
			   | _LAST_N _CTE_INT
			   | _SORT '(' SORT_PARAM ')'
			   | _SPLIT _ID _TO _ID _CRITERION E
			   | _MERGE _ID _WITH _ID _CRITERION E
			   ;

SORT_PARAM : _CRESCENT
	       | _DECRESCENT 
	       ;

TYPE : _INT
     | _CHAR
     | _BOOL
     | _DOUBLE
     | _FLOAT
     | _STRING
     ;

E : E '+' E  
  | E '-' E  
  | E '*' E  
  | E '/' E  
  | E _MOD E 
  | E _AND E 
  | E _OR E  
  | E _ET E  
  | E _DF E  
  | E _GT E  
  | E _GE E  
  | E _LT E  
  | E _LE E  
  | '(' E ')'
  | _NOT E 	 
  | _ID '(' E ')' 		// return one element of the array on a given position
  | _ID '(' E ',' E ')'		// return one element of the matrix on a given position
  | CALL_FUNCTION
  | _ID
  { if( fetchVariableST( st, $1.v, &$$.t ) ) 
      $$.v = $1.v; 
    else
      err( "Variable not declared: " + $1.v );
  }
  | _X
  | F 		 
  ;

F : _CTE_INT
  | _CTE_DOUBLE
  | _CTE_TRUE
  | _CTE_FALSE
  | _CTE_STRING
  ;

%%

int nline = 1;
map<string,int> n_var_temp;
map<string,Type> operationResults;
map<string,Type> type_names;

#include "lex.yy.c"

void generateMainCode( Attribute* SS, const Attribute& cmds ) {
  *SS = Attribute();
  SS->c = "\nint main() {\n" +
           generateTemporaryDeclaration() + 
           "\n" +
           cmds.c + 
           "  return 0;\n" 
           "}\n";
}

string generateTemporaryDeclaration() {
  string c;
  
  for( int i = 0; i < n_var_temp["bool"]; i++ )
    c += "  int temp_bool_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < n_var_temp["int"]; i++ )
    c += "  int temp_int_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["char"]; i++ )
    c += "  char temp_char_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < n_var_temp["double"]; i++ )
    c += "  double temp_double_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < n_var_temp["float"]; i++ )
    c += "  float temp_float_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < n_var_temp["string"]; i++ )
    c += "  char temp_string_" + toStr( i + 1 ) + "[" + toStr( MAX_STR )+ "];\n";
    
  return c;  
}

void initializeOperationResults() {
  operationResults["<string>+<string>"] = Type( "<string>" );
  operationResults["<integer>+<integer>"] = Type( "<integer>" );
  operationResults["<integer>-<integer>"] = Type( "<integer>" );
  operationResults["<integer>*<integer>"] = Type( "<integer>" );
  operationResults["<integer>is equal to<integer>"] = Type( "<boolean>" );
  operationResults["<integer>%<integer>"] = Type( "<integer>" );
  operationResults["<integer>/<integer>"] = Type( "<integer>" );
  operationResults["<integer>is greater than<integer>"] = Type( "<boolean>" );
  operationResults["<integer>>is lesser than<integer>"] = Type( "<boolean>" );
  operationResults["<double_precision>+<integer>"] = Type( "<double_precision>" );
  operationResults["<integer>*<double_precision>"] = Type( "<double_precision>" );
  // TODO: completar essa lista... :(
}

void initialize_type_names() {
  type_names["<string>"] = Type("string");
  type_names["<integer>"] = Type("int");
}

void generateVariableDeclaration( Attribute* SS, const Attribute& typeVar,
                                           const Attribute& id ) {
  SS->v = "";
  SS->t = typeVar.t;
  if( typeVar.t.name == "<string>" ) {
    SS->c = typeVar.c + 
           "char " + id.v + "["+ toStr( MAX_STR ) +"];\n";   
  }
  else {
    SS->c = typeVar.c + 
            type_names[typeVar.t.name].name + " " + id.v + ";\n";
  }
}

void insertVariableST( ST& st, string nameVar, Type typeVar ) {
  if( !fetchVariableST( st, nameVar, &typeVar ) )
    st[nameVar] = typeVar;
  else  
    err( "Variable already defined: " + nameVar );
}


string toStr( int n ) {
  char buf[1024] = "";
  
  sprintf( buf, "%d", n );
  
  return buf;
}

bool fetchVariableST( ST& st, string nameVar, Type* typeVar ) {
  if( st.find( nameVar ) != st.end() ) {
    *typeVar = st[ nameVar ];
    return true;
  }
  else
    return false;
}

void yyerror( const char* st )
{
   puts( st ); 
   printf(  "Line: %d\nNear: '%s'\n", nline, yytext );
}

void err( string msg ) {
  yyerror( msg.c_str() );
  exit(0);
}

int main(int argc, char **argv){

	initializeOperationResults();
	initialize_type_names();
	yyparse();
  	cout << endl << "Sintaxe ok!" << endl;
	return 0;
}
