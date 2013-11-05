module JS
  // Based on ECMA-262, 5.1 Edition, June 2011

  // A.5 Programs
  syntax Program ::= SourceElements

  syntax SourceElements ::= List{SourceElement, ""}
  syntax SourceElement ::= Stmt
                         | FunExp

  // A.5 Functions
  syntax FunExp ::= "function" Name "(" Params ")" "{" FunBody "}"
                  | "function"      "(" Params ")" "{" FunBody "}"
  syntax Params ::= List{Name, ","}
  syntax FunBody ::= SourceElements

  // A.4 Statements
  syntax Stmts ::= List{Stmt, ""}
  syntax Stmt ::= Block
                | "var" VarDeclS ";"
                | ";"
                | ExpS ";"
                | "if" "(" ExpS ")" Stmt
                | "if" "(" ExpS ")" Stmt "else" Stmt
                | "do" Stmt "while" "(" ExpS ")" ";"
                | "while" "(" ExpS ")" Stmt
                | "for" "(" Exps  ";" Exps ";" Exps ")" Stmt
                | "for" "(" "var" VarDeclS ";" Exps ";" Exps ")" Stmt
                | "for" "(" LExp          "in" ExpS ")" Stmt
                | "for" "(" "var" VarDecl "in" ExpS ")" Stmt
                | "continue" ";"
                | "continue" Name ";"
                | "break" ";"
                | "break" Name ";"
                | "return" ";"
                | "return" ExpS ";"
                | "with" "(" ExpS ")" Stmt
                | Name ":" Stmt  // label
                | "switch" "(" ExpS ")" CaseBlock
                | "throw" ExpS ";"
                | "try" Block Catch
                | "try" Block Finally
                | "try" Block Catch Finally
                | "debugger" ";"

  syntax Block ::= "{" Stmts "}"

  syntax VarDeclS ::= NeList{VarDecl, ","}
  syntax VarDecl ::= Name
                   | Name "=" Exp

  syntax CaseBlock ::= "{" CaseClauses "}"
                     | "{" CaseClauses DefaultClause CaseClauses "}"
  syntax CaseClauses ::= List{CaseClause, ""}
  syntax CaseClause ::= "case" ExpS ":" Stmts
  syntax DefaultClause ::= "default" ":" Stmts

  syntax Catch ::= "catch" "(" Name ")" Block
  syntax Finally ::= "finally" Block

  // A.3 Expressions
  syntax ExpS ::= NeList{Exp, ","}
  syntax Exps ::=   List{Exp, ","}

  syntax AtomicExp ::= Name
                     | Literal
                     | "[" ArrayElements "]"
                     | "{" PropertyAssignments "}"
                     | "(" Exps ")" [bracket]

  syntax Name ::= Token{[\_\$A-Za-z][\_\$A-Za-z0-9]*}   [notInRules]

  syntax Literal ::= "this"
                   | "null"
                   | Bool
                   | Int
                   | Float
                   | String

  syntax ArrayElements ::= List{ExpOpt, ","}
  syntax ExpOpt ::= Exp | "" [onlyLabel, klabel("'epsilonExp")]

  syntax PropertyAssignments ::= List{PropertyAssignment, ","}
  syntax PropertyAssignment ::= PropertyName ":" Exp
                              | "get" PropertyName "("      ")" "{" FunBody "}"
                              | "set" PropertyName "(" Name ")" "{" FunBody "}"
  syntax PropertyName ::= Name
                        | String
                        | Int
                        | Float

  syntax LExp ::= AtomicExp
                > FunExp
                | LExp "[" Exps "]"
                | LExp "." Name
                | "new" LExp "(" Exps ")" [prefer]
                |       LExp "(" Exps ")"
                > "new" LExp

  syntax Exp ::= LExp
               > Exp "++"
               | Exp "--"
               > "delete" Exp
               | "void" Exp
               | "typeof" Exp
               | "++" Exp [prefer]
               | "--" Exp [prefer]
               | "+" Exp
               | "-" Exp
               | "~" Exp
               | "!" Exp
               > left:
                 Exp "*" Exp [left]
               | Exp "/" Exp [left]
               | Exp "%" Exp [left]
               > left:
                 Exp "+" Exp [left]
               | Exp "-" Exp [left]
               > left:
                 Exp "<<" Exp [left]
               | Exp ">>" Exp [left]
               | Exp ">>>" Exp [left]
               > left:
                 Exp "<" Exp [left]
               | Exp ">" Exp [left]
               | Exp "<=" Exp [left]
               | Exp ">=" Exp [left]
               | Exp "instanceof" Exp [left]
               | Exp "in" Exp [left]
               > left:
                 Exp "==" Exp [left]
               | Exp "!=" Exp [left]
               | Exp "===" Exp [left]
               | Exp "!==" Exp [left]
               > left:
                 Exp "&" Exp [left]
               > left:
                 Exp "^" Exp [left]
               > left:
                 Exp "|" Exp [left]
               > left:
                 Exp "&&" Exp [left]
               > left:
                 Exp "||" Exp [left]
               > Exp "?" Exp ":" Exp
               > right:
                 LExp "=" Exp [right]
               | LExp "*=" Exp [right]
               | LExp "/=" Exp [right]
               | LExp "%=" Exp [right]
               | LExp "+=" Exp [right]
               | LExp "-=" Exp [right]
               | LExp "<<=" Exp [right]
               | LExp ">>=" Exp [right]
               | LExp ">>>=" Exp [right]
               | LExp "&=" Exp [right]
               | LExp "^=" Exp [right]
               | LExp "|=" Exp [right]

  configuration <T> <k> $PGM:Program </k> </T>
endmodule
