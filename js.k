require "js-syntax.k"
require "builtins/mint.k"

module JS
  imports JS-SYNTAX
	imports MINT

  configuration <T>
    <k> initConfig ~> declFuns($PGM:SourceElements) ~> declVars($PGM) ~> execute($PGM) </k>
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
        <builtinFunction> false </builtinFunction> // Bool
        // Table 9 Internal Properties Only Defined for Some Objects
        <primitiveValue multiplicity="?"> .K </primitiveValue>
        <scope multiplicity="?"> .K </scope> // Eid
        <formalParameters multiplicity="?"> .K </formalParameters> // Params = Name list
        <code multiplicity="?"> .K </code> // FunBody = SourceElement list or String for builtin
        <codeNew multiplicity="?"> .K </codeNew> // String for builtin
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
      <activeStack> .List </activeStack> //Fragments of running Cell
      // Running Execution Context
      <running>
        // Table 19 Execution Context State Components
        <lexicalEnv> .K </lexicalEnv> // Eid
        <thisBinding> .K </thisBinding> // Oid
      </running>
    </ctx>
    <in stream="stdin"> .List </in>
    <out stream="stdout"> .List </out>
  </T>

  syntax Vals ::= List{Val, ","}
	syntax Number ::= Int | Float | SpecialNumber 
	syntax SpecialNumber ::=  "NaN"//  | "+0" | "-0" |  "Infinity"
	//TODO: Differentiate between +0, -0
  syntax Val ::= "undefined"
               | "nullVal"
               | Bool
               | Number
               | String
               | Oid

	syntax Eid ::= e(Int)
  syntax Oid ::= o(Int)
               | "nullOid"
               | "globalOid"
               | "objectProtoOid"
               | "functionProtoOid" | "functionConstrOid" | "functionToStringOid" | "functionApplyOid" 
							 | "functionCallOid" | "functionBindOid"
               | "stringProtoOid" | "stringConstrOid" | "stringToStringOid" | "stringValueOfOid" | "stringCharAtOid" 
							 | "stringCharCodeAtOid" | "stringConcatOid" | "stringIndexOfOid" | "stringLastIndexOfOid"
							 | "stringLocaleCompareOid" | "stringMatchOid" | "stringReplaceOid" | "stringSearchOid" |"stringSliceOid"
							 | "stringSplitOid" | "stringSubstringOid" | "stringToLowerCaseOid" | "stringToLocaleLowerCaseOid"
							 | "stringToUpperCaseOid" | "stringToLocaleUpperCaseOid" | "stringTrimOid"
               | "booleanProtoOid" | "booleanConstrOid" | "booleanToStringOid" | "booleanValueOfOid"
               | "numberProtoOid" | "numberConstrOid" | "numberToStringOid" | "numberToLocaleStringOid" | "numberValueOfOid"
							 | "numberToFixedOid" | "numberToExponentialOid" | "numberToPrecisionOid"
               | "throwTypeErrorOid"

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

  syntax K /* .K */ ::= "initConfig"
  // TODO: More initializations
  rule <k> initConfig => . ... </k>
       <objs>
         <oids> . => SetItem(globalOid) </oids> 
         // 15 Standard Built-in ECMAScript Objects
         // 15.1 The Global Object
         (. => <obj>
                 <oid> globalOid </oid>
                 <properties>   
															"Boolean" |-> vd(booleanConstrOid,false,false,false)
															"Function" |-> vd(functionConstrOid,false,false,false)
															"Number" |-> vd(numberConstrOid,false,false,false)
															"String" |-> vd(stringConstrOid,false,false,false)
								 </properties> // TODO: It should be: String2Name("window") |-> globalOid (think this comment is dated?)
                 <prototype> nullOid </prototype>
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> objectProtoOid </oid>
                 <properties> .Map  </properties>
                 <prototype> nullOid </prototype>
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> throwTypeErrorOid </oid>
                 <properties> "length" |-> vd(0, false, false, false) </properties>
                 <prototype> functionProtoOid </prototype>
                 <class> "Function" </class> 
                 <extensible> false </extensible>
								 <scope> globalEid </scope>
								 <formalParameters> .K </formalParameters>
								 <code> .K </code> //TODO: need code ot throw object 13.2.3
               </obj>)
         (. => <obj>
                 <oid> functionProtoOid </oid>
                 <properties>   
															"length" |-> vd(0,false,false,false)  
															"constructor" |-> vd(functionConstrOid,false,false,false)  
															"toString" |-> vd(functionToStringOid,false,false,false)
															"apply" |-> vd(functionApplyOid,false,false,false)
															"call" |-> vd(functionCallOid,false,false,false)
															"bind" |-> vd(functionBindOid,false,false,false)
									</properties>
                 <prototype> objectProtoOid </prototype>
                 <class> "Function" </class>
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> functionConstrOid </oid>
                 <properties> 
															"prototype" |-> vd(functionProtoOid,false,false,false) 
															"length" |-> vd(1,false,false,false)  
								 </properties>
                 <prototype> functionProtoOid </prototype>
                 <class> "Function" </class>
                 <extensible> true </extensible>
								 <code> "newFunction" </code>
								 <codeNew> "newFunction" </codeNew>
               </obj>)
         (. => <obj>
                 <oid> functionToStringOid </oid>
                 <prototype> objectProtoOid </prototype>
                 <class> "Function" </class>
								 <builtinFunction> true </builtinFunction>
                 <extensible> false </extensible>
								 <code> "functionToString" </code>
               </obj>)
         (. => <obj>
                 <oid> functionApplyOid </oid>
                 <prototype> objectProtoOid </prototype>
                 <class> "Function" </class>
								 <builtinFunction> true </builtinFunction>
                 <extensible> false </extensible>
								 <code> "functionApply" </code>
               </obj>)
         (. => <obj>
                 <oid> functionCallOid </oid>
                 <prototype> objectProtoOid </prototype>
                 <class> "Function" </class>
								 <builtinFunction> true </builtinFunction>
                 <extensible> false </extensible>
								 <code> "functionCall" </code>
               </obj>)
         (. => <obj>
                 <oid> functionBindOid </oid>
                 <prototype> objectProtoOid </prototype>
                 <class> "Function" </class>
								 <builtinFunction> true </builtinFunction>
                 <extensible> false </extensible>
								 <code> "functionBind" </code>
               </obj>)
         (. => <obj>
                 <oid> stringProtoOid </oid>
                 <properties> 
															"constructor" |-> vd(stringConstrOid, false, false, false)  
															"toString" |-> vd(stringToStringOid, false, false, false) //need object
															"valueOf" |-> vd(stringValueOfOid, false, false, false)  //need object
															"charAt" |-> vd(stringCharAtOid, false, false, false)  //need object
															"charCodeAt" |-> vd(stringCharCodeAtOid, false, false, false)  //need object
															"concat" |-> vd(stringConcatOid, false, false, false)  //need object
															"indexOf" |-> vd(stringIndexOfOid, false, false, false)  //need object
															"lastIndexOf" |-> vd(stringLastIndexOfOid, false, false, false)  //need object
															"localeCompare" |-> vd(stringLocaleCompareOid, false, false, false)  //need object
															"match" |-> vd(stringMatchOid, false, false, false)  //need object
															"replace" |-> vd(stringReplaceOid, false, false, false)  //need object
															"search" |-> vd(stringSearchOid, false, false, false)  //need object
															"slice" |-> vd(stringSliceOid, false, false, false)  //need object
															"split" |-> vd(stringSplitOid, false, false, false)  //need object
															"substring" |-> vd(stringSubstringOid, false, false, false)  //need object
															"toLowerCase" |-> vd(stringToLowerCaseOid, false, false, false)  //need object
															"toLocaleLowerCase" |-> vd(stringToLocaleLowerCaseOid, false, false, false)  //need object
															"toUpperCase" |-> vd(stringToUpperCaseOid, false, false, false)  //need object
															"toLocaleUpperCase" |-> vd(stringToLocaleUpperCaseOid, false, false, false)  //need object
															"trim" |-> vd(stringTrimOid, false, false, false)  //need object
								 </properties>
                 <prototype> objectProtoOid </prototype>
                 <class> "String" </class>
                 <extensible> true </extensible>
								 <primitiveValue> false </primitiveValue>
               </obj>)
         (. => <obj>
                 <oid> stringConstrOid </oid>
                 <properties> ("length" |-> vd(1, false,false, false)) 
															("prototype" |-> vd(stringProtoOid, false,false, false)) 
															("fromCharCode" |-> vd(stringProtoOid, false,false, false)) 
								 </properties> 
                 <prototype> functionProtoOid </prototype>
                 <class> "String" </class>  //not sure, maybe Function?
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> booleanProtoOid </oid>
                 <properties> 
															"constructor" |-> vd(booleanConstrOid, false, false, false)  
															"toString" |-> vd(booleanToStringOid, false, false, false) //need object
															"valueOf" |-> vd(booleanValueOfOid, false, false, false)  //need object
								 </properties>
                 <prototype> objectProtoOid </prototype>
                 <class> "Boolean" </class>
                 <extensible> true </extensible>
								 <primitiveValue> false </primitiveValue>
               </obj>)
         (. => <obj>
                 <oid> booleanConstrOid </oid>
                 <properties> ("length" |-> vd(1, false,false, false)) 
															("prototype" |-> vd(booleanProtoOid, false,false, false)) </properties> 
                 <prototype> functionProtoOid </prototype>
                 <class> "Boolean" </class>  //not sure, maybe Function?
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> booleanToStringOid </oid>
                 //<properties>	 </properties> 
                 <prototype> functionProtoOid </prototype>
                 <class> "Function" </class>  //not sure, maybe Function?
                 <extensible> true </extensible>
               </obj>)
         (. => <obj>
                 <oid> numberProtoOid </oid>
                 <properties> 
															"constructor" |-> vd(numberConstrOid, false, false, false)  
															"toString" |-> vd(numberToStringOid, false, false, false)  
															"toLocaleString" |-> vd(numberToLocaleStringOid, false, false, false)  
															"valueOf" |-> vd(numberValueOfOid, false, false, false)  
															"toFixed" |-> vd(numberToFixedOid, false, false, false)  
															"toExponential" |-> vd(numberToExponentialOid, false, false, false)  
															"toPrecision" |-> vd(numberToPrecisionOid, false, false, false)  
								 </properties>
                 <prototype> objectProtoOid </prototype>
                 <class> "Number" </class>
                 <extensible> true </extensible>
								 <primitiveValue> 0 </primitiveValue>
               </obj>)
         (. => <obj>
                 <oid> numberConstrOid </oid>
                 <properties> 
                 							("length" |-> vd(1, false,false, false)) 
															("prototype" |-> vd(numberProtoOid, false,false, false)) 
															("MAX_VALUE" |-> vd(9999999, false,false, false))  //TODO: Make max value correct
															("MIN_VALUE" |-> vd(1, false,false, false))  //TODO: Make min value correct
															("NaN" |-> vd(NaN, false,false, false)) 
															("NEGATIVE_INFINITY" |-> vd(9999999, false,false, false))  //TODO: Make value correct
															("POSITIVE_INFINITY" |-> vd(1, false,false, false))  //TODO: Make value correct
								 </properties> 
                 <prototype> functionProtoOid </prototype>
                 <class> "Function" </class> //not sure, maybe Function
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
  syntax K /* Val */ ::= getValue(K) | endGetValue(K)
  rule <k> getValue(l(E:Eid,N:Name)) => getBindingValue(E,N) ... </k>
  //
  rule <k> getValue(l(O:Oid,P:PName)) => getProperty(O,P) ~> endGetValue(l(O,P)) ... </k>
  rule <k> undefined ~> endGetValue(_) => undefined ... </k>
  rule <k> vd(V:Val,_,_,_) ~> endGetValue(_) => V ... </k>
  // TODO: other cases

  // 8.7.2 PutValue (V, W)
  syntax K /* .K */ ::= putValue(K,K)
  rule <k> putValue(l(undefined,N:Name),V:Val) => put(globalOid,PNameOfName(N),V) ... </k>
  rule <k> putValue(l(E:Eid,N:Name),V:Val) => setMutableBinding(E,N,V) ... </k>
  rule <k> putValue(l(O:Oid,P:PName),V:Val) => put(O,P,V) ... </k>
  // TODO: other cases

  //////////////////////////////////////////////////////////////////////////////
  // 8.9 The Completion Specification Type
  //////////////////////////////////////////////////////////////////////////////
  // TODO

  //////////////////////////////////////////////////////////////////////////////
  // 8.12 Algorithms for Object Internal Methods
  //////////////////////////////////////////////////////////////////////////////

  // 8.12.1 [[GetOwnProperty]] (P)
  syntax K /* Val */ ::= getOwnProperty(Oid,PName)
  rule <k> getOwnProperty(O:Oid,P:PName) => V ... </k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> V:K ... </properties>
         <class> S:String </class>
         _
       </obj>
       when S =/=K "Arguments"
  rule <k> getOwnProperty(O:Oid,P:PName) => V ... </k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> V:K ... </properties>
         <class> "Arguments" </class>
         <parameterMap> .K </parameterMap>
         _
       </obj>
  rule <k> getOwnProperty(O:Oid,P:PName) => undefined ... </k>
       <obj>
         <oid> O </oid>
         <properties> Prop </properties>
         _
       </obj>
       when notBool(P in keys(Prop))
  // 10.6 [[GetOwnProperty]] for arguments object
  syntax K /* Val */ ::= endGetOwnPropertyFromArguments(Oid, Oid, PName)
  rule <k> getOwnProperty(O:Oid, P:PName) => getOwnProperty(M, P) ~> endGetOwnPropertyFromArguments(O, M, P) ... </k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> M </parameterMap>
         _
       </obj>
       when M =/=K .K
  rule <k> undefined ~> endGetOwnPropertyFromArguments(O, _, P) => V ...</k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> V:K ... </properties>
         <class> "Arguments" </class>
         _
       </obj>
  rule <k> V:Val ~> endGetOwnPropertyFromArguments(O, M, P) => get(M, P) ~> vd(HOLE, Wr, En, Co) ...</k>
       <obj>
         <oid> O </oid>
         <properties> ... P |-> vd(_, Wr:Bool, En:Bool, Co:Bool) ... </properties>
         <class> "Arguments" </class>
         _
       </obj>
       when V =/=K undefined
  rule <k> (V:Val => .) ~> vd(HOLE => V, _, _, _) ...</k>

  // 8.12.2 [[GetProperty]] (P)
  syntax K /* Val */ ::= getProperty(Oid,PName) | endGetProperty(Oid,PName)
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
  syntax K /* Val */ ::= get(Oid,PName) | endGet(Oid,PName)
  rule <k> get(O:Oid,P:PName) => getProperty(O,P) ~> endGet(O,P) ... </k>
       <obj>
         <oid> O </oid>
         <class> S:String </class>
         _
       </obj>
       when S =/=K "Arguments"
  rule <k> get(O:Oid,P:PName) => getProperty(O,P) ~> endGet(O,P) ... </k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> .K </parameterMap>
         _
       </obj>
  rule <k> vd(V:Val,_,_,_) ~> endGet(_,_) => V ... </k>
  rule <k> va(Get:Oid,_,_,_) ~> endGet(O,_) => call(Get,O,.Vals) ... </k>
       when Get =/=K undefined
  rule <k> va(undefined,_,_,_) ~> endGet(_,_) => undefined ... </k>
  rule <k> undefined ~> endGet(_,_) => undefined ... </k>
  // 10.6 [[Get]] for arguments object
  syntax K /* Val */ ::= endGetFromArguments(Oid, Oid, PName)
  rule <k> get(O:Oid, P:PName) => getOwnProperty(M, P) ~> endGetFromArguments(O, M, P) ...</k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> M </parameterMap>
         _
       </obj>
       when M =/=K .K
  rule <k> undefined ~> endGetFromArguments(O, _, P) => getProperty(O, P) ~> endGet(O, P) ...</k>
  rule <k> V:Val ~> endGetFromArguments(_, M, P) => get(M, P) ...</k> when V =/=K undefined

  // 8.12.4 [[CanPut]] (P)
  syntax K /* Bool */ ::= canPut(Oid,PName) | endCanPut(Oid,PName)
  rule <k> canPut(O:Oid,P:PName) => getOwnProperty(O,P) ~> endCanPut(O,P) ... </k>
  rule <k> vd(_,Writable:Bool,_,_) ~> endCanPut(_,_) => Writable ... </k>
  rule <k> va(_,Set:Val,_,_) ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> endCanPut(O:Oid,_) => Extensible ... </k>
       <obj>
         <oid> O </oid>
         <prototype> nullOid </prototype>
         <extensible> Extensible:Bool </extensible>
         _
       </obj>
  //
  rule <k> (. => getProperty(O,P)) ~> undefined ~> endCanPut(O:Oid,P:PName) ... </k>
       <obj>
         <oid> O </oid>
         <prototype> Prototype:Oid </prototype>
         _
       </obj>
       when Prototype =/=K nullOid
  rule <k> vd(_,Writable:Bool,_,_) ~> undefined ~> endCanPut(O:Oid,_)
        => Extensible andBool Writable ... </k>
       <obj>
         <oid> O </oid>
         <extensible> Extensible:Bool </extensible>
         _
       </obj>
  rule <k> va(_,Set:Val,_,_) ~> undefined ~> endCanPut(_,_) => Set =/=K undefined ... </k>
  rule <k> undefined ~> undefined ~> endCanPut(O:Oid,_) => Extensible ... </k>
       <obj>
         <oid> O </oid>
         <extensible> Extensible:Bool </extensible>
         _
       </obj>

  // 8.12.5 [[Put]] ( P, V, Throw )
  // TODO: Consider Throw
  syntax K /* .K */ ::= put(Oid,PName,Val) | endPut(Oid,PName,Val)
  rule <k> put(O:Oid,P:PName,V:Val) => canPut(O,P) ~> endPut(O,P,V) ... </k>
  // TODO: Consider Step 3
  rule <k> (. => getProperty(O,P)) ~> true ~> endPut(O:Oid,P:PName,_) ... </k>
  rule <k> V':Val ~> true ~> endPut(O:Oid,P:PName,V:Val)
        => defineOwnProperty(O,P,vd(V,true,true,true)) ... </k>
       when isUndefOrDataDesc(V')
  rule <k> va(_,Set:Oid,_,_) ~> true ~> endPut(O:Oid,_,V:Val) => call(Set,O,V) ~> ignore ... </k>

  // 8.12.6 [[HasProperty]] (P)
  syntax K /* Bool */ ::= hasProperty(Oid,PName) | endHasProperty(Oid,PName)
  rule <k> hasProperty(O:Oid,P:PName) => getProperty(O,P) ~> endHasProperty(O,P) ... </k>
  rule <k> V:Val ~> endHasProperty(_,_) => V =/=K undefined ... </k>

  // 8.12.7 [[Delete]] (P, Throw)
  syntax K /* .K */ ::= delete(Oid,PName) | endDelete(Oid,PName)
  // TODO:
  rule <k> delete(O:Oid, P:PName)
        => getOwnProperty(O, P) ~> endDelete(O, P) ...</k>
       <obj>
         <oid> O </oid>
         <class> S:String </class>
         _
       </obj>
       when S =/=K "Arguments"
  rule <k> delete(O:Oid, P:PName)
        => getOwnProperty(O, P) ~> endDelete(O, P) ...</k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> .K </parameterMap>
         _
       </obj>
  rule <k> undefined ~> endDelete(_, _) => . ...</k>
  rule <k> vd(_, _, _, true) ~> endDelete(O, P) => . ...</k>
       <obj>
         <oid> O </oid>
         <properties> P |-> _ => . ... </properties>
         _
       </obj>
  rule <k> va(_, _, _, true) ~> endDelete(O, P) => . ...</k>
       <obj>
         <oid> O </oid>
         <properties> P |-> _ => . ... </properties>
         _
       </obj>
  // 10.6 [[Delete]] for arguments object
  syntax K /* .K */ ::= endDeleteFromArguments(Oid, Oid, PName)
  rule <k> delete(O:Oid, P:PName)
        => getOwnProperty(O, P) ~> endDelete(O, P) ~> getOwnProperty(M, P) ~> endDeleteFromArguments(O, M, P) ...</k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> M </parameterMap>
         _
       </obj>
       when M =/=K .K
  rule <k> undefined ~> endDeleteFromArguments(_, _, _) => . ...</k>
  rule <k> V:Val ~> endDeleteFromArguments(_, M, P)
        => delete(M, P) ...</k>
       when V =/=K undefined

  // 8.12.8 [[DefaultValue]] (hint)
  syntax K /* Val */ ::= defaultValue(K)
  // TODO:

  // 8.12.9 [[DefineOwnProperty]] (P, Desc, Throw)
  syntax K /* .K */ ::= defineOwnProperty(Oid,PName,Val) | endDefineOwnProperty(Oid,PName,Val)
  rule <k> defineOwnProperty(O:Oid,P:PName,V:Val)
        => getOwnProperty(O,P) ~> endDefineOwnProperty(O,P,V) ... </k>
       <obj>
         <oid> O </oid>
         <class> S:String </class>
         _
       </obj>
       when S =/=K "Arguments"
  rule <k> defineOwnProperty(O:Oid,P:PName,V:Val)
        => getOwnProperty(O,P) ~> endDefineOwnProperty(O,P,V) ... </k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> .K </parameterMap>
         _
       </obj>
  // Step 4
  rule <k> undefined ~> endDefineOwnProperty(O:Oid,P:PName,vd(V:Val,Wr:Bool,En:Bool,Co:Bool))
        => . ... </k>
       <obj>
         <oid> O </oid>
         <properties> (. => P |-> vd(V,Wr,En,Co)) ... </properties>
         <extensible> true </extensible>
         _
       </obj>
  // Step 10.b
  rule <k> vd(_,_,_,true) ~> endDefineOwnProperty(O:Oid,P:PName,vd(V:Val,Wr:Bool,En:Bool,Co:Bool))
        => . ... </k>
       <obj>
         <oid> O </oid>
         <properties> P |-> (_ => vd(V,Wr,En,Co)) ... </properties>
         <extensible> true </extensible>
         _
       </obj>
  // TODO: other cases
  rule <k> undefined ~> endDefineOwnProperty(O:Oid,P:PName,va(G:Val,S:Val,En:Bool,Co:Bool))
        => . ... </k>
       <obj>
         <oid> O </oid>
         <properties> (. => P |-> va(G,S,En,Co)) ... </properties>
         <extensible> true </extensible>
         _
       </obj>
  // 10.6 [[DefineOwnProperty]] for arguments object
  syntax K /* .K */ ::= endDefineOwnPropertyToArguments(Oid, Oid, PName, Val)
  // TODO: Update as defineOwnProperty is changed to return a boolean value.
  rule <k> defineOwnProperty(O:Oid, P:PName, V:Val)
        => getOwnProperty(O, P) ~> endDefineOwnProperty(O, P, V) ~> getOwnProperty(M, P) ~> endDefineOwnPropertyToArguments(O, M, P, V) ...</k>
       <obj>
         <oid> O </oid>
         <class> "Arguments" </class>
         <parameterMap> M </parameterMap>
         _
       </obj>
       when M =/=K .K
  rule <k> undefined ~> endDefineOwnPropertyToArguments(_, _, _, _) => . ...</k>
  rule <k> V:Val ~> endDefineOwnPropertyToArguments(_, M, P, va(_, _, _, _))
        => delete(M, P) ...</k>
       when V =/=K undefined
  rule <k> V:Val ~> endDefineOwnPropertyToArguments(_, M, P, vd(V', true, _, _))
        => put(M, P, V') ...</k>
       when V =/=K undefined
  // TODO: Need review.
  rule <k> V:Val ~> endDefineOwnPropertyToArguments(_, M, P, vd(V', false, _, _))
        => put(M, P, V') ~> delete(M, P) ...</k>
       when V =/=K undefined

  //////////////////////////////////////////////////////////////////////////////
  // 9 Type Conversion and Testing
  //////////////////////////////////////////////////////////////////////////////
  
  syntax NonObject ::= "undefined"
               | "nullVal"
               | Bool
               | Number
               | String
	syntax Val ::= NonObject

  // 9.1 ToPrimitive
  syntax K /* Val */ ::= toPrimitive(Val)
	// TODO: defaultValue not yet implemented
	
	rule toPrimitive(V:NonObject) => V
	rule <k> toPrimitive(V:Oid) => defaultValue(V) ...</k> 

  // 9.2 ToBoolean
  syntax K /* Val */ ::= toBoolean(Val)
  // TODO: implement +0, -0

  rule toBoolean(undefined) => false
  rule toBoolean(nullVal) => false
  rule toBoolean(B:Bool) => B
  rule toBoolean(_:SpecialNumber) => false
  rule <k> toBoolean(N:Number) => true ...</k> when N =/=K NaN
  rule toBoolean(S:String) => lengthString(S) ==Int 0

  // 9.3 ToNumber
  syntax K /* Val */ ::= toNumber(Val) | endToNumber(Val)
  // TODO: +0, -0 Correctly

  rule toNumber(undefined) => NaN
  rule toNumber(nullVal) => 0
  rule toNumber(true) => 1
  rule toNumber(false) => 0
  rule toNumber(N:Number) => N

  //TODO: do correctly...
	rule toNumber(S:String) => String2Float(S)
  
  rule toNumber(O:Oid) => toPrimitive(O) ~> endToNumber(O)
	rule V:Val ~> endToNumber(_) => toNumber(V)



  // 9.4 ToInteger
  syntax K /* Val */ ::= toInteger(Val) | endToInteger(Val) |  evaluateInteger(Val)
	//TODO: special Cases correctly, not sure if Float2Int follows Javascript specification

	rule toInteger(V:Val) => toNumber(V) ~> endToInteger(V)
	rule V:Val ~> endToInteger(_) => evaluateInteger(V)

	rule evaluateInteger(NaN) => 0

	rule evaluateInteger(I:Int) => I
	rule evaluateInteger(F:Float) => Float2Int(F)
	

  // 9.5 ToInt32: (Signed 32 Bit Integer)
  syntax K /* Val */ ::= toInt32(Val) | endToInt32(Val) | evaluateInt32(Val)
  // TODO: just using ToInteger for the time being
  
	rule toInt32(V:Val) => toInteger(V)


  // 9.6 ToUint32: (Unsigned 32 Bit Integer)
  syntax K /* Val */ ::= toUint32(Val) | endToUint32(Val)
  // TODO: just using ToInteger for the time being
	rule toUint32(V:Val) => toInteger(V) ~> endToUint32(V)
	rule I:Int ~> endToUint32(_) => absMInt(mi(32, I))
	//rule I:Int ~> endToUint32(V) => mi(32, I) ~> endToUint32(V)
	//rule MI:MInt ~> endToUint32(V) => absMInt(MI)

  // 9.7 ToUint16: (Unsigned 16 Bit Integer)
  syntax K /* Val */ ::= toUint16(Val) | endToUint16(Val)
  // TODO: just using ToInteger for the time being
	rule toUint16(V:Val) => toInteger(V) ~> endToUint16(V)
	rule I:Int ~> endToUint16(_) => absMInt(mi(16, I))

  // 9.8 ToString
  syntax K /* Val */ ::= toString(Val) | endToString(Val)
  rule toString(undefined) => "undefined"
  rule toString(nullVal) => "null"
  rule toString(true) => "true"
  rule toString(false) => "false"
	//number has its special rules (below)
  rule toString(S:String) => S 
  rule toString(O:Oid) => toPrimitive(O) ~> endToString(O) //TODO: need hint of String...
	rule V:Val ~> endToString(_) => toString(V)

	//number cases
  rule toString(NaN) => "NaN"
  rule toString(I:Int) => Int2String(I)
  rule toString(F:Float) => Float2String(F)
  // TODO: other cases
  rule toString(I:Int) => Int2String(I)

  // 9.9 ToObject
  syntax K /* Val */ ::= toObject(Val)
  // TODO: needs type error, object creation (from section 15)
  //rule <k> toObject(undefined) => . ...</k> 
  //rule <k> toObject(null) => . ...</k> 

  //rule <k> toObject(O:Bool) => . ...</k> 
  //rule <k> toObject(O:Number) => . ...</k> 
  //rule <k> toObject(O:String) => . ...</k> 

  rule toObject(O:Oid) => O 

  // 9.10 CheckObjectCoercible
  syntax K /* .K */ ::= checkObjectCoercible(Val)
  rule <k> checkObjectCoercible(V:Val) => . ... </k> 
       when (V =/=K undefined) orBool (V =/=K nullVal)
	//TODO: need a Type Error for Undefine, Null Cases

  // 9.11 IsCallable
  syntax K /* Bool */ ::= isCallable(Val)

	rule isCallable(No:NonObject) => false
  // TODO: object case

  // 9.12 The SameValue Algorithm
  syntax K /* Bool */ ::= sameValue(Val,Val)
  // TODO: when different types, +0, -0 comparison
  rule sameValue(undefined, undefined) => true
  rule sameValue(nullVal, nullVal) => true
  rule sameValue(NaN, NaN) => true
  rule sameValue(V1:Int, V2:Int) => V1 ==Int V2
  rule sameValue(V1:Float, V2:Float) => V1 ==Float V2
  rule sameValue(V1:String, V2:String) => V1 ==String V2
  rule sameValue(V1:Bool, V2:Bool) => V1 ==Bool V2
  rule sameValue(V:Oid, V:Oid) => true
  rule <k> sameValue(V1:Oid, V2:Oid) => false ...</k> when V1 =/=K V2


  //////////////////////////////////////////////////////////////////////////////
  // 10.2.1 Environment Records
  //////////////////////////////////////////////////////////////////////////////

  syntax K /* Bool */ ::= hasBinding(Eid,Name)
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

  syntax K /* .K */ ::= createMutableBinding(Eid,Name,Bool) | endCreateMutableBinding(Eid,Name,Bool)
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

  syntax K /* .K */ ::= setMutableBinding(Eid,Name,Val)
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

  syntax K /* Val */ ::= getBindingValue(Eid,Name) | endGetBindingValue(Eid,Name)
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

  syntax K /* .K */ ::= deleteBinding(Eid,Name)
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

  syntax K /* Val */ ::= implicitThisValue(Eid)
  // 10.2.1.1.6 ImplicitThisValue()
  rule <k> implicitThisValue(E:Eid) => undefined ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> _ </declEnvRec>
         _
       </env>
  // 10.2.1.2.6 ImplicitThisValue()
  rule <k> implicitThisValue(E:Eid) => O ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <bindingObj> O:Oid </bindingObj>
           <provideThis> true </provideThis>
         </objEnvRec>
         _
       </env>
  rule <k> implicitThisValue(E:Eid) => undefined ... </k>
       <env>
         <eid> E </eid>
         <objEnvRec>
           <provideThis> false </provideThis>
           _
         </objEnvRec>
         _
       </env>

  syntax K /* .K */ ::= createImmutableBinding(Eid,Name)
  // 10.2.1.1.7 CreateImmutableBinding (N)
  rule <k> createImmutableBinding(E:Eid,N:Name) => . ... </k>
       <env>
         <eid> E </eid>
         <declEnvRec> (. => N |-> ve(undefined,false,false,false)) Record:Map </declEnvRec>
         _
       </env>
       when notBool(N in keys(Record))

  syntax K /* .K */ ::= initializeImmutableBinding(Eid,Name,Val)
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
  syntax K /* Ref */ ::= getIdentifierReference(Eid,Name) | endGetIdentifierReference(Eid,Name)
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
  syntax K /* Eid */ ::= newDeclarativeEnvironment(Eid)
  rule <k> newDeclarativeEnvironment(E:Eid) => e(N) ... </k>
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
  syntax K /* Eid */ ::= newObjectEnvironment(Oid,Eid)
  rule <k> newObjectEnvironment(O:Oid,E:Eid) => e(N) ... </k>
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
  syntax K /* .K */ ::= enterFunBody(Oid,Oid,Vals) | endEnterFunBody(Oid,Oid,Vals)
  // TODO: Consider Step 1,2,3
  rule <k> enterFunBody(F:Oid,This:Oid,Args:Vals)
        => newDeclarativeEnvironment(E) ~> endEnterFunBody(F,This,Args) ... </k>
       <obj>
         <oid> F </oid>
         <scope> E:Eid </scope>
         _
       </obj>
  rule <k> E:Eid ~> endEnterFunBody(F:Oid,This:Oid,Args:Vals)
        => declFunParams(F,Args) ~> declFuns(Code) ~> declVars(Code) ~> hasBinding(E, NameOfString("arguments")) ~> createArgumentsObj(F, Args) ... </k>
       <obj>
         <oid> F </oid>
         <code> Code:FunBody </code>
         _
       </obj>
       <ctx>
         <activeStack> (. => active(R)) ... </activeStack>
         <running>
           (R => <lexicalEnv> E </lexicalEnv>
                 <thisBinding> This </thisBinding>)
         </running>
       </ctx>
  //
  syntax K /* .K */ ::= "exitFunBody"
  rule <k> exitFunBody => . ... </k>
       <ctx>
         <activeStack> (active(R) => .) ... </activeStack>
         <running> _ => R </running>
       </ctx>

  //////////////////////////////////////////////////////////////////////////////
  // 10.5 Declaration Binding Instantiation
  //////////////////////////////////////////////////////////////////////////////
  // NOTE: We assume that all variable/function declarations are hoisted in advance.
  // 10.5.4 Binding function arguments
  syntax K /* .K */ ::= declFunParams(Oid,Vals) | endDeclFunParams(Oid,Vals)
  rule <k> declFunParams(F:Oid,Args:Vals) => setParams(Ns,Args) ... </k>
       <obj>
         <oid> F </oid>
         <formalParameters> Ns:Params </formalParameters>
         _
       </obj>
  syntax K /* .K */ ::= setParams(Params,Vals)
  rule <k> setParams(.Params, _:Vals) => . ... </k>
  rule <k> setParams((N:Name, Ns:Params), .Vals)
        => var N; ~> assignExp(N,undefined); ~> setParams(Ns, .Vals) ... </k>
  rule <k> setParams((N:Name, Ns:Params), (V:Val, Vs:Vals))
        => var N; ~> assignExp(N,V); ~> setParams(Ns,Vs) ... </k>

  // 10.5.5 Binding nested functions
  syntax K /* .K */ ::= declFuns(FunBody)
  rule <k> declFuns(.SourceElements) => . ...</k>
  rule <k> declFuns(S:Stmt SEs:SourceElements) => . ...</k>
  rule <k> declFuns(F:FunExp SEs:SourceElements) => F ~> declFuns(SEs) ...</k>

  // 10.5.8 Binding variables
  syntax K /* .K */ ::= declVars(FunBody)
  rule <k> declVars(.SourceElements) => . ...</k>
  rule <k> declVars(_:OtherStmt SEs:SourceElements) => . ...</k>
  rule <k> declVars(_:CaseStmt SEs:SourceElements) => . ...</k>
  rule <k> declVars(F:FunExp SEs:SourceElements) => declVars(SEs) ...</k>
  rule <k> declVars(DS:DeclStmt SEs:SourceElements) => DS ~> declVars(SEs) ...</k>

  // 10.6 Arguments Object
  syntax K /* Oid */ ::= createArgumentsObj(Oid, Vals) | endCreateArgumentsObj(Oid, Vals, Params, Oid, Oid, Params, Int)
  rule <k> true ~> createArgumentsObj(F:Oid,Args:Vals) => . ...</k>
  rule <k> false ~> createArgumentsObj(F:Oid,Args:Vals)
        => createArgumentsObj(F,Args) ~> createMutableBinding(E, NameOfString("arguments"), true) ~> setMutableBinding(E, NameOfString("arguments"), HOLE) ...</k>
       <ctx>
         <running>
           <lexicalEnv> E:Eid </lexicalEnv>
           _
         </running>
         _
       </ctx>
  rule <k> (O:Oid => .) ~> createMutableBinding(_,_,_) ~> setMutableBinding(_,_,HOLE => O) ... </k>
  
  rule <k> createArgumentsObj(F:Oid,Args:Vals)
        => defineOwnProperty(o(N), "length", vd(length(Args), true, false, true)) ~> newObject ~> endCreateArgumentsObj(F, Args, Ps, o(N), HOLE, .Params, length(Args)) ...</k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> objectProtoOid </prototype>
                 <class> "Arguments" </class>
                 <extensible> true </extensible>
                 <parameterMap> .K </parameterMap>
               </obj>)
         <obj>
           <oid> F </oid>
           <formalParameters> Ps:Params </formalParameters>
           _
         </obj>
         _
       </objs>
       <ctx>
         <running>
           <lexicalEnv> E:Eid </lexicalEnv>
           _
         </running>
         _
       </ctx>
       when fresh(N:Int)
  rule <k> (O:Oid => .) ~> endCreateArgumentsObj(_, _, _, _, HOLE => O, _, _) ...</k>
  rule <k> endCreateArgumentsObj(F, (A:Val, As:Vals), (P:Name, Ps:Params), O, M, MNs, L)
        => defineOwnProperty(O, Int2String(L -Int length(As) -Int 1), vd(A, true, true, true))
           ~> createFunObj(.Params, (print("getter\n"); return P; .SourceElements))
           ~> createFunObj((appendArg(P), .Params), (print("setter\n"); P = appendArg(P); .SourceElements)) // TODO
           // TODO: Replace Int2String with toPName
           ~> defineOwnProperty(M, Int2String(L -Int length(As) -Int 1), va(HOLE, HOLE, true, true))
           ~> endCreateArgumentsObj(F, As, Ps, O, M, (P, MNs), L)
       ...
       </k>
  rule <k> (O:Oid => .) ~> createFunObj(_, _) ~> defineOwnProperty(_, _, va(HOLE => O, _, _, _)) ...</k>
  rule <k> (O:Oid => .) ~> defineOwnProperty(_, _, va(_, HOLE => O, _, _)) ...</k>
  rule <k> endCreateArgumentsObj(F, (A:Val, As:Vals), .Params, O, M, MNs, L)
        // TODO: Replace Int2String with toPName
        => defineOwnProperty(O, Int2String(L -Int length(As) -Int 1), vd(A, true, true, true)) ~> endCreateArgumentsObj(F, As, .Params, O, M, MNs, L) ...</k>
  rule <k> endCreateArgumentsObj(F, .Vals, _, O, M, MNs => .Params, _) ...</k>
       <obj>
         <oid> O </oid>
         <parameterMap> _ => M </parameterMap>
         _
       </obj>
       when MNs =/=K .Params
  rule <k> endCreateArgumentsObj(F, .Vals, _, O, _, .Params, _)
        => defineOwnProperty(O, "callee", vd(F, true, false, true)) ~> O ...</k>

  //////////////////////////////////////////////////////////////////////////////
  // 11.1 Primary Expressions
  //////////////////////////////////////////////////////////////////////////////

  // 11.1.4 Array Initialiser
  // TODO:

  // 11.1.6 The Grouping Operator
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 11.2 Left-Hand-Side Expressions
  //////////////////////////////////////////////////////////////////////////////

  // 11.2.4 Argument Lists
  // TODO:

  // 11.2.5 Function Expressions
  // TODO:

  // 11.14 CommaOperator(,)
  syntax K /* Val */ ::= comma(Vals)
  rule comma(V:Val, .Vals) => V
  rule comma(_:Val, Vs:Vals) => comma(Vs)
       when Vs =/=K .Vals

  // 13.2 Creating Function Objects
  syntax K /* Oid */ ::= createFunObj(Params,FunBody) | endCreateFunObj(Oid,Params,FunBody)
  rule <k> createFunObj(Params:Params,FunBody:FunBody)
        => newObject ~> endCreateFunObj(o(N),Params,FunBody) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> functionProtoOid </prototype>
                 <class> "Function" </class>
                 <extensible> true </extensible>
                 <scope> E </scope>
                 <formalParameters> Params </formalParameters>
                 <code> FunBody </code>
               </obj>)
         _
       </objs>
       <ctx>
         <running>
           <lexicalEnv> E:Eid </lexicalEnv>
           _
         </running>
         _
       </ctx>
       when fresh(N:Int)
  rule <k> O':Oid ~> endCreateFunObj(O:Oid,Params:Params,FunBody:FunBody)
        => defineOwnProperty(O, "length", vd(length(Params),false,false,false)) ~>
           defineOwnProperty(O, "prototype", vd(O',true,false,false)) ~>
           defineOwnProperty(O', "constructor", vd(O,true,false,true)) ~> O ... </k>

  // 11.2.3 Function Calls
  // 13.2.1 [[Call]]
  //TODO: Have to consider Bindings (see 15.3.4.5.1)
  syntax K /* Val */ ::= call(Oid,Oid,Vals)
  rule <k> call(F:Oid,This:Oid,Args:Vals)
        => enterFunBody(F,This,Args) ~> execute(Code) ~> exitFunBody ~> undefined ... </k>
       <obj>
         <oid> F </oid>
         <code> Code:FunBody </code>
				 <builtinFunction> false </builtinFunction> //not strictly necessary I hope
         _
       </obj>
  // TODO: Consider step 2 and return values
 
  
	//TODO calls for builtin 
  syntax K /* Val */ ::= callBuiltinFunction(Oid,Oid,Vals)
  rule <k> callBuiltinFunction(F:Oid,This:Oid,Args:Vals)
        => determineBuiltinFunction(FunName, This, Args) ... </k>
       <obj>
         <oid> F </oid>
         <code> FunName:String </code>
				 <builtinFunction> true </builtinFunction> //not strictly necessary
         _
       </obj>

  syntax K /* Val */ ::= callNewBuiltinFunction(Oid,Oid,Vals)
  rule <k> callNewBuiltinFunction(F:Oid,This:Oid,Args:Vals)
        => determineBuiltinFunction(FunName, This, Args) ... </k>
       <obj>
         <oid> F </oid>
				 <codeNew> FunName:String </codeNew>
				 <builtinFunction> true </builtinFunction> //not strictly necessary
         _
       </obj>

  // 13.2.3 The [[ThrowTypeError]] Function Object
  // TODO:

  //////////////////////////////////////////////////////////////////////////////
  // 15 Standard Built-in ECMAScript Objects
  //////////////////////////////////////////////////////////////////////////////

	//Differentiating between different built-in functions
	syntax K::= determineBuiltinFunction(String, Oid, Vals)
	rule determineBuiltinFunction("functionToString", This, Args) => functionToString(This)

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
                 <prototype> objectProtoOid </prototype> // Object prototype object 15.2.4
                 <class> "Object" </class>
                 <extensible> true </extensible>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

  // 15.3 Function Objects
  syntax K /* Oid */ ::= "newFunction"
  rule <k> newFunction => o(N) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 //<properties> </properties>
                 <prototype> functionProtoOid</prototype> // Object prototype object 15.2.4
                 <class> "Function" </class>
                 <extensible> true </extensible>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

  // 15.3.4.2 Function.prototype.toString()
  syntax K ::= functionToString(Val)

	rule <k> functionToString(V:Oid) => "*** Function ***" ...</k>
			<obj>
				<oid> V </oid>
				<class> "Function" </class>
				_
			</obj>
		  <out> ... (. => ListItem("got to here!")) </out>

	rule <k> functionToString(V:Oid) => throwTypeErrorOid ...</k>
			<obj>
				<oid> V </oid>
				<class> C </class>
				_
			</obj> when C =/=K "Function"

	rule functionToString(V:NonObject) => throwTypeErrorOid

  // 15.4 Array Objects
  // 15.5 String Objects
  syntax K /* Oid */ ::= newString(Val)
  rule <k> newString(V:Val) => o(N) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> stringProtoOid</prototype> // Object prototype object 15.2.4
                 <class> "String" </class>
                 <extensible> true </extensible>
								 <primitiveValue> V </primitiveValue>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

	// Constructor Methods
	// 15.5.3.2 String.fromCharCode ([char0 [, chart1 [,...]]])
	
	// Prototype Methods
	// 15.5.4.2 String.prototype.toString()
	syntax K ::= stringToString(Val)	

	rule stringToString(S:String) => S

	rule <k> stringToString(V:Oid) => S ...</k>
			<oid> V </oid> <class> "String" </class> <primitiveValue> S </primitiveValue>

	rule <k> stringToString(V:Oid) => throwTypeErrorOid ...</k>
			<oid> V </oid> <class> C </class> when C =/=K "String"

	//type error for other values
	rule stringToString(undefined) => throwTypeErrorOid 
	rule stringToString(nullVal) => throwTypeErrorOid
	rule stringToString(Bool) => throwTypeErrorOid 
	rule stringToString(Number) => throwTypeErrorOid

	// 15.5.4.3 String.prototype.valueOf()
	syntax K ::= stringValueOf(Val)	

	rule stringValueOf(S:String) => S

	rule <k> stringValueOf(V:Oid) => S ...</k>
			<oid> V </oid> <class> "String" </class> <primitiveValue> S </primitiveValue>

	rule <k> stringValueOf(V:Oid) => throwTypeErrorOid ...</k>
			<oid> V </oid> <class> C </class> when C =/=K "String"

	//type error for other values
	rule stringValueOf(undefined) => throwTypeErrorOid 
	rule stringValueOf(nullVal) => throwTypeErrorOid
	rule stringValueOf(Bool) => throwTypeErrorOid 
	rule stringValueOf(Number) => throwTypeErrorOid

	// 15.5.4.4 String.prototype.charAt(pos)
	// TODO allow more general objects (see note in 15.5.4.4)
	syntax K ::= stringCharAt(String, Val) | endStringCharAt(String)

	rule stringCharAt(S:String, V:Val) =>  checkObjectCoercible(S) ~> toInteger(V) ~> endStringCharAt(S)
	rule <k> I:Int ~> endStringCharAt(S:String) => "" ...</k> when I <Int 0 orBool I >=Int lengthString(S)
	rule <k> I:Int ~> endStringCharAt(S:String) => substrString(S, I, I +Int 1) ...</k> when I >=Int 0 andBool I <Int lengthString(S)

	// 15.5.4.5 String.prototype.charCodeAt(pos)
	// 15.5.4.6 String.prototype.concat([string1 [, string2 [,...]]])
	// 15.5.4.7 String.prototype.indexOf(searchString,position)
	// 15.5.4.8 String.prototype.lastIndexOf(searchString,position)
	// 15.5.4.9 String.prototype.localeCompare(that)
	// 15.5.4.10 String.prototype.match(regexp)
	// 15.5.4.11 String.prototype.replace(searchValue,replaceValue)
	// 15.5.4.12 String.prototype.serach(regexp)
	// 15.5.4.13 String.prototype.slice(start,end)
	// 15.5.4.14 String.prototype.split(separator,limit)
	// 15.5.4.15 String.prototype.substring(start,end)
	// 15.5.4.16 String.prototype.toLowerCase()
	// 15.5.4.17 String.prototype.toLocaleLowerCase()
	// 15.5.4.18 String.prototype.toUpperCase()
	// 15.5.4.19 String.prototype.toLocaleUpperCase()
	// 15.5.4.20 String.prototype.trim()
  // 15.6 Boolean Objects
  syntax K /* Oid */ ::= newBool(Val)
  rule <k> newBool(V:Val) => o(N) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> booleanProtoOid</prototype> // Object prototype object 15.2.4
                 <class> "Boolean" </class>
                 <extensible> true </extensible>
								 <primitiveValue> V </primitiveValue>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

	// 15.6.4.2 Boolean.prototype.toString()
		syntax K ::= booleanToString(Val)

		rule booleanToString(true) => "true"
		rule booleanToString(false) => "false"

		rule <k> booleanToString(V:Oid) => "false" ...</k>
				<oid> V </oid> <class> "Boolean" </class> <primitiveValue> true</primitiveValue>
		rule <k> booleanToString(V:Oid) => "true" ...</k>
				<oid> V </oid> <class> "Boolean" </class> <primitiveValue> false</primitiveValue>

		rule <k> booleanToString(V:Oid) => throwTypeErrorOid ...</k>
				<oid> V </oid> <class> C </class> when C =/=K "Boolean"
				

		//type error for other values
		rule booleanToString(undefined) => throwTypeErrorOid 
		rule booleanToString(nullVal) => throwTypeErrorOid
		rule booleanToString(Number) => throwTypeErrorOid
		rule booleanToString(String) => throwTypeErrorOid 

	// 15.6.4.3 Boolean.prototype.valueOf()
		syntax K ::= booleanValueOf(Val) 
		rule booleanValueOf(B:Bool) => B

		rule <k> booleanValueOf(V:Oid) => B ...</k>
				<oid> V </oid> <class> "Boolean" </class> <primitiveValue> B </primitiveValue>

		rule <k> booleanValueOf(V:Oid) => throwTypeErrorOid ...</k>
				<oid> V </oid> <class> C </class> when C =/=K "Boolean"
				

		//type error for other values
		rule booleanValueOf(undefined) => throwTypeErrorOid 
		rule booleanValueOf(nullVal) => throwTypeErrorOid
		rule booleanValueOf(Number) => throwTypeErrorOid
		rule booleanValueOf(String) => throwTypeErrorOid 
	
  // 15.7 Number Objects
  syntax K /* Oid */ ::= newNumber(Val) | "newNumber()"

	rule newNumber() => newNumber(0)
  rule <k> newNumber(V:Val) => o(N) ... </k>
       <objs>
         <oids> (. => SetItem(o(N))) ... </oids>
         (. => <obj>
                 <oid> o(N) </oid>
                 <properties> .Map </properties>
                 <prototype> numberProtoOid</prototype> // Object prototype object 15.2.4
                 <class> "Number" </class>
                 <extensible> true </extensible>
								 <primitiveValue> V </primitiveValue>
               </obj>)
         _
       </objs>
       when fresh(N:Int)

	// 15.7.4.2 Number.prototype.toString([radix])
	// TODO: needs Range Error Exception, implementation for toString for non-10 base numbers
	syntax K ::= numberToString(Val, Val) | numberToString(Val)	| endNumberToString(Val)

	rule numberToString(V) => numberToString(V, 10)
	rule numberToString(V, undefined) => numberToString(V, 10)

	rule numberToString(V1:Val, V2:Val) => toInteger(V2) ~> endNumberToString(V1)

	rule 10 ~> endNumberToString(V) => toString(V)
	rule <k> I:Int ~> endNumberToString(V) => throwTypeErrorOid ...</k> when I >Int 36 orBool I <Int 2 //TODO should be Range Error

	//Note they say that this is implementation specific TODO have a-z prepended to the front of the number
	rule <k> I:Int ~> endNumberToString(V) => toString(V) ...</k> when I <=Int 36 andBool I >=Int 2

	// 15.7.4.3 Number.prototype.toLocaleString()
	syntax K ::= numberToLocaleString(Val, Val) | numberToLocaleString(Val)
	//"permissible, but not encouraged, for it to return the same thing as toString"
	rule numberToLocaleString(V1, V2) => numberToString(V1, V2)
	rule numberToLocaleString(V) => numberToString(V)
	
	// 15.7.4.4 Number.prototype.valueOf()
	syntax K ::= numberValueOf(Val) 
	rule numberValueOf(N:Number) => N

	rule <k> numberValueOf(V:Oid) => N ...</k>
			<oid> V </oid> <class> "Number" </class> <primitiveValue> N </primitiveValue>

	rule <k> numberValueOf(V:Oid) => throwTypeErrorOid ...</k>
			<oid> V </oid> <class> C </class> when C =/=K "Number"
			

	//type error for other values
	rule numberValueOf(undefined) => throwTypeErrorOid 
	rule numberValueOf(nullVal) => throwTypeErrorOid
	rule numberValueOf(Bool) => throwTypeErrorOid
	rule numberValueOf(String) => throwTypeErrorOid 
	
	// 15.7.4.5 Number.prototype.toFixed (fractionDigits) these need to be reworked....
	// TODO needs RangeError exception, actually implement fraction representation
	syntax K ::= numberToFixed(Val, Val) | endNumberToFixed(Val)

	rule numberToFixed(V1, undefined) => 0 ~> endNumberToFixed(V1)
	rule <k> numberToFixed(V1, V2) => toInteger(V2) ~> endNumberToFixed(V1) ...</k> when V2 =/=K undefined
	
	rule <k> I:Int ~> endNumberToFixed(_) => throwTypeErrorOid ...</k> when I <Int 0 orBool I >Int 20 
	rule <k> I:Int ~> endNumberToFixed(V) => toString(V) ...</k> when I >=Int 0 andBool I <=Int 20  //temp solution
	
	// 15.7.4.6 Number.prototype.toExponential (fractionDigits)
	// TODO needs RangeError exception, actually implement fraction representation
	syntax K ::= numberToExponential(Val, Val) | endNumberToExponential(Val)

	rule numberToExponential(V1, undefined) => 0 ~> endNumberToExponential(V1)
	rule <k> numberToExponential(V1, V2) => toInteger(V2) ~> endNumberToExponential(V1) ...</k> when V2 =/=K undefined
	
	rule <k> I:Int ~> endNumberToExponential(_) => throwTypeErrorOid ...</k> when I <Int 0 orBool I >Int 20 
	rule <k> I:Int ~> endNumberToExponential(V) => toString(V) ...</k> when I >=Int 0 andBool I <=Int 20  //temp solution
	// 15.7.4.7 Number.prototype.toPrecision (precision)
	// TODO needs RangeError exception, actually implement fraction representation
	syntax K ::= numberToPrecision(Val, Val) | endNumberToPrecision(Val)

	rule numberToPrecision(V1, undefined) => 0 ~> endNumberToPrecision(V1)
	rule <k> numberToPrecision(V1, V2) => toInteger(V2) ~> endNumberToPrecision(V1) ...</k> when V2 =/=K undefined
	
	rule <k> I:Int ~> endNumberToPrecision(_) => throwTypeErrorOid ...</k> when I <Int 0 orBool I >Int 20 
	rule <k> I:Int ~> endNumberToPrecision(V) => toString(V) ...</k> when I >=Int 0 andBool I <=Int 20  //temp solution
	
  // 15.8 The Math Object
  // 15.9 Date Objects
  // 15.10 RegExp (RegularExpression) Objects
  // 15.11 ErrorObjects
  // 15.12 The JSON Object

  //////////////////////////////////////////////////////////////////////////////
  // Semantics
  //////////////////////////////////////////////////////////////////////////////

  // 7.8.1 Null Literals
  rule <k> null => nullVal ... </k>

  // 11.1.1 The this Keyword
  rule <k> this => O ... </k>
       <running>
         <thisBinding> O:Oid </thisBinding>
         _
       </running>

  // Step 8 of 10.5 Declaration Binding Instantiation
  rule <k> var N:Name;
        => hasBinding(E,N) ~> false? ~>
           createMutableBinding(E,N,true) ~> setMutableBinding(E,N,undefined) ... </k>
       <ctx>
         <running>
           <lexicalEnv> E:Eid </lexicalEnv>
           _
         </running>
         _
       </ctx>
  /*
  rule <k> var N:Name = E:Exp; => var N; ~> assignExp(N,E); ... </k>
  rule <k> var D:VarDecl, Ds:VarDeclS; => var D; ~> var Ds; ... </k>
       when Ds =/=K .VarDeclS
  */
  // TODO: other cases

  // Step 5 of 10.5 Declaration Binding Instantiation
  rule <k> function N:Name (Params:Params) { FunBody:FunBody }
        => createFunObj(Params,FunBody) ~>
           hasBinding(E,N) ~> false? ~>
           createMutableBinding(E,N,true) ~> setMutableBinding(E,N,HOLE) ... </k>
       <ctx>
         <running>
           <lexicalEnv> E:Eid </lexicalEnv>
           _
         </running>
         _
       </ctx>
  rule <k> (O:Oid => .) ~>
           hasBinding(_,_) ~> false? ~> createMutableBinding(_,_,_) ~>
           setMutableBinding(_,_,HOLE => O) ... </k>
  // TODO: Consider step e

  // 11.1.2 Identifier Reference
  // 10.3.1 Identifier Resolution
  rule <k> lv(N:Name) => getIdentifierReference(E,N) ... </k>
       <running>
         <lexicalEnv> E:Eid </lexicalEnv>
         _
       </running>
  rule <k> N:Name => lv(N) ~> getValue(HOLE) ... </k>

  // 11.2.1 Property Accessors
  rule <k> _:Val[(_:Val => .), Vs:Vals] ... </k>
       when Vs =/=K .Vals
  context lv(lookupLExp(_:Oid,HOLE))
  context lv(lookupLExp(HOLE,_:Exps))
  rule <k> lv(O:Oid[N:Val])
        => checkObjectCoercible(O) ~> toString(N) ~> l(O,HOLE) ... </k>
  rule <k> P:PName ~> l(O:Oid,HOLE) => l(O,P) ... </k>
  rule <k> O:Oid[N:Val] => lv(O[N]) ~> getValue(HOLE) ... </k>

  // 11.13.1 Simple Assignment ( = )
  rule <k> assignExp(L:LExp,V:Val) => lv(L) ~> assignExp(HOLE,V) ... </k>
  rule <k> l(X,Y) ~> assignExp(HOLE,V:Val) => putValue(l(X,Y),V) ~> V ... </k>
  // TODO: other cases

  // 11.13.2 Compound Assignment ( op= )
  // TODO:

  // 11.1.5 Object Initialiser
  rule <k> { PAs:PropertyAssignments } => newObject ~> assignProps(HOLE,PAs) ... </k>
  rule <k> O:Oid ~> assignProps(HOLE,PAs:PropertyAssignments) => assignProps(O,PAs) ... </k>
  //
  syntax K /* Oid */ ::= assignProps(Oid,PropertyAssignments)
  rule <k> assignProps(O:Oid, .PropertyAssignments) => O ... </k>
  rule <k> assignProps(O:Oid, (PA:PropertyAssignment, PAs:PropertyAssignments))
        => assignProp(PA) ~> assignProps(O,PAs) ... </k>
  //
  syntax K /* .K */ ::= assignProp(PropertyAssignment)
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

  // 11.2.3 Function Calls
  rule <k> F:Oid (Vs:Vals) => call(F,globalOid,Vs) ... </k>
				<obj> <oid> F </oid> <builtinFunction> false </builtinFunction> _ </obj>
  // TODO: This is WRONG!! "this" object should be determined properly!!!

  rule <k> F:Oid (Vs:Vals) => callBuiltinFunction(F,globalOid,Vs) ... </k>
				<obj> <oid> F </oid> <builtinFunction> true </builtinFunction> _ </obj>

  // 11.2.2 The new Operator
  // 13.2.2 [[Construct]]
  rule <k> new F:Oid (Vs:Vals) => call(F,o(N),Vs) ... </k>
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
           <properties> ... "prototype" |-> vd(Prototype:Oid,true,false,false) ... </properties>
					 <builtinFunction> false </builtinFunction>
           _
         </obj>
         _
       </objs>
       when fresh(N:Int)
			// TODO: other cases, step 7
			
  rule <k> new F:Oid (Vs:Vals) => callNewBuiltinFunction(F,globalOid,Vs) ... </k>
				<obj> <oid> F </oid> <builtinFunction> true </builtinFunction> _ </obj>

	// 13.2.3 TODO: Throw Code (thorws a TypeError exception)

  // 12.4 Expression Statement
  // TODO: This is a naive implementation
  rule <k> _:Val, Vs:Vals; => Vs; ... </k>
       when Vs =/=K .Vals
  rule <k> _:Val; => . ... </k>

  // 12.9 The return Statement
  rule return; => return undefined; [macro]

  // 14 Program
  // TODO: Consider continue, break, etc. See 8.9 The Completion Specification Type
  rule <k> S:SourceElement Ss:SourceElements => S ~> Ss ... </k>
  rule <k> .SourceElements => . ... </k>

  //////////////////////////////////////////////////////////////////////////////
  // Utils
  //////////////////////////////////////////////////////////////////////////////

  syntax K /* .K */ ::= "true?" | "false?"
  rule <k> true  ~> true?  => . ... </k>
  rule <k> false ~> false? => . ... </k>

  syntax K /* .K */ ::= "ignore"
  rule <k> _ ~> ignore => . ... </k>

  syntax K /* Ref */ ::= lv(LExp)
  rule <k> l(X,Y) ~> getValue(HOLE) => getValue(l(X,Y)) ... </k>

  syntax K /* Int */ ::= length(Params) [function]
                       | length(Vals) [function]
  rule length(_:Name, Ps:Params) => 1 +Int length(Ps)
  rule length(.Params) => 0
  rule length(_:Val, Vs:Vals) => 1 +Int length(Vs)
  rule length(.Vals) => 0

  syntax K /* Bool */ ::= isUndefOrDataDesc(Val) [function]
  rule isUndefOrDataDesc(undefined) => true
  rule isUndefOrDataDesc(vd(_,_,_,_)) => true

  rule <k> print(V:Val); => . ...</k>
       <out> ... (. => ListItem(V)) </out>

  rule - I:Int => 0 -Int I
  rule ! T:Bool => notBool(T)
  rule I1:Int * I2:Int => I1 *Int I2
  rule I1:Int / I2:Int => I1 /Int I2 when I2 =/=K 0
  rule I1:Int % I2:Int => I1 %Int I2 when I2 =/=K 0
  rule I1:Int + I2:Int => I1 +Int I2
  rule S1:String + S2:String => S1 +String S2
  rule I1:Int - I2:Int => I1 -Int I2
  rule I1:Int < I2:Int => I1 <Int I2
  rule I1:Int > I2:Int => I1 >Int I2
  rule I1:Int <= I2:Int => I1 <=Int I2
  rule I1:Int >= I2:Int => I1 >=Int I2
  rule V1:Val == V2:Val => V1 ==K V2
  rule V1:Val != V2:Val => V1 =/=K V2
  rule true  && E:Exp => E
  rule false && _ => false
  rule true  || _ => true
  rule false || E:Exp => E
  // TODO: other cases

  syntax Name ::= appendArg(Name) [function]
  rule appendArg(N:Name) => NameOfString(StringOfName(N) +String "_arg")

  syntax K /* K */ ::= execute(FunBody) [function]
  rule <k> execute(F:FunExp SEs:SourceElements) => execute(SEs) ...</k>
  rule <k> execute(DS:DeclStmt SEs:SourceElements) => execute(SEs) ...</k>
  rule <k> execute(CS:CaseStmt SEs:SourceElements) => CS SEs ...</k>
  rule <k> execute(OS:OtherStmt SEs:SourceElements) => OS SEs ...</k>
  rule <k> execute(.SourceElements) => . ...</k>

endmodule
