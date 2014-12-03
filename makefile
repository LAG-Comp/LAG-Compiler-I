all: output.cpp 
	cat output.cpp

output.cpp: trabalho input.cc 
	./trabalho < input.cc > output.cpp

lex.yy.c: trabalho.lex
	lex trabalho.lex

y.tab.c: trabalho.y 
	yacc -v trabalho.y 

util: LAG-Util.cpp LAG-Util.h
	g++ LAG-Util.h LAG-Util.cpp -o util.o

trabalho: lex.yy.c y.tab.c 
	g++ -o trabalho y.tab.c LAG-Util.cpp -lfl

clean:
	rm lex.yy.c y.tab.c y.output trabalho output.cpp