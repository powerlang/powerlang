Class {
	#name : #LocalBinding,
	#superclass : #Binding,
	#instVars : [
		'index',
		'environment',
		'declaration'
	],
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #actions }
LocalBinding >> beInArray [
	environment := ArrayEnvironment new
]

{ #category : #accessing }
LocalBinding >> declaration [
	^declaration
]

{ #category : #accessing }
LocalBinding >> declaration: anIdentifierNode [
	declaration := anIdentifierNode
]

{ #category : #accessing }
LocalBinding >> environment [
	^environment index
]

{ #category : #accessing }
LocalBinding >> environmentIndex [
	^environment index
]

{ #category : #accessing }
LocalBinding >> environmentIndex: anInteger [
	environment index: anInteger
]

{ #category : #accessing }
LocalBinding >> environmentObject [
	^environment
]

{ #category : #accessing }
LocalBinding >> environmentType [
	^environment environmentType
]

{ #category : #accessing }
LocalBinding >> index [
	^index
]

{ #category : #accessing }
LocalBinding >> index: aNumber [
	index := aNumber
]

{ #category : #testing }
LocalBinding >> isInArray [
	^self isInStack not
]

{ #category : #testing }
LocalBinding >> isInStack [
	^environment isStack
]

{ #category : #testing }
LocalBinding >> isLocal [
	^true
]
