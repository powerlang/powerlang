Class {
	#name : #SSelectorNode,
	#superclass : #SParseNode,
	#instVars : [
		'symbol',
		'keywords'
	],
	#category : #'Powerlang-SCompiler-Parser'
}

{ #category : #visiting }
SSelectorNode >> acceptVisitor: visitor [
	^visitor visitSelector: self
]

{ #category : #accessing }
SSelectorNode >> addKeyword: aSelectorNode [
	keywords isNil ifTrue: [keywords := OrderedCollection new: 1].
	keywords add: aSelectorNode
]

{ #category : #accessing }
SSelectorNode >> end [
	stretch end ifNotNil: [:e | ^e].
	^keywords notNil ifTrue: [keywords last end]
]

{ #category : #testing }
SSelectorNode >> hasSymbol [
	^symbol isSymbol
]

{ #category : #queries }
SSelectorNode >> isBinary [
	^symbol isBinary
]

{ #category : #testing }
SSelectorNode >> isSelector [
	^true
]

{ #category : #accessing }
SSelectorNode >> keywords [
	^keywords isNil ifTrue: [{self}] ifFalse: [keywords]
]

{ #category : #accessing }
SSelectorNode >> positions [
	^self keywords collect: [:node | node position]
]

{ #category : #evaluating }
SSelectorNode >> symbol [
	^symbol
]

{ #category : #evaluating }
SSelectorNode >> symbol: aString [
	symbol := aString asSymbol
]

{ #category : #evaluating }
SSelectorNode >> value [
	^symbol
]
