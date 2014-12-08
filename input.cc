
Starting up...
	
	Array <integer> of size 4 a;
	Array <integer> of size 4 b;
	a(0) = 4;
	a(1) = 2;
	a(2) = 5;
	a(3) = 3;

	For i from 0 to 4 execute{
		b(i) = 0;
	}

	[ a | filter ( x is lesser than 50 ) | for each ( Print this x this "\n"; ) ];

	[ a | filter ( x is lesser than 50 ) | sort ( increasing, b ) ];

	Print this "Look this.\n";

	[ b | filter ( x is lesser than 50 ) | for each ( Print this x this "\n"; ) ];

End of file