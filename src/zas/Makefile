YACC = byacc
LEX = flex
CC = ../zcc/cc86-cc1

all:zas

lex.yy.c:zas.lex
	$(LEX) zas.lex

y.tab.h:zas.y
	$(YACC)  -d zas.y

zas:y.tab.h lex.yy.c zasmain.c
	gcc -g  -DYYDEBUG -o zas lex.yy.c zasmain.c y.tab.c

clean:
	rm -f zas; rm -f zas.exe;rm -f lex.yy.c; rm -f y.tab.c; rm -f y.tab.h; rm -f *.bak; rm -f *~;
	

test:test.psm
	
test.psm:test.c
	$(CC) test.c > test.psm

install:zas
	cp zas.exe ../../bin/zas.exe
	
