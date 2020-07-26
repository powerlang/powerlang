Class {
	#name : #SParseTreeVisitor,
	#superclass : #Object,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
SParseTreeVisitor class >> new [
	^super new initialize
]

{ #category : #visiting }
SParseTreeVisitor >> visit: aParseNode [
	^aParseNode notNil ifTrue: [aParseNode acceptVisitor: self] 
]

{ #category : #visiting }
SParseTreeVisitor >> visitAssignment: anAssignmentNode [
	^self visitParseNode: anAssignmentNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitBlock: aBlockNode [
	^self visitParseNode: aBlockNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitBraceNode: aBraceNode [
	^self visitParseNode: aBraceNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitCascade: aCascadeNode [
	^self visitParseNode: aCascadeNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitCascadeMessage: aCascadeMessageNode [
	^self visitMessage: aCascadeMessageNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitForeignNode: anForeignNode [
	self visitLiteral: anForeignNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitIdentifier: anIdentifierNode [
	^self visitParseNode: anIdentifierNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitLiteral: aLiteralNode [
	^self visitParseNode: aLiteralNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitMessage: aMessageNode [
	^self visitParseNode: aMessageNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitMethod: aMethodNode [
	^self visitParseNode: aMethodNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitNumberNode: aNumberNode [
	^self visitLiteral: aNumberNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitParseNode: aParseNode [
	^self subclassResponsibility
]

{ #category : #visiting }
SParseTreeVisitor >> visitPragma: aPragmaNode [
	^self visitParseNode: aPragmaNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitReturn: aReturnNode [
	^self visitParseNode: aReturnNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitSelector: aSelectorNode [
	^self visitParseNode: aSelectorNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitString: aStringNode [
	^self visitLiteral: aStringNode
]

{ #category : #visiting }
SParseTreeVisitor >> visitSymbolicPragma: aPragmaNode [
	^self visitPragma: aPragmaNode
]
