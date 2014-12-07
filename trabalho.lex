DELIM   [\t ]
LINE    [\n]
NUMBER  [0-9]
LETTER  [A-Za-z_]
INT     {NUMBER}+
DOUBLE  {NUMBER}+("."{NUMBER}+)
ID      {LETTER}({LETTER}|{NUMBER})*
STRING  ["][^"\n]*["]
COMMENT  #[^#]*#


%%

{LINE}    	{ nline++; }
{DELIM}    	{}
{COMMENT}   {}

"<integer>"             {  yylval = Attribute( "", yytext ); return _INT; }
"<boolean>"             {  yylval = Attribute( "", yytext ); return _BOOL; }
"<double_precision>"    {  yylval = Attribute( "", yytext ); return _DOUBLE; }
"<floating_point>"      {  yylval = Attribute( "", yytext ); return _FLOAT; }
"<string>"              {  yylval = Attribute( "", yytext ); return _STRING; }
"<void>"                {  yylval = Attribute( "", yytext ); return _VOID; }


"Global"                {  yylval = Attribute( yytext ); return _GLOBAL; }
"Array"                 {  yylval = Attribute( yytext ); return _ARRAY; }
"Matrix"                {  yylval = Attribute( yytext ); return _MATRIX; }

"of size" 				{ yylval = Attribute( yytext ); return _OF_SIZE;}
"by"	 				{ yylval = Attribute( yytext ); return _BY;}


"Load:"                 {  yylval = Attribute( yytext ); return _LOAD; }
"Input:"                {  yylval = Attribute( yytext ); return _INPUT; }
"Output:"               {  yylval = Attribute( yytext ); return _OUTPUT; }

"Execute function"      {  yylval = Attribute( yytext ); return _EXECUTE_FUNCTION; }
"with"                  {  yylval = Attribute( yytext ); return _WITH; }

"interval from"    		{ yylval = Attribute( yytext ); return _INTERVAL_FROM; }
"filter"    			{ yylval = Attribute( yytext ); return _FILTER; }
"first"    				{ yylval = Attribute( yytext ); return _FIRST_N; }
"last"    				{ yylval = Attribute( yytext ); return _LAST_N; }
"sort"    				{ yylval = Attribute( yytext ); return _SORT; }
"for each"    		    { yylval = Attribute( yytext ); return _FOR_EACH; }

"If"                    {  yylval = Attribute( yytext ); return _IF; }
"Else"                  {  yylval = Attribute( yytext ); return _ELSE; }
"Else if"               {  yylval = Attribute( yytext ); return _ELSE_IF; }

"While"                 {  yylval = Attribute( yytext ); return _WHILE; }
"repeat"                {  yylval = Attribute( yytext ); return _REPEAT; }
"Do"                    {  yylval = Attribute( yytext ); return _DO; }

"For"                   {  yylval = Attribute( yytext ); return _FOR; }
"from"                  {  yylval = Attribute( yytext ); return _FROM; }
"to"                    {  yylval = Attribute( yytext ); return _TO; }

"execute"               {  yylval = Attribute( yytext ); return _EXECUTE; }

"Case"               	{  yylval = Attribute( yytext ); return _CASE; }
"equals"               	{  yylval = Attribute( yytext ); return _CASE_EQUALS; }
"case not"              {  yylval = Attribute( yytext ); return _CASE_NOT; }


"Print"                 {  yylval = Attribute( yytext ); return _PRINT; }
"this"              	{  yylval = Attribute( yytext ); return _THIS; }
"Scan"        			{  yylval = Attribute( yytext ); return _SCAN; }


"modulo"                {  yylval = Attribute( yytext ); return _MOD; }

"is greater than"          	{  yylval = Attribute( yytext ); return _GT; }
"is lesser than"           	{  yylval = Attribute( yytext ); return _LT; }
"is equal to"              	{  yylval = Attribute( yytext ); return _ET; }
"is different from"        	{  yylval = Attribute( yytext ); return _DF; }
"is greater than or equals"	{  yylval = Attribute( yytext ); return _GE; }
"is lesser than or equals" 	{  yylval = Attribute( yytext ); return _LE; }
"or"                       	{  yylval = Attribute( yytext ); return _OR; }
"and"                      	{  yylval = Attribute( yytext ); return _AND; }
"not"                  	   	{  yylval = Attribute( yytext ); return _NOT; }

"using criterion"    		{ yylval = Attribute( yytext ); return _CRITERION; }
"merge"    					{ yylval = Attribute( yytext ); return _MERGE; }
"split"    					{ yylval = Attribute( yytext ); return _SPLIT; }

"increasing"    		{ yylval = Attribute( yytext ); return _CRESCENT; }
"decreasing"    		{ yylval = Attribute( yytext ); return _DECRESCENT; }


"Starting up..."        {  yylval = Attribute( yytext ); return _STARTING_UP; }
"End of file"           {  yylval = Attribute( yytext ); return _END_OF_FILE; }


"x"		   { yylval = Attribute( yytext ); return _X; }
"true"     { yylval = Attribute( yytext ); return _CTE_TRUE; }
"false"    { yylval = Attribute( yytext ); return _CTE_FALSE; }

{INT}      { yylval = Attribute( yytext ); return _CTE_INT; }
{DOUBLE}   { yylval = Attribute( yytext ); return _CTE_DOUBLE; }
{STRING}   { yylval = Attribute( yytext ); return _CTE_STRING; }

{ID}       { yylval = Attribute( yytext ); return _ID; }
.          { yylval = Attribute( yytext ); return *yytext; }

%%
