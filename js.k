require "js-syntax.k"

module JS
  imports JS-SYNTAX

  configuration <T>
    <k> initConfig ~> $PGM:Program </k>
    <objs>
      <oids> .Set </oids> // 2^Oid
      // 8.6 The Object Type
      <obj multiplicity="*">
        <oid> .K </oid> // Oid
        <properties> .Map </properties> // Var -> ValProp
        // 8.6.2 Object Internal Properties and Methods
        // Table 8 Internal Properties Common to All Objects
        <prototype> .K </prototype> // Oid
        <class> .K </class> // String
        <extensible> .K </extensible> // Bool
        // Table 9 Internal Properties Only Defined for Some Objects
        <primitiveValue multiplicity="?"> .K </primitiveValue>
        <scope multiplicity="?"> .K </scope> // Eid
        <formalParameters multiplicity="?"> .K </formalParameters>
        <code multiplicity="?"> .K </code> // Fun
        <targetFunction multiplicity="?"> .K </targetFunction>
        <boundThis multiplicity="?"> .K </boundThis>
        <boundArguments multiplicity="?"> .K </boundArguments>
        <parameterMap multiplicity="?"> .K </parameterMap>
      </obj>
    </objs>
    <envs>
      <eids> .Set </eids>
      // 10.2 Lexical Environments
      <env multiplicity="*">
        <eid> .K </eid> // Eid
        <outer> .K </outer> // Eid // Reference to an outer Lexical Environment
        // 10.2.1 Environment Records
        // NOTE: Should have either declarative or object environment record
        // 10.2.1.1 Declarative Environment Records
        <declEnvRec multiplicity="?"> .Map </declEnvRec> // Var -> Val
        // 10.2.1.2 Object Environment Records
        <objEnvRec multiplicity="?"> .K </objEnvRec> // Oid
      </env>
    </envs>
    // 10.3 Execution Contexts
    <ctx>
      // Active Execution Contexts
      <activeStack> .List </activeStack>
      // Running Execution Context
      <running>
        // Table 19 Execution Context State Components
        <lexicalEnv> .K </lexicalEnv> // Eid
        <thisBinding> .K </thisBinding> // Oid
      </running>
    </ctx>
  </T>

  syntax Vals ::= List{Val, ","}
  syntax Val ::= "undefined"
               | Bool
               | Int
               | String
               | Oid
  syntax Oid ::= o(Int)
               | "nullOid"
               | "globalOid"
  syntax Eid ::= e(Int)
               | "nullEid"
               | "globalEid" // 10.2.3 The Global Environment
  syntax Cid ::= c(Int)
               | "globalCid"

  // Subsorts information
  syntax LExp ::= Val
  syntax Exp ::= Val

  // <properties>
  // 8.6.1 Property Attribute
  syntax K ::= vd(Val,Bool,Bool,Bool) // ValData = Value * Writable * Enumerable * Configurable
  syntax K ::= va(Val,Val,Bool,Bool) // ValAccessor = Get * Set * Enumerable * Configurable

  // <declEnvRec>
  syntax K ::= ve(Val,Bool,Bool) // ValEnv = Value * Mutable * Configurable

  // <activeStack>
  syntax ListItem ::= active(Eid,Oid)

  //////////////////////////////////////////////////////////////////////////////
  // Initializing Configuration
  //////////////////////////////////////////////////////////////////////////////

  syntax K ::= "initConfig"
  // TODO: More initializations
  rule <k> initConfig => . ... </k>
       <objs>
         <oids> . => SetItem(globalOid) </oids>
         // 15 Standard Built-in ECMAScript Objects
         // 15.1 The Global Object
         (. => <obj>
                 <oid> globalOid </oid>
                 <properties> .Map  </properties> // TODO: It should be: String2Name("window") |-> globalOid
                 <prototype> nullOid </prototype>
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
       </objs>
       <envs>
         <eids> . => SetItem(globalEid) </eids>
         // 10.2.3 The Global Environment
         (. => <env>
                 <eid> globalEid </eid>
                 <objEnvRec> globalOid </objEnvRec>
                 <outer> nullEid </outer>
               </env>)
       </envs>
       <ctx>
         // 10.4.1 Entering Global Code
         // 10.4.1.1 Initial Global Execution Context
         // 10.5 Declaration Binding Instantiation
         // TODO: Declaration Binding Instantiation
         <running>
           <lexicalEnv> . => globalEid </lexicalEnv>
           <thisBinding> . => globalOid </thisBinding>
         </running>
         <activeStack> . </activeStack>
       </ctx>

  //////////////////////////////////////////////////////////////////////////////
  // 8.12 Algorithms for Object Internal Methods
  //////////////////////////////////////////////////////////////////////////////

  // 8.12.1 [[GetOwnProperty]] (P)
  syntax K ::= getOwnProperty(Oid,Name)
  rule <k> getOwnProperty(O:Oid,P:Name) => V ... </k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> V:K ... </properties>
         _
       </obj>
  rule <k> getOwnProperty(O:Oid,P:Name) => undefined ... </k>
       <obj>
         <oid> O </oid>
         <properties> Prop </properties>
         _
       </obj>
       when notBool(P in keys(Prop))

  // 8.12.2 [[getProperty]] (P)
  syntax K ::= getProperty(Oid,Name) | endGetProperty(Oid,Name)
  rule <k> getProperty(O:Oid,P:Name) => getOwnProperty(O,P) ~> endGetProperty(O,P) ... </k>
  rule <k> V:Val ~> endGetProperty(_,_) => V ... </k>
       when V =/=K undefined
  rule <k> undefined ~> endGetProperty(O:Oid,P:Name) => getProperty(O',P) ... </k>
       <obj>
         <oid> O </oid>
         <prototype> O':Oid </prototype>
         _
       </obj>
       when O' =/=K nullOid
  rule <k> undefined ~> endGetProperty(O:Oid,_) => undefined ... </k>
       <obj>
         <oid> O </oid>
         <prototype> nullOid </prototype>
         _
       </obj>

  // 8.12.3 [[Get]] (P)
  syntax K ::= get(Oid,Name) | endGet(Oid,Name)
  rule <k> get(O:Oid,P:Name) => getProperty(O,P) ~> endGet(O,P) ... </k>
  rule <k> vd(V:Val,_,_,_) ~> endGet(_,_) => V ... </k>
  rule <k> va(Get:Val,_,_,_) ~> endGet(O,_) => call(Get,O,.Vals) ... </k>
       when Get =/=K undefined
  rule <k> va(undefined,_,_,_) ~> endGet(_,_) => undefined ... </k>
  rule <k> undefined ~> endGet(_,_) => undefined ... </k>

  // 8.12.4 [[CanPut]] (P)
  syntax K ::= canPut(Oid,Name) | endCanPut(Oid,Name)
  rule <k> canPut(O:Oid,P:Name) => getOwnProperty(O,P) ~> endCanPut(O,P) ... </k>
  rule <k> vd(_,Writable:Bool,_,_) ~> endCanPut(_,_) => Writable ... </k>
  rule <k> va(_,Set:Val,_,_) ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> endCanPut(O:Oid,_) => Extensible ... </k>
       <obj>
         <oid> O </oid>
         <prototype> nullOid </prototype>
         <extensible> Extensible:Bool </extensible>
       </obj>
  //
  rule <k> (. => getProperty(O,P)) ~> undefined ~> endCanPut(O:Oid,P:Name) ... </k>
       <obj>
         <oid> O </oid>
         <prototype> Prototype:Oid </prototype>
       </obj>
       when Prototype =/=K nullOid
  rule <k> vd(_,Writable:Bool,_,_) ~> undefined ~> endCanPut(O:Oid,_)
        => Extensible andBool Writable ... </k>
       <obj>
         <oid> O </oid>
         <extensible> Extensible:Bool </extensible>
       </obj>
  rule <k> va(_,Set:Val,_,_) ~> undefined ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> undefined ~> endCanPut(O:Oid,_) => Extensible ... </k>
       <obj>
         <oid> O </oid>
         <extensible> Extensible:Bool </extensible>
       </obj>

  // 8.12.5 [[Put]] ( P, V, Throw )
  // TODO: Consider Throw
  syntax K ::= put(Oid,Name,Val) | endPut(Oid,Name,Val)
  rule <k> put(O:Oid,P:Name,V:Val) => canPut(O,P) ~> endPut(O,P,V) ... </k>
  // TODO: Consider Step 3
  rule <k> (. => getProperty(O,P)) ~> true ~> endPut(O:Oid,P:Name,_) ... </k>
  rule <k> vd(_,_,_,_) ~> true ~> endPut(O:Oid,P:Name,V:Val)
        => defineOwnProperty(O,P,vd(V,true,true,true)) ... </k>
  rule <k> va(_,Set:Val,_,_) ~> true ~> endPut(O:Oid,_,V:Val) => call(Set,O,V) ... </k>

  // 8.12.6 [[HasProperty]] (P)
  syntax K ::= hasProperty(Oid,Name) | endHasProperty(Oid,Name)
  rule <k> hasProperty(O:Oid,P:Name) => getProperty(O,P) ~> endHasProperty(O,P) ... </k>
  rule <k> V:Val ~> endHasProperty(_,_) => V =/=K undefined ... </k>

  // 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)
  syntax K ::= defineOwnProperty(Oid,Name,Val)

  //////////////////////////////////////////////////////////////////////////////
  // 13.2 Creating Function Objects
  //////////////////////////////////////////////////////////////////////////////

  // 11.2.3 Function Calls
  // 13.2.1 [[Call]]
  syntax K ::= call(Val,Oid,Vals)

  // 11.2.2 The new Operator
  // 13.2.2 [[Construct]]
  rule <k> new F:Val (Vs:Vals) => call(F,o(N),Vs) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <class> "Object" </class>
                 <extensible> true </extensible>
                 <prototype> Prototype </prototype>
                 <properties> .Map </properties>
               </obj>)
         <obj>
           <oid> F::Oid </oid>
           <prototype> Prototype:Oid </prototype>
           _
         </obj>
         _
       </objs>
       when fresh(N:Int)

  //////////////////////////////////////////////////////////////////////////////
  // 10.2.1 Environment Records
  //////////////////////////////////////////////////////////////////////////////

  syntax K ::= hasBinding(Eid,Name)
  // 10.2.1.1.1 HasBinding(N)
  rule <k> hasBinding(E:Eid,N:Name) => true ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... N |-> _ ... </declEnvRec>
         _
       </env>
  rule <k> hasBinding(E:Eid,N:Name) => false ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> Record:Map </declEnvRec>
         _
       </env>
       when notBool(N in keys(Record))
  // 10.2.1.2.1 HasBinding(N)
  rule <k> hasBinding(E:Eid,N:Name) => hasProperty(O,N) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec> O:Oid </objEnvRec>
         _
       </env>

  syntax K ::= getBindingValue(Eid,Name) | endGetBindingValue(Eid,Name)
  // 10.2.1.1.4 GetBindingValue(N,S)
  // TODO: Consider Step 3
  rule <k> getBindingValue(E:Eid,N:Name) => V ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... N |-> ve(V:Val,_,_) ... </declEnvRec>
         _
       </env>
  // 10.2.1.2.4 GetBindingValue(N,S)
  rule <k> getBindingValue(E:Eid,N:Name) => hasProperty(O,N) ~> endGetBindingValue(E,N) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec> O:Oid </objEnvRec>
         _
       </env>
  rule <k> true ~> endGetBindingValue(E:Eid,N:Name) => get(O,N) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec> O:Oid </objEnvRec>
         _
       </env>
  rule <k> false ~> endGetBindingValue(_,_) => undefined ... </k>

  //////////////////////////////////////////////////////////////////////////////
  // 10.2.2 Lexical Environment Operations
  //////////////////////////////////////////////////////////////////////////////

  // 10.2.2.1 GetIdentifierReference (lex, name, strict)
  syntax K ::= getIdentifierReference(Eid,Name) | endGetIdentifierReference(Eid,Name)
  syntax K ::= l(K,Name)
  rule <k> getIdentifierReference(nullEid,N:Name) => l(undefined,N) ... </k>
  rule <k> getIdentifierReference(E:Eid,N:Name)
        => hasBinding(E,N) ~> endGetIdentifierReference(E,N) ... </k>
       when E =/=K nullEid
  rule <k> true ~> endGetIdentifierReference(E:Eid,N:Name) => l(E,N) ... </k>
  rule <k> false ~> endGetIdentifierReference(E:Eid,N:Name)
        => getIdentifierReference(E',N) ... </k>
       <env>
         <eid> E </eid>
         <outer> E' </outer>
         _
       </env>

  // 10.2.2.2 NewDeclarativeEnvironment (E)
  syntax K ::= newDeclarativeEnvironment(Eid)
  rule <k> newDeclarativeEnvironment(E:Eid) => . ... </k>
       <envs>
         <eids> (. => SetItem(e(N))) ... </eids>
         (. => <env>
                 <eid> e(N) </eid>
                 <outer> E </outer>
                 <declEnvRec> .Map </declEnvRec>
               </env>)
         _
       </envs>
       when fresh(N:Int)

  // 10.2.2.3 NewObjectEnvironment (O, E)
  syntax K ::= newObjectEnvironment(Oid,Eid)
  rule <k> newObjectEnvironment(O:Oid,E:Eid) => . ... </k>
       <envs>
         <eids> (. => SetItem(e(N))) ... </eids>
         (. => <env>
                 <eid> e(N) </eid>
                 <outer> E </outer>
                 <objEnvRec> O </objEnvRec>
               </env>)
         _
       </envs>
       when fresh(N:Int)

  //////////////////////////////////////////////////////////////////////////////
  // 8.7 The Reference Specification Type
  //////////////////////////////////////////////////////////////////////////////

  // 8.7.1 GetValue (V)
  syntax K ::= getValue(K)
  rule <k> getValue(l(E:Eid,N:Name)) => getBindingValue(E,N) ... </k>
  // TODO: other cases

  //////////////////////////////////////////////////////////////////////////////
  // 10.4 Establishing an Execution Context
  //////////////////////////////////////////////////////////////////////////////

  // 10.4.3 Entering Function Code
  syntax K ::= enterFunBody(Val,Oid,Vals) | endEnterFunBody(Val,Oid,Vals)
  // TODO: Consider Step 1,2,3
  // TODO: Do first newDeclarativeEnvironment(E)
  rule <k> enterFunBody(F:Val,This:Oid,Args:Vals)
        => newDeclarativeEnvironment(E) ~> endEnterFunBody(F,This,Args) ... </k>
       <obj>
         <oid> F </oid>
         <scope> E:Eid </scope>
         _
       </obj>
  rule <k> E:Eid ~> endEnterFunBody(F:Val,This:Oid,Args:Vals)
        => declBindingInst(Code,Args) ... </k>
       <ctx>
         <activeStack> (. => active(E',This')) ... </activeStack>
         <running>
           <lexicalEnv> E':Eid => E </lexicalEnv>
           <thisBinding> This':Oid => This </thisBinding>
         </running>
       </ctx>
       <obj>
         <oid> F </oid>
         <code> Code:SourceElements </code>
         _
       </obj>


  // 10.5 Declaration Binding Instantiation
  syntax K ::= declBindingInst(SourceElements,Vals)

  //////////////////////////////////////////////////////////////////////////////
  // Semantics
  //////////////////////////////////////////////////////////////////////////////

  // 11.1.2 Identifier Reference
  // 10.3.1 Identifier Resolution
  rule <k> N:Name => getIdentifierReference(E,N) ... </k>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>

  // 11.1.1 The this Keyword
  rule <k> this => O ... </k>
       <running>
         <thisBinding> O:Oid </thisBinding>
         _
       </running>

endmodule
