EXEC = parser.out
BISON = bison
LEXER_DIR = ../Lexer
AST_DIR = ../ast
CPP = clang++
CPPFLAGS = -std=c++17

.SILENT: test run ../Lexer/lex.yy.c
.PHONY: clean build test run

$(EXEC) : grammar.y ${LEXER_DIR}
	bison -d grammar.y
	${CPP} -o $(EXEC) grammar.tab.c ${LEXER_DIR}/lex.yy.c ${AST_DIR}/ast.cpp ${CPPFLAGS}

build : grammar.y
	$(BISON) -d grammar.y

${LEXER_DIR} :
	$(MAKE) -C $@ build

test: ${EXEC}
	cd Test && ./test.sh

run: $(EXEC)
	./$(EXEC) < Test/tmp.txt

clean: 
	rm -f *.out
	rm -f *.tab.*