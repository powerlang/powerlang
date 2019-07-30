Class {
	#name : #ParseTreeVisitor,
	#superclass : #Object,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
ParseTreeVisitor class >> new [
	^super new initialize
]

{ #category : #visiting }
ParseTreeVisitor >> visit: aParseNode [
	^aParseNode notNil ifTrue: [aParseNode acceptVisitor: self] 
]

{ #category : #visiting }
ParseTreeVisitor >> visitAssignment: anAssignmentNode [
	^self visitParseNode: anAssignmentNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitBlock: aBlockNode [
	^self visitParseNode: aBlockNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitBraceNode: aBraceNode [
	^self visitParseNode: aBraceNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitCascade: aCascadeNode [
	^self visitParseNode: aCascadeNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitCascadeMessage: aCascadeMessageNode [
	^self visitMessage: aCascadeMessageNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitForeignNode: anForeignNode [
	self visitLiteral: anForeignNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitIdentifier: anIdentifierNode [
	^self visitParseNode: anIdentifierNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitLiteral: aLiteralNode [
	^self visitParseNode: aLiteralNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitMessage: aMessageNode [
	^self visitParseNode: aMessageNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitMethod: aMethodNode [
	^self visitParseNode: aMethodNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitNumberNode: aNumberNode [
	^self visitLiteral: aNumberNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitParseNode: aParseNode [
	^self subclassResponsibility
]

{ #category : #visiting }
ParseTreeVisitor >> visitPragma: aPragmaNode [
	^self visitParseNode: aPragmaNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitReturn: aReturnNode [
	^self visitParseNode: aReturnNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitSelector: aSelectorNode [
	^self visitParseNode: aSelectorNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitString: aStringNode [
	^self visitLiteral: aStringNode
]

{ #category : #visiting }
ParseTreeVisitor >> visitSymbolicPragma: aPragmaNode [
	^self visitPragma: aPragmaNode
]
