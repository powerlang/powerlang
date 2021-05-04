Class {
	#name : #SExpressionNativizer,
	#superclass : #Object,
	#instVars : [
		'environment',
		'method',
		'remainingBlocks',
		'safepointCheck',
		'mainCode',
		'stackCount',
		'fallbacks',
		'activeScript',
		'ir'
	],
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyFor: anSCompiledMethod [
	^ NativizationEnvironment forTesting newExpressionNativizer nativize:
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
	method := SCompiler compile: aString in: aSpecies.
	^self assemblyFor: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSourceOrig: aString [
	^self assemblyForSourceOrig: aString in: UndefinedObject
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForSourceOrig: aString in: aSpecies [
	| method |
	method := SCompiler compile: aString in: aSpecies.
	^self assemblyOrigFor: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyForWhileTrue [
	^self assemblyForSource: 'foo [x := x + 1. true] whileTrue' in: Point
]

{ #category : #'instance creation' }
SExpressionNativizer class >> assemblyOrigFor: aCompiledMethod [
	^ NativizationEnvironment forTesting nativize:
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
	method := SCompiler compile: aString in: aSpecies.
	^self nativize: method
]

{ #category : #'instance creation' }
SExpressionNativizer class >> methodWithBlock [
	^self methodForSource: 'foo [1] value'
]

{ #category : #'instance creation' }
SExpressionNativizer class >> nativize: aCompiledMethod [

	^ NativizationEnvironment forTesting newExpressionNativizer
		nativize: aCompiledMethod
]

{ #category : #'instance creation' }
SExpressionNativizer class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #services }
SExpressionNativizer >> addFallback: aBlock [
	fallbacks add: aBlock
]

{ #category : #services }
SExpressionNativizer >> argumentAt: index in: envIndex [
	envIndex ifNil: [ ^ self argumentInStackAt: index ].
	envIndex < 0
		ifTrue: [ self argumentInlinedAt: index ]
		ifFalse: [ self argumentInEnvironmentAt: index ]
]

{ #category : #services }
SExpressionNativizer >> argumentCount [
	^activeScript argumentCount
]

{ #category : #services }
SExpressionNativizer >> argumentInEnvironmentAt: index [
	ir loadRwithEindex: index + SClosure instSize
]

{ #category : #services }
SExpressionNativizer >> argumentInStackAt: index [
	| args end |
	args := self argumentCount.
	method hasFrame ifTrue: [ 
		end := 3 + args.
	ir loadRwithFPindex: end - index ] ifFalse: [ 
		end := 2 + args.
		ir  loadRwithSPindex: end - index
	 ]
]

{ #category : #services }
SExpressionNativizer >> argumentInlinedAt: index [
	self temporaryInStackAt: index
]

{ #category : #services }
SExpressionNativizer >> associationValueAt: anInteger [
	| literal |
	literal := self methodLiteralAt: anInteger.
	ir
		loadRwithLiteral: literal;
		loadRwithRindex: 2
]

{ #category : #services }
SExpressionNativizer >> associationValueAt: anInteger put: dummy [
	| literal |
	literal := self methodLiteralAt: anInteger.
	ir
		loadAwithLiteral: literal;
		storeRinAindex: 2;
		pushA.
	self emitWriteBarrier 
]

{ #category : #services }
SExpressionNativizer >> captureClosure: anSBlock [
	| slot variables |
	self instantiateClosure: anSBlock.
	slot := 3.
	variables := anSBlock capturedVariables readStream.
	[ variables atEnd ]
		whileFalse: [ self captureVariable: variables index: slot.
			slot := slot + 1 ].
	anSBlock capturesHome
		ifTrue: [ self emitSend: #saveHomeFrame ]
]

{ #category : #services }
SExpressionNativizer >> captureVariable: stream index: anInteger [
	| type pos |
	type := stream next.
	type = nil ifTrue: [^self].
	type = Self ifTrue: [^ir storeSinRindex: anInteger].
	type = Environment ifTrue: [^ir storeEinRindex: anInteger].
	pos := stream next.
	type = LocalArgument ifTrue: [
		ir
			loadTwithFPindex: pos + 2;
			storeTinRindex: anInteger].
	type = EnvironmentValue
		ifTrue: [ir loadTwithEindex: pos; storeTinRindex: anInteger]
]

{ #category : #services }
SExpressionNativizer >> constPoolValueAt: anInteger [
	| literal |
	literal := self methodLiteralAt: anInteger.
	ir loadRwithLiteral: literal
]

{ #category : #services }
SExpressionNativizer >> dropTos [
	ir dropTos: 1.
	^stackCount := stackCount - 1
]

{ #category : #services }
SExpressionNativizer >> emitBlockPrologue: anSBlock [
	ir saveCallerFrame.
	self
		loadBlockSelf: anSBlock compiledCode;
		loadBlockNativeCode;
		pushNativeCode;
		pushEnvironments;
		initializeTemporaries: anSBlock tempCount
]

{ #category : #services }
SExpressionNativizer >> emitCallbackEpilogue [
	ir restoreCallerFrame.
	environment abi
		restoreContext: method descriptor with: ir
]

{ #category : #services }
SExpressionNativizer >> emitCallbackPrologue [
	| retaddr |
	environment abi emitEntrypoint: method descriptor with: ir.
	retaddr := 0.
	ir
		pushImmediate: retaddr;
		xorFPwithFP;
		loadLongMwithIPoffset: 0 - ir currentAddress + ImageSegmentWriter behaviorOffset;
		loadMwithMindex: SCallbackMethod behaviorNativeCodeSlot;
		loadGwithLiteral: environment globals;
		loadNilWithLiteral: nil;
		loadTrueWithLiteral: true;
		loadFalseWithLiteral: false;
		loadEwithNil;
		loadRwithMindex: (NativeCode indexOfSlot: 'compiledCode');
		loadRwithRindex: (SCallbackMethod indexOfSlot: 'receiver')
]

{ #category : #services }
SExpressionNativizer >> emitEpilogue [
	method hasBlocks
		ifTrue: [ ir restoreCallerEnvironment ].
	method isCallback
		ifTrue: [ ^ self emitCallbackEpilogue ].
	method isFrameless
		ifFalse: [ ir restoreCallerFrame ].
	ir
		restoreCallerSelf;
		restoreCallerM;
		return
]

{ #category : #services }
SExpressionNativizer >> emitFFICall [
	self loadObject: method.
	ir pushR; pushS.
	self emitSend: #_ffiCall:.
	ir
		restoreCallerFrame;
		restoreCallerSelf;
		restoreCallerM;
		return
]

{ #category : #services }
SExpressionNativizer >> emitFallbacks [
	fallbacks do: [:block | block value]
]

{ #category : #services }
SExpressionNativizer >> emitFramedMethodPrologue [
	ir
		saveCallerFrame;
		pushR;
		initializeS.
	method isCalloutMethod
		ifTrue: [ self emitFFICall ]
		ifFalse: [ self
				pushNativeCode;
				initializeMethodEnvironment;
				initializeMethodTemporaries;
				emitSafepointCheck ]
]

{ #category : #services }
SExpressionNativizer >> emitFramelessMethodPrologue [
	method capturesSelf
		ifTrue: [ ir initializeS ]
]

{ #category : #services }
SExpressionNativizer >> emitMethodPrologue [
	method isCallback
		ifTrue: [ ^self
				emitCallbackPrologue;
				emitFramedMethodPrologue ].
	method isFrameless
		ifTrue: [ self emitFramelessMethodPrologue ]
		ifFalse: [ self emitFramedMethodPrologue ]
]

{ #category : #services }
SExpressionNativizer >> emitSafepointCheck [
	
]

{ #category : #services }
SExpressionNativizer >> emitSend: selector [
 	| linker |
	linker := environment messageLinker.
	method isDebuggable
		ifTrue: [ linker emitSendDebuggable: selector using: ir ]
		ifFalse: [ linker emitSend: selector using: ir ]
]

{ #category : #services }
SExpressionNativizer >> emitSend: selector super: aBoolean [
	| linker |
	linker := environment messageLinker.
	
	method isDebuggable
		ifTrue: [ aBoolean ifTrue: [linker emitSendSuperDebuggable: selector from: method classBinding using: ir] ifFalse: [linker emitSendDebuggable: selector using: ir ]]
		ifFalse: [ aBoolean ifTrue: [linker emitSendSuper: selector from: method classBinding using: ir ] ifFalse: [linker emitSend: selector using: ir ]]
]

{ #category : #services }
SExpressionNativizer >> emitWriteBarrier [
	ir
		loadAwithGlobal: #WriteBarrier;
		callIndirectA;
		discardArguments: 1
]

{ #category : #accessing }
SExpressionNativizer >> environment: aNativizationEnvironment [
	environment := aNativizationEnvironment.
	ir wordSize: environment wordSize
]

{ #category : #services }
SExpressionNativizer >> falseLiteral [
	ir loadRwithFalse
]

{ #category : #initialization }
SExpressionNativizer >> initialize [
	super initialize.
	ir := JITAssemblerAMD64 new

]

{ #category : #services }
SExpressionNativizer >> initializeMethodEnvironment [
	method hasBlocks
		ifFalse: [ ^ self ].
	ir pushE.
	method hasEnvironment
		ifTrue: [ ir
				pushSmallInteger: method environmentCount;
				loadRwithM.
			self emitSend: #newEnvironment:.
			ir
				loadEwithR;
				pushE ]
		ifFalse: [ ir pushNil ]
]

{ #category : #services }
SExpressionNativizer >> initializeMethodTemporaries [
	self initializeTemporaries: method tempCount
]

{ #category : #services }
SExpressionNativizer >> initializeTemporaries: count [
	count = 0
		ifTrue: [ ^ self ].
	count <= 6
		ifTrue: [ count timesRepeat: [ ir pushNil ] ]
		ifFalse: [ ir
				loop: [ ir pushNil ] times: count ]
]

{ #category : #services }
SExpressionNativizer >> instanceVarAt: index [
	ir loadRwithSindex: index
]

{ #category : #services }
SExpressionNativizer >> instanceVarAt: index put: value [
	ir storeRinSindex: index; pushS.
	self emitWriteBarrier
]

{ #category : #services }
SExpressionNativizer >> instantiateClosure: anSBlock [
	self loadLiteralAt: anSBlock index; emitSend: #newClosure
]

{ #category : #services }
SExpressionNativizer >> loadAwithArgument: index in: envIndex [
	envIndex
		ifNil: [ ^ self loadAwithArgumentInStackAt: index ]. envIndex < 0
		ifTrue: [ self loadAwithArgumentInlinedAt: index ]
		ifFalse: [ self loadAwithArgumentInEnvironment: envIndex at: index ]
]

{ #category : #services }
SExpressionNativizer >> loadAwithArgumentInEnvironment: envIndex at: index [
	| offset |
	envIndex = 0
		ifTrue: [ ir loadAwithEindex: index + SClosure instSize ]
		ifFalse: [ offset := activeScript offsetOfEnvironment: envIndex.
			ir
				loadAwithEindex: envIndex + SClosure instSize;
				loadAwithAindex: index + offset ]
]

{ #category : #services }
SExpressionNativizer >> loadAwithArgumentInStackAt: index [
		| end |
	end := 3 + self argumentCount.
			ir loadAwithFPindex: end - index

]

{ #category : #services }
SExpressionNativizer >> loadAwithArgumentInlinedAt: index [
	self loadAwithTemporaryInStackAt: index

]

{ #category : #services }
SExpressionNativizer >> loadAwithStack: anInteger [
	ir loadAwithFPindex: 1 - anInteger
]

{ #category : #services }
SExpressionNativizer >> loadAwithTemporary: index in: envIndex [

	envIndex
		ifNil: [ self loadAwithTemporaryInStackAt: index ]
		ifNotNil: [ 
		self loadAwithTemporaryInEnvironment: envIndex at: index ]
]

{ #category : #services }
SExpressionNativizer >> loadAwithTemporaryInEnvironment: envIndex at: index [
	| offset |
	envIndex = 0
		ifTrue: [offset := activeScript offsetOfCurrentEnvironment. ir loadAwithEindex: index + offset ]
		ifFalse: [ offset := activeScript offsetOfEnvironment: envIndex.
			ir
				loadAwithEindex: envIndex + SClosure instSize;
				loadAwithAindex: index + offset ]
]

{ #category : #services }
SExpressionNativizer >> loadAwithTemporaryInStackAt: index [
			| start |
	start := self pushesEnvironments
					 ifTrue: [ -3 ]
					 ifFalse: [ -1 ].
		^ ir loadAwithFPindex: start - index

]

{ #category : #services }
SExpressionNativizer >> loadBlockNativeCode [
	| block nativeCode |
	block := SClosure indexOfSlot: 'block'.
	nativeCode := SCompiledBlock indexOfSlot: 'nativeCode'.
	ir
		loadMwithRindex: block;
		loadMwithMindex: nativeCode
]

{ #category : #services }
SExpressionNativizer >> loadBlockSelf: aCompiledBlock [
	| offset | 
	aCompiledBlock capturesSelf
		ifTrue: [ offset := aCompiledBlock capturesHome
				ifTrue: [ 1 ]
				ifFalse: [ 0 ].
			ir loadSwithRindex: SClosure instSize + 1 + offset ]
		ifFalse: [ ir loadSwithNil ].
	ir pushS
]

{ #category : #services }
SExpressionNativizer >> loadLiteralAt: anInteger [
	| literal |
	literal := self methodLiteralAt: anInteger.
	ir loadRwithLiteral: literal
]

{ #category : #services }
SExpressionNativizer >> loadObject: anObject [
	ir 	 loadRwithLiteral:  anObject
]

{ #category : #services }
SExpressionNativizer >> loadRwithStack: anInteger [
	ir loadRwithFPindex: 1 - anInteger
]

{ #category : #services }
SExpressionNativizer >> loadTwithStack: anInteger [
	ir loadTwithFPindex: 1 - anInteger
]

{ #category : #accessing }
SExpressionNativizer >> method [
	^method
]

{ #category : #services }
SExpressionNativizer >> methodLiteralAt: anInteger [
	^ method at: anInteger
	
]

{ #category : #services }
SExpressionNativizer >> methodLiteralFrom: anInteger [
	^ method at: anInteger
]

{ #category : #services }
SExpressionNativizer >> nativeCode [
	^mainCode
]

{ #category : #services }
SExpressionNativizer >> nativize [
	method sexpressions acceptVisitor: self.
	[remainingBlocks isEmpty]
		whileFalse: [self nativizeBlock: remainingBlocks removeFirst]
]

{ #category : #services }
SExpressionNativizer >> nativize: aCompiledMethod [
	self
		resetFor: aCompiledMethod;
		nativize.
	^ aCompiledMethod nativeCode: mainCode
]

{ #category : #services }
SExpressionNativizer >> nativizeBlock: anSBlock [
	| statements |
	self resetForBlock: anSBlock.
	activeScript := anSBlock.
	self emitBlockPrologue: anSBlock.
	statements := anSBlock statements.
	statements do: [:s | s acceptVisitor: self].
	self saveContextSwitchPoint.
	(statements isEmpty orNot: [statements last isReturn])
		ifTrue: [self emitEpilogue].
	self emitFallbacks.
	anSBlock compiledCode nativeCode: ir applyFixups nativeCode
]

{ #category : #services }
SExpressionNativizer >> nilLiteral [
	ir loadRwithNil
]

{ #category : #services }
SExpressionNativizer >> popR [
	ir popR.
	stackCount := stackCount - 1
]

{ #category : #services }
SExpressionNativizer >> pushEnvironments [
	ir pushE; loadEwithR; pushE
]

{ #category : #services }
SExpressionNativizer >> pushNativeCode [
	ir pushM
]

{ #category : #services }
SExpressionNativizer >> pushR [
	ir pushR.
	^stackCount := stackCount + 1
]

{ #category : #services }
SExpressionNativizer >> pushesEnvironments [
	^method hasBlocks
]

{ #category : #services }
SExpressionNativizer >> receiver [
	ir loadRwithS
]

{ #category : #services }
SExpressionNativizer >> resetFor: aCompiledMethod [
	| fixed |
	method := aCompiledMethod.
	fallbacks := OrderedCollection new.
	remainingBlocks := OrderedCollection new.
	fixed := aCompiledMethod hasBlocks ifTrue: [4] ifFalse: [2].
	stackCount := aCompiledMethod tempCount + fixed.
	ir reset
]

{ #category : #services }
SExpressionNativizer >> resetForBlock: anSBlock [ 
	fallbacks := OrderedCollection new.
	stackCount := anSBlock tempCount + 4.
	ir reset
]

{ #category : #services }
SExpressionNativizer >> saveContextSwitchPoint [
	method isDebuggable
		ifFalse: [ ^ self ].
	ir
		pushA;
		pushT;
		pushR.
	environment messageLinker emitSend: #signalStep using: ir.
	ir
		popR;
		popT;
		popA
]

{ #category : #services }
SExpressionNativizer >> saveMethodCode [
	mainCode := ir
					applyFixups;
					nativeCode
]

{ #category : #templates }
SExpressionNativizer >> sendMustBeBoolean [
	self emitSend: #mustBeBoolean
]

{ #category : #services }
SExpressionNativizer >> storeRInStack: index [
	ir storeRinFPindex: 1 - index
]

{ #category : #services }
SExpressionNativizer >> temporaryAt: index in: envIndex [
	envIndex ifNil: [ self temporaryInStackAt: index ]
ifNotNil: [ self temporaryInEnvironment: envIndex at: index ]
]

{ #category : #services }
SExpressionNativizer >> temporaryAt: index in: envIndex put: dummy [
	envIndex ifNil: [self temporaryInStackAtPut: index ] ifNotNil: [ 
	self temporaryInEnvironment: envIndex atPut: index]
]

{ #category : #services }
SExpressionNativizer >> temporaryInEnvironment: envIndex at: index [
	| offset |
	envIndex = 0
		ifTrue: [offset := activeScript offsetOfCurrentEnvironment. ir loadRwithEindex: index + offset ]
		ifFalse: [ 
			offset := activeScript offsetOfEnvironment: envIndex.
			ir
				loadRwithEindex: envIndex + SClosure instSize ;
				loadRwithRindex: index + offset]
]

{ #category : #services }
SExpressionNativizer >> temporaryInEnvironment: envIndex atPut: index [
	| offset |
	envIndex = 0
		ifTrue: [ offset := activeScript offsetOfCurrentEnvironment.
			ir
				storeRinEindex: index + offset;
				pushE ]
		ifFalse: [ offset := activeScript offsetOfEnvironment: envIndex.
			ir
				loadTwithEindex: envIndex + SClosure instSize ;
				storeRinTindex: index + offset;
				pushT ].
	self emitWriteBarrier
]

{ #category : #services }
SExpressionNativizer >> temporaryInStackAt: index [
		| start |
	start := self pushesEnvironments
					 ifTrue: [ -3 ]
					 ifFalse: [ -1 ].
		^ ir loadRwithFPindex: start - index .

]

{ #category : #services }
SExpressionNativizer >> temporaryInStackAtPut: index [
			| start |
	start := self pushesEnvironments
						 ifTrue: [ -3 ]
						 ifFalse: [ -1 ].
			ir storeRinFPindex: start - index

]

{ #category : #services }
SExpressionNativizer >> trueLiteral [
	ir loadRwithTrue
]

{ #category : #services }
SExpressionNativizer >> visitAssignment: anSAssignment [
	anSAssignment expression acceptVisitor: self.
	anSAssignment assignees do: [ :a | 
		a binding assign: nil within: self ]
]

{ #category : #services }
SExpressionNativizer >> visitBlock: anSBlock [
	anSBlock isInlined
		ifTrue: [ ^ anSBlock statements do: [ :s | s acceptVisitor: self ] ].
	remainingBlocks add: anSBlock.
	self captureClosure: anSBlock 
]

{ #category : #services }
SExpressionNativizer >> visitCascade: anSCascade [
	| receiver index |
	receiver := anSCascade receiver.
	receiver acceptVisitor: self.
	index := self pushR.
	anSCascade messages
		do: [ :m | self visitCascadeMessage: m receiver: index super: receiver isSuper ].
	self dropTos
]

{ #category : #services }
SExpressionNativizer >> visitCascadeMessage: anSCascadeMessage receiver: index super: aBoolean [
	| arguments |
	arguments := anSCascadeMessage arguments.
	arguments
		do: [ :node | 
			node acceptVisitor: self.
			self pushR ].
	self
		loadRwithStack: index;
		emitSend: anSCascadeMessage selector super: aBoolean.
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
		assembler: ir;
		nativizer: self.
	nativizer inlineMessage
]

{ #category : #services }
SExpressionNativizer >> visitLiteral: anSLiteral [
	| value |
	value := anSLiteral value.
	value isSmallInteger
		ifTrue: [ ir loadRwithSmallInteger: value ]
		ifFalse: [ self loadLiteralAt: anSLiteral index ]
]

{ #category : #services }
SExpressionNativizer >> visitMessage: anSMessage [
	| arguments index |
	anSMessage isInlined
		ifTrue: [ ^ self visitInlinedMessage: anSMessage ].
	anSMessage isOptimized
		ifTrue: [ ^ self visitOptimizedMessage: anSMessage ].
	anSMessage receiver acceptVisitor: self.
	arguments := anSMessage arguments.
	arguments isEmpty
		ifFalse: [ index := self pushR.
			arguments
				do: [ :node | 
					node acceptVisitor: self.
					self pushR ].
			self loadRwithStack: index ].
	self emitSend: anSMessage selector super: anSMessage receiver isSuper.
	stackCount := stackCount - arguments size.
	arguments isEmpty
		ifFalse: [ self dropTos ]
]

{ #category : #services }
SExpressionNativizer >> visitMethod: anSMethod [
	| statements returned |
	activeScript := anSMethod.
	self emitMethodPrologue.
	statements := anSMethod statements.
	statements do: [ :s | s acceptVisitor: self ].
	(statements notEmpty andNot: [ statements last isReturn ])
		ifTrue: [ ir loadRwithS ].
	returned := statements notEmpty and: [ 	
	statements last isReturn].
	returned ifFalse: [ self emitEpilogue ].
	self
		emitFallbacks;
		saveMethodCode
]

{ #category : #services }
SExpressionNativizer >> visitOptimizedMessage: anSMessage [
	| nativizer |
	nativizer := BinaryMessageNativizer new
		message: anSMessage;
		assembler: ir;
		nativizer: self.
	nativizer inlineMessage
]

{ #category : #services }
SExpressionNativizer >> visitReturn: anSReturn [
  anSReturn expression acceptVisitor: self.
  anSReturn local ifTrue: [ self emitEpilogue ] ifFalse: [ ir
		   pushR;
		   loadRwithE.
		self emitSend: #_return: ] 
]
