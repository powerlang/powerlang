Class {
	#name : #PowertalkIterativeStackedInterpreter,
	#superclass : #PowertalkIterativeInterpreter,
	#instVars : [
		'linearizer',
		'work'
	],
	#category : #'Powerlang-Core-Execution'
}

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> evaluate [
	| operation |
	[ operation := self nextOperation.
	operation notNil ] whileTrue: [ operation acceptVisitor: self ].
	^ regR
]

{ #category : #private }
PowertalkIterativeStackedInterpreter >> evaluateClosure: closure withArgs: arguments [
	| block receiver |
	block := runtime closureBlock: closure.
	work := runtime blockOptimizedCode: block.
	receiver := (runtime blockCapturesSelf: block)
		ifTrue: [ closure at: 1 ]
		ifFalse: [ nilObj ].
	context
		popFrame;
		buildClosureFrameFor: receiver code: block environment: closure.
	^ regR
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> evaluateUndermessage: message with: block [
	| argcount arguments |
	argcount := message argumentCount.
	arguments := context popOperands: argcount.
	regR := block value: regR value: arguments.
	context reserveStackSlots: argcount
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> initialize [
	super initialize.
	context := StackedEvaluationContext new.
	linearizer := SExpressionLinearizer new
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> initializePrimitives [
	super initializePrimitives.
	linearizer primitives: primitives
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> nextOperation [
 | pc |
pc := context incRegPC.
	pc <= work size
		ifFalse: [ ^ nil ].
	^ work at: pc
]

{ #category : #private }
PowertalkIterativeStackedInterpreter >> prepareFor: method [
	self prepareForExecution: method

]

{ #category : #private }
PowertalkIterativeStackedInterpreter >> prepareForExecution: method [
	| operations linearized |
	operations := runtime sexpressionsOf: method.
	operations isCollection
		ifTrue: [ ^ self ].
	linearizer visitMethod: operations.
	linearized := linearizer operations asArray.
	runtime methodOptimizedCode: method put: linearized
]

{ #category : #initializing }
PowertalkIterativeStackedInterpreter >> runtime: aPowertalkRuntime [
	super runtime: aPowertalkRuntime.
	linearizer
		runtime: aPowertalkRuntime;
		dropsArguments.
	context system: runtime
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol literal dummy message dispatch prevWork prevPC |
	symbol := runtime symbolFromLocal: aSymbol.
	literal := SLiteral new value: nilObj.
	dummy := Array new: anArray size withAll: nil.
	message := SMessage new
		selector: symbol;
		receiver: literal;
		arguments: dummy.
	dispatch := SOpDispatchMessage new message: message.
	prevWork := work.
	prevPC := context regPC.
	context buildLaunchFrame.
	regR := receiver.
	anArray isEmpty
		ifFalse: [ context pushOperand: receiver ].
	anArray do: [ :arg | context pushOperand: arg ].
	work := {dispatch}.
	context regPC: 0.
	self evaluate.
	context popLaunchFrame.
	work := prevWork.
	context regPC: prevPC.
	^ regR
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | context restart ]
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpDispatchMessage: anSOpDispatchMessage [
	| message behavior method size environment |
	message := anSOpDispatchMessage message.
	message cachedUndermessage
		ifNotNil: [ :block | ^ self evaluateUndermessage: message with: block ].
	behavior := message receiver isSuper
		ifTrue: [ runtime superBehaviorOf: context classBinding ]
		ifFalse: [ runtime behaviorOf: regR ].
	method := self
		lookup: message selector
		startingAt: behavior
		sendSite: message.
	method isBlock
		ifTrue: [ ^ self evaluateUndermessage: message with: method ].
	size := runtime methodEnvironmentSize: method.
	environment := runtime newEnvironmentSized: size.
	self prepareFor: method.
	work := runtime methodOptimizedCode: method.
	context
		buildMethodFrameFor: regR
		code: method
		environment: environment
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpJump: anSOpJump [
	context regPC: anSOpJump target
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpJumpFalse: anSOpJumpFalse [
	regR == falseObj
		ifTrue: [ context regPC: anSOpJumpFalse target ]
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpJumpTrue: anSOpJumpTrue [
	regR == trueObj
		ifTrue: [ context regPC: anSOpJumpTrue target ]
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpNonLocalReturn: anSOpReturn [
	context unwind.
		work := runtime methodOptimizedCode: context regM
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpPopR: anSOpPopR [
	regR := context pop
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpPrimitive: anSOpPrimtive [
	regR := anSOpPrimtive block value
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpReturn: anSOpReturn [
	context popFrame.
	work := runtime methodOptimizedCode: context regM
]
