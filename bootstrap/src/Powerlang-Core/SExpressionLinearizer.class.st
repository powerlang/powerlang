Class {
	#name : #SExpressionLinearizer,
	#superclass : #Object,
	#instVars : [
		'operations',
		'primitives',
		'inBlock'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #initialization }
SExpressionLinearizer >> assign: aCollection [
	| op |
	op := SOpAssign new assignees: aCollection.
	operations add: op

]

{ #category : #initialization }
SExpressionLinearizer >> dispatch: message [
 	| op |
	op := SOpDispatchMessage new message: message.
	operations add: op
]

{ #category : #initialization }
SExpressionLinearizer >> dropToS [

	operations add: SOpDropToS new
]

{ #category : #initialization }
SExpressionLinearizer >> loadRfromStack: anInteger [
	| op |
	op := SOpLoadRfromStack new index: anInteger.
	operations add: op

]

{ #category : #initialization }
SExpressionLinearizer >> loadRwithNil [
	operations add: SOpLoadRwithNil new
]

{ #category : #initialization }
SExpressionLinearizer >> loadRwithSelf [
	operations add: SOpLoadRwithSelf new
]

{ #category : #initialization }
SExpressionLinearizer >> operations [
^operations
]

{ #category : #initialization }
SExpressionLinearizer >> primitive: aClosure [
	operations add: (SOpPrimitive new block: aClosure)
]

{ #category : #accessing }
SExpressionLinearizer >> primitives: aCollection [ 
	primitives := aCollection
]

{ #category : #initialization }
SExpressionLinearizer >> pushR [
	operations add: SOpPushR new
]

{ #category : #initialization }
SExpressionLinearizer >> reset [
	operations := OrderedCollection new.
	inBlock := false.

]

{ #category : #initialization }
SExpressionLinearizer >> return [
	operations add: SOpReturn new
]

{ #category : #initialization }
SExpressionLinearizer >> return: isLocal [
	|  class |
	class := (isLocal andNot: [ inBlock ])
		ifTrue: [ SOpReturn ]
		ifFalse: [ SOpNonLocalReturn ].
	operations add: class new
]

{ #category : #initialization }
SExpressionLinearizer >> visitAssignment: anSAssignment [
	anSAssignment expression acceptVisitor: self.
	self
		assign: anSAssignment assignees
]

{ #category : #initialization }
SExpressionLinearizer >> visitBlock: anSBlock [
	| prevInBlock prevOperations statements |
	operations add: anSBlock.
	prevInBlock := inBlock.
	prevOperations := operations.
	inBlock := true.
	operations := OrderedCollection new.
	statements := anSBlock statements.
	statements do: [ :node | node acceptVisitor: self ].
	statements isEmpty
		ifTrue: [ self loadRwithNil ]
		ifFalse: [ statements last isReturn
				ifFalse: [ self return ] ].
	anSBlock optimizedCode: operations asArray.
	operations := prevOperations.
	inBlock := prevInBlock
]

{ #category : #initialization }
SExpressionLinearizer >> visitCascade: anSCascade [
	| args argsize |
	anSCascade receiver acceptVisitor: self.
	self pushR.
	anSCascade messages
		do: [ :msg | 
			args := msg arguments.
			argsize := args size.
			args
				do: [ :arg | 
					arg acceptVisitor: self.
					self pushR ].
			self loadRfromStack: argsize; dispatch: msg ].
	self dropToS
]

{ #category : #initialization }
SExpressionLinearizer >> visitIdentifier: anSIdentifier [
	operations add: anSIdentifier
]

{ #category : #initialization }
SExpressionLinearizer >> visitLiteral: anSLiteral [
	operations add: anSLiteral
]

{ #category : #initialization }
SExpressionLinearizer >> visitMessage: anSMessage [
	|  args argsize |
	anSMessage receiver acceptVisitor: self.
	args := anSMessage arguments.
	argsize := args size.
	argsize > 0
		ifTrue: [ self pushR ].
	args
		do: [ :arg | 
			arg acceptVisitor: self.
			self pushR ].
	argsize > 0
		ifTrue: [ self loadRfromStack: argsize ].
	self dispatch: anSMessage
]

{ #category : #initialization }
SExpressionLinearizer >> visitMethod: anSMethod [
	| primitive statements |
	self reset.

	primitive := anSMethod pragma.
	primitive
		ifNotNil: [ primitive := primitives at: anSMethod primitive.
			self
				primitive: primitive;
				return ].
	statements := anSMethod statements.
	statements do: [ :node | node acceptVisitor: self ].
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ self
				loadRwithSelf;
				return ]
]

{ #category : #initialization }
SExpressionLinearizer >> visitReturn: anSReturn [
	anSReturn expression acceptVisitor: self.
	self
		return: anSReturn local
]
