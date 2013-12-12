require "js-syntax.k"

// Semantics for the first pass
module JS
  imports JS-SYNTAX

  configuration
  <T>
    <tasks>
      <task multiplicity="*">
        <k> $PGM:Program </k>
        <fun> .List </fun>
        <var> .Set </var>
        <other> .List </other>
        <out> .SourceElements </out>
        <id multiplicity="?"> 0 </id>
      </task>
    </tasks>
  </T>

  syntax KResult ::= OtherStmt
                   | OtherStmtsBlock
  syntax OtherStmt ::= OtherStmtsBlock
                     | "for" "(" OtherStmt Exps ";" Exps ")" Stmt                                           [strict(4)]
                     | "try" OtherStmtsBlock "catch" "(" Name ")" Block                                     [strict(3)]
                     | "try" OtherStmtsBlock "catch" "(" Name ")" OtherStmtsBlock
                     | "try" OtherStmtsBlock "finally" Block                                                [strict(2)]
                     | "try" OtherStmtsBlock "finally" OtherStmtsBlock
                     | "try" OtherStmtsBlock "catch" "(" Name ")" Block "finally" Block                     [strict(3)]
                     | "try" OtherStmtsBlock "catch" "(" Name ")" OtherStmtsBlock "finally" Block           [strict(4)]
                     | "try" OtherStmtsBlock "catch" "(" Name ")" OtherStmtsBlock "finally" OtherStmtsBlock
  syntax OtherStmts ::= List{OtherStmt, ""}
  syntax OtherStmtsBlock ::= "{" OtherStmts "}" [klabel('OtherStmtsBlock), onlyLabel]

  rule <k> SE:SourceElement SEs:SourceElements => SE ~> SEs ... </k>

  syntax K ::= "processBlock" "(" Int ")"
             | "endBlock"
  rule <k> {Ss:Stmts} => processBlock(I) ...</k>
       (. => <task>
               <k> Ss ~> endBlock </k>
               <fun> .List </fun>
               <var> .Set </var>
               <other> .List </other>
               <out> .SourceElements </out>
               <id> I </id>
             </task>)
       when fresh(I:Int)
  rule <k> processBlock(I) => 'OtherStmtsBlock(Ss) ...</k>
       <var> Var => Var Var' </var>
       (<task>...
          <k> .K </k>
          <var> Var' </var>
          <out> Ss:OtherStmts </out>
          <id> I </id>
        ...</task> => .)
  rule <k> .SourceElements ~> endBlock => . </k>
       <other> Other => .List </other>
       <out> .SourceElements => finalize(.List, .Set, Other) </out>

  syntax K ::= "registerFun" "(" Name "," Params "," Int ")"
  rule <k> function FN:Name ( Ps:Params ) { FB:SourceElements } => registerFun(FN, Ps, I) ...</k>
       (. => <task>
               <k> FB </k>
               <fun> .List </fun>
               <var> .Set </var>
               <other> .List </other>
               <out> .SourceElements </out>
               <id> I </id>
             </task>)
       when fresh(I:Int)
  rule <k> registerFun(FN, Ps, I) => . ...</k>
       (<task>...
          <k> .K </k>
          <out> FB </out>
          <id> I </id>
        ...</task> => .)
       <fun>... (. => ListItem(function FN (Ps) { FB })) </fun>

  syntax K ::= "registerVars" "(" VarDeclS ")"
  syntax ExpS ::= VarDeclS
  rule <k> var Ds:VarDeclS; => registerVars(Ds) ~> Ds; ...</k>
  rule <k> registerVars(.VarDeclS) => . ...</k>
  rule <k> registerVars(N:Name, Ds:VarDeclS) => registerVars(Ds) ...</k>
       <var> Var => Var SetItem(N) </var>
       when notBool(N in Var)
  rule <k> registerVars(N:Name, Ds:VarDeclS) => registerVars(Ds) ...</k>
       <var> Var </var>
       when (N in Var)
  rule <k> registerVars(N:Name = _:Exp, Ds:VarDeclS) => registerVars(Ds) ...</k>
       <var> Var => Var SetItem(N) </var>
       when notBool(N in Var)
  rule <k> registerVars(N:Name = _:Exp, Ds:VarDeclS) => registerVars(Ds) ...</k>
       <var> Var </var>
       when (N in Var)

  rule <k> for(var N:Name in Es:ExpS) S:Stmt => for(N in Es) S ...</k>
       <var> Var => Var SetItem(N) </var>
       when notBool(N in Var)
  rule <k> for(var N:Name in Es:ExpS) S:Stmt => for(N in Es) S ...</k>
       <var> Var </var>
       when (N in Var)

  rule <k> S:OtherStmt => . ...</k>
       <other>... (. => ListItem(S)) </other>

  rule <k> .SourceElements => .K </k>
       <fun> Fun => .List </fun>
       <var> Var => .Set </var>
       <other> Other => .List </other>
       <out> .SourceElements => finalize(Fun, Var, Other) </out>

  syntax SourceElements ::= "finalize" "(" List "," Set "," List ")" [function]
  rule finalize(.List, .Set, .List) => .SourceElements
  rule finalize(ListItem(F) FL:List, VS:Set, OL:List) => F finalize(FL, VS, OL)
  rule finalize(.List, SetItem(V) VS:Set, OL:List) => var V; finalize(.List, VS, OL)
  rule finalize(.List, .Set, ListItem(O) OL:List) => O finalize(.List, .Set, OL)

endmodule
