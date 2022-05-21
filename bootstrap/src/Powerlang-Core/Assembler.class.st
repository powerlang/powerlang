"
I am the JIT assembler frontend. I provide a high-level assembler interface (if that really exists)
and delegate writing of the actual bytes to my backends.
"
Class {
	#name : #Assembler,
	#superclass : #Object,
	#instVars : [
		'codegen',
		'labels',
		'literals'
	],
	#classVars : [
		'IndexedLabels'
	],
	#category : #'Powerlang-Core-Assembly'
}

{ #category : #'instance creation' }
Assembler class >> forTarget: aNativizationTarger [
	^self basicNew 
		initialize;
		target: aNativizationTarger;
		yourself.
]

{ #category : #initialization }
Assembler class >> growIndexedLabelsTo: anInteger [
	| new |
	new := (IndexedLabels size + 1 to: anInteger)
		collect: [:i | ('@' , i asString) asSymbol].
	IndexedLabels := IndexedLabels , new
]

{ #category : #initialization }
Assembler class >> initialize [
	self initializeIndexedLabels
	
]

{ #category : #initialization }
Assembler class >> initializeIndexedLabels [
	IndexedLabels := #().
	self growIndexedLabelsTo: 100
]

{ #category : #'instance creation' }
Assembler class >> new [
	^self shouldNotImplement."Use #forTaget: instead"
]

{ #category : #labels }
Assembler >> @ label [
	self addLabel: label
]

{ #category : #'operations - arithmetic' }
Assembler >> add: source1 to: source2andDest [
	codegen add: source1 to: source2andDest
]

{ #category : #arithmetic }
Assembler >> addAtoR [
	codegen add: codegen regA to: codegen regR
]

{ #category : #arithmetic }
Assembler >> addDoubleX1toX0 [
	codegen addDouble: codegen regX1 to: codegen regX0

]

{ #category : #'operations - arithmetic' }
Assembler >> addImm: imm to: dest [
	codegen addImm: imm to: dest
]

{ #category : #labels }
Assembler >> addLabel: aString [
	self addLabel: aString to: self currentAddress
]

{ #category : #labels }
Assembler >> addLabel: label to: location [
	labels at: label put: location
]

{ #category : #loading }
Assembler >> addLiteral: anObject [
	| index |
	index := literals
		identityIndexOf: anObject
		ifAbsent: [ literals
				add: anObject;
				size ].
	^ index + 2
]

{ #category : #arithmetic }
Assembler >> addRwithImmediate: imm [
	codegen addImm: imm to: codegen regR 
]

{ #category : #logic }
Assembler >> addSPwithImmediate: imm [
	codegen addImm: imm to: codegen regSP
]

{ #category : #arithmetic }
Assembler >> addTtoR [
	codegen add: codegen regT to: codegen regR
]

{ #category : #logic }
Assembler >> addTwithImmediate: imm [
	codegen addImm: imm to: codegen regT
]

{ #category : #'operations - arithmetic' }
Assembler >> alignTo: anInteger [
	codegen alignTo: anInteger
]

{ #category : #'operations - logical' }
Assembler >> and: source1andDest with: source2 [
	codegen and: source1andDest with: source2
]

{ #category : #'operations - logical' }
Assembler >> and: source1andDest withImm: imm [
	codegen and: source1andDest withImm: imm
]

{ #category : #logic }
Assembler >> andRwithA [
	codegen and: codegen regR with: codegen regA
]

{ #category : #arithmetic }
Assembler >> andRwithImmediate: imm [
	codegen and: codegen regR withImm: imm
]

{ #category : #relocation }
Assembler >> applyFixups [
	codegen memory applyFixupsWith: self
]

{ #category : #'operations - arithmetic' }
Assembler >> breakpoint [
	codegen breakpoint
]

{ #category : #private }
Assembler >> buildFrame [
	self
		push: codegen regFP;
		move: codegen regSP to: codegen regFP
]

{ #category : #private }
Assembler >> bytes [
	^codegen bytes
]

{ #category : #'operations - arithmetic' }
Assembler >> callIndirectA [
	| memref |
	memref := codegen memRef: codegen regA indexImm: 1.
	codegen callIndirect: memref
]

{ #category : #'operations - arithmetic' }
Assembler >> callIndirectM [
	| memref |
	memref := codegen memRef: codegen regM indexImm: 1.
	codegen callIndirect: memref
]

{ #category : #'operations - arithmetic' }
Assembler >> callR [
	codegen call: codegen regR
]

{ #category : #'to-cleanup' }
Assembler >> clearFPUFlags [
	codegen clearFPUFlags
]

{ #category : #'operations - arithmetic' }
Assembler >> clearIntegerBit: srcAndDstReg [
	self clearSafeIntegerBit: srcAndDstReg

]

{ #category : #'push/pop' }
Assembler >> clearRhigh32 [
	codegen clearHigh32: codegen regR

]

{ #category : #'operations - arithmetic' }
Assembler >> clearRintegerBit [
	self dec: codegen regR
]

{ #category : #'operations - arithmetic' }
Assembler >> clearSafeIntegerBit: srcAndDstReg [
	self and: srcAndDstReg withImm: -2
]

{ #category : #'operations - arithmetic' }
Assembler >> clearSafeRintegerBit [
	self clearSafeIntegerBit: codegen regR

]

{ #category : #'operations - arithmetic' }
Assembler >> compare: reg1 with: reg2 [
	codegen compare: reg1 with: reg2
]

{ #category : #comparing }
Assembler >> compare: register withBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareWithTrue: register ]
		ifFalse: [ self compareWithFalse: register ]
]

{ #category : #'operations - arithmetic' }
Assembler >> compare: register withLiteral: anObject [
	| index memref |
	index := self addLiteral: anObject.
	memref := codegen memRef: codegen regM indexImm: index.
	codegen compare: register withMem: memref
]

{ #category : #comparing }
Assembler >> compareAwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareAwithTrue ]
		ifFalse: [ self compareAwithFalse ]
]

{ #category : #'operations - arithmetic' }
Assembler >> compareAwithFalse [
	codegen compare: codegen regA with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Assembler >> compareAwithTrue [
	codegen compare: codegen regA with: codegen regTrue
]

{ #category : #'to-cleanup' }
Assembler >> compareEqualDoubleX0withAindirect [
	codegen compareEqualDoubleX0withAindirect
]

{ #category : #'to-cleanup' }
Assembler >> compareLessThanDoubleX0withAindirect [
	codegen compareLessThanDoubleX0withAindirect
]

{ #category : #'operations - arithmetic' }
Assembler >> compareRwithA [
	codegen compare: codegen regR with: codegen regA
]

{ #category : #comparing }
Assembler >> compareRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareRwithTrue ]
		ifFalse: [ self compareRwithFalse ]
]

{ #category : #'operations - arithmetic' }
Assembler >> compareRwithFalse [
	codegen compare: codegen regR with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Assembler >> compareRwithImmediate: imm [
	codegen compare: codegen regR withImm: imm
]

{ #category : #'operations - arithmetic' }
Assembler >> compareRwithNil [
	codegen compare: codegen regR with: codegen regNil
]

{ #category : #comparing }
Assembler >> compareRwithSmallInteger: anInteger [
	| smi |
	smi := self smallInteger: anInteger.
	self compareRwithImmediate: smi
]

{ #category : #'operations - arithmetic' }
Assembler >> compareRwithTrue [
	codegen compare: codegen regR with: codegen regTrue
]

{ #category : #'operations - arithmetic' }
Assembler >> compareSwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen compare: codegen regS withMem: memref
]

{ #category : #'operations - arithmetic' }
Assembler >> compareTwithA [
	codegen compare: codegen regT with: codegen regA
]

{ #category : #'operations - arithmetic' }
Assembler >> compareTwithImmediate: imm [
	codegen compare: codegen regT withImm: imm
]

{ #category : #'operations - arithmetic' }
Assembler >> compareWithFalse: register [
	codegen compare: register with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Assembler >> compareWithNil: register [
	codegen compare: register with: codegen regNil
]

{ #category : #'operations - arithmetic' }
Assembler >> compareWithTrue: register [
	codegen compare: register with: codegen regTrue
]

{ #category : #arithmetic }
Assembler >> convertAtoNativeInteger [
	self convertToNativeInteger: codegen regA
	
]

{ #category : #arithmetic }
Assembler >> convertRtoNativeInteger [
	self convertToNativeInteger: codegen regR
	
]

{ #category : #arithmetic }
Assembler >> convertRtoSmallInteger [
	self convertToSmallInteger: codegen regR
]

{ #category : #arithmetic }
Assembler >> convertToNativeInteger: srcAndDstReg [
	codegen shiftRightArithmetic: srcAndDstReg byImm: 1
]

{ #category : #arithmetic }
Assembler >> convertToSmallInteger: srcAndDstReg [ 
	self shiftLeft: srcAndDstReg byImm: 1; inc: srcAndDstReg
]

{ #category : #arithmetic }
Assembler >> convertTtoNativeInteger [
	self convertToNativeInteger: codegen regT
	
]

{ #category : #services }
Assembler >> currentAddress [
	^ codegen currentAddress
]

{ #category : #'push/pop' }
Assembler >> dec: srcAndDstReg [
	codegen dec: srcAndDstReg

]

{ #category : #private }
Assembler >> decRindirect [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen decMem: memref
]

{ #category : #private }
Assembler >> discardArguments: anInteger [
	anInteger = 0 ifTrue: [^self].
	codegen addImm: anInteger * codegen wordSize to: codegen regSP
]

{ #category : #'floting point' }
Assembler >> divideDoubleX0byX1 [
	codegen divDouble: codegen regX0 by: codegen regX1
]

{ #category : #'to-cleanup' }
Assembler >> dropTopOfFPU [
	codegen dropTopOfFPU
]

{ #category : #'push/pop' }
Assembler >> dropTos: count [
	codegen addImm: (count * codegen addressSize) to: codegen regSP

]

{ #category : #arithmetic }
Assembler >> exchangeRindirectWithT [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen exchange: codegen regT withMem: memref
]

{ #category : #storing }
Assembler >> extendRtoAandDividebyT [
	codegen divide: codegen regR extendingTo: codegen regA by: codegen regT
]

{ #category : #'push/pop' }
Assembler >> inc: srcAndDstReg [
	codegen inc: srcAndDstReg

]

{ #category : #'push/pop' }
Assembler >> initializeS [
	codegen move: codegen regR to: codegen regS
]

{ #category : #jumps }
Assembler >> jumpIfEqualTo: label [
	codegen jumpIfEqualTo: label
]

{ #category : #jumps }
Assembler >> jumpIfGreaterOrEqualSignedTo: label [
	codegen jumpIfGreaterOrEqualSignedTo: label
]

{ #category : #jumps }
Assembler >> jumpIfGreaterSignedTo: label [
	codegen jumpIfGreaterSignedTo: label
]

{ #category : #jumps }
Assembler >> jumpIfLessOrEqualSignedTo: label [
	codegen jumpIfLessOrEqualSignedTo: label
]

{ #category : #jumps }
Assembler >> jumpIfLessSignedTo: label [
	codegen jumpIfLessSignedTo: label
]

{ #category : #jumps }
Assembler >> jumpIfNotEqualTo: label [
	codegen jumpIfNotEqualTo: label
]

{ #category : #jumps }
Assembler >> jumpIfNotZeroTo: label [
	codegen jumpIfNotZeroTo: label
]

{ #category : #jumps }
Assembler >> jumpIfOverflowTo: label [
	codegen jumpIfOverflowTo: label
]

{ #category : #jumps }
Assembler >> jumpIfSignTo: label [
	codegen jumpIfSignTo: label
]

{ #category : #jumps }
Assembler >> jumpIfZeroTo: label [
	codegen jumpIfZeroTo: label
]

{ #category : #accessing }
Assembler >> jumpOver: aBlock [
	| label |
	label := self newLabel.
	self jumpTo: label.
	aBlock value.
	self @ label
]

{ #category : #accessing }
Assembler >> jumpTo: label [
	codegen jumpTo: label
]

{ #category : #accessing }
Assembler >> jumpToMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen jumpToMem: memref
]

{ #category : #integers }
Assembler >> labeledIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfZeroTo: label.
	^label
]

{ #category : #integers }
Assembler >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: codegen regR

]

{ #category : #integers }
Assembler >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: codegen regT byte
]

{ #category : #integers }
Assembler >> labeledIntegerNativizationOf: aRegister [
	| label |
	self convertToNativeInteger: aRegister.
	label := self newLabel.
	self shortJumpIfNotCarryTo: label.
	^label
]

{ #category : #integers }
Assembler >> labeledIntegerNativizationOfA [
	^self labeledIntegerNativizationOf: codegen regA
]

{ #category : #integers }
Assembler >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: codegen regR
]

{ #category : #integers }
Assembler >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: codegen regT
]

{ #category : #integers }
Assembler >> labeledNonIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfNotZeroTo: label.
	^label
]

{ #category : #integers }
Assembler >> labeledNonIntegerBitTestOfR [
	^self labeledNonIntegerBitTestOf: codegen regR

]

{ #category : #'to-cleanup' }
Assembler >> leadingRzeroCount [
	codegen leadingRzeroCount
]

{ #category : #'memory - load / store' }
Assembler >> load: dstReg fromMem: srcMemRef [
	^codegen load: dstReg fromMem: srcMemRef

]

{ #category : #loading }
Assembler >> load:dstReg withImmediate: imm [
	codegen moveImm: imm to: dstReg

]

{ #category : #loading }
Assembler >> load: register withLiteral: anObject [
	| index memref |
	index := self addLiteral: anObject.
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: register
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithFalse [
	codegen move: codegen regFalse to: codegen regA
]

{ #category : #private }
Assembler >> loadAwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadAwithGindex: index
]

{ #category : #integers }
Assembler >> loadAwithImmediate: imm [
	self load: codegen regA withImmediate: imm
]

{ #category : #arithmetic }
Assembler >> loadAwithKnown: anObject [
	codegen breakpoint
]

{ #category : #loading }
Assembler >> loadAwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadAwithMindex: index
]

{ #category : #loading }
Assembler >> loadAwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithNil [
	codegen move: codegen regNil to: codegen regA
]

{ #category : #loading }
Assembler >> loadAwithR [
	codegen move: codegen regR to: codegen regA
]

{ #category : #loading }
Assembler >> loadAwithRoffsetAtA [
	| memref |
	memref := codegen memRef
				base: codegen regR;
				index: codegen regA;
				scale: 1.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadAwithS [
	codegen move: codegen regS to: codegen regA
]

{ #category : #loading }
Assembler >> loadAwithSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #integers }
Assembler >> loadAwithSmallInteger: anInteger [
	| smi |
	smi := (anInteger bitShift: 1) + 1.
	self loadAwithImmediate: smi
]

{ #category : #loading }
Assembler >> loadAwithTrue [
	codegen move: codegen regTrue to: codegen regA
]

{ #category : #'push/pop' }
Assembler >> loadEwithAddressOfRatA [
	| memref |
	memref := codegen
		memRef: codegen regR
		index: codegen regA
		offsetImm: codegen wordSize negated.
	codegen lea: codegen regE withMem: memref
]

{ #category : #loading }
Assembler >> loadEwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regE
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadEwithNil [
	codegen move: codegen regNil to: codegen regE
]

{ #category : #loading }
Assembler >> loadEwithR [
	codegen move: codegen regR to: codegen regE
]

{ #category : #loading }
Assembler >> loadFPwithR [
	codegen move: codegen regR to: codegen regFP
]

{ #category : #loading }
Assembler >> loadFPwithSP [
	codegen move: codegen regSP to: codegen regFP
]

{ #category : #loading }
Assembler >> loadFalseWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadFalseWithMindex: index
]

{ #category : #loading }
Assembler >> loadFalseWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regFalse
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
Assembler >> loadGwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regG
		fromMem: memref
]

{ #category : #'push/pop' }
Assembler >> loadLargeX0withRindirect [
	| memref |
	memref := codegen memRef64: codegen regR indexImm: 1.
	codegen loadDouble: codegen regX0 fromMem: memref
]

{ #category : #'push/pop' }
Assembler >> loadLargeX1withAindirect [
	| memref |
	memref := codegen memRef64: codegen regA indexImm: 1.
	codegen loadDouble: codegen regX1 fromMem: memref
]

{ #category : #'to-cleanup' }
Assembler >> loadLongMwithIPoffset: anInteger [
	codegen loadLongMwithIPoffset: anInteger
]

{ #category : #'push/pop' }
Assembler >> loadLongRwithRatOffsetA [
	| memref |
	memref := codegen
		memRef32: codegen regR
		offset: codegen regA.
	codegen load: codegen regR fromMem: memref

]

{ #category : #'push/pop' }
Assembler >> loadLongSwithRindex: index [
	| memref |
	memref := codegen memRef32: codegen regR indexImm: index.
	codegen load: codegen regS fromMem: memref

]

{ #category : #'to-cleanup' }
Assembler >> loadMXCSRfromA [
	codegen loadMXCSRfromA
]

{ #category : #'push/pop' }
Assembler >> loadMwithA [
	codegen move: codegen regA to: codegen regM
]

{ #category : #loading }
Assembler >> loadMwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #private }
Assembler >> loadMwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadMwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadMwithGindex: index
]

{ #category : #loading }
Assembler >> loadMwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadMwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadMwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
Assembler >> loadNilWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regNil
		fromMem: memref
]

{ #category : #'push/pop' }
Assembler >> loadRconvertingDoublePointedByR [
	| memref |
	memref := codegen memRef64: codegen regR indexImm: 1.
	codegen load: codegen regR convertingDoubleToIntegerFromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithA [
	codegen move: codegen regA to: codegen regR
]

{ #category : #'push/pop' }
Assembler >> loadRwithArgPointer [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: 3.
	codegen lea: codegen regR withMem: memref
]

{ #category : #loading }
Assembler >> loadRwithE [
	codegen move: codegen regE to: codegen regR
]

{ #category : #loading }
Assembler >> loadRwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithFP [
	codegen move: codegen regFP to: codegen regR
]

{ #category : #loading }
Assembler >> loadRwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithFalse [
	codegen move: codegen regFalse to: codegen regR
]

{ #category : #integers }
Assembler >> loadRwithImmediate: imm [
	self load: codegen regR withImmediate: imm
]

{ #category : #loading }
Assembler >> loadRwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadRwithMindex: index
]

{ #category : #loading }
Assembler >> loadRwithM [
	codegen move: codegen regM to: codegen regR
]

{ #category : #loading }
Assembler >> loadRwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithNil [
	codegen move: codegen regNil to: codegen regR
]

{ #category : #integers }
Assembler >> loadRwithRatA [
	| memref |
	memref := codegen memRef: codegen regR index: codegen regA.
	self
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithRatOffsetA [
	| memref |
	memref := codegen memRef
				base: codegen regR;
				index: codegen regA;
				scale: 1.
	codegen
		load: codegen regR
		fromMem:
			memref
]

{ #category : #loading }
Assembler >> loadRwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithS [
	codegen move: codegen regS to: codegen regR
]

{ #category : #loading }
Assembler >> loadRwithSPindex: index [
	| memref |
	memref := codegen memRef: codegen regSP indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadRwithSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #integers }
Assembler >> loadRwithSmallInteger: anInteger [
	| smi |
	smi := self smallInteger: anInteger.
	self loadRwithImmediate: smi
]

{ #category : #loading }
Assembler >> loadRwithT [
	codegen move: codegen regT to: codegen regR
]

{ #category : #'floting point' }
Assembler >> loadRwithTIBatR [
	codegen load: codegen regR withTIBat: codegen regR
]

{ #category : #'floting point' }
Assembler >> loadRwithThreadVariableAtR [
	codegen load: codegen regR withThreadVariableAt: codegen regR
]

{ #category : #loading }
Assembler >> loadRwithTrue [
	codegen move: codegen regTrue to: codegen regR
]

{ #category : #loading }
Assembler >> loadSPwithFP [
	codegen move: codegen regFP to: codegen regSP
]

{ #category : #'push/pop' }
Assembler >> loadSwithAddressOfSatA [
	| memref |
	memref := codegen
		memRef: codegen regS
		index: codegen regA
		offsetImm: codegen wordSize negated.
	codegen lea: codegen regS withMem: memref
]

{ #category : #loading }
Assembler >> loadSwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #private }
Assembler >> loadSwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadSwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadSwithGindex: index
]

{ #category : #loading }
Assembler >> loadSwithNil [
	codegen move: codegen regNil to: codegen regS
]

{ #category : #loading }
Assembler >> loadSwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
Assembler >> loadTrueWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regTrue
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadTwithA [
	codegen move: codegen regA to: codegen regT
]

{ #category : #loading }
Assembler >> loadTwithAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadTwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadTwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #integers }
Assembler >> loadTwithImmediate: imm [
	self load: codegen regT withImmediate: imm
]

{ #category : #loading }
Assembler >> loadTwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTwithMindex: index
]

{ #category : #loading }
Assembler >> loadTwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Assembler >> loadTwithR [
	codegen move: codegen regR to: codegen regT
]

{ #category : #loading }
Assembler >> loadTwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen load: codegen regT fromMem: memref
]

{ #category : #loading }
Assembler >> loadWithFalse: register [ 
	codegen move: codegen regFalse to: register
]

{ #category : #loading }
Assembler >> loadWithNil: register [ 
	codegen move: codegen regNil to: register
]

{ #category : #loading }
Assembler >> loadWithTrue: register [ 
	codegen move: codegen regTrue to: register
]

{ #category : #'push/pop' }
Assembler >> loadX0withRasDouble [
	codegen convert: codegen regR toDouble: codegen regX0
]

{ #category : #'to-cleanup' }
Assembler >> loadZeroExtendByte: dstReg from: srcBaseReg atIndexAt: srcIndexReg [
	codegen loadZeroExtendByte: dstReg from: srcBaseReg atIndexAt: srcIndexReg

]

{ #category : #'to-cleanup' }
Assembler >> loadZeroExtendByte: dstReg from: srcBaseReg atIndexImm: indexImm [

	codegen
		loadZeroExtendByte: dstReg
		from: srcBaseReg
		atIndexImm: indexImm
]

{ #category : #jumps }
Assembler >> loadZeroExtendByte: reg1 from: reg2 atOffset: offset [
	codegen loadZeroExtendByte: reg1 from: reg2 atOffset: offset
]

{ #category : #integers }
Assembler >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: codegen regR from: codegen regR atIndexAt: codegen regA
]

{ #category : #integers }
Assembler >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: codegen regR from: codegen regR atIndexImm: index
]

{ #category : #integers }
Assembler >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: codegen regR from: codegen regSP atIndexAt: codegen regA
]

{ #category : #integers }
Assembler >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: codegen regT from: codegen regA atIndexImm: index
]

{ #category : #integers }
Assembler >> loadZeroExtendLongRwithRatA [
	| memref |
	memref := codegen memRef32: codegen regR index: codegen regA.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #integers }
Assembler >> loadZeroExtendLongRwithRindex: index [
	| memref |
	#dontOptimize.
	memref := codegen memRef32: codegen regR indexImm: index.
	codegen
		load: codegen regR e
		fromMem: memref
]

{ #category : #'to-cleanup' }
Assembler >> loadZeroExtendShortRwithRoffset: offset [
	codegen
		loadZeroExtendShortRwithRoffset: offset
]

{ #category : #'to-cleanup' }
Assembler >> lock [
	codegen lock
]

{ #category : #jumps }
Assembler >> loop: aBlock times: anInteger [
	| loop |
	loop := self newLabel.
	self loadTwithImmediate: anInteger; @ loop.
	aBlock value.
	self dec: codegen regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
Assembler >> loopTtimes: aBlock [
	| loop end |
	loop := self newLabel.
	end := self newLabel.
	self
		compareTwithImmediate: 0;
		@ loop;
		shortJumpIfEqualTo: end.
	aBlock value.
	self
		dec: codegen regT;
		shortJumpTo: loop;
		@ end
]

{ #category : #memory }
Assembler >> memRef [
	"Return clean instance of pointer-sized memory reference"

	^ codegen memRef

]

{ #category : #memory }
Assembler >> memRef32: baseReg indexImm: indexImm [
	^ codegen memRef32: baseReg indexImm: indexImm
]

{ #category : #memory }
Assembler >> memRef8 [
	"Return clean instance of byte-sized memory reference"

	^ codegen memRef8
]

{ #category : #memory }
Assembler >> memRef8: baseReg index: indexReg [
	^ codegen memRef8: baseReg index: indexReg
]

{ #category : #memory }
Assembler >> memRef: baseReg index: indexReg [
	^ codegen memRef: baseReg index: indexReg
]

{ #category : #memory }
Assembler >> memRef: baseReg indexImm: indexImm [
	^ codegen memRef: baseReg indexImm: indexImm
]

{ #category : #services }
Assembler >> move: srcReg to: dstReg [
	^ codegen move: srcReg to: dstReg

]

{ #category : #services }
Assembler >> moveImm: imm to: dstReg [
	codegen moveImm: imm to: dstReg

]

{ #category : #'to-cleanup' }
Assembler >> moveTslots [
	codegen moveTslots
]

{ #category : #'floting point' }
Assembler >> moveX0toR [
	codegen moveDouble: codegen regX0 into: codegen regR
]

{ #category : #'floting point' }
Assembler >> multiplyDoubleX0byX1 [
	codegen mulDouble: codegen regX0 by: codegen regX1
]

{ #category : #storing }
Assembler >> multiplyRbyAwideningToA [
	codegen
		multiply: codegen regR
		by: codegen regA
		wideningTo: codegen regA
]

{ #category : #arithmetic }
Assembler >> nativeCode [
	^(NativeCode withAll: literals) code: codegen memory bytes
]

{ #category : #labels }
Assembler >> newLabel [
	| label next |
	next := labels size + 1.
	IndexedLabels size < next ifTrue: [self class growIndexedLabelsTo: next].
	label := IndexedLabels at: next.
	self addLabel: label to: nil.
	^label
]

{ #category : #'operations - logical' }
Assembler >> or: src1AndDst with: src2 [
	^ codegen or: src1AndDst with: src2
]

{ #category : #'operations - logical' }
Assembler >> or: source1andDest withImm: imm [
	codegen or: source1andDest withImm: imm
]

{ #category : #logic }
Assembler >> orRwithA [
	codegen or: codegen regR with: codegen regA

]

{ #category : #private }
Assembler >> pop: dstReg [
	codegen pop: dstReg
]

{ #category : #'push/pop' }
Assembler >> popA [
	codegen pop: codegen regA
]

{ #category : #'push/pop' }
Assembler >> popE [
	codegen pop: codegen regE
]

{ #category : #'push/pop' }
Assembler >> popFP [
	codegen pop: codegen regFP
]

{ #category : #'push/pop' }
Assembler >> popFalse [
	codegen pop: codegen regFalse
]

{ #category : #'push/pop' }
Assembler >> popG [
	codegen pop: codegen regG
]

{ #category : #'push/pop' }
Assembler >> popM [
	codegen pop: codegen regM
]

{ #category : #'push/pop' }
Assembler >> popNil [
	codegen pop: codegen regNil
]

{ #category : #'push/pop' }
Assembler >> popR [
	codegen pop: codegen regR
]

{ #category : #'push/pop' }
Assembler >> popS [
	codegen pop: codegen regS
]

{ #category : #'operations - arithmetic' }
Assembler >> popSPindirect [
	| memref |
	memref := codegen memRef: codegen regSP indexImm: 1.
	codegen popIntoMem: memref
]

{ #category : #'push/pop' }
Assembler >> popT [
	codegen pop: codegen regT
]

{ #category : #'push/pop' }
Assembler >> popTrue [
	codegen pop: codegen regTrue
]

{ #category : #private }
Assembler >> push: srcReg [
	codegen push: srcReg

]

{ #category : #'push/pop' }
Assembler >> pushA [
	codegen push: codegen regA
]

{ #category : #'floting point' }
Assembler >> pushAatToffset: offset [
	| memref |
	memref := codegen memRef: codegen regA index: codegen regT.
	memref displacement: offset.
	codegen pushMem: memref
]

{ #category : #'push/pop' }
Assembler >> pushE [
	codegen push: codegen regE
]

{ #category : #'push/pop' }
Assembler >> pushFP [
	codegen push: codegen regFP
]

{ #category : #'push/pop' }
Assembler >> pushFalse [
	codegen push: codegen regFalse
]

{ #category : #'push/pop' }
Assembler >> pushG [
	codegen push: codegen regG
]

{ #category : #private }
Assembler >> pushImm: imm [
	codegen pushImm: imm

]

{ #category : #private }
Assembler >> pushIndirectR [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen pushMem: memref
]

{ #category : #'push/pop' }
Assembler >> pushM [
	codegen push: codegen regM
]

{ #category : #'push/pop' }
Assembler >> pushNil [
	codegen push: codegen regNil
]

{ #category : #'push/pop' }
Assembler >> pushR [
	codegen push: codegen regR
]

{ #category : #'push/pop' }
Assembler >> pushS [
	codegen push: codegen regS
]

{ #category : #arithmetic }
Assembler >> pushSmallInteger: integer [
	| smi |
	smi := self smallInteger: integer.
	self pushImm: smi
]

{ #category : #'push/pop' }
Assembler >> pushT [
	codegen push: codegen regT
]

{ #category : #'push/pop' }
Assembler >> pushTrue [
	codegen push: codegen regTrue
]

{ #category : #'to-cleanup' }
Assembler >> readFPUStatusOnA [
	codegen readFPUStatusOnA
]

{ #category : #'registers - IR' }
Assembler >> regA [
	^codegen regA

]

{ #category : #'registers - IR' }
Assembler >> regA8 [
	^ codegen regA byte

]

{ #category : #'registers - IR' }
Assembler >> regE [
	^ codegen regE
]

{ #category : #'registers - IR' }
Assembler >> regFP [
	^ codegen regFP

]

{ #category : #'registers - IR' }
Assembler >> regFalse [
	^ codegen regFalse

]

{ #category : #'registers - IR' }
Assembler >> regG [
	^ codegen regG

]

{ #category : #'registers - IR' }
Assembler >> regIP [
	^ codegen regIP

]

{ #category : #'registers - IR' }
Assembler >> regM [
	^ codegen regM

]

{ #category : #'registers - IR' }
Assembler >> regNil [
	^ codegen regNil

]

{ #category : #'registers - IR' }
Assembler >> regR [
	^ codegen regR

]

{ #category : #'registers - IR' }
Assembler >> regR8 [
	^ codegen regR byte

]

{ #category : #'registers - IR' }
Assembler >> regS [
	^ codegen regS
]

{ #category : #'registers - IR' }
Assembler >> regSP [
	^ codegen regSP

]

{ #category : #'registers - IR' }
Assembler >> regT [
	^ codegen regT
]

{ #category : #'registers - IR' }
Assembler >> regT8 [
	^ codegen reg byte
]

{ #category : #'registers - IR' }
Assembler >> regTrue [
	^ codegen regTrue

]

{ #category : #'registers - IR' }
Assembler >> regV [
	^ codegen regV

]

{ #category : #'registers - IR' }
Assembler >> regX0 [
	"IEEE 754 double register"
	^ codegen regX0

]

{ #category : #'registers - IR' }
Assembler >> regX1 [
	"IEEE 754 double register"
	^ codegen regX1
]

{ #category : #jumps }
Assembler >> renameByteRegisterIfNeeded: register preserving: preserved during: aBlock [
	codegen renameByteRegisterIfNeeded: register preserving: preserved during: aBlock
]

{ #category : #'floting point' }
Assembler >> renameByteRegisterIfNeeded: register preserving: preserved1 preserving: preserved2 during: aBlock [
	codegen renameByteRegisterIfNeeded: register preserving: preserved1 preserving: preserved2 during: aBlock
]

{ #category : #loading }
Assembler >> reserveStackSlots: amount [
	codegen subImm: amount * codegen addressSize from: codegen regSP
]

{ #category : #initialization }
Assembler >> reset [
	labels := Dictionary new: 100.
	literals := OrderedCollection new.
	codegen reset
]

{ #category : #labels }
Assembler >> resolveLabel: aString [
	^labels at: aString
]

{ #category : #epilogue }
Assembler >> restoreCallerEnvironment [
	self loadEwithFPindex: -2
]

{ #category : #epilogue }
Assembler >> restoreCallerFrame [
	codegen
		move: codegen regFP to: codegen regSP;
		pop: codegen regFP
]

{ #category : #epilogue }
Assembler >> restoreCallerM [
	self loadMwithFPindex: -1
]

{ #category : #epilogue }
Assembler >> restoreCallerSelf [
	self loadSwithFPindex: 0
]

{ #category : #jumps }
Assembler >> return [
	codegen return
]

{ #category : #'floting point' }
Assembler >> roundDoubleX0intoX1 [
	codegen roundDouble: codegen regX0 into: codegen regX1
]

{ #category : #loading }
Assembler >> saveCallerFrame [
	self pushFP; loadFPwithSP
]

{ #category : #'to-cleanup' }
Assembler >> scaleFloatOnRWithA [
	codegen scaleFloatOnRWithA
]

{ #category : #arithmetic }
Assembler >> setIntegerBit: srcAndDstReg [
	self setSafeIntegerBit: srcAndDstReg
]

{ #category : #arithmetic }
Assembler >> setRintegerBit [
	self setIntegerBit: codegen regR

]

{ #category : #arithmetic }
Assembler >> setSafeIntegerBit: srcAndDstReg [
	self or: srcAndDstReg withImm: 1
]

{ #category : #arithmetic }
Assembler >> setSafeRintegerBit [
	self setSafeIntegerBit: codegen regR

]

{ #category : #'operations - logical' }
Assembler >> shiftLeft: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Assembler >> shiftLeft: srcAndDst byImm: count [
	codegen shiftLeft: srcAndDst byImm: count
]

{ #category : #arithmetic }
Assembler >> shiftLeftRwithT [
	codegen shiftLeft: codegen regR by: codegen regT

]

{ #category : #arithmetic }
Assembler >> shiftLogicalRright: count [
	codegen shiftRight: codegen regR byImm: count

]

{ #category : #'operations - logical' }
Assembler >> shiftRight: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Assembler >> shiftRight: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Assembler >> shiftRightArithmetic: srcAndDst by: countReg [
	codegen shiftRightArithmetic: srcAndDst by: countReg
]

{ #category : #'operations - logical' }
Assembler >> shiftRightArithmetic: srcAndDst byImm: count [
	codegen shiftRightArithmetic: srcAndDst byImm: count

]

{ #category : #arithmetic }
Assembler >> shiftRightRwithT [
	codegen shiftRightArithmetic: codegen regR by: codegen regT

]

{ #category : #arithmetic }
Assembler >> shiftRleft: count [
	 codegen shiftLeft: codegen regR byImm: count

]

{ #category : #arithmetic }
Assembler >> shiftRright: count [
	codegen shiftRightArithmetic: codegen regR byImm: count

]

{ #category : #arithmetic }
Assembler >> shiftTright: count [
	codegen shiftRightArithmetic: codegen regT byImm: count

]

{ #category : #jumps }
Assembler >> shortJumpIfCarryTo: label [
	codegen shortJumpIfCarryTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfEqualTo: label [
	codegen shortJumpIfEqualTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfNotCarryTo: label [
	codegen shortJumpIfNotCarryTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfNotEqualTo: label [
	codegen shortJumpIfNotEqualTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfNotZeroTo: label [
	self shortJumpIfNotEqualTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfSignTo: label [
	codegen shortJumpIfSignTo: label
]

{ #category : #jumps }
Assembler >> shortJumpIfZeroTo: label [
	self shortJumpIfEqualTo: label
]

{ #category : #jumps }
Assembler >> shortJumpTo: label [
	codegen shortJumpTo: label
]

{ #category : #comparing }
Assembler >> smallInteger: anInteger [
	^(anInteger bitShift: 1) + 1
]

{ #category : #'floting point' }
Assembler >> sqrtDoubleX0 [
	codegen sqrtDouble: codegen regX0 into: codegen regX0
]

{ #category : #'memory - load / store' }
Assembler >> store: srcReg intoMem: dstMemRef [
	^ codegen store: srcReg intoMem: dstMemRef
]

{ #category : #'floting point' }
Assembler >> storeAinThreadVariableAtIndexR [
	codegen store: codegen regA intoThreadVariableAt: codegen regR
]

{ #category : #storing }
Assembler >> storeAinTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		store: codegen regA
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeByteAinRindex: index [
	| memref |
	memref := codegen memRef8: codegen regR indexImm: index.
	codegen store: codegen regA byte intoMem: memref
]

{ #category : #storing }
Assembler >> storeByteTinRatA [
	| memref |
	memref := codegen memRef8: codegen regR index: codegen regA.
	codegen store: codegen regT byte intoMem: memref
]

{ #category : #'floting point' }
Assembler >> storeDoubleResultInRindirect [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen storeDoubleResultIntoMem:  memref
]

{ #category : #storing }
Assembler >> storeEinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regE
		intoMem: memref
]

{ #category : #'memory - load / store' }
Assembler >> storeImm: imm intoMem: dstMemRef [
	"Store constant into memory location `dstMemRef`. 

	 The size of data loaded is specified in `dstMemRef`"

	self
		moveImm: imm to: self regV;
		store: self regV intoMem: dstMemRef
]

{ #category : #storing }
Assembler >> storeLargeX0inA [
	| memref |
	memref := codegen memRef64: codegen regA indexImm: 1.
	codegen storeDouble: codegen regX0 intoMem: memref
		

]

{ #category : #storing }
Assembler >> storeLargeX0inT [
	| memref |
	memref := codegen memRef64: codegen regT indexImm: 1.
	codegen storeDouble: codegen regX0 intoMem: memref
		

]

{ #category : #storing }
Assembler >> storeLongTinRatA [
	| memref |
	memref := codegen memRef32: codegen regR index: codegen regA.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeLongTinRatOffsetA [
	| memref |
	memref := codegen memRef32: codegen regR offset: codegen regA.
	codegen store: codegen regT long intoMem: memref
]

{ #category : #'to-cleanup' }
Assembler >> storeMXCSRintoA [
	codegen storeMXCSRintoA

]

{ #category : #storing }
Assembler >> storeRinAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeRinEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeRinFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeRinSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeRinTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeShortAinRoffset: offset [
	|  memref |
	memref := codegen memRef16: codegen regR offsetImm: offset.
	codegen store: codegen regA short intoMem: memref
]

{ #category : #storing }
Assembler >> storeShortTinRatOffsetA [
	| memref |
	memref := codegen memRef16: codegen regR offset: codegen regA.
	codegen store: codegen regT short intoMem: memref
]

{ #category : #storing }
Assembler >> storeSinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regS
		intoMem: memref
]

{ #category : #'floting point' }
Assembler >> storeTIBatRwithA [
	codegen store: codegen regA intoTIBat: codegen regR
]

{ #category : #storing }
Assembler >> storeTinRatA [
	| memref |
	memref := codegen memRef: codegen regR index: codegen regA.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #storing }
Assembler >> storeTinRatOffsetA [
	| memref |
	memref := codegen memRef: codegen regR offset: codegen regA.
	codegen store: codegen regT intoMem: memref
]

{ #category : #storing }
Assembler >> storeTinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #'operations - arithmetic' }
Assembler >> sub: src2 from: src1AndDst [
	codegen sub: src2  from: src1AndDst

]

{ #category : #arithmetic }
Assembler >> subAfromR [
	codegen sub: codegen regA from: codegen regR

]

{ #category : #arithmetic }
Assembler >> subAfromT [
	codegen sub: codegen regA from: codegen regT    

]

{ #category : #'floting point' }
Assembler >> subDoubleX1fromX0 [
	codegen subDouble: codegen regX1 from: codegen regX0
]

{ #category : #arithmetic }
Assembler >> subFromRconstant: imm [
	codegen subImm: imm from: codegen regR

]

{ #category : #'operations - arithmetic' }
Assembler >> subImm: imm from: srcAndDst [
	codegen subImm: imm from: srcAndDst

]

{ #category : #'to-cleanup' }
Assembler >> subTslotsToSP [
	codegen subTslotsToSP
]

{ #category : #initialization }
Assembler >> target: aNativizationTarget [
	codegen := aNativizationTarget newCodeGenerator.
	self reset
]

{ #category : #loading }
Assembler >> testIntegerBit: aRegister [
	codegen testIntegerBit: aRegister
]

{ #category : #loading }
Assembler >> testIntegerBitOf: aRegister [
	codegen test: aRegister byte withImm: 1
]

{ #category : #loading }
Assembler >> testRintegerBit [
	codegen test: codegen regR byte withImm: 1
]

{ #category : #loading }
Assembler >> testRwithR [
	codegen test: codegen regR with: codegen regR
]

{ #category : #services }
Assembler >> wordSize [
	^codegen wordSize
]

{ #category : #'to-cleanup' }
Assembler >> writeTslots [
	codegen writeTslots
]

{ #category : #'operations - logical' }
Assembler >> xor: src1AndDst with: src2 [
	^ self subclassResponsibility

]

{ #category : #logic }
Assembler >> xorAwithR [
	codegen xor: codegen regA with: codegen regR

]

{ #category : #logic }
Assembler >> xorFPwithFP [
	codegen xor: codegen regFP with: codegen regFP

]

{ #category : #logic }
Assembler >> xorRwithA [
	codegen xor: codegen regR with: codegen regA

]
