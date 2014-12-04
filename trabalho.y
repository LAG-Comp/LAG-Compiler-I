%{
#include "LAG-Util.h"

using namespace std;

const int MAX_STR = 256;

symbol_table st; 

string pipeActive;

bool fetch_var_ST( symbol_table& st, string nameVar, Type* typeVar );
string gen_temp( Type t );
string gen_temp_declaration();
void gen_code_attribution_without_index( Attribute* SS, Attribute& lvalue, const Attribute& rvalue );
void gen_code_bin_ops( Attribute* SS, const Attribute& S1, const Attribute& S2, const Attribute& S3 );
void gen_code_for( Attribute* SS, const Attribute& index, const Attribute& initial, const Attribute& end, const Attribute& cmds );
void gen_code_if( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen );
void gen_code_if_else( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen, const Attribute& else_ifs, const Attribute& cmdsElse );
void gen_code_main( Attribute* SS, const Attribute& cmds );
void gen_code_print( Attribute* SS, const Attribute& cmds, const Attribute& expr );
void gen_var_declaration( Attribute* SS, const Attribute& typeVar, const Attribute& id );
void insert_var_ST( symbol_table& st, string nameVar, Type typeVar );
Type result_type( Type a, string op, Type b );
void err( string msg );

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
%token _PRINT _THIS
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

%% // END OF INCLUDES //

START : LIST_VAR FUNCTIONS MAIN 
    { cout << "#include <stdio.h>\n"
               "#include <stdlib.h>\n"
               "#include <string.h>\n\n"
            << $1.c << $2.c << $3.c << endl; }
      ;
      
START : LIST_VAR FUNCTIONS { cout << $1.c << "\n\n" << $2.c << "\n\n" << endl; }
      ;

MAIN : _STARTING_UP COMMANDS _END_OF_FILE { gen_code_main( &$$, $2 ); }
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

BLOCK : '{' COMMANDS '}' { $$ = $2; }
      ;

COMMANDS : COMMAND COMMANDS { $$.c = $1.c + "\n" + $2.c; }
         | PIPE ';' COMMANDS { $$.c = $1.c + "\n" + $3.c; }
         | COMMAND_COMMA ';' COMMANDS { $$.c = $1.c + "\n" + $3.c; }
         | {$$.c = "";}
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

PRINT : _PRINT EXPR_PRINT
	  { $$ = $2; }
      ;

EXPR_PRINT : EXPR_PRINT _THIS E
			{ gen_code_print( &$$, $1, $3 ); }
		   | { $$ = Attribute(); }
		   ;

CMD_IF : _IF E _EXECUTE BLOCK
        { gen_code_if( &$$, $2, $4 ); }
       | _IF E _EXECUTE BLOCK ELSE_IFS _ELSE BLOCK
       ;

ELSE_IFS : _ELSE_IF E _EXECUTE BLOCK ELSE_IFS
         | 
         ;

CMD_WHILE : _WHILE E _REPEAT BLOCK
          ;

CMD_DOWHILE : _DO BLOCK _WHILE E
            ;

CMD_FOR : _FOR INDEX_FOR _FROM E _TO E _EXECUTE BLOCK
		{ gen_code_for( &$$, $2, $4, $6, $8 ); }
        ;

INDEX_FOR : _ID
		  { insert_var_ST( st, $1.v, Type("<integer>") );}
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
  { insert_var_ST( st, $3.v, $1.t );
      gen_var_declaration( &$$, $1, $2 ); }
    | TYPE _ID
    { insert_var_ST( st, $2.v, $1.t );
      gen_var_declaration( &$$, $1, $2 ); }     
    | _GLOBAL TYPE _ID  
    | _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    | _GLOBAL _ARRAY TYPE _OF_SIZE _CTE_INT _ID
    | _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    | _GLOBAL _MATRIX TYPE _OF_SIZE _CTE_INT _BY _CTE_INT _ID
    ;

ATR : _ID '=' E { gen_code_attribution_without_index( &$$, $1, $3 );}
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

E : E '+' E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E '-' E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E '*' E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E '/' E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _MOD E { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _AND E { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _OR E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _ET E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _DF E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _GT E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _GE E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _LT E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | E _LE E  { gen_code_bin_ops(&$$, $1, $2, $3); }
  | '(' E ')' { $$ = $2; }
  | _NOT E   
  | _ID '(' E ')'     // return one element of the array on a given position
  | _ID '(' E ',' E ')'   // return one element of the matrix on a given position
  | CALL_FUNCTION
  | _ID
  { if( fetch_var_ST( st, $1.v, &$$.t ) ) 
      $$.v = $1.v; 
    else
      err( "Variable not declared: " + $1.v );
  }
  | _X
  | F      
  ;

F : _CTE_INT 	{ $$.v = $1.v; $$.t = Type( "<integer>" );}
  | _CTE_DOUBLE { $$.v = $1.v; $$.t = Type( "<double_precision>" );}
  | _CTE_TRUE 	{ $$.v = $1.v; $$.t = Type( "<boolean>" );}
  | _CTE_FALSE	{ $$.v = $1.v; $$.t = Type( "<boolean>" );}
  | _CTE_STRING	{ $$.v = $1.v; $$.t = Type( "<string>" );}
  ;

%% // END OF GRAMMAR //

int nline = 1;

map<string,int> n_var_temp;
map<string,int> label_counter;

map<string,Type> operation_results;
map<string,string> c_op;
map<string,Type> type_names;

#include "lex.yy.c"

void gen_code_print( Attribute* SS, const Attribute& cmds, const Attribute& expr ){

	if( expr.t.name == "<integer>" ){
		SS->c = cmds.c + expr.c + "\tprintf( \"%d\" , " + expr.v + " );\n";
	}

	if( expr.t.name == "<boolean>" ){
		string if_bool_label = new_label( "if_bool", label_counter );
		SS->c = cmds.c + expr.c + "\tif( " + expr.v + " ) goto " + if_bool_label + ";\n" +
				"\tprintf( \"false\" );\n" +
				"\t" + if_bool_label + ":\n" +
				"\tprintf( \"true\" );\n";
	}

	if( expr.t.name == "<floating_point>" || expr.t.name == "<double_precision>" ){
		SS->c = cmds.c + expr.c + "\tprintf( \"%f\" , " + expr.v + " );\n";
	}

	if( expr.t.name == "<string>" ){
		SS->c = cmds.c + expr.c + "\tprintf( \"%s\" , " + expr.v + " );\n";
	}
}

void gen_code_for( Attribute* SS, const Attribute& index,
								  const Attribute& initial,
                                  const Attribute& end, 
                                  const Attribute& cmds ) {

  	string cond_for = new_label( "cond_for", label_counter ),
         	end_for = new_label( "end_for", label_counter );
  	string valueNotCond = gen_temp( Type( "<boolean>" ) );
    
    if( initial.t.name != "<integer>" ){
    	err("Type of initial value must be <integer> and was found "+ initial.t.name);
    }

    if( end.t.name != "<integer>" ){
    	err("Type of end value must be <integer> and was found "+ end.t.name);
    }

  	*SS = Attribute();

 	SS->c = "\tint " + index.v + ";\n" +
 			"\t" + index.v + " = " + initial.v + ";\n" +
 			"\t" + cond_for + ":\n" +
 			"\t" + valueNotCond + " = !( " + index.v + " < " + end.v + " );\n" +
 			"\tif( " + valueNotCond + " ) goto " + end_for + ";\n" +
 			"\n" + cmds.c + "\n" +
 			"\t" + index.v + "++" + ";\n" +
 			"\tgoto " + cond_for + ";\n" +
 			"\t" + end_for + ":\n\n";

}

void gen_code_if( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen )
{
  string ifEnd = new_label("if_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\tif( !" + expr.v + " ) goto " + ifEnd + ";\n" +
          "\t" + cmdsThen.c + "\n" +
          "\t" + ifEnd + ":\n";
}

void gen_code_if_else( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen, const Attribute& else_ifs, const Attribute& cmdsElse )
{
  string ifEnd = new_label("if_end", label_counter);
  string ifChainEnd = new_label("if_chain_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\tif( !" + expr.v + " ) goto " + ifEnd + ";\n" +
          "\t" + cmdsThen.c + "\n" +
          "\t" + ifEnd + ":\n" + 
          "\t" + cmdsElse.c + "\n" +
          "\t" + ifChainEnd + ":\n";  
}


void gen_code_main( Attribute* SS, const Attribute& cmds ) {
  *SS = Attribute();
  SS->c = "\nint main() {\n" +
           gen_temp_declaration() + 
           "\n" +
           cmds.c + 
           "\treturn 0;\n" 
           "}\n";
}

string gen_temp_declaration() {
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

void gen_code_attribution_without_index( Attribute* SS, Attribute& lvalue, 
                                         const Attribute& rvalue ) {
  if( fetch_var_ST( st, lvalue.v, &lvalue.t ) ) {
    if( lvalue.t.name == rvalue.t.name ) {
      if( lvalue.t.name == "<string>" ) {
        SS->c = lvalue.c + rvalue.c + 
                "  strncpy( " + lvalue.v + ", " + rvalue.v + ", " + 
                            toStr( MAX_STR - 1 ) + " );\n" +
                "  " + lvalue.v + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n";
      }
      else
        SS->c = lvalue.c + rvalue.c + 
                "  " + lvalue.v + " = " + rvalue.v + ";\n"; 
    }
    else
      err( "Expression " + rvalue.t.name + 
            " can be attributed to variable " +
            lvalue.t.name );
    } 
    else
      err( "Variable not declared: " + lvalue.v );
}

void gen_var_declaration( Attribute* SS, const Attribute& typeVar, const Attribute& id ) {
  SS->v = "";
  SS->t = typeVar.t;
  if( typeVar.t.name == "<string>" ) {
    SS->c = typeVar.c + 
           "char " + id.v + "["+ toStr( MAX_STR ) +"];\n";   
  }
  else {
  	if( typeVar.t.name == "<boolean>" ){
  		SS->c = "\t" + typeVar.c + 
        	"int" + " " + id.v + ";\n";
  	}
  	else{
		SS->c = "\t" + typeVar.c + 
        	type_names[typeVar.t.name].name + " " + id.v + ";\n";
    }
  }
}

void insert_var_ST( symbol_table& st, string nameVar, Type typeVar ) {
  if( !fetch_var_ST( st, nameVar, &typeVar ) )
    st[nameVar] = typeVar;
  else  
    err( "Variable already defined: " + nameVar );
}




void gen_code_bin_ops( Attribute* SS, const Attribute& S1, const Attribute& S2, const Attribute& S3 )
{
  SS->t = result_type( S1.t, S2.v, S3.t );
  SS->v = gen_temp( SS->t );

  if( SS->t.name == "<string>" ){
    "\n  strncpy( " + SS->v + ", " + S1.v + ", " + 
                        toStr( MAX_STR - 1 ) + " );\n" +
            "  strncat( " + SS->v + ", " + S3.v + ", " + 
                        toStr( MAX_STR - 1 ) + " );\n" +
            "  " + SS->v + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n\n";    
  }
  else
    SS->c = S1.c + S3.c + 
            "  " + SS->v + " = " + S1.v + " " + c_op[S2.v] + " " + S3.v + ";\n";
}

Type result_type( Type a, string op, Type b )
{
  if( operation_results.find(a.name + op + b.name) == operation_results.end() )
    err( "I don't know how to do this operation :( " + a.name + ' ' + op + ' ' + b.name);

  return operation_results[a.name + op + b.name];
}

bool fetch_var_ST( symbol_table& st, string nameVar, Type* typeVar ) {
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

void err( string msg ) 
{
  yyerror( msg.c_str() );
  exit(0);
}

string gen_temp( Type t ) {
  return "temp_" + type_names[t.name].name + "_" + toStr( ++n_var_temp[type_names[t.name].name] );
}

int main(int argc, char **argv){

  init_operation_results(operation_results);
  init_type_names(type_names);
  init_c_operands_table(c_op);
  yyparse();
  return 0;
}
