Global <integer> a, b;
b = 10 modulo (5 + 2 * 3 );
a = (a + b) * (1 + 10 * a);

Global <boolean> c;
c = true;
c = true and false;
c = true or false;

Global Array <integer> of size 3 arr;
Global Matrix <integer> of size 4 by 5 mat;

c = b is greater than a;
c = b is greater than or equals a;


Load: my_function
Input: <integer> <copy> bca, <boolean> <reference> gbo
Output: <integer> ret
{
	<boolean> d;

	d = a is lesser than b;
	d = a is lesser than or equals b;

	Array <integer> of size 3 arrl;
    Matrix <integer> of size 4 by 5 matl;

	<integer> f;
	f = Execute function one_function();

	Execute function other_function();
	Execute function other_function with( a, b );

	<boolean> e;

	e = [ for each x Execute function inexistent_function with (a,b,c,x) ];

	e = not ( b is different from a );
	e = Execute function one_function();

	If b is lesser than or equals a execute
	{
		dfg = Execute function uhuuu();
	}

	While a is lesser than or equals b repeat
	{
		<integer> ab;
		Print ab;
		Print "hello!\n";
	}

	For pudim from 1 to 4 execute
	{
		Print pudim;
	}

	Case teo
		equals 6:
		{
			Print "coisas 1";
		}
		case not:
		{
			Print "coisas default";
		}

	a = [ interval from 0 to 100 ];
}

Load: ostra
Input: <void>
Output: <void>
{
	Print "work!";
}

Starting up...
	<integer> gh;
	gh = Execute function my_function();
End of file