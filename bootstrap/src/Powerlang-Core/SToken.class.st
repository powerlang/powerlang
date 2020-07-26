Class {
	#name : #SToken,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'stretch',
		'comments'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #printing }
SToken >> comment [
	^comments notNil ifTrue: [comments anyOne]
]

{ #category : #printing }
SToken >> comments [
	^comments
]

{ #category : #printing }
SToken >> comments: aCollection [
	aCollection isNil ifTrue: [^self].
	comments isNil
		ifTrue: [comments := aCollection]
		ifFalse: [comments addAll: aCollection]
]

{ #category : #accessing }
SToken >> compileWarning: aString [
	compiler notify: aString at: self stretch
]

{ #category : #accessing }
SToken >> compiler [
	^compiler
]

{ #category : #accessing }
SToken >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler
]

{ #category : #accessing }
SToken >> end [
	^stretch end
]

{ #category : #accessing }
SToken >> end: aNumber [
	stretch end: aNumber
]

{ #category : #testing }
SToken >> endsExpression [
	^self isEnd
]

{ #category : #testing }
SToken >> hasSymbol [
	^false
]

{ #category : #initialization }
SToken >> initialize [
	super initialize.
	stretch := 1 thru: 0
]

{ #category : #testing }
SToken >> is: anObject [
	^false
]

{ #category : #testing }
SToken >> isAssignment [
	^false
]

{ #category : #testing }
SToken >> isBar [
	^(self is: #'|') or: [self is: #'/']
]

{ #category : #testing }
SToken >> isBlockNode [
	^false
]

{ #category : #testing }
SToken >> isComment [
	^false
]

{ #category : #visiting }
SToken >> isDelimitedIdentifier [
	^false
]

{ #category : #testing }
SToken >> isDelimiter [
	^false
]

{ #category : #testing }
SToken >> isEnd [
	^false
]

{ #category : #testing }
SToken >> isIdentifier [
	^false
]

{ #category : #testing }
SToken >> isKeyword [
	^false
]

{ #category : #testing }
SToken >> isLiteral [
	^false
]

{ #category : #testing }
SToken >> isNameToken [
	^false
]

{ #category : #testing }
SToken >> isNumberNode [
	^false
]

{ #category : #testing }
SToken >> isPoolLiteral [
	^false
]

{ #category : #testing }
SToken >> isStringToken [
	^false
]

{ #category : #printing }
SToken >> moveCommentsTo: aParseNode [
	aParseNode comments: comments.
	comments := nil
]

{ #category : #accessing }
SToken >> position [
	^stretch start
]

{ #category : #accessing }
SToken >> position: aNumber [
	stretch start: aNumber
]

{ #category : #accessing }
SToken >> prevPosition [
	^stretch start - 1
]

{ #category : #accessing }
SToken >> source [
	^compiler sourceCode copyFrom: stretch start to: stretch end
]

{ #category : #accessing }
SToken >> stretch [
	^stretch
]

{ #category : #accessing }
SToken >> stretch: aStretch [
	stretch := aStretch
]
