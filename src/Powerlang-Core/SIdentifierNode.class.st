Class {
	#name : #SIdentifierNode,
	#superclass : #SParseNode,
	#instVars : [
		'name',
		'binding'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SIdentifierNode >> acceptVisitor: visitor [
	^visitor visitIdentifier: self
]

{ #category : #binding }
SIdentifierNode >> beAssigned [
	| immutable |
	binding canBeAssigned ifTrue: [^self].
	immutable := binding isClassBinding
		ifTrue: ['class']
		ifFalse: [compiler activeScope describe: binding name].
	self compileError: 'cannot assign to ' , immutable
]

{ #category : #accessing }
SIdentifierNode >> binding [
	^binding
]

{ #category : #accessing }
SIdentifierNode >> binding: aBinding [
	binding := aBinding
]

{ #category : #testing }
SIdentifierNode >> checkLowercase [
	| char |
	char := name first.
	(char isLetter and: [char isUppercase]) ifFalse: [^self].
	self compileWarning: name storeString , ' should start with lowercase'
]

{ #category : #private }
SIdentifierNode >> declaration [
	^binding declaration
]

{ #category : #private }
SIdentifierNode >> defineArgumentIn: aScriptScope [
	binding := aScriptScope defineArgument: name.
	binding declaration: self
]

{ #category : #private }
SIdentifierNode >> defineTemporaryIn: scope [
	binding := scope defineTemporary: name.
	binding declaration: self
]

{ #category : #accessing }
SIdentifierNode >> initialize [
	super initialize.
	binding := DynamicBinding default
]

{ #category : #testing }
SIdentifierNode >> isEvaluable [
	^self isIdentifierLiteral
]

{ #category : #testing }
SIdentifierNode >> isIdentifier [
	^true
]

{ #category : #testing }
SIdentifierNode >> isIdentifierLiteral [
	binding isDynamic ifFalse: [^binding isLiteral].
	^self ast ifNil: [false] ifNotNil: [:ast | | b |
		b := ast scope resolve: name.
		b isLiteral]
]

{ #category : #testing }
SIdentifierNode >> isImmediate [
	^true
]

{ #category : #testing }
SIdentifierNode >> isLocal [
	^binding isLocal
]

{ #category : #testing }
SIdentifierNode >> isMethodArgument [
	| ast |
	binding isArgument ifFalse: [^false].
	ast := self ast ifNil: [^false].
	^ast arguments includes: self declaration
]

{ #category : #testing }
SIdentifierNode >> isMethodTemporary [
	^self ast temporaries includes: self declaration
]

{ #category : #testing }
SIdentifierNode >> isSelf [
	^binding isSelf
]

{ #category : #testing }
SIdentifierNode >> isSuper [
	^binding isSuper
]

{ #category : #accessing }
SIdentifierNode >> name [
	^name
]

{ #category : #evaluating }
SIdentifierNode >> name: aString [
	name := aString reduced
]

{ #category : #private }
SIdentifierNode >> printOn: aStream [
	aStream nextPut: $<;
	nextPutAll: name;
	nextPutAll: '> ('.
	super printOn: aStream.
	aStream nextPut: $)
]

{ #category : #binding }
SIdentifierNode >> resolveAssigning: aBoolean [
	binding := compiler activeScope resolve: name.
	^binding

]

{ #category : #testing }
SIdentifierNode >> sourceIntervals [
	| stretchs declaration ast string code index |
	stretchs := OrderedCollection new.
	declaration := binding declaration.
	ast := self ast.
	ast allNodesDo: [:node | 
		(node class == self class and: [node binding declaration == declaration])
			ifTrue: [stretchs add: node stretch]].
	string := self source.
	code := compiler sourceCode.
	index := ast stretch end.
	[
		index := code indexOfString: string startingAt: index + 1.
		index > 0]
		whileTrue: [stretchs add: (index to: index + string size - 1)].
	^stretchs
]
