"
I am the JIT assembler frontend. I provide a high-level assembler interface (if that really exists)
and delegate writing of the actual bytes to my backends.
"
Class {
	#name : #Nativizer,
	#superclass : #Object,
	#instVars : [
		'codegen',
		'labels',
		'literals'
	],
	#classVars : [
		'IndexedLabels'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #'instance creation' }
Nativizer class >> forTarget: aNativizationTarger [
	^self basicNew 
		initialize;
		target: aNativizationTarger;
		yourself.
]

{ #category : #initialization }
Nativizer class >> growIndexedLabelsTo: anInteger [
	| new |
	new := (IndexedLabels size + 1 to: anInteger)
		collect: [:i | ('@' , i asString) asSymbol].
	IndexedLabels := IndexedLabels , new
]

{ #category : #initialization }
Nativizer class >> initialize [
	self initializeIndexedLabels
	
]

{ #category : #initialization }
Nativizer class >> initializeIndexedLabels [
	IndexedLabels := #().
	self growIndexedLabelsTo: 100
]

{ #category : #'instance creation' }
Nativizer class >> new [
	^self shouldNotImplement."Use #forTaget: instead"
]

{ #category : #labels }
Nativizer >> @ label [
	self addLabel: label
]

{ #category : #'operations - arithmetic' }
Nativizer >> add: source1 to: source2andDest [
	codegen add: source1 to: source2andDest
]

{ #category : #arithmetic }
Nativizer >> addAtoR [
	codegen add: codegen regA to: codegen regR
]

{ #category : #arithmetic }
Nativizer >> addDoubleX1toX0 [
	codegen addDouble: codegen regX1 to: codegen regX0

]

{ #category : #'operations - arithmetic' }
Nativizer >> addImm: imm to: dest [
	codegen addImm: imm to: dest
]

{ #category : #labels }
Nativizer >> addLabel: aString [
	self addLabel: aString to: self currentAddress
]

{ #category : #labels }
Nativizer >> addLabel: label to: location [
	labels at: label put: location
]

{ #category : #loading }
Nativizer >> addLiteral: anObject [
	| index |
	index := literals
		identityIndexOf: anObject
		ifAbsent: [ literals
				add: anObject;
				size ].
	^ index + 2
]

{ #category : #arithmetic }
Nativizer >> addRwithImmediate: imm [
	codegen addImm: imm to: codegen regR 
]

{ #category : #logic }
Nativizer >> addSPwithImmediate: imm [
	codegen addImm: imm to: codegen regSP
]

{ #category : #arithmetic }
Nativizer >> addTtoR [
	codegen add: codegen regT to: codegen regR
]

{ #category : #logic }
Nativizer >> addTwithImmediate: imm [
	codegen addImm: imm to: codegen regT
]

{ #category : #'operations - arithmetic' }
Nativizer >> alignTo: anInteger [
	codegen alignTo: anInteger
]

{ #category : #'operations - logical' }
Nativizer >> and: source1andDest with: source2 [
	codegen and: source1andDest with: source2
]

{ #category : #'operations - logical' }
Nativizer >> and: source1andDest withImm: imm [
	codegen and: source1andDest withImm: imm
]

{ #category : #logic }
Nativizer >> andRwithA [
	codegen and: codegen regR with: codegen regA
]

{ #category : #arithmetic }
Nativizer >> andRwithImmediate: imm [
	codegen and: codegen regR withImm: imm
]

{ #category : #relocation }
Nativizer >> applyFixups [
	codegen memory applyFixupsWith: self
]

{ #category : #'operations - arithmetic' }
Nativizer >> breakpoint [
	codegen breakpoint
]

{ #category : #private }
Nativizer >> buildFrame [
	self
		push: codegen regFP;
		move: codegen regSP to: codegen regFP
]

{ #category : #private }
Nativizer >> bytes [
	^codegen bytes
]

{ #category : #'operations - arithmetic' }
Nativizer >> callIndirectA [
	| memref |
	memref := codegen memRef: codegen regA indexImm: 1.
	codegen callIndirect: memref
]

{ #category : #'operations - arithmetic' }
Nativizer >> callIndirectM [
	| memref |
	memref := codegen memRef: codegen regM indexImm: 1.
	codegen callIndirect: memref
]

{ #category : #'operations - arithmetic' }
Nativizer >> callR [
	codegen call: codegen regR
]

{ #category : #'to-cleanup' }
Nativizer >> clearFPUFlags [
	codegen clearFPUFlags
]

{ #category : #'operations - arithmetic' }
Nativizer >> clearIntegerBit: srcAndDstReg [
	self clearSafeIntegerBit: srcAndDstReg

]

{ #category : #'push/pop' }
Nativizer >> clearRhigh32 [
	codegen clearHigh32: codegen regR

]

{ #category : #'operations - arithmetic' }
Nativizer >> clearRintegerBit [
	self dec: codegen regR
]

{ #category : #'operations - arithmetic' }
Nativizer >> clearSafeIntegerBit: srcAndDstReg [
	self and: srcAndDstReg withImm: -2
]

{ #category : #'operations - arithmetic' }
Nativizer >> clearSafeRintegerBit [
	self clearSafeIntegerBit: codegen regR

]

{ #category : #'operations - arithmetic' }
Nativizer >> compare: reg1 with: reg2 [
	codegen compare: reg1 with: reg2
]

{ #category : #comparing }
Nativizer >> compare: register withBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareWithTrue: register ]
		ifFalse: [ self compareWithFalse: register ]
]

{ #category : #'operations - arithmetic' }
Nativizer >> compare: register withLiteral: anObject [
	| index memref |
	index := self addLiteral: anObject.
	memref := codegen memRef: codegen regM indexImm: index.
	codegen compare: register withMem: memref
]

{ #category : #comparing }
Nativizer >> compareAwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareAwithTrue ]
		ifFalse: [ self compareAwithFalse ]
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareAwithFalse [
	codegen compare: codegen regA with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareAwithTrue [
	codegen compare: codegen regA with: codegen regTrue
]

{ #category : #'to-cleanup' }
Nativizer >> compareEqualDoubleX0withAindirect [
	codegen compareEqualDoubleX0withAindirect
]

{ #category : #'to-cleanup' }
Nativizer >> compareLessThanDoubleX0withAindirect [
	codegen compareLessThanDoubleX0withAindirect
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareRwithA [
	codegen compare: codegen regR with: codegen regA
]

{ #category : #comparing }
Nativizer >> compareRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareRwithTrue ]
		ifFalse: [ self compareRwithFalse ]
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareRwithFalse [
	codegen compare: codegen regR with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareRwithImmediate: imm [
	codegen compare: codegen regR withImm: imm
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareRwithNil [
	codegen compare: codegen regR with: codegen regNil
]

{ #category : #comparing }
Nativizer >> compareRwithSmallInteger: anInteger [
	| smi |
	smi := self smallInteger: anInteger.
	self compareRwithImmediate: smi
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareRwithTrue [
	codegen compare: codegen regR with: codegen regTrue
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareSwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen compare: codegen regS withMem: memref
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareTwithA [
	codegen compare: codegen regT with: codegen regA
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareTwithImmediate: imm [
	codegen compare: codegen regT withImm: imm
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareWithFalse: register [
	codegen compare: register with: codegen regFalse
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareWithNil: register [
	codegen compare: register with: codegen regNil
]

{ #category : #'operations - arithmetic' }
Nativizer >> compareWithTrue: register [
	codegen compare: register with: codegen regTrue
]

{ #category : #arithmetic }
Nativizer >> convertAtoNativeInteger [
	self convertToNativeInteger: codegen regA
	
]

{ #category : #arithmetic }
Nativizer >> convertRtoNativeInteger [
	self convertToNativeInteger: codegen regR
	
]

{ #category : #arithmetic }
Nativizer >> convertRtoSmallInteger [
	self convertToSmallInteger: codegen regR
]

{ #category : #arithmetic }
Nativizer >> convertToNativeInteger: srcAndDstReg [
	codegen shiftRightArithmetic: srcAndDstReg byImm: 1
]

{ #category : #arithmetic }
Nativizer >> convertToSmallInteger: srcAndDstReg [ 
	self shiftLeft: srcAndDstReg byImm: 1; inc: srcAndDstReg
]

{ #category : #arithmetic }
Nativizer >> convertTtoNativeInteger [
	self convertToNativeInteger: codegen regT
	
]

{ #category : #services }
Nativizer >> currentAddress [
	^ codegen currentAddress
]

{ #category : #'push/pop' }
Nativizer >> dec: srcAndDstReg [
	codegen dec: srcAndDstReg

]

{ #category : #private }
Nativizer >> decRindirect [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen decMem: memref
]

{ #category : #private }
Nativizer >> discardArguments: anInteger [
	anInteger = 0 ifTrue: [^self].
	codegen addImm: anInteger * codegen wordSize to: codegen regSP
]

{ #category : #'floting point' }
Nativizer >> divideDoubleX0byX1 [
	codegen divDouble: codegen regX0 by: codegen regX1
]

{ #category : #'to-cleanup' }
Nativizer >> dropTopOfFPU [
	codegen dropTopOfFPU
]

{ #category : #'push/pop' }
Nativizer >> dropTos: count [
	codegen addImm: (count * codegen addressSize) to: codegen regSP

]

{ #category : #arithmetic }
Nativizer >> exchangeRindirectWithT [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen exchange: codegen regT withMem: memref
]

{ #category : #storing }
Nativizer >> extendRtoAandDividebyT [
	codegen divide: codegen regR extendingTo: codegen regA by: codegen regT
]

{ #category : #'push/pop' }
Nativizer >> inc: srcAndDstReg [
	codegen inc: srcAndDstReg

]

{ #category : #'push/pop' }
Nativizer >> initializeS [
	codegen move: codegen regR to: codegen regS
]

{ #category : #jumps }
Nativizer >> jumpIfEqualTo: label [
	codegen jumpIfEqualTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfGreaterOrEqualSignedTo: label [
	codegen jumpIfGreaterOrEqualSignedTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfGreaterSignedTo: label [
	codegen jumpIfGreaterSignedTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfLessOrEqualSignedTo: label [
	codegen jumpIfLessOrEqualSignedTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfLessSignedTo: label [
	codegen jumpIfLessSignedTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfNotEqualTo: label [
	codegen jumpIfNotEqualTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfNotZeroTo: label [
	codegen jumpIfNotZeroTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfOverflowTo: label [
	codegen jumpIfOverflowTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfSignTo: label [
	codegen jumpIfSignTo: label
]

{ #category : #jumps }
Nativizer >> jumpIfZeroTo: label [
	codegen jumpIfZeroTo: label
]

{ #category : #accessing }
Nativizer >> jumpOver: aBlock [
	| label |
	label := self newLabel.
	self jumpTo: label.
	aBlock value.
	self @ label
]

{ #category : #accessing }
Nativizer >> jumpTo: label [
	codegen jumpTo: label
]

{ #category : #accessing }
Nativizer >> jumpToMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen jumpToMem: memref
]

{ #category : #integers }
Nativizer >> labeledIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfZeroTo: label.
	^label
]

{ #category : #integers }
Nativizer >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: codegen regR

]

{ #category : #integers }
Nativizer >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: codegen regT byte
]

{ #category : #integers }
Nativizer >> labeledIntegerNativizationOf: aRegister [
	| label |
	self convertToNativeInteger: aRegister.
	label := self newLabel.
	self shortJumpIfNotCarryTo: label.
	^label
]

{ #category : #integers }
Nativizer >> labeledIntegerNativizationOfA [
	^self labeledIntegerNativizationOf: codegen regA
]

{ #category : #integers }
Nativizer >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: codegen regR
]

{ #category : #integers }
Nativizer >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: codegen regT
]

{ #category : #integers }
Nativizer >> labeledNonIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfNotZeroTo: label.
	^label
]

{ #category : #integers }
Nativizer >> labeledNonIntegerBitTestOfR [
	^self labeledNonIntegerBitTestOf: codegen regR

]

{ #category : #'to-cleanup' }
Nativizer >> leadingRzeroCount [
	codegen leadingRzeroCount
]

{ #category : #'memory - load / store' }
Nativizer >> load: dstReg fromMem: srcMemRef [
	^codegen load: dstReg fromMem: srcMemRef

]

{ #category : #loading }
Nativizer >> load:dstReg withImmediate: imm [
	codegen moveImm: imm to: dstReg

]

{ #category : #loading }
Nativizer >> load: register withLiteral: anObject [
	| index memref |
	index := self addLiteral: anObject.
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: register
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithFalse [
	codegen move: codegen regFalse to: codegen regA
]

{ #category : #private }
Nativizer >> loadAwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadAwithGindex: index
]

{ #category : #integers }
Nativizer >> loadAwithImmediate: imm [
	self load: codegen regA withImmediate: imm
]

{ #category : #arithmetic }
Nativizer >> loadAwithKnown: anObject [
	codegen breakpoint
]

{ #category : #loading }
Nativizer >> loadAwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadAwithMindex: index
]

{ #category : #loading }
Nativizer >> loadAwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadAwithNil [
	codegen move: codegen regNil to: codegen regA
]

{ #category : #loading }
Nativizer >> loadAwithR [
	codegen move: codegen regR to: codegen regA
]

{ #category : #loading }
Nativizer >> loadAwithRoffsetAtA [
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
Nativizer >> loadAwithS [
	codegen move: codegen regS to: codegen regA
]

{ #category : #loading }
Nativizer >> loadAwithSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		load: codegen regA
		fromMem: memref
]

{ #category : #integers }
Nativizer >> loadAwithSmallInteger: anInteger [
	| smi |
	smi := (anInteger bitShift: 1) + 1.
	self loadAwithImmediate: smi
]

{ #category : #loading }
Nativizer >> loadAwithTrue [
	codegen move: codegen regTrue to: codegen regA
]

{ #category : #'push/pop' }
Nativizer >> loadEwithAddressOfRatA [
	| memref |
	memref := codegen
		memRef: codegen regR
		index: codegen regA
		offsetImm: codegen wordSize negated.
	codegen lea: codegen regE withMem: memref
]

{ #category : #loading }
Nativizer >> loadEwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regE
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadEwithNil [
	codegen move: codegen regNil to: codegen regE
]

{ #category : #loading }
Nativizer >> loadEwithR [
	codegen move: codegen regR to: codegen regE
]

{ #category : #loading }
Nativizer >> loadFPwithR [
	codegen move: codegen regR to: codegen regFP
]

{ #category : #loading }
Nativizer >> loadFPwithSP [
	codegen move: codegen regSP to: codegen regFP
]

{ #category : #loading }
Nativizer >> loadFalseWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadFalseWithMindex: index
]

{ #category : #loading }
Nativizer >> loadFalseWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regFalse
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
Nativizer >> loadGwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regG
		fromMem: memref
]

{ #category : #'push/pop' }
Nativizer >> loadLargeX0withRindirect [
	| memref |
	memref := codegen memRef64: codegen regR indexImm: 1.
	codegen loadDouble: codegen regX0 fromMem: memref
]

{ #category : #'push/pop' }
Nativizer >> loadLargeX1withAindirect [
	| memref |
	memref := codegen memRef64: codegen regA indexImm: 1.
	codegen loadDouble: codegen regX1 fromMem: memref
]

{ #category : #'to-cleanup' }
Nativizer >> loadLongMwithIPoffset: anInteger [
	codegen loadLongMwithIPoffset: anInteger
]

{ #category : #'push/pop' }
Nativizer >> loadLongRwithRatOffsetA [
	| memref |
	memref := codegen
		memRef32: codegen regR
		offset: codegen regA.
	codegen load: codegen regR fromMem: memref

]

{ #category : #'push/pop' }
Nativizer >> loadLongSwithRindex: index [
	| memref |
	memref := codegen memRef32: codegen regR indexImm: index.
	codegen load: codegen regS fromMem: memref

]

{ #category : #'to-cleanup' }
Nativizer >> loadMXCSRfromA [
	codegen loadMXCSRfromA
]

{ #category : #'push/pop' }
Nativizer >> loadMwithA [
	codegen move: codegen regA to: codegen regM
]

{ #category : #loading }
Nativizer >> loadMwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #private }
Nativizer >> loadMwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadMwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadMwithGindex: index
]

{ #category : #loading }
Nativizer >> loadMwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadMwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadMwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		load: codegen regM
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
Nativizer >> loadNilWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regNil
		fromMem: memref
]

{ #category : #'push/pop' }
Nativizer >> loadRconvertingDoublePointedByR [
	| memref |
	memref := codegen memRef64: codegen regR indexImm: 1.
	codegen load: codegen regR convertingDoubleToIntegerFromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithA [
	codegen move: codegen regA to: codegen regR
]

{ #category : #'push/pop' }
Nativizer >> loadRwithArgPointer [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: 3.
	codegen lea: codegen regR withMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithE [
	codegen move: codegen regE to: codegen regR
]

{ #category : #loading }
Nativizer >> loadRwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithFP [
	codegen move: codegen regFP to: codegen regR
]

{ #category : #loading }
Nativizer >> loadRwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithFalse [
	codegen move: codegen regFalse to: codegen regR
]

{ #category : #integers }
Nativizer >> loadRwithImmediate: imm [
	self load: codegen regR withImmediate: imm
]

{ #category : #loading }
Nativizer >> loadRwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadRwithMindex: index
]

{ #category : #loading }
Nativizer >> loadRwithM [
	codegen move: codegen regM to: codegen regR
]

{ #category : #loading }
Nativizer >> loadRwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithNil [
	codegen move: codegen regNil to: codegen regR
]

{ #category : #integers }
Nativizer >> loadRwithRatA [
	| memref |
	memref := codegen memRef: codegen regR index: codegen regA.
	self
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithRatOffsetA [
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
Nativizer >> loadRwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithS [
	codegen move: codegen regS to: codegen regR
]

{ #category : #loading }
Nativizer >> loadRwithSPindex: index [
	| memref |
	memref := codegen memRef: codegen regSP indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadRwithSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #integers }
Nativizer >> loadRwithSmallInteger: anInteger [
	| smi |
	smi := self smallInteger: anInteger.
	self loadRwithImmediate: smi
]

{ #category : #loading }
Nativizer >> loadRwithT [
	codegen move: codegen regT to: codegen regR
]

{ #category : #'floting point' }
Nativizer >> loadRwithTIBatR [
	codegen load: codegen regR withTIBat: codegen regR
]

{ #category : #'floting point' }
Nativizer >> loadRwithThreadVariableAtR [
	codegen load: codegen regR withThreadVariableAt: codegen regR
]

{ #category : #loading }
Nativizer >> loadRwithTrue [
	codegen move: codegen regTrue to: codegen regR
]

{ #category : #loading }
Nativizer >> loadSPwithFP [
	codegen move: codegen regFP to: codegen regSP
]

{ #category : #'push/pop' }
Nativizer >> loadSwithAddressOfSatA [
	| memref |
	memref := codegen
		memRef: codegen regS
		index: codegen regA
		offsetImm: codegen wordSize negated.
	codegen lea: codegen regS withMem: memref
]

{ #category : #loading }
Nativizer >> loadSwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #private }
Nativizer >> loadSwithGindex: index [
	| memref |
	memref := codegen memRef: codegen regG indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadSwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadSwithGindex: index
]

{ #category : #loading }
Nativizer >> loadSwithNil [
	codegen move: codegen regNil to: codegen regS
]

{ #category : #loading }
Nativizer >> loadSwithRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		load: codegen regS
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
Nativizer >> loadTrueWithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regTrue
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadTwithA [
	codegen move: codegen regA to: codegen regT
]

{ #category : #loading }
Nativizer >> loadTwithAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadTwithEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadTwithFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #integers }
Nativizer >> loadTwithImmediate: imm [
	self load: codegen regT withImmediate: imm
]

{ #category : #loading }
Nativizer >> loadTwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTwithMindex: index
]

{ #category : #loading }
Nativizer >> loadTwithMindex: index [
	| memref |
	memref := codegen memRef: codegen regM indexImm: index.
	codegen
		load: codegen regT
		fromMem: memref
]

{ #category : #loading }
Nativizer >> loadTwithR [
	codegen move: codegen regR to: codegen regT
]

{ #category : #loading }
Nativizer >> loadTwithTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen load: codegen regT fromMem: memref
]

{ #category : #loading }
Nativizer >> loadWithFalse: register [ 
	codegen move: codegen regFalse to: register
]

{ #category : #loading }
Nativizer >> loadWithNil: register [ 
	codegen move: codegen regNil to: register
]

{ #category : #loading }
Nativizer >> loadWithTrue: register [ 
	codegen move: codegen regTrue to: register
]

{ #category : #'push/pop' }
Nativizer >> loadX0withRasDouble [
	codegen convert: codegen regR toDouble: codegen regX0
]

{ #category : #'to-cleanup' }
Nativizer >> loadZeroExtendByte: dstReg from: srcBaseReg atIndexAt: srcIndexReg [
	codegen loadZeroExtendByte: dstReg from: srcBaseReg atIndexAt: srcIndexReg

]

{ #category : #'to-cleanup' }
Nativizer >> loadZeroExtendByte: dstReg from: srcBaseReg atIndexImm: indexImm [

	codegen
		loadZeroExtendByte: dstReg
		from: srcBaseReg
		atIndexImm: indexImm
]

{ #category : #jumps }
Nativizer >> loadZeroExtendByte: reg1 from: reg2 atOffset: offset [
	codegen loadZeroExtendByte: reg1 from: reg2 atOffset: offset
]

{ #category : #integers }
Nativizer >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: codegen regR from: codegen regR atIndexAt: codegen regA
]

{ #category : #integers }
Nativizer >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: codegen regR from: codegen regR atIndexImm: index
]

{ #category : #integers }
Nativizer >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: codegen regR from: codegen regSP atIndexAt: codegen regA
]

{ #category : #integers }
Nativizer >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: codegen regT from: codegen regA atIndexImm: index
]

{ #category : #integers }
Nativizer >> loadZeroExtendLongRwithRatA [
	| memref |
	memref := codegen memRef32: codegen regR index: codegen regA.
	codegen
		load: codegen regR
		fromMem: memref
]

{ #category : #integers }
Nativizer >> loadZeroExtendLongRwithRindex: index [
	| memref |
	#dontOptimize.
	memref := codegen memRef32: codegen regR indexImm: index.
	codegen
		load: codegen regR e
		fromMem: memref
]

{ #category : #'to-cleanup' }
Nativizer >> loadZeroExtendShortRwithRoffset: offset [
	codegen
		loadZeroExtendShortRwithRoffset: offset
]

{ #category : #'to-cleanup' }
Nativizer >> lock [
	codegen lock
]

{ #category : #jumps }
Nativizer >> loop: aBlock times: anInteger [
	| loop |
	loop := self newLabel.
	self loadTwithImmediate: anInteger; @ loop.
	aBlock value.
	self dec: codegen regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
Nativizer >> loopTtimes: aBlock [
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
Nativizer >> memRef [
	"Return clean instance of pointer-sized memory reference"

	^ codegen memRef

]

{ #category : #memory }
Nativizer >> memRef32: baseReg indexImm: indexImm [
	^ codegen memRef32: baseReg indexImm: indexImm
]

{ #category : #memory }
Nativizer >> memRef8 [
	"Return clean instance of byte-sized memory reference"

	^ codegen memRef8
]

{ #category : #memory }
Nativizer >> memRef8: baseReg index: indexReg [
	^ codegen memRef8: baseReg index: indexReg
]

{ #category : #memory }
Nativizer >> memRef: baseReg index: indexReg [
	^ codegen memRef: baseReg index: indexReg
]

{ #category : #memory }
Nativizer >> memRef: baseReg indexImm: indexImm [
	^ codegen memRef: baseReg indexImm: indexImm
]

{ #category : #services }
Nativizer >> move: srcReg to: dstReg [
	^ codegen move: srcReg to: dstReg

]

{ #category : #services }
Nativizer >> moveImm: imm to: dstReg [
	codegen moveImm: imm to: dstReg

]

{ #category : #'to-cleanup' }
Nativizer >> moveTslots [
	codegen moveTslots
]

{ #category : #'floting point' }
Nativizer >> moveX0toR [
	codegen moveDouble: codegen regX0 into: codegen regR
]

{ #category : #'floting point' }
Nativizer >> multiplyDoubleX0byX1 [
	codegen mulDouble: codegen regX0 by: codegen regX1
]

{ #category : #storing }
Nativizer >> multiplyRbyAwideningToA [
	codegen
		multiply: codegen regR
		by: codegen regA
		wideningTo: codegen regA
]

{ #category : #arithmetic }
Nativizer >> nativeCode [
	^(NativeCode withAll: literals) code: codegen memory bytes
]

{ #category : #labels }
Nativizer >> newLabel [
	| label next |
	next := labels size + 1.
	IndexedLabels size < next ifTrue: [self class growIndexedLabelsTo: next].
	label := IndexedLabels at: next.
	self addLabel: label to: nil.
	^label
]

{ #category : #'operations - logical' }
Nativizer >> or: src1AndDst with: src2 [
	^ codegen or: src1AndDst with: src2
]

{ #category : #'operations - logical' }
Nativizer >> or: source1andDest withImm: imm [
	codegen or: source1andDest withImm: imm
]

{ #category : #logic }
Nativizer >> orRwithA [
	codegen or: codegen regR with: codegen regA

]

{ #category : #private }
Nativizer >> pop: dstReg [
	codegen pop: dstReg
]

{ #category : #'push/pop' }
Nativizer >> popA [
	codegen pop: codegen regA
]

{ #category : #'push/pop' }
Nativizer >> popE [
	codegen pop: codegen regE
]

{ #category : #'push/pop' }
Nativizer >> popFP [
	codegen pop: codegen regFP
]

{ #category : #'push/pop' }
Nativizer >> popFalse [
	codegen pop: codegen regFalse
]

{ #category : #'push/pop' }
Nativizer >> popG [
	codegen pop: codegen regG
]

{ #category : #'push/pop' }
Nativizer >> popM [
	codegen pop: codegen regM
]

{ #category : #'push/pop' }
Nativizer >> popNil [
	codegen pop: codegen regNil
]

{ #category : #'push/pop' }
Nativizer >> popR [
	codegen pop: codegen regR
]

{ #category : #'push/pop' }
Nativizer >> popS [
	codegen pop: codegen regS
]

{ #category : #'operations - arithmetic' }
Nativizer >> popSPindirect [
	| memref |
	memref := codegen memRef: codegen regSP indexImm: 1.
	codegen popIntoMem: memref
]

{ #category : #'push/pop' }
Nativizer >> popT [
	codegen pop: codegen regT
]

{ #category : #'push/pop' }
Nativizer >> popTrue [
	codegen pop: codegen regTrue
]

{ #category : #private }
Nativizer >> push: srcReg [
	codegen push: srcReg

]

{ #category : #'push/pop' }
Nativizer >> pushA [
	codegen push: codegen regA
]

{ #category : #'floting point' }
Nativizer >> pushAatToffset: offset [
	| memref |
	memref := codegen memRef: codegen regA index: codegen regT.
	memref displacement: offset.
	codegen pushMem: memref
]

{ #category : #'push/pop' }
Nativizer >> pushE [
	codegen push: codegen regE
]

{ #category : #'push/pop' }
Nativizer >> pushFP [
	codegen push: codegen regFP
]

{ #category : #'push/pop' }
Nativizer >> pushFalse [
	codegen push: codegen regFalse
]

{ #category : #'push/pop' }
Nativizer >> pushG [
	codegen push: codegen regG
]

{ #category : #private }
Nativizer >> pushImm: imm [
	codegen pushImm: imm

]

{ #category : #private }
Nativizer >> pushIndirectR [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen pushMem: memref
]

{ #category : #'push/pop' }
Nativizer >> pushM [
	codegen push: codegen regM
]

{ #category : #'push/pop' }
Nativizer >> pushNil [
	codegen push: codegen regNil
]

{ #category : #'push/pop' }
Nativizer >> pushR [
	codegen push: codegen regR
]

{ #category : #'push/pop' }
Nativizer >> pushS [
	codegen push: codegen regS
]

{ #category : #arithmetic }
Nativizer >> pushSmallInteger: integer [
	| smi |
	smi := self smallInteger: integer.
	self pushImm: smi
]

{ #category : #'push/pop' }
Nativizer >> pushT [
	codegen push: codegen regT
]

{ #category : #'push/pop' }
Nativizer >> pushTrue [
	codegen push: codegen regTrue
]

{ #category : #'to-cleanup' }
Nativizer >> readFPUStatusOnA [
	codegen readFPUStatusOnA
]

{ #category : #'registers - IR' }
Nativizer >> regA [
	^codegen regA

]

{ #category : #'registers - IR' }
Nativizer >> regA8 [
	^ codegen regA byte

]

{ #category : #'registers - IR' }
Nativizer >> regE [
	^ codegen regE
]

{ #category : #'registers - IR' }
Nativizer >> regFP [
	^ codegen regFP

]

{ #category : #'registers - IR' }
Nativizer >> regFalse [
	^ codegen regFalse

]

{ #category : #'registers - IR' }
Nativizer >> regG [
	^ codegen regG

]

{ #category : #'registers - IR' }
Nativizer >> regIP [
	^ codegen regIP

]

{ #category : #'registers - IR' }
Nativizer >> regM [
	^ codegen regM

]

{ #category : #'registers - IR' }
Nativizer >> regNil [
	^ codegen regNil

]

{ #category : #'registers - IR' }
Nativizer >> regR [
	^ codegen regR

]

{ #category : #'registers - IR' }
Nativizer >> regR8 [
	^ codegen regR byte

]

{ #category : #'registers - IR' }
Nativizer >> regS [
	^ codegen regS
]

{ #category : #'registers - IR' }
Nativizer >> regSP [
	^ codegen regSP

]

{ #category : #'registers - IR' }
Nativizer >> regT [
	^ codegen regT
]

{ #category : #'registers - IR' }
Nativizer >> regT8 [
	^ codegen reg byte
]

{ #category : #'registers - IR' }
Nativizer >> regTrue [
	^ codegen regTrue

]

{ #category : #'registers - IR' }
Nativizer >> regV [
	^ codegen regV

]

{ #category : #'registers - IR' }
Nativizer >> regX0 [
	"IEEE 754 double register"
	^ codegen regX0

]

{ #category : #'registers - IR' }
Nativizer >> regX1 [
	"IEEE 754 double register"
	^ codegen regX1
]

{ #category : #jumps }
Nativizer >> renameByteRegisterIfNeeded: register preserving: preserved during: aBlock [
	codegen renameByteRegisterIfNeeded: register preserving: preserved during: aBlock
]

{ #category : #'floting point' }
Nativizer >> renameByteRegisterIfNeeded: register preserving: preserved1 preserving: preserved2 during: aBlock [
	codegen renameByteRegisterIfNeeded: register preserving: preserved1 preserving: preserved2 during: aBlock
]

{ #category : #loading }
Nativizer >> reserveStackSlots: amount [
	codegen subImm: amount * codegen addressSize from: codegen regSP
]

{ #category : #initialization }
Nativizer >> reset [
	labels := Dictionary new: 100.
	literals := OrderedCollection new.
	codegen reset
]

{ #category : #labels }
Nativizer >> resolveLabel: aString [
	^labels at: aString
]

{ #category : #epilogue }
Nativizer >> restoreCallerEnvironment [
	self loadEwithFPindex: -2
]

{ #category : #epilogue }
Nativizer >> restoreCallerFrame [
	codegen
		move: codegen regFP to: codegen regSP;
		pop: codegen regFP
]

{ #category : #epilogue }
Nativizer >> restoreCallerM [
	self loadMwithFPindex: -1
]

{ #category : #epilogue }
Nativizer >> restoreCallerSelf [
	self loadSwithFPindex: 0
]

{ #category : #jumps }
Nativizer >> return [
	codegen return
]

{ #category : #'floting point' }
Nativizer >> roundDoubleX0intoX1 [
	codegen roundDouble: codegen regX0 into: codegen regX1
]

{ #category : #loading }
Nativizer >> saveCallerFrame [
	self pushFP; loadFPwithSP
]

{ #category : #'to-cleanup' }
Nativizer >> scaleFloatOnRWithA [
	codegen scaleFloatOnRWithA
]

{ #category : #arithmetic }
Nativizer >> setIntegerBit: srcAndDstReg [
	self setSafeIntegerBit: srcAndDstReg
]

{ #category : #arithmetic }
Nativizer >> setRintegerBit [
	self setIntegerBit: codegen regR

]

{ #category : #arithmetic }
Nativizer >> setSafeIntegerBit: srcAndDstReg [
	self or: srcAndDstReg withImm: 1
]

{ #category : #arithmetic }
Nativizer >> setSafeRintegerBit [
	self setSafeIntegerBit: codegen regR

]

{ #category : #'operations - logical' }
Nativizer >> shiftLeft: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Nativizer >> shiftLeft: srcAndDst byImm: count [
	codegen shiftLeft: srcAndDst byImm: count
]

{ #category : #arithmetic }
Nativizer >> shiftLeftRwithT [
	codegen shiftLeft: codegen regR by: codegen regT

]

{ #category : #arithmetic }
Nativizer >> shiftLogicalRright: count [
	codegen shiftRight: codegen regR byImm: count

]

{ #category : #'operations - logical' }
Nativizer >> shiftRight: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Nativizer >> shiftRight: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
Nativizer >> shiftRightArithmetic: srcAndDst by: countReg [
	codegen shiftRightArithmetic: srcAndDst by: countReg
]

{ #category : #'operations - logical' }
Nativizer >> shiftRightArithmetic: srcAndDst byImm: count [
	codegen shiftRightArithmetic: srcAndDst byImm: count

]

{ #category : #arithmetic }
Nativizer >> shiftRightRwithT [
	codegen shiftRightArithmetic: codegen regR by: codegen regT

]

{ #category : #arithmetic }
Nativizer >> shiftRleft: count [
	 codegen shiftLeft: codegen regR byImm: count

]

{ #category : #arithmetic }
Nativizer >> shiftRright: count [
	codegen shiftRightArithmetic: codegen regR byImm: count

]

{ #category : #arithmetic }
Nativizer >> shiftTright: count [
	codegen shiftRightArithmetic: codegen regT byImm: count

]

{ #category : #jumps }
Nativizer >> shortJumpIfCarryTo: label [
	codegen shortJumpIfCarryTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfEqualTo: label [
	codegen shortJumpIfEqualTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfNotCarryTo: label [
	codegen shortJumpIfNotCarryTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfNotEqualTo: label [
	codegen shortJumpIfNotEqualTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfNotZeroTo: label [
	self shortJumpIfNotEqualTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfSignTo: label [
	codegen shortJumpIfSignTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpIfZeroTo: label [
	self shortJumpIfEqualTo: label
]

{ #category : #jumps }
Nativizer >> shortJumpTo: label [
	codegen shortJumpTo: label
]

{ #category : #comparing }
Nativizer >> smallInteger: anInteger [
	^(anInteger bitShift: 1) + 1
]

{ #category : #'floting point' }
Nativizer >> sqrtDoubleX0 [
	codegen sqrtDouble: codegen regX0 into: codegen regX0
]

{ #category : #'memory - load / store' }
Nativizer >> store: srcReg intoMem: dstMemRef [
	^ codegen store: srcReg intoMem: dstMemRef
]

{ #category : #'floting point' }
Nativizer >> storeAinThreadVariableAtIndexR [
	codegen store: codegen regA intoThreadVariableAt: codegen regR
]

{ #category : #storing }
Nativizer >> storeAinTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		store: codegen regA
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeByteAinRindex: index [
	| memref |
	memref := codegen memRef8: codegen regR indexImm: index.
	codegen store: codegen regA byte intoMem: memref
]

{ #category : #storing }
Nativizer >> storeByteTinRatA [
	| memref |
	memref := codegen memRef8: codegen regR index: codegen regA.
	codegen store: codegen regT byte intoMem: memref
]

{ #category : #'floting point' }
Nativizer >> storeDoubleResultInRindirect [
	| memref |
	memref := codegen memRef: codegen regR indexImm: 1.
	codegen storeDoubleResultIntoMem:  memref
]

{ #category : #storing }
Nativizer >> storeEinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regE
		intoMem: memref
]

{ #category : #'memory - load / store' }
Nativizer >> storeImm: imm intoMem: dstMemRef [
	"Store constant into memory location `dstMemRef`. 

	 The size of data loaded is specified in `dstMemRef`"

	self
		moveImm: imm to: self regV;
		store: self regV intoMem: dstMemRef
]

{ #category : #storing }
Nativizer >> storeLargeX0inA [
	| memref |
	memref := codegen memRef64: codegen regA indexImm: 1.
	codegen storeDouble: codegen regX0 intoMem: memref
		

]

{ #category : #storing }
Nativizer >> storeLargeX0inT [
	| memref |
	memref := codegen memRef64: codegen regT indexImm: 1.
	codegen storeDouble: codegen regX0 intoMem: memref
		

]

{ #category : #storing }
Nativizer >> storeLongTinRatA [
	| memref |
	memref := codegen memRef32: codegen regR index: codegen regA.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeLongTinRatOffsetA [
	| memref |
	memref := codegen memRef32: codegen regR offset: codegen regA.
	codegen store: codegen regT long intoMem: memref
]

{ #category : #'to-cleanup' }
Nativizer >> storeMXCSRintoA [
	codegen storeMXCSRintoA

]

{ #category : #storing }
Nativizer >> storeRinAindex: index [
	| memref |
	memref := codegen memRef: codegen regA indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeRinEindex: index [
	| memref |
	memref := codegen memRef: codegen regE indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeRinFPindex: index [
	| memref |
	memref := codegen memRef: codegen regFP indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeRinSindex: index [
	| memref |
	memref := codegen memRef: codegen regS indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeRinTindex: index [
	| memref |
	memref := codegen memRef: codegen regT indexImm: index.
	codegen
		store: codegen regR
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeShortAinRoffset: offset [
	|  memref |
	memref := codegen memRef16: codegen regR offsetImm: offset.
	codegen store: codegen regA short intoMem: memref
]

{ #category : #storing }
Nativizer >> storeShortTinRatOffsetA [
	| memref |
	memref := codegen memRef16: codegen regR offset: codegen regA.
	codegen store: codegen regT short intoMem: memref
]

{ #category : #storing }
Nativizer >> storeSinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regS
		intoMem: memref
]

{ #category : #'floting point' }
Nativizer >> storeTIBatRwithA [
	codegen store: codegen regA intoTIBat: codegen regR
]

{ #category : #storing }
Nativizer >> storeTinRatA [
	| memref |
	memref := codegen memRef: codegen regR index: codegen regA.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #storing }
Nativizer >> storeTinRatOffsetA [
	| memref |
	memref := codegen memRef: codegen regR offset: codegen regA.
	codegen store: codegen regT intoMem: memref
]

{ #category : #storing }
Nativizer >> storeTinRindex: index [
	| memref |
	memref := codegen memRef: codegen regR indexImm: index.
	codegen
		store: codegen regT
		intoMem: memref
]

{ #category : #'operations - arithmetic' }
Nativizer >> sub: src2 from: src1AndDst [
	codegen sub: src2  from: src1AndDst

]

{ #category : #arithmetic }
Nativizer >> subAfromR [
	codegen sub: codegen regA from: codegen regR

]

{ #category : #arithmetic }
Nativizer >> subAfromT [
	codegen sub: codegen regA from: codegen regT    

]

{ #category : #'floting point' }
Nativizer >> subDoubleX1fromX0 [
	codegen subDouble: codegen regX1 from: codegen regX0
]

{ #category : #arithmetic }
Nativizer >> subFromRconstant: imm [
	codegen subImm: imm from: codegen regR

]

{ #category : #'operations - arithmetic' }
Nativizer >> subImm: imm from: srcAndDst [
	codegen subImm: imm from: srcAndDst

]

{ #category : #'to-cleanup' }
Nativizer >> subTslotsToSP [
	codegen subTslotsToSP
]

{ #category : #initialization }
Nativizer >> target: aNativizationTarget [
	codegen := aNativizationTarget newCodeGenerator.
	self reset
]

{ #category : #loading }
Nativizer >> testIntegerBit: aRegister [
	codegen testIntegerBit: aRegister
]

{ #category : #loading }
Nativizer >> testIntegerBitOf: aRegister [
	codegen test: aRegister byte withImm: 1
]

{ #category : #loading }
Nativizer >> testRintegerBit [
	codegen test: codegen regR byte withImm: 1
]

{ #category : #loading }
Nativizer >> testRwithR [
	codegen test: codegen regR with: codegen regR
]

{ #category : #services }
Nativizer >> wordSize [
	^codegen wordSize
]

{ #category : #'to-cleanup' }
Nativizer >> writeTslots [
	codegen writeTslots
]

{ #category : #'operations - logical' }
Nativizer >> xor: src1AndDst with: src2 [
	^ self subclassResponsibility

]

{ #category : #logic }
Nativizer >> xorAwithR [
	codegen xor: codegen regA with: codegen regR

]

{ #category : #logic }
Nativizer >> xorFPwithFP [
	codegen xor: codegen regFP with: codegen regFP

]

{ #category : #logic }
Nativizer >> xorRwithA [
	codegen xor: codegen regR with: codegen regA

]
