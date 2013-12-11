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

  rule <k> SE:SourceElement SEs:SourceElements => SE ~> SEs ... </k>

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

  syntax K ::= "registerFun" "(" Name "," Params "," Int ")"
  rule <k> registerFun(FN, Ps, I) => . ...</k>
       (<task>...
          <k> .SourceElements </k>
          <out> FB </out>
          <id> I </id>
        ...</task> => .)
       <fun>... (. => ListItem(function FN (Ps) { FB })) </fun>

  rule <k> var N:Name; => N; ...</k>
       <var> Var => Var SetItem(N) </var>
       when notBool(N in Var)
  rule <k> var N:Name; => N; ...</k>
       <var> Var </var>
       when (N in Var)
  rule <k> var N:Name = E:Exp; => N = E; ...</k>
       <var> Var => Var SetItem(N) </var>
       when notBool(N in Var)
  rule <k> var N:Name = E:Exp; => N = E; ...</k>
       <var> Var </var>
       when (N in Var)
  rule <k> var D:VarDecl, Ds:VarDeclS; => var D; ~> var Ds; ...</k>
       when Ds =/=K .VarDeclS

  rule <k> S:OtherStmt => . ...</k>
       <other>... (. => ListItem(S)) </other>

  rule <k> .SourceElements </k>
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
