#ifndef LAG_UTIL_H
#define LAG_UTIL_H

#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <map>

using namespace std;

struct Type {
	string name;

	Type() {}
	Type( string name ) { this->name = name; }
};

struct Attribute {
	string v;  // Value
	Type   t;  // type
	string c;  // code

	Attribute() {}  // initialized with empty string
	Attribute( string v, string t = "", string c = "" ) 
	{
		this->v = v;
		this->t.name = t;
		this->c = c;
	}
};

typedef map<string,Type> symbol_table;

bool is_number(const std::string& s);
string toStr( int n );
string label( string cmd, map<string,int> &label_counter ); 

void init_operation_results(map<string,Type> &operation_results);
void init_c_operands_table(map<string,string> &c_op);
void init_type_names(map<string,Type> &type_names);
 
#endif /* LAG_UTIL_H */