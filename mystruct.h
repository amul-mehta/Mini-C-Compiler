struct symbol{
	char *var_name;
	int entry;
	int var_type;
	char data_type[7];
	struct symbol *next;
};

struct abstract_tree{
     	char *node;
	int no_reg,lines_code;
	char name_reg[4];
	char data_type[7];
	char code[4000];
	int type;
	struct abstract_tree * left,*right;
	struct abstract_tree *parent;
};

struct symbol *head;

enum {false=0,true};

typedef int bool;

FILE *code;
FILE *abstract_tree;
FILE *symbol_table;

int lable_count,lable_exit_count,label_loop_count;
