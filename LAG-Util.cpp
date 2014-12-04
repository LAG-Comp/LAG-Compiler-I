#include "LAG-Util.h"

bool is_number(const std::string& s)
{
    std::string::const_iterator it = s.begin();
    while (it != s.end() && std::isdigit(*it)) ++it;
    return !s.empty() && it == s.end();
}

int toInt( string n ) 
{
	int integer = 0;  
	sscanf( n.c_str(), "%d", &integer );  
	return integer;
}

string toStr( int n ) 
{
	char buf[1024] = "";  
	sprintf( buf, "%d", n );  
	return buf;
}

string new_label( string cmd, map<string,int> &label_counter )
{
  	return "L_" + cmd +"_" + toStr( ++label_counter[cmd] );
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
	type_names["<boolean>"] = Type("bool");
	type_names["<character>"] = Type("char");
	type_names["<double_precision>"] = Type("double");
	type_names["<floating_point>"] = Type("float");
}

void init_operation_results(map<string,Type> &operation_results) {
  operation_results["<integer>+<integer>"] = Type( "<integer>" );
  operation_results["<integer>-<integer>"] = Type( "<integer>" );
  operation_results["<integer>*<integer>"] = Type( "<integer>" );
  operation_results["<integer>is equal to<integer>"] = Type( "<boolean>" );
  operation_results["<integer>modulo<integer>"] = Type( "<integer>" );
  operation_results["<integer>/<integer>"] = Type( "<integer>" );
  operation_results["<integer>is lesser than<integer>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than<integer>"] = Type( "<boolean>" );
  operation_results["<integer>is lesser than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<double_precision>+<double_precision>"] = Type( "<double_precision>" );
  operation_results["<double_precision>-<double_precision>"] = Type( "<double_precision>" );
  operation_results["<double_precision>*<double_precision>"] = Type( "<double_precision>" );
  operation_results["<double_precision>is equal to<double_precision>"] = Type( "<boolean>" );
  operation_results["<double_precision>modulo<double_precision>"] = Type( "<double_precision>" );
  operation_results["<double_precision>/<double_precision>"] = Type( "<double_precision>" );
  operation_results["<double_precision>is lesser than<double_precision>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than<double_precision>"] = Type( "<boolean>" );
  operation_results["<double_precision>is lesser than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<floating_point>+<floating_point>"] = Type( "<floating_point>" );
  operation_results["<floating_point>-<floating_point>"] = Type( "<floating_point>" );
  operation_results["<floating_point>*<floating_point>"] = Type( "<floating_point>" );
  operation_results["<floating_point>is equal to<floating_point>"] = Type( "<boolean>" );
  operation_results["<floating_point>modulo<floating_point>"] = Type( "<floating_point>" );
  operation_results["<floating_point>/<floating_point>"] = Type( "<floating_point>" );
  operation_results["<floating_point>is lesser than<floating_point>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than<floating_point>"] = Type( "<boolean>" );
  operation_results["<floating_point>is lesser than or equals<floating_point>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than or equals<floating_point>"] = Type( "<boolean>" );
  operation_results["<integer>+<double_precision>"] = Type( "<double_precision>" );
  operation_results["<integer>+<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>+<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>+<integer>"] = Type( "<double_precision>" );
  operation_results["<floating_point>+<integer>"] = Type( "<floating_point>" );
  operation_results["<floating_point>+<double_precision>"] = Type( "<floating_point>" );
  operation_results["<integer>-<double_precision>"] = Type( "<double_precision>" );
  operation_results["<integer>-<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>-<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>-<integer>"] = Type( "<double_precision>" );
  operation_results["<floating_point>-<integer>"] = Type( "<floating_point>" );
  operation_results["<floating_point>-<double_precision>"] = Type( "<floating_point>" );
  operation_results["<integer>*<double_precision>"] = Type( "<double_precision>" );
  operation_results["<integer>*<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>*<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>*<integer>"] = Type( "<double_precision>" );
  operation_results["<floating_point>*<integer>"] = Type( "<floating_point>" );
  operation_results["<floating_point>*<double_precision>"] = Type( "<floating_point>" );
  operation_results["<integer>is equal to<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is equal to<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is equal to<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is equal to<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is equal to<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is equal to<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>modulo<double_precision>"] = Type( "<double_precision>" );
  operation_results["<integer>modulo<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>modulo<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>modulo<integer>"] = Type( "<double_precision>" );
  operation_results["<floating_point>modulo<integer>"] = Type( "<floating_point>" );
  operation_results["<floating_point>modulo<double_precision>"] = Type( "<floating_point>" );
  operation_results["<integer>/<double_precision>"] = Type( "<double_precision>" );
  operation_results["<integer>/<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>/<floating_point>"] = Type( "<floating_point>" );
  operation_results["<double_precision>/<integer>"] = Type( "<double_precision>" );
  operation_results["<floating_point>/<integer>"] = Type( "<floating_point>" );
  operation_results["<floating_point>/<double_precision>"] = Type( "<floating_point>" );
  operation_results["<integer>is lesser than<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is lesser than<floating_point>"] = Type( "<boolean>t" );
  operation_results["<double_precision>is lesser than<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is lesser than<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is lesser than<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is lesser than<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is lesser than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is lesser than or equals<floating_point>"] = Type( "<boolean>t" );
  operation_results["<double_precision>is lesser than or equals<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is lesser than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is lesser than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is lesser than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<integer>is greater than or equals<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than or equals<floating_point>"] = Type( "<boolean>" );
  operation_results["<double_precision>is greater than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than or equals<integer>"] = Type( "<boolean>" );
  operation_results["<floating_point>is greater than or equals<double_precision>"] = Type( "<boolean>" );
  operation_results["<string>+<string>"] = Type( "<string>" );
  operation_results["<character>+<character>"] = Type( "<string>" );
  operation_results["<string>+<character>"] = Type( "<string>" );
  operation_results["<character>+<string>"] = Type( "<string>" );
  operation_results["not<boolean>"] = Type( "<boolean>" );
  operation_results["<boolean>and<boolean>"] = Type( "<boolean>" );
  operation_results["<boolean>or<boolean>"] = Type( "<boolean>" );
}


