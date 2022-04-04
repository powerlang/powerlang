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
	[ 
	operation := self nextOperation.
	operation notNil ] whileTrue: [ operation acceptVisitor: self ].
	Transcript
		print: 'MessageCount: ' , messageCount asString;
		cr.
	^ regR
]

{ #category : #private }
PowertalkIterativeStackedInterpreter >> evaluateClosure: closure withArgs: arguments [
	| sblock block |
	sblock := closure astcodes.
	block := sblock compiledCode.
	work := block optimizedCode.
	context popFrame; buildFrameFor: regR code: block environment: closure.
	sblock isInlined
		ifTrue: [ arguments
				with: sblock inlinedArgs
				do: [ :arg :i | context stackTemporaryAt: i put: arg ] ].
	^ regR
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
PowertalkIterativeStackedInterpreter >> prepareFor: anSCompiledMethod [
	| operations array |
	operations := runtime sexpressionsOf: anSCompiledMethod.
	operations isCollection ifTrue: [ ^self ].
	linearizer visitMethod: operations.
			array := linearizer operations asArray.
			operations optimizedCode: array.

]

{ #category : #initializing }
PowertalkIterativeStackedInterpreter >> runtime: aPowertalkRuntime [
	| launcher |
	super runtime: aPowertalkRuntime.
	linearizer runtime: aPowertalkRuntime; dropsArguments.
	launcher := SCompiledMethod new optimizedCode: #().
	context
		system: runtime;
		buildFrameFor: nilObj code: launcher environment: nilObj
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> sendLocal: aSymbol to: receiver with: anArray [
	| symbol literal dummy message dispatch |
	symbol := runtime symbolFromLocal: aSymbol.
	literal := SLiteral new value: nilObj.
	dummy := Array new: anArray size withAll: nil.
	message := SMessage new
		selector: symbol;
		receiver: literal;
		arguments: dummy.
	dispatch := SOpDispatchMessage new message: message.
	regR := receiver.
	anArray isEmpty
		ifFalse: [ context pushOperand: receiver ].
	anArray do: [ :arg | context pushOperand: arg ].
	work := {dispatch}.
	self evaluate.
	^ regR
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> underprimitiveRestart [
	^ [ :receiver :arguments | context restart ]
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpDispatchMessage: anSOpDispatchMessage [
	| message argcount arguments behavior method size environment |
	message := anSOpDispatchMessage message.
	argcount := message argumentCount.
	message cachedUndermessage
		ifNotNil: [ :block | 
			arguments := context popOperands: argcount.
			regR := block value: regR value: arguments.
			(argcount > 0 andNot: [ message isCascadeMessage ])
				ifTrue: [ context popOperand ].
			^ self ].
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
	self prepareFor: method.
	work := method optimizedCode.
	context buildFrameFor: regR code: method environment: environment
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
		work := context regM optimizedCode
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpPrimitive: anSOpPrimtive [
	regR := anSOpPrimtive block value
]

{ #category : #initialization }
PowertalkIterativeStackedInterpreter >> visitOpReturn: anSOpReturn [
	context popFrame.
	work := context regM optimizedCode
]
