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


    extern int syntaxErrorCount;
	extern vector<string> global_arguement_list;
	extern vector<pair<string,int>> global_variable_list;
	extern vector<pair<string,string>> global_parameter_list;
	extern vector<string>array_list;
	extern vector<string>arguement_list;
	extern string func_name;
	extern string type;
	extern bool func;

}

@parser::members {
    void writeIntoparserLogFile(const string message) {
        if (!parserLogFile) {
            cout << "Error opening parserLogFile.txt" << endl;
            return;
        }

        parserLogFile << message << endl;
        parserLogFile.flush();
    }

    void writeIntoErrorFile(const string message) {
        if (!errorFile) {
            cout << "Error opening errorFile.txt" << endl;
            return;
        }
        errorFile << message << endl;
        errorFile.flush();
    }
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
}


start : pr=program
	{
		writeIntoparserLogFile("Line "+to_string($pr.line)+": start : program\n");
        smb_tb.PrintAllScopeTable(parserLogFile);
		writeIntoparserLogFile("Total number of lines: "+to_string($pr.line)+"\nTotal number of errors: "+to_string(syntaxErrorCount));

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
        : ts=type_specifier ID LPAREN prl=parameter_list RPAREN SEMICOLON
		{
           $name=$ts.name+" "+$ID->getText()+$LPAREN->getText()+$prl.name+$RPAREN->getText()+$SEMICOLON->getText();
		   $line=$SEMICOLON->getLine();
		   writeFile("Line "+to_string($line)+": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n",string($name)+string("\n"));
		   string n=$ID->getText();
		   string t=$ts.retType;
		   SymbolInfo *tmp=smb_tb.LookUp(n,t);
		   if(tmp==nullptr)
		   {
			//insert_function(n,t,-2,$line);
				SymbolInfo *si=new SymbolInfo(n, "ID", t, -2);
				si->initializeAsFunction(t);
				si->setFunctionDeclared(true);

				if(global_parameter_list.size()>0)
				{
					for(int i=0;i<global_parameter_list.size();i++)
					{
						si->addFunctionParameter(global_parameter_list[i].first,global_parameter_list[i].second);
					}
				}

				smb_tb.Insert(si);					
		   }
		   global_parameter_list.clear();
		  // writeIntoparserLogFile("done........................................................................");

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
			//insert_function(n,t,-2,$line);

				SymbolInfo *si=new SymbolInfo(n, "ID", t, -2);
				si->initializeAsFunction(t);
				si->setFunctionDeclared(true);
				smb_tb.Insert(si);	
		   }
		}
		;
		 
func_definition returns [string name,int line]
        : ts=type_specifier ID 
		{   //cout<<"true.......func.............................."<<endl;
		    
			$name=$ts.name+" "+$ID->getText();
			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			

			//insert_function(n,t,-3,$line);
			SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
			si->initializeAsFunction(t);
			si->setFunctionDefined(true);

			if(tmp==nullptr)
			{
				smb_tb.Insert(si);				
			}



		}
		LPAREN prl=parameter_list 
		{
			
			$name=$name+$LPAREN->getText()+$prl.name;
			//writeIntoparserLogFile(to_string(global_parameter_list.size()));
			if(global_parameter_list.size()>0)
			{
				for(int i=0;i<global_parameter_list.size();i++)
				{
					si->addFunctionParameter(global_parameter_list[i].first,global_parameter_list[i].second);
				}
				//global_parameter_list.clear();
				
			}
			si->printSymbolInfo(si);
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
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
				}
				else if(m==1)
				{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
				}
				else if(m==2)
				{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Total number of arguments mismatch with declaration in function "+$ID->getText()+"\n");
				}
				else if(m==2)
				{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Parameter mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Parameter mismatch of "+$ID->getText()+"\n");
				}								

			}
			else if(tmp!=nullptr && tmp->isFunctionDeclared()==false)
			{
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
			}
		}
		 cs=compound_statement
		{
		    
			//$name=$name+$LPAREN->getText()+$prl.name+$RPAREN->getText()+$cs.name;
			$name=$name+$cs.name;
			$line=$cs.line;
			if($ts.retType=="void" && $cs.ret==true)
			{
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
			}
			writeFile("Line "+to_string($line)+": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n",string($name)+string("\n"));
		}
		| ts=type_specifier ID 
		{
			$name=$ts.name+" "+$ID->getText();

			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp($ID->getText(),t);

				//insert_function(n,t,-3,$line);
				SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
				si->initializeAsFunction(t);
				si->setFunctionDefined(true);


			if(tmp==nullptr)
			{
				smb_tb.Insert(si);						
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
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Function info null "+$ID->getText()+"\n");
				}
				else if(m==1)
				{
					syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Return type mismatch of "+$ID->getText()+"\n");
				}

			}
			else if(tmp!=nullptr && tmp->isFunctionDeclared()==false)
			{
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
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Cannot return value from function "+$ID->getText()+" with void return type \n");
			}
			writeFile("Line "+to_string($line)+": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n",string($name)+string("\n"));				
		}		
        | ts=type_specifier ID  
		{   cout<<"true.......func.............................."<<endl;
		    
			$name=$ts.name+" "+$ID->getText();
			string n=$ID->getText();
			string t=$ts.retType;
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			

			//insert_function(n,t,-3,$line);
			SymbolInfo *si=new SymbolInfo(n, "ID", t, -3);
			si->initializeAsFunction(t);
			si->setFunctionDefined(true);

			if(tmp==nullptr)
			{
				smb_tb.Insert(si);				
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
		}	
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
		    //writeIntoparserLogFile("pushing "+$ID->getText()+" "+$ts.name+" into the list");		
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
			//writeIntoparserLogFile("pushing "+$ID->getText()+" "+$ts.name+" into the list");		
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

						//insert_variable(global_variable_list[i].first,"ID",global_variable_list[i].second);
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
						//insert_variable(global_variable_list[i].first,"ID",global_variable_list[i].second);
						SymbolInfo *si=new SymbolInfo(global_variable_list[i].first, "ID",type, global_variable_list[i].second);
		                
		                
						for(int j=0;j<array_list.size();j++)
						{
							if(array_list[j]==global_variable_list[i].first)
							{   //writeIntoErrorFile("true................................................");
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
		if($t.retType=="void")
		{
			syntaxErrorCount++;
			writeIntoErrorFile("Error at line "+to_string($line)+": Variable type cannot be void\n");
			writeIntoparserLogFile("Error at line "+to_string($line)+": Variable type cannot be void\n");
		}
		writeIntoparserLogFile(string($name)+string("\n"));
		

        

		for(int i=0;i<global_variable_list.size();i++)
		{  
			//insert_variable(global_variable_list[i].first,$t.name,global_variable_list[i].second);
						SymbolInfo *si=new SymbolInfo(global_variable_list[i].first, "ID",$t.name, global_variable_list[i].second);
		                
		                
						for(int j=0;j<array_list.size();j++)
						{
							if(array_list[j]==global_variable_list[i].first)
							{   //writeIntoErrorFile("true................................................");
								si->setIsArray(true);
								si->setArraySize(global_variable_list[i].second);
							}
						}
						smb_tb.Insert(si);				
		}
		global_variable_list.clear();	
      }
    ;

		 
type_specifier returns [string name, string retType,int line]	
    : INT {
		cout<<"true.......ts.............................."<<endl;
		
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
					//tmp->setReturnType(type);
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
			//smb_tb.PrintAllScopeTable(parserLogFile);
			if(tmp==nullptr)
				global_variable_list.push_back({$ID->getText(), -1});

		    else
			    {	syntaxErrorCount++;
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");	
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					//tmp->setReturnType(type);
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
					syntaxErrorCount++;	
					writeIntoparserLogFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					writeIntoErrorFile("Error at line "+to_string($line)+": Multiple declaration of "+$ID->getText()+"\n");
					//tmp->setReturnType(type);
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
		//valid_statement.push_back($st.name);
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
      : vdl=var_declaration
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
	  | FOR LPAREN exps1=expression_statement exps2=expression_statement exps3=expression RPAREN st=statement
	  {
		$name=$FOR->getText()+$LPAREN->getText()+$exps1.name+$exps2.name+$exps3.name+$RPAREN->getText()+$st.name;
		$line=$st.line;
		writeFile(string("Line ")+to_string($line)+string(": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n"),string($name)+string("\n"));
		$ret=false;
	  }
	  | IF LPAREN exp=expression RPAREN st=statement
	  {
        $name = $IF->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText() + $st.name;
        $line = $st.line;
        writeFile("Line " + to_string($line) + ": statement : IF LPAREN expression RPAREN statement\n", string($name + "\n"));
		$ret=false;

	  }
	  | IF LPAREN exp=expression RPAREN st1=statement ELSE st2=statement
	  {
		$name = $IF->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText()+ $st1.name + $ELSE->getText() +" "+ $st2.name;
        $line = $st2.line;
        writeFile("Line " + to_string($line) + ": statement : IF LPAREN expression RPAREN statement ELSE statement\n", $name + "\n");
		$ret=false;

	  }
	  | WHILE LPAREN exp=expression RPAREN st=statement
	  {
		$name = $WHILE->getText()+$LPAREN->getText() + $exp.name + $RPAREN->getText() + $st.name;
        $line = $st.line;
        writeFile("Line " + to_string($line) + ": statement : WHILE LPAREN expression RPAREN statement\n", $name + "\n");
		$ret=false;

	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		 $name=$PRINTLN->getText()+$LPAREN->getText()+$ID->getText()+$RPAREN->getText()+$SEMICOLON->getText();
		 $line=$SEMICOLON->getLine();
		 writeIntoparserLogFile("Line " + to_string($line) + ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
		 if(smb_tb.LookUp2($ID->getText())==nullptr)
		 {
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+$ID->getText()+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+$ID->getText()+"\n");
		 }
		 writeIntoparserLogFile($name + "\n");
		 $ret=false;


	  }
	  | RETURN exp=expression SEMICOLON
	  {
		$name=$RETURN->getText()+" "+$exp.name+$SEMICOLON->getText();
		$line=$SEMICOLON->getLine();
		writeFile("Line " + to_string($line) + ": statement : RETURN expression SEMICOLON\n", $name + "\n");
		$ret=true;
		$isok="true";

	  }


	  ;


expression_statement returns [string name,string retType,int line ,int next_token]
            : SEMICOLON		
			{   cout<<"Semicolon found"<<endl;
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
		
		$name=$ID->getText();
		$line=$ID->getLine();
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": variable : ID\n"));
		SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
		if(tmp==nullptr && !in_variable_list($ID->getText()) && !in_parameter_list($ID->getText()))
		{
			
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			$retType=type;

		}

		if(tmp && tmp->getIsArray())
		{
			
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Type mismatch, "+string($ID->getText())+" is an array\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Type mismatch, "+string($ID->getText())+" is an array\n");
			$retType=tmp->getReturnType();			
		}
	
		if(tmp && tmp->isFunctionDeclared()==true)
		{
			//writeIntoparserLogFile("...........................");
		}
		

		writeIntoparserLogFile(string($name)+string("\n"));
		if(tmp)
		{$retType=tmp->getReturnType();}
		else
		{$retType=type;}

	 }	
	 | ID LTHIRD exp=expression RTHIRD 
	 {
		$name=$ID->getText()+$LTHIRD->getText()+$exp.name+$RTHIRD->getText();
		$line=$RTHIRD->getLine();
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": variable : ID LTHIRD expression RTHIRD\n"));
		if($exp.retType!="int")
		{
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Expression inside third brackets not an integer\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Expression inside third brackets not an integer\n");
		}
		SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
		if(tmp==nullptr && !in_variable_list($ID->getText()) && !in_parameter_list($ID->getText()))
		{
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Undeclared variable "+string($ID->getText())+"\n");

		}
		if(tmp!=nullptr && tmp->getIsArray()==false)
		{
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": "+$ID->getText()+" not an array\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": "+$ID->getText()+" not an array\n");
			
		}

		if(tmp)
		{$retType=tmp->getReturnType();}
		else
		{$retType=type;}
		//if(tmp && tmp->getIsArray())
		//{$retType=type;}
		writeIntoparserLogFile(string($name)+string("\n"));

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


	   | v=variable ASSIGNOP le=logic_expression 	
	   {
		if($v.retType!="error" && $le.retType!="error")
		{
		$name=$v.name+$ASSIGNOP->getText()+$le.name;
		$retType=$le.retType;
		$line=$le.line;
		//writeIntoparserLogFile($v.retType + " " +$le.retType);
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": expression : variable ASSIGNOP logic_expression\n"));	
		//if(smb_tb.LookUp2($v.name)!=nullptr)
		//{
			//if(smb_tb.LookUp2($v.name)->getReturnType()=="int" && $le.retType=="float")

			//{  // writeIntoErrorFile($v.name+" "+smb_tb.LookUp2($v.name)->getReturnType()+" "+$le.name+" "+$le.retType);
			//	syntaxErrorCount++;
			//	writeIntoparserLogFile("Error at line "+to_string($line)+": Type Mismatch\n");
			//	writeIntoErrorFile("Error at line "+to_string($line)+": Type Mismatch\n");
			//}
			

		//}
		//else
		//{

		//}
		//writeIntoparserLogFile($v.retType+"  " +$le.retType);
		    if($v.retType=="int" && $le.retType=="float")
			{
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Type Mismatch\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Type Mismatch\n");				
			}
			if($le.retType=="void" || $v.retType=="void")
			{
				syntaxErrorCount++;
				writeIntoparserLogFile("Error at line "+to_string($line)+": Void function used in expression\n");
				writeIntoErrorFile("Error at line "+to_string($line)+": Void function used in expression\n");
			}		

		writeIntoparserLogFile(string($name)+string("\n"));
		}
		else
		{
			$retType="error";
		}
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
		 | re1=rel_expression LOGICOP re=rel_expression 
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
			}
			else
			{
				$retType="error";
			}		
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


		}

		| se1=simple_expression RELOP se2=simple_expression
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
		  | se=simple_expression ADDOP t=term
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
     |  t=term MULOP ue=unary_expression
	 {
		$retType=$ue.retType;
		if($retType!="error")
		{		
		$name=string($t.name)+string($MULOP->getText())+string($ue.name);
		$line=$ue.line;
		$retType=$ue.retType;
		writeIntoparserLogFile(string("Line ")+to_string($line)+string(": term : term MULOP unary_expression\n"));
		if($retType=="void")
		{
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
			syntaxErrorCount++;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Non-Integer operand on modulus operator\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Non-Integer operand on modulus operator\n");
			

		}
		if($ue.name=="0" && ($MULOP->getText()=="/" || $MULOP->getText()=="%"))
		{
			syntaxErrorCount++ ;
			writeIntoparserLogFile("Error at line "+to_string($line)+": Modulus by Zero\n");
			writeIntoErrorFile("Error at line "+to_string($line)+": Modulus by Zero\n");
		}
		writeIntoparserLogFile(string($name)+string("\n"));
		}
	 }
	 |
	 ue=unary_expression i=invalid
	 {
		$name=$ue.name;
		$line=$ue.line;
		//writeIntoparserLogFile(to_string($line));
		$retType=$ue.retType;
         writeIntoparserLogFile(string("Line ")+to_string($line)+string(": term : unary_expression\n"));
		 writeIntoparserLogFile($name+"\n");
		 writeIntoparserLogFile("Error at line "+to_string($i.line)+": Unrecognized character "+$i.name+"\n");
		 writeIntoErrorFile("Error at line "+to_string($i.line)+": Unrecognized character "+$i.name+"\n");
		 $line=$i.line+1;
		 syntaxErrorCount++;
		 
		//writeIntoparserLogFile("dfghjk");
	 }
     ;
invalid returns [string name,int line]
         : ERROR_CHAR 
		 {
			$name=$ERROR_CHAR->getText();
			$line=$ERROR_CHAR->getLine();
			//writeIntoparserLogFile($name+" "+to_string($line));
		 }

		;
unary_expression returns [string name,string retType,int line]
         : ADDOP ue=unary_expression 
		 {
			$name=string($ADDOP->getText())+string($ue.name);
			$line=$ue.line;
			$retType=$ue.retType;
			writeFile(string("Line ")+to_string($line)+string(": unary_expression : ADDOP unary_expression\n"),string($name)+string("\n"));
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
			//writeIntoparserLogFile($retType);
			writeFile(string("Line ")+to_string($line)+string(": unary_expression : factor\n"),string($name)+string("\n"));	
			}

			
	
		 }
		 ;
	
factor returns [string name,string retType,int line]
    : v=variable 
	{
			$name=string($v.name);
			$line=$v.line;
			$retType=$v.retType;
			writeFile(string("Line ")+to_string($line)+string(": factor : variable\n"),string($name)+string("\n"));	
	}
	| ID LPAREN agl=argument_list RPAREN
	{
			$name=string($ID->getText())+string($LPAREN->getText())+string($agl.name)+string($RPAREN->getText());
			$line=$RPAREN->getLine();
			SymbolInfo *tmp=smb_tb.LookUp2($ID->getText());
			writeIntoparserLogFile(string("Line ")+to_string($line)+string(": factor : ID LPAREN argument_list RPAREN\n"));
			if(tmp!=nullptr)
			{
				//writeIntoparserLogFile((tmp->getsymbolName()));
				for(int i=0;i<arguement_list.size();i++)
				{
					//writeIntoparserLogFile(arguement_list[i]);
				}
				//writeIntoparserLogFile("ok");
				for(int i=0;i<tmp->getFunctionParameterCount();i++)
				{
					//writeIntoparserLogFile(tmp->getFunctionInfo()->getParameterName(i));
				}
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
           // $retType="-1";
			arguement_list.clear();
			
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
	}
	| CONST_FLOAT
	{
		$name=string($CONST_FLOAT->getText());
		$line=$CONST_FLOAT->getLine();
		$retType="float";
		writeFile(string("Line ")+to_string($line)+string(": factor : CONST_FLOAT\n"),string($name)+string("\n"));
	}	
	| v=variable INCOP 
	{
		$name=$v.name+string($INCOP->getText());
		$line=$INCOP->getLine();
		$retType=$v.retType;
		writeFile(string("Line ")+to_string($line)+string(": factor : variable INCOP\n"),string($name)+string("\n"));
	}	
	| v=variable DECOP
	{
		$name=$v.name+string($DECOP->getText());
		$line=$DECOP->getLine();
		$retType=$v.retType;
		writeFile(string("Line ")+to_string($line)+string(": factor : variable DECOP\n"),string($name)+string("\n"));
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
          : ag=arguments COMMA le=logic_expression
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

