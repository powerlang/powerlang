Class {
	#name : #SCascadeNode,
	#superclass : #SParseNode,
	#instVars : [
		'receiver',
		'messages',
		'optimized'
	],
	#category : #'Powerlang-SCompiler-Parser'
}

{ #category : #visiting }
SCascadeNode >> acceptVisitor: visitor [
	^visitor visitCascade: self
]

{ #category : #testing }
SCascadeNode >> hasAssign [
	receiver hasAssign ifTrue: [^true].
	messages detect: [:msg | msg hasAssign] ifNone: [^false].
	^true
]

{ #category : #enumerating }
SCascadeNode >> isCascade [
	^true
]

{ #category : #accessing }
SCascadeNode >> messages [
	^messages
]

{ #category : #accessing }
SCascadeNode >> messages: aCollection [
	messages := aCollection
]

{ #category : #enumerating }
SCascadeNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	receiver nodesDo: aBlock includingDeclarations: aBoolean.
	messages do: [:msg | msg nodesDo: aBlock includingDeclarations: aBoolean]
]

{ #category : #accessing }
SCascadeNode >> receiver [
	^receiver
]

{ #category : #accessing }
SCascadeNode >> receiver: rcvr [
	receiver := rcvr
]
