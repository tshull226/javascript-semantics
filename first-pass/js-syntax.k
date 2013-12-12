// Syntax for the first pass
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
  syntax DeclStmt ::= "var" VarDeclS ";"
  syntax ForStmt ::= "for" "(" "var" VarDecl "in" ExpS ")" Stmt
  syntax OtherStmt ::= ";"
                | ExpS ";"
                | "if" "(" ExpS ")" Stmt                              [strict(2)]
                | "if" "(" ExpS ")" Stmt "else" Stmt                  [strict(2), strict(3)]
                | "do" Stmt "while" "(" ExpS ")" ";"                  [strict(1)]
                | "while" "(" ExpS ")" Stmt                           [strict(2)]
                | "for" "(" Exps  ";" Exps ";" Exps ")" Stmt          [strict(4)]
                | "for" "(" DeclStmt Exps ";" Exps ")" Stmt           [strict(1), strict(4)]
                | "for" "(" LExp          "in" ExpS ")" Stmt          [strict(3)]
                | "continue" ";"
                | "continue" Name ";"
                | "break" ";"
                | "break" Name ";"
                | "return" ";"
                | "return" ExpS ";"
                | "with" "(" ExpS ")" Stmt                            [strict(2)]
                | Name ":" Stmt                                       [strict(2)]
                | "switch" "(" ExpS ")" CaseBlock                     [strict(2)]
                | "throw" ExpS ";"              
                | "try" Block "catch" "(" Name ")" Block                     [strict(1)]
                | "try" Block "finally" Block                                [strict(1)]
                | "try" Block "catch" "(" Name ")" Block "finally" Block     [strict(1)]
                | "debugger" ";"
                | "print" "(" Exp ")" ";"
  syntax Stmt ::= DeclStmt
                | ForStmt
                | OtherStmt
                | Block

  syntax Block ::= "{" Stmts "}"

  syntax VarDeclS ::= NeList{VarDecl, ","}
  syntax VarDecl ::= Name
                   | Name "=" Exp              

  syntax CaseBlock ::= "{" CaseClauses "}"
                     | "{" CaseClauses DefaultClause CaseClauses "}"
  syntax CaseClauses ::= List{CaseClause, ""}
  syntax CaseClause ::= "case" ExpS ":" Stmts 
  syntax DefaultClause ::= "default" ":" Stmts

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
                | "new" LExp "(" Exps ")"               [prefer]
                |       LExp "(" Exps ")"              
                > "new" LExp                          

  syntax Exp ::= LExp
               > Exp "++"                            
               | Exp "--"                           
               > "delete" Exp                      
               | "void" Exp                       
               | "typeof" Exp                    
               | "++" Exp                               [prefer]
               | "--" Exp                               [prefer]
               | "+" Exp                              
               | "-" Exp                             
               | "~" Exp                            
               | "!" Exp                           
               > left:
                 Exp "*" Exp                            [left]
               | Exp "/" Exp                            [left]
               | Exp "%" Exp                            [left]
               > left:
                 Exp "+" Exp                            [left]
               | Exp "-" Exp                            [left]
               > left:
                 Exp "<<" Exp                           [left]
               | Exp ">>" Exp                           [left]
               | Exp ">>>" Exp                          [left]
               > left:
                 Exp "<" Exp                            [left]
               | Exp ">" Exp                            [left]
               | Exp "<=" Exp                           [left]
               | Exp ">=" Exp                           [left]
               | Exp "instanceof" Exp                   [left]
               | Exp "in" Exp                           [left]
               > left:
                 Exp "==" Exp                           [left]
               | Exp "!=" Exp                           [left]
               | Exp "===" Exp                          [left]
               | Exp "!==" Exp                          [left]
               > left:
                 Exp "&" Exp                            [left]
               > left:
                 Exp "^" Exp                            [left]
               > left:
                 Exp "|" Exp                            [left]
               > left:
                 Exp "&&" Exp                           [left]
               > left:
                 Exp "||" Exp                           [left]
               > Exp "?" Exp ":" Exp
               > right:
                 LExp "=" Exp                           [right]
               | LExp "*=" Exp                          [right]
               | LExp "/=" Exp                          [right]
               | LExp "%=" Exp                          [right]
               | LExp "+=" Exp                          [right]
               | LExp "-=" Exp                          [right]
               | LExp "<<=" Exp                         [right]
               | LExp ">>=" Exp                         [right]
               | LExp ">>>=" Exp                        [right]
               | LExp "&=" Exp                          [right]
               | LExp "^=" Exp                          [right]
               | LExp "|=" Exp                          [right]

endmodule
