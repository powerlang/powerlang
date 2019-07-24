Class {
	#name : #Token,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'stretch'
	],
	#category : #'Powerlang-Core-SCompiler'
}

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
Token >> isComment [
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

{ #category : #accessing }
Token >> position [
	^stretch start
]

{ #category : #accessing }
Token >> position: aNumber [
	stretch start: aNumber
]

{ #category : #accessing }
Token >> source [
	^compiler sourceCode copyFrom: stretch start to: stretch end
]
