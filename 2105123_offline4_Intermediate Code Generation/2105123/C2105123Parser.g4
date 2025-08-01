parser grammar C2105123Parser;

options {
    tokenVocab = C2105123Lexer;
}

@parser::header {
    #include <iostream>
    #include <fstream>
    #include <string>
    #include <cstdlib>
	#include <vector>


    #include "C2105123Lexer.h"
	#include "HEADER_SYMBOL_TABLE/2105123_HashFunction.hpp"
	#include "HEADER_SYMBOL_TABLE/2105123_SymbolTable.hpp"
    using namespace std;


    extern ofstream parserLogFile;
    extern ofstream errorFile;
	extern SymbolTable smb_tb;

	//icg file

	extern ofstream code_asmFile;
	extern ofstream temp_codeFile;

    extern int syntaxErrorCount;
	extern vector<string> global_arguement_list;
	extern vector<pair<string,int>> global_variable_list;
	extern vector<pair<string,string>> global_parameter_list;
	extern vector<string>array_list;
	extern vector<string>arguement_list;
	extern string func_name;
	extern string type;
	extern bool func;
	//icg
	extern bool is_code_initialization;
	extern int local_offset;
	extern int global_offset;
	extern int label_count;
	extern vector<int> true_label,exit_label,next_label;
	extern map<string,string> label_map;
	extern vector<string>true_list,false_list,unconditional_jump_list;
	extern vector<int>condition_label,increment_label,outside_label,jumping_true,jumping_false,jumping_unconditional,tmp_vector;
	extern int tmp_label_cnt;
	extern int tmp_label_cnt2,unconditional_jump;
	extern int relational_assignment;
	extern int logical_assignment;
	extern string else_if_statement;
	extern string cur_file_name;
	extern int loop_count;
	extern int is_expression;
	extern bool loop_if;
	extern int logical_if_else;
	extern bool non_relational_logical;
	extern map<string,string>final_label_map; 
	extern int final_label_map_count;
	




}

@parser::members {
    void writeIntoCodeFile(const string message) {
        if (!temp_codeFile) {
            cout << "Error opening code.txt" << endl;
            return;
        }
        temp_codeFile << message << endl;
        temp_codeFile.flush();
		
    }	
	void write_final_asm(const string message)
	{
        if (!code_asmFile) {
            cout << "Error opening code.asm" << endl;
            return;
        }
        code_asmFile << message << endl;
        code_asmFile.flush();		
	}

    void writeIntoparserLogFile(const string message) {
        if (!parserLogFile) {
            cout << "Error opening parserLogFile.txt" << endl;
            return;
        }

        parserLogFile << message << endl;
        parserLogFile.flush();
		//writeIntoCodeFile(message);
    }

    void writeIntoErrorFile(const string message) {
        if (!errorFile) {
            cout << "Error opening errorFile.txt" << endl;
            return;
        }
        errorFile << message << endl;
        errorFile.flush();
    }

    /*void writeIntoOptimizedCodeFile(const string message) {
        if (!optimized_code_asmFile) {
            cout << "Error opening optimized_code_asm.asm" << endl;
            return;
        }
        optimized_code_asmFile << message << endl;
        optimized_code_asmFile.flush();
    }*/	
	void writeFile(const string msg1,const string msg2)
	{
		writeIntoparserLogFile(msg1);
		writeIntoparserLogFile(msg2);
	}



	void insert_variable(string name,string retType,int size,bool isArray=false)
	{  

		SymbolInfo *si=new SymbolInfo(name, "ID", retType, size);
		
		smb_tb.Insert(si);
		
	}
 
 	int in_variable_list(string name)
	{
		for(int i=0;i<global_variable_list.size();i++)
		{
			if(name==global_variable_list[i].first)
			 return 1;
		}
		return 0;
	}

	int in_parameter_list(string name)
	{
		for(int i=0;i<global_parameter_list.size();i++)
		{
			if(name==global_parameter_list[i].first)
			 return 1;
		}
		return 0;
	}
	void write_for_label_map(string l)
	{
		final_label_map_count+=1;
		final_label_map["L"+to_string(final_label_map_count)]="L"+to_string(label_count);
	}	
	void write_label()
	{
		label_count+=1;
		writeIntoCodeFile("L"+to_string(label_count)+":");
		write_for_label_map("L"+to_string(label_count));

	}	
	void write_push_pop()
	{
		writeIntoCodeFile("\tPUSH AX");
		writeIntoCodeFile("\tPOP AX");

	}
	void write_println(string s,int l)
	{

		writeIntoCodeFile("\tMOV AX, "+s+"       ; Line "+to_string(l));
		writeIntoCodeFile("\tCALL print_output");
		writeIntoCodeFile("\tCALL new_line");
	}
     void write_push_pop_line(int line)
	 {
		writeIntoCodeFile("\tPUSH AX");
		writeIntoCodeFile("\tPOP AX       ; Line "+to_string(line));
	 }	
	 int get_next_label()
	 {
		return (label_count+1);
	 }
	int extractTLNumber(const string& line) {
		size_t pos = line.find("TL");
		if (pos != string::npos && pos + 2 < line.size()) {
			string number_str;
			for (size_t i = pos + 2; i < line.size(); ++i) {
				if (isdigit(line[i])) {
					number_str += line[i];
				} else {
					break; 
				}
			}
			if (!number_str.empty()) {
				return stoi(number_str);
			}
		}
		return -1; 
	}
	string get_ID(const string &variable_name)
	{
	string actual_name = variable_name;
	int bracket_pos = actual_name.find('[');
	if (bracket_pos != string::npos) {
    actual_name = actual_name.substr(0, bracket_pos);
	}
		return actual_name;
	}
	void common_assembly1()
	{
		writeIntoCodeFile("\tPOP BX");
	}
	void common_assembly2()
	{
		writeIntoCodeFile("\tMOV AX, 2");
		writeIntoCodeFile("\tMUL BX");
		writeIntoCodeFile("\tMOV BX, AX");

	}	
	void common_assembly3()
	{
		writeIntoCodeFile("\tSUB AX, BX");
		writeIntoCodeFile("\tMOV BX, AX");
		//writeIntoCodeFile("\tPOP AX");
		writeIntoCodeFile("\tMOV SI, BX");
		writeIntoCodeFile("\tNEG SI");
		

	}
	bool function_parameter_exist(string func_name,string param_name)	
	{
		SymbolInfo *tmp=smb_tb.LookUp2(func_name);
		if(tmp!=nullptr)
		{
			

			if(tmp->isFunctionDefined() && tmp->isParameter(param_name))
			{
				return true;

			}
		}
		return false;
	}
	void write_func_call(string s,int l)
	{
		write_label();

		writeIntoCodeFile("\tCALL "+s+"       ; Line "+to_string(l));
		writeIntoCodeFile("\tPUSH AX");
		writeIntoCodeFile("\tPOP AX");


	} 

	bool is_relational_statement(string s)
	{
		if(s.find("<") != string::npos)
		{
			return true;
		}
		else if(s.find("<=") != string::npos)
		{
			return true;
		}
		else if(s.find(">") != string::npos)
		{
			return true;
		}
		else if(s.find(">=") != string::npos)
		{
			return true;
		}
		else if(s.find("==") != string::npos)
		{
			return true;
		}
		else if(s.find("!=") != string::npos)
		{
			return true;
		}
		return false;

	}

}



start :
    {
		write_final_asm(".MODEL SMALL\n.STACK 1000H\n.Data\n\tnumber DB \"00000$\"");
	} 
	pr = program
	{
		writeIntoparserLogFile("Line " + to_string($pr.line) + ": start : program\n");
		smb_tb.PrintAllScopeTable(parserLogFile);
		writeIntoparserLogFile("Total number of lines: " + to_string($pr.line) + "\nTotal number of errors: " + to_string(syntaxErrorCount));
		ifstream temp_code_reader("output/code.txt");
		cout<<"True Label:"<<endl;
		for(int i=0;i<true_label.size();i++)
		{
			cout<<true_label[i]<<" ";
		}
		cout<<endl;
		cout<<"Next Label:"<<endl;
		for(int i=0;i<next_label.size();i++)
		{
			cout<<next_label[i]<<" ";
		}
		cout<<endl;		
		cout<<"Exit Label:"<<endl;
		for(int i=0;i<exit_label.size();i++)
		{
			cout<<exit_label[i]<<" ";
		}
		cout<<endl;	
		for (const auto& pair : label_map) {
            cout << pair.first << ": " << pair.second << endl;
        }					
		if (!temp_code_reader) {
			cout << "Error opening temp code file (code.txt)" << endl;
		} else {
			string cur_sentence;
		    
			int i=0,j=0,k=0,l=0;
			while (getline(temp_code_reader, cur_sentence)) {
				if (cur_sentence.find("TL") != string::npos)
				{
					istringstream iss(cur_sentence);
                    string first_word;
					iss >> first_word;
					int index=extractTLNumber(cur_sentence);


					if(first_word=="JMP" && i==next_label.size() && j== true_label.size() && k<exit_label.size())
					{
						cur_sentence="\tJMP L"+to_string(exit_label[k]);
						k++;						
					}					
					else if(first_word=="JMP" && i<next_label.size())
					{
						cur_sentence="\tJMP L"+to_string(next_label[i]);
						i++;
					}
					else 
					{
						if(j<true_label.size())
						{
							cur_sentence="\t"+first_word+" L"+to_string(true_label[j]);
						    j++;
						}
					}
					

				}

				if (cur_sentence.find("SL") != string::npos)
				{
					istringstream iss(cur_sentence);
					string first_word;
					iss >> first_word;
					string second_word;
					iss>> second_word;
					cur_sentence="\t"+first_word+" "+label_map[second_word];


					
				}

				if(cur_sentence!="JMP ")
				    write_final_asm(cur_sentence);
				
				
			}
			temp_code_reader.close();
		}
	write_final_asm(";-------------------------------");
	write_final_asm(";         print library");         
	write_final_asm(";-------------------------------");
	write_final_asm("new_line proc");
	write_final_asm("    push ax");
	write_final_asm("    push dx");
	write_final_asm("    mov ah,2");
	write_final_asm("    mov dl,0Dh");
	write_final_asm("    int 21h");
	write_final_asm("    mov ah,2");
	write_final_asm("    mov dl,0Ah");
	write_final_asm("    int 21h");
	write_final_asm("    pop dx");
	write_final_asm("    pop ax");
	write_final_asm("    ret");
	write_final_asm("    new_line endp");
	write_final_asm("print_output proc  ;print what is in ax");
	write_final_asm("    push ax");
	write_final_asm("    push bx");
	write_final_asm("    push cx");
	write_final_asm("    push dx");
	write_final_asm("    push si");
	write_final_asm("    lea si,number");
	write_final_asm("    mov bx,10");
	write_final_asm("    add si,4");
	write_final_asm("    cmp ax,0");
	write_final_asm("    jnge negate");
	write_final_asm("    print:");
	write_final_asm("    xor dx,dx");
	write_final_asm("    div bx");
	write_final_asm("    mov [si],dl");
	write_final_asm("    add [si],'0'");
	write_final_asm("    dec si");
	write_final_asm("    cmp ax,0");
	write_final_asm("    jne print");
	write_final_asm("    inc si");
	write_final_asm("    lea dx,si");
	write_final_asm("    mov ah,9");
	write_final_asm("    int 21h");
	write_final_asm("    pop si");
	write_final_asm("    pop dx");
	write_final_asm("    pop cx");
	write_final_asm("    pop bx");
	write_final_asm("    pop ax");
	write_final_asm("    ret");
	write_final_asm("    negate:");
	write_final_asm("    push ax");
	write_final_asm("    mov ah,2");
	write_final_asm("    mov dl,'-'");
	write_final_asm("    int 21h");
	write_final_asm("    pop ax");
	write_final_asm("    neg ax");
	write_final_asm("    jmp print");
	write_final_asm("   print_output endp");
	write_final_asm(";-------------------------------");        		
	write_final_asm("\nEND main");
	}
	;

program returns [string name, int line]
    : pr=program u=unit
    {
        $name = $pr.name +"\n"+ $u.name;
        $line = $u.line;
        writeFile("Line " + to_string($line) + ": program : program unit\n", $name + "\n");
    }
    | u=unit
    {
        $name = $u.name;
        $line = $u.line;
        writeFile("Line " + to_string($line) + ": program : unit\n", $name + "\n");
    }
	| invalid
    ;

	
unit returns [string name, int line]
		: vdl=var_declaration
		{
			$name = $vdl.name;
			$line = $vdl.line;
			writeFile("Line " + to_string($line) + ": unit : var_declaration\n", $name + "\n");
		}
		| fdl=func_declaration
		{
			$name = $fdl.name;
			$line = $fdl.line;
			writeFile("Line " + to_string($line) + ": unit : func_declaration\n", $name + "\n");
		}
		| fdf=func_definition
		{
			$name = $fdf.name;
			$line = $fdf.line;
			writeFile("Line " + to_string($line) + ": unit : func_definition\n", $name + "\n");
		}
		;

     
func_declaration returns [string name ,int line]
        : ts=type_specifier ID 
		{

		}
		LPAREN prl=parameter_list 
		{

		}
		RPAREN SEMICOLON
		{
           $name=$ts.name+" "+$ID->getText()+$LPAREN->getText()+$prl.name+$RPAREN->getText()+$SEMICOLON->getText();
		   $line=$SEMICOLON->getLine();
		   writeFile("Line "+to_string($line)+": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",string($name)+string("\n"));
		   string n=$ID->getText();
		   string t=$ts.retType;
		   SymbolInfo *tmp=smb_tb.LookUp(n,t);
		   if(tmp==nullptr)
		   {
			    int fn_st_off=2;
				SymbolInfo *si=new SymbolInfo(n, "ID", t, -2);
				si->initializeAsFunction(t);
				si->setFunctionDeclared(true);
				si->setFunctionStackOffset(fn_st_off);


				if(global_parameter_list.size()>0)
				{
					for(int i=0;i<global_parameter_list.size();i++)
					{
						fn_st_off+=2;
					}
					for(int i=0;i<global_parameter_list.size();i++)
					{
						si->addFunctionParameter(global_parameter_list[i].first,global_parameter_list[i].second);
						si->setFunctionStackOffset_parameter(global_parameter_list[i].first,fn_st_off);
						fn_st_off-=2;
					}
				}

				smb_tb.Insert(si);					
		   }
		   global_parameter_list.clear();

		}
		| ts=type_specifier ID LPAREN RPAREN SEMICOLON
		{
           $name=$ts.name+" "+$ID->getText()+$LPAREN->getText()+$RPAREN->getText()+$SEMICOLON->getText();
		   $line=$SEMICOLON->getLine();
		   writeFile("Line "+to_string($line)+": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n",string($name)+string("\n"));
		   string n=$ID->getText();
		   string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp(n,t);
		   if(tmp==nullptr)
		   {
			    int fn_st_off=2;

				SymbolInfo *si=new SymbolInfo(n, "ID", t, -2);
				si->initializeAsFunction(t);
				si->setFunctionDeclared(true);
				si->setFunctionStackOffset(fn_st_off);
				smb_tb.Insert(si);	
		   }
		}
		;
		 
func_definition returns [string name,int line]
        : ts=type_specifier ID 
		{ 
			local_offset=0;
			bool error_exist=false;  
		    
			$name=$ts.name+" "+$ID->getText();
			cur_file_name=$ID->getText();
			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
			si->initializeAsFunction(t);
			si->setFunctionDefined(true);
			int fn_st_off=2;
			si->setFunctionStackOffset(fn_st_off);

			if(tmp==nullptr)
			{
				smb_tb.Insert(si);				
			}
			if(is_code_initialization==false)
			{
				is_code_initialization=true;
				write_final_asm(".CODE\n");

			}
			writeIntoCodeFile(si->getsymbolName()+" PROC");
			if(si->getsymbolName()=="main")
			{
				writeIntoCodeFile("\tMOV AX, @DATA");
				writeIntoCodeFile("\tMOV DS, AX");
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}
			else
			{
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}


		}
		LPAREN prl=parameter_list 
		{
			//local_offset=0;
			
			$name=$name+$LPAREN->getText()+$prl.name;
			if(global_parameter_list.size()>0)
			{
					for(int i=0;i<global_parameter_list.size();i++)
					{
						fn_st_off+=2;
					}
				for(int i=0;i<global_parameter_list.size();i++)
				{
					si->addFunctionParameter(global_parameter_list[i].first,global_parameter_list[i].second);
					
					si->setFunctionStackOffset_parameter(global_parameter_list[i].first,fn_st_off);
					fn_st_off-=2;
				}
				
			}
			
		}
		RPAREN
		{
			$line=$RPAREN->getLine();
			$name=$name+$RPAREN->getText();
			
			if(tmp!=nullptr && tmp->isFunctionDeclared()==true)
			{
			  	int m=tmp->matchesFunctionSignature(si);
				if(m==0)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
				}
				else if(m==1)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
				}
				else if(m==2)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
				}
				else if(m==2)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Parameter mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Parameter mismatch of "+$ID->getText()+"\n");
				}								

			}
			else if(tmp!=nullptr && tmp->isFunctionDeclared()==false)
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
			}
		}
		 cs=compound_statement
		{
		    
			$name=$name+$cs.name;
			$line=$cs.line;
			if($ts.retType=="void" && $cs.ret==true)
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
			}
			writeFile("Line "+to_string($line)+": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n",string($name)+string("\n"));
			if(cur_file_name=="main")
			{
			write_label();
			//exit_label pop done
			if(exit_label.empty()==false)
			exit_label.pop_back();
			exit_label.push_back(label_count);
			writeIntoCodeFile("\tADD SP, "+to_string(local_offset));
			writeIntoCodeFile("\tPOP BP");
			writeIntoCodeFile("\tMOV AX,4CH");
			writeIntoCodeFile("\tINT 21H");					
			}			
			write_label();

			if(local_offset>0)
			{
				cout<<"Local offset "<<local_offset<<endl;
				writeIntoCodeFile("\tADD SP, "+to_string(local_offset));
			}	
			writeIntoCodeFile("\tPOP BP");
			writeIntoCodeFile("\tRET "+to_string(si->getFunctionParameterCount()*2));
			writeIntoCodeFile($ID->getText()+" ENDP");	

			
			if(cur_file_name!="main" && si->getFunctionParameterCount()>0)
			 {
				//exit_label pop done
				for(int i=0;i<exit_label.size();i++)
				{
					cout<<exit_label[i]<<endl;
				}
				if(exit_label.empty()==false)
			    exit_label.pop_back();
				exit_label.push_back(label_count);
			 }

		}
		| ts=type_specifier ID 
		{
			local_offset=0;
			bool error_exist=false; 
			$name=$ts.name+" "+$ID->getText();
			cur_file_name=$ID->getText();			
			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp($ID->getText(),t);
				SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
				si->initializeAsFunction(t);
				si->setFunctionDefined(true);
				int fn_st_off=2;
				si->setFunctionStackOffset(fn_st_off);


			if(tmp==nullptr)
			{
				smb_tb.Insert(si);						
			}
			if(is_code_initialization==false)
			{
				is_code_initialization=true;
				write_final_asm(".CODE");
				
			}
			writeIntoCodeFile(si->getsymbolName()+" PROC");
			if(si->getsymbolName()=="main")
			{
				writeIntoCodeFile("\tMOV AX, @DATA");
				writeIntoCodeFile("\tMOV DS, AX");
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}
			else
			{
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}	
						
		}
		LPAREN RPAREN
		{	$line=$RPAREN->getLine();
			$name=$name+$LPAREN->getText()+$RPAREN->getText();
			if(tmp!=nullptr && tmp->isFunctionDeclared()==true)
			{
			  	int m=tmp->matchesFunctionSignature(si);
				if(m==0)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
				}
				else if(m==1)
				{
					error_exist=true;
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
				}

			}
			else if(tmp!=nullptr && tmp->isFunctionDeclared()==false)
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
			}			
		}			
		 cs=compound_statement
		{
            $name=$name+$cs.name;
			$line=$cs.line;

			if($ts.retType=="void" && $cs.ret==true)
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
			}
			writeFile("Line "+to_string($line)+": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n",string($name)+string("\n"));
			if(cur_file_name=="main")
			{
			write_label();
			//exit_label pop done
			cout<<"here"<<endl;
			if(exit_label.empty()==false)
			exit_label.pop_back();
			exit_label.push_back(label_count);
			writeIntoCodeFile("\tADD SP, "+to_string(local_offset));
			writeIntoCodeFile("\tPOP BP");
			writeIntoCodeFile("\tMOV AX,4CH");
			writeIntoCodeFile("\tINT 21H");					
			}			
			write_label();
			/*if(exit_label.empty()==false)
			exit_label.pop_back();*/
			writeIntoCodeFile("\tPOP BP");
			writeIntoCodeFile("\tRET");			
			writeIntoCodeFile($ID->getText()+" ENDP");	
			if(cur_file_name!="main" && si->getFunctionParameterCount()>0)
			    {
				   //exit_label pop done
				   if(exit_label.empty()==false)
			        exit_label.pop_back();
					exit_label.push_back(label_count);
				}	
		}		
        /*| ts=type_specifier ID  
		{  
			local_offset=0;
			bool error_exist=false; 
		    
			$name=$ts.name+" "+$ID->getText();
			cur_file_name=$ID->getText();			
			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
			si->initializeAsFunction(t);
			si->setFunctionDefined(true);

			if(tmp==nullptr)
			{
				smb_tb.Insert(si);				
			}
			writeIntoCodeFile(si->getsymbolName()+" PROC");
			if(si->getsymbolName()=="main")
			{
				writeIntoCodeFile("\tMOV AX, @DATA");
				writeIntoCodeFile("\tMOV DS, AX");
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}
			else
			{
				writeIntoCodeFile("\tPUSH BP");
				writeIntoCodeFile("\tMOV BP, SP");
			}
		}		
		LPAREN plr=parameter_list_err 
		{
          $name=$name+$LPAREN->getText()+$plr.name;
		}
		RPAREN
		{
			$name=$name+$RPAREN->getText();
		}
		cs=compound_statement	
		{
			$name=$name+$cs.name;
			$line=$cs.line;
			writeFile("Line "+to_string($line)+": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n",string($name)+string("\n"));				
			writeIntoCodeFile($ID->getText()+" ENDP");		
		
		}	*/
 		;	

parameter_list_err returns [string name,int line]
		:
		ts=type_specifier it=invalid_type
		{
          	syntaxErrorCount++;	
			$name=$ts.name;
			$line=$it.line;
			writeFile(string("Line ")+to_string($line)+string(": parameter_list : type_specifier\n"),string($name)+string("\n"));	
			writeIntoparserLogFile("Error at line "+to_string($line)+": syntax error, unexpected "+$it.name+", expecting RPAREN or COMMA\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": syntax error, unexpected "+$it.name+", expecting RPAREN or COMMA\n");		
		
		}
		;		


parameter_list returns [string name,int line]
        : prl=parameter_list COMMA ts=type_specifier ID
		{

			$name=$prl.name+$COMMA->getText()+$ts.name+" "+$ID->getText();
			$line=$ID->getLine();
			if(in_parameter_list($ID->getText())==0)
			{	
			global_parameter_list.push_back({$ID->getText(),$ts.name});
			writeFile(string("Line ")+to_string($line)+string(": parameter_list : parameter_list COMMA type_specifier ID\n"),string($name)+string("\n"));
			}
			else
			{
			  syntaxErrorCount++;
              writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+" in parameter\n");
			  writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+" in parameter\n");
			  writeFile(string("Line ")+to_string($line)+string(": parameter_list : parameter_list COMMA type_specifier ID\n"),string($name)+string("\n"));
			  
			}
		
		}
		| prl=parameter_list COMMA ts=type_specifier
		{ 	
			$name=$prl.name+$COMMA->getText()+$ts.name;
			$line=$ts.line;
			global_parameter_list.push_back({"",$ts.name});
			writeFile(string("Line ")+to_string($line)+string(": parameter_list  : parameter_list COMMA type_specifier\n"),string($name)+string("\n"));
		}		
 		| ts=type_specifier ID
		{	
			$name=$ts.name+" "+$ID->getText();
			$line=$ID->getLine();
			if(in_parameter_list($ID->getText())==0)
		    {	
			global_parameter_list.push_back({$ID->getText(),$ts.name});
		
			writeFile(string("Line ")+to_string($line)+string(": parameter_list : type_specifier ID\n"),string($name)+string("\n"));
			}
			else
			{
				syntaxErrorCount++;
              writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+" in parameter\n");	
			  writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+" in parameter\n");
			  writeFile(string("Line ")+to_string($line)+string(": parameter_list : type_specifier ID\n"),string($name)+string("\n"));			
			}			
		}
		| ts=type_specifier
		{	
			$name=$ts.name;
			$line=$ts.line;
			global_parameter_list.push_back({"",$ts.name});
			writeFile(string("Line ")+to_string($line)+string(": parameter_list  : type_specifier\n"),string($name)+string("\n"));			
		}		
 		;

 		
compound_statement returns [string name,int line,bool ret]
            : LCURL 
			{
				$name=$LCURL->getText();
				smb_tb.EnterScope();
			}
			sts=statements RCURL
			{

				
				$name=$name+"\n"+$sts.name+"\n"+$RCURL->getText();
				$line=$RCURL->getLine();
				writeFile(string("Line ")+to_string($line)+string(": compound_statement : LCURL statements RCURL\n"),string($name)+string("\n"));				

					int i=0;
					while(i<global_parameter_list.size())
					{  
						insert_variable(global_parameter_list[i].first,global_parameter_list[i].second,-1);
						i++;
					}
				    i=0;
					while(i<global_variable_list.size())
					{
						SymbolInfo *si=new SymbolInfo(global_variable_list[i].first, "ID","ID", global_variable_list[i].second);
		                
		                
						for(int j=0;j<array_list.size();j++)
						{
							if(array_list[j]==global_variable_list[i].first)
							{
								si->setIsArray(true);
								si->setArraySize(global_variable_list[i].second);
							}
						}
						smb_tb.Insert(si);
						i++;
					}					
				
				global_parameter_list.clear();
				global_variable_list.clear();	
				array_list.clear();			
				smb_tb.PrintAllScopeTable(parserLogFile);
				smb_tb.ExitScope();	
                $ret=$sts.ret;

			}
 		    | LCURL
			{
				//local_offset=0;
				$name=$LCURL->getText();
				smb_tb.EnterScope();
			}
			 RCURL
			{
				$name=$name+$RCURL->getText();
				$line=$RCURL->getLine();
				writeFile(string("Line ")+to_string($line)+string(": compound_statement : LCURL RCURL\n"),string($name)+string("\n"));
				int i=0;
				while(i<global_variable_list.size())
				{
						SymbolInfo *si=new SymbolInfo(global_variable_list[i].first, "ID",type, global_variable_list[i].second);
		                
		                
						for(int j=0;j<array_list.size();j++)
						{
							if(array_list[j]==global_variable_list[i].first)
							{  
								si->setIsArray(true);
								si->setArraySize(global_variable_list[i].second);
							}
						}
						smb_tb.Insert(si);						
						i++;
				}					
				global_variable_list.clear();					
				array_list.clear();
                smb_tb.PrintAllScopeTable(parserLogFile);
				smb_tb.ExitScope();
				$ret=false;
								
			}
 		    ;
var_declaration returns [string name,int line,string isok]
    : t=type_specifier dl=declaration_list sm=SEMICOLON {
		$isok=$dl.isok;
		$name=$t.name+" "+$dl.name+$sm->getText();
		$line=$sm->getLine();
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": var_declaration : type_specifier declaration_list SEMICOLON\n"));		
		bool error_exist=false;
		if($t.retType=="void")
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoErrorFile("Error at line "+to_string($line)+": Variable type cannot be void\n");
			writeIntoparserLogFile("Error at line "+to_string($line)+": Variable type cannot be void\n");
		}
		writeIntoparserLogFile(string($name)+string("\n"));
		for(int i=0;i<global_variable_list.size();i++)
		{  
						SymbolInfo *si=new SymbolInfo(global_variable_list[i].first, "ID",$t.name, global_variable_list[i].second);
		                
		                
						for(int j=0;j<array_list.size();j++)
						{
							if(array_list[j]==global_variable_list[i].first)
							{
								si->setIsArray(true);
								si->setArraySize(global_variable_list[i].second);
							}
						}
						smb_tb.Insert(si);	

						if(error_exist==false)	
						{
								
						if(smb_tb.get_current_scope_table_id()==1)
						{
							if(si->getIsArray())
							{


                            int arr_size=si->getArraySize();
							global_offset+=(arr_size*2);
							si->setStackOffset(global_offset);
							si->set_is_global(true);
							write_final_asm("\t"+si->getsymbolName()+" DW "+to_string(arr_size)+" DUP (0000H)");
							}
                            else{
							global_offset+=2;
							si->setStackOffset(global_offset);
							si->set_is_global(true);
							write_final_asm("\t"+si->getsymbolName()+" DW 1 DUP (0000H)");
							}
						}	
						else
						{
							if(si->getIsArray())
							{
							write_label();	
							int arr_size=si->getArraySize();	
							local_offset+=(2*arr_size);
							si->setStackOffset(local_offset);
							si->set_is_global(false);

							//for(int ar=0;ar<arr_size;ar++)
						    writeIntoCodeFile("\tSUB SP, "+to_string(arr_size*2));
							}
							else
							{
							local_offset+=2;
							si->setStackOffset(local_offset);
							si->set_is_global(false);
							writeIntoCodeFile("\tSUB SP, 2");
							}
						}
						}
						else
						{
							writeIntoCodeFile("Error exists at Line "+to_string($line));
						}
		}
		global_variable_list.clear();	
      }
    ;

		 
type_specifier returns [string name, string retType,int line]	
    : INT {
		
        $name = $INT->getText();
        $retType="int";
		$line=$INT->getLine();
        writeFile("Line " + to_string($INT->getLine()) + ": type_specifier : INT\n", $name+"\n");
		type=$retType;
		
		
    }
    | FLOAT {
        $name = $FLOAT->getText();
        $retType="float";
		$line=$FLOAT->getLine();
        writeFile("Line " + to_string($FLOAT->getLine()) + ": type_specifier : FLOAT\n", $name+"\n");
		type=$retType;
		
    }
    | VOID {
        $name = $VOID->getText();
        $retType="void";
		$line=$VOID->getLine();
        writeFile("Line " + to_string($VOID->getLine()) + ": type_specifier : VOID\n", $name+"\n");
		type=$retType;
		
		
    }
    ;

 		
declaration_list returns [string name,int line,string isok]
          : dcl=declaration_list COMMA ID
		  { 
			$name=$dcl.name+$COMMA->getText()+$ID->getText();
			$line=$ID->getLine();
			SymbolInfo *tmp=smb_tb.LookUp3($ID->getText());

			if(tmp==nullptr)
				global_variable_list.push_back({$ID->getText(),-1});
		    else
			    {	
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
				}		
			writeFile(string("Line ")+to_string($line)+string(": declaration_list : declaration_list COMMA ID\n"),string($name)+string("\n"));
			$isok=$dcl.isok;

		  }
		  
 		  | dcl=declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		  {
			$name = $dcl.name + $COMMA->getText() + $ID->getText() + $LTHIRD->getText()+$CONST_INT->getText()+$RTHIRD->getText();
			$line = $RTHIRD->getLine();
			SymbolInfo *tmp=smb_tb.LookUp3($ID->getText());
			if(tmp==nullptr)
				{
				global_variable_list.push_back({$ID->getText(), stoi($CONST_INT->getText())});
				array_list.push_back($ID->getText());
				
				}
		    else
			    {
					if(tmp->getIsArray()==true)
					{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");	
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					}
					else
					{
						global_variable_list.push_back({$ID->getText(), stoi($CONST_INT->getText())});
						array_list.push_back($ID->getText());
					}
				}				
			
			writeFile("Line " + to_string($line) + ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n", $name + "\n");
            $isok=$dcl.isok;

		  }
 		  | ID
		  { 
			
			$name = $ID->getText();
			$line = $ID->getLine();
							
			SymbolInfo *tmp=smb_tb.LookUp3($ID->getText());
			if(tmp==nullptr)
				global_variable_list.push_back({$ID->getText(), -1});

		    else
			    {	syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");	
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
				}			
			
             writeFile("Line " + to_string($line) + ": declaration_list : ID\n", $name + "\n");
			 $isok="true";

		  }
		| i=ID it=invalid_type ID
		{
			$name=$i->getText();
			syntaxErrorCount++;
			$line=$it.line;
			writeIntoparserLogFile("Line "+to_string($line)+": declaration_list : ID\n");
			writeIntoparserLogFile(string($name)+string("\n"));
			SymbolInfo *tmp=smb_tb.LookUp3($i->getText());
			if(tmp==nullptr)
			global_variable_list.push_back({$i->getText(),-1});
			
			writeIntoparserLogFile("Error at line "+to_string($line)+": syntax error, unexpected "+$it.name+", expecting COMMA or SEMICOLON\n"); 
			writeIntoErrorFile("Error at line "+to_string($line)+": syntax error, unexpected "+$it.name+", expecting COMMA or SEMICOLON\n");
			$isok="error";
			
		}	

 		| ID LTHIRD CONST_INT RTHIRD
		  {    
			    bool error_exist=false; 
				$name = $ID->getText() + $LTHIRD->getText() + $CONST_INT->getText() + $RTHIRD->getText();
				$line = $RTHIRD->getLine();
                SymbolInfo *tmp= smb_tb.LookUp3($ID->getText());
				if(!tmp)
				{
					global_variable_list.push_back({$ID->getText(), stoi($CONST_INT->getText())});
					array_list.push_back($ID->getText());
						
				}
				else 
				{
					if(tmp->getIsArray()==true)
					{
				    error_exist=true;		
					syntaxErrorCount++;	
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					}
					else
					{
						global_variable_list.push_back({$ID->getText(), stoi($CONST_INT->getText())});
						array_list.push_back($ID->getText());						
					}

				}
						
				
			    writeFile("Line " + to_string($line) + ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n", $name + "\n");	
				$isok="true";


			
		  }

 		  ;
 		  
statements returns [string name,int line,bool ret,string isok]
       : st=statement
	   {
		
		$line=$st.line;
		$ret=$st.ret;


		if($st.isok!="error")
		{
		$name=$st.name;	
		writeIntoparserLogFile(string("Line ")+to_string($line)+": statements : statement\n");
		writeIntoparserLogFile($name+"\n");
		}
		else
		{
			$name="";
		}
	   }
	   | sts=statements st=statement
	   {
			
        if($st.isok!="error")
		{
		$isok=$st.isok;
		$line=$st.line;
		$name=$sts.name+"\n"+$st.name;
		$ret=$st.ret;
		writeIntoparserLogFile(string("Line ")+to_string($line)+": statements : statements statement\n");		
		writeIntoparserLogFile($name+"\n");
		}
		else
		{
			$name=$sts.name;
			$line=$st.line;

		}
	
	   }
	   
	   ;
   
	   
statement returns [string name,int line,bool ret,string isok]
      : 
	  vdl=var_declaration
	  {
		 $name=$vdl.name;
		 $line=$vdl.line;
		 writeFile(string("Line ")+to_string($line)+string(": statement : var_declaration\n"),string($name)+string("\n"));
		 $ret=false;
		 $isok="true";
		
	  }

	  | exps=expression_statement
	  {
		if($exps.retType!="error")
		 {$name=$exps.name;
		 $line=$exps.line;
		 writeFile(string("Line ")+to_string($line)+string(": statement : expression_statement\n"),string($name)+string("\n"));
		 $isok="true";
		 $ret=false;
		 }
		 else
		 {
			$isok="error";
		 }
	  }
	  | cmps=compound_statement
	  {
		 $name=$cmps.name;
		 $line=$cmps.line;
		 writeFile(string("Line ")+to_string($line)+string(": statement : compound_statement\n"),string($name)+string("\n"));
		 $ret=false;
		 $isok=true;
	  }
	  | 
	  FOR LPAREN 
	  {
		loop_if=true;
        loop_count+=1;
        writeIntoCodeFile("START"+to_string(loop_count)+":");
		write_for_label_map("START"+to_string(loop_count));
		condition_label.push_back(loop_count);
		outside_label.push_back(loop_count);
		increment_label.push_back(loop_count);

	  }
	  exps1=expression_statement 
	  {
      
		writeIntoCodeFile("COND"+to_string(loop_count)+":");
		write_for_label_map("COND"+to_string(loop_count));

	  }
	  exps2=expression_statement 
	  {

		
        //if(label_map.find("SL"+to_string(tmp_label_cnt2-1))==label_map.end())
		label_map["SL"+to_string(tmp_label_cnt2-1)]="LOOP_BODY"+to_string(loop_count);
		write_for_label_map("LOOP_BODY"+to_string(loop_count));
		label_map["SL"+to_string(tmp_label_cnt2)]="OUTSIDE"+to_string(loop_count);
		write_for_label_map("OUTSIDE"+to_string(loop_count));
		writeIntoCodeFile("OPERATION"+to_string(loop_count)+":");
		write_for_label_map("OPERATION"+to_string(loop_count));


		


	  }
	  exps3=expression 
	  {
		writeIntoCodeFile("\tJMP COND"+to_string(condition_label[condition_label.size()-1]));
		writeIntoCodeFile("LOOP_BODY"+to_string(loop_count)+":");
		write_for_label_map("LOOP_BODY"+to_string(loop_count));
		
	  }
	  RPAREN 
	  {
	  }
	  st=statement
	  {
	
	   writeIntoCodeFile("\tJMP OPERATION"+to_string(increment_label[increment_label.size()-1]));

	  increment_label.pop_back();	
      writeIntoCodeFile("OUTSIDE"+to_string(outside_label[outside_label.size()-1])+":");
	  write_for_label_map("OUTSIDE"+to_string(outside_label[outside_label.size()-1]));
	  outside_label.pop_back();
	  int idx=condition_label[condition_label.size()-1]-1;
	  condition_label.pop_back();
	  loop_if=false;
	  

	



		
	  }
	  |
	  IF
      {
		write_label();
	  }
	  LPAREN exp=expression
	  {
		int tmp_2=tmp_label_cnt2;
		int tmp_1=tmp_label_cnt2-1;
		string index="SL"+to_string(tmp_1);
		if(loop_if==false)
		{label_map[index]="L"+to_string(get_next_label());
		write_for_label_map("L"+to_string(get_next_label()));
		}
		else
		{label_map[index]="OPERATION"+to_string(loop_count);
		write_for_label_map("OPERATION"+to_string(loop_count));
		}
	  }
	   RPAREN st=statement
	  {
		
        $name = $IF->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText() + $st.name;
        $line = $st.line;
        writeFile("Line " + to_string($line) + ": statement : IF LPAREN expression RPAREN statement\n", string($name + "\n"));
		$ret=false;
		index="SL"+to_string(tmp_2);
		label_map[index]="L"+to_string(get_next_label());
		write_for_label_map("L"+to_string(get_next_label()));


	  }
	  |
	  IF 
	  {  
		else_if_statement = "else if";	
		write_label();	

	  }
	  LPAREN exp=expression
	  {	
		
		int tmp_2=tmp_label_cnt2;
		int tmp_1=tmp_label_cnt2-1;

		cout<<"TRUE "<<tmp_1<<"    FALSE "<<tmp_2<<endl;

		string index="SL"+to_string(tmp_1);
		
		label_map[index]="L"+to_string(get_next_label());	
 
		int tmp2=tmp_label_cnt2;	
		index="SL"+to_string(tmp_2);
		
	  }
	   RPAREN st1=statement 
	   {
		true_list.push_back("L"+to_string(get_next_label()));


        	
	   }		
	   ELSE 
	   {
		if(else_if_statement=="else if")
		{
			
			unconditional_jump+=1;
			writeIntoCodeFile("\tJMP SLunconditional"+to_string(unconditional_jump));
			unconditional_jump_list.push_back("SLunconditional"+to_string(unconditional_jump));
			else_if_statement=="else";
		}
		false_list.push_back(index);

		       
	   }
	   st2=statement	   
	  {
					
		if(true_list.size()>0 && false_list.size()>0 && true_list.size()==false_list.size())
		{
          for(int i=0;i<false_list.size()-1;i++)
		  {
			if(label_map.find(false_list[i])==label_map.end())
			{
				label_map[false_list[i]]=true_list[i];


			}
		  }
		}
		for(int i=0;i<unconditional_jump_list.size();i++)
		{
			if(loop_if==false)
			{label_map[unconditional_jump_list[i]]="L"+to_string(get_next_label());	

			}
			else
			{label_map[unconditional_jump_list[i]]="OPERATION"+to_string(loop_count);

			}				
		}		
		int x;
		if ($st2.name.find("if") == 0) {    
			else_if_statement = "else if";	
		}
		else
		{
		else_if_statement = "else";
		index="SL"+to_string(tmp_2);	
		label_map[index]="L"+to_string(label_count);

		

		}



		
		$name = $IF->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText()+ $st1.name + $ELSE->getText() +" "+ $st2.name;
        $line = $st2.line;
        writeFile("Line " + to_string($line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n", $name + "\n");
		$ret=false;
		true_list.clear();
		false_list.clear();
		unconditional_jump_list.clear();
	  }

	  | WHILE LPAREN 
	  {
		is_expression=1;
        loop_count++;
		condition_label.push_back(loop_count);
		outside_label.push_back(loop_count);		
		writeIntoCodeFile("START"+to_string(loop_count)+":");
		write_for_label_map("START"+to_string(loop_count));
		
		writeIntoCodeFile("COND"+to_string(loop_count)+":");
		write_for_label_map("COND"+to_string(loop_count));


	  }
	  exp=expression 
	  {
		
		label_map["SL"+to_string(tmp_label_cnt2-1)]="LOOP_BODY"+to_string(loop_count);
		label_map["SL"+to_string(tmp_label_cnt2)]="OUTSIDE"+to_string(loop_count);
		writeIntoCodeFile("LOOP_BODY"+to_string(loop_count)+":");
		write_for_label_map("LOOP_BODY"+to_string(loop_count));

		is_expression=false;



	  }
	  RPAREN st=statement
	  {
		$name = $WHILE->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText() + $st.name;
        $line = $st.line;
        writeFile("Line " + to_string($line) + ": statement : WHILE LPAREN expression RPAREN statement\n", $name + "\n");
		$ret=false;
		writeIntoCodeFile("\tJMP COND"+to_string(condition_label[condition_label.size()-1]));
		condition_label.pop_back();
        writeIntoCodeFile("OUTSIDE"+to_string(outside_label[outside_label.size()-1])+":");
		write_for_label_map("OUTSIDE"+to_string(outside_label[outside_label.size()-1]));
	    outside_label.pop_back();
				

	  }
	  |
	  {
		write_label();
	  } 
	  PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		bool error_exist=false;
		 $name=$PRINTLN->getText()+$LPAREN->getText()+$ID->getText()+$RPAREN->getText()+$SEMICOLON->getText();
		 $line=$SEMICOLON->getLine();
		 writeIntoparserLogFile("Line " + to_string($line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		 if(smb_tb.LookUp2($ID->getText())==nullptr)
		 {
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+$ID->getText()+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+$ID->getText()+"\n");
		 }
		 writeIntoparserLogFile($name + "\n");
		 $ret=false;
		 if(error_exist==false)
		 {
			string s;
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			if(tmp!=nullptr)
			{
			 if(tmp->get_is_global())
				{
					s=$ID->getText();
				}
				else
				{
					s="[BP-"+to_string(tmp->getStackOffset())+"]";
				}
			}
			write_println(s,$line);
		 }
		 else
		 {
			writeIntoCodeFile("Error exists");
		 }


	  }
	  |
	  {
		write_label();
	  } 
	  RETURN exp=expression SEMICOLON
	  {
		$name=$RETURN->getText()+" "+$exp.name+$SEMICOLON->getText();
		$line=$SEMICOLON->getLine();
		writeFile("Line " + to_string($line) + ": statement : RETURN expression SEMICOLON\n", $name + "\n");
		$ret=true;
		$isok="true";
		tmp_label_cnt+=1;
		writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
		exit_label.push_back(get_next_label());
		write_label();
		if(local_offset>0)
		writeIntoCodeFile("\tADD SP, "+to_string(local_offset));
		writeIntoCodeFile("\tPOP BP");
		SymbolInfo *tmp=smb_tb.LookUp2(cur_file_name);
		if(tmp!=nullptr)
		writeIntoCodeFile("\tRET "+to_string(tmp->getFunctionParameterCount()*2));
		/*if(cur_file_name=="main")
		{
		write_label();
		exit_label.push_back(label_count);
		writeIntoCodeFile("\tADD SP, "+to_string(local_offset));
		writeIntoCodeFile("\tPOP BP");
		writeIntoCodeFile("\tMOV AX,4CH");
		writeIntoCodeFile("\tINT 21H");	
		}	
		else
		{
			//exit_label.push_back(label_count);
					
			
		}*/


	  }


	  ;


expression_statement returns [string name,string retType,int line ,int next_token]
            : SEMICOLON		
			{  
				$name=$SEMICOLON->getText();
				$line=$SEMICOLON->getLine();
				$retType="int";
				writeFile(string("Line ")+to_string($line)+string(": expression_statement : SEMICOLON\n"),string($name)+string("\n"));
			}	
			| exp=expression 
			{
				if($exp.retType!="error")
				{$name=$exp.name;
				$line=$exp.line;
				$retType=$exp.retType;
				$next_token=_input->LA(1);

				}
				else
				{
					$retType="error";
				}


			}
			SEMICOLON
			{
               if($retType!="error" && $next_token==SEMICOLON)
			   
				{
				$name=$name+$SEMICOLON->getText();
				$line=$SEMICOLON->getLine();
				writeFile(string("Line ")+to_string($line)+string(": expression_statement : expression SEMICOLON\n"),string($name)+string("\n"));
				}
				else
				{
					$retType="error";
				}
					   

			}	
			;


	  
variable returns [string name,string retType,int line]
     : ID 	
	 {
		bool error_exist=false;
		
		$name=$ID->getText();
		$line=$ID->getLine();
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": variable : ID\n"));
		SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
		if(tmp==nullptr && !in_variable_list($ID->getText()) && !in_parameter_list($ID->getText()))
		{
			error_exist=true;
			
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			$retType=type;

		}

		if(tmp && tmp->getIsArray())
		{
			error_exist=true;
			
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Type mismatch, "+string($ID->getText())+" is an array\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Type mismatch, "+string($ID->getText())+" is an array\n");
			$retType=tmp->getReturnType();			
		}
		writeIntoparserLogFile(string($name)+string("\n"));
		if(tmp)
		{$retType=tmp->getReturnType();}
		else
		{$retType=type;}

	 }	
	 | ID LTHIRD exp=expression RTHIRD 
	 {
		bool error_exist=false;
		
		$name=$ID->getText()+$LTHIRD->getText()+$exp.name+$RTHIRD->getText();
		$line=$RTHIRD->getLine();
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": variable : ID LTHIRD expression RTHIRD\n"));
		if($exp.retType!="int")
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Expression inside third brackets not an integer\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Expression inside third brackets not an integer\n");
		}
		SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
		if(tmp==nullptr && !in_variable_list($ID->getText()) && !in_parameter_list($ID->getText()))
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");

		}
		if(tmp!=nullptr && tmp->getIsArray()==false)
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": "+$ID->getText()+" not an array\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": "+$ID->getText()+" not an array\n");
			
		}

		if(tmp)
		{$retType=tmp->getReturnType();}
		else
		{$retType=type;}
		writeIntoparserLogFile(string($name)+string("\n"));
		if(error_exist==false)
		{
			writeIntoCodeFile("\tPUSH AX");
		}

	 }
	 ;
	 
expression returns [string name,string retType,int line]
       : le=logic_expression
	   {
		$retType=$le.retType;
		if($retType!="error")
		{
		$name=$le.name;
		$retType=$le.retType;
		$line=$le.line;
		writeFile(string("Line ")+to_string($line)+string(": expression : logic_expression\n"),string($name)+string("\n"));
		}

	   }


	   | 
	   {
		write_label();
		relational_assignment=1;
		logical_assignment=1;
	   }
	   v=variable 
	   {
		string actual_id_name=get_ID($v.name);
		SymbolInfo *tmp=smb_tb.LookUp2(actual_id_name);
		if(tmp!=nullptr)
		{
			if(tmp->getIsArray())
			{
				common_assembly1();
				common_assembly2();
				writeIntoCodeFile("\tPUSH BX");


			}
			else
			{
                 
			}

		}

	   }
	   ASSIGNOP le=logic_expression 	
	   {
		bool error_exist=false;
		
		if($v.retType!="error" && $le.retType!="error")
		{
		
		string actual_assign_name=get_ID($le.name);
		
		$name=$v.name+$ASSIGNOP->getText()+$le.name;
		$retType=$le.retType;
		$line=$le.line;
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": expression : variable ASSIGNOP logic_expression\n"));	
		    if($v.retType=="int" && $le.retType=="float")
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Type Mismatch\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Type Mismatch\n");				
			}
			if($le.retType=="void" || $v.retType=="void")
			{
				error_exist=true;
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Void function used in expression\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Void function used in expression\n");
			}		
			if(error_exist==true)
			{
				writeIntoCodeFile("error exist");
			}
			else
			{
				
				SymbolInfo *tmp2=smb_tb.LookUp2(actual_assign_name);
				if(tmp!=nullptr)
				{
					if(tmp->getIsArray())
					{

                       if(tmp2!=nullptr && tmp2->getIsArray())
					   {
						common_assembly1();
						common_assembly2();
						if(tmp2->get_is_global())
						writeIntoCodeFile("\tMOV AX, "+actual_assign_name+"[BX]");
						else
						{
							writeIntoCodeFile("\tMOV AX, "+to_string(tmp->getStackOffset()));
							writeIntoCodeFile("\tSUB AX, BX");
							writeIntoCodeFile("\tMOV BX, AX");
							writeIntoCodeFile("\tMOV SI, BX");
							writeIntoCodeFile("\tNEG SI");
							writeIntoCodeFile("\tMOV AX, [BP+SI]");								
						}
						writeIntoCodeFile("\tPOP BX");
						writeIntoCodeFile("\tPUSH AX");
						writeIntoCodeFile("\tMOV AX, "+to_string(tmp->getStackOffset()));
						common_assembly3();
						writeIntoCodeFile("\tPOP AX");
						writeIntoCodeFile("\tMOV [BP+SI], AX");



					   }
					   else
					   {

                        writeIntoCodeFile("\tPOP BX");
						if(tmp->get_is_global()==true)
						{
						writeIntoCodeFile("\tMOV "+actual_id_name+"[BX], AX");
						}
						else
						{
							
							writeIntoCodeFile("\tPUSH AX");
							writeIntoCodeFile("\tMOV AX, "+to_string(tmp->getStackOffset()));
							common_assembly3();
							writeIntoCodeFile("\tPOP AX");
							writeIntoCodeFile("\tMOV [BP+SI], AX");
							
						}



					   }

					}
					else
					{
						if(tmp2!=nullptr && tmp2->getIsArray())
						{
							
                             
							 common_assembly1();
							 common_assembly2();
							 writeIntoCodeFile("\tMOV AX, "+to_string(tmp2->getStackOffset()));
							 common_assembly3();
							 writeIntoCodeFile("\tMOV AX, [BP+SI]");
							 writeIntoCodeFile("\tMOV [BP+SI], CX");
							
						}
						else
						{
							
						}
						
						if(function_parameter_exist(cur_file_name,tmp->getsymbolName()))
						{
							SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
							writeIntoCodeFile("\tMOV [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(tmp->getsymbolName()))+"], AX");


						}
						else if(tmp->get_is_global())
						{
							
							writeIntoCodeFile("\tMOV "+tmp->getsymbolName()+", AX");
							
						}
						else
						{
							writeIntoCodeFile("\tMOV [BP-"+to_string(tmp->getStackOffset())+"], AX");
						}
						
					}
					write_push_pop();
				}
				else
				{
					
					if(function_parameter_exist(cur_file_name,actual_id_name))
					{
						SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
						writeIntoCodeFile("\tMOV [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"], AX");	
						write_push_pop();
					}
				}
				

			}

		writeIntoparserLogFile(string($name)+string("\n"));
		}
		else
		{
			$retType="error";
		}
		relational_assignment=0;
		logical_assignment=0;
	
	   }

	   ;

logic_expression returns [string name,string retType,int line]
         : re=rel_expression 	
		 {
			$retType=$re.retType;
			if($retType!="error")
			{
			$line=$re.line;
			$name=$re.name;
			$retType=$re.retType;
			writeFile(string("Line ")+to_string($line)+": logic_expression : rel_expression\n",string($name)+"\n");
			}

		 }
		 | re1=rel_expression LOGICOP 
		 {
			
			if($LOGICOP->getText()=="||" && (logical_assignment==1))	
			{	
			writeIntoCodeFile("\tCMP AX, 0");
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJNE TL"+to_string(tmp_label_cnt));

			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
			write_label();
			next_label.push_back(label_count);
			label_count+=1;
			true_label.push_back(label_count);			
			

			}	
			else if($LOGICOP->getText()=="||" && logical_assignment==0)	
			{
			if(is_relational_statement($re1.name))	
			{
		    logical_if_else+=1;
			int tmp_2=tmp_label_cnt2;
			int tmp_1=tmp_label_cnt2-1;
			//cout<<"TRUE "<<tmp_1<<"    FALSE "<<tmp_2<<endl;
			string index="SL"+to_string(tmp_1);
			
			label_map[index]="JMP_UNCOND"+to_string(logical_if_else);	
			cout<<"Jumping instruction ......................... "<<label_map[index]<<endl;
			jumping_unconditional.push_back(logical_if_else);	 
			int tmp2=tmp_label_cnt2;	
			index="SL"+to_string(tmp_2);
			label_map[index]="JMP_FALSE"+to_string(logical_if_else);	
			jumping_false.push_back(logical_if_else);
			cout<<"logical if else label "<<tmp_1<<" ////// "<<tmp_2<<endl;		
							
			writeIntoCodeFile("JMP_FALSE"+to_string(jumping_false[jumping_false.size()-1])+":");
			write_for_label_map("JMP_FALSE"+to_string(jumping_false[jumping_false.size()-1]));	
			jumping_false.pop_back();	
			tmp_vector.push_back(tmp_2);
			}
			else
			{
			logical_if_else+=1;	
		    //writeIntoCodeFile("\start for 1 no operand of or");		

			writeIntoCodeFile("\tCMP AX, 1");
			writeIntoCodeFile("\tJE JMP_UNCOND"+to_string(logical_if_else));	
			jumping_unconditional.push_back(logical_if_else);
			writeIntoCodeFile("\tJMP JMP_FALSE"+to_string(logical_if_else));	 
			writeIntoCodeFile("JMP_FALSE"+to_string(logical_if_else)+":");
			write_for_label_map("JMP_FALSE"+to_string(logical_if_else));
							

			}			 					
			}

			else if($LOGICOP->getText()=="&&" && (logical_assignment==1))
			{
			writeIntoCodeFile("\tCMP AX, 0");
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJNE TL"+to_string(tmp_label_cnt));

			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
			write_label();
			true_label.push_back(label_count);
			label_count+=1;

					

			}
			else if($LOGICOP->getText()=="&&" && logical_assignment==0)	
			{
			if(is_relational_statement($re1.name))			
		    {
			logical_if_else+=1;	
			int tmp_2=tmp_label_cnt2;
			int tmp_1=tmp_label_cnt2-1;
			//cout<<"TRUE "<<tmp_1<<"    FALSE "<<tmp_2<<endl;
			string index="SL"+to_string(tmp_1);
			label_map[index]="JMP_FALSE"+to_string(logical_if_else);	
			jumping_false.push_back(logical_if_else);			
 
			int tmp2=tmp_label_cnt2;	
			index="SL"+to_string(tmp_2);
			label_map[index]="JMP_UNCOND"+to_string(logical_if_else);	
			cout<<"Jumping instruction ......................... "<<label_map[index]<<endl;
			jumping_unconditional.push_back(logical_if_else);	
			cout<<"logical if else label "<<tmp_1<<" ////// "<<tmp_2<<endl;	
							
			writeIntoCodeFile("JMP_FALSE"+to_string(jumping_false[jumping_false.size()-1])+":");
			write_for_label_map("JMP_FALSE"+to_string(jumping_false[jumping_false.size()-1]));	
			jumping_false.pop_back();	
			tmp_vector.push_back(tmp_2+1);	
			}
			else
			{

			logical_if_else+=1;	
		    //writeIntoCodeFile("\start for 1 no operand of or");		

			writeIntoCodeFile("\tCMP AX, 0");
			writeIntoCodeFile("\tJE JMP_UNCOND"+to_string(logical_if_else));	
			jumping_unconditional.push_back(logical_if_else);
			writeIntoCodeFile("\tJMP JMP_FALSE"+to_string(logical_if_else));	 
			writeIntoCodeFile("JMP_FALSE"+to_string(logical_if_else)+":");	
			write_for_label_map("JMP_FALSE"+to_string(logical_if_else));			
			//writeIntoCodeFile("not implemented yet");
			}	 		
			}
			
			else
			{
				//writeIntoCodeFile("yet to be implemented..............................");
			}

			

		 }
		 re=rel_expression 
		 {
			
			if($re1.retType!="error" && $re.retType!="error")
			{
			$line=$re.line;
			$name=$re1.name+string($LOGICOP->getText())+$re.name;
			if($re1.retType=="float"||$re.retType=="float")
			$retType="float";
			else
			$retType="int";
			writeFile(string("Line ")+to_string($line)+": logic_expression : rel_expression LOGICOP rel_expression\n",string($name)+"\n");
			if($LOGICOP->getText()=="||"&& (logical_assignment==1))	
			{
				
			writeIntoCodeFile("\tCMP AX, 0");
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJNE TL"+to_string(tmp_label_cnt));
			//label_count+=1;
			
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
			
			true_label.push_back(label_count);

			writeIntoCodeFile("L"+to_string(true_label[true_label.size()-1])+":");
			write_for_label_map("L"+to_string(true_label[true_label.size()-1]));
			writeIntoCodeFile("\tMOV AX, 1       ; Line "+to_string($line));

			label_count+=1;
			int l=label_count;
			writeIntoCodeFile("\tJMP L"+to_string(label_count));

			write_label();
			
			writeIntoCodeFile("\tMOV AX, 0");
			writeIntoCodeFile("L"+to_string(l)+":");
			write_for_label_map("L"+to_string(l));
			next_label.push_back(label_count);				

			}	
			else if($LOGICOP->getText()=="||"&& logical_assignment==0)
		    {
				if(is_relational_statement($re.name))
				{writeIntoCodeFile("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1])+":");
				write_for_label_map("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
				jumping_unconditional.pop_back();

				writeIntoCodeFile("\tJMP SL"+to_string(tmp_vector[tmp_vector.size()-1]+1));
				tmp_vector.pop_back();
				}
				else
				{
					//writeIntoCodeFile("not implemented yet");

				
					writeIntoCodeFile("\tCMP AX, 1");
					writeIntoCodeFile("\tJE JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
					writeIntoCodeFile("\tJMP L"+to_string(get_next_label()+1));
					writeIntoCodeFile("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1])+":");
					write_for_label_map("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
					jumping_unconditional.pop_back();

						
				}
				

			}

			else if($LOGICOP->getText()=="&&" && (logical_assignment==1))	
			{
			
			writeIntoCodeFile("\tCMP AX, 0");
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJNE TL"+to_string(tmp_label_cnt));

			
			tmp_label_cnt+=1;
			writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
		
			true_label.push_back(label_count);
			writeIntoCodeFile("L"+to_string(true_label[true_label.size()-1])+":");
			write_for_label_map("L"+to_string(true_label[true_label.size()-1]));
			writeIntoCodeFile("\tMOV AX, 1       ; Line "+to_string($line));

			label_count+=1;
			int l=label_count;
			writeIntoCodeFile("\tJMP L"+to_string(label_count));

			write_label();
			
			writeIntoCodeFile("\tMOV AX, 0");
			writeIntoCodeFile("L"+to_string(l)+":");
			write_for_label_map("L"+to_string(l));
			next_label.push_back(label_count);
			next_label.push_back(label_count);
			
						

			}
			else if($LOGICOP->getText()=="&&" && logical_assignment==0)
			{
				if(is_relational_statement($re.name))
				{writeIntoCodeFile("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1])+":");
				write_for_label_map("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
				jumping_unconditional.pop_back();
				writeIntoCodeFile("\tJMP SL"+to_string(tmp_vector[tmp_vector.size()-1]+1));
				tmp_vector.pop_back();
				}
			else
			{
					writeIntoCodeFile("\tCMP AX, 0");
					writeIntoCodeFile("\tJE JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
					writeIntoCodeFile("\tJMP L"+to_string(get_next_label()));
					writeIntoCodeFile("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1])+":");
					write_for_label_map("JMP_UNCOND"+to_string(jumping_unconditional[jumping_unconditional.size()-1]));
					writeIntoCodeFile("\tJMP L"+to_string(get_next_label()+1));
					jumping_unconditional.pop_back();
					write_label();
			}				
			}
			

		
			



			}
			else
			{
				$retType="error";
			}	
			logical_assignment=0;	
		 }	


		 ;
			
rel_expression returns [string name, string retType, int line]
		: se1=simple_expression
		{
			$retType=$se1.retType;
			if($retType!="error")
			{
			$line = $se1.line;
			$name = $se1.name;
			$retType = $se1.retType;
			writeFile("Line " + to_string($line) + ": rel_expression : simple_expression\n", string($name) + string("\n"));
			}
			//logical_assignment=1;
			//writeIntoCodeFile("from here...................................................");
			


		}

		| se1=simple_expression 
		{
			//writeIntoCodeFile("ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo");
			writeIntoCodeFile("\tMOV DX, AX");
		}
		RELOP se2=simple_expression
		{
			if($se1.retType!="error" && $se2.retType!="error")
			{
			$line = $se2.line;
			$name = $se1.name + string($RELOP->getText()) + $se2.name;
			if($se1.retType=="float"||$se2.retType=="float")
			$retType="float";
			else
			$retType="int";
			writeFile("Line " + to_string($line) + ": rel_expression : simple_expression RELOP simple_expression\n", $name + "\n");
			writeIntoCodeFile("\tCMP DX, AX");
			if(relational_assignment==1)
			{			
			tmp_label_cnt+=1;
			if($RELOP->getText()=="<")
			{
				writeIntoCodeFile("\tJL TL"+to_string(tmp_label_cnt));
			}
			else if($RELOP->getText()=="<=")
			{
				writeIntoCodeFile("\tJLE TL"+to_string(tmp_label_cnt));				
			}
			else if($RELOP->getText()==">")
			{
				writeIntoCodeFile("\tJG TL"+to_string(tmp_label_cnt));
			}
			else if($RELOP->getText()==">=")
			{
				writeIntoCodeFile("\tJGE TL"+to_string(tmp_label_cnt));				
			}	
			else if($RELOP->getText()=="==")
			{
				writeIntoCodeFile("\tJE TL"+to_string(tmp_label_cnt));
			}		
			else if($RELOP->getText()=="!=")
			{
				writeIntoCodeFile("\tJNE TL"+to_string(tmp_label_cnt));
			}

			tmp_label_cnt+=1;
			int l=0;			
			writeIntoCodeFile("\tJMP TL"+to_string(tmp_label_cnt));
			
			write_label();
			writeIntoCodeFile("\tMOV AX, 1       ; Line "+to_string($line));
			true_label.push_back(label_count);
			label_count+=1;
			l=label_count;
			writeIntoCodeFile("\tJMP L"+to_string(label_count));
			
			write_label();
			writeIntoCodeFile("\tMOV AX, 0");
			writeIntoCodeFile("L"+to_string(l)+":");
			write_for_label_map("L"+to_string(l));
			next_label.push_back(label_count);
			}
			else
			{
			tmp_label_cnt2+=1;
			if($RELOP->getText()=="<")
			{
				writeIntoCodeFile("\tJL SL"+to_string(tmp_label_cnt2));
			}
			else if($RELOP->getText()=="<=")
			{
				writeIntoCodeFile("\tJLE SL"+to_string(tmp_label_cnt2));				
			}
			else if($RELOP->getText()==">")
			{
				writeIntoCodeFile("\tJG SL"+to_string(tmp_label_cnt2));
			}
			else if($RELOP->getText()==">=")
			{
				writeIntoCodeFile("\tJGE SL"+to_string(tmp_label_cnt2));				
			}	
			else if($RELOP->getText()=="==")
			{
				writeIntoCodeFile("\tJE SL"+to_string(tmp_label_cnt2));
			}		
			else if($RELOP->getText()=="!=")
			{
				writeIntoCodeFile("\tJNE SL"+to_string(tmp_label_cnt2));
			}

			tmp_label_cnt2+=1;
			writeIntoCodeFile("\tJMP SL"+to_string(tmp_label_cnt2));
				
			}




			}
			else
			{
				$retType="error";
			}
		}
		;

				
simple_expression returns [string name,string retType,int line]
          : t=term 
		  {
		    $retType=$t.retType;
			if($retType!="error")	
			{
			$name=$t.name;
			$line=$t.line;
			$retType=$t.retType;
			writeFile(string("Line ")+to_string($line)+string(": simple_expression : term\n"),string($name)+string("\n"));
			
			}
		  } 	  
		  | se=simple_expression 
		  {
            //writeIntoCodeFile("\tMOV DX, AX");
			writeIntoCodeFile("\tPUSH AX");
		  }
		  ADDOP t=term
		  {
			if($se.retType!="error" && $t.retType!="error")
			{
			$name=string($se.name)+string($ADDOP->getText())+string($t.name);
			$line=$t.line;
			if($se.retType=="float"||$t.retType=="float")
			$retType="float";
			else
			$retType="int";
			writeFile(string("Line ")+to_string($line)+string(": simple_expression : simple_expression ADDOP term\n"),string($name)+string("\n"));
           	
			if($ADDOP->getText()=="+")
				{
					writeIntoCodeFile("\tPOP DX");
					writeIntoCodeFile("\tADD AX, DX");
				}
			else if($ADDOP->getText()=="-")
				{
				writeIntoCodeFile("\tPOP DX");	
				writeIntoCodeFile("\tSUB DX, AX");	
				writeIntoCodeFile("\tMOV AX, DX");	
				}		
            write_push_pop_line($line);
			}
			else
			{
				$retType="error";
			}		
		  }



		  ;
  
					
term returns [string name,string retType,int line]
     :	ue=unary_expression
	 {
		$retType=$ue.retType;
		if($retType!="error")
		{
		$name=$ue.name;
		$line=$ue.line;
		$retType=$ue.retType;
		writeFile(string("Line ")+to_string($line)+string(": term : unary_expression\n"),string($name)+string("\n"));
		}

	 }
     |  t=term 
	 {
        writeIntoCodeFile("\tMOV BX, AX");
		writeIntoCodeFile("\tPUSH BX");
	 }
	 MULOP ue=unary_expression
	 {
		bool error_exist=false;

		$retType=$ue.retType;
		if($retType!="error")
		{		
		$name=string($t.name)+string($MULOP->getText())+string($ue.name);
		$line=$ue.line;
		$retType=$ue.retType;
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": term : term MULOP unary_expression\n"));
		if($retType=="void")
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Void function used in expression\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Void function used in expression\n");
		}
		
		else if($t.retType=="float" || $ue.retType=="float")
			$retType="float";
		else 
			$retType="int";	

		if($MULOP->getText()=="%")
			$retType="int";

		if($ue.retType!="int" && $MULOP->getText()=="%")
		{
			error_exist=true;
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Non-Integer operand on modulus operator\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Non-Integer operand on modulus operator\n");
			

		}
		if($ue.name=="0" && ($MULOP->getText()=="/" || $MULOP->getText()=="%"))
		{
			error_exist=true;
			syntaxErrorCount++ ;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Modulus by Zero\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Modulus by Zero\n");
		}
		writeIntoparserLogFile(string($name)+string("\n"));
		if(error_exist==false)
		{
			
			writeIntoCodeFile("\tMOV CX, AX");
			writeIntoCodeFile("\tPOP AX");
			//writeIntoCodeFile("\tMOV AX, BX");
			writeIntoCodeFile("\tMOV BX, DX");
			writeIntoCodeFile("\tCWD");
			if($MULOP->getText()=="*")
			{

                writeIntoCodeFile("\tMUL CX");
				writeIntoCodeFile("\tPUSH AX");
				writeIntoCodeFile("\tPOP AX       ; Line "+to_string($line));	
				writeIntoCodeFile("\tMOV DX, BX");
						
			 
		   			
				
			}
			else if($MULOP->getText()=="/")
			{
			
				writeIntoCodeFile("\tDIV CX");
				writeIntoCodeFile("\tPUSH AX");
				writeIntoCodeFile("\tPOP AX       ; Line "+to_string($line));
				writeIntoCodeFile("\tMOV DX, BX");
				

			}
			else
			{
			
				writeIntoCodeFile("\tDIV CX");
				writeIntoCodeFile("\tPUSH DX");
				writeIntoCodeFile("\tPOP AX       ; Line "+to_string($line));
				writeIntoCodeFile("\tMOV DX, BX");
				
			}
          
			//writeIntoCodeFile("\tMOV DX, BX");
			

		}
		}
	 }
	 |
	 ue=unary_expression i=invalid
	 {
		$name=$ue.name;
		$line=$ue.line;
		$retType=$ue.retType;
         writeIntoparserLogFile(string("Line ")+to_string($line)+string(": term : unary_expression\n"));
		 writeIntoparserLogFile($name+"\n");
		 writeIntoparserLogFile("Error at line "+to_string($i.line)+": Unrecognized character "+$i.name+"\n");
		 writeIntoErrorFile("Error at line "+to_string($i.line)+": Unrecognized character "+$i.name+"\n");
		 $line=$i.line+1;
		 syntaxErrorCount++;
		 
	 }
     ;
invalid returns [string name,int line]
         : ERROR_CHAR 
		 {
			$name=$ERROR_CHAR->getText();
			$line=$ERROR_CHAR->getLine();
		 }

		;
unary_expression returns [string name,string retType,int line]
         : ADDOP ue=unary_expression 
		 {
			$name=string($ADDOP->getText())+string($ue.name);
			$line=$ue.line;
			$retType=$ue.retType;
			writeFile(string("Line ")+to_string($line)+string(": unary_expression : ADDOP unary_expression\n"),string($name)+string("\n"));
			writeIntoCodeFile("\tNEG AX");
			write_push_pop_line($line);
		 } 
		 | NOT ue=unary_expression
		 {
			$name=string($NOT->getText())+string($ue.name);
			$line=$ue.line;
			$retType=$ue.retType;
			writeFile(string("Line ")+to_string($line)+string(": unary_expression : NOT unary_expression\n"),string($name)+string("\n"));
          
		 } 
		 | f=factor 
		 {
			$retType=$f.retType;
			if($retType!="error")
			{
			
			$name=string($f.name);
			$line=$f.line;
			$retType=$f.retType;
			writeFile(string("Line ")+to_string($line)+string(": unary_expression : factor\n"),string($name)+string("\n"));	
			}
		 }
		 ;
	
factor returns [string name,string retType,int line]
    : v=variable 
	{
			$name=string($v.name);
			string actual_id_name=get_ID($v.name);
			$line=$v.line;
			$retType=$v.retType;
			writeFile(string("Line ")+to_string($line)+string(": factor : variable\n"),string($name)+string("\n"));	
			SymbolInfo *tmp=smb_tb.LookUp2(actual_id_name);

			if(tmp!=nullptr && !tmp->getIsArray())
			{
						
				if(function_parameter_exist(cur_file_name,tmp->getsymbolName()))
				{
					SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
					writeIntoCodeFile("\tMOV AX, [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(tmp->getsymbolName()))+"]");
					//writeIntoCodeFile("\tPUSH AX");
					//writeIntoCodeFile("\tPOP AX");

				}
				else if(tmp->get_is_global()==true)
				{
					writeIntoCodeFile("\tMOV AX, "+$name+"       ; Line "+to_string($line));
				}
				else
				{
					writeIntoCodeFile("\tMOV AX, [BP-"+to_string(tmp->getStackOffset())+"]       ; Line "+to_string($line));					
				}
			}
			else if(tmp!=nullptr && tmp->getIsArray())
			{
				

			}
			else
			{

				if(function_parameter_exist(cur_file_name,actual_id_name))
				{
					SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
					writeIntoCodeFile("\tMOV AX, [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"]");
					//writeIntoCodeFile("\tPUSH AX");
					//writeIntoCodeFile("\tPOP AX");

				}
				
			}

						
		
	}
	| ID LPAREN agl=argument_list RPAREN
	{
			$name=string($ID->getText())+string($LPAREN->getText())+string($agl.name)+string($RPAREN->getText());
			$line=$RPAREN->getLine();
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			writeIntoparserLogFile(string("Line ")+to_string($line)+string(": factor : ID LPAREN argument_list RPAREN\n"));
			if(tmp!=nullptr)
			{
            if(tmp->isFunctionDefined())

				{  if(tmp->getFunctionParameterCount()==arguement_list.size())
				{
					for(int i=0;i<arguement_list.size();i++)
					{
						if(tmp->getFunctionInfo()->getParameterName(i)=="int" && arguement_list[i]=="float")
						{
							syntaxErrorCount++;
							writeIntoparserLogFile("Error at line "+to_string($line)+": "+to_string(i+1)+"th argument mismatch in function "+$ID->getText()+"\n");
							writeIntoErrorFile("Error at line "+to_string($line)+": "+to_string(i+1)+"th argument mismatch in function "+$ID->getText()+"\n");
							break;
						}
					}
				}
				else
				{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
				}
				$retType=tmp->getReturnType();
				}
			}
			else
			{
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Undefined function "+$ID->getText()+"\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Undefined function "+$ID->getText()+"\n");
			}
			writeIntoparserLogFile(string($name)+string("\n"));
			arguement_list.clear();
			write_func_call($ID->getText(),$line);
			//exit_label.push_back(get_next_label());
			
			
	}
	| LPAREN exp=expression RPAREN
	{
		$name=string($LPAREN->getText())+string($exp.name)+string($RPAREN->getText());
		$line=$RPAREN->getLine();
		$retType=$exp.retType;
		writeFile(string("Line ")+to_string($line)+string(": factor : LPAREN expression RPAREN\n"),string($name)+string("\n"));

	}
	| CONST_INT 
	{
		$name=string($CONST_INT->getText());
		$line=$CONST_INT->getLine();
		$retType="int";
		writeFile(string("Line ")+to_string($line)+string(": factor : CONST_INT\n"),string($name)+string("\n"));
		writeIntoCodeFile("\tMOV AX, "+$name+"       ; Line "+to_string($line));		
        		
	}
	| CONST_FLOAT
	{
		$name=string($CONST_FLOAT->getText());
		$line=$CONST_FLOAT->getLine();
		$retType="float";
		writeFile(string("Line ")+to_string($line)+string(": factor : CONST_FLOAT\n"),string($name)+string("\n"));
		writeIntoCodeFile("\tMOV AX, "+$name+"       ; Line "+to_string($line));		
	}	
	| v=variable INCOP 
	{
		string actual_id_name=get_ID($v.name);
		$name=$v.name+string($INCOP->getText());
		$line=$INCOP->getLine();
		$retType=$v.retType;
		writeFile(string("Line ")+to_string($line)+string(": factor : variable INCOP\n"),string($name)+string("\n"));
		SymbolInfo *tmp=smb_tb.LookUp2(actual_id_name);
		
		if(tmp!=nullptr)
		{
		if(tmp->getIsArray()==false)
		{
			write_label();
			if(tmp->get_is_global())
			{
				writeIntoCodeFile("\tMOV AX, "+$v.name);
			}
			else
			{
				writeIntoCodeFile("\tMOV AX, [BP-"+to_string(tmp->getStackOffset())+"]       ; Line "+to_string($line));
				
			}
		writeIntoCodeFile("\tPUSH AX");
		writeIntoCodeFile("\tINC AX");
		writeIntoCodeFile("\tMOV [BP-"+to_string(tmp->getStackOffset())+"], "+"AX");
		writeIntoCodeFile("\tPOP AX");		
		}
		else
		{
        writeIntoCodeFile("\tPOP BX");
		writeIntoCodeFile("\tPUSH BX");
		writeIntoCodeFile("\tMOV AX, 2       ; Line "+to_string($line));	
		writeIntoCodeFile("\tMUL BX");
		writeIntoCodeFile("\tMOV BX, AX");
		writeIntoCodeFile("\tPUSH BX");
		if(tmp->get_is_global())
		writeIntoCodeFile("\tMOV AX, "+actual_id_name+"[BX]"); 
		else
		{
			writeIntoCodeFile("\tMOV AX, "+to_string(tmp->getStackOffset()));
			writeIntoCodeFile("\tSUB AX, BX");
			writeIntoCodeFile("\tMOV BX, AX");
			writeIntoCodeFile("\tMOV SI, BX");
			writeIntoCodeFile("\tNEG SI");
			writeIntoCodeFile("\tMOV AX, [BP+SI]");		
			writeIntoCodeFile("\tPUSH AX");	
		}
		//writeIntoCodeFile("yet to be implemented");    

		writeIntoCodeFile("\tINC AX");
		if(tmp->get_is_global()==false)
		{
			writeIntoCodeFile("\tMOV [BP+SI], AX");	
			writeIntoCodeFile("\tPOP AX");
		}
		else{
		writeIntoCodeFile("\tPOP BX");	
		writeIntoCodeFile("\tMOV CX, AX");
		//writeIntoCodeFile("\tMOV "+actual_id_name+"[BX], AX");
		}

	
		
		}	
		}
		else
		{
			if(function_parameter_exist(cur_file_name,actual_id_name))
			{

				
				SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
				writeIntoCodeFile("\tMOV AX, [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"]       ; Line "+to_string($line));
				writeIntoCodeFile("\tPUSH AX");
				writeIntoCodeFile("\tINC AX");
				writeIntoCodeFile("\tMOV [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"], AX");
				writeIntoCodeFile("\tPOP AX");


			}
		}

		



	}	
	| v=variable DECOP
	{

        string actual_id_name=get_ID($v.name);
		$name=$v.name+string($DECOP->getText());
		$line=$DECOP->getLine();
		$retType=$v.retType;
		writeFile(string("Line ")+to_string($line)+string(": factor : variable DECOP\n"),string($name)+string("\n"));
		SymbolInfo *tmp=smb_tb.LookUp2(actual_id_name);
		
		if(tmp!=nullptr)
		{
		if(tmp->getIsArray()==false)
		{	
			write_label();		
			if(tmp->get_is_global())
			{
				writeIntoCodeFile("\tMOV AX, "+$v.name);
			}
			else
			{
				writeIntoCodeFile("\tMOV AX, [BP-"+to_string(tmp->getStackOffset())+"]       ; Line "+to_string($line));
				
			}
		writeIntoCodeFile("\tPUSH AX");
		writeIntoCodeFile("\tDEC AX");
		writeIntoCodeFile("\tMOV [BP-"+to_string(tmp->getStackOffset())+"], "+"AX");
		writeIntoCodeFile("\tPOP AX");			
		}
		
		else
		{
        writeIntoCodeFile("\tPOP BX");
		writeIntoCodeFile("\tPUSH BX");
		writeIntoCodeFile("\tMOV AX, 2       ; Line "+to_string($line));	
		writeIntoCodeFile("\tMUL BX");
		writeIntoCodeFile("\tMOV BX, AX");
		writeIntoCodeFile("\tPUSH BX");
		if(tmp->get_is_global())
		writeIntoCodeFile("\tMOV AX, "+actual_id_name+"[BX]"); 
		else
		{
			writeIntoCodeFile("\tMOV AX, "+to_string(tmp->getStackOffset()));
			writeIntoCodeFile("\tSUB AX, BX");
			writeIntoCodeFile("\tMOV BX, AX");
			writeIntoCodeFile("\tMOV SI, BX");
			writeIntoCodeFile("\tNEG SI");
			writeIntoCodeFile("\tMOV AX, [BP+SI]");			
		}     
		writeIntoCodeFile("\tDEC AX");
		writeIntoCodeFile("\tPOP BX");	
		writeIntoCodeFile("\tMOV CX, AX");
		}
		}
		else
		{
			if(function_parameter_exist(cur_file_name,actual_id_name))
			{

				
				SymbolInfo *f_tmp=smb_tb.LookUp2(cur_file_name);
				writeIntoCodeFile("\tMOV AX, [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"]       ; Line "+to_string($line));
				writeIntoCodeFile("\tPUSH AX");
				writeIntoCodeFile("\tDEC AX");
				writeIntoCodeFile("\tMOV [BP+"+to_string(f_tmp->getFunctionStackOffset_parameter(actual_id_name))+"], AX");
				writeIntoCodeFile("\tPOP AX");


			}			
		}
		if(is_expression==1)
		{
			tmp_label_cnt2+=1;
			writeIntoCodeFile("\tCMP AX,0");
			writeIntoCodeFile("\tJG SL"+to_string(tmp_label_cnt2));
			tmp_label_cnt2+=1;
			writeIntoCodeFile("\tJMP SL"+to_string(tmp_label_cnt2));


		}


	}
	| ASSIGNOP
	{
		$line=$ASSIGNOP->getLine();
		$retType="error";
		syntaxErrorCount++;
		writeIntoparserLogFile("Error at line "+to_string($line)+": syntax error, unexpected ASSIGNOP\n");
		writeIntoErrorFile("Error at line "+to_string($line)+": syntax error, unexpected ASSIGNOP\n");
	}


	;
	
argument_list returns [string name,int line]
              : ag=arguments
              {
				$name=$ag.name;
                $line=$ag.line;
				writeFile(string("Line ")+to_string($line)+string(": argument_list : arguments\n"),string($name)+string("\n"));
			  }
			  |
			  {
				        
				$name="";
                $line=-1;
				writeFile(string("Line ")+to_string($line)+string(": argument_list : epsilon\n"),string($name)+string("\n"));

			  }
			  ;
	
arguments returns [string name, int line,string retType]	
          : ag=arguments 
		  {
			//writeIntoCodeFile("\tPUSH AXahhhhhhhhhhhhhhhhhhhhhhh");
		  }
		  COMMA 
		  le=logic_expression
		  { $name=string($ag.name)+string($COMMA->getText())+string($le.name);
			$line=$le.line;
			$retType=$ag.retType;			
			writeFile(string("Line ")+to_string($line)+string(": arguments : arguments COMMA logic_expression\n"),string($name)+string("\n"));
			
			if($le.retType=="")
			{
				SymbolInfo *tmp=smb_tb.LookUp2($le.name);
				if(tmp)
				{
					$retType=tmp->getReturnType();
				}
			}
			arguement_list.push_back($retType);
			writeIntoCodeFile("\tPUSH AX");
			
		  }
	      | le=logic_expression
		  { $name=$le.name;
            $line=$le.line;
			$retType=$le.retType;
			writeFile(string("Line ")+to_string($line)+string(": arguments : logic_expression\n"),string($name)+"\n");
			
			if($le.retType=="")
			{
				SymbolInfo *tmp=smb_tb.LookUp2($le.name);
				if(tmp)
				{
					$retType=tmp->getReturnType();
				}
			}
			arguement_list.push_back($retType);
			writeIntoCodeFile("\tPUSH AX");
		
			
		  }
	
		  
	      ;

	  
invalid_type returns [string name, int line]
    : ADDOP
      {
        $name = "ADDOP";
        $line = $ADDOP->getLine();
      }
    | MULOP
      {
        $name = "MULOP";
        $line = $MULOP->getLine();
      }
    | SUBOP
      {
        $name = "SUBOP";
        $line = $SUBOP->getLine();
      }
    | INCOP
      {
        $name = "INCOP";
        $line = $INCOP->getLine();
      }
    | DECOP
      {
        $name = "DECOP";
        $line = $DECOP->getLine();
      }
    | NOT
      {
        $name = "NOT";
        $line = $NOT->getLine();
      }
    | RELOP
      {
        $name = "RELOP";
        $line = $RELOP->getLine();
      }
    | LOGICOP
      {
        $name = "LOGICOP";
        $line = $LOGICOP->getLine();
      }
    | ASSIGNOP
      {
        $name = "ASSIGNOP";
        $line = $ASSIGNOP->getLine();
      }
    ;
 invalid_type2 returns [string name, int line]

    : ADDOP
      {
        $name = "ADDOP";
        $line = $ADDOP->getLine();
      }
    | MULOP
      {
        $name = "MULOP";
        $line = $MULOP->getLine();
      }
    | SUBOP
      {
        $name = "SUBOP";
        $line = $SUBOP->getLine();
      }
    | INCOP
      {
        $name = "INCOP";
        $line = $INCOP->getLine();
      }
    | DECOP
      {
        $name = "DECOP";
        $line = $DECOP->getLine();
      }
    | NOT
      {
        $name = "NOT";
        $line = $NOT->getLine();
      }
    | RELOP
      {
        $name = "RELOP";
        $line = $RELOP->getLine();
      }
    | LOGICOP
      {
        $name = "LOGICOP";
        $line = $LOGICOP->getLine();
      }
    ;

