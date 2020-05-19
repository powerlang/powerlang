Class {
	#name : #CascadeNode,
	#superclass : #ParseNode,
	#instVars : [
		'receiver',
		'messages',
		'optimized'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
CascadeNode >> acceptVisitor: visitor [
	^visitor visitCascade: self
]

{ #category : #testing }
CascadeNode >> hasAssign [
	receiver hasAssign ifTrue: [^true].
	messages detect: [:msg | msg hasAssign] ifNone: [^false].
	^true
]

{ #category : #enumerating }
CascadeNode >> isCascade [
	^true
]

{ #category : #accessing }
CascadeNode >> messages [
	^messages
]

{ #category : #accessing }
CascadeNode >> messages: aCollection [
	messages := aCollection
]

{ #category : #enumerating }
CascadeNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	receiver nodesDo: aBlock includingDeclarations: aBoolean.
	messages do: [:msg | msg nodesDo: aBlock includingDeclarations: aBoolean]
]

{ #category : #accessing }
CascadeNode >> receiver [
	^receiver
]

{ #category : #accessing }
CascadeNode >> receiver: rcvr [
	receiver := rcvr
]
