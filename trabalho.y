%{
#include "LAG-Util.h"

using namespace std;

const int MAX_STR = 256;

map<string,Type> type_names;

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

map<string,int> label_counter;

string pipeActive;
string stepPipe;
Attribute begin_pipe;
Attribute end_pipe;
Attribute index_pipe;

bool fetch_function_st( string function_name, map<string,Type>* sim_t );
bool fetch_var_ST( symbol_table& st, string nameVar, Type* typeVar );
string gen_defined_variable(map<string,Type>& sim_table);
string gen_function_header();
string gen_temp( Type t );
string gen_temp_declaration(map<string,int> local_temp);
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
void gen_code_una_ops( Attribute* SS, const Attribute& op, const Attribute& value);
void gen_code_parameter( Attribute* SS, const Attribute var_type, const Attribute var_name);
void gen_code_parameters( Attribute* SS, const Attribute param, const Attribute params);
void gen_code_pipe_array( Attribute* SS, Attribute id, Attribute proc, Attribute consumer);
void gen_code_pipe_filter( Attribute* SS, const Attribute& condition );
void gen_code_pipe_firstN(Attribute* SS, Attribute n);
void gen_code_pipe_interval( Attribute* SS, Attribute begin, Attribute end, string cmds);
void gen_code_pipe_lastN(Attribute* SS, Attribute n);
void gen_code_pipe_source( Attribute* SS, Attribute var);
void gen_code_pipe_sort( Attribute* SS, Attribute order, Attribute id);
void gen_code_pipe_split( Attribute* SS, Attribute id_1, Attribute id_2, Attribute expr);
void gen_code_print( Attribute* SS, const Attribute& cmds, const Attribute& expr );
void gen_code_scan( Attribute* SS, const Attribute& var_type, const Attribute& var_name );
void gen_code_switch( Attribute* SS, Attribute& id, Attribute& switch_block );
void gen_code_while( Attribute* SS, const Attribute& expr, const Attribute& cmds );
void gen_code_return_array( Attribute* SS, const Attribute& var, const Attribute& index);
void gen_code_return_matrix( Attribute* SS, const Attribute& var, const Attribute& line,  const Attribute& column );
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

%token _CTE_INT _CTE_DOUBLE _CTE_STRING _ID _CTE_TRUE _CTE_FALSE _X
%token _INT _BOOL _DOUBLE _FLOAT _STRING _VOID
%token _GLOBAL _ARRAY _MATRIX
%token _OF_SIZE _BY
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
%token _CRITERION _SPLIT

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

         | NAME_FUNCTION '!' _INPUT PARAMETERS _OUTPUT _VOID BLOCK
         { gen_code_function_without_return(&$$, $1, $4, $7); }
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

COMMAND_TO_PIPE : COMMAND COMMAND_TO_PIPE { $$.c = $1.c + "\n" + $2.c; }
        		| COMMAND_COMMA ';' COMMAND_TO_PIPE { $$.c = $1.c + "\n" + $3.c; }
        		| { $$ = Attribute(); }
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

CMD_SWITCH : _CASE _ID SIWTCH_BLOCK { gen_code_switch(&$$, $2, $3); }
           ;

SIWTCH_BLOCK : _CASE_EQUALS F ':' BLOCK SIWTCH_BLOCK { $$.label = $5.label; $$.label[$2.v] = $4.c; }
             | _CASE_NOT ':' BLOCK  { $$.label["default"] = $3.c; }
             | { $$ = Attribute(); }
             ;

CALL_FUNCTION : _EXECUTE_FUNCTION _ID _WITH '(' ARGUMENTS ')' 
			  { if( fetch_function_st($2.v, NULL) ){
			  		$$.c = $5.c + "\n\t" + $2.v + "(" + $5.v + ");\n";
			  		$$.t = function_return[$2.v];
			  	}
			  	else{
			  		err("Function not declared: "+$2.v);
			  	}
			  }
              | _EXECUTE_FUNCTION _ID '(' ')' 
              { if( fetch_function_st($2.v, NULL) ){
              		$$.c = "\n\t" + $2.v + "();\n"; 
              		$$.t = function_return[$2.v];
              	}
			  	else{
			  		err("Function not declared: "+$2.v);
			  	}
              }
              ;

CALL_FUNCTION_RETURN : _EXECUTE_FUNCTION _ID _WITH '(' ARGUMENTS ')' 
			  		 {  if( fetch_function_st($2.v, NULL) ){
			  		 		$$.c = $5.c;
			  				$$.v = $2.v + "(" + $5.v + ")";
			  				$$.t = function_return[$2.v];
			  			}
					  	else{
					  		err("Function not declared: "+$2.v);
					  	}
			  		 }
              		 | _EXECUTE_FUNCTION _ID '(' ')' 
              		 {  if( fetch_function_st($2.v, NULL) ){
              		 		$$.v = $2.v + "()"; 
              		 		$$.t = function_return[$2.v]; 
              		 	}
					  	else{
					  		err("Function not declared: "+$2.v);
					  	}
              		 }
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
     		| _BOOL
     		| _DOUBLE
     		| _FLOAT
     		| _STRING
     		;

ATR : _ID '=' E 
	{ 	if( $1.v == "x" || $1.v == "x_"+type_names[pipeActive].name ) 
			err("Can't make the attribution to variable 'x' because it work only on pipe.");
		gen_code_attribution_without_index( &$$, $1, $3 );
	}
    | _ID '(' E ')' '=' E 		{ gen_code_attribution_1_index( &$$, $1, $3, $6 ); }
    | _ID '(' E ',' E ')' '=' E { gen_code_attribution_2_index( &$$, $1, $3, $5, $8 ); }
    ;

PIPE : '[' LOAD_PIPE_ID '|' PIPE_PROCESSORS '|' PIPE_CONSUMER ']'
	 { gen_code_pipe_array(&$$, $2, $4, $6); }
	 | '[' _INTERVAL_FROM LOAD_PIPE _TO INIT_PIPE '|' PIPE_PROCESSORS '|' PIPE_CONSUMER ']'
	 { gen_code_pipe_interval( &$$, $3, $5, $7.c + $9.c); }
     ;

LOAD_PIPE_ID : _ID
			 {
			 	if( pipeActive != "" )
			 		err("There isn't pipe into pipe.");
			 	if( fetch_var_ST( *st, $1.v, &$1.t) || fetch_var_ST( global_st, $1.v, &$1.t) ){
			 		if( $1.t.n_dim == 1 ){
			 			$$ = $1;
					  	begin_pipe = Attribute();
					  	begin_pipe.v = gen_temp(Type("<integer>"));
					  	index_pipe = Attribute();
					  	index_pipe.v = gen_temp(Type("<integer>"));
					  	index_pipe.c = "\t" + index_pipe.v + " = 0;\n";

						end_pipe = Attribute();
				  		end_pipe.v = gen_temp(Type("<integer>"));
						pipeActive = $1.t.name;
						Type tt = Type();
						if( !fetch_var_ST( *st, "x_"+type_names[pipeActive].name, &tt) ) 
							insert_var_ST( *st, "x_"+type_names[pipeActive].name, pipeActive);
						stepPipe = new_label( "step_pipe", label_counter);

			 		}
			 		else{
			 			err("The variable is not a array.");
			 		}
			 	}
			 	else{
			 		err("variable not declared.");
			 	}
			 }
			 ;

LOAD_PIPE : E
		  { 
		  	$$ = $1;
		  	begin_pipe = Attribute();
		  	begin_pipe.v = gen_temp(Type("<integer>"));
		  	index_pipe = Attribute();
		  	index_pipe.v = gen_temp(Type("<integer>"));
		  	index_pipe.c = "\t" + index_pipe.v + " = 0;\n"; 
		  }
		  ;

INIT_PIPE : E 
			{ 	
				if( pipeActive != "" )
			 		err("There isn't pipe into pipe.");
				$$ = $1;
				end_pipe = Attribute();
		  		end_pipe.v = gen_temp(Type("<integer>"));
				pipeActive = $1.t.name;
				Type tt = Type();
				if( !fetch_var_ST( *st, "x_"+type_names[pipeActive].name, &tt) )
					insert_var_ST( *st, "x_"+type_names[pipeActive].name, pipeActive);
				stepPipe = new_label( "step_pipe", label_counter);
			}
      		;

PIPE_CONSUMER : _FOR_EACH '(' COMMAND_TO_PIPE ')' { $$.c = $3.c; }
         	  | _SORT '(' SORT_PARAM ',' _ID ')'
         	  { gen_code_pipe_sort( &$$, $3, $5); }
	       	  | _SPLIT _ID _TO _ID _CRITERION E 
                  { gen_code_pipe_split( &$$, $2, $4, $6); }
        	  ;

PIPE_PROCESSORS : PIPE_PROCESSORS '|' PIPE_PROCESSOR { $$.c = $1.c + "\n" + $3.c; }
          		| PIPE_PROCESSOR
          		;

PIPE_PROCESSOR : _FILTER '(' E ')'
			   { gen_code_pipe_filter( &$$, $3 ); }
         	   | _FIRST_N '(' E ')' { gen_code_pipe_firstN( &$$, $3); }
         	   | _LAST_N '(' E ')' { gen_code_pipe_lastN( &$$, $3); }
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
  | _NOT E   { gen_code_una_ops(&$$, $1, $2); }
  | '+' E 	 { gen_code_una_ops(&$$, $1, $2); }
  | '-' E 	 { gen_code_una_ops(&$$, $1, $2); }
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
  {
  	if( pipeActive != "" )
  		$$ = Attribute( "x_"+type_names[pipeActive].name, pipeActive);
  	else
  		err("Variable x can be use out of pipe.");
  }
  | F      
  ;

F : _CTE_INT 	{ $$.v = $1.v; $$.t = Type( "<integer>" );}
  | _CTE_DOUBLE { $$.v = $1.v; $$.t = Type( "<double_precision>" );}
  | _CTE_TRUE 	{ $$.v = "1"; $$.t = Type( "<boolean>" );}
  | _CTE_FALSE	{ $$.v = "0"; $$.t = Type( "<boolean>" );}
  | _CTE_STRING	{ $$.v = $1.v; $$.t = Type( "<string>" );}
  ;

%% // END OF GRAMMAR //

int nline = 1;

map<string,int> n_var_temp;

map<string,Type> operation_results;
map<string,string> c_op;

#include "lex.yy.c"

void gen_code_pipe_split( Attribute* SS, Attribute id_1, Attribute id_2, Attribute expr){
	if( (fetch_var_ST( *st, id_1.v, &id_1.t) || fetch_var_ST( global_st, id_1.v, &id_1.t) ) 
		&&(fetch_var_ST( *st, id_2.v, &id_2.t) || fetch_var_ST( global_st, id_2.v, &id_2.t)) 
		&& expr.t.name == "<boolean>"){
		if( id_1.t.n_dim == 1 && id_2.t.n_dim == 1){
			string temp_bool = gen_temp( Type("<boolean>"));
			string temp_1 = gen_temp( Type("<integer>"));
			string temp_counter1 = gen_temp( Type("<integer>"));
			string temp_counter2 = gen_temp( Type("<integer>"));
			string label_split = new_label( "pipe_split", label_counter );
			string label_split2 = new_label( "pipe_split_init", label_counter );
			string label_split3 = new_label( "pipe_split_end", label_counter );
			SS->c = expr.c +
					"\t" + temp_1 + " = " + index_pipe.v + " - " + begin_pipe.v + ";\n" +
					"\tif( " + temp_1 + ") goto " + label_split2 + ";\n" +
					"\t" + temp_counter1 + " = 0;\n" +
					"\t" + temp_counter2 + " = 0;\n" +
					"\t" + label_split2 + ":;\n" +
					"\tif( " + expr.v + " ) goto " + label_split + ";\n" +
					"\t" + id_2.v + "[" + temp_counter1 + "] = x_" + type_names[pipeActive].name + ";\n" +
					"\t" + temp_counter1 + " = " + temp_counter1 + " + 1;\n"+
					"\tgoto " + label_split3 + ";\n" + 
					"\t" + label_split + ":;\n" +
					"\t" + id_1.v + "[" + temp_counter2 + "] = x_" + type_names[pipeActive].name + ";\n" +
					"\t" + temp_counter2 + " = " + temp_counter2 + " + 1;\n"+
					"\t" + label_split3 + ":;\n" ;
		}
		else{
			err("The variable passed are not array types.");
		}

	}
	else{
		err("Wrong values to split. try others.");
	}
}

void gen_code_pipe_sort( Attribute* SS, Attribute order, Attribute id){
	if( fetch_var_ST( *st, id.v, &id.t) || fetch_var_ST( global_st, id.v, &id.t) ){
		if( id.t.n_dim == 1 && id.t.name == pipeActive && pipeActive == "<integer>"){
			string ord;
			if( order.v == "increasing" )
				ord = " < ";
			else{
				ord = " > ";
			}
			string temp1_int = gen_temp(Type("<integer>"));
			string temp2_int = gen_temp(Type("<integer>"));
			string temp3_int = gen_temp(Type("<integer>"));
			string temp1_bool = gen_temp(Type("<boolean>"));
			string label_sort = new_label("pipe_sort_couter",label_counter);
			string label_sort_test = new_label("pipe_sort_test",label_counter);
			string label_sort_test2 = new_label("pipe_sort_test",label_counter);
			string label_sort_end = new_label("pipe_sort_end",label_counter);
			SS->c = "\t" + temp1_int + " = 0;\n" +
					"\t" + temp3_int + " = x_" + type_names[pipeActive].name + ";\n" +
					"\t" + temp1_bool + " = !" + index_pipe.v + ";\n" +
					"\tif( " + temp1_bool + " ) goto " + label_sort_test2 + ";\n" +
					"\t" + label_sort + ":;\n" +

					"\t" + temp1_bool + " = " + temp1_int + " == " + index_pipe.v + ";\n" +
					"\tif( " + temp1_bool + " ) goto " + label_sort_test2 + ";\n" +

					"\t" + temp1_bool + " = " + temp1_int + " < " + index_pipe.v + ";\n" +
					"\t" + temp1_bool + " = !" + temp1_bool + ";\n" +
					"\tif( " + temp1_bool + " ) goto " + label_sort_end + ";\n" +

					"\t" + temp2_int + " = " + id.v + "[" + temp1_int + "];\n" +

					"\t" + temp1_bool + " = " + temp2_int + ord + temp3_int + ";\n" +

					"\tif( " + temp1_bool + " ) goto " + label_sort_test + ";\n" +
					"\t" + id.v + "[" + temp1_int + "] = " + temp3_int + ";\n" +
					"\t" + temp3_int + " = " + temp2_int + ";\n" +
					"\t" + label_sort_test + ":;\n" +

					"\t" + temp1_int + " = " + temp1_int + " + 1;\n" +
					"\tgoto " + label_sort + ";\n" +
					"\t" + label_sort_test2 + ":;\n" +
					"\t" + id.v + "[" + temp1_int + "] = " + temp3_int + ";\n" +
					"\t" + label_sort_end + ":;\n" ;
		}
		else{
			err("The variable is not valid to this operation.");
		}
	}
	else{
		err("Variable not declared.");
	}
}

void gen_code_pipe_firstN(Attribute* SS, Attribute n){
	*SS = Attribute();
	if( n.t.name == "<integer>"){
		string temp1 = gen_temp(Type("<integer>"));
		SS->v = gen_temp(Type("<boolean>"));
		SS->c = n.c +
				"\t" + temp1 + " = " + begin_pipe.v + " + " + n.v + ";\n" +
				"\t" + SS->v + " = " + index_pipe.v + " >= " + temp1 + ";\n" +
				"\tif( " + SS->v + " ) goto " + stepPipe + ";\n" +
				"\t" + end_pipe.v + " = " + temp1 + ";\n";
	}
	else
		err("The parameter of first N must be <integer> type.");
}

void gen_code_pipe_lastN(Attribute* SS, Attribute n){
	*SS = Attribute();
	string temp1, temp_label;
	if( n.t.name == "<integer>"){
		temp1 = gen_temp(Type("<integer>"));
		temp_label = new_label("last_n", label_counter);
		SS->v = gen_temp(Type("<boolean>"));
		SS->c = n.c +
				"\t" + temp1 + " = " + end_pipe.v + " - " + n.v + ";\n" +
				"\t" + SS->v + " = " + index_pipe.v + " < " + temp1 + ";\n" +
				"\tif( " + SS->v + " ) goto " + stepPipe + ";\n" +
				"\t" + begin_pipe.v + " = " + temp1 + ";\n" ;

	}
	else
		err("The parameter of last N must be <integer> type.");
}

void gen_code_pipe_filter( Attribute* SS, const Attribute& condition ) {
  *SS = Attribute();
  SS->v = gen_temp( Type( "<boolean>" ) );
  SS->c = condition.c + 
          "\t" + SS->v + " = ! " + condition.v + ";\n" +
          "\tif( " + SS->v + " ) goto " + stepPipe + ";\n";
}

void gen_code_pipe_interval( Attribute* SS, Attribute begin, Attribute end, string cmds)
{
	Attribute start, condition, step;
            
    start.c = index_pipe.c + begin.c + end.c +
               "\tx_" + type_names[pipeActive].name + " = " + begin.v + ";\n";
    condition.t.name = "<boolean>";
    condition.v = gen_temp( Type( "<boolean>" ) ); 
    condition.c = "\t" + condition.v + " = " + "x_" + type_names[pipeActive].name + " <= " + end.v + ";\n";

    step.c =  "\t" + stepPipe + ":;\n" + 
              "\tx_" + type_names[pipeActive].name + " = x_" + type_names[pipeActive].name + " + 1;\n" +
              "\t" + index_pipe.v + " = 1 + " + index_pipe.v + ";\n";

    string 	for_cond = new_label( "for_cond", label_counter),
    		end_for = new_label( "end_for", label_counter);
    string valueNotCond = gen_temp( Type("<boolean>"));

    *SS = Attribute();
    if( condition.t.name != "<boolean>")
    	err("The expression must be boolean.");

    SS->c = start.c + "\t" + for_cond + ":;\n" + 
    		"\t" + begin_pipe.v + " = 0;\n" +
    		"\t" + end_pipe.v + " = " + end.v + " - " + begin.v + ";\n" +
    		"\t" + end_pipe.v + " = " + end_pipe.v + " + 1;\n" +
    		condition.c +
    		"\t" + valueNotCond + " = !" + condition.v + ";\n" +
    		"\tif( " + valueNotCond + " ) goto " + end_for + ";\n" +
    		cmds +
    		step.c +
    		"\tgoto " + for_cond + ";\n" +
    		"\t" + end_for + ":;\n";


    pipeActive = "";
    begin_pipe = Attribute();
    end_pipe = Attribute();
    index_pipe = Attribute();
}

void gen_code_pipe_array( Attribute* SS, 
					Attribute id, 
					Attribute proc, 
					Attribute consumer)
{
	Attribute start, condition, step;
	string cmds = proc.c + "\n" + consumer.c;
            
    start.c = index_pipe.c;
    condition.t.name = "<boolean>";
    condition.v = gen_temp( Type( "<boolean>" ) ); 
    condition.c = "\t" + condition.v + " = " + index_pipe.v + " < " + toStr(id.t.d1) + ";\n";

    step.c =  "\t" + stepPipe + ":;\n" +
              "\t" + index_pipe.v + " = 1 + " + index_pipe.v + ";\n";

    string 	for_cond = new_label( "for_cond", label_counter),
    		end_for = new_label( "end_for", label_counter);
    string valueNotCond = gen_temp( Type("<boolean>"));

    *SS = Attribute();
    if( condition.t.name != "<boolean>")
    	err("The expression must be boolean.");

    SS->c = index_pipe.c +
    		start.c + "\t" + for_cond + ":;\n" + 
    		"\t" + begin_pipe.v + " = 0;\n" +
    		"\t" + end_pipe.v + " = " + toStr(id.t.d1) + ";\n" +
    		condition.c +
    		"\t" + valueNotCond + " = !" + condition.v + ";\n" +
    		"\tif( " + valueNotCond + " ) goto " + end_for + ";\n" +
    		"\tx_" + type_names[pipeActive].name + " = " + id.v + "[" + index_pipe.v + "];\n" +
    		cmds +
    		step.c +
    		"\tgoto " + for_cond + ";\n" +
    		"\t" + end_for + ":;\n";


    pipeActive = "";
    begin_pipe = Attribute();
    end_pipe = Attribute();
    index_pipe = Attribute();
}

void gen_code_switch( Attribute* SS, Attribute& id, Attribute& switch_block ){

	if( fetch_var_ST( *st, id.v, &id.t ) || fetch_var_ST( global_st, id.v, &id.t )){
		string default_l = new_label( "default", label_counter);
		string end_switch = new_label( "end_switch", label_counter);
		string default_code = switch_block.label["default"];
		switch_block.label.erase("default");
		string temp = gen_temp(Type("<boolean>"));
		string c, c_if, label_temp;
		for(map<string,string>::iterator it = switch_block.label.begin(); it != switch_block.label.end(); ++it){
			label_temp = new_label("case", label_counter);

			c_if += "\t" + temp + " = " + id.v + " == " + it->first + ";\n" +
					"\tif(" + temp + ") goto " + label_temp + ";\n";

			c += "\t" + label_temp + ":;\n" +
				it->second +
				"\tgoto " + end_switch + ";\n";
		}

		SS->c = c_if + 
				"\tgoto " + default_l + ";\n\n" + c +
				"\t" + default_l + ":;\n" + default_code + "\n"
				"\t" + end_switch + ":;\n";

		switch_block.label.clear();

	}
	else{
		err("Variable not dlecared: "+ id.v);
	}
}

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

void gen_code_una_ops( Attribute* SS, const Attribute& op, const Attribute& value){
	if( (op.v == "!" && value.t.name == "<boolean>") 
		|| ( (op.v == "+" || op.v == "-") && ( value.t.name == "<integer>" 
											|| value.t.name == "<floating_point>"
											|| value.t.name == "<double_precision>" ) ) ){
		string temp1 = gen_temp(value.t);
		SS->c = value.c + 
				"\t" + temp1 + " = " + op.v + value.v + ";\n";
		SS->v = temp1;
		SS->t = value.t;
	}
	else{
		err("Can't make a this unary operand: "+op.v+", with type: "+value.t.name);
	}
}

void gen_code_print( Attribute* SS, const Attribute& cmds, const Attribute& expr ){

	if( expr.t.name == "<integer>" ){
		SS->c = cmds.c + expr.c + "\tprintf( \"%d\" , " + expr.v + " );\n";
	}

	if( expr.t.name == "<boolean>" ){
		string if_bool_label = new_label( "if_bool", label_counter );
		string end_if = new_label("end_if", label_counter);
		SS->c = cmds.c + expr.c + "\tif( " + expr.v + " ) goto " + if_bool_label + ";\n" +
				"\tprintf( \"%s\",\"false\" );\n" +
				"\tgoto " + end_if + ";\n" +
				"\t" + if_bool_label + ":;\n" +
				"\tprintf( \"%s\",\"true\" );\n"
				"\t" + end_if + ":;\n\n" ;
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
      "\t" + cond_for + ":;\n" +
      "\t" + valueNotCond + " = " + index.v + " < " + end.v + ";\n" +
      "\t" + valueNotCond + " = !" + valueNotCond + ";\n" +
      "\tif( " + valueNotCond + " ) goto " + end_for + ";\n" +
      "\n" + cmds.c + "\n" +
      "\t" + index.v + "= 1 + " + index.v + ";\n" +
      "\tgoto " + cond_for + ";\n" +
      "\t" + end_for + ":;\n\n";

}

void gen_code_while( Attribute* SS, const Attribute& expr, const Attribute& cmds )
{
  string whileEnd = new_label("while_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\t" + expr.v + "= !" + expr.v + ";\n" +
          "\tif( " + expr.v + " ) goto " + whileEnd + ";\n" +
          "\t" + cmds.c + "\n" +
          "\t" + whileEnd + ":;\n";
}

void gen_code_do_while( Attribute* SS, const Attribute& cmds, const Attribute& expr )
{
  string doWhileBegin = new_label("do_while_begin", label_counter);

  *SS = Attribute();
  SS->c = "\t" + doWhileBegin + ":;\n" +
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
          cmdsThen.c + "\n" +
          "\t" + ifEnd + ":;\n";
}

void gen_code_if_else( Attribute *SS, const Attribute& expr, const Attribute& cmdsThen, const Attribute& cmdsElse )
{
  string ifEnd = new_label("if_end", label_counter);
  string ifChainEnd = new_label("if_chain_end", label_counter);

  *SS = Attribute();
  SS->c = expr.c + 
          "\t" + expr.v + "= !" + expr.v + ";\n" +
          "\tif( " + expr.v + " ) goto " + ifEnd + ";\n" +
          cmdsThen.c + "\n" +
          "\tgoto " + ifChainEnd + ";\n" +
          "\t" + ifEnd + ":;\n" + 
          cmdsElse.c + "\n" +
          "\t" + ifChainEnd + ":;\n";  
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

	for( int i = 0; i < local_temp["char*"]; i++ )
		c += "\tchar* temp_char_pointer_" + toStr( i + 1 ) + ";\n";

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
		if( line.t.name == "<integer>" 
			&& column.t.name == "<integer>" 
			&& SS->t.n_dim == 2 ){
		  	if( SS->t.name == "<string>" ){
		  		string temp1 = gen_temp(Type("<integer>"));
		  		string temp_char_pointer = gen_temp(Type("char*"));
			  	SS->c = line.c + column.c +
			  			"\t" + temp1 + " = " + toStr(SS->t.d2) + " * " + line.v + ";\n" +
			  			"\t" + temp1 + " = " + temp1 + " + " + column.v + ";\n" + 
			  			"\t" + temp1 + " = " + temp1 + " * " + toStr(MAX_STR) + ";\n" +
			  			"\t" + temp_char_pointer + " = " + var.v + " + " + temp1 + ";\n";
			  	SS->v = temp_char_pointer;
			  	SS->t =Type(SS->t.name);
		  	}
		  	else{
		  		string temp1 = gen_temp(Type("<integer>"));
			  	SS->c = line.c + column.c +
			  			"\t" + temp1 + " = " + toStr(SS->t.d2) + " * " + line.v + ";\n" +
			  			"\t" + temp1 + " = " + temp1 + " + " + column.v + ";\n" + 
			  			"\t" + temp1 + " = " + var.v + "[" + temp1 + "];\n";
			  	SS->v = temp1;
			  	SS->t =Type(SS->t.name);
		  	}
		}
		else{
		  	err("Type of index line: " + line.t.name + " column: " + column.t.name + " not accepted, please choose one with type equal to <integer>." + 
      		" or the" + " dimension is wrong: "+ toStr(SS->t.n_dim));
		}
	}
	else {
	  	err( "Variable not declared: " + var.v );
	}  
}

void gen_code_return_array( Attribute* SS, const Attribute& var, const Attribute& index){
	if( fetch_var_ST( *st, var.v, &SS->t ) || fetch_var_ST( global_st, var.v, &SS->t ) ) 
      if( index.t.name == "<integer>" && SS->t.n_dim == 1 ){
      	if( SS->t.name == "<string>" ){
      		string temp_char_pointer = gen_temp(Type("char*"));
		  	string temp1 = gen_temp(Type("<integer>"));
      		SS->c =	index.c +
      				"\t" + temp1 + " = " + index.v + " * " + toStr(MAX_STR) + ";\n" +
      				"\t" + temp_char_pointer + " = " + var.v + " + " + temp1 + ";\n";
      		SS->v = temp_char_pointer;
      		SS->t = Type("<string>");

      	}
      	else{
      		string temp1 = gen_temp(SS->t);
	      	SS->c = index.c +
	      			"\t" + temp1 + " = " + var.v + "[" + index.v + "];\n";
	      	SS->v = temp1;
	      	SS->t = Type(SS->t.name);
        }
      }
      else{
      	err("Type of index " + index.t.name +" not accepted, please choose one with type equal to <integer>." + 
      		" or the" + " dimension is wrong: "+ toStr(SS->t.n_dim));
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
	      	if( lvalue.t.name == "<string>" ) {
	      		string temp1 = gen_temp( Type("<integer>") );
	        	string temp_char_pointer = gen_temp(Type("char*"));
				SS->c = lvalue.c + rvalue.c + 
	        			"\t" + temp1 + " = " + line.v + " * " + toStr(lvalue.t.d2) + ";\n" +
	        			"\t" + temp1 + " = " + temp1 + " + " + column.v + ";\n" +
						"\t" + temp1 + " = " + temp1 + " * " + toStr(MAX_STR) + ";\n" +
						"\t" + temp_char_pointer + " = " + lvalue.v + " + " + temp1 + ";\n" +
				        "\tstrncpy( " + temp_char_pointer + ", " + rvalue.v + ", " + 
				                    toStr( MAX_STR - 1 ) + " );\n" +
				        "\t" + temp_char_pointer + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n";
	      	}
	      	else{
	      		string temp1 = gen_temp( Type("<integer>") );

	        	SS->c = lvalue.c + rvalue.c +
	        		"\t" + temp1 + " = " + line.v + " * " + toStr(lvalue.t.d2) + ";\n" +
	        		"\t" + temp1 + " = " + temp1 + " + " + column.v + ";\n" +
	                "\t" + lvalue.v + "[" + temp1 + "] = " + rvalue.v + ";\n"; 
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
			if( lvalue.t.name == "<string>" ) {
				string temp_char_pointer = gen_temp(Type("char*"));
				string temp_index = gen_temp(Type("<integer>"));
				SS->c = lvalue.c + rvalue.c + 
						"\t" + temp_index + " = " + index.v + " * " + toStr(MAX_STR) + ";\n" +
						"\t" + temp_char_pointer + " = " + lvalue.v + " + " + temp_index + ";\n" +
				        "\tstrncpy( " + temp_char_pointer + ", " + rvalue.v + ", " + 
				                    toStr( MAX_STR - 1 ) + " );\n" +
				        "\t" + temp_char_pointer + "[" + toStr( MAX_STR - 1 ) + "] = 0;\n";
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
    if( lvalue.t.name == rvalue.t.name && lvalue.t.n_dim == 0 ) {
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
    SS->c = "\n\tstrncpy( " + SS->v + ", " + S1.v + ", " + 
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
	if( t.name == "char*"){
		return "temp_char_pointer_" + toStr( ++( *st_temp)[t.name] );
	}
	else
		return "temp_" + type_names[t.name].name + "_" + toStr( ++( *st_temp)[type_names[t.name].name] );
}

int main(int argc, char **argv){

  init_operation_results(operation_results);
  init_type_names(type_names);
  init_c_operands_table(c_op);
  yyparse();
  return 0;
}
