Class {
	#name : #AssignmentNode,
	#superclass : #ParseNode,
	#instVars : [
		'assignees',
		'expression',
		'operators'
	],
	#classVars : [
		'Token'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'adding / removing' }
AssignmentNode >> assign: anIdentifierNode operator: aDelimiterToken [
	assignees add: anIdentifierNode.
	operators add: aDelimiterToken
]

{ #category : #'adding / removing' }
AssignmentNode >> assign: anIdentifierNode with: aParseNode operator: aDelimiterToken [
	assignees add: anIdentifierNode.
	operators add: aDelimiterToken.
	expression := aParseNode
]

{ #category : #accessing }
AssignmentNode >> assignees [
	^assignees
]

{ #category : #accessing }
AssignmentNode >> expression [
	^expression
]

{ #category : #initialization }
AssignmentNode >> initialize [
	super initialize.
	assignees := OrderedCollection new: 1.
	operators := OrderedCollection new: 1
]

{ #category : #testing }
AssignmentNode >> isAssign [
	^true
]

{ #category : #enumerating }
AssignmentNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	assignees do: [:v | v nodesDo: aBlock includingDeclarations: aBoolean].
	expression nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
AssignmentNode >> operators [
	^operators
]
