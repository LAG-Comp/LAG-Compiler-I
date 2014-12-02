Starting up...
<integer> a;
If 5 is lesser than 10 execute
{
	# Code #
}
End of file

E : E '+' E  { genBinaryOpCode(); }
  | E '-' E  
  | E '*' E  
  | E '/' E  
  | E _MOD E 
  | E _AND E 
  | E _OR E  
  | E _ET E  
  | E _DF E  
  | E _GT E  
  | E _GE E  
  | E _LT E  
  | E _LE E  