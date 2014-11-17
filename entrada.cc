<integer> a, b;
b = 10 modulo (5 + 2 * 3 );
a = (a + b) * (1 + 10 * a);

<boolean> c;
c = true;
c = true and false;
c = true or false;

c = b is greater than a;
c = b is greater than or equal to a;


Load: my_function
Input: <integer> <copy> bca, <boolean> <reference> gbo
Output: <integer> ret
{
	<boolean> d;

	d = a is lesser than b;
	d = a is lesser than or equal to b;

	<boolean> e;

	e = not ( b is different from a );


	Execute function other_function;
	Execute function other_function with a, b;

}