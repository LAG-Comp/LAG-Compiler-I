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

	For index from b to a execute{
		Print this "\t" this index this "\n";
		If index is equal to 70 execute{
			resultado = 40;
		}
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