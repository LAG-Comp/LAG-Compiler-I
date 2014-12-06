%{
#include "LAG-Util.h"

using namespace std;

const int MAX_STR = 256;

symbol_table global_st;

symbol_table temp_tbl;
var_temp_table tep;

symbol_table* st = &temp_tbl;
var_temp_table* st_temp = &tep;

symbol_table temp_table;
symbol_table function_return;
map<string,string> function_header;
map<string, symbol_table> function_st;
map<string, var_temp_table> function_temps;
map<string, symbol_table> function_parameters;


string pipeActive;

bool fetch_function_st( string function_name, map<string,Type>* sim_t );
bool fetch_var_ST( symbol_table& st, string nameVar, Type* typeVar );
string gen_defined_variable(map<string,Type>& sim_table);
string gen_function_header();
string gen_temp( Type t );
string gen_temp_declaration(map<string,int> local_temp);
void add_function_header( Attribute* SS, const Attribute function_name );
void gen_code_attribution_without_index( Attribute* SS, Attribute& lvalue, const Attribute& rvalue );
void gen_code_attribution_1_index( Attribute* SS, Attribute& lvalue, const Attribute& index, const Attribute& rvalue );
void gen_code_attribution_2_index( Attribute* SS, Attribute& lvalue, const Attribute& line, const Attribute& column, const Attribute& rvalue );
void gen_code_bin_ops( Attribute* SS, const Attribute& S1, const Attribute& S2, const Attribute& S3 );
void gen_code_do_while( Attribute* SS, const Attribute& cmds, const Attribute& expr );
void gen_code_for( Attribute* SS, const Attribute& index, const Attribute& initial, const Attribute& end, const Attribute& cmds );
void gen_code_function_with_return( Attribute* SS, const Attribute function_name, const Attribute param, const Attribute type_output, const Attribute output_name, const Attribute block );
void gen_code_function_without_return( Attribute* SS, const Attribute function_name, const Attribute param, const Attribute block );
void gen_code_if( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen );
void gen_code_if_else( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen, const Attribute& cmdsElse );
void gen_code_main( Attribute* SS, const Attribute& cmds );
void gen_code_not( Attribute* SS, const Attribute& value);
void gen_code_parameter( Attribute* SS, const Attribute var_type, const Attribute var_name);
void gen_code_parameters( Attribute* SS, const Attribute param, const Attribute params);
void gen_code_print( Attribute* SS, const Attribute& cmds, const Attribute& expr );
void gen_code_scan( Attribute* SS, const Attribute& var_type, const Attribute& var_name );
void gen_code_while( Attribute* SS, const Attribute& expr, const Attribute& cmds );
void gen_code_return_array( Attribute* SS, const Attribute& var, const Attribute& index);
void gen_code_return_matrix( Attribute* SS, const Attribute& var, const Attribute& line,  const Attribute& column );
void gen_var_declaration( Attribute* SS, const Attribute& typeVar, const Attribute& id );
void insert_var_ST( symbol_table& st, string nameVar, Type typeVar );
void insert_function_st( string function_name );
void remove_temporary_vars();
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
%token _PRINT _THIS _SCAN
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
            << gen_defined_variable( global_st )
            << gen_function_header()
            << $1.c << $2.c << $3.c << endl; }
      ;

MAIN : SIM_ST _STARTING_UP COMMANDS _END_OF_FILE { fetch_function_st("main", st); gen_code_main( &$$, $3 ); }
     ;

SIM_ST : 
	   { $$ = Attribute();
	   	 insert_function_st("main"); }
	   ;

FUNCTIONS : FUNCTION FUNCTIONS { $$.c = $1.c + $2.c; }
          | { $$ = Attribute(); }
          ;

NAME_FUNCTION : _LOAD _ID {insert_function_st($2.v); $$.v = $2.v;}
			  ;

FUNCTION : NAME_FUNCTION '!' _INPUT PARAMETERS _OUTPUT TYPE _ID 
		 { insert_var_ST( *st, $7.v, $6.t ); 
		 	function_return[$1.v] = $6.t; } BLOCK
		 { gen_code_function_with_return(&$$, $1, $4, $6, $7, $9); }

         | _LOAD _ID _INPUT PARAMETERS _OUTPUT _VOID { insert_function_st($2.v); } BLOCK
         { gen_code_function_without_return(&$$, $2, $4, $8); }
     	 ;

PARAMETERS : PARAMETER ',' PARAMETERS { gen_code_parameters(&$$, $1, $3); }
      	   | PARAMETER
      	   ;

PARAMETER : TYPE _ID { gen_code_parameter(&$$, $1, $2); }
       	  | _VOID { $$.c = ""; }
       	  ;

BLOCK : '{' COMMANDS '}' { $$ = $2; }
      ;

COMMANDS : COMMAND COMMANDS { $$.c = $1.c + "\n" + $2.c; }
         | PIPE ';' COMMANDS { $$.c = $1.c + "\n" + $3.c; }
         | COMMAND_COMMA ';' COMMANDS { $$.c = $1.c + "\n" + $3.c; }
         | { $$ = Attribute(); }
         ;

COMMAND_COMMA : CALL_FUNCTION
        	  | VAR   
        	  | ATR     
              | PRINT
        	  | SCAN
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

SCAN : _SCAN SCAN_TYPE _TO _ID
    { gen_code_scan( &$$, $2, $4 ); }
    ;

SCAN_TYPE: _INT
         | _FLOAT
         | _DOUBLE
         ;

CMD_IF : _IF E _EXECUTE BLOCK 
         { gen_code_if( &$$, $2, $4 ); }
       | _IF E _EXECUTE BLOCK _ELSE BLOCK
         { gen_code_if_else( &$$, $2, $4, $6 );}
       ;

CMD_WHILE : _WHILE E _REPEAT BLOCK
          { gen_code_while( &$$, $2, $4 ); }
          ;

CMD_DOWHILE : _DO BLOCK _WHILE E
            { gen_code_do_while( &$$, $2, $4 ); }
            ;

CMD_FOR : _FOR INDEX_FOR _FROM E _TO E _EXECUTE BLOCK
		    { gen_code_for( &$$, $2, $4, $6, $8 ); }
        ;

INDEX_FOR : _ID
		  { insert_var_ST( *st, $1.v, Type("<integer>") );}
		  ;

CMD_SWITCH : _CASE _ID SIWTCH_BLOCK 
           ;

SIWTCH_BLOCK : _CASE_EQUALS F ':' BLOCK SIWTCH_BLOCK 
             | _CASE_NOT ':' BLOCK           
             | { $$ = Attribute(); }
             ;

CALL_FUNCTION : _EXECUTE_FUNCTION _ID _WITH '(' ARGUMENTS ')' 
			  { if( fetch_function_st($2.v, NULL) ){
			  		$$.c = $5.c + "\n\t" + $2.v + "(" + $5.v + ");\n";
			  		$$.t = function_return[$2.v];
			  	}
			  }
              | _EXECUTE_FUNCTION _ID '(' ')' { $$.c = "\n\t" + $2.c + "();\n"; $$.t = function_return[$2.v]; }
              ;

CALL_FUNCTION_RETURN : _EXECUTE_FUNCTION _ID _WITH '(' ARGUMENTS ')' 
			  		 { if( fetch_function_st($2.v, NULL) ){
			  		 		$$.c = $5.c;
			  				$$.v = $2.v + "(" + $5.v + ")";
			  				$$.t = function_return[$2.v];
			  			}
			  		 }
              		 | _EXECUTE_FUNCTION _ID '(' ')' { $$.v = $2.v + "()"; $$.t = function_return[$2.v]; }
               		 ;

ARGUMENTS : E ',' ARGUMENTS { $$.v = $1.v + $2.v + $3.v; $$.c = $1.c + $3.c; }
          | E 
          ;

LIST_VAR : VAR_GLOBAL ';' LIST_VAR 
         | { $$ = Attribute(); }
         ;

VAR_GLOBAL : VAR_GLOBAL ',' _ID { insert_var_ST( global_st, $3.v, $1.t ); }
           | _GLOBAL TYPE _ID 	{ insert_var_ST( global_st, $3.v, $2.t ); }
           ;

VAR : VAR ',' _ID 			{ insert_var_ST( *st, $3.v, $1.t ); }
    | TYPE _ID 				{ insert_var_ST( *st, $2.v, $1.t ); }
    ;

TYPE : SIMPLE_TYPE
	 | _ARRAY SIMPLE_TYPE _OF_SIZE _CTE_INT 
	 { $$ = $2;
	   $$.t.n_dim = 1;
	   $$.t.d1 = toInt( $4.v ); }
	 | _MATRIX SIMPLE_TYPE _OF_SIZE _CTE_INT _BY _CTE_INT
	 { $$ = $2;
	   $$.t.n_dim = 2;
	   $$.t.d1 = toInt( $4.v );
	   $$.t.d2 = toInt( $6.v ); }
	 ;

SIMPLE_TYPE : _INT
     		| _CHAR
     		| _BOOL
     		| _DOUBLE
     		| _FLOAT
     		| _STRING
     		;

ATR : _ID '=' E { gen_code_attribution_without_index( &$$, $1, $3 );}
    | _ID '(' E ')' '=' E 		{ gen_code_attribution_1_index( &$$, $1, $3, $6 ); }
    | _ID '(' E ',' E ')' '=' E { gen_code_attribution_2_index( &$$, $1, $3, $5, $8 ); }
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
         ;

SORT_PARAM : _CRESCENT
         | _DECRESCENT
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
  | _NOT E   { gen_code_not(&$$, $2); }
  | _ID '(' E ')' 		{ gen_code_return_array(&$$, $1, $3); }
  | _ID '(' E ',' E ')' { gen_code_return_matrix(&$$, $1, $3, $5); }
  | CALL_FUNCTION_RETURN
  | _ID
  { if( fetch_var_ST( *st, $1.v, &$$.t ) || fetch_var_ST( global_st, $1.v, &$$.t ) ) 
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

string gen_function_header(){
	string c;
	for( map<string,string>::iterator it = function_header.begin(); it != function_header.end(); ++it){
		c += it->second + ";\n";
	}
	return c;
}

void remove_temporary_vars(){
	if( temp_table.size() > 0 ){
		for (map<string, Type>::iterator i = temp_table.begin(); i != temp_table.end(); ++i)
		{
			st->erase( st->find( i->first ) );
		}
		temp_table.clear();
	}
}

void gen_code_parameter( Attribute* SS, const Attribute var_type, const Attribute var_name){
	string t = "void";
	if( var_type.t.name == "<boolean>" ){
		t = "int";
	}
	else if( var_type.t.name == "<string>" ){
		t = "char["+ toStr(MAX_STR) +"]";
	}
	else{
		t = type_names[var_type.t.name].name;
	}

	SS->c = t + " " + var_name.v;
	SS->v = var_name.v;
	SS->t = var_type.t;
	insert_var_ST( temp_table, var_name.v, var_type.t);
	insert_var_ST( *st, var_name.v, var_type.t);
}

void gen_code_parameters( Attribute* SS, const Attribute param, const Attribute params){
	if( params.c == ""){
		SS->c = param.c;
	}
	else{
		SS->c = param.c + ", " + params.c;
	}
}

void gen_code_function_without_return( 	Attribute* SS, 
										const Attribute function_name, 
										const Attribute param, 
										const Attribute block ){
	remove_temporary_vars();
	function_header[function_name.v] = "void " + function_name.v + "(" + param.c + ")";
	SS->c = "\n\n" + function_header[function_name.v] + "{\n" +
			gen_temp_declaration( *st_temp ) +
			gen_defined_variable( *st ) +
			block.c +
			"}\n\n";
}

void gen_code_function_with_return( Attribute* SS, 
									const Attribute function_name, 
									const Attribute param, 
									const Attribute type_output, 
									const Attribute output_name, 
									const Attribute block ){
	string t = "void";
	if( type_output.t.name == "<boolean>" )
		t = "int";
	else if(type_output.t.name == "<string>"){
		t = "char";
	}
	else if( type_output.t.name == ""){
		t = "void";
	}
	else{
		t = type_names[type_output.t.name].name;
	}
	remove_temporary_vars();
	function_header[function_name.v] = t + " " + function_name.v + "(" + param.c + ")";

	SS->c = "\n\n" + function_header[function_name.v] + "{\n" +
			gen_temp_declaration( *st_temp ) +
			gen_defined_variable( *st ) +
			block.c +
			"\treturn " + output_name.v + ";\n" +
			"}\n\n";
}

void gen_code_not( Attribute* SS, const Attribute& value){
	if( value.t.name == "<boolean>" ){
		string temp1 = gen_temp(Type("<boolean>"));
		SS->c = value.c + 
				"\t" + temp1 + " = !" + value.v + ";\n";
		SS->v = temp1;
		SS->t = Type("<boolean>");
	}
	else{
		err("The type of expression is not a boolean!");
	}
}

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

void gen_code_scan( Attribute* SS, const Attribute& var_type, const Attribute& var_name )
{

  if( var_type.t.name == "<integer>" )
  {
    SS->c =  "\tscanf( \"%d\" , &" + var_name.v + " );\n";
  }
  else if( var_type.t.name == "<floating_point>" || var_type.t.name == "<double_precision>" )
  {
    SS->c = "\tscanf( \"%f\" , &" + var_name.v + " );\n";
  }

}


void gen_code_for( Attribute* SS, const Attribute& index, const Attribute& initial, const Attribute& end, const Attribute& cmds ) {

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

  SS->c = "\t" + index.v + " = " + initial.v + ";\n" +
      "\t" + cond_for + ":\n" +
      "\t" + valueNotCond + " = " + index.v + " < " + end.v + ";\n" +
      "\t" + valueNotCond + " = !" + valueNotCond + ";\n" +
      "\tif( " + valueNotCond + " ) goto " + end_for + ";\n" +
      "\n" + cmds.c + "\n" +
      "\t" + index.v + "= 1 + " + index.v + ";\n" +
      "\tgoto " + cond_for + ";\n" +
      "\t" + end_for + ":\n\n";

}

void gen_code_while( Attribute* SS, const Attribute& expr, const Attribute& cmds )
{
  string whileEnd = new_label("while_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\t" + expr.v + "= !" + expr.v + ";\n" +
          "\tif( " + expr.v + " ) goto " + whileEnd + ";\n" +
          "\t" + cmds.c + "\n" +
          whileEnd + ":\n";
}

void gen_code_do_while( Attribute* SS, const Attribute& cmds, const Attribute& expr )
{
  string doWhileBegin = new_label("do_while_begin", label_counter);

  *SS = Attribute();
  SS->c = doWhileBegin + ":\n" +
          "\t" + cmds.c + "\n" +
          "\t" + expr.c +
          "\tif( " + expr.v + " ) goto " + doWhileBegin + ";\n";
}

void gen_code_if( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen )
{
  string ifEnd = new_label("if_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\t" + expr.v + "= !" + expr.v + ";\n" +
          "\tif( " + expr.v + " ) goto " + ifEnd + ";\n" +
          "\t" + cmdsThen.c + "\n" +
          "\t" + ifEnd + ":\n";
}

void gen_code_if_else( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen, const Attribute& cmdsElse )
{
  string ifEnd = new_label("if_end", label_counter);
  string ifChainEnd = new_label("if_chain_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\t" + expr.v + "= !" + expr.v + ";\n" +
          "\tif( " + expr.v + " ) goto " + ifEnd + ";\n" +
          "\t" + cmdsThen.c + "\n" +
          "\t" + ifEnd + ":\n" + 
          "\t" + cmdsElse.c + "\n" +
          "\t" + ifChainEnd + ":\n";  
}


void gen_code_main( Attribute* SS, const Attribute& cmds ) {
  *SS = Attribute();
  SS->c = "\nint main() {\n" +
           gen_temp_declaration( *st_temp ) + 
           "\n" +
           gen_defined_variable( *st ) +
           "\n" +
           cmds.c + 
           "\treturn 0;\n" 
           "}\n";
}

string gen_temp_declaration(map<string,int> local_temp) {
  string c;

  for( int i = 0; i < local_temp["bool"]; i++ )
    c += "\tint temp_bool_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < local_temp["int"]; i++ )
    c += "\tint temp_int_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < local_temp["char"]; i++ )
    c += "\tchar temp_char_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < local_temp["double"]; i++ )
    c += "\tdouble temp_double_" + toStr( i + 1 ) + ";\n";

    for( int i = 0; i < local_temp["float"]; i++ )
    c += "\tfloat temp_float_" + toStr( i + 1 ) + ";\n";
    
  for( int i = 0; i < local_temp["string"]; i++ )
    c += "\tchar temp_string_" + toStr( i + 1 ) + "[" + toStr( MAX_STR )+ "];\n";
    
  return c;  
}

string gen_defined_variable(map<string,Type>& sim_table){
	string c;
	map<string,Type>::iterator it;
	int array_length = 0;
	for( it = sim_table.begin(); it != sim_table.end(); ++it ){
		if(it->second.n_dim == 0){
			if( it->second.name == "<string>" )
				c += "\tchar " + it->first + "[" + toStr( MAX_STR )+ "];\n";
			else {
				if( it->second.name == "<boolean>" )
			    	c += "\tint " + it->first + ";\n";
			    else
			    	c += "\t" + type_names[it->second.name].name + " " + it->first + ";\n";
			}
		}
		else if(it->second.n_dim == 1){
			if( it->second.name == "<string>" )
				c += "\tchar " + it->first + "[" + toStr( MAX_STR * it->second.d1 )+ "];\n";
			else {
				if( it->second.name == "<boolean>" )
			    	c += "\tint " + it->first + "[" + toStr( it->second.d1 ) + "];\n";
			    else
			    	c += "\t" + type_names[it->second.name].name + " " + it->first + "[" + toStr( it->second.d1 ) + "];\n";
			}
		}
		else if(it->second.n_dim == 2){
			if( it->second.name == "<string>" )
				c += "\tchar " + it->first + "[" + toStr( MAX_STR * it->second.d1 * it->second.d2 )+ "];\n";
			else {
				if( it->second.name == "<boolean>" )
			    	c += "\tint " + it->first + "[" + toStr( it->second.d1 * it->second.d1 ) + "];\n";
			    else
			    	c += "\t" + type_names[it->second.name].name + " " + it->first + "[" + toStr( it->second.d1 * it->second.d2 ) + "];\n";
			}
		}
		
	}

	return c;
}

void gen_code_return_matrix( Attribute* SS, const Attribute& var, const Attribute& line,  const Attribute& column ){
	
	map<string,Type> local_st = *st;
	if( fetch_var_ST( local_st, var.v, &SS->t ) || fetch_var_ST( global_st, var.v, &SS->t ) ){
		if( line.t.name == "<integer>" && column.t.name == "<integer>" ){
		  	string temp1 = gen_temp(Type("<integer>"));
		  	string temp2 = gen_temp(Type("<integer>"));
		  	SS->c = line.c + column.c +
		  			"\t" + temp1 + " = " + toStr(SS->t.d2) + " * " + line.v + ";\n" +
		  			"\t" + temp2 + " = " + temp1 + " + " + column.v + ";\n";
		  	SS->v = var.v + "[" + temp2 + "]"; 
		}
		else{
		  	err("The type of index not accepted, please choose one with type equal to <integer>");
		}
	}
	else {
	  	err( "Variable not declared: " + var.v );
	}  
}

void gen_code_return_array( Attribute* SS, const Attribute& var, const Attribute& index){
	if( fetch_var_ST( *st, var.v, &SS->t ) || fetch_var_ST( global_st, var.v, &SS->t ) ) 
      if( index.t.name == "<integer>" ){
      	SS->c = index.c;
      	SS->v = var.v + "[" + index.v + "]"; 
      }
      else{
      	err("Type of index not accepted, please choose one with type equal to <integer>");
      }

    else
      err( "Variable not declared: " + var.v );
}

void gen_code_attribution_2_index( Attribute* SS, Attribute& lvalue,
										 const Attribute& line,
										 const Attribute& column,
                                         const Attribute& rvalue ) {
  	if( fetch_var_ST( *st, lvalue.v, &lvalue.t ) || fetch_var_ST( global_st, lvalue.v, &lvalue.t )) {
	    if( lvalue.t.name == rvalue.t.name 
	    	&& lvalue.t.n_dim == 2 
	    	&& line.t.name == "<integer>"
	    	&& column.t.name == "<integer>" ) 
	    {
	      	if( lvalue.t.name == "<string>" ) { // ainda não funciona, não sei como fazer sem usar ponteiros;
	        	//SS->c = lvalue.c + rvalue.c + 
	        	//		"" +
	        	//        "\tstrncpy( " + lvalue.v + "[" + line.v + "], " + rvalue.v + ", " + 
	        	//                    toStr( MAX_STR - 1 ) + " );\n" +
	        	//        "\t" + lvalue.v + "[" + toStr( MAX_STR*lvalue.t.d1 - 1 ) + "] = 0;\n";
	      	}
	      	else{
	      		string temp1 = gen_temp( Type("<integer>") );
	      		string temp2 = gen_temp( Type("<integer>") );

	        	SS->c = lvalue.c + rvalue.c +
	        		"\t" + temp1 + " = " + line.v + " * " + toStr(lvalue.t.d2) + ";\n" +
	        		"\t" + temp2 + " = " + temp1 + " + " + column.v + ";\n" +
	                "\t" + lvalue.v + "[" + temp2 + "] = " + rvalue.v + ";\n"; 
	    	}
	    }
	    else
	      err( "Expression " + rvalue.t.name + 
	            " can be attributed to variable " +
	            lvalue.t.name );
    } 
    else
      err( "Variable not declared: " + lvalue.v );
}

void gen_code_attribution_1_index( Attribute* SS, Attribute& lvalue,
										 const Attribute& index,
                                         const Attribute& rvalue ) {
  if( fetch_var_ST( *st, lvalue.v, &lvalue.t ) || fetch_var_ST( global_st, lvalue.v, &lvalue.t )) {
    if( lvalue.t.name == rvalue.t.name 
    	&& lvalue.t.n_dim == 1 
    	&& index.t.name == "<integer>" ) 
    {
      if( lvalue.t.name == "<string>" ) { // ainda não funciona, não sei como fazer sem usar ponteiros;
        //SS->c = lvalue.c + rvalue.c + 
        //		"" +
        //        "\tstrncpy( " + lvalue.v + "[" + index.v + "], " + rvalue.v + ", " + 
        //                    toStr( MAX_STR - 1 ) + " );\n" +
        //        "\t" + lvalue.v + "[" + toStr( MAX_STR*lvalue.t.d1 - 1 ) + "] = 0;\n";
      }
      else
        SS->c = lvalue.c + rvalue.c + 
                "\t" + lvalue.v + "[" + index.v + "] = " + rvalue.v + ";\n"; 
    }
    else
      err( "Expression " + rvalue.t.name + 
            " can be attributed to variable " +
            lvalue.t.name );
    } 
    else
      err( "Variable not declared: " + lvalue.v );
}

void gen_code_attribution_without_index( Attribute* SS, Attribute& lvalue,
                                         const Attribute& rvalue ) {
  if( fetch_var_ST( *st, lvalue.v, &lvalue.t ) || fetch_var_ST( global_st, lvalue.v, &lvalue.t )) {
    if( lvalue.t.name == rvalue.t.name ) {
      if( lvalue.t.name == "<string>" ) {
        SS->c = lvalue.c + rvalue.c + 
                "\tstrncpy( " + lvalue.v + ", " + rvalue.v + ", " + 
                            toStr( MAX_STR - 1 ) + " );\n" +
                "\t" + lvalue.v + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n";
      }
      else
        SS->c = lvalue.c + rvalue.c + 
                "\t" + lvalue.v + " = " + rvalue.v + ";\n"; 
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

void insert_var_ST( symbol_table& sim_t, string nameVar, Type typeVar ) {
  if( !fetch_function_st(nameVar, NULL) ){
  	if( !fetch_var_ST( *st, nameVar, &typeVar ) && !fetch_var_ST( global_st, nameVar, &typeVar) )
	    sim_t[nameVar] = typeVar;
	else  
	    err( "Variable already defined: " + nameVar );
  }
  else{
  	err("The "+ nameVar + " is a function");
  }
}

void insert_function_st( string function_name ){
	Type t;
	map<string,Type> sim_t;
	map<string, int> sim_t2;
	if( !fetch_var_ST( *st, function_name, &t ) && !fetch_var_ST( global_st, function_name, &t) ){
		if( !fetch_function_st( function_name, NULL ) ){
			function_st[function_name] = sim_t;
			function_temps[function_name] = sim_t2;
			st = &function_st[function_name];
			st_temp = &function_temps[function_name];
		}
		else{
			err("Function already defined: " + function_name);
		}
	}
	else{
		err("The " + function_name + " is a variable");
	}
}

bool fetch_function_st( string function_name, map<string,Type>* sim_t ){
	if( function_st.find( function_name ) != function_st.end() ) {
	    if( sim_t != NULL ) *sim_t = function_st[ function_name ];
	    return true;
	}
	else
	    return false;
}

void gen_code_bin_ops( Attribute* SS, const Attribute& S1, const Attribute& S2, const Attribute& S3 )
{
  SS->t = result_type( S1.t, S2.v, S3.t );
  SS->v = gen_temp( SS->t );

  if( SS->t.name == "<string>" ){
    "\n\tstrncpy( " + SS->v + ", " + S1.v + ", " + 
                        toStr( MAX_STR - 1 ) + " );\n" +
            "\tstrncat( " + SS->v + ", " + S3.v + ", " + 
                        toStr( MAX_STR - 1 ) + " );\n" +
            "\t" + SS->v + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n\n";    
  }
  else
    SS->c = S1.c + S3.c + 
            "\t" + SS->v + " = " + S1.v + " " + c_op[S2.v] + " " + S3.v + ";\n";
}

Type result_type( Type a, string op, Type b )
{
  if( operation_results.find(a.name + op + b.name) == operation_results.end() )
    err( "I don't know how to do this operation :( " + a.name + ' ' + op + ' ' + b.name);

  return operation_results[a.name + op + b.name];
}

bool fetch_var_ST( symbol_table& sim_t, string nameVar, Type* typeVar ) {
  if( sim_t.find( nameVar ) != sim_t.end() ) {
    *typeVar = sim_t[ nameVar ];
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
	return "temp_" + type_names[t.name].name + "_" + toStr( ++( *st_temp)[type_names[t.name].name] );
}

int main(int argc, char **argv){

  init_operation_results(operation_results);
  init_type_names(type_names);
  init_c_operands_table(c_op);
  yyparse();
  return 0;
}
