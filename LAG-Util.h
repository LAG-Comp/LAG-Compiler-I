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
	char level;
	int n_dim;
	int d1;
	int d2;

	Type() { 
		this->name = "";
		this->level = 'L';
		this->n_dim = 0; 
		this->d1 = 0; 
		this->d2 = 0; 
	}
	Type( string name ) { 
		this->name = name; 
		this->level = 'L';
		this->n_dim = 0; 
		this->d1 = 0; 
		this->d2 = 0;
	}
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
typedef map<string,int> var_temp_table;

bool is_number(const std::string& s);
string toStr( int n );
int toInt( string n );
string new_label( string cmd, map<string,int> &label_counter ); 

void init_operation_results(map<string,Type> &operation_results);
void init_c_operands_table(map<string,string> &c_op);
void init_type_names(map<string,Type> &type_names);
 
#endif /* LAG_UTIL_H */