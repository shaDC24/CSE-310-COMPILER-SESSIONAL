#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <unordered_set>
#include <algorithm>
#include <cctype>
using namespace std;

string trim(const string& str) {
    int start = str.find_first_not_of(" \t");
    if (start == string::npos) 
    return "";
    int end = str.find_last_not_of(" \t");
    return str.substr(start, end - start + 1);
}
vector<string> split(const string& str, char delimiter) {
    vector<string> word_list;
    stringstream ss(str);
    string word;
    while (getline(ss, word, delimiter)) {
        word_list.push_back(trim(word));
    }
    return word_list;
}
bool is_label(const string& line, string& labelName) {
    string trimmed_line = trim(line);
    if (trimmed_line.empty()) 
    return false;
    if (trimmed_line.back() == ':') 
    {
        labelName = trim(trimmed_line.substr(0, trimmed_line.length() - 1));
        if (labelName.empty()) 
        return false;
        for (char c : labelName) 
        {
            if (!isalnum(c) && c != '_') 
            return false;
        }
        return true;
    }
    return false;
}
bool is_redundant_move(const string& line1, const string& line2) {
    string trimmed_line1 = (trim(line1));
    string trimmed_line2 = (trim(line2));
    if (trimmed_line1.substr(0, 3) != "MOV" || trimmed_line2.substr(0, 3) != "MOV") 
    {
        return false;
    }
    int position_of_comma1 = trimmed_line1.find(',');
    if (position_of_comma1 == string::npos) 
    return false;
    string dest1 = trim(trimmed_line1.substr(3, position_of_comma1 - 3));
    string src1 = trim(trimmed_line1.substr(position_of_comma1 + 1));
    int position_of_comma2 = trimmed_line2.find(',');
    if (position_of_comma2 == string::npos) 
    return false;
    string dest2 = trim(trimmed_line2.substr(3, position_of_comma2 - 3));
    string src2 = trim(trimmed_line2.substr(position_of_comma2 + 1));
    return (dest1 == src2 && src1 == dest2);
}

bool is_push_pop_pair(const string& line1, const string& line2) {
    string trimmed_line1 = (trim(line1));
    string trimmed_line2 = (trim(line2));
    if (trimmed_line1.substr(0, 4) != "PUSH" || trimmed_line2.substr(0, 3) != "POP") {
        return false;
    }
    string push_register = trim(trimmed_line1.substr(4));
    string pop_register = trim(trimmed_line2.substr(3));
    return push_register == pop_register;
}

bool is_redundant_neutral_operation(const string& line) {
    string trimmed_line = (trim(line));
    if (trimmed_line.empty()) 
    return false;
    if (trimmed_line.substr(0, 3) == "ADD" || trimmed_line.substr(0, 3) == "SUB") {
        int position_of_comma = trimmed_line.find(',');
        if (position_of_comma != string::npos) {
            string operand = trim(trimmed_line.substr(position_of_comma + 1));
            return (operand == "0");
        }
    }
    
    if (trimmed_line.substr(0, 3) == "MUL") {
        
        int position_of_comma = trimmed_line.find(',');
        if (position_of_comma != string::npos) {
            string operand = trim(trimmed_line.substr(position_of_comma + 1));
            return (operand == "1");
        }
    }
    return false;
}

bool is_jump_instruction(const string& line, string& targetLabel) {
    string trimmed_line = (trim(line));
    
    if (trimmed_line.empty()) 
    return false;

    vector<string> jump_instruction_list = {
        "JMP", "JE", "JNE", "JG", "JL", "JGE", "JLE"};
    for (const string& jump_instruction : jump_instruction_list) {
        if (trimmed_line.length() >= jump_instruction.length() && 
            trimmed_line.substr(0, jump_instruction.length()) == jump_instruction) {
            if (trimmed_line.length() > jump_instruction.length() && !isspace(trimmed_line[jump_instruction.length()])) 
            {
                continue;
            }
            targetLabel = trim(trimmed_line.substr(jump_instruction.length()));
            int position_of_comment = targetLabel.find(';');
            if (position_of_comment != string::npos) {
                targetLabel = trim(targetLabel.substr(0, position_of_comment));
            }
            
            if (!targetLabel.empty()) {
                cout << "Target Label: " << targetLabel << endl;
                return true;
            }
        }
    }
    
    return false;
}

void optimizeAssembly(const string& inputPath, const string& outputPath) {
    ifstream inFile(inputPath);
    ofstream outFile(outputPath);
    vector<string> lines;
    string line;

    unordered_set<string> jumpTargets;

    while (getline(inFile, line)) {
        lines.push_back(line);
        string target;
        if (is_jump_instruction(line, target)) {
            jumpTargets.insert(target);
        }
    }
    vector<string> optimized;
    int i = 0;

    while (i < lines.size()) {
        string cur = lines[i];
        if (i + 1 < lines.size() && is_redundant_move(cur, lines[i + 1])) {
            optimized.push_back(cur);
            i += 2;
            continue;
        }
        if (i + 1 < lines.size() && is_push_pop_pair(cur, lines[i + 1])) {
            i += 2;
            continue;
        }
        if (is_redundant_neutral_operation(cur)) {
            i++;
            continue;
        }
        string labelName;
        if (is_label(cur, labelName)) {
            vector<string> labelGroup;
            int j = i;
            while (j < lines.size()) {
                string tempLabelName;
                if (is_label(lines[j], tempLabelName)) {
                    labelGroup.push_back(lines[j]);
                    j++;
                } 
                else 
                break;
            }
            cout<<"Label Group size : "<<labelGroup.size()<<endl;
            for(int i=0;i<labelGroup.size();i++)
            {
                
                cout<<labelGroup[i]<<endl;
            }
            bool foundJumpTarget = false;
            string keep_label="";
            for (const string& labelLine : labelGroup) {
                string name;
                if (is_label(labelLine, name)) {
                    cout << "Checking label: " << name << endl;
                    if (jumpTargets.count(name)) {
                        cout << "Name: " << name << " jump is used!" << endl;
                        keep_label=name;
                        foundJumpTarget = true;
                        break;
                    }
                }
            }

            if (foundJumpTarget) {
                /*for (const string& labelLine : labelGroup) {
                    optimized.push_back(labelLine);
                }*/
               optimized.push_back(keep_label+":");
            } else {
                optimized.push_back(labelGroup[0]);
            }

            i = j;
            continue;
        }
        optimized.push_back(cur);
        i++;
    }
    for (const string& line : optimized) {
        outFile << line << endl;
    }

    cout << "Optimized assembly written to " << outputPath << endl;
}

// int main() {
//     optimizeAssembly("output/code.asm", "output/opt_code.asm");
//     return 0;
// }
