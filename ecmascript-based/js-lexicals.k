//JavaScript lexical conventions module

module JS-LEXICALS

//LEXICAL CONVENTIONS - Ecma262-7

//Identifier Names and Identifiers - Ecma262-7.6
  syntax Identifier ::= IdentifierName /* but not ReservedWord */

//TODO: not complete
  syntax IdentifierName ::= Id
//----------------------------------------

//Reserved words - Ecma262-7.6.1
  syntax ReservedWord ::= Keyword
		       |  FutureReservedWord
		       |  NullLiteral
		       |  BooleanLiteral

  syntax Keyword ::= "break" | "do" | "instanceof" | "typeof" | "case" | "else" | "new" | "var" | "catch"
		  |  "finally" | "return" | "void" | "continue" | "for" | "switch" | "while" | "debugger"
		  |  "function" | "this" | "with" | "default" | "if" | "throw" | "delete" | "in" | "try"

  syntax FutureReservedWord ::= "class" | "enum" | "extends" | "super" | "const" | "export" | "import"
//if strict mode	     |  "implements" | "let" | "private" | "public" | "yield" | "interface" | "package" | "protected" | "static"
//----------------------------------------

//Punctuators - Ecma262-7.7
  syntax Punctuator ::= "{" | "}" | "(" | ")" | "[" | "]" | "." | ";" | "," | "<" | ">" | "<=" | ">=" | "==" | "!=" | "===" | "!=="
		     |  "+" | "-" | "*" | "%" | "++" | "--" | "<<" | ">>" | ">>>" | "&" | "|" | "^" | "!" | "~" | "&&" | "||" | "?"
		     |  ":" | "=" | "+=" | "-=" | "*=" | "%=" | "<<=" | ">>=" | ">>>=" | "&=" | "|=" | "^="

  syntax DivPunctuator ::= "/" | "/="
//----------------------------------------

//Literals - Ecma262-7.8
  syntax Literal ::= NullLiteral | BooleanLiteral 
		  | NumericLiteral | StringLiteral 
		/*| RegularExpressionLiteral*/

//Null Literals - Ecma262-7.8.1
  syntax NullLiteral ::= "null"

//Boolean Literals - Ecma262-7.8.2
  syntax BooleanLiteral ::= Bool
		/*	"true"
			 |  "false"  //??	*/

//Numeric Literals - Ecma262-7.8.3
  syntax NumericLiteral ::= Int | Float
/*  syntax NumericLiteral ::= DecimalLiteral | HexIntegerLiteral

  syntax DecimalLiteral ::= DecimalIntegerLiteral "." DecimalDigit ExponentPart
			 |  DecimalIntegerLiteral "." ExponentPart
			 |  DecimalIntegerLiteral "." DecimalDigit
			 |  DecimalIntegerLiteral "." //??
			 |  "." DecimalDigits ExponentPart
			 |  "." DecimalDigits
			 |  DecimalIntegerLiteral ExponentPart


DecimalIntegerLiteral ::
0 NonZeroDigit DecimalDigitsopt
DecimalDigits ::
DecimalDigit DecimalDigits DecimalDigit
DecimalDigit :: one of
0 1 2 3 4 5 6 7 8 9
NonZeroDigit :: one of
1 2 3 4 5 6 7 8 9
ExponentPart ::
ExponentIndicator SignedInteger
ExponentIndicator :: one of
e E
SignedInteger ::
DecimalDigits + DecimalDigits - DecimalDigits
HexIntegerLiteral ::
0x HexDigit 0X HexDigit HexIntegerLiteral HexDigit

HexDigit :: one of
0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F

*/
//----------------------------------------

//String Literals - Ecma262-7.8.4
  syntax StringLiteral ::= String
//----------------------------------------
endmodule
