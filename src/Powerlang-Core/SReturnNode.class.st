Class {
	#name : #SReturnNode,
	#superclass : #SParseNode,
	#instVars : [
		'expression',
		'return'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SReturnNode >> acceptVisitor: visitor [
	^visitor visitReturn: self
]

{ #category : #accessing }
SReturnNode >> expression [
	^expression
]

{ #category : #accessing }
SReturnNode >> expression: node [
	expression := node
]

{ #category : #testing }
SReturnNode >> hasAssign [
	^expression hasAssign
]

{ #category : #testing }
SReturnNode >> isReturn [
	^true
]

{ #category : #enumerating }
SReturnNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	expression nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
SReturnNode >> return: aSmalltalkToken [
	return := aSmalltalkToken
]
