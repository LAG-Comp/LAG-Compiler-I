
Starting up...
	
	Array <integer> of size 9 a;
	Array <integer> of size 9 b;

	For i from 0 to 9 execute{
		a(i) = 0;
		b(i) = 0;
	}

	[ interval from 1 to 10 | last ( 5 ) | split a to b using criterion x is lesser than 8 ];

	Print this "Look this.\n";
	[ a | filter ( x is lesser than 50 ) | for each ( Print this x this "\n"; ) ];

	[ b | filter ( x is lesser than 50 ) | for each ( Print this x this "\n"; ) ];

End of file
