Class {
	#name : #SmalltalkScanner,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'stream'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #private }
SmalltalkScanner >> buildToken: aSmalltalkToken [
	^self buildToken: aSmalltalkToken at: stream position
]

{ #category : #private }
SmalltalkScanner >> buildToken: aSmalltalkToken at: anInteger [
	| string |
	string := stream copyFrom: anInteger to: stream position.
	^self buildToken: aSmalltalkToken at: anInteger with: string
]

{ #category : #private }
SmalltalkScanner >> buildToken: aSmalltalkToken at: anInteger with: anObject [
	^aSmalltalkToken
		position: anInteger;
		value: anObject;
		end: stream position
]

{ #category : #testing }
SmalltalkScanner >> canBeInIdentifier: aCharacter [
	^compiler frontend canBeInIdentifier: aCharacter
]

{ #category : #testing }
SmalltalkScanner >> canStartIdentifier: aCharacter [
	(compiler frontend canStartIdentifier: aCharacter) ifFalse: [^false].
	aCharacter = $_
		ifTrue: [^stream peek ifNil: [false] ifNotNil: [:ch | ch asInteger >= 33]].
	^true
]

{ #category : #accessing }
SmalltalkScanner >> compiler [
	^compiler
]

{ #category : #accessing }
SmalltalkScanner >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler
]

{ #category : #scanning }
SmalltalkScanner >> end [
	^self buildToken: compiler endToken at: stream position + 1
]

{ #category : #errors }
SmalltalkScanner >> error: aString [
	^self error: aString at: stream position
]

{ #category : #errors }
SmalltalkScanner >> error: aString at: anInteger [
	^compiler error: aString at: anInteger
]

{ #category : #initialization }
SmalltalkScanner >> initialize [
	super initialize.
	compiler := Compiler new smalltalkCompiler.
	compiler resetResult
]

{ #category : #scanning }
SmalltalkScanner >> isBinary: aCharacter [
	| code |
	aCharacter isNil ifTrue: [^false].
	code := aCharacter asInteger.
	code < 128 ifTrue: [
		^#($+ $- $< $> $= $* $/ $\ $| $& $~ $, $@ $% $? $! $: $^)
			includes: aCharacter].
	^code > 255
]

{ #category : #scanning }
SmalltalkScanner >> next [
	^self nextToken
]

{ #category : #scanning }
SmalltalkScanner >> nextArrayPrefix [
	| string |
	string := stream copyFrom: stream position - 1 to: stream position.
	^self
		buildToken: compiler delimiterToken
		at: stream position - 1
		with: string
]

{ #category : #scanning }
SmalltalkScanner >> nextAssignment [
	^self buildToken: compiler delimiterToken at: stream position with: #':='
]

{ #category : #scanning }
SmalltalkScanner >> nextBinarySelector [
	stream back.
	^self
		buildToken: compiler stringToken
		at: stream position + 1
		with: self scanBinarySymbol
]

{ #category : #scanning }
SmalltalkScanner >> nextBinarySymbol [
	^self
		buildToken: compiler literalNode
		at: stream position
		with: self scanBinarySymbol
]

{ #category : #scanning }
SmalltalkScanner >> nextColon [
	| start char |
	start := stream position.
	char := stream peek.
	((char = $ or: [char = $	]) and: [(stream peek: 2) second = $=]) ifTrue: [
		stream skip: 1.
		char := $=].
	char = $= ifTrue: [
		stream skip.
		^self nextAssignment position: start].
	^(self isBinary: stream peek)
		ifTrue: [self nextBinarySelector]
		ifFalse: [self nextSpecialCharacter]
]

{ #category : #scanning }
SmalltalkScanner >> nextComment [
	| start comment |
	start := stream position.
	(stream skipTo: $") ifFalse: [self error: 'unfinished comment' at: start].
	stream position: start.
	comment := stream upTo: $".
	^self buildToken: compiler commentNode at: start with: comment
]

{ #category : #scanning }
SmalltalkScanner >> nextIdentifierOrKeyword [
	| start |
	start := stream position.
	self skipIdentifier.
	((stream peekFor: $:) and: [stream peekFor: $=]) ifTrue: [stream skip: -2].
	^self buildToken: compiler stringToken at: start
]

{ #category : #scanning }
SmalltalkScanner >> nextKeyword [
	| start string |
	start := stream position + 1.
	self skipKeyword.
	string := stream copyFrom: start to: stream position.
	^self buildToken: compiler literalNode at: start - 1 with: string asSymbol
]

{ #category : #scanning }
SmalltalkScanner >> nextLiteralCharacter [
	stream atEnd ifTrue: [^self error: 'character expected'].
	^self
		buildToken: compiler literalNode
		at: stream position
		with: stream next
]

{ #category : #scanning }
SmalltalkScanner >> nextLiteralString [
	^self
		buildToken: compiler literalNode
		at: stream position
		with: self scanString reduced
]

{ #category : #scanning }
SmalltalkScanner >> nextNumber [
	| parser assoc |
	stream skip: -1.
	parser := NumberParser2 new on: stream.
	assoc := parser next.
	parser error ifNotNil: [:e | ^self error: e key at: e value].
	^self
		buildToken: compiler numericLiteralNode
		at: assoc value start
		with: assoc key
]

{ #category : #scanning }
SmalltalkScanner >> nextQuotedSymbol [
	| node |
	node := self nextLiteralString.
	^node beSymbol; position: node position - 1
]

{ #category : #scanning }
SmalltalkScanner >> nextSpecialCharacter [
	| token |
	token := self buildToken: compiler delimiterToken.
	^token beCharacter
]

{ #category : #scanning }
SmalltalkScanner >> nextSymbolOrArrayPrefix [
	| char |
	stream atEnd ifTrue: [self error: 'character expected'].
	char := stream peek.
	(self canBeInIdentifier: char) ifTrue: [^self nextKeyword].
	(self isBinary: char) ifTrue: [^self nextBinarySymbol].
	stream next.
	(char = $[ or: [char = $(]) ifTrue: [^self nextArrayPrefix].
	char = $' ifTrue: [^self nextQuotedSymbol].
	self error: 'character expected'
]

{ #category : #scanning }
SmalltalkScanner >> nextToken [
	| first |
	first := self scanChar.
	first isNil ifTrue: [^self end].
	(self canStartIdentifier: first) ifTrue: [^self nextIdentifierOrKeyword].
	(first = $→ or: [first = $_]) ifTrue: [^self nextAssignment].
	first = $: ifTrue: [^self nextColon].
	first = $' ifTrue: [^self nextLiteralString].
	first = $$ ifTrue: [^self nextLiteralCharacter].
	first = $# ifTrue: [^self nextSymbolOrArrayPrefix].
	first = $" ifTrue: [^self nextComment].
	first isDigit ifTrue: [^self nextNumber].
	(first != $^ and: [first != $↑ and: [self isBinary: first]])
		ifTrue: [^self nextBinarySelector].
	^self nextSpecialCharacter
]

{ #category : #accessing }
SmalltalkScanner >> on: aString [
	stream := aString readStream.
	compiler notNil ifTrue: [compiler sourceCode: aString]
]

{ #category : #scanning }
SmalltalkScanner >> scanBinarySymbol [
	| start symbol |
	start := stream position.
	self skipBinary.
	symbol := stream copyFrom: start + 1 to: stream position.
	^symbol asSymbol
]

{ #category : #scanning }
SmalltalkScanner >> scanChar [
	^stream skipSeparators atEnd ifFalse: [stream next]
]

{ #category : #scanning }
SmalltalkScanner >> scanString [
	| current start |
	start := current := stream position.
	^String streamContents: [:writer | 
		[| fragment |
			fragment := stream upTo: $'.
			writer nextPutAll: fragment.
			(current < stream position and: [(stream back; next) = $'])
				ifFalse: [self error: 'string end expected' at: start].
			stream peekFor: $']
			whileTrue: [
				writer nextPut: $'.
				current := stream position]]
]

{ #category : #scanning }
SmalltalkScanner >> skipBinary [
	[self isBinary: stream peek] whileTrue: [stream next]
]

{ #category : #scanning }
SmalltalkScanner >> skipIdentifier [
	| frontend |
	frontend := compiler frontend.
	[stream atEnd]
		whileFalse: [(frontend peekForIdentifier: stream) ifFalse: [^self]]
]

{ #category : #scanning }
SmalltalkScanner >> skipKeyword [
	| frontend continue pos |
	frontend := compiler frontend.
	[
		self skipIdentifier.
		continue := false.
		(stream peekFor: $:) ifTrue: [
			pos := stream position.
			stream atEnd
				ifFalse: [continue := frontend canStartIdentifier: stream peek]].
		continue] whileTrue.
	pos isNil ifFalse: [stream position: pos]
]
