Class {
	#name : #SSemanticVisitor,
	#superclass : #SParseTreeVisitor,
	#instVars : [
		'inliner'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #analizing }
SSemanticVisitor >> analyzeAssignment: anAssignmentNode [
	anAssignmentNode assignees
		do: [:v | self analyzeIdentifier: v assignee: true]
]

{ #category : #analizing }
SSemanticVisitor >> analyzeBlock: aBlockNode while: aBlock [
	aBlockNode isInlined
		ifFalse: [aBlockNode index: aBlockNode compiler blockIndex].
	self analyzeScript: aBlockNode while: aBlock
]

{ #category : #analizing }
SSemanticVisitor >> analyzeIdentifier: anIdentifierNode [
	self analyzeIdentifier: anIdentifierNode assignee: false
]

{ #category : #analizing }
SSemanticVisitor >> analyzeIdentifier: anIdentifierNode assignee: aBoolean [
	| script binding |
	anIdentifierNode resolveAssigning: aBoolean.
	aBoolean ifTrue: [anIdentifierNode beAssigned].
	script := anIdentifierNode compiler activeScript.
	binding := anIdentifierNode binding.
	script reference: binding.
	binding isLocal ifTrue: [binding := script scope captureLocal: binding].
	anIdentifierNode binding: binding
]

{ #category : #analizing }
SSemanticVisitor >> analyzeMessage: aMessageNode [
	inliner inline: aMessageNode.
	aMessageNode isInlined ifFalse: [aMessageNode compiler noticeSend]
]

{ #category : #analizing }
SSemanticVisitor >> analyzeMethod: aMethodNode while: aBlock [
	self analyzeScript: aMethodNode while: aBlock
]

{ #category : #analizing }
SSemanticVisitor >> analyzeReturn: aReturnNode [
	aReturnNode compiler activeScript realScript captureHome
]

{ #category : #analizing }
SSemanticVisitor >> analyzeScript: aScriptNode while: aBlock [
	aScriptNode compiler activate: aScriptNode while: aBlock
]

{ #category : #initialization }
SSemanticVisitor >> initialize [
	super initialize.
	inliner := MessageInliner new
]

{ #category : #visiting }
SSemanticVisitor >> visitAssignment: anAssignmentNode [
	| c |
	self analyzeAssignment: anAssignmentNode.
	anAssignmentNode expression acceptVisitor: self.
	c := anAssignmentNode compiler.

]

{ #category : #visiting }
SSemanticVisitor >> visitBlock: aBlockNode [
	self
		analyzeBlock: aBlockNode
		while: [aBlockNode statements do: [:node | node acceptVisitor: self]]
]

{ #category : #visiting }
SSemanticVisitor >> visitBraceNode: aBraceNode [
	aBraceNode isLiteral
		ifFalse: [aBraceNode asMessageNode acceptVisitor: self]
]

{ #category : #visiting }
SSemanticVisitor >> visitCascade: aCascadeNode [
	aCascadeNode receiver acceptVisitor: self.
	aCascadeNode messages do: [:msg | msg acceptVisitor: self]
]

{ #category : #visiting }
SSemanticVisitor >> visitIdentifier: anIdentifierNode [
	self analyzeIdentifier: anIdentifierNode
]

{ #category : #visiting }
SSemanticVisitor >> visitMessage: aMessageNode [
	self analyzeMessage: aMessageNode.
	aMessageNode receiver acceptVisitor: self.
	aMessageNode arguments do: [:arg | arg acceptVisitor: self]
]

{ #category : #visiting }
SSemanticVisitor >> visitMethod: aMethodNode [
	self analyzeMethod: aMethodNode while: [
		aMethodNode bindLocals.
		aMethodNode statements do: [:s | s acceptVisitor: self].
		aMethodNode positionLocals]
]

{ #category : #visiting }
SSemanticVisitor >> visitParseNode: aParseNode [
	"
	do nothing
	"
	
]

{ #category : #visiting }
SSemanticVisitor >> visitReturn: aReturnNode [
	aReturnNode expression acceptVisitor: self.
	self analyzeReturn: aReturnNode
]
