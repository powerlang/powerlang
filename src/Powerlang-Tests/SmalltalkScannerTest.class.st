Class {
	#name : #SmalltalkScannerTest,
	#superclass : #TestCase,
	#instVars : [
		'scanner'
	],
	#category : #'Powerlang-Tests-SCompiler'
}

{ #category : #setup }
SmalltalkScannerTest >> setUp [
	super setUp.
	scanner := SCompiler new smalltalkScanner
]

{ #category : #numbers }
SmalltalkScannerTest >> test0xNotation [
	| node |
	node := SCompiler new smalltalkParser parseExpression: '0x10'.
	self assert: node statements first value = 16.
	node := SCompiler new smalltalkParser parseExpression: '0X10'.
	self assert: node statements first value = 16
]

{ #category : #arrays }
SmalltalkScannerTest >> testArrayStart [
	| node |
	scanner on: '#()'.
	node := scanner next.
	self
		assert: (node is: #'#(');
		assert: node source = '#('.
	scanner on: '#['.
	node := scanner next.
	self
		assert: (node is: #'#[');
		assert: node source = '#['.
	scanner on: '#''hello'''.
	node := scanner next.
	self
		assert: node value = #hello;
		assert: node source = '#''hello'''
]

{ #category : #strings }
SmalltalkScannerTest >> testBinary [
	| node |
	scanner on: '-
		--
		---
		==>
		~!|\/%&*+=><'.
	node := scanner next.
	self
		assert: node isBinary;
		assert: node value = #'-';
		assert: node source = '-'.
	node := scanner next.
	self
		assert: node isBinary;
		assert: node value = #'--';
		assert: node source = '--'.
	node := scanner next.
	self
		assert: node isBinary;
		assert: node value = #'---';
		assert: node source = '---'.
	node := scanner next.
	self
		assert: node isBinary;
		assert: node value = #'==>';
		assert: node source = '==>'.
	node := scanner next.
	self
		assert: node isBinary;
		assert: node value = #'~!|\/%&*+=><';
		assert: node source = '~!|\/%&*+=><'
]

{ #category : #symbols }
SmalltalkScannerTest >> testBinarySymbol [
	| node |
	scanner on: '#='.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node hasSymbol;
		assert: node value = #'='
]

{ #category : #strings }
SmalltalkScannerTest >> testCharacter [
	| node |
	scanner on: '$a$b'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = $a;
		assert: node source = '$a'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = $b;
		assert: node source = '$b'
]

{ #category : #colons }
SmalltalkScannerTest >> testColon [
	| node |
	scanner on: ':a'.
	node := scanner next.
	self
		assert: (node is: $:);
		assert: node source = ':'.
	node := scanner next.
	self
		assert: node value = 'a';
		assert: node source = 'a'.
	scanner on: ':='.
	node := scanner next.
	self
		assert: node isAssignment;
		assert: node source = ':='
]

{ #category : #colons }
SmalltalkScannerTest >> testColon2 [
	| node |
	scanner on: '::'.
	node := scanner next.
	self
		assert: node class = SStringToken;
		assert: node source = '::'
]

{ #category : #comments }
SmalltalkScannerTest >> testComment [
	| node |
	scanner on: '"comment"a'.
	node := scanner next.
	self
		assert: node isComment;
		assert: node value = 'comment';
		assert: node source = '"comment"'.
	scanner on: '"comment"'.
	node := scanner next.
	self
		assert: node isComment;
		assert: node source = '"comment"';
		assert: node position = 1.
	scanner on: 'a"comment"'.
	node := scanner next.
	self
		assert: node isNameToken;
		assert: node value = 'a';
		assert: node source = 'a'.
	node := scanner next.
	self
		assert: node isComment;
		assert: node position = ('a' size + 1)
]

{ #category : #symbols }
SmalltalkScannerTest >> testDashStartingSymbol [
	| node |
	scanner on: '#++'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'++';
		assert: node source = '#++'.
	scanner on: '#//'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'//';
		assert: node source = '#//'.
	scanner on: '#--'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'--';
		assert: node source = '#--'.
	scanner on: '#+-'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'+-';
		assert: node source = '#+-'
]

{ #category : #strings }
SmalltalkScannerTest >> testEmpty [
	scanner on: ''.
	self assert: scanner next isEnd
]

{ #category : #numbers }
SmalltalkScannerTest >> testFloat [
	| node |
	scanner on: '0.1'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 0.1;
		assert: node source = '0.1'.
	scanner on: '0.1e-35'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 0.1e-35;
		assert: node source = '0.1e-35'
]

{ #category : #identifiers }
SmalltalkScannerTest >> testIdentifier [
	| node |
	scanner on: 'a'.
	node := scanner next.
	self
		assert: node isNameToken;
		assert: node value = 'a';
		assert: node source = 'a'.
	scanner on: ' a1'.
	node := scanner next.
	self
		assert: node isNameToken;
		assert: node value = 'a1';
		assert: node source = 'a1'.
	scanner on: '_a'.
	node := scanner next.
	self
		assert: node isNameToken;
		assert: node value = '_a';
		assert: node source = '_a'.
	scanner on: 'a_1b'.
	node := scanner next.
	self
		assert: node isNameToken;
		assert: node value = 'a_1b';
		assert: node source = 'a_1b'
]

{ #category : #numbers }
SmalltalkScannerTest >> testInteger [
	| node |
	scanner on: '0 12 -35'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 0;
		assert: node source = '0'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 12;
		assert: node source = '12'.
	node := scanner next.
	self
		deny: node isNumberNode;
		assert: (node is: #'-');
		assert: node source = '-'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 35;
		assert: node source = '35'
]

{ #category : #numbers }
SmalltalkScannerTest >> testIntegerRadix [
	| node |
	scanner on: '16rFA2'.
	node := scanner next.
	self
		assert: node isNumberNode;
		assert: node value = 16rFA2;
		assert: node source = '16rFA2'
]

{ #category : #identifiers }
SmalltalkScannerTest >> testKeyword [
	| node node2 |
	scanner on: 'a:'.
	node := scanner next.
	self
		assert: node isKeyword;
		assert: node value = 'a:';
		assert: node source = 'a:'.
	scanner on: 'ab:cd:'.
	node := scanner next.
	node2 := scanner next.
	self
		assert: node isKeyword;
		assert: node value = 'ab:';
		assert: node source = 'ab:';
		assert: node2 isKeyword;
		assert: node2 value = 'cd:';
		assert: node2 source = 'cd:'
]

{ #category : #symbols }
SmalltalkScannerTest >> testNumericSymbol [
	scanner on: '#35'.
	self assert: scanner next value = '35' asSymbol
]

{ #category : #strings }
SmalltalkScannerTest >> testString [
	| node quote |
	scanner on: '' storeString.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = '';
		assert: node source = (String with: $' with: $').
	scanner on: 'Hello World!' storeString.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = 'Hello World!';
		assert: node source = 'Hello World!' storeString.
	quote := String with: $'.
	scanner on: quote storeString.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = quote;
		assert: node source = quote storeString
]

{ #category : #symbols }
SmalltalkScannerTest >> testSymbol [
	| node |
	scanner on: '#-'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'-';
		assert: node source = '#-'.
	scanner on: '#a:'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #a:;
		assert: node source = '#a:'.
	scanner on: '#-!'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #'-!';
		assert: node source = '#-!'.
	scanner on: '#a:b:'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #a:b:;
		assert: node source = '#a:b:'.
	scanner on: '#a:b'.
	node := scanner next.
	self
		assert: node isLiteral;
		assert: node value = #a:;
		assert: node source = '#a:'.
	node := scanner next.
	self assert: node value = 'b'; assert: node source = 'b'
]

{ #category : #unicode }
SmalltalkScannerTest >> testUnicodeScanning [
	| next three tensor |
	scanner on: '3 + 4' asWideString.
	self assert: scanner next value = 3.
	next := scanner next.
	self
		assert: next value == #'+';
		assert: scanner next value = 4.
	scanner on: '3' asWideString , 8855 asCharacter asString , '4' asWideString.
	three := scanner next.
	self assert: three value = 3.
	tensor := scanner next.
	self assert: tensor value = 8855 asCharacter asString asSymbol
]
