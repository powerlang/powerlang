Class {
	#name : #Token,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'stretch',
		'comments'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #printing }
Token >> comment [
	^comments notNil ifTrue: [comments anyOne]
]

{ #category : #printing }
Token >> comments [
	^comments
]

{ #category : #printing }
Token >> comments: aCollection [
	aCollection isNil ifTrue: [^self].
	comments isNil
		ifTrue: [comments := aCollection]
		ifFalse: [comments addAll: aCollection]
]

{ #category : #accessing }
Token >> compileWarning: aString [
	compiler notify: aString at: self stretch
]

{ #category : #accessing }
Token >> compiler [
	^compiler
]

{ #category : #accessing }
Token >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler
]

{ #category : #accessing }
Token >> end [
	^stretch end
]

{ #category : #accessing }
Token >> end: aNumber [
	stretch end: aNumber
]

{ #category : #testing }
Token >> endsExpression [
	^self isEnd
]

{ #category : #testing }
Token >> hasSymbol [
	^false
]

{ #category : #initialization }
Token >> initialize [
	super initialize.
	stretch := 1 thru: 0
]

{ #category : #testing }
Token >> is: anObject [
	^false
]

{ #category : #testing }
Token >> isAssignment [
	^false
]

{ #category : #testing }
Token >> isBar [
	^(self is: #'|') or: [self is: #'/']
]

{ #category : #testing }
Token >> isBlockNode [
	^false
]

{ #category : #testing }
Token >> isComment [
	^false
]

{ #category : #visiting }
Token >> isDelimitedIdentifier [
	^false
]

{ #category : #testing }
Token >> isDelimiter [
	^false
]

{ #category : #testing }
Token >> isEnd [
	^false
]

{ #category : #testing }
Token >> isIdentifier [
	^false
]

{ #category : #testing }
Token >> isKeyword [
	^false
]

{ #category : #testing }
Token >> isLiteral [
	^false
]

{ #category : #testing }
Token >> isNameToken [
	^false
]

{ #category : #testing }
Token >> isNumberNode [
	^false
]

{ #category : #testing }
Token >> isPoolLiteral [
	^false
]

{ #category : #testing }
Token >> isStringToken [
	^false
]

{ #category : #printing }
Token >> moveCommentsTo: aParseNode [
	aParseNode comments: comments.
	comments := nil
]

{ #category : #accessing }
Token >> position [
	^stretch start
]

{ #category : #accessing }
Token >> position: aNumber [
	stretch start: aNumber
]

{ #category : #accessing }
Token >> prevPosition [
	^stretch start - 1
]

{ #category : #accessing }
Token >> source [
	^compiler sourceCode copyFrom: stretch start to: stretch end
]

{ #category : #accessing }
Token >> stretch [
	^stretch
]

{ #category : #accessing }
Token >> stretch: aStretch [
	stretch := aStretch
]
