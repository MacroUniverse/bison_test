%{
#include <bits/stdc++.h>
using namespace std;

// value type of a symbol
union symb_val_t
{
  double symb_val_as_var; // value of a VAR
  double (*symb_val_as_fun)(double); // value of a FNCT
};

/* definition of `symb'        */
/* Data type for links in the chain of symbols.      */
struct symb
{
  string symb_name;
  int symb_type;  // VAR or FNCT
  symb_val_t symb_val;
  struct symb *symb_next;
};

/* Head node of the symbol table: a chain of `struct symb'.  */
symb *sym_table = NULL;

symb *putsym(const string &sym_name, int sym_type);
symb *getsym(const string &sym_name);

int yylex(); // the lexer
void yyerror(const string &);
%}

// ### YYSTYPE ###
// definition of possible value types of all tokens
// the lexer will set the value of each token to `YYSTYPE yylval`
%union {
  double token_val_as_doub;  // for NUM
  symb *token_val_as_symb; // for VAR, FNCT
}

/* ALL TOKENS */
// NUM -> double
// VAR -> token_val_as_symb
// FNCT -> token_val_as_symb
// (implicit) single char operator

// members of `enum yytokentype {};`, aliased `yytoken_kind_t`
%token <token_val_as_doub>  NUM
%token <token_val_as_symb>  VAR FNCT
%type  <token_val_as_doub>  expr

// order determins precidence
%right '='  // right association
%left '-' '+'
%left '*' '/'
%left NEG // prefixed -
%right '^'


%% /* Grammar starts */

input:   /* empty */
        | input line
;

line:
          '\n'
        | expr '\n'  { cout << "ans = " << $1 << endl << ">> "; }
        | error '\n' { yyerrok; }
;

// types of $$, $1, $2 etc are one of YYSTYPE, i.e. yylval.token_val_as_doub or yylval.token_val_as_symb
// depending on the token
// '+', '-', etc. don't have values and are omitted
expr:     NUM                 { $$ = $1; }
        | VAR                 { $$ = $1->symb_val.symb_val_as_var; }
        | VAR '=' expr        { $$ = $3; $1->symb_val.symb_val_as_var = $3; }
        | FNCT '(' expr ')'   { $$ = (*($1->symb_val.symb_val_as_fun))($3); }
        | expr '+' expr       { $$ = $1 + $3; }
        | expr '-' expr       { $$ = $1 - $3; }
        | expr '*' expr       { $$ = $1 * $3; }
        | expr '/' expr       { $$ = $1 / $3; }
        | '-' expr  %prec NEG { $$ = -$2; }
        | expr '^' expr       { $$ = pow($1, $3); }
        | '(' expr ')'        { $$ = $2; }
;

%% /* End of grammar */

/* Called by yyparse on error */
void yyerror(const string &s) { cout << s << endl; }

// temporary struct
struct Temp
{
  string fname;
  double (*fnct)(double);
};

// put arithmetic functions in table
void init_table()
{
  struct Temp arith_fncts[]
  = {
      "sin", sin,   "cos", cos,   "tan", tan,
      "atan", atan, "log", log,   "log2", log2,
      "exp", exp,   "sqrt", sqrt, "abs", abs,
      "", NULL // end
    };
  int i;
  symb *ptr;
  for (i = 0; arith_fncts[i].fnct != NULL; i++)
  {
    ptr = putsym(arith_fncts[i].fname, FNCT);
    ptr->symb_val.symb_val_as_fun = arith_fncts[i].fnct;
  }
}

// insert sym to the head of the sym_table linked list
symb *putsym(const string &sym_name, int sym_type)
{
  symb *ptr = (symb *) malloc(sizeof(symb));
  ptr->symb_name = sym_name;
  ptr->symb_type = sym_type;
  ptr->symb_val.symb_val_as_var = 0; // set value to 0 even if fctn.
  ptr->symb_next = sym_table;
  sym_table = ptr;
  return ptr;
}

symb *getsym(const string &sym_name)
{
  symb *ptr;
  for (ptr = sym_table; ptr != NULL; ptr = ptr->symb_next)
    if (ptr->symb_name == sym_name)
      return ptr;
  return NULL;
}

// return NUM, VAR, FUN or 0 (for EOF),
//   and set yylval.token_val_as_doub for NUM and yylval.token_val_as_symb
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
    scanf("%lf", &yylval.token_val_as_doub);
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
    yylval.token_val_as_symb = s;
    return s->symb_type;
  }

  /* Any other character is a token by itself. */
  return c;
}

int main()
{
  init_table();
  cout << ">> ";
  yyparse();
  return 0;
}
