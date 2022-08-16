Class {
	#name : #PowertalkIterativeLinkedInterpreter,
	#superclass : #PowertalkIterativeInterpreter,
	#category : #'Powerlang-Core-Execution'
}

{ #category : #private }
PowertalkIterativeLinkedInterpreter >> evaluateClosure: closure withArgs: arguments [
	| frame sblock |
	frame := closure builder.
	sblock := closure executionTree.
	context := frame copy
		beBlock;
		parent: context;
		initializeForBlock: sblock args: arguments closure: closure.
	^ self prepareForBlock: sblock
]

{ #category : #accessing }
PowertalkIterativeLinkedInterpreter >> evaluationContextClass [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeLinkedInterpreter >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol literal dummy message dispatch |
	symbol := runtime symbolFromLocal: aSymbol.
	literal := SLiteral new value: nilObj.
	dummy := Array new: anArray size withAll: literal.
	message := SMessage new
		selector: symbol;
		receiver: literal;
		arguments: dummy.
	dispatch := SOpDispatchMessage new message: message.
	regR := receiver.
	context := self evaluationContextClass new system: self.
	self prepareDispatch: dispatch.
	dummy isEmpty
		ifFalse: [ context pushOperand: receiver ].
	anArray do: [ :arg | context pushOperand: arg ].
	self evaluate.
	^ regR
]

{ #category : #accessing }
PowertalkIterativeLinkedInterpreter >> visitOpDispatchMessage: anSOpDispatchMessage [
	| message argcount arguments behavior method size environment |
	message := anSOpDispatchMessage message.
	argcount := message argumentCount.
	arguments := context popOperands: argcount.
	(argcount > 0 andNot: [ message isCascadeMessage ])
		ifTrue: [ context popOperand ].
	message cachedUndermessage
		ifNotNil: [ :block | ^ regR := block value: regR value: arguments ].
	behavior := message receiver isSuper
		ifTrue: [ runtime superBehaviorOf: context classBinding ]
		ifFalse: [ runtime behaviorOf: regR ].
	method := self
		lookup: message selector
		startingAt: behavior
		sendSite: message.
	method class == BlockClosure
		ifTrue: [ ^ regR := method value: regR value: arguments ].
	size := runtime methodEnvironmentSize: method.
	environment := runtime newEnvironmentSized: size.
	context := self evaluationContextClass new
		self: regR;
		arguments: arguments;
		environment: environment;
		system: runtime; method: method;
		parent: context
		.
	self prepareFor: method
]

{ #category : #accessing }
PowertalkIterativeLinkedInterpreter >> visitOpNonLocalReturn: anSOpReturn [
	context := context homeContext parent
]

{ #category : #accessing }
PowertalkIterativeLinkedInterpreter >> visitOpReturn: anSOpReturn [
	context := context parent
]
