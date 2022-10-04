%{
#include <bits/stdc++.h>
using namespace std;

typedef double (*pfun_1doub)(double);

// value type of a symb
union symb_val_t
{
  double     symb_val_as_var; // value of a VAR
  pfun_1doub symb_val_as_fun; // value of a FNCT
};

struct symb
{
  int symb_type;  // VAR or FNCT
  symb_val_t symb_val;
};

// symbol table for VAR and FNCT
map<string, symb> symb_table;

int yylex(); // the lexer
void yyerror(const string &);
%}

// ### YYSTYPE ###
// definition of possible value types of all tokens
// the lexer will set the value of each token to `YYSTYPE yylval`
%union {
  double token_val_as_doub;  // for NUM
  symb  *token_val_as_symb;  // for VAR, FNCT
}

/* ALL TOKENS */
// single char tokens are implicit
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

%% /* end of grammar */

/* Called by yyparse on error */
void yyerror(const string &s) { cout << s << endl; }

// put arithmetic functions in table
void init_table()
{
  struct Temp
  {
    string name;
    pfun_1doub fun;
  };
  Temp arith_fncts[] =
  {
    "sin",  sin,  "cos",  cos,  "tan",  tan,
    "atan", atan, "log",  log,  "log2", log2,
    "exp",  exp,  "sqrt", sqrt, "abs",  abs,
  };
  for (auto &e : arith_fncts) {
    symb *ptr = &symb_table[e.name];
    ptr->symb_type = FNCT;
    ptr->symb_val.symb_val_as_fun = e.fun;
  }
}

// return NUM, VAR, FUN or 0 (for EOF),
//   and set yylval.token_val_as_doub for NUM
//   and set yylval.token_val_as_symb for VAR and FUN
// or ascii code for single character token
int yylex()
{
  static string sym_name; sym_name.reserve(40);
  static int length = 0;
  int c;

  // ignore whitespace
  while ((c = getchar()) == ' ' || c == '\t');
  if (c == EOF) return 0;

  // parse NUM
  if (c == '.' || isdigit(c)) {
    ungetc(c, stdin);
    scanf("%lf", &yylval.token_val_as_doub);
    return NUM;
  }

  // parse symb
  if (isalpha(c)) {
    sym_name.clear();
    do {
      sym_name += c;
      c = getchar();
    }
    while (c != EOF && isalnum(c));

    ungetc(c, stdin);
    symb *s;
    auto it = symb_table.find(sym_name);
    if (it == symb_table.end()) {
      // sym_name not found, add a VAR
      s = &(it->second);
      s->symb_type = VAR;
    }
    else // sym_name found
      s = &(it->second);  
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
