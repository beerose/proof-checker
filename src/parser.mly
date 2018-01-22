(** Parser for natural deduction proofs **)
%token <string> NAME
%token <char> VAR
%token FORALL, EXISTS
%token LPAREN, RPAREN
%token LPARENK, RPARENK
%token COLON, SEMICOLON
%token FALSE, TRUE
%token OR
%token AND
%token IMPL
%token EQ
%token NEG
%token PROOF, AXIOM
%token END
%token EOF

(** Start *)
%start <Expr.expr option> prog

%%
prog:
  | v = goal            { Some v }
  | AXIOM e = expr5 END { Some (`Axiom e) }
  | EOF                 { None }

goal:
  | n = NAME; e = expr5; e1 = proof  { `Prog (`Goal (`Name n, e), (`Proof e1))}
  
proof:
  | PROOF; e1 = proof_expr END { e1 }

proof_expr:
  | e1 = expr6 SEMICOLON e2 = proof_expr { e1::e2 }
  | AXIOM e1 = expr5 SEMICOLON e2 =proof_expr { (`Axiom e1)::e2 }
  | e = expr6 { [e] }

expr6:
  | LPARENK e = expr5 COLON r = proof_expr RPARENK { `Frame (e, r) }
  | e = expr5 { e }

expr5 :
  | e1 = expr5 EQ e2=expr4     { `Eq (e1, e2) }
  | e = expr4                  { e };

expr4 :
  | e1 = expr4 IMPL e2=expr3   { `Impl (e1, e2) }
  | e = expr3                  { e };

expr3 :
  | e1 = expr3 OR e2=expr2     { `Or (e1, e2) }
  | e = expr2                  { e };

expr2 :
  | e1 = expr2 AND e2=expr1    { `And (e1, e2) }
  | e = expr1                  { e };

expr1 :
  | x = VAR                    { `Var x }
  | FALSE                      { `False }
  | TRUE                       { `True  }
  | NEG e = expr1              { `Neg e }
  | LPAREN e=expr3 RPAREN      { e }
  | LPAREN e=expr5 RPAREN      { `Paren e }
