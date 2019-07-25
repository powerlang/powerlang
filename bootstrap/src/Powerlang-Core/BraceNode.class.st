Class {
	#name : #BraceNode,
	#superclass : #ParseNode,
	#instVars : [
		'elements',
		'message'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
BraceNode >> elements [
	^elements
]

{ #category : #accessing }
BraceNode >> elements: aCollection [
	elements := aCollection asArray
]

{ #category : #testing }
BraceNode >> isBraceNode [
	^true
]

{ #category : #enumerating }
BraceNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	elements do: [:n | n nodesDo: aBlock includingDeclarations: aBoolean]
]
