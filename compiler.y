%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include "mystruct.h"


struct abstract_tree * mknode(char s,struct abstract_tree *lptr, struct abstract_tree *rptr);
void traverse(struct abstract_tree *);
void generate_code(struct abstract_tree *,int );
struct symbol* lookup_var(char *var);
int add_var(char* type, char *var);
int max(int,int);
void add_code(char * );
extern int yylex();

int IsAssign=1,nameOfreg=1;
char temp_code[40];
extern int l_count;
bool flag=true;
int entry_count=1;
char *tp;

%}

%union
{
     	struct abstract_tree *ptr_tree;
		char* name;
		
};


%token ID
%token END
%token IF
%token ELSE
%token MAIN
%token WHILE
%token TYPE
%token COMMA
%%

	BEGIN:	MAIN '{' START '}'	{	fclose(symbol_table);
					fclose(abstract_tree);
					fclose(code);
				;}	
	;

	START: DECLARATION START
		 | EXPRESSION  START
		 | CONDITIONAL 	START
		 | LOOPS START
		 |
	;



	DECLARATION : PRETYPE ID EXTN END  { if(lookup_var($<ptr_tree>2 -> node) == NULL){
										add_var($<name>1,$<ptr_tree>2 -> node); }
										
										else{
										printf("Error: Variable %s is already declared,this Re-declaration is illegal\n",$<ptr_tree>2 -> node);
										exit(0);
										}
										;}
				;
	PRETYPE:	TYPE {tp=$<name>1;}
				;
	EXTN:		COMMA ID EXTN { if(lookup_var($<ptr_tree>2 -> node) == NULL){
									add_var(tp,$<ptr_tree>2 -> node);}
								else{
										printf("Error: Variable %s is already declared,this Re-declaration is illegal\n",$<ptr_tree>2 -> node);
										}
								
							;}
                | ID EXTN { if(lookup_var($<ptr_tree>1 -> node) == NULL){
							add_var(tp,$<ptr_tree>1 -> node);}
								else{
						printf("Error: Variable %s is already declared,this Re-declaration is illegal\n",$<ptr_tree>1	 -> node);
								}
							
						;}
				|
                ;



	CONDITIONAL: IF '(' CONDITION ')' '{' START 	{   strcpy(temp_code,"JMP ");
														strcat(temp_code,"Lable_exit_");
														char temp[3];
														sprintf(temp,"%d",lable_exit_count);
														strcat(temp_code,temp);
														strcat(temp_code,". \0");
														add_code(temp_code); 
														add_code(". \0");
													;}
									'}'
							{
							strcpy(temp_code,"Lable_");
							char temp[3];
							sprintf(temp,"%d",lable_count++);
							strcat(temp_code,temp);
							strcat(temp_code," :");
							strcat(temp_code,". \0");
							add_code(temp_code); 
							;} 

							else_statement
								
	;
	
	else_statement: ELSE CONDITIONAL
			|ELSE '{' START '}'	{
								add_code(". \0");
								strcpy(temp_code,"Lable_exit_");
								char temp[3];
								sprintf(temp,"%d",lable_exit_count++);
								strcat(temp_code,temp);
								strcat(temp_code," :");
								strcat(temp_code,". \0");
								add_code(temp_code); 
								add_code(". \0");
								;}	
			|					// NULL
	
	;
	LOOPS : WHILE '(' 			{ strcpy(temp_code,"Label_Loop_");
								 char temp[3];
								sprintf(temp,"%d",label_loop_count++);
								strcat(temp_code,temp);
								strcat(temp_code," :");
								strcat(temp_code,". \0");
								add_code(temp_code);
								;}
							
						CONDITION ')' '{'
								
							 START { 
										strcpy(temp_code,"JMP ");
										strcat(temp_code,"Label_Loop_");
										char temp[3];
										sprintf(temp,"%d",--label_loop_count);
										strcat(temp_code,temp);
										strcat(temp_code,". \0");
										add_code(temp_code)

								;}

						
							'}'
								{strcpy(temp_code,"Lable_");
								 char temp[3];
								sprintf(temp,"%d",lable_count++);
								strcat(temp_code,temp);
								strcat(temp_code," :");								
								strcat(temp_code,". \0");
								add_code(temp_code); ;}
					
			;
	CONDITION : E '>' E	{	strcpy(temp_code,"JMPLE ");
							strcat(temp_code,$<ptr_tree>1->node);
							strcat(temp_code,", ");
							strcat(temp_code,$<ptr_tree>3->node);
							strcat(temp_code,", ");
							strcat(temp_code,"Lable_");
							char temp[3];
							sprintf(temp,"%d",lable_count);
							strcat(temp_code,temp);
							strcat(temp_code,". \0");
						add_code(temp_code);
				;}
		
		|     E '<' E	{
					strcpy(temp_code,"JMPGE ");
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,$<ptr_tree>3->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);
				;}
		|E '>''=' E	{

					strcpy(temp_code,"JMPL ");	
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,$<ptr_tree>4->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);
				;}
		|E '<''=' E	{
					strcpy(temp_code,"JMPG ");
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,$<ptr_tree>4->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);	
				;}
		|E '=''=' E	{
					strcpy(temp_code,"JMPNE ");
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,$<ptr_tree>4->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);	
				;}
		|E '!''=' E	{
					strcpy(temp_code,"JMPE ");
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,$<ptr_tree>4->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);
				;}
		|E		{	
					strcpy(temp_code,"JMPZ ");
					strcat(temp_code,$<ptr_tree>1->node);
					strcat(temp_code,", ");
					strcat(temp_code,"Lable_");
					char temp[3];
					sprintf(temp,"%d",lable_count);
					strcat(temp_code,temp);
					strcat(temp_code,". \0");
					add_code(temp_code);
				;}
	
	;
	
	EXPRESSION:	ID '=' E END	{
								if(lookup_var($<ptr_tree>1 -> node) != NULL){
								if(flag){
									if(type_of_symbol($<ptr_tree>1,$<ptr_tree>3)==false){
										printf("%s should be %s.\n",$<ptr_tree>1->node,$<ptr_tree>3->data_type);
										flag = false;
									}

									else {
											$<ptr_tree>$ = mknode('=',$<ptr_tree>1,$<ptr_tree>3);
											generate_code($<ptr_tree>$,1);
											traverse($<ptr_tree>$);
											fprintf(abstract_tree,"\n\n");
											strcat($<ptr_tree>$->code,"\0");
											add_code($<ptr_tree>$->code);
									}
						
						}
						else{
							printf("FAIL\n");
						}
						
					flag=true;
					nameOfreg=1;
					IsAssign=1;
}
else
{
printf("Variable not found");
}
					;}
	;
	
	E: E '-' T 		{
					if(flag){
						if(type_of_symbol($<ptr_tree>1,$<ptr_tree>3)==false){
								printf("%s should be %s.\n",$<ptr_tree>3->node,$<ptr_tree>1->data_type);
								flag = false;
							}
					    
					    else {
								$<ptr_tree>$ = mknode('-',$<ptr_tree>1,$<ptr_tree>3);
						}
					}
				
				;}
		|T		
					{if(flag)	$<ptr_tree>$ = $<ptr_tree>1;	;}
		;

	T: T '+' F		{
					if(flag){
						if(type_of_symbol($<ptr_tree>1,$<ptr_tree>3)==false){
								printf("%s should be %s.\n",$<ptr_tree>3->node,$<ptr_tree>1->data_type);
								flag = false;
						}
						else {
								$<ptr_tree>$ = mknode('+',$<ptr_tree>1,$<ptr_tree>3);
							}
						};
					}
	|F		{
			if(flag)	$<ptr_tree>$ = $<ptr_tree>1;	
			;}
		;

	F: F '*' U 		{if(flag){
						if(type_of_symbol($<ptr_tree>1,$<ptr_tree>3)==false){
							printf("%s should be %s.\n",$<ptr_tree>3->node,$<ptr_tree>1->data_type);
							flag = false;
						}else {
							$<ptr_tree>$ = mknode('*',$<ptr_tree>1,$<ptr_tree>3);
						}
					}
				;}
	|U		{if(flag)	$<ptr_tree>$ = $<ptr_tree>1;	;}
		;

	U: U '/' V		{if(flag){
						if(type_of_symbol($<ptr_tree>1,$<ptr_tree>3)==false){
							printf("%s should be %s.\n",$<ptr_tree>3->node,$<ptr_tree>1->data_type);
							flag = false;
						}else {
							$<ptr_tree>$ = mknode('/',$<ptr_tree>1,$<ptr_tree>3);
						}
					};
				}
	|V		{if(flag)	$<ptr_tree>$ = $<ptr_tree>1;	;}
		;
 
	V: //'('E')' 		{	$<ptr_tree>$ = $<ptr_tree>1;	;}

//	|
	ID		{	$<ptr_tree>$ = $<ptr_tree>1;	;}
	
		

%%
struct symbol* lookup_var(char *var){
	struct symbol *temp=head;
	while(temp){
		if(strcmp(temp->var_name,var)==0){
			return(temp);	
			}
	temp=temp->next;
	}
	return(NULL);
}

struct abstract_tree * mknode(char s, struct abstract_tree *lptr,struct abstract_tree *rptr)
     {
     	struct abstract_tree *p;
          p = (struct abstract_tree *)malloc(sizeof(struct abstract_tree));
	 	 p->node=(char*)malloc(sizeof(char)*2);
          p->node[0]=s;
          p->node[1]='\0';
	  	p->type=lptr->type;
	  	strcpy(p->data_type,lptr->data_type);
          p->left = lptr;
          p->right = rptr;
          return p;

     }	

void traverse(struct abstract_tree *p)
{
     if(p == NULL)
          return;
     
     fprintf(abstract_tree,"%s  %d  %s  %s\n",p->node,p->no_reg,p->name_reg,p->code);
     traverse(p->left);
     traverse(p->right);

}

void add_code(char * input){
	
	fclose(code);
	code=fopen("code.txt","a");
	int i=0;
	while(input[i]!='\0'){
		
		if(input[i]=='.'){
			fprintf(code,"\n");
			i=i+2;
			continue;
		}
		fprintf(code,"%c",input[i]);
		i++;
	}	
}

void generate_code(struct abstract_tree *p,int count){

	
	if(p->left==NULL){
	
		if(count!=0){
			if(IsAssign==1){
				strcpy(p->name_reg,p->node);	
				p->no_reg=0;
				IsAssign=0;
			}
			else{
				sprintf(p->name_reg,"R%d",nameOfreg);
				nameOfreg++;
				p->lines_code=1;

				strcpy(p->code,"MOV ");
				strcat(p->code,p->name_reg);
				strcat(p->code,",");
				strcat(p->code," ");
				char temp_2[10];
				sprintf(temp_2,"%s",p->node);
				strcat(p->code,temp_2);
				strcat(p->code,". ");
				p->no_reg=count;
			}
		}
		else{
			
			//strcpy(p->name_reg,"");
			strcpy(p->name_reg,p->node);	
			p->lines_code=0;
			p->no_reg=count;
		}
		
		return;
	}
	
	generate_code(p->left,1);
	generate_code(p->right,0);
	
	if(p->left->no_reg != p->right->no_reg){
		p->no_reg = max(p->left->no_reg,p->right->no_reg);
	}
	else{
		p->no_reg=p->left->no_reg+1;
	}	
	strcpy(p->name_reg,p->left->name_reg);
	p->lines_code=p->left->lines_code+p->right->lines_code+1;
	strcat(p->code,p->left->code);
	strcat(p->code,p->right->code);
	if(!strcmp(p->node,"*"))
		strcat(p->code,"MUL ");
	else if(!strcmp(p->node,"+"))
		strcat(p->code,"ADD ");
	else if(!strcmp(p->node,"-"))
		strcat(p->code,"SUB ");
	else if(!strcmp(p->node,"/"))
		strcat(p->code,"DIV ");
	else if(!strcmp(p->node,"="))
		strcat(p->code,"MOV ");
	strcat(p->code,p->left->name_reg);
	strcat(p->code,",");
	strcat(p->code," ");
	strcat(p->code,p->right->name_reg);
	strcat(p->code,". ");
}

int max(int i,int j){

	if(i>=j)
		return i;
	else
		return j;
}

bool type_of_symbol(struct abstract_tree* input_1,struct abstract_tree* input_2){
	if(input_1->type!=input_2->type){
			return false;
	}
	return true;
}



int add_var(char* typ, char *var){
	int type;
	if(strcmp(typ,"int") == 0){
			type=1;
	}
	else if(strcmp(typ,"float") == 0){
	type =2;
	}
	
	struct symbol *temp;
	if(lookup_var(var) != NULL){
		printf("\nAt Line %d, variable \" %s \" already exist!\n",l_count,var);
		return(0);
	}	
	temp = (struct symbol*)malloc(sizeof(struct symbol));
	temp->var_type = type;
	switch(type){
			case 1:
				strcpy(temp->data_type,"int");
				break;
			case 2:
				strcpy(temp->data_type,"float");
				break;					
	}
	temp->var_name = (char *)malloc(strlen(var)+1);
	temp->entry=entry_count++;
	strcpy(temp->var_name,var);
 	temp->next = head;	
	head = temp;
	
	fprintf(symbol_table,"%d ",temp->entry);
	fprintf(symbol_table,"%s ",temp->var_name);
	fprintf(symbol_table,"%s \n",temp->data_type);
	
	return(1);	
}



main(){
	symbol_table=fopen("symbol_table.txt","w");
	abstract_tree=fopen("abstract_tree.txt","w");
	code=fopen("code.txt","w");
	code=fopen("code.txt","a");
	yyparse();
}

yyerror(char *err){
	fclose(symbol_table);
	fclose(abstract_tree);
	fclose(code);
	printf("Error : %s at Line %d\n\n",err,l_count);
}
