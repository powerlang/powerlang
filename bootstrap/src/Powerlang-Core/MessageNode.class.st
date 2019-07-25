Class {
	#name : #MessageNode,
	#superclass : #ParseNode,
	#instVars : [
		'selector',
		'receiver',
		'arguments'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
MessageNode >> arguments [
	^arguments
]

{ #category : #accessing }
MessageNode >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #testing }
MessageNode >> isCascadeMessageNode [
	^false
]

{ #category : #testing }
MessageNode >> isMessageNode [
	^true
]

{ #category : #enumerating }
MessageNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	receiver nodesDo: aBlock includingDeclarations: aBoolean.
	arguments do: [:arg | arg nodesDo: aBlock includingDeclarations: aBoolean].
	selector nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
MessageNode >> receiver [
	^receiver
]

{ #category : #accessing }
MessageNode >> receiver: node [
	receiver := node
]

{ #category : #accessing }
MessageNode >> selector [
	^selector
]

{ #category : #accessing }
MessageNode >> selector: node [
	selector := node
]

{ #category : #accessing }
MessageNode >> symbol [
	^selector symbol
]
