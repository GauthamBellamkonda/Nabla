TEST-DIR := Test
EXEC = lexer.out
PARSER_DIR = ../Parser

.PHONY : test clean build ${PARSER_DIR}
.SILENT : test ${PARSER_DIR} 

$(EXEC) : lexer.l ${PARSER_DIR}
	lex lexer.l
	gcc -o $(EXEC) lex.yy.c ${D_FLAGS}

build : lexer.l
	lex lexer.l

${PARSER_DIR} : 
	$(MAKE) -C $@ build

test :
	@echo "\e[1mTesting Lexer\e[0m"
	cd $(TEST-DIR);\
	make test

clean:
	rm -f *.yy.c 
	rm -f *.out 
	cd $(TEST-DIR); make clean

