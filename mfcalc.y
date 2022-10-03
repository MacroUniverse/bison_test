%{
#include <math.h>  /* For math functions, cos(), sin(), etc. */
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

// value type of a symbol
typedef union {
    double var;           /* value of a VAR          */
    double (*p_fun)();  /* value of a FNCT         */
  } val_t;

/* definition of `symb'        */
/* Data type for links in the chain of symbols.      */
typedef struct
{
  char *s_name;
  int s_type;  // VAR or FNCT
  val_t s_value;
  struct symb *next;    /* link field              */
} symb;

/* Head node of the symbol table: a chain of `struct symb'.  */
symb *sym_table = NULL;

symb *putsym();
symb *getsym();

int yylex();
void yyerror(char *);
%}

// definition of YYSTYPE -- the class for `yylval` for the lexer
%union {
  double val;  /* For returning numbers.                   */
  symb *p_symb;   /* For returning symbol-table pointers      */
}

/* ALL TOKENS */
// NUM -> double
// VAR -> p_symb
// FNCT -> p_symb
// (implicit) single char operator

// members of `enum yytokentype {};`, aliased `yytoken_kind_t`
//     type
%token <val>  NUM        /* Simple double precision number   */
%token <p_symb> VAR FNCT   /* Variable and Function            */
%type  <val>  expr

// order determins precidence
%right '='
%left '-' '+'
%left '*' '/'
%left NEG     /* Negation--unary minus */
%right '^'    /* Exponential           */

/* Grammar follows */

%%
input:   /* empty */
        | input line
;

line:
          '\n'
        | expr '\n'   { printf("\t%.16g\n", $1); }
        | error '\n' { yyerrok;                 }
;

// types of $1, $2 etc are YYSTYPE
expr:     NUM                 { $$ = $1;                         }
        | VAR                 { $$ = $1->s_value.var;              }
        | VAR '=' expr        { $$ = $3; $1->s_value.var = $3;     }
        | FNCT '(' expr ')'   { $$ = (*($1->s_value.p_fun))($3); }
        | expr '+' expr       { $$ = $1 + $3;                    }
        | expr '-' expr       { $$ = $1 - $3;                    }
        | expr '*' expr       { $$ = $1 * $3;                    }
        | expr '/' expr       { $$ = $1 / $3;                    }
        | '-' expr  %prec NEG { $$ = -$2;                        }
        | expr '^' expr       { $$ = pow($1, $3);                }
        | '(' expr ')'        { $$ = $2;                         }
;
/* End of grammar */
%%

/* Called by yyparse on error */
void yyerror(char *s) { printf("%s\n", s); }

struct Temp
{
  char *fname;
  double (*fnct)();
};

void init_table()  /* puts arithmetic functions in table. */
{
  struct Temp arith_fncts[]
  = {
      "sin", sin,
      "cos", cos,
      "tan", tan,
      "atan", atan,
      "log", log,
      "log2", log2,
      "exp", exp,
      "sqrt", sqrt,
      0, 0
    };
  int i;
  symb *ptr;
  for (i = 0; arith_fncts[i].fname != 0; i++)
  {
    ptr = putsym(arith_fncts[i].fname, FNCT);
    ptr->s_value.p_fun = arith_fncts[i].fnct;
  }
}

// insert sym to the head of the sym_table linked list
symb *putsym(char *sym_name, int sym_type)
{
  symb *ptr = (symb *) malloc(sizeof(symb));
  ptr->s_name = (char *) malloc(strlen(sym_name) + 1);
  strcpy(ptr->s_name, sym_name);
  ptr->s_type = sym_type;
  ptr->s_value.var = 0; // set value to 0 even if fctn.
  ptr->next = sym_table;
  sym_table = ptr;
  return ptr;
}

symb *getsym(char *sym_name)
{
  symb *ptr;
  for (ptr = sym_table; ptr != NULL; ptr = ptr->next)
    if (strcmp(ptr->s_name,sym_name) == 0)
      return ptr;
  return NULL;
}

// return NUM, VAR, FUN or 0 (for EOF),
//   and set yylval.val for NUM and yylval.p_symb
// or ascii code for single character token
int yylex()
{
  int c;

  // ignore whitespace
  while ((c = getchar()) == ' ' || c == '\t');
  if (c == EOF) return 0;

  // Char starts a number => parse the number.
  if (c == '.' || isdigit(c)) {
    ungetc(c, stdin);
    scanf("%lf", &yylval.val);
    return NUM;
  }

  // Char starts an identifier => read the name.
  if (isalpha(c)) {
    static char *sym_name = NULL;
    static int length = 0;
    int i;

    if (length == 0)
      length = 40, sym_name = (char *)malloc(length + 1);

    i = 0;
    do {
      // if buffer is full, make it bigger.
      if (i == length) {
        length *= 2;
        sym_name = (char *)realloc(sym_name, length+1);
      }
      /* Add this character to the buffer.         */
      sym_name[i++] = c;
      /* Get another character.                    */
      c = getchar();
    }
    while (c != EOF && isalnum(c));

    ungetc(c, stdin);
    sym_name[i] = '\0';

    // new symbols must be a variable name!
    symb *s = getsym(sym_name);
    if (s == 0)
      s = putsym(sym_name, VAR);
    yylval.p_symb = s;
    return s->s_type;
  }

  /* Any other character is a token by itself. */
  return c;
}

int main()
{
  init_table();
  yyparse();
  return 0;
}
