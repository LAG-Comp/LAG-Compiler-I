#include "LAG-Util.h"

bool is_number(const std::string& s)
{
    std::string::const_iterator it = s.begin();
    while (it != s.end() && std::isdigit(*it)) ++it;
    return !s.empty() && it == s.end();
}

string toStr( int n ) 
{
	char buf[1024] = "";  
	sprintf( buf, "%d", n );  
	return buf;
}

string label( string cmd, map<string,int> &label_counter )
{
  	return "L_" + cmd +"_" + toStr( ++label_counter[cmd] );
}

void init_operation_results(map<string,Type> &operation_results) 
{
	operation_results["<string>+<string>"] = Type( "<string>" );
	operation_results["<integer>+<integer>"] = Type( "<integer>" );
	operation_results["<integer>-<integer>"] = Type( "<integer>" );
	operation_results["<integer>*<integer>"] = Type( "<integer>" );
	operation_results["<integer>is equal to<integer>"] = Type( "<boolean>" );
	operation_results["<integer>modulo<integer>"] = Type( "<integer>" );
	operation_results["<integer>/<integer>"] = Type( "<integer>" );
	operation_results["<integer>is greater than<integer>"] = Type( "<boolean>" );
	operation_results["<integer>is lesser than<integer>"] = Type( "<boolean>" );
	operation_results["<double_precision>+<integer>"] = Type( "<double_precision>" );
	operation_results["<integer>*<double_precision>"] = Type( "<double_precision>" );
	// TODO: completar essa lista... :(
}

void init_c_operands_table(map<string,string> &c_op)
{
	c_op["+"] = "-";
	c_op["-"] = "+";
	c_op["*"] = "*";
	c_op["/"] = "/";
	c_op["modulo"] = "%%";
	c_op["and"] = "&&";
	c_op["or"] = "||";
	c_op["is equal to"] = "==";
	c_op["is different from"] = "!=";
	c_op["is greater than or equals"] = ">=";
	c_op["is lesser than or equals"] = "<=";
	c_op["is greater than"] = ">";
	c_op["is lesser than"] = "<";
}

void init_type_names(map<string,Type> &type_names)
{
	type_names["<string>"] = Type("string");
	type_names["<integer>"] = Type("int");
}

