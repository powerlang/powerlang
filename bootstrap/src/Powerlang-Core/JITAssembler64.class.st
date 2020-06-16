"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #JITAssembler64,
	#superclass : #Assembler64,
	#classVars : [
		'ExternalFunctions'
	],
	#category : #'Powerlang-Core-Assembler-JIT'
}

{ #category : #inspecting }
JITAssembler64 class >> aspects [
	^#(#disassembledText32 #disassembledText64)
]

{ #category : #initialization }
JITAssembler64 class >> initialize [
	super initialize.
	ExternalFunctions := Dictionary new
]

{ #category : #arithmetic }
JITAssembler64 >> addAtoR [
	self assemble: 'add' with: self regR with: self regA
]

{ #category : #arithmetic }
JITAssembler64 >> addDoubleX1toX0 [
	self assemble: 'addsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssembler64 >> addRconstant: imm [
	self assemble: 'add' with: self regR withImm: imm
]

{ #category : #arithmetic }
JITAssembler64 >> addSPtoT [
	self assemble: 'add' with: self regT with: self regSP
]

{ #category : #logic }
JITAssembler64 >> addSPwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'add' with: self regSP withImm: imm
]

{ #category : #arithmetic }
JITAssembler64 >> addSslotsToSP [
	pointer
		reset;
		length: self addressLength;
		base: self regSP;
		index: self regS;
		scale: self regSP sizeInBytes.
	self assemble: 'lea' with: self regSP with: pointer
]

{ #category : #arithmetic }
JITAssembler64 >> addToTconstant: imm [
	self assemble: 'add' with: self regT withImm: imm
]

{ #category : #arithmetic }
JITAssembler64 >> addTslotsToSP [
	pointer
		reset;
		length: self addressLength;
		base: self regSP;
		index: self regT;
		scale: self regSP sizeInBytes.
	self assemble: 'lea' with: self regSP with: pointer
]

{ #category : #arithmetic }
JITAssembler64 >> addTtoR [
	self assemble: 'add' with: self regR with: self regT
]

{ #category : #services }
JITAssembler64 >> addressOfExternal: function [
	^ExternalFunctions at: function ifAbsent: nil
]

{ #category : #logic }
JITAssembler64 >> andRwithA [
	self assemble: 'and' with: self regR with: self regA
]

{ #category : #logic }
JITAssembler64 >> andRwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'and' with: self regR withImm: imm
]

{ #category : #logic }
JITAssembler64 >> andTosWithImmediate: anInteger [
	#imm8.
	#imm32.
	pointer reset; length: self addressLength; base: self regSP.
	self assemble: 'and' with: pointer withImm: anInteger
]

{ #category : #private }
JITAssembler64 >> buildFrame [
	self
		push: self regFP;
		move: self regSP to: self regFP
]

{ #category : #private }
JITAssembler64 >> callA [
	self assemble: 'call' with: self regA
]

{ #category : #private }
JITAssembler64 >> callIndirectA [
	pointer reset; length: self addressLength; base: self regA.
	self assemble: 'call' with: pointer
]

{ #category : #private }
JITAssembler64 >> callR [
	self assemble: 'call' with: self regR
]

{ #category : #integers }
JITAssembler64 >> clearAintegerBit [
	self assemble: 'dec' with: self regA
]

{ #category : #loading }
JITAssembler64 >> clearFPUFlags [
	self assemble: 'fnclex'
]

{ #category : #integers }
JITAssembler64 >> clearRhighHalf [
	self assemble: 'mov' with: self regR e with: self regR e
]

{ #category : #integers }
JITAssembler64 >> clearRintegerBit [
	self assemble: 'dec' with: self regR
]

{ #category : #integers }
JITAssembler64 >> clearSafeRintegerBit [
	immediate value: 16rFE; length: 8.
	self assemble: 'and' with: al with: immediate
]

{ #category : #comparing }
JITAssembler64 >> compareAwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regA withImm: imm
]

{ #category : #comparing }
JITAssembler64 >> compareAwithSmallInteger: anInteger [
	self compareAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssembler64 >> compareEqualLargeX0withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'cmpsd' with: xmm0 with: pointer with: 0
]

{ #category : #loading }
JITAssembler64 >> compareLessThanLargeX0withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'cmpsd' with: xmm0 with: pointer with: 1
]

{ #category : #comparing }
JITAssembler64 >> compareRwithA [
	self assemble: 'cmp' with: self regR with: self regA
]

{ #category : #comparing }
JITAssembler64 >> compareRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareRwithTrue ]
		ifFalse: [ self compareRwithFalse ]
]

{ #category : #loading }
JITAssembler64 >> compareRwithEindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regE index: index
]

{ #category : #loading }
JITAssembler64 >> compareRwithFPindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regFP index: index
]

{ #category : #comparing }
JITAssembler64 >> compareRwithFalse [
	self assemble: 'cmp' with: self regR with: self regFalse
]

{ #category : #comparing }
JITAssembler64 >> compareRwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regR withImm: imm
]

{ #category : #comparing }
JITAssembler64 >> compareRwithIndirect: object [
	wordSize = 8
		ifTrue: [^self loadVwithPointer: object; compareRwithVindex: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'cmp' with: self regR with: pointer;
		holdReferenceTo: object
]

{ #category : #storing }
JITAssembler64 >> compareRwithIndirect: reg1 andExchange: reg2 [
	pointer reset; length: self addressLength; base: reg1.
	self assemble: 'cmpxchg' with: pointer with: reg2
]

{ #category : #comparing }
JITAssembler64 >> compareRwithPointer: object [
	self compareRwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #comparing }
JITAssembler64 >> compareRwithS [
	self assemble: 'cmp' with: self regR with: self regS
]

{ #category : #loading }
JITAssembler64 >> compareRwithSindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regS index: index
]

{ #category : #comparing }
JITAssembler64 >> compareRwithSmallInteger: anInteger [
	self compareRwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #comparing }
JITAssembler64 >> compareRwithTrue [
	self assemble: 'cmp' with: self regR with: self regTrue
]

{ #category : #loading }
JITAssembler64 >> compareRwithVindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regV index: index
]

{ #category : #loading }
JITAssembler64 >> compareSwithTindex: index [
	self assemble: 'cmp' withReg: self regS withReg: self regT index: index
]

{ #category : #comparing }
JITAssembler64 >> compareTwithA [
	self assemble: 'cmp' with: self regT with: self regA
]

{ #category : #comparing }
JITAssembler64 >> compareTwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regT withImm: imm
]

{ #category : #integers }
JITAssembler64 >> convertAtoNativeInteger [
	self convertToNativeInteger: self regA
]

{ #category : #integers }
JITAssembler64 >> convertAtoSmallInteger [
	self convertToSmallInteger: self regA
]

{ #category : #integers }
JITAssembler64 >> convertRtoNativeInteger [
	self convertToNativeInteger: self regR
]

{ #category : #integers }
JITAssembler64 >> convertRtoSmallInteger [
	self convertToSmallInteger: self regR
]

{ #category : #integers }
JITAssembler64 >> convertTToNativeInteger [
	self convertToNativeInteger: self regT
]

{ #category : #integers }
JITAssembler64 >> convertTosToSmallInteger [
	pointer reset; length: self addressLength; base: self regSP.
	self
		assemble: 'shl' with: pointer with: 1;
		assemble: 'inc' with: pointer
]

{ #category : #integers }
JITAssembler64 >> convertTtoNativeInteger [
	self convertToNativeInteger: self regT
]

{ #category : #jumps }
JITAssembler64 >> dec: op1 [
	self assemble: 'dec' with: op1
]

{ #category : #arithmetic }
JITAssembler64 >> decR [
	self assemble: 'dec' with: self regR
]

{ #category : #private }
JITAssembler64 >> decRindirect [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'dec' with: pointer
]

{ #category : #services }
JITAssembler64 >> disassembledText32 [
	^self nativeCode disassembledText32
]

{ #category : #services }
JITAssembler64 >> disassembledText64 [
	^self nativeCode disassembledText64
]

{ #category : #private }
JITAssembler64 >> discardArguments: anInteger [
	anInteger = 0 ifTrue: [^self].
	self addSPwithImmediate: anInteger * wordSize
]

{ #category : #arithmetic }
JITAssembler64 >> divideDoubleX0byX1 [
	self assemble: 'divsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssembler64 >> divideRbyT [
	| conversion |
	self ASSERT: (self regR r == rax and: [self regA r == rdx]).
	conversion := wordSize = 8 ifTrue: ['cqo'] ifFalse: ['cdq'].
	self
		assemble: conversion;
		assemble: 'idiv' with: self regT
]

{ #category : #loading }
JITAssembler64 >> dropTopOfFPU [
	"
	fstp st(0)
	"
	self assembleBytes: #[16rDD 16rD8]
]

{ #category : #'push/pop' }
JITAssembler64 >> dropTos: count [
	| imm |
	imm := count * self addressSize.
	self assemble: 'add' with: self regSP with: imm
]

{ #category : #loading }
JITAssembler64 >> dummyPointer [
	#dontOptimize.
	^wordSize = 8 ifTrue: [16r1BADADD01BADADD0] ifFalse: [16r1BADADD0]
]

{ #category : #integers }
JITAssembler64 >> ensureRintegerBit [
	self assemble: 'or' with: al with: 1
]

{ #category : #integers }
JITAssembler64 >> ensureSafeRintegerBit [
	self assemble: 'or' with: al with: 1
]

{ #category : #loading }
JITAssembler64 >> exchangeRindirectWithT [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'xchg' with: pointer with: self regT
]

{ #category : #arithmetic }
JITAssembler64 >> incA [
	self assemble: 'inc' with: self regA
]

{ #category : #arithmetic }
JITAssembler64 >> incC [
	self assemble: 'inc' with: self regC
]

{ #category : #private }
JITAssembler64 >> initializeS [
	self assemble: 'mov' with: self regS with: self regR
]

{ #category : #private }
JITAssembler64 >> jumpIndirectA [
	pointer reset; length: self addressLength; base: self regA.
	self assemble: 'jmp' with: pointer
]

{ #category : #comparing }
JITAssembler64 >> jumpToA [
	self assemble: 'jmp' with: self regA
]

{ #category : #comparing }
JITAssembler64 >> jumpToS [
	self assemble: 'jmp' with: self regS
]

{ #category : #loading }
JITAssembler64 >> jumpToTindex: index [
	self assemble: 'jmp' withReg: self regT index: index
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfZeroTo: label.
	^label
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerBitTestOfA [
	^self labeledIntegerBitTestOf: self regA8
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: self regR8
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: self regT byte
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerNativizationOf: aRegister [
	| label |
	self convertToNativeInteger: aRegister.
	label := self newLabel.
	self shortJumpIfNotCarryTo: label.
	^label
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerNativizationOfA [
	^self labeledIntegerNativizationOf: self regA
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: self regR
]

{ #category : #integers }
JITAssembler64 >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: self regT
]

{ #category : #integers }
JITAssembler64 >> labeledNonIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfNotZeroTo: label.
	^label
]

{ #category : #integers }
JITAssembler64 >> labeledNonIntegerBitTestOfR [
	^self labeledNonIntegerBitTestOf: self regR8
]

{ #category : #loading }
JITAssembler64 >> loadAwithAindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regA index: index
]

{ #category : #loading }
JITAssembler64 >> loadAwithBoolean: aBoolean [
	aBoolean ifTrue: [self loadAwithTrue]
	ifFalse: [self loadAwithFalse]

]

{ #category : #loading }
JITAssembler64 >> loadAwithEindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regE index: index
]

{ #category : #loading }
JITAssembler64 >> loadAwithFPindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regFP index: index
]

{ #category : #loading }
JITAssembler64 >> loadAwithFalse [
	self assemble: 'mov' with: self regA with: self regFalse
]

{ #category : #loading }
JITAssembler64 >> loadAwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regA withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadAwithIndirect: object [
	wordSize = 8 ifTrue: [^self loadAwithPointer: object; loadAwithAindex: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'mov' with: self regA with: pointer;
		holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadAwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regA
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssembler64 >> loadAwithNil [
	self assemble: 'mov' with: self regA with: self regNil
]

{ #category : #loading }
JITAssembler64 >> loadAwithPointer: object [
	self loadAwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadAwithR [
	self assemble: 'mov' with: self regA with: self regR
]

{ #category : #loading }
JITAssembler64 >> loadAwithRindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regR index: index
]

{ #category : #loading }
JITAssembler64 >> loadAwithRoffsetAtA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regA with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadAwithS [
	self assemble: 'mov' with: self regA with: self regS
]

{ #category : #loading }
JITAssembler64 >> loadAwithSindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regS index: index
]

{ #category : #integers }
JITAssembler64 >> loadAwithSmallInteger: anInteger [
	self loadAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssembler64 >> loadAwithT [
	self assemble: 'mov' with: self regA with: self regT
]

{ #category : #loading }
JITAssembler64 >> loadAwithTrue [
	self assemble: 'mov' with: self regA with: self regTrue
]

{ #category : #integers }
JITAssembler64 >> loadEwithAddressOfRatA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA;
		scale: self regE sizeInBytes;
		displacement: 0 - self regE sizeInBytes.
	self assemble: 'lea' with: self regE with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadEwithFPindex: index [
	self assemble: 'mov' withReg: self regE withReg: self regFP index: index
]

{ #category : #loading }
JITAssembler64 >> loadEwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regE withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadEwithNil [
	self assemble: 'mov' with: self regE with: self regNil
]

{ #category : #loading }
JITAssembler64 >> loadEwithPointer: object [
	self loadEwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadEwithR [
	self assemble: 'mov' with: self regE with: self regR
]

{ #category : #loading }
JITAssembler64 >> loadFPwithR [
	self assemble: 'mov' with: self regFP with: self regR
]

{ #category : #loading }
JITAssembler64 >> loadFPwithSP [
	self assemble: 'mov' with: self regFP with: self regSP
]

{ #category : #loading }
JITAssembler64 >> loadLargeX0withRindirect [
	pointer reset; length: 64; base: self regR.
	self assemble: 'movq' with: xmm0 with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadLargeX1withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'movq' with: xmm1 with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadLongRWithRAtOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR e with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadLongRwithRatOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR e with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadLongSwithRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 32;
		base: self regR;
		displacement: index - 1 * 4.
	self assemble: 'mov' with: self regS e with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadMXCSRfromA [
	pointer reset; length: 32; base: self regA.
	self assemble: 'ldmxcsr' with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRConvertingDoubleRindirect [
	pointer reset; length: 64; base: self regR.
	self assemble: 'cvttsd2si' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRconvertingDoublePointedByR [
	pointer reset; length: 64; base: self regR.
	self assemble: 'cvttsd2si' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRwithA [
	self assemble: 'mov' with: self regR with: self regA
]

{ #category : #loading }
JITAssembler64 >> loadRwithArgPointer [
	pointer
		reset;
		length: self addressLength;
		base: self regFP;
		displacement: wordSize * 2.
	self assemble: 'lea' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self loadRwithTrue ]
		ifFalse: [ self loadRwithFalse ]
]

{ #category : #loading }
JITAssembler64 >> loadRwithE [
	self assemble: 'mov' with: self regR with: self regE
]

{ #category : #loading }
JITAssembler64 >> loadRwithEindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regE index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithFP [
	self assemble: 'mov' with: self regR with: self regFP
]

{ #category : #loading }
JITAssembler64 >> loadRwithFPindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regFP index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithFalse [
	self assemble: 'mov' with: self regR with: self regFalse
]

{ #category : #loading }
JITAssembler64 >> loadRwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regR withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadRwithIndirect: object [
	wordSize = 8 ifTrue: [^self loadRwithPointer: object; loadRwithRindex: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'mov' with: self regR with: pointer;
		holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadRwithM [
	self assemble: 'mov' with: self regR with: self regM
]

{ #category : #loading }
JITAssembler64 >> loadRwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regR
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithNil [
	self assemble: 'mov' with: self regR with: self regNil
]

{ #category : #loading }
JITAssembler64 >> loadRwithPointer: object [
	self loadRwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #integers }
JITAssembler64 >> loadRwithRatA [
	self load: self regR from: self regR atIndexAt: self regA
]

{ #category : #loading }
JITAssembler64 >> loadRwithRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRwithRbyte: index [
	pointer
		reset;
		length: 8;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'mov' with: self regR b with: pointer;
		andRwithImmediate: 16rFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssembler64 >> loadRwithRindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regR index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithRwordAt: index [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'mov' with: self regR with: pointer;
		andRwithImmediate: 16rFFFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssembler64 >> loadRwithS [
	self assemble: 'mov' with: self regR with: self regS
]

{ #category : #loading }
JITAssembler64 >> loadRwithSPindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regSP index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithSbyte: index [
	pointer
		reset;
		length: 8;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'mov' with: self regR b with: pointer;
		andRwithImmediate: 16rFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssembler64 >> loadRwithSindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regS index: index
]

{ #category : #integers }
JITAssembler64 >> loadRwithSmallInteger: anInteger [
	self loadRwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssembler64 >> loadRwithSwordAt: index [
	pointer
		reset;
		length: 16;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'mov' with: self regR w with: pointer;
		andRwithImmediate: 16rFFFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssembler64 >> loadRwithT [
	self assemble: 'mov' with: self regR with: self regT
]

{ #category : #storing }
JITAssembler64 >> loadRwithTIBatIndexR [
	| seg |
	seg := wordSize = 8 ifTrue: [gs] ifFalse: [fs].
	pointer
		reset;
		length: self addressLength;
		index: self regR;
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #storing }
JITAssembler64 >> loadRwithThreadVariableAtIndexR [
	pointer
		reset;
		length: self addressLength;
		index: self regR;
		scale: wordSize.
	wordSize = 8
		ifTrue: [pointer segment: gs; displacement: 16r1480]
		ifFalse: [pointer segment: fs; displacement: 16rE10].
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRwithTindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regT index: index
]

{ #category : #loading }
JITAssembler64 >> loadRwithTos [
	pointer reset; length: self addressLength; base: self regSP.
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadRwithTrue [
	self assemble: 'mov' with: self regR with: self regTrue
]

{ #category : #loading }
JITAssembler64 >> loadRwithX0 [
	| mov |
	mov := wordSize = 8 ifTrue: ['movq'] ifFalse: ['movd'].
	self assemble: mov with: self regR with: xmm0
]

{ #category : #loading }
JITAssembler64 >> loadSPwithFP [
	self assemble: 'mov' with: self regSP with: self regFP
]

{ #category : #loading }
JITAssembler64 >> loadSPwithT [
	self assemble: 'mov' with: self regSP with: self regT
]

{ #category : #loading }
JITAssembler64 >> loadSWithRIndex: index [
	self load: self regS from: self regR atIndex: index
]

{ #category : #loading }
JITAssembler64 >> loadSwithA [
	self assemble: 'mov' with: self regS with: self regA
]

{ #category : #integers }
JITAssembler64 >> loadSwithAddressOfSatA [
	pointer
		reset;
		length: self addressLength;
		base: self regS;
		index: self regA;
		scale: self regS sizeInBytes;
		displacement: 0 - self regS sizeInBytes.
	self assemble: 'lea' with: self regS with: pointer
]

{ #category : #loading }
JITAssembler64 >> loadSwithFPindex: index [
	self assemble: 'mov' withReg: self regS withReg: self regFP index: index
]

{ #category : #loading }
JITAssembler64 >> loadSwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regS withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadSwithNil [
	self assemble: 'mov' with: self regS with: self regNil
]

{ #category : #loading }
JITAssembler64 >> loadSwithPointer: object [
	self loadSwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadSwithRindex: index [
	self assemble: 'mov' withReg: self regS withReg: self regR index: index
]

{ #category : #loading }
JITAssembler64 >> loadSwithT [
	self assemble: 'mov' with: self regS with: self regT
]

{ #category : #loading }
JITAssembler64 >> loadTwithA [
	self assemble: 'mov' with: self regT with: self regA
]

{ #category : #loading }
JITAssembler64 >> loadTwithAindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regA index: index
]

{ #category : #loading }
JITAssembler64 >> loadTwithEindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regE index: index
]

{ #category : #loading }
JITAssembler64 >> loadTwithFPindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regFP index: index
]

{ #category : #loading }
JITAssembler64 >> loadTwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regT withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadTwithIndirect: object [
	wordSize = 8 ifTrue: [^self loadTwithPointer: object; loadTwithTindex: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'mov' with: self regT with: pointer;
		holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadTwithPointer: object [
	self loadTwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadTwithR [
	self assemble: 'mov' with: self regT with: self regR
]

{ #category : #loading }
JITAssembler64 >> loadTwithTindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regT index: index
]

{ #category : #loading }
JITAssembler64 >> loadVwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regV withImm: imm
]

{ #category : #loading }
JITAssembler64 >> loadVwithPointer: object [
	self loadVwithImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #loading }
JITAssembler64 >> loadX0withRasDouble [
	self assemble: 'cvtsi2sd' with: xmm0 with: self regR
]

{ #category : #loading }
JITAssembler64 >> loadX1roundingX0 [
	self assemble: 'roundsd' with: xmm1 with: xmm0 with: 3
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: self regR from: self regR atIndexAt: self regA
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: self regR from: self regR atIndex: index
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: self regR from: self regSP atIndexAt: self regA
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: self regT from: self regA atIndex: index
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendLongRwithRatA [
	self load: self regR e from: self regR atIndexAt: self regA
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendLongRwithRindex: index [
	#dontOptimize.
	self load: self regR e from: self regR atIndex: index
]

{ #category : #integers }
JITAssembler64 >> loadZeroExtendShortRwithRoffset: offset [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: offset.
	self assemble: 'movzx' with: self regR with: pointer
]

{ #category : #arithmetic }
JITAssembler64 >> lock [
	self assembleByte: 16rF0
]

{ #category : #jumps }
JITAssembler64 >> loop: aBlock times: anInteger [
	| loop |
	loop := self newLabel.
	self loadTwithImmediate: anInteger; @ loop.
	aBlock value.
	self dec: self regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
JITAssembler64 >> loopTo: label [
	self
		assemble: 'dec' with: self regT;
		jumpIfNotZeroTo: label
]

{ #category : #jumps }
JITAssembler64 >> loopTtimes: aBlock [
	| loop end |
	loop := self newLabel.
	end := self newLabel.
	self
		compareTwithImmediate: 0;
		@ loop;
		shortJumpIfEqualTo: end.
	aBlock value.
	self
		dec: self regT;
		shortJumpTo: loop;
		@ end
]

{ #category : #'opcodes - integer related' }
JITAssembler64 >> moveTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['movsq'] ifFalse: ['movsd'].
	self assembleByte: rep; assemble: mnemonic
]

{ #category : #arithmetic }
JITAssembler64 >> multiplyDoubleX0byX1 [
	self assemble: 'mulsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssembler64 >> multiplyRbyA [
	self ASSERT: (self regR r == rax and: [self regA r == rdx]).
	self assemble: 'imul' with: self regA
]

{ #category : #arithmetic }
JITAssembler64 >> multiplyRbyConstant: imm [
	self assemble: 'imul' with: self regR with: self regR with: imm
]

{ #category : #logic }
JITAssembler64 >> orRwithA [
	self assemble: 'or' with: self regR with: self regA
]

{ #category : #'push/pop' }
JITAssembler64 >> popA [
	self assemble: 'pop' with: self regA
]

{ #category : #'push/pop' }
JITAssembler64 >> popB [
	self assemble: 'pop' with: self regB
]

{ #category : #'push/pop' }
JITAssembler64 >> popE [
	self assemble: 'pop' with: self regE
]

{ #category : #'push/pop' }
JITAssembler64 >> popFP [
	self assemble: 'pop' with: self regFP
]

{ #category : #'push/pop' }
JITAssembler64 >> popR [
	self assemble: 'pop' with: self regR
]

{ #category : #'push/pop' }
JITAssembler64 >> popS [
	self assemble: 'pop' with: self regS
]

{ #category : #'push/pop' }
JITAssembler64 >> popSP [
	self assemble: 'pop' with: self regSP
]

{ #category : #'push/pop' }
JITAssembler64 >> popSPindirect [
	pointer reset; length: self addressLength; base: self regSP.
	self assemble: 'pop' with: pointer
]

{ #category : #'push/pop' }
JITAssembler64 >> popT [
	self assemble: 'pop' with: self regT
]

{ #category : #'push/pop' }
JITAssembler64 >> pushA [
	self assemble: 'push' with: self regA
]

{ #category : #loading }
JITAssembler64 >> pushAOnFPUStack [
	pointer reset; length: 64; base: self regA.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssembler64 >> pushAatToffset: offset [
	pointer
		reset;
		length: self addressLength;
		base: self regA;
		index: self regT;
		scale: self regSP sizeInBytes;
		displacement: offset.
	self assemble: 'push' with: pointer
]

{ #category : #'push/pop' }
JITAssembler64 >> pushB [
	self assemble: 'push' with: self regB
]

{ #category : #'push/pop' }
JITAssembler64 >> pushE [
	self assemble: 'push' with: self regE
]

{ #category : #'push/pop' }
JITAssembler64 >> pushEindex: index [
	self assemble: 'push' withReg: self regE index: index
]

{ #category : #'push/pop' }
JITAssembler64 >> pushFP [
	self assemble: 'push' with: self regFP
]

{ #category : #'push/pop' }
JITAssembler64 >> pushFPindex: index [
	self assemble: 'push' withReg: self regFP index: index
]

{ #category : #'push/pop' }
JITAssembler64 >> pushImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'push' withImm: imm
]

{ #category : #'push/pop' }
JITAssembler64 >> pushIndirect: object [
	wordSize = 8 ifTrue: [^self loadVwithPointer: object; pushVindex: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'push' with: pointer;
		holdReferenceTo: object
]

{ #category : #'push/pop' }
JITAssembler64 >> pushIndirectR [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'push' with: pointer
]

{ #category : #'push/pop' }
JITAssembler64 >> pushM [
	self assemble: 'push' with: self regM
]

{ #category : #'push/pop' }
JITAssembler64 >> pushNil [
	self assemble: 'push' with: self regNil
]

{ #category : #'push/pop' }
JITAssembler64 >> pushPointer: object [
	self pushImmediate: self dummyPointer; holdReferenceTo: object
]

{ #category : #'push/pop' }
JITAssembler64 >> pushR [
	self assemble: 'push' with: self regR
]

{ #category : #loading }
JITAssembler64 >> pushROnFPUStack [
	pointer reset; length: 64; base: self regR.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssembler64 >> pushRbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andTosWithImmediate: 16rFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssembler64 >> pushRwordAt: index [
	pointer
		halt;
		reset;
		length: self addressLength;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andTosWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssembler64 >> pushS [
	self assemble: 'push' with: self regS
]

{ #category : #'push/pop' }
JITAssembler64 >> pushSP [
	self assemble: 'push' with: self regSP
]

{ #category : #'push/pop' }
JITAssembler64 >> pushSbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andTosWithImmediate: 16rFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssembler64 >> pushSindex: index [
	self assemble: 'push' withReg: self regS index: index
]

{ #category : #'push/pop' }
JITAssembler64 >> pushSmallInteger: integer [
	self pushImmediate: (integer bitShift: 1) + 1
]

{ #category : #'push/pop' }
JITAssembler64 >> pushSwordAt: index [
	pointer
		reset;
		length: self addressLength;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andTosWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssembler64 >> pushT [
	self assemble: 'push' with: self regT
]

{ #category : #'push/pop' }
JITAssembler64 >> pushTindex: index [
	self assemble: 'push' withReg: self regT index: index
]

{ #category : #'push/pop' }
JITAssembler64 >> pushVindex: index [
	self assemble: 'push' withReg: self regV index: index
]

{ #category : #services }
JITAssembler64 >> readFPUStatusOnA [
	pointer reset; length: 16; base: self regA.
	self assemble: 'fstsw' with: pointer
]

{ #category : #private }
JITAssembler64 >> regA [
	^wordSize = 8 ifTrue: [rdx] ifFalse: [edx]
]

{ #category : #private }
JITAssembler64 >> regA8 [
	^dl
]

{ #category : #private }
JITAssembler64 >> regB [
	^wordSize = 8 ifTrue: [rbx] ifFalse: [ebx]
]

{ #category : #private }
JITAssembler64 >> regC [
	^wordSize = 8 ifTrue: [rbx] ifFalse: [ebx]
]

{ #category : #private }
JITAssembler64 >> regE [
	^wordSize = 8 ifTrue: [rdi] ifFalse: [edi]
]

{ #category : #private }
JITAssembler64 >> regFP [
	^wordSize = 8 ifTrue: [rbp] ifFalse: [ebp]
]

{ #category : #private }
JITAssembler64 >> regFalse [
	^ r14
]

{ #category : #private }
JITAssembler64 >> regM [
	^rbx
]

{ #category : #private }
JITAssembler64 >> regNil [
	^ r12
]

{ #category : #private }
JITAssembler64 >> regR [
	^wordSize = 8 ifTrue: [rax] ifFalse: [eax]
]

{ #category : #private }
JITAssembler64 >> regR8 [
	^al
]

{ #category : #private }
JITAssembler64 >> regS [
	^wordSize = 8 ifTrue: [rsi] ifFalse: [esi]
]

{ #category : #private }
JITAssembler64 >> regSP [
	^wordSize = 8 ifTrue: [rsp] ifFalse: [esp]
]

{ #category : #private }
JITAssembler64 >> regT [
	^wordSize = 8 ifTrue: [rcx] ifFalse: [ecx]
]

{ #category : #private }
JITAssembler64 >> regTrue [
	^ r13
]

{ #category : #private }
JITAssembler64 >> reserveStackSlots: amount [
	self subtract: amount * self addressSize from: self regSP
]

{ #category : #epilogue }
JITAssembler64 >> restoreCallerEnvironment [
	self loadEwithFPindex: -2
]

{ #category : #epilogue }
JITAssembler64 >> restoreCallerFrame [
	self
		move: self regFP to: self regSP;
		pop: self regFP
]

{ #category : #epilogue }
JITAssembler64 >> restoreCallerSelf [
	self loadSwithFPindex: 0
]

{ #category : #integers }
JITAssembler64 >> restoreRSmallInteger [
	self assemble: 'rcl' with: self regR with: 1
]

{ #category : #integers }
JITAssembler64 >> restoreRsmallInteger [
	self assemble: 'rcl' with: self regR with: 1
]

{ #category : #services }
JITAssembler64 >> returnFromCallback: argCount [
	wordSize = 4 ifTrue: [self return: argCount] ifFalse: [self return]
]

{ #category : #loading }
JITAssembler64 >> saveCallerFrame [
	self pushFP; loadFPwithSP
]

{ #category : #loading }
JITAssembler64 >> scaleFloatOnRWithA [
	self pushAOnFPUStack; pushROnFPUStack; assemble: 'fscale'.
	pointer reset; length: 64; base: self regR.
	self assemble: 'fstp' with: pointer; dropTopOfFPU
]

{ #category : #arithmetic }
JITAssembler64 >> shiftLeftRwithT [
	self ASSERT: self regT r == rcx.
	self assemble: 'sal' with: self regR with: self regT b
]

{ #category : #arithmetic }
JITAssembler64 >> shiftLogicalRright: count [
	self ASSERT: count < 32.
	self assemble: 'shr' with: self regR with: count
]

{ #category : #arithmetic }
JITAssembler64 >> shiftRightRwithT [
	self ASSERT: self regT r == rcx.
	self assemble: 'sar' with: self regR with: self regT b
]

{ #category : #arithmetic }
JITAssembler64 >> shiftRleft: count [
	self ASSERT: count < 32.
	self assemble: 'sal' with: self regR with: count
]

{ #category : #arithmetic }
JITAssembler64 >> shiftRright: count [
	self ASSERT: count < (wordSize * 8).
	self assemble: 'sar' with: self regR with: count
]

{ #category : #arithmetic }
JITAssembler64 >> shiftTleft: count [
	self ASSERT: count < 32.
	self assemble: 'sal' with: self regT with: count
]

{ #category : #arithmetic }
JITAssembler64 >> shiftTright: count [
	self ASSERT: count < 32.
	self assemble: 'sar' with: self regT with: count
]

{ #category : #arithmetic }
JITAssembler64 >> sqrtDoubleX0 [
	self assemble: 'sqrtsd' with: xmm0 with: xmm0
]

{ #category : #storing }
JITAssembler64 >> storeAinRindex: index [
	self store: self regA in: self regR index: index
]

{ #category : #storing }
JITAssembler64 >> storeAinSPatT [
	self store: self regA in: self regSP indexAt: self regT
]

{ #category : #storing }
JITAssembler64 >> storeAinThreadVariableAtIndexR [
	pointer
		reset;
		length: self addressLength;
		index: self regR;
		scale: wordSize.
	wordSize = 8
		ifTrue: [pointer segment: gs; displacement: 16r1480]
		ifFalse: [pointer segment: fs; displacement: 16rE10].
	self assemble: 'mov' with: pointer with: self regA
]

{ #category : #storing }
JITAssembler64 >> storeAinTindex: index [
	self store: self regA in: self regT index: index
]

{ #category : #integers }
JITAssembler64 >> storeArgumentsInStack [
	self
		store: rcx in: rbp index: 3;
		store: rdx in: rbp index: 4;
		store: r8 in: rbp index: 5;
		store: r9 in: rbp index: 6
]

{ #category : #storing }
JITAssembler64 >> storeByteAinRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 8;
		base: self regR;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: self regA b
]

{ #category : #storing }
JITAssembler64 >> storeByteTinRatA [
	pointer
		reset;
		length: 8;
		base: self regR;
		index: self regA;
		displacement: -1.
	self assemble: 'mov' with: pointer with: self regT b
]

{ #category : #'push/pop' }
JITAssembler64 >> storeDoubleResultInRindirect [
	pointer reset; length: 64; base: self regR.
	wordSize = 8
		ifTrue: [self assemble: 'movq' with: pointer with: xmm0]
		ifFalse: [self assemble: 'fstp' with: pointer]
]

{ #category : #storing }
JITAssembler64 >> storeEinAindex: index [
	self store: self regE in: self regA index: index
]

{ #category : #storing }
JITAssembler64 >> storeEinRindex: index [
	self store: self regE in: self regR index: index
]

{ #category : #loading }
JITAssembler64 >> storeLargeX0inA [
	pointer reset; length: 64; base: self regA.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #loading }
JITAssembler64 >> storeLargeX0inR [
	pointer reset; length: 64; base: self regR.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #loading }
JITAssembler64 >> storeLargeX0inT [
	pointer reset; length: 64; base: self regT.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #storing }
JITAssembler64 >> storeLongTInRAtA [
	self store: self regT e in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssembler64 >> storeLongTinRatA [
	self store: self regT e in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssembler64 >> storeLongTinRatOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT e
]

{ #category : #loading }
JITAssembler64 >> storeMXCSRintoA [
	pointer reset; length: 32; base: self regA.
	self assemble: 'stmxcsr' with: pointer
]

{ #category : #storing }
JITAssembler64 >> storeRinAindex: index [
	self store: self regR in: self regA index: index
]

{ #category : #storing }
JITAssembler64 >> storeRinEindex: index [
	self store: self regR in: self regE index: index
]

{ #category : #storing }
JITAssembler64 >> storeRinFPindex: index [
	self store: self regR in: self regFP index: index
]

{ #category : #storing }
JITAssembler64 >> storeRinIndirect: object [
	wordSize = 8 ifTrue: [
		^self
			loadVwithPointer: object;
			store: self regR in: self regV index: 1].
	pointer reset; length: self addressLength; displacement: self dummyPointer.
	self
		assemble: 'mov' with: pointer with: self regR;
		holdReferenceTo: object
]

{ #category : #storing }
JITAssembler64 >> storeRinSbyte: index [
	pointer
		reset;
		length: 8;
		base: self regS;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: self regR b
]

{ #category : #storing }
JITAssembler64 >> storeRinSindex: index [
	self store: self regR in: self regS index: index
]

{ #category : #'push/pop' }
JITAssembler64 >> storeRinSwordAt: index [
	pointer
		reset;
		length: 16;
		base: self regS;
		displacement: index - 1.
	self
		convertRtoNativeInteger;
		assemble: 'mov' with: pointer with: self regR w;
		convertRtoSmallInteger
]

{ #category : #storing }
JITAssembler64 >> storeRinTindex: index [
	self store: self regR in: self regT index: index
]

{ #category : #integers }
JITAssembler64 >> storeShortAinRoffset: offset [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: offset.
	self assemble: 'mov' with: pointer with: self regA w
]

{ #category : #storing }
JITAssembler64 >> storeShortTinRatOffsetA [
	pointer
		reset;
		length: 16;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT w
]

{ #category : #storing }
JITAssembler64 >> storeSinAindex: index [
	self store: self regS in: self regA index: index
]

{ #category : #storing }
JITAssembler64 >> storeSinRindex: index [
	self store: self regS in: self regR index: index
]

{ #category : #storing }
JITAssembler64 >> storeTIBwithAatIndexR [
	| seg |
	seg := wordSize = 8 ifTrue: [gs] ifFalse: [fs].
	pointer
		reset;
		length: self addressLength;
		index: self regR;
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: pointer with: self regA
]

{ #category : #storing }
JITAssembler64 >> storeTInRAtA [
	self store: self regT in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssembler64 >> storeTinAindex: index [
	self store: self regT in: self regA index: index
]

{ #category : #storing }
JITAssembler64 >> storeTinRatA [
	self store: self regT in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssembler64 >> storeTinRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT
]

{ #category : #storing }
JITAssembler64 >> storeTinRindex: index [
	self store: self regT in: self regR index: index
]

{ #category : #arithmetic }
JITAssembler64 >> subAfromR [
	self assemble: 'sub' with: self regR with: self regA
]

{ #category : #arithmetic }
JITAssembler64 >> subAfromT [
	self assemble: 'sub' with: self regT with: self regA
]

{ #category : #arithmetic }
JITAssembler64 >> subDoubleX1fromX0 [
	self assemble: 'subsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssembler64 >> subFromRconstant: imm [
	self assemble: 'sub' with: self regR withImm: imm
]

{ #category : #arithmetic }
JITAssembler64 >> subTslotsToSP [
	self assemble: 'neg' with: self regT.
	pointer
		reset;
		length: self addressLength;
		base: self regSP;
		index: self regT;
		scale: self regSP sizeInBytes.
	self
		assemble: 'lea' with: self regSP with: pointer;
		assemble: 'neg' with: self regT
]

{ #category : #integers }
JITAssembler64 >> testAintegerBit [
	self assemble: 'test' with: self regA8 with: 1
]

{ #category : #integers }
JITAssembler64 >> testIntegerBitOf: aRegister [
	self assemble: 'test' with: aRegister byte with: 1
]

{ #category : #integers }
JITAssembler64 >> testRintegerBit [
	self assemble: 'test' with: self regR8 with: 1
]

{ #category : #loading }
JITAssembler64 >> testRwithR [
	self assemble: 'test' with: self regR with: self regR
]

{ #category : #integers }
JITAssembler64 >> testTIntegerBit [
	self assemble: 'test' with: self regT byte with: 1
]

{ #category : #integers }
JITAssembler64 >> testTintegerBit [
	self assemble: 'test' with: self regT byte with: 1
]

{ #category : #services }
JITAssembler64 >> wordSize [
	^wordSize
]

{ #category : #'opcodes - integer related' }
JITAssembler64 >> writeTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['stosq'] ifFalse: ['stosd'].
	self assembleByte: rep; assemble: mnemonic
]

{ #category : #logic }
JITAssembler64 >> xorAwithR [
	self assemble: 'xor' with: self regA with: self regR
]

{ #category : #logic }
JITAssembler64 >> xorFPwithFP [
	self assemble: 'xor' with: self regFP with: self regFP
]

{ #category : #logic }
JITAssembler64 >> xorRwithA [
	self assemble: 'xor' with: self regR with: self regA
]
