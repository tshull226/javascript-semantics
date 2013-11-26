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
                | "new" LExp "(" Exps ")" [prefer,strict]
                |       LExp "(" Exps ")" [strict]
                > "new" LExp [strict]

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
                 LExp AssignOp Exp [right]

  syntax AssignOp ::= "="
                    | "*=" | "/=" | "%=" | "+=" | "-="
                    | "<<=" | ">>=" | ">>>=" | "&=" | "^=" | "|="

  rule new E:LExp => new E (.Exps) [macro]

endmodule

module JS
  imports JS-SYNTAX

  configuration <T>
    <k> $PGM:Program </k>
    <envStack> .List </envStack>
    <objs>
      <locs> .Set </locs> // 2^Loc
      <obj multiplicity="*">
        <loc> .K </loc> // Loc
        <class> .K </class> // String
        <extensible> .K </extensible> // Bool
        <prototype> .K </prototype> // Loc
        <properties> .Map </properties> // Var -> ValProp
        <code multiplicity="?"> .K </code> // Fun
        <scope multiplicity="?"> .List </scope> // <envStack>
      </obj>
    </objs>
  </T>

  syntax Vals ::= List{Val, ","}
  syntax Val ::= "undefined"
               | Bool
               | Int
               | String
               | Loc
  syntax Loc ::= l(Int)
               | "nullLoc"

  // Subsorts information
  syntax LExp ::= Val
  syntax Exp ::= Val

  // <envStack>
  // 10.2.1.1 Declarative Environment Records
  syntax ListItem ::= ed(Map) // Var -> ValEnv
  syntax K ::= ve(Val,Bool,Bool) // ValEnv = Value * Mutable * Configurable
  // 10.2.1.2 Object Environment Records
  syntax ListItem ::= eo(Loc)

  // <properties>
  // 8.6.1 Property Attribute
  syntax K ::= vd(Val,Bool,Bool,Bool) // ValData = Value * Writable * Enumerable * Configurable
  syntax K ::= va(Val,Val,Bool,Bool) // ValAccessor = Get * Set * Enumerable * Configurable

  //////////////////////////////////////////////////////////////////////////////
  // Internal Methods
  //////////////////////////////////////////////////////////////////////////////

  // 8.12.1 [[GetOwnProperty]] (P)
  syntax K ::= getOwnProperty(Loc,Name)
  rule <k> getOwnProperty(L:Loc,P:Name) => V ... </k>
       <obj>
         <loc> L </loc>
         <properties> ... P |-> V:K ... </properties>
         _
       </obj>
  rule <k> getOwnProperty(L:Loc,P:Name) => undefined ... </k>
       <obj>
         <loc> L </loc>
         <properties> Prop </properties>
         _
       </obj>
       when notBool(P in keys(Prop))

  // 8.12.2 [[getProperty]] (P)
  syntax K ::= getProperty(Loc,Name) | endGetProperty(Loc,Name)
  rule <k> getProperty(L:Loc,P:Name) => getOwnProperty(L,P) ~> endGetProperty(L,P) ... </k>
  rule <k> V:Val ~> endGetProperty(_,_) => V ... </k>
       when V =/=K undefined
  rule <k> undefined ~> endGetProperty(L:Loc,P:Name) => getProperty(L',P) ... </k>
       <obj>
         <loc> L </loc>
         <prototype> L':Loc </prototype>
         _
       </obj>
       when L' =/=K nullLoc
  rule <k> undefined ~> endGetProperty(L:Loc,_) => undefined ... </k>
       <obj>
         <loc> L </loc>
         <prototype> nullLoc </prototype>
         _
       </obj>

  // 8.12.3 [[Get]] (P)
  syntax K ::= get(Loc,Name) | endGet(Loc,Name)
  rule <k> get(L:Loc,P:Name) => getProperty(L,P) ~> endGet(L,P) ... </k>
  rule <k> vd(V:Val,_,_,_) ~> endGet(_,_) => V ... </k>
  rule <k> va(Get:Val,_,_,_) ~> endGet(L,_) => call(Get,L,.Vals) ... </k>
       when Get =/=K undefined
  rule <k> va(undefined,_,_,_) ~> endGet(_,_) => undefined ... </k>
  rule <k> undefined ~> endGet(_,_) => undefined ... </k>

  // 8.12.4 [[CanPut]] (P)
  syntax K ::= canPut(Loc,Name) | endCanPut(Loc,Name)
  rule <k> canPut(L:Loc,P:Name) => getOwnProperty(L,P) ~> endCanPut(L,P) ... </k>
  rule <k> vd(_,Writable:Bool,_,_) ~> endCanPut(_,_) => Writable ... </k>
  rule <k> va(_,Set:Val,_,_) ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> endCanPut(L:Loc,_) => Extensible ... </k>
       <obj>
         <loc> L </loc>
         <prototype> nullLoc </prototype>
         <extensible> Extensible:Bool </extensible>
       </obj>
  //
  rule <k> (. => getProperty(L,P)) ~> undefined ~> endCanPut(L:Loc,P:Name) ... </k>
       <obj>
         <loc> L </loc>
         <prototype> Prototype:Loc </prototype>
       </obj>
       when Prototype =/=K nullLoc
  rule <k> vd(_,Writable:Bool,_,_) ~> undefined ~> endCanPut(L:Loc,_)
        => Extensible andBool Writable ... </k>
       <obj>
         <loc> L </loc>
         <extensible> Extensible:Bool </extensible>
       </obj>
  rule <k> va(_,Set:Val,_,_) ~> undefined ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> undefined ~> endCanPut(L:Loc,_) => Extensible ... </k>
       <obj>
         <loc> L </loc>
         <extensible> Extensible:Bool </extensible>
       </obj>

  // 8.12.5 [[Put]] ( P, V, Throw )
  // TODO: Consider Throw
  syntax K ::= put(Loc,Name,Val) | endPut(Loc,Name,Val)
  rule <k> put(L:Loc,P:Name,V:Val) => canPut(L,P) ~> endPut(L,P,V) ... </k>
  // TODO: Consider Step 3
  rule <k> (. => getProperty(L,P)) ~> true ~> endPut(L:Loc,P:Name,_) ... </k>
  rule <k> vd(_,_,_,_) ~> true ~> endPut(L:Loc,P:Name,V:Val)
        => defineOwnProperty(L,P,vd(V,true,true,true)) ... </k>
  rule <k> va(_,Set:Val,_,_) ~> true ~> endPut(L:Loc,_,V:Val) => call(Set,L,V) ... </k>

  // 8.12.6 [[HasProperty]] (P)
  syntax K ::= hasProperty(Loc,Name) | endHasProperty(Loc,Name)
  rule <k> hasProperty(L:Loc,P:Name) => getProperty(L,P) ~> endHasProperty(L,P) ... </k>
  rule <k> V:Val ~> endHasProperty(_,_) => V =/=K undefined ... </k>

  // 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)
  syntax K ::= defineOwnProperty(Loc,Name,Val)

  // 11.2.3 Function Calls
  // 13.2.1 [[Call]]
  syntax K ::= call(Val,Loc,Vals)

  // 11.2.2 The new Operator
  // 13.2.2 [[Construct]]
  rule <k> new F:Val (Vs:Vals) => call(F,l(L),Vs) ... </k>
       <objs>
         <locs> (. => SetItem(l(L))) ... </locs>
         (. => <obj>
                 <loc> l(L) </loc>
                 <class> "Object" </class>
                 <extensible> true </extensible>
                 <prototype> Prototype </prototype>
                 <properties> .Map </properties>
               </obj>)
         <obj>
           <loc> F::Loc </loc>
           <prototype> Prototype:Loc </prototype>
           _
         </obj>
         _
       </objs>
       when fresh(L:Int)

endmodule
