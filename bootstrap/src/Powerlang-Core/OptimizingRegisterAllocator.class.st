"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingRegisterAllocator,
	#superclass : #Object,
	#instVars : [
		'abi',
		'liveRanges',
		'unifiedLiveRanges',
		'expirations',
		'allocation',
		'free',
		'used',
		'usedOut',
		'locals',
		'currentBlock',
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingRegisterAllocator class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> abi: anAbi [
	abi := anAbi.
	free := OrderedCollection new.
	free
		add: abi regS;
		add: abi regT;
		add: abi regA;
		add: abi regR;
		add: abi regFP
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> activationRecord [
	^firstBlock firstInstruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> addLiveRangesOf: block [
	block
		instructionsDo: [:instruction | self
			assureLiveRangeStartingAt: instruction
			in: block]
]

{ #category : #private }
OptimizingRegisterAllocator >> allocateFor: inst [
	| range register starts ends |
	(self rangesEndingAt: inst) reverseDo: [:ending | self free: ending].
	range := self unifiedLiveRangeOf: inst.
	starts := range startsAt: inst.
	ends := range endsAt: inst.
	(ends not and: [range isSpilled not]) ifTrue: [
		starts ifTrue: [self assignRegisterTo: inst in: range].
		register := allocation at: range.
		allocation at: inst put: register].
	inst isMessageSend ifTrue: [self repairToRespectABI: inst with: range]
]

{ #category : #private }
OptimizingRegisterAllocator >> allocateLiveRanges [
	self preallocateImplicitVariables.
	firstBlock reversePostOrderDo: [:block | 
		currentBlock := block.
		self recalculateRegisterUsage.
		block instructionsDo: [:inst | self allocateFor: inst].
		usedOut at: block put: used copy]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> allocation [
	^allocation
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> assign: register to: aRange [
	((free includes: register) not and: [(used at: register) != aRange])
		ifTrue: [self error: 'register ' , register , ' is not free'].
	allocation at: aRange put: register.
	free remove: register ifAbsent: [].
	used at: register put: aRange
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> assignRegisterTo: instruction in: aRange [
	| register |
	register := allocation at: aRange ifAbsent: [
		free isEmpty
			ifTrue: [self spillALiveRangeInUseAfter: instruction]
			ifFalse: [free last]].
	"register == edx ifTrue: [self halt]."
	self assign: register to: aRange
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> assureLiveRangeOf: operand startingAt: anInstruction [
	| range |
	range := self assureLiveRangeStartingAt: anInstruction in: currentBlock.
	liveRanges at: operand put: range
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> assureLiveRangeStartingAt: anInstruction [
	^self assureLiveRangeStartingAt: anInstruction in: currentBlock
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> assureLiveRangeStartingAt: anInstruction in: block [
	| range |
	range := OSimpleLiveRange new definedAt: anInstruction in: block.
	liveRanges at: anInstruction put: range.
	^range
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeExpirationOf: instruction [
	| range |
	range := self unifiedLiveRangeOf: instruction.
	range expirationPoints do: [:operation | self kill: range at: operation]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeExpirations [
	firstBlock
		instructionsWithSuccessorsDo: [:instruction | self
			computeExpirationOf: instruction]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeInterferenceGraph [
	liveRanges do: [:range | self computeInterferencesOf: range]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeInterferencesOf: range [
	range instructionsDo: [:instruction | | other |
		other := self liveRangeOf: instruction.
		self range: range interferes: other]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeLiveRanges [
	firstBlock
		reversePostOrderDo: [:block | self addLiveRangesOf: block];
		reversePostOrderDo: [:block | self
			currentBlock: block;
			computeLiveRangesOf: block].
	self computeExpirations
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> computeLiveRangesOf: block [
	block firstInstruction acceptVisitor: self
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> currentBlock: aBasicBlock [
	currentBlock := aBasicBlock
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> doAllocation [
	| record |
	"	record := self activationRecord.
	record isLoadImplicit ifFalse: [free remove: ebp]."
	self computeLiveRanges; allocateLiveRanges; reserveSpaceForLocals.
	^allocation
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> firstBlock: aBasicBlock [
	firstBlock := aBasicBlock
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> free: range [
	| register |
	register := allocation at: range ifAbsent: [^self].
	(free includes: register) ifTrue: [^self].
	(used at: register) == range ifFalse: [^self].
	"register == ecx ifTrue: [self halt]."
	free add: register.
	used removeKey: register.
	^register
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> initialize [
	allocation := IdentityDictionary new.
	liveRanges := IdentityDictionary new.
	unifiedLiveRanges := IdentityDictionary new.
	expirations := IdentityDictionary new.
	locals := 2.
	used := Dictionary new.
	usedOut := Dictionary new
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertCopyResultAfter: messageSend [
	| copy range |
	copy := OUnaryOperation receiver: messageSend name: #copyResult.
	messageSend
		afterInsert: copy;
		replaceAllUsesWith: copy;
		addUse: copy at: #receiver.
	range := self liveRangeOf: messageSend.
	range definition: copy.
	liveRanges at: copy put: range.
	unifiedLiveRanges
		at: messageSend
		ifPresent: [:unified | unifiedLiveRanges at: copy put: unified]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertCopyToR: anInstruction before: inst [
	| copy range |
	copy := OUnaryOperation receiver: anInstruction name: #copy.
	anInstruction addUse: copy at: #receiver.
	inst beforeInsert: copy.
	range := self unifiedLiveRangeOf: anInstruction.
	liveRanges at: copy put: range.
	allocation at: copy put: abi regR
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertLoadBefore: use at: block changing: operand [
	| stack load range definition |
	use isPhi ifTrue: [
		range := self liveRangeOf: use.
		range beSpilled.
		^self].
	stack := used at: abi regFP.
	load := OBinaryConstantOperation
		left: stack anyDefinition
		right: 1 - locals
		name: #_basicAt:.
	stack anyDefinition addUse: load at: #left.
	use beforeInsert: load.
	definition := operand definition.
	operand replaceUseWith: load.
	load addUse: use at: operand name.
	range := self assureLiveRangeStartingAt: load.
	range addUseFrom: use at: block.
	self kill: range at: use.
	allocation
		at: definition
		ifPresent: [:register | allocation at: load put: register]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertPop: anInstruction to: register after: messageSend [
	| pop range |
	pop := OUnaryOperation receiver: nil name: #pop.
	messageSend afterInsert: pop.
	range := self unifiedLiveRangeOf: anInstruction.
	liveRanges at: pop put: range.
	allocation at: pop put: register
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertPush: anInstruction before: inst [
	| push |
	push := OUnaryOperation receiver: anInstruction name: #push.
	anInstruction addUse: push at: #receiver.
	inst beforeInsert: push
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> insertStoreAfter: definition at: block [
	| stack store range |
	unifiedLiveRanges removeKey: definition ifAbsent: [].
	definition isPhi ifTrue: [^self].
	stack := used at: abi regFP.
	store := OTernaryOperation
		receiver: stack anyDefinition
		left: 1 - locals
		right: definition
		name: #_basicAt:put:.
	stack anyDefinition addUse: store at: #receiver.
	definition addUse: store at: #right.
	definition afterInsert: store.
	range := self assureLiveRangeStartingAt: definition.
	range addUseFrom: store at: block.
	stack addUseFrom: store at: block.
	self kill: range at: store.
	range := self assureLiveRangeStartingAt: store.
	self kill: range at: store
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> isFree: register [
	^free includes: register
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> isSpilled: register [
	^false
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> kill: range at: instruction [
	| expiring |
	(range class = OSimpleLiveRange or: [range class == OComposedLiveRange])
		ifFalse: [self halt].
	expiring := expirations
		at: instruction
		ifAbsentPut: [OrderedCollection new].
	expiring add: range
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> liveRangeOf: value [
	^liveRanges at: value
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> preallocateImplicitVariables [
	firstBlock instructionsDo: [:inst | | range register |
		inst isLoadImplicit ifFalse: [^self].
		range := self unifiedLiveRangeOf: inst.
		register := inst source.
		register ifNotNil: [allocation at: range put: register]]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> rangesEndingAt: instruction [
	^expirations at: instruction ifAbsent: [OrderedCollection new]
]

{ #category : #private }
OptimizingRegisterAllocator >> recalculateRegisterUsage [
	| incoming recalculated |
	currentBlock predecessors size = 0 ifTrue: [^self].
	incoming := (currentBlock predecessors
		select: [:block | usedOut includesKey: block])
		collect: [:block | usedOut at: block].
	recalculated := incoming first.
	used := recalculated select: [:assoc | assoc value isLiveAt: currentBlock].
	free := OrderedCollection new: 10.
	free
		add: abi regS;
		add: abi regT;
		add: abi regA;
		add: abi regR;
		add: abi regFP;
		removeAll: used keys
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> repairToRespectABI: messageSend with: range [
	| result clobbered receiver spillPoint |
	result := allocation at: messageSend ifAbsent: nil.
	clobbered := (used copy
		removeKey: abi regFP ifAbsent: [];
		removeKey: result ifAbsent: [];
		yourself) associations.
	spillPoint := messageSend arguments size > 0
		ifTrue: [messageSend arguments first]
		ifFalse: [messageSend].
	clobbered do: [:assoc | 
		self
			insertPush: assoc value anyDefinition before: spillPoint;
			insertPop: assoc value anyDefinition to: assoc key after: messageSend].
	receiver := allocation at: messageSend receiver.
	receiver == abi regR
		ifFalse: [self insertCopyToR: messageSend receiver before: messageSend].
	(result != nil and: [result != abi regR])
		ifTrue: [self insertCopyResultAfter: messageSend]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> reserveSpaceForLocals [
	self activationRecord temporaries: locals - 2
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> spillALiveRangeInUseAfter: instruction [
	| freed register |
	freed := self usedRangeReadLastAfter: instruction.
	locals := locals + 1.
	self splitRange: freed.
	register := self free: freed.
	^register
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> splitRange: aLiveRange [
	| real |
	real := self unifiedLiveRangeOfRange: aLiveRange.
	real definitionsWithBlocksDo: [:definition :block | 
		definition allUses
			do: [:operand | self
				insertLoadBefore: operand instruction
				at: nil
				changing: operand].
		self insertStoreAfter: definition at: block]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> unifiedLiveRangeOf: anInstruction [
	^unifiedLiveRanges
		at: anInstruction
		ifAbsent: [liveRanges at: anInstruction]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> unifiedLiveRangeOfRange: aLiveRange [
	^unifiedLiveRanges at: aLiveRange ifAbsent: [aLiveRange]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> unify: anInstruction liveRangeTo: unified [
	| range |
	range := self unifiedLiveRangeOf: anInstruction.
	range = unified ifTrue: [^self].
	unified addAll: range simpleRanges.
	unified allDefinitions
		do: [:instruction | unifiedLiveRanges at: instruction put: unified]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> use: operand from: anInstruction [
	self use: operand from: anInstruction in: currentBlock
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> use: operand from: anInstruction in: block [
	| range |
	range := self liveRangeOf: operand.
	range addUseFrom: anInstruction at: block
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> usedRangeLessAccessed [
	| ranges |
	ranges := (used copy removeKey: abi regFP) values asOrderedCollection.
	^ranges
		min: [:range | (range allDefinitions , range allUses reject: #isPhi) size]
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> usedRangeReadLast [
	| ranges |
	ranges := (used copy removeKey: abi regFP) values asOrderedCollection.
	currentBlock
		instructionsWithReversePostOrderSuccessorsDo: [:instruction | | candidate |
			candidate := ranges first.
			ranges removeAllSuchThat: [:range | 
				range allDefinitions
					anySatisfy: [:definition | instruction usesResultOf: definition]].
			ranges size = 1 ifTrue: [^ranges first].
			ranges size = 0 ifTrue: [^candidate]].
	self ASSERT: false
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> usedRangeReadLastAfter: first [
	| ranges |
	ranges := (used copy removeKey: abi regFP) values asOrderedCollection.
	currentBlock
		instructionsAfter: first
		withReversePostOrderSuccessorsDo: [:instruction | | candidate |
			candidate := ranges first.
			ranges removeAllSuchThat: [:range | range isUsedBy: instruction].
			ranges size = 1 ifTrue: [^ranges first].
			ranges size = 0 ifTrue: [^candidate]].
	^ranges first
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitBinaryWithConstant: instruction [
	self use: instruction left from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitBinaryWithVariable: instruction [
	self
		use: instruction left from: instruction;
		use: instruction right from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitJump: instruction [
	
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitJumpFalse: instruction [
	self use: instruction variable from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitJumpTrue: instruction [
	self use: instruction variable from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitLoadConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitLoadImplicit: instruction [
	
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitMessageSend: instruction [
	self
		use: instruction receiver
		from: instruction
	"instruction arguments
		do: [:operation | self use: operation from: instruction]"
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitNullary: instruction [
	
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitPhi: instruction [
	| unified |
	unified := OComposedLiveRange new.
	instruction variables do: [:source | 
		self
			use: source from: instruction;
			unify: source liveRangeTo: unified].
	self unify: instruction liveRangeTo: unified
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitReturn: instruction [
	self
		use: instruction source from: instruction;
		use: self activationRecord from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitTernary: instruction [
	self use: instruction receiver from: instruction.
	instruction left isInteger
		ifFalse: [self use: instruction left from: instruction].
	self use: instruction right from: instruction
]

{ #category : #unclassified }
OptimizingRegisterAllocator >> visitUnary: instruction [
	self use: instruction receiver from: instruction
]
