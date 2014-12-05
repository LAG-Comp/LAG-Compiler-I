
Global Matrix <integer> of size 3 by 10 mat; 

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
		resultado = m;
	}
	Else
	{
		resultado = Execute function MDC with ( a, b );
	}
}

Starting up...

<boolean> ghf;
ghf = not( 4 is lesser than 6 );
<integer> a;
a = 1;
mat(a,3) = 5;
a = mat(2,3);

End of file