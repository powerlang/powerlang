Class {
	#name : #SScriptNode,
	#superclass : #SParseNode,
	#instVars : [
		'statements',
		'arguments',
		'temporaries',
		'children',
		'scope'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #'add/remove' }
SScriptNode >> addChild: aBlockNode [
	children add: aBlockNode
]

{ #category : #initialization }
SScriptNode >> addStatements: anOrderedCollection [
	statements addAll: anOrderedCollection
]

{ #category : #accessing }
SScriptNode >> arguments [
	^arguments
]

{ #category : #accessing }
SScriptNode >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #binding }
SScriptNode >> bindLocals [
	arguments do: [:arg | arg defineArgumentIn: scope].
	temporaries do: [:temp | temp checkLowercase; defineTemporaryIn: scope].
	children do: [:block | block bindLocals]
]

{ #category : #accessing }
SScriptNode >> children [
	^children
]

{ #category : #accessing }
SScriptNode >> environmentSize [
	^scope environmentSize
]

{ #category : #testing }
SScriptNode >> hasAssign [
	statements do: [:s | s hasAssign ifTrue: [^true]].
	^false
]

{ #category : #initialization }
SScriptNode >> initialize [
	super initialize.
	statements := OrderedCollection new.
	arguments := #().
	temporaries := #().
	children := OrderedCollection new
]

{ #category : #enumerating }
SScriptNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	aBoolean ifTrue: [
		arguments do: [:a | a nodesDo: aBlock includingDeclarations: aBoolean].
		temporaries do: [:a | a nodesDo: aBlock includingDeclarations: aBoolean]].
	statements do: [:s | s nodesDo: aBlock includingDeclarations: aBoolean]
]

{ #category : #binding }
SScriptNode >> positionLocals [
	scope positionLocals.
	children do: [:b | b positionLocals]
]

{ #category : #accessing }
SScriptNode >> realScript [
	self subclassResponsibility
]

{ #category : #binding }
SScriptNode >> reference: aBinding [
	aBinding beReferencedFrom: self
]

{ #category : #binding }
SScriptNode >> scope [
	^scope
]

{ #category : #accessing }
SScriptNode >> statements [
	^statements
]

{ #category : #accessing }
SScriptNode >> temporaries [
	^temporaries
]

{ #category : #accessing }
SScriptNode >> temporaries: aCollection [
	temporaries := aCollection
]

{ #category : #private }
SScriptNode >> useSelf [
	scope captureSelf
]
