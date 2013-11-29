module JS-SYNTAX
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
                | ExpS ";"                              [strict(1)]
                | "if" "(" ExpS ")" Stmt                [strict(1)]
                | "if" "(" ExpS ")" Stmt "else" Stmt    [strict(1)]
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
                | "return" ExpS ";"                     [strict(1)]
                | "with" "(" ExpS ")" Stmt              [strict(1)]
                | Name ":" Stmt  // label
                | "switch" "(" ExpS ")" CaseBlock       [strict(1)]
                | "throw" ExpS ";"                      [strict(1)]
                | "try" Block Catch
                | "try" Block Finally
                | "try" Block Catch Finally
                | "debugger" ";"
                | "print" "(" Exp ")" ";" [strict(1)]

  syntax Block ::= "{" Stmts "}"

  syntax VarDeclS ::= NeList{VarDecl, ","}
  syntax VarDecl ::= Name
                   | Name "=" Exp                       [strict(2)]

  syntax CaseBlock ::= "{" CaseClauses "}"
                     | "{" CaseClauses DefaultClause CaseClauses "}"
  syntax CaseClauses ::= List{CaseClause, ""}
  syntax CaseClause ::= "case" ExpS ":" Stmts           [strict(1)]
  syntax DefaultClause ::= "default" ":" Stmts

  syntax Catch ::= "catch" "(" Name ")" Block
  syntax Finally ::= "finally" Block

  // A.3 Expressions
  syntax ExpS ::= NeList{Exp, ","}                      [seqstrict]
  syntax Exps ::=   List{Exp, ","}                      [seqstrict]

  syntax AtomicExp ::= Name
                     | Literal
                     | "[" ArrayElements "]"
                     | "{" PropertyAssignments "}"
                     | "(" Exps ")" [bracket]

  syntax Name ::= Token{[\_\$A-Za-z][\_\$A-Za-z0-9]*}   [notInRules]
  syntax String ::= StringOfName(Name) [function]
  rule StringOfName(N:Name) => #tokenToString(N)
  syntax Name ::= NameOfString(String) [function]
  rule NameOfString(S:String) => #parseToken("Name", S)

  syntax Literal ::= "this"
                   | "null"
                   | Bool
                   | Int
                   | Float
                   | String

  syntax ArrayElements ::= List{ExpOpt, ","}
  syntax ExpOpt ::= Exp | "" [onlyLabel, klabel("'epsilonExp")]

  syntax PropertyAssignments ::= List{PropertyAssignment, ","}
  syntax PropertyAssignment ::= PropertyName ":" Exp    [strict(2)]
                              | "get" PropertyName "("      ")" "{" FunBody "}"
                              | "set" PropertyName "(" Name ")" "{" FunBody "}"
  syntax PropertyName ::= Name
                        | String
                        | Int
                        | Float

  syntax LExp ::= AtomicExp
                > FunExp
                | LExp "[" Exps "]"                     [seqstrict,klabel("'lookupLExp")]
                | LExp "." Name
                | "new" LExp "(" Exps ")"               [seqstrict,prefer]
                |       LExp "(" Exps ")"               [seqstrict] // TODO: WRONG!! It should be: [strict(2)]
                > "new" LExp                            [strict(1)]

  syntax Exp ::= LExp
               > Exp "++"                               [strict(1)]
               | Exp "--"                               [strict(1)]
               > "delete" Exp                           [strict(1)]
               | "void" Exp                             [strict(1)]
               | "typeof" Exp                           [strict(1)]
               | "++" Exp                               [strict(1),prefer]
               | "--" Exp                               [strict(1),prefer]
               | "+" Exp                                [strict(1)]
               | "-" Exp                                [strict(1)]
               | "~" Exp                                [strict(1)]
               | "!" Exp                                [strict(1)]
               > left:
                 Exp "*" Exp                            [seqstrict,left]
               | Exp "/" Exp                            [seqstrict,left]
               | Exp "%" Exp                            [seqstrict,left]
               > left:
                 Exp "+" Exp                            [seqstrict,left]
               | Exp "-" Exp                            [seqstrict,left]
               > left:
                 Exp "<<" Exp                           [seqstrict,left]
               | Exp ">>" Exp                           [seqstrict,left]
               | Exp ">>>" Exp                          [seqstrict,left]
               > left:
                 Exp "<" Exp                            [seqstrict,left]
               | Exp ">" Exp                            [seqstrict,left]
               | Exp "<=" Exp                           [seqstrict,left]
               | Exp ">=" Exp                           [seqstrict,left]
               | Exp "instanceof" Exp                   [seqstrict,left]
               | Exp "in" Exp                           [seqstrict,left]
               > left:
                 Exp "==" Exp                           [seqstrict,left]
               | Exp "!=" Exp                           [seqstrict,left]
               | Exp "===" Exp                          [seqstrict,left]
               | Exp "!==" Exp                          [seqstrict,left]
               > left:
                 Exp "&" Exp                            [seqstrict,left]
               > left:
                 Exp "^" Exp                            [seqstrict,left]
               > left:
                 Exp "|" Exp                            [seqstrict,left]
               > left:
                 Exp "&&" Exp                           [strict(1),left]
               > left:
                 Exp "||" Exp                           [strict(1),left]
               > Exp "?" Exp ":" Exp                    [strict(1)]
               > right:
                 LExp "=" Exp                           [strict(2),right,klabel("'assignExp")]
               | LExp "*=" Exp                          [strict(2),right]
               | LExp "/=" Exp                          [strict(2),right]
               | LExp "%=" Exp                          [strict(2),right]
               | LExp "+=" Exp                          [strict(2),right]
               | LExp "-=" Exp                          [strict(2),right]
               | LExp "<<=" Exp                         [strict(2),right]
               | LExp ">>=" Exp                         [strict(2),right]
               | LExp ">>>=" Exp                        [strict(2),right]
               | LExp "&=" Exp                          [strict(2),right]
               | LExp "^=" Exp                          [strict(2),right]
               | LExp "|=" Exp                          [strict(2),right]

  //////////////////////////////////////////////////////////////////////////////
  // Desugaring syntactic sugars
  //////////////////////////////////////////////////////////////////////////////

  rule new E:LExp => new E (.Exps) [macro]

  // 11.2.1 Property Accessors
  rule E:LExp . N:Name => E[StringOfName(N)] [macro]

  syntax Exp ::= assignExp(LExp,Exp)
  syntax LExp ::= lookupLExp(LExp,Exps)

endmodule
