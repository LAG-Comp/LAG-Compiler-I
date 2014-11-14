DELIM   [\t ]
LINHA   [\n]
NUMERO  [0-9]
LETRA   [A-Za-z_]
INT     {NUMERO}+
DOUBLE  {NUMERO}+("."{NUMERO}+)
ID      {LETRA}({LETRA}|{NUMERO})*
STRING  \"[^"\n]*\"


%%

{LINHA}    { nlinha++; }
{DELIM}    {}

"<integer>"             {  yylval = Atributo( "", yytext ); return _INT; }
"<character>"           {  yylval = Atributo( "", yytext ); return _CHAR; }
"<boolean>"             {  yylval = Atributo( "", yytext ); return _BOOL; }
"<double_precision>"    {  yylval = Atributo( "", yytext ); return _DOUBLE; }
"<floating_point>"      {  yylval = Atributo( "", yytext ); return _FLOAT; }
"<string>"              {  yylval = Atributo( "", yytext ); return _STRING; }


"Global"                {  yylval = Atributo( "", yytext ); return _GLOBAL; }
"Array"                 {  yylval = Atributo( "", yytext ); return _ARRAY; }
"Array2d"               {  yylval = Atributo( "", yytext ); return _ARRAY2D; }


"<reference>"           {  yylval = Atributo( "", yytext ); return _REFERENCE; }
"<copy>"                {  yylval = Atributo( "", yytext ); return _COPY; }

"Load:"                 {  yylval = Atributo( "", yytext ); return _LOAD; }
"Input"                 {  yylval = Atributo( "", yytext ); return _INPUT; }
"Output:"               {  yylval = Atributo( "", yytext ); return _OUTPUT; }

"Execute function"      {  yylval = Atributo( "", yytext ); return _EXECUTE_FUNCTION; }
"with"                  {  yylval = Atributo( "", yytext ); return _WITH; }


"If"                    {  yylval = Atributo( "", yytext ); return _IF; }
"execute"               {  yylval = Atributo( "", yytext ); return _EXECUTE_IF; }
"Else"                  {  yylval = Atributo( "", yytext ); return _ELSE; }
"Else if"               {  yylval = Atributo( "", yytext ); return _ELSE_IF; }

"While"                 {  yylval = Atributo( "", yytext ); return _WHILE; }
"repeat"                {  yylval = Atributo( "", yytext ); return _REPEAT; }
"Do"                    {  yylval = Atributo( "", yytext ); return _DO; }

"For"                   {  yylval = Atributo( "", yytext ); return _FOR; }
"from"                  {  yylval = Atributo( "", yytext ); return _FROM; }
"to"                    {  yylval = Atributo( "", yytext ); return _TO; }
"do"                    {  yylval = Atributo( "", yytext ); return _DO_FOR; }


"modulo"                {  yylval = Atributo( "", yytext ); return _MODULO; }

"is"                    {  yylval = Atributo( "", yytext ); return _IS; }
"greater than"          {  yylval = Atributo( "", yytext ); return _GREATER_THAN; }
"lesser than"           {  yylval = Atributo( "", yytext ); return _LESSER_THAN; }
"equal to"              {  yylval = Atributo( "", yytext ); return _EQUAL_TO; }
"or"                    {  yylval = Atributo( "", yytext ); return _OR; }
"and"                   {  yylval = Atributo( "", yytext ); return _AND; }
"not"                   {  yylval = Atributo( "", yytext ); return _NOT; }


"Starting up..."        {  yylval = Atributo( "", yytext ); return _STARTING_UP; }
"End of file"           {  yylval = Atributo( "", yytext ); return _END_OF_FILE; }


"true"     { yylval = Atributo( yytext ); return _CTE_TRUE; }
"false"    { yylval = Atributo( yytext ); return _CTE_FALSE; }

{ID}       { yylval = Atributo( yytext ); return _ID; }
{INT}      { yylval = Atributo( yytext ); return _CTE_INT; }
{DOUBLE}   { yylval = Atributo( yytext ); return _CTE_DOUBLE; }
{STRING}   { yylval = Atributo( yytext ); return _CTE_STRING; }

.          { yylval = Atributo( yytext ); return *yytext; }

%%

 


