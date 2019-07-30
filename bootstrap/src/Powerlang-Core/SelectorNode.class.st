Class {
	#name : #SelectorNode,
	#superclass : #ParseNode,
	#instVars : [
		'symbol',
		'keywords'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
SelectorNode >> acceptVisitor: visitor [
	^visitor visitSelector: self
]

{ #category : #accessing }
SelectorNode >> addKeyword: aSelectorNode [
	keywords isNil ifTrue: [keywords := OrderedCollection new: 1].
	keywords add: aSelectorNode
]

{ #category : #accessing }
SelectorNode >> end [
	stretch end ifNotNil: [:e | ^e].
	^keywords notNil ifTrue: [keywords last end]
]

{ #category : #testing }
SelectorNode >> hasSymbol [
	^symbol isSymbol
]

{ #category : #queries }
SelectorNode >> isBinary [
	^symbol isBinary
]

{ #category : #testing }
SelectorNode >> isSelector [
	^true
]

{ #category : #accessing }
SelectorNode >> keywords [
	^keywords isNil ifTrue: [{self}] ifFalse: [keywords]
]

{ #category : #accessing }
SelectorNode >> positions [
	^self keywords collect: [:node | node position]
]

{ #category : #evaluating }
SelectorNode >> symbol [
	^symbol
]

{ #category : #evaluating }
SelectorNode >> symbol: aString [
	symbol := aString asSymbol
]

{ #category : #evaluating }
SelectorNode >> value [
	^symbol
]
