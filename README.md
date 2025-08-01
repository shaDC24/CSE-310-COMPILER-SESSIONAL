# CSE 310 Compiler Sessional - Complete Compiler Implementation

A comprehensive implementation of a compiler for a subset of the C language, developed as part of CSE 310 (Compiler Sessional) at Bangladesh University of Engineering and Technology (BUET).

##  Project Overview

This repository contains the complete implementation of a compiler that processes a subset of the C programming language. The project is divided into four progressive assignments, each building upon the previous one to create a fully functional compiler.

###  Architecture

```
Source Code (.c) → Lexical Analysis → Syntax Analysis → Semantic Analysis → Intermediate Code Generation → Optimized Assembly Code (.asm)
```

##  Assignments Overview

### Assignment 1: Symbol Table Implementation
** Directory:** `2105123_offline1_Symbol_table/`

Implementation of a comprehensive symbol table using hash tables with chaining for collision resolution.

**Key Features:**
- **SymbolInfo Class**: Stores symbol name, type, and supports chaining for collision resolution
- **ScopeTable Class**: Hash table implementation with SDBM hash function
- **SymbolTable Class**: Manages multiple scope tables as a stack structure
- **Operations**: Insert, lookup, delete, scope management (enter/exit)
- **Hash Function Evaluation**: Comparison of multiple hash functions for collision analysis

**Technical Details:**
- Dynamic memory allocation (no STL containers allowed)
- SDBM hash function implementation
- Proper memory management with destructors
- Support for nested scopes

### Assignment 2: Lexical Analysis
** Directory:** `2105123_offline2_Lexical Analysis/`

A complete lexical analyzer (scanner) built using Flex that converts C source code into token streams.

**Token Recognition:**
- **Keywords**: `if`, `else`, `for`, `while`, `int`, `float`, `void`, etc.
- **Constants**: Integer, floating-point, and character literals
- **Operators**: Arithmetic, relational, logical, assignment operators
- **Identifiers**: Variable and function names
- **Strings**: Single-line and multi-line string literals
- **Comments**: Single-line (`//`) and multi-line (`/* */`) comments

**Error Detection:**
- Malformed numbers and identifiers
- Unfinished strings and comments
- Invalid character constants
- Unrecognized characters

**Output Files:**
- `Ongoing Code/2105123_token.txt`: Generated token stream
- `Ongoing Code/2105123_log.txt`: Detailed analysis log with symbol table operations

### Assignment 3: Syntax and Semantic Analysis
**📁 Directory:** `2105123_offline3_Semantic And Syntax Analysis/`

A complete parser with semantic analysis using ANTLR4 that builds parse trees and performs comprehensive error checking.

**Syntax Analysis:**
- Grammar-based parsing for C subset
- Parse tree construction and traversal
- Ambiguity resolution (if-else conflicts)
- Comprehensive error reporting with line numbers

**Semantic Analysis:**
- **Type Checking**: Assignment compatibility, array indexing, operator operands
- **Type Conversion**: Implicit conversions and warnings
- **Scope Management**: Variable declaration and usage validation
- **Function Analysis**: Parameter matching, return type validation, call verification

**Advanced Features:**
- Symbol table integration with parser
- Function declaration vs definition matching
- Array bounds and indexing validation
- Void function call restrictions

### Assignment 4: Intermediate Code Generation
** Directory:** `2105123_offline4_Intermediate Code Generation/`

Complete code generator that produces optimized 8086 assembly language from parsed C code.

**Code Generation Features:**
- **8086 Assembly Output**: Fully functional assembly code for EMU8086 emulator
- **Stack-based Variables**: All local variables stored on stack
- **Function Calls**: Stack-based parameter passing with register return values
- **Boolean Expressions**: Short-circuit evaluation with jumping code
- **Source Mapping**: Assembly code annotated with source line numbers

**Optimization (Peephole):**
- Redundant instruction removal (`MOV AX, a; MOV a, AX`)
- Unnecessary stack operations (`PUSH AX; POP AX`)
- Identity operations (`ADD AX, 0; MUL AX, 1`)
- Label consolidation

**Output Files:**
- `code.asm`: Generated assembly before optimization
- `opt_code.asm`: Assembly after peephole optimization

## 🛠️ Technology Stack

- **Languages**: C++, Java (ANTLR4 support)
- **Tools**: 
  - Flex (Fast Lexical Analyzer Generator)
  - ANTLR4 (Parser Generator)
  - EMU8086 (Assembly Emulator)
- **Platform**: Linux (WSL compatible)
- **Build**: GCC with memory sanitization support


##  Testing

Each assignment includes comprehensive test cases:

- **Positive Test Cases**: Valid C programs with expected outputs
- **Negative Test Cases**: Programs with various error conditions
- **Edge Cases**: Boundary conditions and corner cases


##  Learning Outcomes

This project demonstrates mastery of:

1. **Data Structures**: Hash tables, stacks, trees, symbol management
2. **Language Processing**: Tokenization, parsing, semantic analysis
3. **Code Generation**: Assembly language, optimization techniques
4. **Software Engineering**: Modular design, error handling, testing
5. **Tools & Technologies**: Flex, ANTLR4, build systems

## 🔧 Advanced Features

- **Symbol Table**: Multiple hash function analysis and optimization
- **Lexer**: Multi-line string and comment support
- **Parser**: ANTLR4 integration with custom actions
- **Code Generator**: Stack-based architecture with optimization



**Note**: This compiler successfully processes a significant subset of the C language and generates working 8086 assembly code. All generated assembly files are tested and verified to run on the EMU8086 emulator.