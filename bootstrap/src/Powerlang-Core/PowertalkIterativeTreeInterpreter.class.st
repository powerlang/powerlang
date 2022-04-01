Class {
	#name : #PowertalkIterativeTreeInterpreter,
	#superclass : #PowertalkIterativeInterpreter,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> dropToS [
	context pushOperation: SOpDropToS new
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> evaluate [
	| operation |
	[ context hasWork ]
		whileTrue: [ operation := context popOperation.
			operation acceptVisitor: self ].
	Transcript print: 'MessageCount: ' , messageCount asString; cr.
	^ regR
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> evaluationContextClass [
	^ IterativeTreeEvaluationContext
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> loadRfromStack: anInteger [
	| load |
	load := SOpLoadRfromStack new index: anInteger.
		context pushOperation: load
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> loadRwithSelf [
		context pushOperation:SOpLoadRwithSelf new
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> prepareDispatch: dispatch [
	context pushOperation: dispatch
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> prepareFor: anSCompiledMethod [
	| sexpressions |
	sexpressions := runtime sexpressionsOf: anSCompiledMethod.
	self push: sexpressions
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> prepareForBlock: sblock [
	| statements |
	statements := sblock statements.
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ context pushOperation: SOpReturn new ].
	statements reverseDo: [ :exp | context pushOperation: exp ].
	^ nilObj
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> push: anSExpression [
		context pushOperation: anSExpression
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> pushOpAssign: aCollection [
	| op |
	op := SOpAssign new assignees: aCollection.
		context pushOperation: op
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> pushOpReturn [
		context pushOperation: SOpReturn new
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> pushOpReturn: aBoolean [
	| class |
	class := (aBoolean andNot: [ context isBlock ])
		ifTrue: [ SOpReturn ]
		ifFalse: [ SOpNonLocalReturn ].
	context pushOperation: class new
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> pushR [
		context pushOperation: SOpPushR new
]

{ #category : #initializing }
PowertalkIterativeTreeInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | 
	| sexpressions |
	sexpressions := runtime sexpressionsOf: context method.
	context
		restart;
		pushOperation: sexpressions ]
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> visitAssignment: anSAssignment [
	self
		pushOpAssign: anSAssignment assignees;		push: anSAssignment expression

]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> visitCascade: anSCascade [
	| dispatch args argsize |
	self dropToS.
	anSCascade messages
		reverseDo: [ :msg | 
			dispatch := SOpDispatchMessage new message: msg.
			self push: dispatch.
			args := msg arguments.
			argsize := args size.
			self loadRfromStack: argsize.
			args
				reverseDo: [ :arg | 
					self
						pushR;
						push: arg ] ].
	self
		pushR;
		push: anSCascade receiver
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> visitMessage: anSMessage [
	| dispatch args argsize |
	messageCount := messageCount + 1.
	dispatch := SOpDispatchMessage new message: anSMessage.
	self push: dispatch.
	args := anSMessage arguments.
	argsize := args size.
	argsize > 0
		ifTrue: [ self loadRfromStack: argsize ].
	args
		reverseDo: [ :arg | 
			self
				pushR;
				push: arg ].
	argsize > 0
		ifTrue: [ self pushR ].
	self push: anSMessage receiver
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> visitMethod: anSMethod [
	| primitive statements |
	primitive := anSMethod pragma.
	primitive
		ifNotNil: [ primitive class == SPragma
				ifTrue: [ primitive := self primitiveFor: anSMethod primitive.
					anSMethod pragma: primitive ].
			self pushOpReturn.
			^ regR := primitive value ].
	statements := anSMethod statements.
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ self
				pushOpReturn;
				loadRwithSelf ].
	statements reverseDo: [ :node | self push: node ]
]

{ #category : #accessing }
PowertalkIterativeTreeInterpreter >> visitReturn: anSReturn [
	self
		pushOpReturn: anSReturn local;
		push: anSReturn expression
]
