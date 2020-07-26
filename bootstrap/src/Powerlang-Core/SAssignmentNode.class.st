Class {
	#name : #SAssignmentNode,
	#superclass : #SParseNode,
	#instVars : [
		'assignees',
		'expression',
		'operators'
	],
	#classVars : [
		'Token'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SAssignmentNode >> acceptVisitor: visitor [
	^visitor visitAssignment: self
]

{ #category : #'adding / removing' }
SAssignmentNode >> assign: anIdentifierNode operator: aDelimiterToken [
	assignees add: anIdentifierNode.
	operators add: aDelimiterToken
]

{ #category : #'adding / removing' }
SAssignmentNode >> assign: anIdentifierNode with: aParseNode operator: aDelimiterToken [
	assignees add: anIdentifierNode.
	operators add: aDelimiterToken.
	expression := aParseNode
]

{ #category : #accessing }
SAssignmentNode >> assignees [
	^assignees
]

{ #category : #accessing }
SAssignmentNode >> expression [
	^expression
]

{ #category : #testing }
SAssignmentNode >> hasAssign [
	^true
]

{ #category : #initialization }
SAssignmentNode >> initialize [
	super initialize.
	assignees := OrderedCollection new: 1.
	operators := OrderedCollection new: 1
]

{ #category : #testing }
SAssignmentNode >> isAssign [
	^true
]

{ #category : #enumerating }
SAssignmentNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	super nodesDo: aBlock includingDeclarations: aBoolean.
	assignees do: [:v | v nodesDo: aBlock includingDeclarations: aBoolean].
	expression nodesDo: aBlock includingDeclarations: aBoolean
]

{ #category : #accessing }
SAssignmentNode >> operators [
	^operators
]
