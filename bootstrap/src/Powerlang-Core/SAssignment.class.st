Class {
	#name : #SAssignment,
	#superclass : #SExpression,
	#instVars : [
		'assignees',
		'expression'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SAssignment class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeAssignment
]

{ #category : #visiting }
SAssignment >> acceptVisitor: visitor [
	^visitor visitAssignment: self
]

{ #category : #private }
SAssignment >> assign: anSIdentifier [
	assignees add: anSIdentifier
]

{ #category : #visiting }
SAssignment >> assignees [
	^assignees
]

{ #category : #visiting }
SAssignment >> expression [
	^expression
]

{ #category : #visiting }
SAssignment >> expression: anSExpression [
	expression := anSExpression
]

{ #category : #visiting }
SAssignment >> initialize [
	assignees := OrderedCollection new
]

{ #category : #testing }
SAssignment >> isAssignment [
	^true
]

{ #category : #testing }
SAssignment >> printOn: aStream indent: anInteger [
	aStream tab: anInteger; nextPutAll: '{AssignmentId.'.
	assignees
		do: [:identifier | 
			aStream cr.
			identifier printOn: aStream indent: anInteger + 1]
		separatedBy: [aStream nextPutAll: '.'].
	aStream nextPutAll: '.'; cr.
	expression printOn: aStream indent: anInteger + 1.
	aStream nextPutAll: '}'
]
