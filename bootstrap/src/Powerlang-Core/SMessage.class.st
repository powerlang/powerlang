Class {
	#name : #SMessage,
	#superclass : #SExpression,
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'opcodes'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SMessage class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeMessage
]

{ #category : #printing }
SMessage >> acceptVisitor: visitor [
	^visitor visitMessage: self
]

{ #category : #printing }
SMessage >> arguments [
	^arguments
]

{ #category : #printing }
SMessage >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #printing }
SMessage >> initialize [
	super initialize.
	arguments := #()
]

{ #category : #printing }
SMessage >> isInlined [
	^opcodes = #inlined
]

{ #category : #printing }
SMessage >> isMessage [
	^true
]

{ #category : #printing }
SMessage >> isOptimized [
	^opcodes notNil
]

{ #category : #private }
SMessage >> opcodes [
	^opcodes
]

{ #category : #private }
SMessage >> opcodes: aCollection [
	opcodes := aCollection
]

{ #category : #printing }
SMessage >> printOn: aStream indent: anInteger [
	aStream tab: anInteger; nextPutAll: '{MessageId. '; nextPutAll: selector; nextPutAll: '. '; cr.
	receiver printOn: aStream indent: anInteger + 1.
	aStream nextPutAll: '.'; cr.
	arguments
		do: [:statement | statement printOn: aStream indent: anInteger + 1]
		separatedBy: [aStream nextPutAll: '. '; cr].
	aStream nextPutAll: '}'
]

{ #category : #printing }
SMessage >> receiver [
	^receiver
]

{ #category : #printing }
SMessage >> receiver: anSExpression [
	receiver := anSExpression
]

{ #category : #printing }
SMessage >> selector [
	^selector
]

{ #category : #printing }
SMessage >> selector: aSelector [
	selector := aSelector
]
