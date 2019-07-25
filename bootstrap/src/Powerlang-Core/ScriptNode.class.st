Class {
	#name : #ScriptNode,
	#superclass : #ParseNode,
	#instVars : [
		'statements',
		'arguments',
		'temporaries',
		'children'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'add/remove' }
ScriptNode >> addChild: aBlockNode [
	children add: aBlockNode
]

{ #category : #initialization }
ScriptNode >> addStatements: anOrderedCollection [
	statements addAll: anOrderedCollection
]

{ #category : #accessing }
ScriptNode >> arguments [
	^arguments
]

{ #category : #accessing }
ScriptNode >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #initialization }
ScriptNode >> initialize [
	super initialize.
	statements := OrderedCollection new.
	arguments := #().
	temporaries := #().
	children := OrderedCollection new
]

{ #category : #enumerating }
ScriptNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	aBoolean ifTrue: [
		arguments do: [:a | a nodesDo: aBlock includingDeclarations: aBoolean].
		temporaries do: [:a | a nodesDo: aBlock includingDeclarations: aBoolean]].
	statements do: [:s | s nodesDo: aBlock includingDeclarations: aBoolean]
]

{ #category : #accessing }
ScriptNode >> statements [
	^statements
]

{ #category : #accessing }
ScriptNode >> temporaries [
	^temporaries
]

{ #category : #accessing }
ScriptNode >> temporaries: aCollection [
	temporaries := aCollection
]
