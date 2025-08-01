antlr4 -v 4.13.2 -Dlanguage=Cpp C2105123Lexer.g4
antlr4 -v 4.13.2 -Dlanguage=Cpp C2105123Parser.g4
g++ -std=c++17 -w -I/usr/local/include/antlr4-runtime -c C2105123Lexer.cpp C2105123Parser.cpp Main.cpp
g++ -std=c++17 -w C2105123Lexer.o C2105123Parser.o Main.o -L/usr/local/lib/ -lantlr4-runtime -o Main.out -pthread
LD_LIBRARY_PATH=/usr/local/lib ./Main.out $1