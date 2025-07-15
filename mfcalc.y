%{
// ===== user prologue =========================
#include <bits/stdc++.h>
using namespace std;

typedef double (*pfun_1doub)(double);

// value type of a symb
union symb_val_t
{
  double     symb_val_as_var; // value of a TOK_VAR
  pfun_1doub symb_val_as_fun; // value of a TOK_FNCT
};

// symbol (dynamic typing)
struct symb_t
{
  int symb_type;  // TOK_VAR or TOK_FNCT
  symb_val_t symb_val; // exact type determined by symb_type at runtime
};

// symbol table for TOK_VAR and TOK_FNCT
map<string, symb_t> symb_table;

int yylex(); // the lexer

void yyerror(const string &); // error handler
// ===== end user prologue =========================
%}

// ### YYSTYPE ###
// definition of possible value types of all tokens
// the lexer will set the value of each token to `YYSTYPE yylval` (yy l-value)
%union {
  double token_val_as_doub;  // for TOK_NUM
  symb_t  *token_val_as_symb;  // for TOK_VAR, TOK_FNCT
}

/* ALL TOKENS */
// single char tokens are implicit
// members of `enum yytokentype {};`, aliased `yytoken_kind_t`
%token <token_val_as_doub>  TOK_NUM
%token <token_val_as_symb>  TOK_VAR TOK_FNCT
%type  <token_val_as_doub>  expr

// operators, order determins precidence
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
expr:     TOK_NUM                 { $$ = $1; }
        | TOK_VAR                 { $$ = $1->symb_val.symb_val_as_var; }
        | TOK_VAR '=' expr        { $$ = $3; $1->symb_val.symb_val_as_var = $3; }
        | TOK_FNCT '(' expr ')'   { $$ = (*($1->symb_val.symb_val_as_fun))($3); }
        | expr '+' expr       { $$ = $1 + $3; }
        | expr '-' expr       { $$ = $1 - $3; }
        | expr '*' expr       { $$ = $1 * $3; }
        | expr '/' expr       { $$ = $1 / $3; }
        | '-' expr  %prec NEG { $$ = -$2; }
        | expr '^' expr       { $$ = pow($1, $3); }
        | '(' expr ')'        { $$ = $2; }
;

%% /* end of grammar */

/* Called by yyparse on error */
void yyerror(const string &s) { cout << s << endl; }

// put arithmetic functions in table
void init_table()
{
  struct Func
  {
    string name;
    pfun_1doub fun;
  };

  Func arith_fncts[] =
  {
    "sin",  sin,  "cos",  cos,  "tan",  tan,
    "atan", atan, "log",  log,  "log2", log2,
    "exp",  exp,  "sqrt", sqrt, "abs",  abs,
  };

  for (auto &e : arith_fncts) {
    symb_t *ptr = &symb_table[e.name];
    ptr->symb_type = TOK_FNCT;
    ptr->symb_val.symb_val_as_fun = e.fun;
  }
}

// return TOK_NUM, TOK_VAR, TOK_FNCT or 0 (for EOF),
//   and set yylval.token_val_as_doub for TOK_NUM
//   and set yylval.token_val_as_symb for TOK_VAR and TOK_FNCT
// or ascii code for single character token
int yylex()
{
  static string sym_name; sym_name.reserve(40);
  static int length = 0;
  int c;

  // ignore whitespace
  while ((c = getchar()) == ' ' || c == '\t')
    ;

  if (c == EOF)
    return 0;

  // parse TOK_NUM
  if (c == '.' || isdigit(c)) {
    ungetc(c, stdin);
    scanf("%lf", &yylval.token_val_as_doub);
    return TOK_NUM;
  }

  // parse identifier
  if (isalpha(c)) {
      sym_name.clear();
      do {
          sym_name += c;
          c = getchar();
      } while (c != EOF && isalnum(c));

      ungetc(c, stdin);

      symb_t *s = &symb_table[sym_name];  // inserts a default‑constructed entry
      if (s->symb_type == 0)              // first time we see this name
          s->symb_type = TOK_VAR;

      yylval.token_val_as_symb = s;
      return s->symb_type;
  }

  return c; // single char operator, no value
}

int main()
{
  init_table();
  cout << ">> ";
  yyparse();
  return 0;
}
