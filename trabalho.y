%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

struct Tipo {
  string nome;
  
  Tipo() {}
  Tipo( string nome ) {
    this->nome = nome;
  }
};

struct Atributo {
  string v;  // Valor
  Tipo   t;  // tipo
  string c;  // codigo
  
  Atributo() {}  // inicializacao automatica para vazio ""
  Atributo( string v, string t = "", string c = "" ) {
    this->v = v;
    this->t.nome = t;
    this->c = c;
  }
};

typedef map< string, Tipo > TS;
TS ts; // Tabela de simbolos

Tipo tipoResultado( Tipo a, string operador, Tipo b );
string geraTemp( Tipo tipo );

void insereVariavelTS( TS&, string nomeVar, Tipo tipo );
bool buscaVariavelTS( TS&, string nomeVar, Tipo* tipo );
void erro( string msg );

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
%}

%token _CTE_INT _CTE_CHAR _CTE_DOUBLE _CTE_STRING _ID 
%token _INT _CHAR _BOOL _DOUBLE _FLOAT _STRING

%left '+' '-'
%left '*' '/'

%%

S : VAR ';' S
  | ATR ';' S { cout << $1.c << endl; }
  |
  ;

VAR : VAR ',' _ID
      { insereVariavelTS( ts, $3.v, $1.t ); 
        $$ = $1; }
    | TIPO _ID
      { insereVariavelTS( ts, $2.v, $1.t ); 
        $$ = $1; }
    ;
    
TIPO : _INT
     | _CHAR
     | _BOOL
     | _DOUBLE
     | _FLOAT
     | _STRING
     ;
  
ATR : _ID '=' E 
    { $$.c = $3.c +
             $1.v + " = " + $3.v + ";\n"; }
    ;

E : E '+' E   
  { $$.v = geraTemp( tipoResultado( $1.t, $2.v, $3.t ) );
    $$.c = $1.c + $3.c + 
           $$.v + " = " + $1.v + " + " + $3.v + ";\n"; }
  | E '-' E
  | E '*' E
  { $$.v = geraTemp( tipoResultado( $1.t, $2.v, $3.t ) );
    $$.c = $1.c + $3.c + 
           $$.v + " = " + $1.v + " * " + $3.v + ";\n"; }
  | E '/' E
  | F
  ;

F : _ID		
  { if( buscaVariavelTS( ts, $1.v, &$$.t ) ) 
      $$.v = $1.v; 
    else
      erro( "Variavel nao declarada: " + $1.v );
  }	
  | _CTE_INT 
  {  $$.v = $1.v; 
     $$.t = Tipo( "int" ); }
  | _CTE_DOUBLE 
  {  $$.v = $1.v; 
     $$.t = Tipo( "double" ); }
  | '(' E ')'  { $$ = $2; }
  ;

%%
int nlinha = 1;
map<string,int> n_var_temp;
map<string,Tipo> resultadoOperador;

void inicializaResultadoOperador() {
  resultadoOperador["int+int"] = Tipo( "int" );
  resultadoOperador["int*int"] = Tipo( "int" );
  resultadoOperador["double+int"] = Tipo( "double" );
  // TODO: completar essa lista... :(
}

#include "lex.yy.c"

int yyparse();

string toStr( int n ) {
  char buf[1024] = "";
  
  sprintf( buf, "%d", n );
  
  return buf;
}

void yyerror( const char* st )
{
  puts( st );
  printf( "Linha: %d\nPerto de: '%s'\n", nlinha, yytext );
}

void erro( string msg ) {
  yyerror( msg.c_str() );
  exit(0);
}

string geraTemp( Tipo tipo ) {
  return "temp_" + toStr( ++n_var_temp[tipo.nome] );
}

void insereVariavelTS( TS& ts, string nomeVar, Tipo tipo ) {
  if( !buscaVariavelTS( ts, nomeVar, &tipo ) )
    ts[nomeVar] = tipo;
  else  
    erro( "Variavel já definida: " + nomeVar );
}

bool buscaVariavelTS( TS& ts, string nomeVar, Tipo* tipo ) {
  if( ts.find( nomeVar ) != ts.end() ) {
    *tipo = ts[ nomeVar ];
    return true;
  }
  else
    return false;
}

Tipo tipoResultado( Tipo a, string operador, Tipo b ) {
  if( resultadoOperador.find( a.nome + operador + b.nome ) == resultadoOperador.end() )
    erro( "Operacao nao permitida: " + a.nome + operador + b.nome );

  return resultadoOperador[a.nome + operador + b.nome];
}

int main( int argc, char* argv[] )
{
  inicializaResultadoOperador();
  yyparse();
}
