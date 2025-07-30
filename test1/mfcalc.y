%{
// ===== user prologue =========================
// copied exactly from mfcalc.y

#include <bits/stdc++.h>
using namespace std;

typedef double (*pfun_000)(double);

// symbol (dynamic typing)
struct Sym
{
  // value type of a sym
  union SymVal
  {
    double sym_var_val_doub;  // for sym_type == TOK_VAR
    pfun_000 sym_fun_val_ptr; // for sym_type == TOK_FNCT
  };

  int sym_type;   // TOK_VAR or TOK_FNCT
  SymVal sym_val; // exact type determined by sym_type at runtime
};

// symbol table for TOK_VAR and TOK_FNCT
// similar to matlab workspace, stores variable values real-time
map<string, Sym> sym_table;

int yylex(); // the lexer

void yyerror(const string &); // error handler
// ===== end user prologue =========================
%}

// ### YYSTYPE (semantic value type) ###
// definition of possible value types of all tokens
// define `union YYSTYPE`
%union {
  // each TOK_* maps to one of these, (see /* ALL TOKENS */)
  double token_val_as_doub;  // for TOK_NUM
  Sym *token_val_as_sym;  // for TOK_VAR, TOK_FNCT
}
// the lexer should set the value of each token to `YYSTYPE yylval` (yy lexical value)

/* ALL TOKENS */
// single char tokens are implicit
// define members of `enum yytokentype {};`, aliased `yytoken_kind_t`
// map each token type to a field of YYSTYPE
%token <token_val_as_doub> TOK_NUM
%token <token_val_as_sym> TOK_VAR TOK_FNCT
// %type defines a non-token expression
%type  <token_val_as_doub> expr

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
          '\n' { cout << ">> "; }
        | expr '\n'  { cout << "ans = " << $1 << endl << ">> "; }
        | error '\n' { yyerrok; }
;

// types of $$, $1, $2 etc will be replaced with one of YYSTYPE, i.e. `yylval.token_val_as_doub` or `yylval.token_val_as_sym` etc. which depends on `%token <...> ...` or `%type <...> ...` declaration
// depending on the token
// '+', '-', etc. don't have values and are omitted
expr:     TOK_NUM                 { $$ = $1; }
        | TOK_VAR                 { $$ = $1->sym_val.sym_var_val_doub; }
        | TOK_VAR '=' expr        { $$ = $3; $1->sym_val.sym_var_val_doub = $3; }
        | TOK_FNCT '(' expr ')'   { $$ = $1->sym_val.sym_fun_val_ptr($3); }
        | expr '+' expr           { $$ = $1 + $3; }
        | expr '-' expr           { $$ = $1 - $3; }
        | expr '*' expr           { $$ = $1 * $3; }
        | expr '/' expr           { $$ = $1 / $3; }
        | '-' expr  %prec NEG     { $$ = -$2; }
        | expr '^' expr           { $$ = pow($1, $3); }
        | '(' expr ')'            { $$ = $2; }
;

%% /* end of grammar */

// ======= user epilogue =================================
// copied exactly from mfcalc.y

/* Called by yyparse on error */
void yyerror(const string &s) { cout << s << endl; }

// put arithmetic functions in table
void init_table()
{
  // register functions
  struct Func
  {
    string name;
    pfun_000 fun;
  };

  Func arith_fncts[] =
      {
          {"sin", sin},
          {"cos", cos},
          {"tan", tan},
          {"atan", atan},
          {"log", log},
          {"log2", log2},
          {"exp", exp},
          {"sqrt", sqrt},
          {"abs", abs},
      };

  for (auto &e : arith_fncts)
  {
    Sym *ptr = &sym_table[e.name];
    ptr->sym_type = TOK_FNCT;
    ptr->sym_val.sym_fun_val_ptr = e.fun;
  }
}

// return TOK_NUM, TOK_VAR, TOK_FNCT or 0 (for EOF),
//   and set yylval.token_val_as_doub for TOK_NUM
//   and set yylval.token_val_as_sym for TOK_VAR and TOK_FNCT
// or ascii code for single character token
int yylex()
{
  static string sym_name;
  sym_name.reserve(40);
  static int length = 0;
  int c;

  // ignore whitespace
  while ((c = getchar()) == ' ' || c == '\t')
    ;

  if (c == EOF)
    return 0;

  // parse TOK_NUM
  if (c == '.' || isdigit(c))
  {
    ungetc(c, stdin);
    scanf("%lf", &yylval.token_val_as_doub);
    return TOK_NUM;
  }

  // parse identifier
  if (isalpha(c))
  {
    sym_name.clear();
    do
    {
      sym_name += c;
      c = getchar();
    } while (c != EOF && isalnum(c));

    ungetc(c, stdin);

    Sym *s = &sym_table[sym_name]; // inserts a default‑constructed entry
    if (s->sym_type == 0)          // first time we see this name
      s->sym_type = TOK_VAR;

    yylval.token_val_as_sym = s;
    return s->sym_type;
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

// ======= end user epilogue =================================
