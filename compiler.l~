%{
#include<stdlib.h>
#include<malloc.h>
#include<string.h>
#include "mystruct.h"
#include "y.tab.h"
#include<stdlib.h>
struct abstract_tree * mkleaf(const char *);

#define LOOKUP 0
#define INT 1
#define FLOAT 2


int l_count=1;

int temp_2;
int state=LOOKUP;
//int add_var(int type, char *var);
//struct symbol* lookup_var(char *var);

%}
%option yylineno

%%
 
" " {;}
\n { l_count++ ;}
";"	{state=LOOKUP;
	return END;}
"," {return COMMA;}
"int"	{yylval.name=(char*)malloc(sizeof(char)*strlen(yytext));
		strcpy(yylval.name,yytext);
		state = LOOKUP;	
		return TYPE;
		}

"float"	{
		yylval.name=(char*)malloc(sizeof(char)*strlen(yytext));
		strcpy(yylval.name,yytext);		
		state = LOOKUP;
		return TYPE;		
		}


"if"	{return IF;}
"else"	{return ELSE;}
"while"  {return WHILE;}
"main"  {return MAIN;}

[+*=()-/<>!{}]	{return *yytext;}	

[a-zA-Z0-9]+	{
					yylval.name=(char*)malloc(sizeof(char)*strlen(yytext));
					strcpy(yylval.name,yytext);	
					//printf("LEX %s END",yylval.name);
					yylval.ptr_tree=mkleaf(yytext);	
					return ID;

			}         
%%



struct abstract_tree *mkleaf(const char *txt)
{
          struct abstract_tree *p;
          p = (struct abstract_tree *)malloc(sizeof(struct abstract_tree));
          p->node=(char*)malloc(sizeof(char)*strlen(txt+1));	
          strcat(p->node,txt);
          p->left = NULL;
          p->right = NULL;
         
	  return p;
}
     

yywrap(){}
