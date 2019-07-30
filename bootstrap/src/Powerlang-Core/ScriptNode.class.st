Class {
	#name : #ScriptNode,
	#superclass : #ParseNode,
	#instVars : [
		'statements',
		'arguments',
		'temporaries',
		'children',
		'scope'
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

{ #category : #binding }
ScriptNode >> bindLocals [
	arguments do: [:arg | arg defineArgumentIn: scope].
	temporaries do: [:temp | temp checkLowercase; defineTemporaryIn: scope].
	children do: [:block | block bindLocals]
]

{ #category : #accessing }
ScriptNode >> children [
	^children
]

{ #category : #accessing }
ScriptNode >> environmentSize [
	^scope environmentSize
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

{ #category : #binding }
ScriptNode >> positionLocals [
	scope positionLocals.
	children do: [:b | b positionLocals]
]

{ #category : #accessing }
ScriptNode >> realScript [
	self subclassResponsibility
]

{ #category : #binding }
ScriptNode >> reference: aBinding [
	aBinding beReferencedFrom: self
]

{ #category : #binding }
ScriptNode >> scope [
	^scope
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

{ #category : #private }
ScriptNode >> useSelf [
	scope captureSelf
]
