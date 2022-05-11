Class {
	#name : #PowertalkLinkedTreeInterpreter,
	#superclass : #PowertalkIterativeLinkedInterpreter,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> dropToS [
	context pushOperation: SOpDropToS new
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> evaluate [
	| operation |
	[ context hasWork ]
		whileTrue: [ operation := context popOperation.
			operation acceptVisitor: self ].
	Transcript print: 'MessageCount: ' , messageCount asString; cr.
	^ regR
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> evaluationContextClass [
	^ LinkedTreeEvaluationContext
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> loadRfromStack: anInteger [
	| load |
	load := SOpLoadRfromStack new index: anInteger.
		context pushOperation: load
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> loadRwithSelf [
		context pushOperation:SOpLoadRwithSelf new
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> prepareDispatch: dispatch [
	context pushOperation: dispatch
]

{ #category : #private }
PowertalkLinkedTreeInterpreter >> prepareFor: method [
	| sexpressions |
	sexpressions := self prepareForExecution: method.
	self push: sexpressions
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> prepareForBlock: sblock [
	| statements |
	statements := sblock statements.
	(statements isEmpty orNot: [ statements last isReturn ])
		ifTrue: [ context pushOperation: SOpReturn new ].
	statements reverseDo: [ :exp | context pushOperation: exp ].
	^ nilObj
]

{ #category : #private }
PowertalkLinkedTreeInterpreter >> prepareForExecution: anSCompiledMethod [
	^runtime sexpressionsOf: anSCompiledMethod.

]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> push: anSExpression [
		context pushOperation: anSExpression
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> pushOpAssign: aCollection [
	| op |
	op := SOpAssign new assignees: aCollection.
		context pushOperation: op
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> pushOpReturn [
		context pushOperation: SOpReturn new
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> pushOpReturn: aBoolean [
	| class |
	class := (aBoolean andNot: [ context isBlock ])
		ifTrue: [ SOpReturn ]
		ifFalse: [ SOpNonLocalReturn ].
	context pushOperation: class new
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> pushR [
		context pushOperation: SOpPushR new
]

{ #category : #initializing }
PowertalkLinkedTreeInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | 
	| sexpressions |
	sexpressions := runtime sexpressionsOf: context method.
	context
		restart;
		pushOperation: sexpressions ]
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> visitAssignment: anSAssignment [
	self
		pushOpAssign: anSAssignment assignees;		push: anSAssignment expression

]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> visitCascade: anSCascade [
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
PowertalkLinkedTreeInterpreter >> visitMessage: anSMessage [
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
PowertalkLinkedTreeInterpreter >> visitMethod: anSMethod [
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
PowertalkLinkedTreeInterpreter >> visitOpRestart: anSOpRestart [
	| sexpressions |
	sexpressions := runtime sexpressionsOf: context method.
	self push: sexpressions
]

{ #category : #accessing }
PowertalkLinkedTreeInterpreter >> visitReturn: anSReturn [
	self
		pushOpReturn: anSReturn local;
		push: anSReturn expression
]
