/* %option noyywrap */
D			[0-9]
L			[a-zA-Z_]
E			[Ee][+-]?{D}+

%{
#include <stdio.h>
#include "error.h"

static void count();
static void comment();
extern void yyerror(const char *);
extern void warning(const char *);
extern void check_integer_overflow(const char *);
char linebuf[500];
char filename[50];

#define xels(s) printf("%s\n", #s)
#define xelc(c) printf("%c\n", c)

%}

%option lex-compat

%%
"/*"						{ comment();}            
"//"[^\n]*      			{}                                          /* consume comment */
"cns"						{ count(); xels(CNS) ;        }                    /* cns is constant */
"float"						{ count(); xels(FLOAT) ;      }          
"int"						{ count(); xels(INT) ;        }        
"Tensor"					{ count(); xels(TENSOR) ;     }         
"var"						{ count(); xels(VAR) ;        }    
"bool"						{ count(); xels(BOOL) ;       }          
"sizeof"					{ count(); xels(SIZEOF) ;     }        
"grad"						{ count(); xels(GRAD) ;       }          
"backward"					{ count(); xels(BACKWARD) ;   }
"cos"						{ count(); xels(COS) ;        }       
"sin"						{ count(); xels(SIN) ;        }       
"exp"						{ count(); xels(EXP) ;        }       
"log"						{ count(); xels(LOG) ;        }       
"declare"					{ count(); xels(DECLARE) ;    }       
"operations"				{ count(); xels(OPERATIONS) ; }    
"gradient"                  { count(); xels(GRADIENT) ;   }      

{L}({L}|{D})*				{ count(); xels(IDENTIFIER) ; }
{D}+						{ check_integer_overflow(yytext); xels(INT_CONST) ;   }
L?'(\\.|[^\\'])+'			{ count(); xels(CONSTANT) ;   }
{D}+{E}						{ count(); xels(FLOAT_CONST) ;    }
{D}*"."{D}+({E})?			{ count(); xels(FLOAT_CONST) ;    }
{D}+"."{D}*({E})?			{ count(); xels(FLOAT_CONST) ;    }

        /* Tensor multiply operator */
"+="				{ count(); xels(ADD_ASSIGN) ; }
"-="				{ count(); xels(SUB_ASSIGN) ; }
"*="				{ count(); xels(MUL_ASSIGN) ; }
"/="				{ count(); xels(DIV_ASSIGN) ; }
"%="				{ count(); xels(MOD_ASSIGN) ; }
"@="				{ count(); xels(AT_ASSIGN) ;  }
";"					{ count(); xelc(';') ;}    
"{"					{ count(); xelc('{') ;}
"}"					{ count(); xelc('}') ;}
","					{ count(); xelc(',') ;}
":"					{ count(); xelc(':') ;}
"="					{ count(); xelc('=') ;}
"("					{ count(); xelc('(') ;}
")"					{ count(); xelc(')') ;}
"["					{ count(); xelc('[') ;}
"]"					{ count(); xelc(']') ;}
"-"					{ count(); xelc('-') ;}
"+"					{ count(); xelc('+') ;}
"*"					{ count(); xelc('*') ;}
"@"					{ count(); xelc('@') ;}  
"/"					{ count(); xelc('/') ;}
"%"					{ count(); xelc('%') ;}
"<"					{ count(); xelc('<') ;}
">"					{ count(); xelc('>') ;}
[ \n\t\v\f]		    { }                                                     /* consume whitespace */
.					{ }                                                     /* ignore other characters */

%%

int yywrap()
{
	return(1);
}


static void comment() {
	char c, c1 = 0;
	while ( (c = input()) != 0 ) {	/* (EOF maps to 0) */
		if ( c == '/' && c1 == '*' )
			return;
		c1 = c;
	}
	printf("Error::Unclosed comment of type */ \n");
}


int column = 0;

void count()
{
	int i;

	for (i = 0; yytext[i] != '\0'; i++)
		if (yytext[i] == '\n')
			column = 0;
		else if (yytext[i] == '\t')
			column += 8 - (column % 8);
		else
            column++;
}

int main(int argc,char** argv)
{
	if( argc >=2 ){
		yyin = fopen(argv[1] ,"r");
		if(yyin ==NULL){
			printf("File not found\n");
			return 1;
		}
	}
	else{
		printf("Use case : ./lexer.out \"filename.txt\" \n");
		return 1;
	}
	yylex();
	return 0;
}