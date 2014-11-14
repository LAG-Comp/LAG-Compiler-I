#ifndef lint
static const char yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93";
#endif

#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define YYPATCH 20140101

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)

#define YYPREFIX "yy"

#define YYPURE 0

#line 2 "trabalho.y"
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
  string v;  /* Valor*/
  Tipo   t;  /* tipo*/
  string c;  /* codigo*/
  
  Atributo() {}  /* inicializacao automatica para vazio ""*/
  Atributo( string v, string t = "", string c = "" ) {
    this->v = v;
    this->t.nome = t;
    this->c = c;
  }
};

typedef map< string, Tipo > TS;
TS ts; /* Tabela de simbolos*/

Tipo tipoResultado( Tipo a, string operador, Tipo b );
string geraTemp( Tipo tipo );

void insereVariavelTS( TS&, string nomeVar, Tipo tipo );
bool buscaVariavelTS( TS&, string nomeVar, Tipo* tipo );
void erro( string msg );

#define YYSTYPE Atributo

int yylex();
int yyparse();
void yyerror(const char *);
#line 65 "y.tab.c"

#ifndef YYSTYPE
typedef int YYSTYPE;
#endif

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

extern int YYPARSE_DECL();

#define _CTE_INT 257
#define _CTE_CHAR 258
#define _CTE_DOUBLE 259
#define _CTE_STRING 260
#define _ID 261
#define _INT 262
#define _CHAR 263
#define _BOOL 264
#define _DOUBLE 265
#define _FLOAT 266
#define _STRING 267
#define _CTE_TRUE 268
#define _CTE_FALSE 269
#define _GLOBAL 270
#define _ARRAY 271
#define _ARRAY2D 272
#define $token 273
#define _REFERENCE 274
#define _COPY 275
#define _LOAD 276
#define _INPUT 277
#define _OUTPUT 278
#define _EXECUTE_FUNCTION 279
#define _WITH 280
#define _IF 281
#define _EXECUTE_IF 282
#define _ELSE 283
#define _ELSE_IF 284
#define _WHILE 285
#define _REPEAT 286
#define _DO 287
#define _FOR 288
#define _FROM 289
#define _TO 290
#define _DO_FOR 291
#define _MODULO 292
#define _IS 293
#define _GREATER_THAN 294
#define _LESSER_THAN 295
#define _EQUAL_TO 296
#define _OR 297
#define _AND 298
#define _NOT 299
#define _STARTING_UP 300
#define _END_OF_FILE 301
#define YYERRCODE 256
static const short yylhs[] = {                           -1,
    0,    0,    0,    1,    1,    3,    3,    3,    3,    3,
    3,    2,    4,    4,    4,    4,    4,    5,    5,    5,
    5,
};
static const short yylen[] = {                            2,
    3,    3,    0,    3,    2,    1,    1,    1,    1,    1,
    1,    3,    3,    3,    3,    3,    1,    1,    1,    1,
    3,
};
static const short yydefred[] = {                         0,
    0,    6,    7,    8,    9,   10,   11,    0,    0,    0,
    0,    0,    0,    0,    0,    5,   19,   20,   18,    0,
    0,   17,    1,    4,    2,    0,    0,    0,    0,    0,
   21,    0,    0,   15,   16,
};
static const short yydgoto[] = {                          8,
    9,   10,   11,   21,   22,
};
static const short yysindex[] = {                      -253,
  -32,    0,    0,    0,    0,    0,    0,    0,  -43,  -41,
 -230,  -40, -253, -224, -253,    0,    0,    0,    0,  -40,
   -9,    0,    0,    0,    0,  -15,  -40,  -40,  -40,  -40,
    0,   -7,   -7,    0,    0,
};
static const short yyrindex[] = {                        39,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,   39,    0,   39,    0,    0,    0,    0,    0,
  -18,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  -39,  -38,    0,    0,
};
static const short yygindex[] = {                         4,
    0,    0,    0,   -5,    0,
};
#define YYTABLESIZE 221
static const short yytable[] = {                         20,
   14,   13,   14,   13,   14,   13,   14,    1,    2,    3,
    4,    5,    6,    7,   26,   13,   23,   15,   25,   13,
   14,   32,   33,   34,   35,   31,   29,   27,   12,   28,
   16,   30,   29,   27,   29,   28,   24,   30,    3,   30,
   12,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   17,    0,   18,    0,
   19,
};
static const short yycheck[] = {                         40,
   44,   41,   41,   43,   43,   45,   45,  261,  262,  263,
  264,  265,  266,  267,   20,   59,   13,   59,   15,   59,
   59,   27,   28,   29,   30,   41,   42,   43,   61,   45,
  261,   47,   42,   43,   42,   45,  261,   47,    0,   47,
   59,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,  257,   -1,  259,   -1,
  261,
};
#define YYFINAL 8
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 301
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? (YYMAXTOKEN + 1) : (a))
#if YYDEBUG
static const char *yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,"'('","')'","'*'","'+'","','","'-'",0,"'/'",0,0,0,0,0,0,0,0,0,0,0,
"';'",0,"'='",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,"_CTE_INT","_CTE_CHAR","_CTE_DOUBLE","_CTE_STRING","_ID","_INT","_CHAR",
"_BOOL","_DOUBLE","_FLOAT","_STRING","_CTE_TRUE","_CTE_FALSE","_GLOBAL",
"_ARRAY","_ARRAY2D","$token","_REFERENCE","_COPY","_LOAD","_INPUT","_OUTPUT",
"_EXECUTE_FUNCTION","_WITH","_IF","_EXECUTE_IF","_ELSE","_ELSE_IF","_WHILE",
"_REPEAT","_DO","_FOR","_FROM","_TO","_DO_FOR","_MODULO","_IS","_GREATER_THAN",
"_LESSER_THAN","_EQUAL_TO","_OR","_AND","_NOT","_STARTING_UP","_END_OF_FILE",
"illegal-symbol",
};
static const char *yyrule[] = {
"$accept : S",
"S : VAR ';' S",
"S : ATR ';' S",
"S :",
"VAR : VAR ',' _ID",
"VAR : TIPO _ID",
"TIPO : _INT",
"TIPO : _CHAR",
"TIPO : _BOOL",
"TIPO : _DOUBLE",
"TIPO : _FLOAT",
"TIPO : _STRING",
"ATR : _ID '=' E",
"E : E '+' E",
"E : E '-' E",
"E : E '*' E",
"E : E '/' E",
"E : F",
"F : _ID",
"F : _CTE_INT",
"F : _CTE_DOUBLE",
"F : '(' E ')'",

};
#endif

int      yydebug;
int      yynerrs;

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#define YYINITSTACKSIZE 200

typedef struct {
    unsigned stacksize;
    short    *s_base;
    short    *s_mark;
    short    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
} YYSTACKDATA;
/* variables for the parser stack */
static YYSTACKDATA yystack;
#line 122 "trabalho.y"
int nlinha = 1;
map<string,int> n_var_temp;
map<string,Tipo> resultadoOperador;

void inicializaResultadoOperador() {
  resultadoOperador["<integer>+<integer>"] = Tipo( "<integer>" );
  resultadoOperador["<integer>*<integer>"] = Tipo( "<integer>" );
  resultadoOperador["<double_precision>+<integer>"] = Tipo( "<double_precision>" );
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
#line 383 "y.tab.c"

#if YYDEBUG
#include <stdio.h>		/* needed for printf */
#endif

#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    short *newss;
    YYSTYPE *newvs;

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return -1;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (short *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return -1;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return -1;

    data->l_base = newvs;
    data->l_mark = newvs + i;

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab

int
YYPARSE_DECL()
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack)) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = YYLEX) < 0) yychar = 0;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack))
        {
            goto yyoverflow;
        }
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;

    yyerror("syntax error");

    goto yyerrlab;

yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yystack.s_mark]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack))
                {
                    goto yyoverflow;
                }
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
                --yystack.s_mark;
                --yystack.l_mark;
            }
        }
    }
    else
    {
        if (yychar == 0) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
    switch (yyn)
    {
case 2:
#line 68 "trabalho.y"
	{ cout << yystack.l_mark[-2].c << endl; }
break;
case 4:
#line 73 "trabalho.y"
	{ insereVariavelTS( ts, yystack.l_mark[0].v, yystack.l_mark[-2].t ); 
        yyval = yystack.l_mark[-2]; }
break;
case 5:
#line 76 "trabalho.y"
	{ insereVariavelTS( ts, yystack.l_mark[0].v, yystack.l_mark[-1].t ); 
        yyval = yystack.l_mark[-1]; }
break;
case 12:
#line 89 "trabalho.y"
	{ yyval.c = yystack.l_mark[0].c +
             yystack.l_mark[-2].v + " = " + yystack.l_mark[0].v + ";\n"; }
break;
case 13:
#line 94 "trabalho.y"
	{ yyval.v = geraTemp( tipoResultado( yystack.l_mark[-2].t, yystack.l_mark[-1].v, yystack.l_mark[0].t ) );
    yyval.c = yystack.l_mark[-2].c + yystack.l_mark[0].c + 
           yyval.v + " = " + yystack.l_mark[-2].v + " + " + yystack.l_mark[0].v + ";\n"; }
break;
case 15:
#line 99 "trabalho.y"
	{ yyval.v = geraTemp( tipoResultado( yystack.l_mark[-2].t, yystack.l_mark[-1].v, yystack.l_mark[0].t ) );
    yyval.c = yystack.l_mark[-2].c + yystack.l_mark[0].c + 
           yyval.v + " = " + yystack.l_mark[-2].v + " * " + yystack.l_mark[0].v + ";\n"; }
break;
case 18:
#line 107 "trabalho.y"
	{ if( buscaVariavelTS( ts, yystack.l_mark[0].v, &yyval.t ) ) 
      yyval.v = yystack.l_mark[0].v; 
    else
      erro( "Variavel nao declarada: " + yystack.l_mark[0].v );
  }
break;
case 19:
#line 113 "trabalho.y"
	{  yyval.v = yystack.l_mark[0].v; 
     yyval.t = Tipo( "<integer>" ); }
break;
case 20:
#line 116 "trabalho.y"
	{  yyval.v = yystack.l_mark[0].v; 
     yyval.t = Tipo( "<double_precision>" ); }
break;
case 21:
#line 118 "trabalho.y"
	{ yyval = yystack.l_mark[-1]; }
break;
#line 638 "y.tab.c"
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
        if (yychar < 0)
        {
            if ((yychar = YYLEX) < 0) yychar = 0;
#if YYDEBUG
            if (yydebug)
            {
                yys = yyname[YYTRANSLATE(yychar)];
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == 0) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yystack.s_mark, yystate);
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack))
    {
        goto yyoverflow;
    }
    *++yystack.s_mark = (short) yystate;
    *++yystack.l_mark = yyval;
    goto yyloop;

yyoverflow:
    yyerror("yacc stack overflow");

yyabort:
    yyfreestack(&yystack);
    return (1);

yyaccept:
    yyfreestack(&yystack);
    return (0);
}
