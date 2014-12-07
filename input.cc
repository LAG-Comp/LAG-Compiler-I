
Starting up...
	
	Array <integer> of size 9 a;
	For index from 0 to 9 execute{
		a(index) = (index+1)*2;
	}

	[ interval from 4 to 89 | filter ( x is lesser than 9 ) | for each ( a(5) = a(x-4); Print this x; ) ];

	

End of file