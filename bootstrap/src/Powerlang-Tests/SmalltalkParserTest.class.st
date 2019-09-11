Class {
	#name : #SmalltalkParserTest,
	#superclass : #TestCase,
	#instVars : [
		'parser'
	],
	#category : #'Powerlang-Tests-SCompiler'
}

{ #category : #setup }
SmalltalkParserTest >> setUp [
	super setUp.
	parser := SmalltalkParser new
]

{ #category : #other }
SmalltalkParserTest >> testAllNodesDo [
	| source nodes |
	source := 'rcvr msg1; msg2'.
	parser on: source.
	parser step.
	nodes := OrderedCollection new.
	parser expression allNodesDo: [:n | nodes add: n].
	self assert: nodes size = 4
]

{ #category : #assignments }
SmalltalkParserTest >> testAssignment [
	| assignment |
	parser on: 'a := nil + 4'.
	parser step.
	assignment := parser expression.
	self
		assert: assignment isAssign;
		assert: assignment assignees size = 1;
		assert: assignment assignees anyOne source = 'a';
		assert: assignment expression source = 'nil + 4'
]

{ #category : #assignments }
SmalltalkParserTest >> testAssignment2 [
	| assignment |
	parser on: 'a := b := nil + 4'.
	parser step.
	assignment := parser expression.
	self
		assert: assignment isAssign;
		assert: assignment assignees size = 2;
		assert: assignment assignees first name = 'b';
		assert: assignment assignees second name = 'a'
]

{ #category : #assignments }
SmalltalkParserTest >> testAssignment3 [
	| node |
	node := parser parseExpression: 'a : = 1'.
	self
		assert: node statements anyOne isAssign.
	node := parser parseExpression: 'a :	= 1'.
	self
		assert: node statements anyOne isAssign
]

{ #category : #messages }
SmalltalkParserTest >> testBinaryColon [
	| statements binary |
	parser on: '3:4'.
	parser step.
	statements := parser statements.
	self assert: statements size = 1.
	binary := statements anyOne.
	self
		assert: binary receiver source = '3';
		assert: binary symbol = #':';
		assert: binary arguments anyOne source = '4'
]

{ #category : #messages }
SmalltalkParserTest >> testBinaryColon2 [
	| m |
	m := parser parse: ': b ^self / b'.
	self assert: m selector = #':'.
	self assert: m arguments anyOne source = 'b'
]

{ #category : #'method headers' }
SmalltalkParserTest >> testBinaryHeader [
	| method selector |
	parser on: '+++ x'.
	parser step.
	method := parser binarySignature.
	self
		assert: method notNil;
		assert: method class == MethodNode;
		assert: method selector keywords size = 1;
		assert: method selector value == #'+++';
		assert: method arguments size = 1.
	parser on: 'a'.
	parser step.
	selector := parser binarySignature.
	self assert: selector isNil.
	parser on: 'a: x'.
	parser step.
	selector := parser binarySignature.
	self assert: selector isNil
]

{ #category : #messages }
SmalltalkParserTest >> testBinaryPower [
	| statements binary |
	parser on: '2^3'.
	parser step.
	statements := parser statements.
	self assert: statements size = 1.
	binary := statements anyOne.
	self
		assert: binary receiver source = '2';
		assert: binary symbol = #'^';
		assert: binary arguments anyOne source = '3'
]

{ #category : #messages }
SmalltalkParserTest >> testBinaryPower2 [
	| m |
	m := parser parse: '^ n ^self raisedTo: n'.
	self assert: m selector = #'^'.
	self assert: m arguments anyOne source = 'n'
]

{ #category : #blocks }
SmalltalkParserTest >> testBlock [
	| block |
	parser on: '[]'.
	parser compiler activeScript: parser compiler methodNode.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[]'.
	parser on: '[x]'.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[x]';
		assert: block temporaries isEmpty;
		assert: block arguments isEmpty;
		assert: block statements size = 1;
		assert: block statements anyOne isIdentifier
]

{ #category : #blocks }
SmalltalkParserTest >> testBlock2 [
	| block |
	parser on: '[:i | i]'.
	parser compiler activeScript: parser compiler methodNode.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[:i | i]';
		assert: block arguments size = 1.
	parser on: '[:i :j |]'.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[:i :j |]';
		assert: block temporaries isEmpty;
		assert: block arguments size = 2;
		assert: block statements isEmpty;
		assert: block arguments first isIdentifier;
		assert: block arguments second isIdentifier
]

{ #category : #blocks }
SmalltalkParserTest >> testBlock3 [
	| block |
	parser on: '[:i | | a b | a + b]'.
	parser compiler activeScript: parser compiler methodNode.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[:i | | a b | a + b]';
		assert: block arguments size = 1;
		assert: block temporaries size = 2.
	parser on: '[:i ||a b|a|b]'.
	parser step.
	block := parser primary.
	self
		assert: block isBlockNode;
		assert: block source = '[:i ||a b|a|b]';
		assert: block temporaries size = 2;
		assert: block arguments size = 1;
		assert: block statements size = 1;
		assert: block statements anyOne selector value = #'|'
]

{ #category : #braces }
SmalltalkParserTest >> testBraceNode [
	| ast brace sum |
	ast := parser parseExpression: '{1. 3 + 4}'.
	brace := ast statements anyOne.
	sum := parser parseExpression: '3 + 4'.
	self
		assert: brace elements size = 2;
		assert: brace elements first value = 1;
		assert: brace elements second class = sum statements anyOne class;
		assert: brace elements second arguments anyOne value = 4
]

{ #category : #literals }
SmalltalkParserTest >> testByteArray [
	| node |
	node := parser parseExpression: '#[16rFE]'.
	self assert: node statements anyOne source = '#[16rFE]'.
	node := parser parse: 'b #[16rFE]'.
	self assert: node statements anyOne source = '#[16rFE]'
]

{ #category : #literals }
SmalltalkParserTest >> testByteArray2 [
	| array |
	parser on: '#[16rFE]'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = #[16rFE];
		assert: array source = '#[16rFE]'
]

{ #category : #literals }
SmalltalkParserTest >> testByteArray3 [
	| array |
	parser on: '#[16rFE 2]'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = #[16rFE 2];
		assert: array source = '#[16rFE 2]'.
	parser on: '#[16rFE 256 2]'.
	parser step.
	self should: [array := parser primary] raise: Exception
]

{ #category : #messages }
SmalltalkParserTest >> testCascade [
	| cascade statements |
	parser on: 'r m1; m2'.
	parser step.
	statements := parser statements.
	self assert: statements size = 1.
	cascade := statements anyOne.
	self
		assert: cascade receiver source = 'r';
		assert: cascade messages size = 2;
		assert: cascade messages first source = 'r m1';
		assert: cascade messages first selector source = 'm1';
		assert: cascade messages second selector source = 'm2'
]

{ #category : #messages }
SmalltalkParserTest >> testCascade2 [
	| cascade statements |
	parser on: 'r m: 1; + 2'.
	parser step.
	statements := parser statements.
	self assert: statements size = 1.
	cascade := statements anyOne.
	self
		assert: cascade receiver source = 'r';
		assert: cascade messages size = 2;
		assert: cascade messages first selector keywords size = 1;
		assert: cascade messages first arguments anyOne value = 1;
		assert: cascade messages second selector isBinary;
		assert: cascade messages second arguments anyOne value = 2
]

{ #category : #comments }
SmalltalkParserTest >> testComment1 [
	| node |
	node := parser parse: 'unary
	"comment"
	^true'.
	self assert: node selectorNode comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment10 [
	| node |
	node := parser parse: 'unary
	1 "comment1".
	[2. "comment3" 3]'.
	self
		assert: node statements first comment value = 'comment1';
		assert: node statements second statements second comment value = 'comment3'
]

{ #category : #comments }
SmalltalkParserTest >> testComment11 [
	| node |
	node := parser parse: 'unary
	1. "comment"'.
	self assert: node comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment12 [
	| node |
	node := parser parse: 'unary
	[1. "comment"]'.
	self assert: node statements anyOne comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment2 [
	| node |
	node := parser parse: '+ binary
	"comment"
	^true'.
	self assert: node selectorNode comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment3 [
	| node |
	node := parser parse: 'keyword: arg
	"comment"
	^true'.
	self assert: node selectorNode comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment4 [
	| node |
	node := parser parse: 'unary
	^true "comment"'.
	self
		assert: node statements anyOne expression comment value = 'comment';
		deny: node comment value = 'comment';
		assert: node comment isNil
]

{ #category : #comments }
SmalltalkParserTest >> testComment5 [
	| node |
	node := parser parse: '+ binary
	^true "comment"'.
	self assert: node statements anyOne expression comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment6 [
	| node |
	node := parser parse: 'keyword: arg
	^true "comment"'.
	self assert: node statements anyOne expression comment value = 'comment'
]

{ #category : #comments }
SmalltalkParserTest >> testComment7 [
	| node |
	node := parser parse: 'unary
	1 "comment1".
	2 "comment2"'.
	self
		assert: node statements first comment value = 'comment1';
		assert: node statements second comment value = 'comment2'
]

{ #category : #comments }
SmalltalkParserTest >> testComment8 [
	| node |
	node := parser parse: 'unary
	1 "comment1".
	^2 "comment2"'.
	self
		assert: node statements first comment value = 'comment1';
		assert: node statements second expression comment value = 'comment2'
]

{ #category : #comments }
SmalltalkParserTest >> testComment9 [
	| node |
	node := parser parse: 'unary
	1. "comment2" 2'.
	self assert: node statements second comment value = 'comment2'
]

{ #category : #literals }
SmalltalkParserTest >> testDashStartingSymbol1 [
	| array |
	parser on: '#(#++)'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = (Array with: #'++').
	parser on: '#(#-- )'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = (Array with: #'--')
]

{ #category : #literals }
SmalltalkParserTest >> testDashStartingSymbol2 [
	| symbol |
	parser on: '#++'.
	parser step.
	symbol := parser primary.
	self
		assert: symbol isLiteral;
		assert: symbol value = #'++'.
	parser on: '#--'.
	parser step.
	symbol := parser primary.
	self
		assert: symbol isLiteral;
		assert: symbol value = #'--'
]

{ #category : #'embedded dot' }
SmalltalkParserTest >> testEmbeddedDots [
	| node |
	node := parser parse: 'm
	A.B.C name.
	self m: A.B.C.
	^true'.
	self
		assert: node statements first receiver name = 'A.B.C';
		assert: node statements second arguments anyOne name = 'A.B.C'
]

{ #category : #'embedded dot' }
SmalltalkParserTest >> testEmbeddedDots2 [
	self
		should: [parser parse: '
	m
		#(1 2 3) do: [:funny.arg | funny.arg + 1]']
		raise: CompilationError.
	self
		should: [parser
			parse: '
	m
		| funny.local |
		funny.local := 1.
		^funny.local']
		raise: CompilationError.
	self
		should: [parser
			parse: '
	m
		#(1 2 3) do: [:e |  | funny.local | funny.local := e]']
		raise: CompilationError
]

{ #category : #literals }
SmalltalkParserTest >> testExpression [
	| expression |
	parser on: '(x)'; step.
	expression := parser primary.
	self
		assert: expression isIdentifier;
		assert: expression source = 'x'.
	parser on: '(x + 1)'; step.
	expression := parser primary.
	self
		assert: expression class == MessageNode;
		assert: expression selector isBinary;
		assert: expression source = '(x + 1)'
]

{ #category : #literals }
SmalltalkParserTest >> testFloat [
	| source node |
	source := '3.14159265358979323846'.
	node := parser parseExpression: source.
	self assert: node statements anyOne source = source.
	node := parser parse: 'm ' , source.
	self assert: node statements anyOne source = source
]

{ #category : #'method headers' }
SmalltalkParserTest >> testKeywordHeader [
	| method selector |
	parser on: 'x: x y: y z: z'.
	parser step.
	method := parser keywordSignature.
	self
		assert: method notNil;
		assert: method class == MethodNode;
		assert: method selector keywords size = 3;
		assert: method selector value == #x:y:z:;
		assert: method arguments size = 3.
	parser on: 'a'.
	parser step.
	selector := parser keywordSignature.
	self assert: selector isNil.
	parser on: '+ x'.
	parser step.
	selector := parser keywordSignature.
	self assert: selector isNil
]

{ #category : #'method headers' }
SmalltalkParserTest >> testKeywordHeader2 [
	| method |
	parser on: 'x: xx y: yy z: zz'.
	parser step.
	method := parser methodSignature.
	self
		assert: method class == MethodNode;
		assert: method header = 'x: xx y: yy z: zz'.
	parser on: 'x'.
	parser step.
	method := parser methodSignature.
	self assert: method header = 'x'.
	parser on: '+= arg value := value + arg'.
	parser step.
	method := parser methodSignature.
	self assert: method header = '+= arg'
]

{ #category : #literals }
SmalltalkParserTest >> testLiteralArray [
	| array |
	parser on: '#(16rFE)'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = #(16rFE);
		assert: array source = '#(16rFE)'.
	parser on: '#(16rFE $a ''hello'' #s #(1 2))'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = #(16rFE $a 'hello' #s #(1 2));
		assert: array source = '#(16rFE $a ''hello'' #s #(1 2))'
]

{ #category : #literals }
SmalltalkParserTest >> testLiteralArray2 [
	| array |
	parser on: '#(a:b:)'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = #(#a:b:);
		assert: array source = '#(a:b:)'
]

{ #category : #literals }
SmalltalkParserTest >> testLiteralKeywordArray [
	| ast literal |
	ast := parser parseExpression: '#(a:b: c: d:)'.
	literal := ast statements anyOne value.
	self
		assert: literal isArray;
		assert: literal size = 3;
		assert: literal first == #a:b:;
		assert: literal second == #c:;
		assert: literal third == #d:
]

{ #category : #messages }
SmalltalkParserTest >> testMissingPrimary [
	| source |
	source := 'pendingReservesAtTime: time well: index
	i0 := startings at: index.
	ti := self timeAt: i0.
	dt := time - ti.
	c := single primaryCurve.
	^c reserves - (cumAtTime: dt)'.
	self should: [parser parse: source] raise: Error
]

{ #category : #literals }
SmalltalkParserTest >> testNegativeElementInArray [
	| array |
	parser on: '#(-21)'.
	parser step.
	array := parser primary.
	self assert: array isLiteral.
	parser on: '#(-21 1 -5 4)'.
	parser step.
	array := parser primary.
	self
		assert: array isLiteral;
		assert: array value = (Array
			with: -21
			with: 1
			with: -5
			with: 4)
]

{ #category : #literals }
SmalltalkParserTest >> testNegativeNumber [
	| number |
	parser on: '-3'.
	parser step.
	number := parser primary.
	self
		assert: number isLiteral;
		assert: number value = -3;
		assert: number source = '-3'.
	parser on: '-3.14'.
	parser step.
	number := parser primary.
	self
		assert: number isLiteral;
		assert: number value = -3.14;
		assert: number source = '-3.14'.
	parser on: '-3.14e-10'.
	parser step.
	number := parser primary.
	self
		assert: number isLiteral;
		assert: number value = -0.000000000314;
		assert: number source = '-3.14e-10'
]

{ #category : #literals }
SmalltalkParserTest >> testNotAFloat [
	| method |
	method := parser parseExpression: '0.a'.
	self
		assert: method statements size = 2;
		assert: method statements first value = 0
]

{ #category : #blocks }
SmalltalkParserTest >> testParseFragment [
	| source ast |
	source := 'm
	self do: [:x | Object'.
	ast := parser compiler parseFragment: source.
	self
		assert: ast selector == #m;
		assert: ast statements isEmpty
]

{ #category : #temporaries }
SmalltalkParserTest >> testParseTemporaries [
	| temporaries |
	temporaries := SmalltalkParser new
		parseTemporaries: 'm: arg
	| t1 t2 t3 |
	^:= will not even parse'.
	self assert: (temporaries collect: #name) asArray = #('t1' 't2' 't3')
]

{ #category : #'embedded dot' }
SmalltalkParserTest >> testPeekForIdentifier [
	| strm |
	strm := 'abc.de' readStream.
	self
		assert: (Compiler new peekForIdentifier: strm);
		assert: strm position = 1.
	strm position: 3.
	self assert: (Compiler new peekForIdentifier: strm).
	strm := 'a2.c' readStream.
	strm position: 2.
	self deny: (Compiler new peekForIdentifier: strm)
]

{ #category : #messages }
SmalltalkParserTest >> testPrimitive1 [
	| source ast |
	source := 'perform: selector
						<primitive: Perform>'.
	ast := parser parse: source.
	self
		assert: ast pragma notNil;
		assert: ast pragma isPrimitive;
		assert: ast pragma name = 'Perform'

]

{ #category : #literals }
SmalltalkParserTest >> testScientificNotation [
	| method |
	method := parser parseExpression: '
	0.1e-2.
	0.1E2'.
	self
		assert: method statements size = 2;
		assert: method statements first value = 0.001;
		assert: method statements second value = 10
]

{ #category : #messages }
SmalltalkParserTest >> testSelector [
	| source ast |
	source := 'k1: arg1 k2: arg2'.
	ast := parser parse: source.
	self
		assert: ast selectorNode positions first
			= (source indexOfSubCollection: 'k1:');
		assert: ast selectorNode positions second
			= (source indexOfSubCollection: 'k2:');
		assert: ast selector == #k1:k2:
]

{ #category : #temporaries }
SmalltalkParserTest >> testTemporaries [
	| temporaries |
	parser on: '||'.
	parser step.
	self assert: parser temporaries isEmpty.
	parser on: '| |'.
	parser step.
	self assert: parser temporaries isEmpty.
	parser on: '| a b c |'.
	parser step.
	temporaries := parser temporaries.
	self
		assert: temporaries size = 3;
		assert: temporaries first isIdentifier;
		assert: temporaries first name = 'a';
		assert: temporaries second isIdentifier;
		assert: temporaries second name = 'b';
		assert: temporaries third isIdentifier;
		assert: temporaries third name = 'c'
]

{ #category : #temporaries }
SmalltalkParserTest >> testTemporaryDeclarations [
	| temporaries |
	parser on: '| | | a b |'.
	parser step.
	temporaries := parser temporaries.
	self assert: temporaries size = 0.
	parser on: '|| | a b |'.
	parser step.
	temporaries := parser temporaries.
	self assert: temporaries size = 0.
	parser on: 'a || b'.
	parser step.
	self assert: parser token value = 'a'.
	parser step.
	self assert: parser token value = #'||'.
	parser step.
	self assert: parser token value = 'b'
]

{ #category : #'method headers' }
SmalltalkParserTest >> testUnaryHeader [
	| selector |
	parser on: 'a'.
	parser step.
	self assert: parser token isNameToken.
	selector := parser unarySelector.
	self
		assert: selector notNil;
		assert: selector class == SelectorNode;
		assert: selector keywords size = 1;
		assert: selector value == #a.
	parser on: 'a: x'.
	parser step.
	self deny: parser token isNameToken.
	parser on: '+ x'.
	parser step.
	self deny: parser token isNameToken
]

{ #category : #messages }
SmalltalkParserTest >> testUnarySelector [
	| source ast |
	source := 'm a notNil'.
	ast := parser parse: source.
	self
		assert: (ast nodeWithLiteral: #notNil) positions first
			= (source indexOfSubCollection: 'notNil')
]

{ #category : #assignments }
SmalltalkParserTest >> testUnderscoreAssignment [
	| assignment |
	parser on: 'a _ 3 + 4'.
	parser step.
	assignment := parser expression.
	self assert: assignment isAssign
]

{ #category : #unicode }
SmalltalkParserTest >> testUnicode [
	| source ast |
	source := 8855 asCharacter asString , ' aFreeTensor'.
	ast := parser parse: source.
	self
		assert: ast selectorNode position
			= (source indexOfSubCollection: 8855 asCharacter asString);
		assert: ast selector == 8855 asCharacter asString asSymbol
]
