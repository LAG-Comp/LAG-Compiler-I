Load: MDC !
Input: <integer> n, <integer> m
Output: <integer> resultado
{
	<integer> a;
	<integer> b;
	If n is greater than m execute
	{
		a = n;
		b = m;
	}
	Else 
	{
		a = m;
		b = n;
	}

	If b is equal to 0 execute
	{
		resultado = 0;
	}
	Else
	{
		resultado = Execute function MDC with ( a, b );
	}
}

Starting up...

	<integer> a;
	<integer> b;
	<integer> res;
	Print this "Digite dois inteiros, por favor: \n";
	Scan <integer> to a;
	Scan <integer> to b;
	Print this "Ai estão eles: " this a this " " this b this " " this a+b this " \n";
	res = Execute function MDC with (a, b);
	Print this "MDC entre os dois: " this res this "\n";

End of file