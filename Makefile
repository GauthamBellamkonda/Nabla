ASTDIR = ast
LEXERDIR = Lexer
PARSERDIR = Parser
BUILDDIR = Build
LEXERFILE = $(LEXERDIR)/lexer.l
PARSERFILE = $(PARSERDIR)/grammar.y
TARGET = exec
CPP = clang++
CPPFLAGS = -std=c++17
LLVMFLAGS = `llvm-config --cxxflags --ldflags --system-libs --libs core`

.PHONY: build $(LEXERDIR) $(PARSERDIR) ${BUILDDIR} ${ASTDIR} debug test_lexer test_parser clean
.SILENT: $(LEXERDIR) $(PARSERDIR) ${BUILDDIR} ${ASTDIR}


our_build: ${LEXERFILE} ${PARSERFILE} ast/ast.cpp ast/ast.h
	flex ${LEXERFILE} && mv lex.yy.c Lexer/lex.yy.c
	bison -d ${PARSERFILE} && mv grammar.tab.c Parser/grammar.tab.c && mv grammar.tab.h Parser/grammar.tab.h
	clang++ ${CPPFLAGS} Parser/grammar.tab.c Lexer/lex.yy.c ast/ast.cpp -o ${TARGET} 

build: $(LEXERDIR) $(PARSERDIR) ${BUILDDIR} 
	clang++ ${CPPFLAGS} -o ${TARGET} Parser/grammar.tab.c Lexer/lex.yy.c ast/ast.cpp
	cp ${TARGET} $(BUILDDIR)/${TARGET}

debug: $(LEXERDIR) $(PARSERDIR) ${BUILDDIR} ${ASTDIR}
	clang++ Parser/grammar.tab.c Lexer/lex.yy.c ast/ast.cpp ${LLVMFLAGS} ${CPPFLAGS} -g -o ${BUILDDIR}/debug.out 
	cp test.nb ${BUILDDIR}

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

$(LEXERDIR): ${BUILDDIR}
	$(MAKE) --no-print-directory -C $@ build
	cp $(LEXERDIR)/*.* $(BUILDDIR)

$(PARSERDIR): ${BUILDDIR}
	$(MAKE) --no-print-directory -C $@ build
	cp $(PARSERDIR)/*.* $(BUILDDIR)

${ASTDIR}: ${BUILDDIR}
	cp ${ASTDIR}/*.* $(BUILDDIR)

test_lexer: $(LEXERDIR)
	$(MAKE) -C $< test

test_parser: $(PARSERDIR)
	$(MAKE) -C $< test

clean:
	rm -rf $(BUILDDIR)
	rm -f $(TARGET)
	$(MAKE) --no-print-directory -C $(LEXERDIR) clean
	$(MAKE) --no-print-directory -C $(PARSERDIR) clean