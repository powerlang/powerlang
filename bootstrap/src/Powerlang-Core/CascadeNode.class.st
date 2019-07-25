Class {
	#name : #CascadeNode,
	#superclass : #ParseNode,
	#instVars : [
		'receiver',
		'messages'
	],
	#category : #'Powerlang-Core-SCompiler'
}

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
