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
        <properties> .Map </properties> // PName -> ValProp
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
        <declEnvRec multiplicity="?"> .Map </declEnvRec> // Name -> ValEnv
        // 10.2.1.2 Object Environment Records
        <objEnvRec multiplicity="?">
          <bindingObj> .K </bindingObj> // Oid
          <provideThis> .K </provideThis> // Bool
        </objEnvRec>
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
               | "nullVal"
               | Bool
               | Int
               | Float
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
  syntax KResult ::= Val

  // <properties>
  syntax PName ::= String
  syntax PName ::= PNameOfName(Name) [function]
  rule PNameOfName(N:Name) => #tokenToString(N)
  // 8.6.1 Property Attribute
  syntax Val ::= vd(Val,Bool,Bool,Bool) // ValData = Value * Writable * Enumerable * Configurable
  syntax Val ::= va(Val,Val,Bool,Bool) // ValAccessor = Get * Set * Enumerable * Configurable

  // <declEnvRec>
  syntax Val ::= ve(Val,Bool,Bool,Bool) // ValEnv = Value * Initialized * Mutable * Deletable

  // <activeStack>
  syntax ListItem ::= active(RunningCellFragment)

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
                 <objEnvRec>
                   <bindingObj> globalOid </bindingObj>
                   <provideThis> false </provideThis>
                 </objEnvRec>
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
  // 7.8 Literals
  //////////////////////////////////////////////////////////////////////////////

  // 7.8.1 Null Literals
  rule <k> null => nullVal ... </k>

  // 7.8.2 Boolean Literals
  // Bool

  // 7.8.3 Numeric Literals
  // Int
  // Float

  // 7.8.4 String Literals
  // String

  // 7.8.5 Regular Expression Literals
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 8.7 The Reference Specification Type
  //////////////////////////////////////////////////////////////////////////////

  // 8.7.1 GetValue (V)
  syntax K ::= getValue(K) | endGetValue(K)
  rule <k> getValue(l(E:Eid,N:Name)) => getBindingValue(E,N) ... </k>
  //
  rule <k> getValue(l(O:Oid,P:PName)) => getProperty(O,P) ~> endGetValue(l(O,P)) ... </k>
  rule <k> undefined ~> endGetValue(_) => undefined ... </k>
  rule <k> vd(V:Val,_,_,_) ~> endGetValue(_) => V ... </k>
  // TODO: other cases

  // 8.7.2 PutValue (V, W)
  syntax K ::= putValue(K,K)
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 8.12 Algorithms for Object Internal Methods
  //////////////////////////////////////////////////////////////////////////////

  // 8.12.1 [[GetOwnProperty]] (P)
  syntax K ::= getOwnProperty(Oid,PName)
  rule <k> getOwnProperty(O:Oid,P:PName) => V ... </k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> V:K ... </properties>
         _
       </obj>
  rule <k> getOwnProperty(O:Oid,P:PName) => undefined ... </k>
       <obj>
         <oid> O </oid>
         <properties> Prop </properties>
         _
       </obj>
       when notBool(P in keys(Prop))

  // 8.12.2 [[getProperty]] (P)
  syntax K ::= getProperty(Oid,PName) | endGetProperty(Oid,PName)
  rule <k> getProperty(O:Oid,P:PName) => getOwnProperty(O,P) ~> endGetProperty(O,P) ... </k>
  rule <k> V:Val ~> endGetProperty(_,_) => V ... </k>
       when V =/=K undefined
  rule <k> undefined ~> endGetProperty(O:Oid,P:PName) => getProperty(O',P) ... </k>
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
  syntax K ::= get(Oid,PName) | endGet(Oid,PName)
  rule <k> get(O:Oid,P:PName) => getProperty(O,P) ~> endGet(O,P) ... </k>
  rule <k> vd(V:Val,_,_,_) ~> endGet(_,_) => V ... </k>
  rule <k> va(Get:Val,_,_,_) ~> endGet(O,_) => call(Get,O,.Vals) ... </k>
       when Get =/=K undefined
  rule <k> va(undefined,_,_,_) ~> endGet(_,_) => undefined ... </k>
  rule <k> undefined ~> endGet(_,_) => undefined ... </k>

  // 8.12.4 [[CanPut]] (P)
  syntax K ::= canPut(Oid,PName) | endCanPut(Oid,PName)
  rule <k> canPut(O:Oid,P:PName) => getOwnProperty(O,P) ~> endCanPut(O,P) ... </k>
  rule <k> vd(_,Writable:Bool,_,_) ~> endCanPut(_,_) => Writable ... </k>
  rule <k> va(_,Set:Val,_,_) ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> endCanPut(O:Oid,_) => Extensible ... </k>
       <obj>
         <oid> O </oid>
         <prototype> nullOid </prototype>
         <extensible> Extensible:Bool </extensible>
       </obj>
  //
  rule <k> (. => getProperty(O,P)) ~> undefined ~> endCanPut(O:Oid,P:PName) ... </k>
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
  syntax K ::= put(Oid,PName,Val) | endPut(Oid,PName,Val)
  rule <k> put(O:Oid,P:PName,V:Val) => canPut(O,P) ~> endPut(O,P,V) ... </k>
  // TODO: Consider Step 3
  rule <k> (. => getProperty(O,P)) ~> true ~> endPut(O:Oid,P:PName,_) ... </k>
  rule <k> vd(_,_,_,_) ~> true ~> endPut(O:Oid,P:PName,V:Val)
        => defineOwnProperty(O,P,vd(V,true,true,true)) ... </k>
  rule <k> va(_,Set:Val,_,_) ~> true ~> endPut(O:Oid,_,V:Val) => call(Set,O,V) ... </k>

  // 8.12.6 [[HasProperty]] (P)
  syntax K ::= hasProperty(Oid,PName) | endHasProperty(Oid,PName)
  rule <k> hasProperty(O:Oid,P:PName) => getProperty(O,P) ~> endHasProperty(O,P) ... </k>
  rule <k> V:Val ~> endHasProperty(_,_) => V =/=K undefined ... </k>

  // 8.12.7 [[Delete]] (P, Throw)
  syntax K ::= delete(Oid,PName)
  // TODO:

  // 8.12.8 [[DefaultValue]] (hint)
  syntax K ::= defaultValue(K)
  // TODO:

  // 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)
  syntax K ::= defineOwnProperty(Oid,PName,Val) | endDefineOwnProperty(Oid,PName,Val)
  rule <k> defineOwnProperty(O:Oid,P:PName,V:Val)
        => getOwnProperty(O,P) ~> endDefineOwnProperty(O,P,V) ... </k>
  rule <k> undefined ~> endDefineOwnProperty(O:Oid,P:PName,vd(V:Val,Wr:Bool,En:Bool,Co:Bool))
        => . ... </k>
       <obj>
         <oid> O </oid>
         <properties> (. => P |-> vd(V,Wr,En,Co)) ... </properties>
         <extensible> true </extensible>
         _
       </obj>
  // TODO: other cases

  //////////////////////////////////////////////////////////////////////////////
  // 9 Type Conversion and Testing
  //////////////////////////////////////////////////////////////////////////////

  // 9.1 ToPrimitive
  syntax K ::= toPrimitive(Val)
  // TODO:

  // 9.2 ToBoolean
  syntax K ::= toBoolean(Val)
  // TODO:

  // 9.3 ToNumber
  syntax K ::= toNumber(Val)
  // TODO:

  // 9.4 ToInteger
  syntax K ::= toInteger(Val)
  // TODO:

  // 9.5 ToInt32: (Signed 32 Bit Integer)
  syntax K ::= toInt32(Val)
  // TODO:

  // 9.6 ToUint32: (Unsigned 32 Bit Integer)
  syntax K ::= toUint32(Val)
  // TODO:

  // 9.7 ToUint16: (Unsigned 16 Bit Integer)
  syntax K ::= toUint16(Val)
  // TODO:

  // 9.8 ToString
  syntax K ::= toString(Val)
  rule <k> toString(S:String) => S ... </k>
  // TODO: other cases

  // 9.9 ToObject
  syntax K ::= toObject(Val)
  // TODO:

  // 9.10 CheckObjectCoercible
  syntax K ::= checkObjectCoercible(Val)
  rule <k> checkObjectCoercible(V:Val) => . ... </k>
       when (V =/=K undefined) orBool (V =/=K nullVal)

  // 9.11 IsCallable
  syntax K ::= isCallable(Val)
  // TODO:

  // 9.12 The SameValue Algorithm
  syntax K ::= sameValue(Val,Val)
  // TODO:

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
  rule <k> hasBinding(E:Eid,N:Name) => hasProperty(O,PNameOfName(N)) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>

  syntax K ::= createMutableBinding(Eid,Name,Bool) | endCreateMutableBinding(Eid,Name,Bool)
  // 10.2.1.1.2 CreateMutableBinding (N, D)
  rule <k> createMutableBinding(E:Eid,N:Name,D:Bool) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> (. => N |-> ve(undefined,false,true,D)) Record:Map </declEnvRec>
         _
       </env>
       when notBool(N in keys(Record))
  // 10.2.1.2.2 CreateMutableBinding (N, D)
  rule <k> createMutableBinding(E:Eid,N:Name,D:Bool)
        => hasProperty(O,PNameOfName(N)) ~> endCreateMutableBinding(E,N,D) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>
  rule <k> false ~> endCreateMutableBinding(E:Eid,N:Name,D:Bool)
        => defineOwnProperty(O,PNameOfName(N),vd(undefined,true,true,D)) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>

  syntax K ::= setMutableBinding(Eid,Name,Val)
  // 10.2.1.1.3 SetMutableBinding (N,V,S)
  rule <k> setMutableBinding(E:Eid,N:Name,V:Val) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... N |-> ve((_ => V),(_ => true),true,_) ... </declEnvRec>
         _
       </env>
  // 10.2.1.2.3 SetMutableBinding (N,V,S)
  rule <k> setMutableBinding(E:Eid,N:Name,V:Val) => put(O,PNameOfName(N),V) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>

  syntax K ::= getBindingValue(Eid,Name) | endGetBindingValue(Eid,Name)
  // 10.2.1.1.4 GetBindingValue(N,S)
  // TODO: Consider Step 3
  rule <k> getBindingValue(E:Eid,N:Name) => V ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... N |-> ve(V:Val,_,_,_) ... </declEnvRec>
         _
       </env>
  // 10.2.1.2.4 GetBindingValue(N,S)
  rule <k> getBindingValue(E:Eid,N:Name) => hasProperty(O,PNameOfName(N)) ~> endGetBindingValue(E,N) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>
  rule <k> true ~> endGetBindingValue(E:Eid,N:Name) => get(O,PNameOfName(N)) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>
  rule <k> false ~> endGetBindingValue(_,_) => undefined ... </k>

  syntax K ::= deleteBinding(Eid,Name)
  // 10.2.1.1.5 DeleteBinding (N)
  rule <k> deleteBinding(E:Eid,N:Name) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... (N |-> ve(_,_,_,true) => .) ... </declEnvRec>
         _
       </env>
  // 10.2.1.2.5 DeleteBinding (N)
  rule <k> deleteBinding(E:Eid,N:Name) => delete(O,PNameOfName(N)) ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           _
         </objEnvRec>
         _
       </env>

  syntax K ::= "implicitThisValue"
  // 10.2.1.1.6 ImplicitThisValue()
  rule <k> implicitThisValue => undefined ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> _ </declEnvRec>
         _
       </env>
  // 10.2.1.2.6 ImplicitThisValue()
  rule <k> implicitThisValue => O ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           <provideThis> true </provideThis>
         </objEnvRec>
         _
       </env>
  rule <k> implicitThisValue => undefined ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           <provideThis> false </provideThis>
         </objEnvRec>
         _
       </env>

  syntax K ::= createImmutableBinding(Eid,Name)
  // 10.2.1.1.7 CreateImmutableBinding (N)
  rule <k> createImmutableBinding(E:Eid,N:Name) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> (. => N |-> ve(undefined,false,false,false)) Record:Map </declEnvRec>
         _
       </env>
       when notBool(N in keys(Record))

  syntax K ::= initializeImmutableBinding(Eid,Name,Val)
  // 10.2.1.1.8 InitializeImmutableBinding (N,V)
  rule <k> initializeImmutableBinding(E:Eid,N:Name,V:Val) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> ... N |-> ve((_ => V),(false => true),false,_) ... </declEnvRec>
         _
       </env>

  //////////////////////////////////////////////////////////////////////////////
  // 10.2.2 Lexical Environment Operations
  //////////////////////////////////////////////////////////////////////////////

  // 10.2.2.1 GetIdentifierReference (lex, name, strict)
  syntax K ::= getIdentifierReference(Eid,Name) | endGetIdentifierReference(Eid,Name)
  syntax K ::= l(K,K)
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
                 <objEnvRec>
                   <bindingObj> O </bindingObj>
                   <provideThis> false </provideThis>
                 </objEnvRec>
               </env>)
         _
       </envs>
       when fresh(N:Int)

  //////////////////////////////////////////////////////////////////////////////
  // 10.4 Establishing an Execution Context
  //////////////////////////////////////////////////////////////////////////////

  // 10.4.2 Entering Eval Code
  // TODO:

  // 10.4.3 Entering Function Code
  syntax K ::= enterFunBody(Val,Oid,Vals) | endEnterFunBody(Val,Oid,Vals)
  // TODO: Consider Step 1,2,3
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
         <activeStack> (. => active(R)) ... </activeStack>
         <running>
           (R => <lexicalEnv> E </lexicalEnv>
                 <thisBinding> This </thisBinding>)
         </running>
       </ctx>
       <obj>
         <oid> F </oid>
         <code> Code:SourceElements </code>
         _
       </obj>

  // 10.5 Declaration Binding Instantiation
  syntax K ::= declBindingInst(SourceElements,Vals)
  // TODO:

  // 10.6 Arguments Object
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 11.1 Primary Expressions
  //////////////////////////////////////////////////////////////////////////////

  // 11.1.1 The this Keyword
  rule <k> this => O ... </k>
       <running>
         <thisBinding> O:Oid </thisBinding>
         _
       </running>

  // 11.1.2 Identifier Reference
  // 10.3.1 Identifier Resolution
  rule <k> N:Name => getIdentifierReference(E,N) ... </k>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>

  // 11.1.3 Literal Reference
  // See 7.8 Literals

  // 11.1.4 Array Initialiser
  // TODO:

  // 11.1.5 Object Initialiser
  rule <k> { PAs:PropertyAssignments } => newObject ~> assignProps(HOLE,PAs) ... </k>
  rule <k> O:Oid ~> assignProps(HOLE,PAs:PropertyAssignments) => assignProps(O,PAs) ... </k>
  //
  syntax K ::= assignProps(Oid,PropertyAssignments)
  rule <k> assignProps(O:Oid, .PropertyAssignments) => O ... </k>
  rule <k> assignProps(O:Oid, (PA:PropertyAssignment, PAs:PropertyAssignments))
        => assignProp(PA) ~> assignProps(O,PAs) ... </k>
  //
  syntax K ::= assignProp(PropertyAssignment)
  rule <k> (. => toPName(P)) ~> assignProp(P:PropertyName : _) ~> assignProps(_,_) ... </k>
  rule <k> (. => E) ~> _:PName ~> assignProp(_ : E:Exp) ~> assignProps(_,_) ... </k>
  rule <k> (V:Val ~> P:PName ~> assignProp(_ : _)
            => defineOwnProperty(O,P,vd(V,true,true,true))
           ) ~> assignProps(O:Oid,_) ... </k>
  // TODO: Consider get, set properties
  //
  syntax K /* PName */ ::= toPName(PropertyName)
  rule toPName(N:Name) => PNameOfName(N)
  rule toPName(S:String) => S
  rule toPName(I:Int) => toString(I)
  rule toPName(F:Float) => toString(F)

  // 11.1.6 The Grouping Operator
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 11.2 Left-Hand-Side Expressions
  //////////////////////////////////////////////////////////////////////////////

  // 11.2.1 Property Accessors
  rule <k> _:Val[(_:Val => .), Vs:Vals] ... </k>
       when Vs =/=K .Vals
  rule <k> O:Oid[N:Val]
        => checkObjectCoercible(O) ~> toString(N) ~> getValue(l(O,HOLE)) ... </k>
  rule <k> P:PName ~> getValue(l(O:Oid,HOLE)) => getValue(l(O,P)) ... </k>

  // 11.2.2 The new Operator
  // See 13.2 Creating Function Objects

  // 11.2.3 Function Calls
  // See 13.2 Creating Function Objects

  // 11.2.4 Argument Lists
  // TODO:

  // 11.2.5 Function Expressions
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 11.13 AssignmentOperators
  //////////////////////////////////////////////////////////////////////////////

  // 11.13.1 Simple Assignment ( = )
  // TODO:

  // 11.13.2 Compound Assignment ( op= )
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 12.2 Variable Statement
  //////////////////////////////////////////////////////////////////////////////
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 13 Function Definition
  //////////////////////////////////////////////////////////////////////////////
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 13.2 Creating Function Objects
  //////////////////////////////////////////////////////////////////////////////

  // 11.2.3 Function Calls
  // 13.2.1 [[Call]]
  syntax K ::= call(Val,Oid,Vals)
  // TODO:

  // 11.2.2 The new Operator
  // 13.2.2 [[Construct]]
  rule <k> new F:Val (Vs:Vals) => call(F,o(N),Vs) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> Prototype </prototype>
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
         <obj>
           <oid> F::Oid </oid>
           <prototype> Prototype:Oid </prototype>
           _
         </obj>
         _
       </objs>
       when fresh(N:Int)

  // 13.2.3 The [[ThrowTypeError]] Function Object
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 14 Program
  //////////////////////////////////////////////////////////////////////////////
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 15 Standard Built-in ECMAScript Objects
  //////////////////////////////////////////////////////////////////////////////

  // 15.1 The Global Object
  // 15.2 Object Objects

  // 15.2.2.1 new Object ( [ value ] )
  // TODO: Generalize
  syntax K /* Oid */ ::= "newObject"
  rule <k> newObject => o(N) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> nullOid </prototype> // TODO: Object prototype object 15.2.4
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

  // 15.3 Function Objects
  // 15.4 Array Objects
  // 15.5 String Objects
  // 15.6 Boolean Objects
  // 15.7 Number Objects
  // 15.8 The Math Object
  // 15.9 Date Objects
  // 15.10 RegExp (RegularExpression) Objects
  // 15.11 ErrorObjects
  // 15.12 The JSON Object

  // Temporary
  rule <k> S:SourceElement Ss:SourceElements => S ~> Ss ... </k>
  rule <k> V:Vals ~> S:SourceElements => S ... </k>

endmodule
