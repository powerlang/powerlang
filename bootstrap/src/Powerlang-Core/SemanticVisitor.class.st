Class {
	#name : #SemanticVisitor,
	#superclass : #ParseTreeVisitor,
	#instVars : [
		'inliner'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #analizing }
SemanticVisitor >> analyzeAssignment: anAssignmentNode [
	anAssignmentNode assignees
		do: [:v | self analyzeIdentifier: v assignee: true]
]

{ #category : #analizing }
SemanticVisitor >> analyzeBlock: aBlockNode while: aBlock [
	aBlockNode isInlined
		ifFalse: [aBlockNode index: aBlockNode compiler blockIndex].
	self analyzeScript: aBlockNode while: aBlock
]

{ #category : #analizing }
SemanticVisitor >> analyzeIdentifier: anIdentifierNode [
	self analyzeIdentifier: anIdentifierNode assignee: false
]

{ #category : #analizing }
SemanticVisitor >> analyzeIdentifier: anIdentifierNode assignee: aBoolean [
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
SemanticVisitor >> analyzeMessage: aMessageNode [
	inliner inline: aMessageNode.
	aMessageNode isInlined ifFalse: [aMessageNode compiler noticeSend]
]

{ #category : #analizing }
SemanticVisitor >> analyzeMethod: aMethodNode while: aBlock [
	self analyzeScript: aMethodNode while: aBlock
]

{ #category : #analizing }
SemanticVisitor >> analyzeReturn: aReturnNode [
	aReturnNode compiler activeScript realScript captureHome
]

{ #category : #analizing }
SemanticVisitor >> analyzeScript: aScriptNode while: aBlock [
	aScriptNode compiler activate: aScriptNode while: aBlock
]

{ #category : #initialization }
SemanticVisitor >> initialize [
	super initialize.
	inliner := MessageInliner new
]

{ #category : #visiting }
SemanticVisitor >> visitAssignment: anAssignmentNode [
	| c |
	self analyzeAssignment: anAssignmentNode.
	anAssignmentNode expression acceptVisitor: self.
	c := anAssignmentNode compiler.

]

{ #category : #visiting }
SemanticVisitor >> visitBlock: aBlockNode [
	self
		analyzeBlock: aBlockNode
		while: [aBlockNode statements do: [:node | node acceptVisitor: self]]
]

{ #category : #visiting }
SemanticVisitor >> visitBraceNode: aBraceNode [
	aBraceNode isLiteral
		ifFalse: [aBraceNode asMessageNode acceptVisitor: self]
]

{ #category : #visiting }
SemanticVisitor >> visitCascade: aCascadeNode [
	aCascadeNode receiver acceptVisitor: self.
	aCascadeNode messages do: [:msg | msg acceptVisitor: self]
]

{ #category : #visiting }
SemanticVisitor >> visitIdentifier: anIdentifierNode [
	self analyzeIdentifier: anIdentifierNode
]

{ #category : #visiting }
SemanticVisitor >> visitMessage: aMessageNode [
	self analyzeMessage: aMessageNode.
	aMessageNode receiver acceptVisitor: self.
	aMessageNode arguments do: [:arg | arg acceptVisitor: self]
]

{ #category : #visiting }
SemanticVisitor >> visitMethod: aMethodNode [
	self analyzeMethod: aMethodNode while: [
		aMethodNode bindLocals.
		aMethodNode statements do: [:s | s acceptVisitor: self].
		aMethodNode positionLocals]
]

{ #category : #visiting }
SemanticVisitor >> visitParseNode: aParseNode [
	"
	do nothing
	"
	
]

{ #category : #visiting }
SemanticVisitor >> visitReturn: aReturnNode [
	aReturnNode expression acceptVisitor: self.
	self analyzeReturn: aReturnNode
]
