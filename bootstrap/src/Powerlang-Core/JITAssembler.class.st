"
I am the JIT assembler frontend. I provide a high-level assembler interface (if that really exists)
and delegate writing of the actual bytes to my backends.
"
Class {
	#name : #JITAssembler,
	#superclass : #Object,
	#instVars : [
		'backend',
		'labels',
		'literals'
	],
	#classVars : [
		'IndexedLabels'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #initialization }
JITAssembler class >> growIndexedLabelsTo: anInteger [
	| new |
	new := (IndexedLabels size + 1 to: anInteger)
		collect: [:i | ('@' , i asString) asSymbol].
	IndexedLabels := IndexedLabels , new
]

{ #category : #initialization }
JITAssembler class >> initialize [
	self initializeIndexedLabels
	
]

{ #category : #initialization }
JITAssembler class >> initializeIndexedLabels [
	IndexedLabels := #().
	self growIndexedLabelsTo: 100
]

{ #category : #'instance creation' }
JITAssembler class >> new [
	^super new initialize
]

{ #category : #labels }
JITAssembler >> @ label [
	self addLabel: label
]

{ #category : #'operations - arithmetic' }
JITAssembler >> add: source1 to: source2andDest [
	backend add: source1 to: source2andDest
]

{ #category : #arithmetic }
JITAssembler >> addAtoR [
	backend add: backend regA to: backend regR
]

{ #category : #arithmetic }
JITAssembler >> addDoubleX1toX0 [
	self 
		assemble: 'addsd'
		with: backend regX0
		with: backend regX1

]

{ #category : #'operations - arithmetic' }
JITAssembler >> addImm: imm to: dest [
	backend addImm: imm to: dest
]

{ #category : #labels }
JITAssembler >> addLabel: aString [
	self addLabel: aString to: self currentAddress
]

{ #category : #labels }
JITAssembler >> addLabel: label to: location [
	labels at: label put: location
]

{ #category : #loading }
JITAssembler >> addLiteral: anObject [
	| index |
	index := literals
		identityIndexOf: anObject
		ifAbsent: [ literals
				add: anObject;
				size ].
	^ index + 2
]

{ #category : #arithmetic }
JITAssembler >> addRwithImmediate: imm [
	backend addImm: imm to: backend regR 
]

{ #category : #logic }
JITAssembler >> addSPwithImmediate: imm [
	backend addImm: imm to: backend regSP
]

{ #category : #arithmetic }
JITAssembler >> addTtoR [
	backend add: backend regT to: backend regR
]

{ #category : #logic }
JITAssembler >> addTwithImmediate: imm [
	backend addImm: imm to: backend regT
]

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest with: source2 [
	backend and: source1andDest with: source2
]

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest withImm: imm [
	backend and: source1andDest withImm: imm
]

{ #category : #logic }
JITAssembler >> andRwithA [
	backend and: backend regR with: backend regA
]

{ #category : #arithmetic }
JITAssembler >> andRwithImmediate: imm [
	backend and: backend regR withImm: imm
]

{ #category : #relocation }
JITAssembler >> applyFixups [
	backend memory applyFixupsWith: self
]

{ #category : #private }
JITAssembler >> buildFrame [
	self
		push: backend regFP;
		move: backend regSP to: backend regFP
]

{ #category : #'operations - arithmetic' }
JITAssembler >> callIndirectA [
	| memref |
	memref := backend memRef: backend regA indexImm: 1.
	backend callIndirect: memref
]

{ #category : #'operations - arithmetic' }
JITAssembler >> callIndirectM [
	| memref |
	memref := backend memRef: backend regM indexImm: 1.
	backend callIndirect: memref
]

{ #category : #'operations - arithmetic' }
JITAssembler >> callR [
	backend call: backend regR
]

{ #category : #'operations - arithmetic' }
JITAssembler >> clearIntegerBit: srcAndDstReg [
	self clearSafeIntegerBit: srcAndDstReg

]

{ #category : #'push/pop' }
JITAssembler >> clearRhigh32 [
	backend clearHigh32: backend regR

]

{ #category : #'operations - arithmetic' }
JITAssembler >> clearRintegerBit [
	self dec: backend regR
]

{ #category : #'operations - arithmetic' }
JITAssembler >> clearSafeIntegerBit: srcAndDstReg [
	self and: srcAndDstReg withImm: -2
]

{ #category : #'operations - arithmetic' }
JITAssembler >> clearSafeRintegerBit [
	self clearSafeIntegerBit: backend regR8
]

{ #category : #arithmetic }
JITAssembler >> convertAtoNativeInteger [
	self convertToNativeInteger: backend regA
	
]

{ #category : #arithmetic }
JITAssembler >> convertRtoNativeInteger [
	self convertToNativeInteger: backend regR
	
]

{ #category : #arithmetic }
JITAssembler >> convertRtoSmallInteger [
	self convertToSmallInteger: backend regR
]

{ #category : #arithmetic }
JITAssembler >> convertToNativeInteger: srcAndDstReg [
	backend shiftRightArithmetic: srcAndDstReg byImm: 1
]

{ #category : #arithmetic }
JITAssembler >> convertToSmallInteger: srcAndDstReg [ 
	self shiftLeft: srcAndDstReg byImm: 1; inc: srcAndDstReg
]

{ #category : #arithmetic }
JITAssembler >> convertTtoNativeInteger [
	self convertToNativeInteger: backend regT
	
]

{ #category : #'push/pop' }
JITAssembler >> dec: srcAndDstReg [
	backend dec: srcAndDstReg

]

{ #category : #private }
JITAssembler >> decRindirect [
	| memref |
	memref := backend memRef: backend regR indexImm: 1.
	backend decMem: memref
]

{ #category : #private }
JITAssembler >> discardArguments: anInteger [
	anInteger = 0 ifTrue: [^self].
	backend addImm: anInteger * backend wordSize to: backend regSP
]

{ #category : #loading }
JITAssembler >> doesNotUnderstand: aMessage [
	(backend respondsTo: aMessage selector)
		ifFalse: [ ^ super doesNotUnderstand: aMessage ].
	^ backend
		perform: aMessage selector
		withArguments: aMessage arguments
]

{ #category : #'push/pop' }
JITAssembler >> dropTos: count [
	backend addImm: (count * backend addressSize) to: backend regSP

]

{ #category : #'push/pop' }
JITAssembler >> inc: srcAndDstReg [
	backend inc: srcAndDstReg

]

{ #category : #'push/pop' }
JITAssembler >> initializeS [
	backend move: backend regR to: backend regS
]

{ #category : #accessing }
JITAssembler >> jumpOver: aBlock [
	| label |
	label := self newLabel.
	self jumpTo: label.
	aBlock value.
	self @ label
]

{ #category : #accessing }
JITAssembler >> jumpTo: label [
	backend jumpTo: label
]

{ #category : #accessing }
JITAssembler >> jumpToMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend jumpToMem: memref
]

{ #category : #integers }
JITAssembler >> labeledIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfZeroTo: label.
	^label
]

{ #category : #integers }
JITAssembler >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: backend regR8
]

{ #category : #integers }
JITAssembler >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: backend regT byte
]

{ #category : #integers }
JITAssembler >> labeledIntegerNativizationOf: aRegister [
	| label |
	self convertToNativeInteger: aRegister.
	label := self newLabel.
	self shortJumpIfNotCarryTo: label.
	^label
]

{ #category : #integers }
JITAssembler >> labeledIntegerNativizationOfA [
	^self labeledIntegerNativizationOf: backend regA
]

{ #category : #integers }
JITAssembler >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: backend regR
]

{ #category : #integers }
JITAssembler >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: backend regT
]

{ #category : #integers }
JITAssembler >> labeledNonIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfNotZeroTo: label.
	^label
]

{ #category : #integers }
JITAssembler >> labeledNonIntegerBitTestOfR [
	^self labeledNonIntegerBitTestOf: backend regR8
]

{ #category : #'memory - load / store' }
JITAssembler >> load: dstReg fromMem: srcMemRef [
	^backend load: dstReg fromMem: srcMemRef

]

{ #category : #loading }
JITAssembler >> load:dstReg withImmediate: imm [
	backend moveImm: imm to: dstReg

]

{ #category : #loading }
JITAssembler >> load: register withLiteral: anObject [
	| index memref |
	index := self addLiteral: anObject.
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: register
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithAindex: index [
	| memref |
	memref := backend memRef: backend regA indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithEindex: index [
	| memref |
	memref := backend memRef: backend regE indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithFalse [
	backend move: backend regFalse to: backend regA
]

{ #category : #private }
JITAssembler >> loadAwithGindex: index [
	| memref |
	memref := backend memRef: backend regG indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadAwithGindex: index
]

{ #category : #integers }
JITAssembler >> loadAwithImmediate: imm [
	self load: backend regA withImmediate: imm
]

{ #category : #arithmetic }
JITAssembler >> loadAwithKnown: anObject [
	backend breakpoint
]

{ #category : #loading }
JITAssembler >> loadAwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadAwithMindex: index
]

{ #category : #loading }
JITAssembler >> loadAwithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithNil [
	backend move: backend regNil to: backend regA
]

{ #category : #loading }
JITAssembler >> loadAwithR [
	backend move: backend regR to: backend regA
]

{ #category : #loading }
JITAssembler >> loadAwithRoffsetAtA [
	| memref |
	memref := backend memRef
				base: backend regR;
				index: backend regA;
				scale: 1.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadAwithS [
	backend move: backend regS to: backend regA
]

{ #category : #loading }
JITAssembler >> loadAwithSindex: index [
	| memref |
	memref := backend memRef: backend regS indexImm: index.
	backend
		load: backend regA
		fromMem: memref
]

{ #category : #integers }
JITAssembler >> loadAwithSmallInteger: anInteger [
	| smi |
	smi := (anInteger bitShift: 1) + 1.
	self loadAwithImmediate: smi
]

{ #category : #loading }
JITAssembler >> loadAwithTrue [
	backend move: backend regTrue to: backend regA
]

{ #category : #'push/pop' }
JITAssembler >> loadEwithAddressOfRatA [
	| memref |
	memref := backend
		memRef: backend regR
		index: backend regA
		offsetImm: backend wordSize negated.
	backend lea: backend regE withMem: memref
]

{ #category : #loading }
JITAssembler >> loadEwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regE
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadEwithNil [
	backend move: backend regNil to: backend regE
]

{ #category : #loading }
JITAssembler >> loadEwithR [
	backend move: backend regR to: backend regE
]

{ #category : #loading }
JITAssembler >> loadFPwithR [
	backend move: backend regR to: backend regFP
]

{ #category : #loading }
JITAssembler >> loadFPwithSP [
	backend move: backend regSP to: backend regFP
]

{ #category : #loading }
JITAssembler >> loadFalseWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadFalseWithMindex: index
]

{ #category : #loading }
JITAssembler >> loadFalseWithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regFalse
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
JITAssembler >> loadGwithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regG
		fromMem: memref
]

{ #category : #'push/pop' }
JITAssembler >> loadLongRwithRatOffsetA [
	| memref |
	memref := backend
		memRef32: backend regR
		offset: backend regA.
	backend load: backend regR32 fromMem: memref
	

]

{ #category : #'push/pop' }
JITAssembler >> loadLongSwithRindex: index [
	| memref |
	memref := backend memRef32: backend regR indexImm: index.
	backend load: backend regS32 fromMem: memref
]

{ #category : #'push/pop' }
JITAssembler >> loadMwithA [
	backend move: backend regA to: backend regM
]

{ #category : #loading }
JITAssembler >> loadMwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regM
		fromMem: memref
]

{ #category : #private }
JITAssembler >> loadMwithGindex: index [
	| memref |
	memref := backend memRef: backend regG indexImm: index.
	backend
		load: backend regM
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadMwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadMwithGindex: index
]

{ #category : #loading }
JITAssembler >> loadMwithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regM
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadMwithRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		load: backend regM
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadMwithTindex: index [
	| memref |
	memref := backend memRef: backend regT indexImm: index.
	backend
		load: backend regM
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
JITAssembler >> loadNilWithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regNil
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithA [
	backend move: backend regA to: backend regR
]

{ #category : #'push/pop' }
JITAssembler >> loadRwithArgPointer [
	| memref |
	memref := backend memRef: backend regFP indexImm: 3.
	backend lea: backend regR withMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithE [
	backend move: backend regE to: backend regR
]

{ #category : #loading }
JITAssembler >> loadRwithEindex: index [
	| memref |
	memref := backend memRef: backend regE indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithFP [
	backend move: backend regFP to: backend regR
]

{ #category : #loading }
JITAssembler >> loadRwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithFalse [
	backend move: backend regFalse to: backend regR
]

{ #category : #integers }
JITAssembler >> loadRwithImmediate: imm [
	self load: backend regR withImmediate: imm
]

{ #category : #loading }
JITAssembler >> loadRwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadRwithMindex: index
]

{ #category : #loading }
JITAssembler >> loadRwithM [
	backend move: backend regM to: backend regR
]

{ #category : #loading }
JITAssembler >> loadRwithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithNil [
	backend move: backend regNil to: backend regR
]

{ #category : #integers }
JITAssembler >> loadRwithRatA [
	| memref |
	memref := backend memRef: backend regR index: backend regA.
	self
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithRatOffsetA [
	| memref |
	memref := backend memRef
				base: backend regR;
				index: backend regA;
				scale: 1.
	backend
		load: backend regR
		fromMem:
			memref
]

{ #category : #loading }
JITAssembler >> loadRwithRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithS [
	backend move: backend regS to: backend regR
]

{ #category : #loading }
JITAssembler >> loadRwithSPindex: index [
	| memref |
	memref := backend memRef: backend regSP indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadRwithSindex: index [
	| memref |
	memref := backend memRef: backend regS indexImm: index.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #integers }
JITAssembler >> loadRwithSmallInteger: anInteger [
	| smi |
	smi := self smallInteger: anInteger.
	self loadRwithImmediate: smi
]

{ #category : #loading }
JITAssembler >> loadRwithT [
	backend move: backend regT to: backend regR
]

{ #category : #loading }
JITAssembler >> loadRwithTrue [
	backend move: backend regTrue to: backend regR
]

{ #category : #loading }
JITAssembler >> loadSPwithFP [
	backend move: backend regFP to: backend regSP
]

{ #category : #'push/pop' }
JITAssembler >> loadSwithAddressOfSatA [
	| memref |
	memref := backend
		memRef: backend regS
		index: backend regA
		offsetImm: backend wordSize negated.
	backend lea: backend regS withMem: memref
]

{ #category : #loading }
JITAssembler >> loadSwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regS
		fromMem: memref
]

{ #category : #private }
JITAssembler >> loadSwithGindex: index [
	| memref |
	memref := backend memRef: backend regG indexImm: index.
	backend
		load: backend regS
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadSwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadSwithGindex: index
]

{ #category : #loading }
JITAssembler >> loadSwithNil [
	backend move: backend regNil to: backend regS
]

{ #category : #loading }
JITAssembler >> loadSwithRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		load: backend regS
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
JITAssembler >> loadTrueWithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regTrue
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadTwithA [
	backend move: backend regA to: backend regT
]

{ #category : #loading }
JITAssembler >> loadTwithAindex: index [
	| memref |
	memref := backend memRef: backend regA indexImm: index.
	backend
		load: backend regT
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadTwithEindex: index [
	| memref |
	memref := backend memRef: backend regE indexImm: index.
	backend
		load: backend regT
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadTwithFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		load: backend regT
		fromMem: memref
]

{ #category : #integers }
JITAssembler >> loadTwithImmediate: imm [
	self load: backend regT withImmediate: imm
]

{ #category : #loading }
JITAssembler >> loadTwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTwithMindex: index
]

{ #category : #loading }
JITAssembler >> loadTwithMindex: index [
	| memref |
	memref := backend memRef: backend regM indexImm: index.
	backend
		load: backend regT
		fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadTwithR [
	backend move: backend regR to: backend regT
]

{ #category : #loading }
JITAssembler >> loadTwithTindex: index [
	| memref |
	memref := backend memRef: backend regT indexImm: index.
	backend load: backend regT fromMem: memref
]

{ #category : #loading }
JITAssembler >> loadWithFalse: register [ 
	backend move: backend regFalse to: register
]

{ #category : #loading }
JITAssembler >> loadWithNil: register [ 
	backend move: backend regNil to: register
]

{ #category : #loading }
JITAssembler >> loadWithTrue: register [ 
	backend move: backend regTrue to: register
]

{ #category : #integers }
JITAssembler >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: backend regR from: backend regR atIndexAt: backend regA
]

{ #category : #integers }
JITAssembler >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: backend regR from: backend regR atIndex: index
]

{ #category : #integers }
JITAssembler >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: backend regR from: backend regSP atIndexAt: backend regA
]

{ #category : #integers }
JITAssembler >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: backend regT from: backend regA atIndex: index
]

{ #category : #integers }
JITAssembler >> loadZeroExtendLongRwithRatA [
	| memref |
	memref := backend memRef32: backend regR index: backend regA.
	backend
		load: backend regR
		fromMem: memref
]

{ #category : #integers }
JITAssembler >> loadZeroExtendLongRwithRindex: index [
	| memref |
	#dontOptimize.
	memref := backend memRef32: backend regR indexImm: index.
	backend
		load: backend regR e
		fromMem: memref
]

{ #category : #jumps }
JITAssembler >> loop: aBlock times: anInteger [
	| loop |
	loop := self newLabel.
	self loadTwithImmediate: anInteger; @ loop.
	aBlock value.
	self dec: backend regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
JITAssembler >> loopTtimes: aBlock [
	| loop end |
	loop := self newLabel.
	end := self newLabel.
	self
		compareTwithImmediate: 0;
		@ loop;
		shortJumpIfEqualTo: end.
	aBlock value.
	self
		dec: backend regT;
		shortJumpTo: loop;
		@ end
]

{ #category : #memory }
JITAssembler >> memRef [
	"Return clean instance of pointer-sized memory reference"

	^ backend memRef

]

{ #category : #memory }
JITAssembler >> memRef: baseReg indexImm: indexImm [
	^ backend memRef: baseReg indexImm: indexImm
]

{ #category : #services }
JITAssembler >> move: srcReg to: dstReg [
	^ backend move: srcReg to: dstReg

]

{ #category : #services }
JITAssembler >> moveImm: imm to: dstReg [
	backend moveImm: imm to: dstReg

]

{ #category : #arithmetic }
JITAssembler >> nativeCode [
	^(NativeCode withAll: literals) code: backend memory bytes
]

{ #category : #labels }
JITAssembler >> newLabel [
	| label next |
	next := labels size + 1.
	IndexedLabels size < next ifTrue: [self class growIndexedLabelsTo: next].
	label := IndexedLabels at: next.
	self addLabel: label to: nil.
	^label
]

{ #category : #'operations - logical' }
JITAssembler >> or: src1AndDst with: src2 [
	^ backend or: src1AndDst with: src2
]

{ #category : #'operations - logical' }
JITAssembler >> or: source1andDest withImm: imm [
	backend or: source1andDest withImm: imm
]

{ #category : #logic }
JITAssembler >> orRwithA [
	backend or: backend regR with: backend regA

]

{ #category : #private }
JITAssembler >> pop: dstReg [
	backend pop: dstReg
]

{ #category : #'push/pop' }
JITAssembler >> popA [
	backend pop: backend regA
]

{ #category : #'push/pop' }
JITAssembler >> popE [
	backend pop: backend regE
]

{ #category : #'push/pop' }
JITAssembler >> popFP [
	backend pop: backend regFP
]

{ #category : #'push/pop' }
JITAssembler >> popFalse [
	backend pop: backend regFalse
]

{ #category : #'push/pop' }
JITAssembler >> popG [
	backend pop: backend regG
]

{ #category : #'push/pop' }
JITAssembler >> popM [
	backend pop: backend regM
]

{ #category : #'push/pop' }
JITAssembler >> popNil [
	backend pop: backend regNil
]

{ #category : #'push/pop' }
JITAssembler >> popR [
	backend pop: backend regR
]

{ #category : #'push/pop' }
JITAssembler >> popS [
	backend pop: backend regS
]

{ #category : #'push/pop' }
JITAssembler >> popT [
	backend pop: backend regT
]

{ #category : #'push/pop' }
JITAssembler >> popTrue [
	backend pop: backend regTrue
]

{ #category : #private }
JITAssembler >> push: srcReg [
	backend push: srcReg

]

{ #category : #'push/pop' }
JITAssembler >> pushA [
	backend push: backend regA
]

{ #category : #'push/pop' }
JITAssembler >> pushE [
	backend push: backend regE
]

{ #category : #'push/pop' }
JITAssembler >> pushFP [
	backend push: backend regFP
]

{ #category : #'push/pop' }
JITAssembler >> pushFalse [
	backend push: backend regFalse
]

{ #category : #'push/pop' }
JITAssembler >> pushG [
	backend push: backend regG
]

{ #category : #private }
JITAssembler >> pushImm: imm [
	backend pushImm: imm

]

{ #category : #private }
JITAssembler >> pushIndirectR [
	| memref |
	memref := backend memRef: backend regR indexImm: 1.
	backend pushMem: memref
]

{ #category : #'push/pop' }
JITAssembler >> pushM [
	backend push: backend regM
]

{ #category : #'push/pop' }
JITAssembler >> pushNil [
	backend push: backend regNil
]

{ #category : #'push/pop' }
JITAssembler >> pushR [
	backend push: backend regR
]

{ #category : #'push/pop' }
JITAssembler >> pushS [
	backend push: backend regS
]

{ #category : #arithmetic }
JITAssembler >> pushSmallInteger: integer [
	| smi |
	smi := self smallInteger: integer.
	self pushImm: smi
]

{ #category : #'push/pop' }
JITAssembler >> pushT [
	backend push: backend regT
]

{ #category : #'push/pop' }
JITAssembler >> pushTrue [
	backend push: backend regTrue
]

{ #category : #'registers - IR' }
JITAssembler >> regA [
	^backend regA

]

{ #category : #'registers - IR' }
JITAssembler >> regA8 [
	^ backend regA byte

]

{ #category : #'registers - IR' }
JITAssembler >> regB [
	^ backend regB

]

{ #category : #'registers - IR' }
JITAssembler >> regC [
	^ backend regC
]

{ #category : #'registers - IR' }
JITAssembler >> regE [
	^ backend regE
]

{ #category : #'registers - IR' }
JITAssembler >> regFP [
	^ backend regFP

]

{ #category : #'registers - IR' }
JITAssembler >> regFalse [
	^ backend regFalse

]

{ #category : #'registers - IR' }
JITAssembler >> regG [
	^ backend regG

]

{ #category : #'registers - IR' }
JITAssembler >> regIP [
	^ backend regIP

]

{ #category : #'registers - IR' }
JITAssembler >> regM [
	^ backend regM

]

{ #category : #'registers - IR' }
JITAssembler >> regNil [
	^ backend regNil

]

{ #category : #'registers - IR' }
JITAssembler >> regR [
	^ backend regR

]

{ #category : #'registers - IR' }
JITAssembler >> regR8 [
	^ backend regR byte

]

{ #category : #'registers - IR' }
JITAssembler >> regS [
	^ backend regS
]

{ #category : #'registers - IR' }
JITAssembler >> regSP [
	^ backend regSP

]

{ #category : #'registers - IR' }
JITAssembler >> regT [
	^ backend regT
]

{ #category : #'registers - IR' }
JITAssembler >> regT8 [
	^ backend reg byte
]

{ #category : #'registers - IR' }
JITAssembler >> regTrue [
	^ backend regTrue

]

{ #category : #'registers - IR' }
JITAssembler >> regV [
	^ backend regV

]

{ #category : #'registers - IR' }
JITAssembler >> regX0 [
	"IEEE 754 double register"
	^ backend regX0

]

{ #category : #'registers - IR' }
JITAssembler >> regX1 [
	"IEEE 754 double register"
	^ backend regX1
]

{ #category : #loading }
JITAssembler >> reserveStackSlots: amount [
	backend subImm: amount * backend addressSize from: backend regSP
]

{ #category : #initialization }
JITAssembler >> reset [
	labels := Dictionary new: 100.
	literals := OrderedCollection new.
	backend reset
]

{ #category : #labels }
JITAssembler >> resolveLabel: aString [
	^labels at: aString
]

{ #category : #epilogue }
JITAssembler >> restoreCallerEnvironment [
	self loadEwithFPindex: -2
]

{ #category : #epilogue }
JITAssembler >> restoreCallerFrame [
	backend
		move: backend regFP to: backend regSP;
		pop: backend regFP
]

{ #category : #epilogue }
JITAssembler >> restoreCallerM [
	self loadMwithFPindex: -1
]

{ #category : #epilogue }
JITAssembler >> restoreCallerSelf [
	self loadSwithFPindex: 0
]

{ #category : #loading }
JITAssembler >> saveCallerFrame [
	self pushFP; loadFPwithSP
]

{ #category : #arithmetic }
JITAssembler >> setIntegerBit: srcAndDstReg [
	self setSafeIntegerBit: srcAndDstReg
]

{ #category : #arithmetic }
JITAssembler >> setRintegerBit [
	self setIntegerBit: backend regR8
]

{ #category : #arithmetic }
JITAssembler >> setSafeIntegerBit: srcAndDstReg [
	self or: srcAndDstReg withImm: 1
]

{ #category : #arithmetic }
JITAssembler >> setSafeRintegerBit [
	self setSafeIntegerBit: backend regR8
]

{ #category : #'operations - logical' }
JITAssembler >> shiftLeft: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftLeft: srcAndDst byImm: count [
	backend shiftLeft: srcAndDst byImm: count
]

{ #category : #arithmetic }
JITAssembler >> shiftLeftRwithT [
	backend shiftLeft: backend regR by: backend regT

]

{ #category : #arithmetic }
JITAssembler >> shiftLogicalRright: count [
	backend shiftRight: backend regR byImm: count

]

{ #category : #'operations - logical' }
JITAssembler >> shiftRight: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRight: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRightArithmetic: srcAndDst by: countReg [
	backend shiftRightArithmetic: srcAndDst by: countReg
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRightArithmetic: srcAndDst byImm: count [
	backend shiftRightArithmetic: srcAndDst byImm: count

]

{ #category : #arithmetic }
JITAssembler >> shiftRightRwithT [
	backend shiftRightArithmetic: backend regR by: backend regT

]

{ #category : #arithmetic }
JITAssembler >> shiftRleft: count [
	 backend shiftLeft: backend regR byImm: count

]

{ #category : #arithmetic }
JITAssembler >> shiftRright: count [
	backend shiftRightArithmetic: backend regR byImm: count

]

{ #category : #arithmetic }
JITAssembler >> shiftTright: count [
	backend shiftRightArithmetic: backend regT byImm: count

]

{ #category : #jumps }
JITAssembler >> shortJumpIfNotZeroTo: label [
	self shortJumpIfNotEqualTo: label
]

{ #category : #jumps }
JITAssembler >> shortJumpIfZeroTo: label [
	self shortJumpIfEqualTo: label
]

{ #category : #comparing }
JITAssembler >> smallInteger: anInteger [
	^(anInteger bitShift: 1) + 1
]

{ #category : #'memory - load / store' }
JITAssembler >> store: srcReg intoMem: dstMemRef [
	"Store `srcReg` into memory location `dstMemRef`. 

	 The size of data loaded is specified in `dstMemRef`"

	^ backend store: srcReg intoMem: dstMemRef 

]

{ #category : #storing }
JITAssembler >> storeAinTindex: index [
	| memref |
	memref := backend memRef: backend regT indexImm: index.
	backend
		store: backend regA
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeEinRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		store: backend regE
		intoMem: memref
]

{ #category : #'memory - load / store' }
JITAssembler >> storeImm: imm intoMem: dstMemRef [
	"Store constant into memory location `dstMemRef`. 

	 The size of data loaded is specified in `dstMemRef`"

	self
		moveImm: imm to: self regV;
		store: self regV intoMem: dstMemRef
]

{ #category : #storing }
JITAssembler >> storeLongTinRatA [
	| memref |
	memref := backend memRef32: backend regR index: backend regA.
	backend
		store: backend regT
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeRinAindex: index [
	| memref |
	memref := backend memRef: backend regA indexImm: index.
	backend
		store: backend regR
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeRinEindex: index [
	| memref |
	memref := backend memRef: backend regE indexImm: index.
	backend
		store: backend regR
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeRinFPindex: index [
	| memref |
	memref := backend memRef: backend regFP indexImm: index.
	backend
		store: backend regR
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeRinSindex: index [
	| memref |
	memref := backend memRef: backend regS indexImm: index.
	backend
		store: backend regR
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeRinTindex: index [
	| memref |
	memref := backend memRef: backend regT indexImm: index.
	backend
		store: backend regR
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeSinRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		store: backend regS
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeTinRatA [
	| memref |
	memref := backend memRef: backend regR index: backend regA.
	backend
		store: backend regT
		intoMem: memref
]

{ #category : #storing }
JITAssembler >> storeTinRindex: index [
	| memref |
	memref := backend memRef: backend regR indexImm: index.
	backend
		store: backend regT
		intoMem: memref
]

{ #category : #'operations - arithmetic' }
JITAssembler >> sub: src2 from: src1AndDst [
	backend sub: src2  from: src1AndDst

]

{ #category : #arithmetic }
JITAssembler >> subAfromR [
	backend sub: backend regA from: backend regR

]

{ #category : #arithmetic }
JITAssembler >> subAfromT [
	backend sub: backend regA from: backend regT    

]

{ #category : #arithmetic }
JITAssembler >> subFromRconstant: imm [
	backend subImm: imm from: backend regR

]

{ #category : #'operations - arithmetic' }
JITAssembler >> subImm: imm from: srcAndDst [
	backend subImm: imm from: srcAndDst

]

{ #category : #initialization }
JITAssembler >> useAMD64 [
	backend := JITAssemblerAMD64 new wordSize: 8.
	self reset
]

{ #category : #'operations - logical' }
JITAssembler >> xor: src1AndDst with: src2 [
	^ self subclassResponsibility

]

{ #category : #logic }
JITAssembler >> xorAwithR [
	backend xor: backend regA with: backend regR

]

{ #category : #logic }
JITAssembler >> xorFPwithFP [
	backend xor: backend regFP with: backend regFP

]

{ #category : #logic }
JITAssembler >> xorRwithA [
	backend xor: backend regR with: backend regA

]
