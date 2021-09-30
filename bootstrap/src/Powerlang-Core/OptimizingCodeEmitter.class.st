"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingCodeEmitter,
	#superclass : #Object,
	#instVars : [
		'allocation',
		'assembler',
		'jumpDestinations',
		'assemblers',
		'method',
		'firstBlock',
		'currentBlockIndex',
		'blocks',
		'messageLinker'
	],
	#pools : [
		'ObjectHeaderMasks',
		'ObjectHeaderOffsets'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #'instance creation' }
OptimizingCodeEmitter class >> forTarget: aNativizationTarget [
	^ self basicNew
		initialize;
		target: aNativizationTarget;
		yourself
]

{ #category : #'instance creation' }
OptimizingCodeEmitter class >> new [
	self shouldNotImplement."Use #forTarget: instead"
]

{ #category : #unclassified }
OptimizingCodeEmitter >> activationRecord [
	^firstBlock firstInstruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> allocation: anAllocation [
	allocation := anAllocation
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleAsNative: asNativeSend [
	| src dst |
	src := allocation at: asNativeSend receiver.
	dst := allocation at: asNativeSend.
	self ASSERT: src == dst.
	assembler convertToNativeInteger: src
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleAsObject: asNativeSend [
	| src dst |
	src := allocation at: asNativeSend receiver.
	dst := allocation at: asNativeSend.
	self ASSERT: src == dst.
	assembler clearIntegerBit: src
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleAsPointer: asNativeSend [
	| src dst oop |
	src := allocation at: asNativeSend receiver.
	dst := allocation at: asNativeSend.
	self ASSERT: src == dst.
	oop := assembler newLabel.
	assembler
		testIntegerBit: src;
		jumpIfZeroTo: oop;
		convertToNativeInteger: src;
		@ oop;
		setIntegerBit: src
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleAsSmallInteger: asNativeSend [
	| src dst |
	src := allocation at: asNativeSend receiver.
	dst := allocation at: asNativeSend.
	self ASSERT: src == dst.
	assembler convertToSmallInteger: src
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicAt: instruction [
	| base index result memref |
	base := allocation at: instruction left.
	index := allocation at: instruction right.
	result := allocation at: instruction.
	memref := assembler memRef: base index: index.
	assembler
		convertToNativeInteger: index;
		load: result fromMem: memref.
	result != index
		ifTrue: [ assembler convertToSmallInteger: index ]
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicAtConstant: instruction [
	| src dst index memref |
	src := allocation at: instruction left.
	dst := allocation at: instruction ifAbsent: [ ^ self ].
	index := instruction right.
	memref := assembler memRef: src indexImm: index.
	assembler load: dst fromMem: memref
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBasicAtPut: instruction [
	| base value index memref |
	index := instruction left value.
	index isInteger
		ifTrue: [ ^ self assembleBasicAtPutConstant: instruction ].
	base := allocation at: instruction receiver.
	value := allocation at: instruction right.
	index := allocation at: index.
	memref := assembler memRef: base index: index.
	assembler
		convertToNativeInteger: index;
		store: value intoMem: memref;
		convertToSmallInteger: index
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBasicAtPutConstant: instruction [
	| base value position memref |
	base := allocation at: instruction receiver.
	value := allocation at: instruction right.
	position := instruction left value.
	memref := assembler memRef: base indexImm: position.
	assembler
		store: value
		intoMem: memref
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicFlags: basicFlagsSend [
	| base dst |
	base := allocation at: basicFlagsSend receiver.
	dst := allocation at: basicFlagsSend.
	assembler
		loadZeroExtendByte: dst from: base atOffset: FlagsOffset;
		convertToSmallInteger: dst
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicFlagsPut: basicFlagsPut [
	self assembleByteAtOffset: FlagsOffset put: basicFlagsPut
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicSize: basicSizeSend [
	| base dst |
	base := allocation at: basicSizeSend receiver.
	dst := allocation at: basicSizeSend.
	assembler
		loadZeroExtendByte: dst from: base atOffset: SizeOffset;
		convertToSmallInteger: dst
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicSizePut: basicSizePut [
	self assembleByteAtOffset: SizeOffset put: basicSizePut
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicSizePutConstant: basicFlagsPutSend [
	| base value memref |

	base := allocation at: basicFlagsPutSend left.
	value := basicFlagsPutSend right.
	memref := assembler memRef8 base: base; displacement: SizeOffset.
	assembler storeImm: value intoMem: memref.

]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicULongAt: instruction [
	| base index result memref |
	base := allocation at: instruction left.
	index := allocation at: instruction right.
	result := allocation at: instruction.
	memref := assembler memRef32: base index: index.
	assembler
		convertToNativeInteger: index;
		load: result fromMem: memref.
	result != index
		ifTrue: [ assembler convertToSmallInteger: index ]
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicULongAtConstant: instruction [
	| src dst index memref |
	src := allocation at: instruction left.
	dst := allocation at: instruction ifAbsent: [ ^ self ].
	index := instruction right.
	memref := assembler memRef32: src indexImm: index.
	assembler
		load: dst
		fromMem: memref
]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicULongAtPut: instruction [
	| base value index memref |
	index := instruction left value.
	index isInteger
		ifTrue: [^self assembleBasicULongAtPutConstant: instruction].
	base := allocation at: instruction receiver.
	value := allocation at: instruction right.
	index := allocation at: index.
	memref := assembler memRef32: base index: index.
	assembler
		convertToNativeInteger: index;
		store: value intoMem: memref;
		convertToSmallInteger: index

]

{ #category : #private }
OptimizingCodeEmitter >> assembleBasicULongAtPutConstant: instruction [
	| base value position memref |
	base := allocation at: instruction receiver.
	value := allocation at: instruction right.
	position := instruction left value.
	memref := assembler memRef32: base indexImm: position.
	assembler
		store: value
		intoMem: memref
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitAnd: instruction [
	| left right |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	assembler and: left with: right
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitAndConstant: instruction [
	| left value |
	left := allocation at: instruction.
	value := instruction right * 2 + 1.
	assembler and: left withImm: value
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitOr: instruction [
	| left right |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	assembler or: left with: right
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitOrConstant: instruction [
	| left value |
	left := allocation at: instruction.
	value := instruction right * 2 + 1.
	assembler or: left with: value
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitShift: instruction [
	| src offset |
	src := allocation at: instruction left.
	instruction right isConstant
		ifTrue: [self assembleBitShift: src by: instruction right value]
		ifFalse: [
			offset := allocation at: instruction right.
			offset halt]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitShift: src by: amount [
	amount > 0
		ifTrue: [ assembler
				convertToNativeInteger: src;
				shiftLeft: src by: amount + 1;
				convertToSmallInteger: src ]
		ifFalse: [ assembler
				shiftRightArithmetic: src byImm: 0 - amount;
				setIntegerBit: src ]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleBitShiftConstant: instruction [
	| src amount |
	src := allocation at: instruction left.
	amount := instruction right.
	self assembleBitShift: src by: amount
]

{ #category : #private }
OptimizingCodeEmitter >> assembleByteAt: instruction [
	| base index dst |
	base := allocation at: instruction left.
	index := allocation at: instruction right.
	dst := allocation at: instruction.
	assembler
		convertToNativeInteger: index;
		loadZeroExtendByte: dst from: base atIndexAt: index;
		convertToSmallInteger: dst.
	index != dst ifTrue: [assembler convertToSmallInteger: index]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleByteAt: index put: instruction [
	self assembleByteAtOffset: index - 1 put: instruction
]

{ #category : #private }
OptimizingCodeEmitter >> assembleByteAtConstant: instruction [
	| base index dst |
	base := allocation at: instruction left.
	index := instruction right.
	dst := allocation at: instruction.
	assembler
		loadZeroExtendByte: dst from: base atIndexImm: index;
		convertToSmallInteger: dst
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleByteAtOffset: offset put: instruction [
	| base value |
	base := allocation at: instruction left.
	value := allocation at: instruction right.
	assembler
		convertToNativeInteger: value;
		renameByteRegisterIfNeeded: value
		preserving: base
		during: [:final | | memref |
			memref := assembler memRef8 base: base; displacement: offset.
			assembler store: final intoMem: memref.
		];
		convertToSmallInteger: value

]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleByteAtPut: instruction [
	| index base value memref |
	base := allocation at: instruction receiver.
	index := allocation at: instruction left.
	value := allocation at: instruction right.
	memref := assembler memRef8: base index: index.
	assembler
		convertToNativeInteger: index;
		convertToNativeInteger: value;
		renameByteRegisterIfNeeded: value
			preserving: base
			preserving: index
			during:
				[ :final | assembler store: final intoMem: memref ];
		convertToSmallInteger: value;
		convertToSmallInteger: index
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleCompare: instruction [
	| left right |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	assembler compare: left with: right
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleCompareConstant: instruction jumpTrue: trueBlock jumpFalse: falseBlock [
	| left  |
	left := allocation at: instruction left.
	self
		assembleCompareConstant: left with: instruction right;
		assembleJumpTrue: trueBlock orJumpFalse: falseBlock in: instruction
]

{ #category : #private }
OptimizingCodeEmitter >> assembleCompareConstant: left with: right [

	right isSmallInteger
		ifTrue: [ ^ assembler compare: left with: right * 2 + 1 ].
	right ifNil: [ ^ assembler compareWithNil: left ].
	right = false
		ifTrue: [ ^ assembler compareWithFalse: left ].
	right = true
		ifTrue: [ ^ assembler compareWithTrue: left ].
	assembler compare: left withLiteral: right
]

{ #category : #private }
OptimizingCodeEmitter >> assembleCopy: instruction [
	| source target |
	target := allocation at: instruction.
	source := allocation at: instruction receiver.
	self assembleCopyIfNeeded: source to: target
]

{ #category : #private }
OptimizingCodeEmitter >> assembleCopyIfNeeded: source to: dest [
	source = dest ifTrue: [^self].
	assembler move: source to: dest
]

{ #category : #private }
OptimizingCodeEmitter >> assembleCopyResult: instruction [
	| dest |
	dest := allocation at: instruction ifAbsent: [^self].
	self assembleCopyIfNeeded: assembler regR to: dest
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleEquals: instruction [
	self
		assembleCompare: instruction;
		assembleJumpTrue: [:label | assembler jumpIfEqualTo: label]
		orJumpFalse: [:label | assembler jumpIfNotEqualTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleEqualsConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfEqualTo: label]
		jumpFalse: [:label | assembler jumpIfNotEqualTo: label]
]

{ #category : #private }
OptimizingCodeEmitter >> assembleExtendedSize: extendedSizeSend [
	| base dst index memref |
	base := allocation at: extendedSizeSend receiver.
	dst := allocation at: extendedSizeSend.
	index := LargeSizeOffset // 4 + 1.
	memref := assembler memRef32: base indexImm: index.
	assembler
		load: dst fromMem: memref;
		convertToSmallInteger: dst
]

{ #category : #private }
OptimizingCodeEmitter >> assembleExtendedSizePut: extendedSizeSend [
	| base index value memref |
	base := allocation at: extendedSizeSend left.
	value := allocation at: extendedSizeSend right.
	index := LargeSizeOffset // 4 + 1.
	memref := assembler memRef32: base indexImm: index.
	assembler
		convertToNativeInteger: value e;
		store: value intoMem: memref;
		convertToSmallInteger: value e
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleFrom: aBasicBlock [
	| code |
	assembler reset.
	firstBlock := aBasicBlock.
	blocks := firstBlock withSuccessorsPostOrder reversed.
	self doAssemble.
	code := assembler nativeCode compiledCode: method.
	^method nativeCode: code
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleGenericMessageSend: instruction [
	self assembleLookup: instruction selector
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleGreater: instruction [
	self
		assembleCompare: instruction;
		assembleJumpTrue: [:label | assembler jumpIfGreaterSignedTo: label]
		orJumpFalse: [:label | assembler jumpIfLessOrEqualSignedTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleGreaterConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfGreaterSignedTo: label]
		jumpFalse: [:label | assembler jumpIfLessOrEqualSignedTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleGreaterEqual: instruction [
	self
		assembleCompare: instruction;
		assembleJumpTrue: [:label | assembler jumpIfGreaterOrEqualSignedTo: label]
		orJumpFalse: [:label | assembler jumpIfLessSignedTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleGreaterEqualConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfGreaterOrEqualSignedTo: label]
		jumpFalse: [:label | assembler jumpIfLessSignedTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleIsSmallInteger: instruction [
	| src |
	src := allocation at: instruction receiver.
	assembler testIntegerBit: src.
	self
		assembleJumpTrue: [:label | assembler jumpIfNotZeroTo: label]
		orJumpFalse: [:label | assembler jumpIfZeroTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleJumpIfEqualTo: target [
	| label |
	label := jumpDestinations at: target.
	assembler jumpIfEqualTo: label
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleJumpTo: target [
	| label index |
	label := jumpDestinations at: target.
	index := blocks indexOf: target.
	^((index - currentBlockIndex) abs > 18 or: true)
		ifTrue: [assembler jumpTo: label]
		ifFalse: [assembler shortJumpTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleJumpTrue: blockJumpTrue orJumpFalse: blockJumpFalse in: instruction [
	| next end result label loadFalse |
	next := instruction next.
	(next isConditionalJump and: [instruction allUses size = 1])
		ifTrue: [
			label := jumpDestinations at: next target.
			next isJumpTrue
				ifTrue: [blockJumpTrue value: label]
				ifFalse: [blockJumpFalse value: label].
			self nextBlock != next implicitTarget
				ifTrue: [self assembleJumpTo: next implicitTarget]]
		ifFalse: [
			result := allocation at: instruction.
			loadFalse := assembler newLabel.
			end := assembler newLabel.
			blockJumpFalse value: loadFalse.
			self assembleLoadConstant: true to: result.
			assembler shortJumpTo: end; @ loadFalse.
			self assembleLoadConstant: false to: result.
			assembler @ end]
]

{ #category : #private }
OptimizingCodeEmitter >> assembleLoadConstant: value to: register [
	| constant |
	value isSmallInteger
		ifTrue: [ constant := value * 2 + 1.
			^ assembler load: register withImmediate: constant ].
	value ifNil: [ ^ assembler loadWithNil: register ].
	value = false
		ifTrue: [ ^ assembler loadWithFalse: register ].
	value = true
		ifTrue: [ ^ assembler loadWithTrue: register ].
	assembler load: register withLiteral: value
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleLookup: selector [
	messageLinker emitSend: selector using: assembler
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleLower: instruction [
	self
		assembleCompare: instruction;
		assembleJumpTrue: [:label | assembler jumpIfLessSignedTo: label]
		orJumpFalse: [:label | assembler jumpIfGreaterOrEqualSignedTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleLowerConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfLessSignedTo: label]
		jumpFalse: [:label | assembler jumpIfGreaterOrEqualSignedTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleLowerEqual: instruction [
	self
		assembleCompare: instruction;
		assembleJumpTrue: [:label | assembler jumpIfLessOrEqualSignedTo: label]
		orJumpFalse: [:label | assembler jumpIfGreaterSignedTo: label]
		in: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleLowerEqualConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfLessOrEqualSignedTo: label]
		jumpFalse: [:label | assembler jumpIfGreaterSignedTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleMinus: instruction [
	| left right |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	assembler
		addImm: 1 to: left;
		sub: right from: left
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleMinusConstant: instruction [
	| left value |
	left := allocation at: instruction left.
	value := instruction right * 2.
	assembler subImm: value from: left
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleNegate: instruction [
	| src dst |
	src := allocation at: instruction receiver.
	dst := allocation at: instruction.
	self ASSERT: dst = src.
	assembler
		negate: src;
		add: 2 to: dst
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleNotEqualConstant: instruction [
	self
		assembleCompareConstant: instruction
		jumpTrue: [:label | assembler jumpIfNotEqualTo: label]
		jumpFalse: [:label | assembler jumpIfEqualTo: label]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleObjectAtOffsetPut: instruction [
	| base value offset |
	base := allocation at: instruction receiver.
	value := allocation at: instruction right.
	offset := instruction left value.
	assembler storePointer: value in: base offset: offset
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assemblePlus: instruction [
	| left right |
	left := allocation at: instruction left.
	right := allocation at: instruction right.
	assembler
		clearIntegerBit: left;
		add: right to: left
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assemblePlusConstant: instruction [
	| left value |
	left := allocation at: instruction left.
	value := instruction right * 2.
	assembler add: value to: left
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assemblePop: instruction [
	| register |
	register := allocation at: instruction.
	assembler pop: register
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assemblePush: instruction [
	| register |
	register := allocation at: instruction receiver.
	assembler push: register
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleRestorePreviousContext: instruction [
	assembler restoreCallerFrame
]

{ #category : #unclassified }
OptimizingCodeEmitter >> assembleTimesConstant: instruction [
	| left value shift |
	left := allocation at: instruction left.
	value := instruction right.
	self ASSERT: (value == 4 or: [value == 8 or: [value == 2]]).
	shift := value == 4 ifTrue: [2] ifFalse: [value == 8 ifTrue: [3] ifFalse: [1]].
	assembler
		clearIntegerBit: left;
		shiftLeft: left byImm: shift;
		setIntegerBit: left
]

{ #category : #private }
OptimizingCodeEmitter >> assembleTransferControlTo: instruction [
	| code receiver activation |
	receiver := allocation at: instruction left.
	code := allocation at: instruction right.
	receiver == assembler regA
		ifTrue: [ code == assembler regT
				ifTrue: [ assembler move: assembler regA to: assembler regR.
					receiver := assembler regR ]
				ifFalse: [ assembler move: assembler regA to: assembler regT.
					receiver := assembler regT ] ].
	self assembleCopyIfNeeded: code to: assembler regM.
	self assembleCopyIfNeeded: receiver to: assembler regR.
	activation := self activationRecord.
	(activation savesPreviousSelf and: [activation hasFrame])
		ifTrue: [assembler popS].
	assembler restoreCallerFrame; jumpToMindex: 1
]

{ #category : #unclassified }
OptimizingCodeEmitter >> currentBlock [
	^blocks at: currentBlockIndex
]

{ #category : #unclassified }
OptimizingCodeEmitter >> doAssemble [
	self labelBlocks.
	blocks withIndexDo: [:block :index | | label |
		currentBlockIndex := index.
		label := jumpDestinations at: block.
		assembler @ label.
		block firstInstruction acceptVisitor: self].
	assembler applyFixups
]

{ #category : #initialization }
OptimizingCodeEmitter >> initialize [
	jumpDestinations := Dictionary new.
	self initializeAssemblers
]

{ #category : #initialization }
OptimizingCodeEmitter >> initializeAssemblers [
	assemblers := Dictionary new
		at: #'+' put: #Plus;
		at: #'-' put: #Minus;
		at: #'*' put: #Times;
		at: #'=' put: #Equals;
		at: #'==' put: #Equals;
		at: #'~=' put: #NotEqual;
		at: #'!=' put: #NotEqual;
		at: #'<' put: #Lower;
		at: #'<=' put: #LowerEqual;
		at: #'>=' put: #GreaterEqual;
		at: #'>' put: #Greater;
		at: #'&' put: #BitAnd;
		at: #bitAnd: put: #BitAnd;
		at: #bitOr: put: #BitOr;
		at: #bitShift: put: #BitShift;
		at: #_asNative put: #AsNative;
		at: #_asObject put: #AsObject;
		at: #_asPointer put: #AsPointer;
		at: #_asSmallInteger put: #AsSmallInteger;
		at: #_byteAt: put: #ByteAt;
		at: #_basicAt: put: #BasicAt;
		at: #_basicULongAt: put: #BasicULongAt;
		at: #_byteAt:put: put: #ByteAtPut;
		at: #_basicAt:put: put: #BasicAtPut;
		at: #_basicULongAt:put: put: #BasicULongAtPut;
		at: #_objectAtOffset:put: put: #ObjectAtOffsetPut;
		at: #_basicFlags put: #BasicFlags;
		at: #_basicFlags: put: #BasicFlagsPut;
		at: #_smallSize put: #BasicSize;
		at: #_smallSize: put: #BasicSizePut;
		at: #_largeSize put: #ExtendedSize;
		at: #_largeSize: put: #ExtendedSizePut;
		at: #_isSmallInteger put: #IsSmallInteger;
		at: #_transferControlTo: put: #TransferControlTo;
		at: #negate put: #Negate;
		at: #push put: #Push;
		at: #pop put: #Pop;
		at: #copy put: #Copy;
		at: #copyResult put: #CopyResult;
		yourself
]

{ #category : #unclassified }
OptimizingCodeEmitter >> jumpWasAssembledInComparison: aConditionalJump [
	| prev |
	prev := aConditionalJump prev.
	prev == aConditionalJump variable ifFalse: [^false].
	prev allUses size != 1 ifTrue: [^false].
	prev class == OMessageSend ifTrue: [^false].
	prev class == OPhi ifTrue: [^false].
	(prev isKindOf: OBinaryOperation) ifTrue: [
		(#(< <= = == != >= >) includes: prev name) ifTrue: [^true].
		(#(_basicAt:) includes: prev name) ifTrue: [^false]].
	prev class == OUnaryOperation ifTrue: [
		(#(_isSmallInteger) includes: prev name) ifTrue: [^true].
		(#(copy) includes: prev name) ifTrue: [^false]].
	self halt
]

{ #category : #unclassified }
OptimizingCodeEmitter >> labelBlocks [
	blocks do: [:block | | label |
		label := assembler newLabel.
		jumpDestinations at: block put: label]
]

{ #category : #visiting }
OptimizingCodeEmitter >> loadMifNeeded [
				method selector == #_dispatchOn:
			ifTrue: [^assembler loadMwithGlobal: #Lookup].
		method selector == #_dispatchOn:startingAt:
			ifTrue: [^assembler loadMwithGlobal: #LookupSuper].
		method selector == #_dispatchDebuggableOn:
			ifTrue: [^assembler loadMwithGlobal: #DebuggableLookup].
		method selector == #_dispatchDebuggableOn:startingAt:
			ifTrue: [^assembler loadMwithGlobal: #DebuggableLookupSuper].

]

{ #category : #unclassified }
OptimizingCodeEmitter >> messageLinker: aMessageLinker [
	messageLinker := aMessageLinker
]

{ #category : #accessing }
OptimizingCodeEmitter >> method: anSCompiledMethod [
	method := anSCompiledMethod
]

{ #category : #unclassified }
OptimizingCodeEmitter >> nextBlock [
	^blocks at: currentBlockIndex + 1 ifAbsent: [nil]
]

{ #category : #accessing }
OptimizingCodeEmitter >> savesPreviousSelf [
	^self activationRecord savesPreviousSelf
]

{ #category : #unclassified }
OptimizingCodeEmitter >> selectorFor: instruction [
	^assemblers at: instruction name
]

{ #category : #initialization }
OptimizingCodeEmitter >> target: aNativizationTarget [
	assembler := aNativizationTarget newNativizer
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitBinaryWithConstant: instruction [
	| selector |
	selector := #assemble , (self selectorFor: instruction) , #Constant:.
	self perform: selector asSymbol with: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitBinaryWithVariable: instruction [
	| selector |
	selector := #assemble , (self selectorFor: instruction) , #':'.
	self perform: selector asSymbol with: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitBranch: branch comparing: aBoolean [
	| reg |
	(self jumpWasAssembledInComparison: branch) ifTrue: [^self].
	reg := allocation at: branch variable.
	assembler compare: reg withBoolean: aBoolean.
	self assembleJumpIfEqualTo: branch target.
	branch implicitTarget != self nextBlock
		ifTrue: [self assembleJumpTo: branch implicitTarget]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitJump: aJump [
	aJump target == self nextBlock ifTrue: [^self].
	self assembleJumpTo: aJump target
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitJumpFalse: aJumpFalse [
	self visitBranch: aJumpFalse comparing: false
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitJumpTrue: aJumpTrue [
	self visitBranch: aJumpTrue comparing: true
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitLoadConstant: aLoadConstant [
	| register value |
	register := allocation
		at: aLoadConstant
		ifAbsent: [aLoadConstant isUsed ifTrue: [self halt] ifFalse: [^self]].
	value := aLoadConstant value.
	self assembleLoadConstant: value to: register
]

{ #category : #visiting }
OptimizingCodeEmitter >> visitLoadImplicit: instruction [
	| frame receiver nativecode |
	instruction name == #activationRecord
		ifTrue: [ assembler buildFrame.
			^ self loadMifNeeded ].
	instruction name == #self
		ifFalse: [ ^ self ].
	frame := instruction prev.
	frame hasFrame
		ifFalse: [ ^ self ].
	receiver := assembler memRef: assembler regFP indexImm: 0.
	nativecode := assembler memRef: assembler regFP indexImm: -1.
	assembler
		reserveStackSlots: frame temporaries + 2;
		store: assembler regR
			intoMem: receiver;
		store: assembler regM
			intoMem: nativecode.
	self savesPreviousSelf
		ifTrue: [ assembler
				pushS;
				pushM;
				loadMwithA ]
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitMessageSend: aMessageSend [
	self assembleGenericMessageSend: aMessageSend.
	firstBlock activationRecord haveFrame
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitNullary: instruction [
	| selector |
	selector := #assemble , (self selectorFor: instruction) , #':'.
	self perform: selector asSymbol with: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitPhi: phiInstruction [
	
]

{ #category : #visiting }
OptimizingCodeEmitter >> visitReturn: aReturnInstruction [
	| source memref |
	source := allocation at: aReturnInstruction source.
	self assembleCopyIfNeeded: source to: assembler regR.
	self savesPreviousSelf
		ifTrue: [ assembler
				popM;
				popS;
				restoreCallerFrame ]
		ifFalse: [ memref := assembler memRef: assembler regFP indexImm: 0. assembler
				restoreCallerFrame;
				load: assembler regS
					fromMem: memref;
				restoreCallerM ].
	assembler return
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitTernary: instruction [
	| selector |
	selector := #assemble , (self selectorFor: instruction) , #':'.
	self perform: selector asSymbol with: instruction
]

{ #category : #unclassified }
OptimizingCodeEmitter >> visitUnary: instruction [
	| selector |
	selector := #assemble , (self selectorFor: instruction) , #':'.
	self perform: selector asSymbol with: instruction
]
