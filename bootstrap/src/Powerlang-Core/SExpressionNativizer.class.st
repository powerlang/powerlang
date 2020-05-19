Class {
	#name : #SExpressionNativizer,
	#superclass : #Object,
	#instVars : [
		'assembler',
		'method',
		'messageLinker',
		'environmentInfo',
		'remainingBlocks',
		'safepointCheck',
		'mainCode',
		'stackCount',
		'fallbacks',
		'activeScript'
	],
	#pools : [
		'ClosureElementTypes',
		'SmalltalkOpcodes'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyFor: anSCompiledMethod [
	^ NativizationEnvironment forTesting astcodeNativizer nativeCodeFor:
		  anSCompiledMethod
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForBlock [
	^self assemblyForSource: 'foo [1] value'
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForIfTrue [
	^self assemblyForSource: 'foo x ifTrue: [1]' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForMessage [
	^self assemblyForSource: 'foo self bar'
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForMessageCascade [
	^self assemblyForSource: 'foo self bar; baz'
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForMethod: aCompiledMethod [

^	self
		assemblyForSource: aCompiledMethod sourceCode
		in: aCompiledMethod classBinding value.

]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_1_plus_y [
	^self assemblyForSource: 'foo 1 + y' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_ret_x_eq_1 [
	^ self assemblyForSource: 'foo ^x = 1' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_x [
	^ self assemblyForMethod: Point >> #x
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_x_eq_1 [
	^self assemblyForSource: 'foo x = 1' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_x_eq_eq_1 [
	^self assemblyForSource: 'foo x == 1' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_x_plus_1 [
	^self assemblyForSource: 'foo x + 1' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForPoint_x_plus_y [
	^self assemblyForSource: 'foo x + y' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSource: aString [
	^self assemblyForSource: aString in: UndefinedObject
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSource: aString in: aSpecies [
	| method |
	method := Compiler compile: aString in: aSpecies.
	^self assemblyFor: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSourceOrig: aString [
	^self assemblyForSourceOrig: aString in: UndefinedObject
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSourceOrig: aString in: aSpecies [
	| method |
	method := Compiler compile: aString in: aSpecies.
	^self assemblyOrigFor: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForWhileTrue [
	^self assemblyForSource: 'foo [x := x + 1. true] whileTrue' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyOrigFor: aCompiledMethod [
	^ NativizationEnvironment forTesting nativeCodeFor:
		  aCompiledMethod
]

{ #category : #'instance creation' }
SExpressionNativizer class >> methodBasicAdd [
	| source |
	source := 'basicAdd: anObject
	end = contents size ifTrue: [self makeRoomBehind].
	end := end + 1.
	contents at: end put: anObject.
	^anObject'.
	^self methodForSource: source in: OrderedCollection
]

{ #category : #'instance creation' }
SExpressionNativizer class >> methodForSource: aString [
	^self methodForSource: aString in: UndefinedObject
]

{ #category : #'instance creation' }
SExpressionNativizer class >> methodForSource: aString in: aSpecies [
	| method |
	method := Compiler compile: aString in: aSpecies.
	^self nativize: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> methodWithBlock [
	^self methodForSource: 'foo [1] value'
]

{ #category : #'instance creation' }
SExpressionNativizer class >> nativize: aCompiledMethod [
	| code |
	code := NativizationEnvironment forTesting astcodeNativizer 
		        nativeCodeFor: aCompiledMethod.
	^ aCompiledMethod nativeCode: code
]

{ #category : #services }
SExpressionNativizer >> abi: anAbi [
	assembler wordSize: anAbi wordSize
]

{ #category : #services }
SExpressionNativizer >> addFallback: aBlock [
	fallbacks add: aBlock
]

{ #category : #services }
SExpressionNativizer >> argumentAt: index in: environment [
	| end |
	environment = 0
		ifTrue: [
			end := 3 + self argumentCount.
			assembler loadRwithFPindex: end - index]
		ifFalse: [assembler loadRwithEindex: index]
]

{ #category : #services }
SExpressionNativizer >> argumentCount [
	^activeScript argumentCount
]

{ #category : #services }
SExpressionNativizer >> captureVariable: stream index: anInteger [
	| type pos |
	type := stream next.
	type = nil ifTrue: [^self].
	type = Self ifTrue: [^assembler storeSinRindex: anInteger].
	type = Environment ifTrue: [^assembler storeEinRindex: anInteger].
	pos := stream next.
	type = LocalArgument ifTrue: [
		assembler
			loadTwithFPindex: pos + 2;
			storeTinRindex: anInteger].
	type = EnvironmentValue
		ifTrue: [assembler loadTwithEindex: pos; storeTinRindex: anInteger]
]

{ #category : #services }
SExpressionNativizer >> compile: aCompiledMethod [
	self resetFor: aCompiledMethod; nativize
]

{ #category : #services }
SExpressionNativizer >> dropTos [
	assembler dropTos: 1.
	^stackCount := stackCount - 1
]

{ #category : #services }
SExpressionNativizer >> emitBlockPrologue: anSBlock [
	assembler saveCallerFrame.
	self
		loadBlockSelf: anSBlock compiledCode;
		pushCompiledBlock;
		pushEnvironments;
		initializeTemporaries: anSBlock tempCount
]

{ #category : #services }
SExpressionNativizer >> emitCallbackEpilogue [
	assembler
		restoreCallerFrame;
		popA;
		popA;
		popB;
		popE;
		popS;
		popFP;
		returnFromCallback: method callbackArgumentCount
]

{ #category : #services }
SExpressionNativizer >> emitEpilogue [
	method hasBlocks ifTrue: [assembler restoreCallerEnvironment].
	method isFrameless not
		ifTrue: [
			method isCallback
				ifTrue: [self emitCallbackEpilogue]
				ifFalse: [self emitEpilogueCommon]]
		ifFalse: [self emitEpilogueNoFrame]
]

{ #category : #services }
SExpressionNativizer >> emitEpilogueCommon [
	assembler restoreCallerFrame; restoreCallerSelf; return
]

{ #category : #services }
SExpressionNativizer >> emitEpilogueNoFrame [
	assembler restoreCallerSelf; return
]

{ #category : #services }
SExpressionNativizer >> emitFFICall [
	self loadObject: method.
	assembler pushR; pushS.
	self emitSend: #_ffiCall:.
	assembler restoreCallerFrame; restoreCallerSelf; return
]

{ #category : #services }
SExpressionNativizer >> emitFallbacks [
	fallbacks do: [:block | block value]
]

{ #category : #services }
SExpressionNativizer >> emitFramedMethodPrologue [
	method isCallback ifTrue: [self prepareCallbackFrame].
	assembler saveCallerFrame; pushR; initializeS.
	method isFFIMethod ifTrue: [self emitFFICall] ifFalse: [
		self pushCompiledMethod
			initializeMethodEnvironment;
			initializeMethodTemporaries;
			emitSafepointCheck]
]

{ #category : #services }
SExpressionNativizer >> emitFramelessMethodPrologue [
	method capturesSelf
		ifTrue: [ assembler initializeS ]
]

{ #category : #services }
SExpressionNativizer >> emitMethodPrologue [
	method isFrameless
		ifTrue: [self emitFramelessMethodPrologue]
		ifFalse: [self emitFramedMethodPrologue]
]

{ #category : #services }
SExpressionNativizer >> emitSafepointCheck [
	
]

{ #category : #services }
SExpressionNativizer >> emitSend: selector [
	method isDebuggable
		ifTrue: [messageLinker emitSendDebuggable: selector using: assembler]
		ifFalse: [messageLinker emitSend: selector using: assembler]
]

{ #category : #services }
SExpressionNativizer >> emitSend: selector to: anObject [
	self loadObject: anObject; emitSend: selector
]

{ #category : #services }
SExpressionNativizer >> initialize [
	super initialize.
	assembler := TemplateAssembler64 on: #[  ] writeStream.
	messageLinker := InlineMessageLinker new
]

{ #category : #services }
SExpressionNativizer >> initializeMethodEnvironment [
	method hasBlocks ifFalse: [^self].
	assembler pushE.
	method hasEnvironment
		ifTrue: [
			assembler pushSmallInteger: method environmentSize.
			self emitSend: #new: to: Array.
			assembler loadEwithR; pushE]
		ifFalse: [self pushNil]
]

{ #category : #services }
SExpressionNativizer >> initializeMethodTemporaries [
	self initializeTemporaries: method tempCount
]

{ #category : #services }
SExpressionNativizer >> initializeTemporaries: count [
	count = 0 ifTrue: [^self].
	count <= 6
		ifTrue: [
			assembler loadAwithPointer: nil.
			count timesRepeat: [assembler pushA]]
		ifFalse: [
			assembler
				loadAwithPointer: nil;
				loop: [assembler pushA] times: count]
]

{ #category : #services }
SExpressionNativizer >> instanceVarAt: index [
	assembler loadRwithSindex: index
]

{ #category : #services }
SExpressionNativizer >> instantiateClosure: aCompiledBlock [
	self
		loadObject: self closureClass;
		pushObject: aCompiledBlock;
		emitSend: #newFrom:
]

{ #category : #services }
SExpressionNativizer >> loadAwithArgument: index env: environment [
	| end |
	environment = 0
		ifTrue: [
			end := 3 + self argumentCount.
			assembler loadAwithFPindex: end - index]
		ifFalse: [assembler loadAwithEindex: index]
]

{ #category : #services }
SExpressionNativizer >> loadAwithTemporary: position env: environment [
	| start |
	environment = 0 ifTrue: [
		start := self pushesEnvironments ifTrue: [-3] ifFalse: [-1].
		^assembler loadAwithFPindex: start - position].
	environment = 1
		ifTrue: [assembler loadAwithEindex: position]
		ifFalse: [assembler
			loadAwithEindex: environment;
			loadAwithAindex: position]
]

{ #category : #services }
SExpressionNativizer >> loadBlockSelf: aCompiledBlock [
	aCompiledBlock capturesSelf
		ifTrue: [ 
		assembler loadSwithRindex: SClosure instSize + SClosure receiverIndex ]
		ifFalse: [ assembler loadSwithPointer: nil ].
	assembler pushS
]

{ #category : #services }
SExpressionNativizer >> loadObject: anObject [
	assembler loadRwithPointer: anObject
]

{ #category : #services }
SExpressionNativizer >> loadRwithStack: anInteger [
	assembler loadRwithFPindex: 1 - anInteger
]

{ #category : #services }
SExpressionNativizer >> messageLinker: aMessageLinker [
	messageLinker ifNil: [^self halt ].
	messageLinker := aMessageLinker
]

{ #category : #accessing }
SExpressionNativizer >> method [
	^method
]

{ #category : #services }
SExpressionNativizer >> nativeCode [
	^mainCode
]

{ #category : #services }
SExpressionNativizer >> nativeCodeFor: aCompiledMethod [
	^self compile: aCompiledMethod; nativeCode
]

{ #category : #services }
SExpressionNativizer >> nativize [
	method sexpressions acceptVisitor: self.
	[remainingBlocks isEmpty]
		whileFalse: [self nativizeBlock: remainingBlocks removeFirst]
]

{ #category : #services }
SExpressionNativizer >> nativizeBlock: anSBlock [
	| statements |
	assembler reset.
	activeScript := anSBlock.
	self emitBlockPrologue: anSBlock.
	statements := anSBlock statements.
	statements do: [:s | s acceptVisitor: self].
	self saveContextSwitchPoint.
	(statements isEmpty orNot: [statements last isReturn])
		ifTrue: [self emitEpilogue].
	self emitFallbacks.
	anSBlock compiledCode nativeCode: assembler applyFixups nativeCode
]

{ #category : #services }
SExpressionNativizer >> popR [
	assembler popR.
	stackCount := stackCount - 1
]

{ #category : #services }
SExpressionNativizer >> prepareCallbackFrame [
	assembler saveCallerFrame.
	assembler wordSize = 8 ifTrue: [ assembler storeArgumentsInStack ].
	assembler
		pushS;
		pushE;
		pushB;
		loadRwithArgPointer;
		convertRtoSmallInteger;
		pushR;
		pushSmallInteger: 0;
		xorFPwithFP;
		loadEwithPointer: nil;
		loadRwithPointer: method
]

{ #category : #services }
SExpressionNativizer >> pushCompiledBlock [
	assembler loadAwithRindex: 1; pushA
]

{ #category : #services }
SExpressionNativizer >> pushCompiledMethod [
	assembler pushPointer: method
]

{ #category : #services }
SExpressionNativizer >> pushEnvironments [
	assembler pushE; loadEwithR; pushE
]

{ #category : #services }
SExpressionNativizer >> pushNil [
	self pushObject: nil
]

{ #category : #services }
SExpressionNativizer >> pushObject: anObject [
	assembler pushPointer: anObject
]

{ #category : #services }
SExpressionNativizer >> pushR [
	assembler pushR.
	^stackCount := stackCount + 1
]

{ #category : #services }
SExpressionNativizer >> pushesEnvironments [
	^method hasBlocks
]

{ #category : #services }
SExpressionNativizer >> resetFor: aCompiledMethod [
	| fixed |
	method := aCompiledMethod.
	fallbacks := OrderedCollection new.
	remainingBlocks := OrderedCollection new.
	fixed := aCompiledMethod hasBlocks ifTrue: [4] ifFalse: [2].
	stackCount := aCompiledMethod tempCount + fixed.
	assembler reset
]

{ #category : #accessing }
SExpressionNativizer >> saveContextSwitchPoint [
	method isDebuggable ifTrue: [
		assembler pushA; pushT; pushR.
		messageLinker emitSend: #signalStep using: assembler.
		assembler popR; popT; popA]
]

{ #category : #services }
SExpressionNativizer >> saveMethodCode [
	mainCode := assembler
		            applyFixups;
		            nativeCode
]

{ #category : #services }
SExpressionNativizer >> saveReturnFrame [
	assembler pushR.
	self emitSend: #top to: self stackFrameCursorClass.
	assembler
		loadAwithR;
		popR;
		storeAinRindex: 2
]

{ #category : #templates }
SExpressionNativizer >> sendMustBeBoolean [
	self emitSend: #mustBeBoolean
]

{ #category : #services }
SExpressionNativizer >> storeTemporary: position inEnvironment: env [
	env = 1
		ifTrue: [assembler storeRinEindex: position; pushE]
		ifFalse: [assembler loadTwithEindex: env; storeRinTindex: position; pushT].
	self emitSend: #holdRefererIfNeeded:
]

{ #category : #services }
SExpressionNativizer >> temporaryAt: index in: environment [
	| start |
	environment = 0 ifTrue: [ 
		start := self pushesEnvironments
			         ifTrue: [ -3 ]
			         ifFalse: [ -1 ].
		^ assembler loadRwithFPindex: start - index ].
	environment = 1
		ifTrue: [ assembler loadRwithEindex: index ]
		ifFalse: [ 
			assembler
				loadRwithEindex: environment;
				loadRwithRindex: index ]
]

{ #category : #services }
SExpressionNativizer >> temporaryAt: index in: environment put: dummy [
	| start |
	environment = 0
		ifTrue: [ 
			start := self pushesEnvironments
				         ifTrue: [ -3 ]
				         ifFalse: [ -1 ].
			assembler storeRinFPindex: start - index ]
		ifFalse: [ self storeTemporary: index inEnvironment: environment ]
]

{ #category : #services }
SExpressionNativizer >> visitAssignment: anSAssignment [
	anSAssignment expression acceptVisitor: self.
	anSAssignment assignees do: [ :a | 
		a binding assign: nil within: self ]
]

{ #category : #services }
SExpressionNativizer >> visitBlock: anSBlock [
	| block slot variables |
	remainingBlocks add: anSBlock.
	block := anSBlock compiledCode.
	self instantiateClosure: block.
	slot := 3.
	variables := anSBlock capturedVariables readStream.
	[ variables atEnd ] whileFalse: [ 
		self captureVariable: variables index: slot.
		slot := slot + 1 ].
	block capturesHome ifTrue: [ self saveReturnFrame ]
]

{ #category : #services }
SExpressionNativizer >> visitCascade: anSCascade [
	| index |
	anSCascade receiver acceptVisitor: self.
	index := self pushR.
	anSCascade messages do: [:m | self visitCascadeMessage: m receiver: index].
	self dropTos
]

{ #category : #services }
SExpressionNativizer >> visitCascadeMessage: anSCascadeMessage receiver: index [
	| arguments |
	arguments := anSCascadeMessage arguments.
	arguments do: [:node | 
		node acceptVisitor: self.
		self pushR].
	self loadRwithStack: index; emitSend: anSCascadeMessage selector.
	stackCount := stackCount - arguments size
]

{ #category : #services }
SExpressionNativizer >> visitIdentifier: anSIdentifier [
	anSIdentifier binding valueWithin: self
]

{ #category : #services }
SExpressionNativizer >> visitInlinedMessage: anSMessage [
	| nativizer |
	nativizer := InlinedMessageNativizer new
		message: anSMessage;
		assembler: assembler;
		nativizer: self.
	nativizer inlineMessage
]

{ #category : #services }
SExpressionNativizer >> visitLiteral: anSLiteral [
	| literal |
	literal := anSLiteral value.
	literal isSmallInteger
		ifTrue: [assembler loadRwithSmallInteger: literal]
		ifFalse: [self loadObject: literal]
]

{ #category : #services }
SExpressionNativizer >> visitMessage: anSMessage [
	| arguments index |
	anSMessage isInlined ifTrue: [^self visitInlinedMessage: anSMessage].
	anSMessage isOptimized ifTrue: [^self visitOptimizedMessage: anSMessage].
	anSMessage receiver acceptVisitor: self.
	arguments := anSMessage arguments.
	arguments isEmpty ifFalse: [
		index := self pushR.
		arguments do: [:node | 
			node acceptVisitor: self.
			self pushR].
		self loadRwithStack: index].
	self emitSend: anSMessage selector.
	stackCount := stackCount - arguments size.
	arguments isEmpty ifFalse: [self dropTos]
]

{ #category : #services }
SExpressionNativizer >> visitMethod: anSMethod [
	| statements |
	activeScript := anSMethod.
	self emitMethodPrologue.
	statements := anSMethod statements.
	statements do: [:s | s acceptVisitor: self].
	(statements notEmpty andNot: [statements last isReturn])
		ifTrue: [assembler loadRwithS].
	self emitEpilogue; emitFallbacks; saveMethodCode
]

{ #category : #services }
SExpressionNativizer >> visitOptimizedMessage: anSMessage [
	| nativizer |
	nativizer := BinaryMessageNativizer new
		message: anSMessage;
		assembler: assembler;
		nativizer: self.
	nativizer inlineMessage
]

{ #category : #services }
SExpressionNativizer >> visitReturn: anSReturn [
	anSReturn expression acceptVisitor: self.
	anSReturn local ifTrue: [
	"self emitEpilogue"] ifFalse: [
		assembler pushR; loadRwithE.
		self emitSend: #_return:]
]
