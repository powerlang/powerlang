Class {
	#name : #PowertalkIterativeInterpreter,
	#superclass : #PowertalkInterpreter,
	#instVars : [
		'regR'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #accessing }
PowertalkIterativeInterpreter >> evaluate [
	^self subclassResponsibility

]

{ #category : #accessing }
PowertalkIterativeInterpreter >> evaluateClosure: closure withArgs: arguments [
	| frame sblock |
	frame := closure builder.
	sblock := closure astcodes.
	context := frame copy
		beBlock;
		parent: context;
		initializeForBlock: sblock args: arguments closure: closure.
	^ self prepareForBlock: sblock
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> evaluationContextClass [
	^self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> hasFinished [
	^context parent isNil
]

{ #category : #initializing }
PowertalkIterativeInterpreter >> initializeUndermessages [
	super initializeUndermessages.
	undermessages 		at: #_restart put: self underprimitiveRestart
	
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> prepareDispatch: dispatch [
	self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> prepareFor: anSCompiledMethod [
	self subclassResponsibility
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> prepareForBlock: sblock [
	^self subclassResponsibility	
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> regR: anObject [ 
	regR := anObject
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> sendLocal: aSymbol to: receiver with: anArray [
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
PowertalkIterativeInterpreter >> underprimitiveRestart [
	^ self subclassResponsibility 
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitBlock: anSBlock [
	regR := context captureClosure: anSBlock
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitIdentifier: anSIdentifier [
	regR := anSIdentifier binding valueWithin: context
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitLiteral: anSLiteral [
	regR := runtime literalFor: anSLiteral value
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpAssign: anSOpAssign [
	anSOpAssign assignees
		do: [ :identifier | identifier binding assign: regR within: context ]
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpDispatchMessage: anSOpDispatchMessage [
	| message argcount arguments behavior method size environment |
	self stackSize > 1000
		ifTrue: [ self halt ].
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
		receiver: regR;
		arguments: arguments;
		environment: environment;
		method: method;
		parent: context;
		system: runtime.
	self prepareFor: method
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpDropToS: anSOpDropToS [
	context popOperand
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRfromStack: anSOpLoadRfromStack [
	regR := context operandAt: anSOpLoadRfromStack index
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRwithNil: anSOpLoadRwithNil [
	regR := nilObj
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpLoadRwithSelf: anSOpLoadRwithSelf [
	regR := context receiver
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpNonLocalReturn: anSOpReturn [
	context := context home parent
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpPushR: anSOpPushR [
	context pushOperand: regR
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpRestart: anSOpRestart [
	| sexpressions |
	sexpressions := runtime sexpressionsOf: context method.
	self push: sexpressions
]

{ #category : #accessing }
PowertalkIterativeInterpreter >> visitOpReturn: anSOpReturn [
	context := context parent
]
