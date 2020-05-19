Class {
	#name : #ReturnNode,
	#superclass : #ParseNode,
	#instVars : [
		'expression',
		'return'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
ReturnNode >> acceptVisitor: visitor [
	^visitor visitReturn: self
]

{ #category : #accessing }
ReturnNode >> expression [
	^expression
]

{ #category : #accessing }
ReturnNode >> expression: node [
	expression := node
]

{ #category : #testing }
ReturnNode >> hasAssign [
	^expression hasAssign
]

{ #category : #testing }
ReturnNode >> isReturn [
	^true
]

{ #category : #enumerating }
ReturnNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	expression nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
ReturnNode >> return: aSmalltalkToken [
	return := aSmalltalkToken
]
