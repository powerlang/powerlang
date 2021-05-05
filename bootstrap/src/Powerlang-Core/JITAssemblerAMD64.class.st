"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #JITAssemblerAMD64,
	#superclass : #AssemblerAMD64,
	#instVars : [
		'literals'
	],
	#classVars : [
		'ExternalFunctions'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #inspecting }
JITAssemblerAMD64 class >> aspects [
	^#(#disassembledText32 #disassembledText64)
]

{ #category : #initialization }
JITAssemblerAMD64 class >> initialize [
	super initialize.
	ExternalFunctions := Dictionary new
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addAtoR [
	backend add: backend regA to: backend regR
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addDoubleX1toX0 [
	self assemble: 'addsd' with: xmm0 with: xmm1
]

{ #category : #loading }
JITAssemblerAMD64 >> addLiteral: anObject [
	| index | 
	index := literals
		indexOf: anObject
		ifAbsent: [ literals
				add: anObject;
				size ].
	^ index + 2
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addRwithImmediate: imm [
	backend addImm: imm to: backend regR 
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addSPtoT [
	backend add: backend regSP to: backend regT
]

{ #category : #logic }
JITAssemblerAMD64 >> addSPwithImmediate: imm [
	backend addImm: imm to: backend regSP
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addSslotsToSP [
	backend lea: backend regSP base: backend regSP index: backend regS scale: backend regSP sizeInBytes

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addTslotsToSP [
	backend
		lea: backend regSP
		base: backend regSP
		index: backend regT
		scale: backend regSP sizeInBytes
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addTtoR [
	backend add: backend regT to: backend regR
]

{ #category : #logic }
JITAssemblerAMD64 >> addTwithImmediate: imm [
	backend addImm: imm to: backend regT
]

{ #category : #services }
JITAssemblerAMD64 >> addressOfExternal: function [
	^ExternalFunctions at: function ifAbsent: nil
]

{ #category : #logic }
JITAssemblerAMD64 >> andRwithA [
	backend and: backend regR with: backend regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> andRwithImmediate: imm [
	backend and: backend regR withImm: imm
]

{ #category : #logic }
JITAssemblerAMD64 >> andSPindirectWithImmediate: imm [
	backend andIndirect: backend regSP withImm: imm
]

{ #category : #private }
JITAssemblerAMD64 >> buildFrame [
	self
		push: self regFP;
		move: self regSP to: self regFP
]

{ #category : #private }
JITAssemblerAMD64 >> callA [
	self assemble: 'call' with: self regA
]

{ #category : #private }
JITAssemblerAMD64 >> callIndirectA [
	pointer reset; length: self addressLength; base: self regA.
	self assemble: 'call' with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> callIndirectM [
	pointer reset; length: self addressLength; base: self regM.
	self assemble: 'call' with: pointer
]

{ #category : #private }
JITAssemblerAMD64 >> callR [
	self assemble: 'call' with: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> clearAintegerBit [
	self assemble: 'dec' with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> clearFPUFlags [
	self assemble: 'fnclex'
]

{ #category : #integers }
JITAssemblerAMD64 >> clearRhighHalf [
	self assemble: 'mov' with: self regR e with: self regR e
]

{ #category : #integers }
JITAssemblerAMD64 >> clearRintegerBit [
	self assemble: 'dec' with: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> clearSafeRintegerBit [
	immediate value: 16rFE; length: 8.
	self assemble: 'and' with: al with: immediate
]

{ #category : #comparing }
JITAssemblerAMD64 >> compare: register withBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareWithTrue: register ]
		ifFalse: [ self compareWithFalse: register ]
]

{ #category : #loading }
JITAssemblerAMD64 >> compare: register withLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self
		assemble: 'cmp'
		withReg: register
		withReg: self regM
		index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareAwithTrue ]
		ifFalse: [ self compareAwithFalse ]
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithFalse [
	self assemble: 'cmp' with: self regA with: self regFalse
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regA withImm: imm
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithSmallInteger: anInteger [
	self compareAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithTrue [
	self assemble: 'cmp' with: self regA with: self regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> compareEqualLargeX0withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'cmpsd' with: xmm0 with: pointer with: 0
]

{ #category : #loading }
JITAssemblerAMD64 >> compareLessThanLargeX0withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'cmpsd' with: xmm0 with: pointer with: 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithA [
	self assemble: 'cmp' with: self regR with: self regA
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareRwithTrue ]
		ifFalse: [ self compareRwithFalse ]
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithEindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regE index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithFPindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regFP index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithFalse [
	self assemble: 'cmp' with: self regR with: self regFalse
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regR withImm: imm
]

{ #category : #storing }
JITAssemblerAMD64 >> compareRwithIndirect: reg1 andExchange: reg2 [
	pointer reset; length: self addressLength; base: reg1.
	self assemble: 'cmpxchg' with: pointer with: reg2
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithNil [
	self assemble: 'cmp' with: self regR with: self regNil
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithS [
	self assemble: 'cmp' with: self regR with: self regS
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithSindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regS index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithSmallInteger: anInteger [
	self compareRwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithTrue [
	self assemble: 'cmp' with: self regR with: self regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithVindex: index [
	self assemble: 'cmp' withReg: self regR withReg: self regV index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> compareSwithTindex: index [
	self assemble: 'cmp' withReg: self regS withReg: self regT index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareTwithA [
	self assemble: 'cmp' with: self regT with: self regA
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareTwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: self regT withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithFalse: register [
	self assemble: 'cmp' with: register with: self regFalse
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithNil: register [
	self assemble: 'cmp' with: register with: self regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithTrue: register [
	self assemble: 'cmp' with: register with: self regTrue
]

{ #category : #integers }
JITAssemblerAMD64 >> convertAtoNativeInteger [
	self convertToNativeInteger: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> convertAtoSmallInteger [
	self convertToSmallInteger: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> convertRtoNativeInteger [
	self convertToNativeInteger: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertRtoSmallInteger [
	self convertToSmallInteger: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTToNativeInteger [
	self convertToNativeInteger: self regT
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTosToSmallInteger [
	pointer reset; length: self addressLength; base: self regSP.
	self
		assemble: 'shl' with: pointer with: 1;
		assemble: 'inc' with: pointer
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTtoNativeInteger [
	self convertToNativeInteger: self regT
]

{ #category : #jumps }
JITAssemblerAMD64 >> dec: op1 [
	self assemble: 'dec' with: op1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> decR [
	self assemble: 'dec' with: self regR
]

{ #category : #private }
JITAssemblerAMD64 >> decRindirect [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'dec' with: pointer
]

{ #category : #services }
JITAssemblerAMD64 >> disassembledText32 [
	^self nativeCode disassembledText32
]

{ #category : #services }
JITAssemblerAMD64 >> disassembledText64 [
	^self nativeCode disassembledText64
]

{ #category : #private }
JITAssemblerAMD64 >> discardArguments: anInteger [
	anInteger = 0 ifTrue: [^self].
	self addSPwithImmediate: anInteger * wordSize
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> divideDoubleX0byX1 [
	self assemble: 'divsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> divideRbyT [
	| conversion |
	self ASSERT: (self regR r == rax and: [self regA r == rdx]).
	conversion := wordSize = 8 ifTrue: ['cqo'] ifFalse: ['cdq'].
	self
		assemble: conversion;
		assemble: 'idiv' with: self regT
]

{ #category : #loading }
JITAssemblerAMD64 >> dropTopOfFPU [
	"
	fstp st(0)
	"
	self assembleBytes: #[16rDD 16rD8]
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> dropTos: count [
	| imm |
	imm := count * self addressSize.
	self assemble: 'add' with: self regSP with: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> dummyPointer [
	#dontOptimize.
	^wordSize = 8 ifTrue: [16r1BADADD01BADADD0] ifFalse: [16r1BADADD0]
]

{ #category : #integers }
JITAssemblerAMD64 >> ensureRintegerBit [
	self assemble: 'or' with: al with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> ensureSafeRintegerBit [
	self assemble: 'or' with: al with: 1
]

{ #category : #loading }
JITAssemblerAMD64 >> exchangeRindirectWithT [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'xchg' with: pointer with: self regT
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> incA [
	self assemble: 'inc' with: self regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> incC [
	self assemble: 'inc' with: self regC
]

{ #category : #private }
JITAssemblerAMD64 >> initialize [
	super initialize.
	literals := OrderedCollection new.
	backend := self
]

{ #category : #private }
JITAssemblerAMD64 >> initializeS [
	self assemble: 'mov' with: self regS with: self regR
]

{ #category : #private }
JITAssemblerAMD64 >> jumpIndirectA [
	pointer reset; length: self addressLength; base: self regA.
	self assemble: 'jmp' with: pointer
]

{ #category : #comparing }
JITAssemblerAMD64 >> jumpToA [
	self assemble: 'jmp' with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> jumpToMindex: index [
	self assemble: 'jmp' withReg: self regM index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> jumpToS [
	self assemble: 'jmp' with: self regS
]

{ #category : #loading }
JITAssemblerAMD64 >> jumpToTindex: index [
	self assemble: 'jmp' withReg: self regT index: index
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfZeroTo: label.
	^label
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOfA [
	^self labeledIntegerBitTestOf: self regA8
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: self regR8
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: self regT byte
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOf: aRegister [
	| label |
	self convertToNativeInteger: aRegister.
	label := self newLabel.
	self shortJumpIfNotCarryTo: label.
	^label
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOfA [
	^self labeledIntegerNativizationOf: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: self regT
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledNonIntegerBitTestOf: aRegister [
	| label |
	self testIntegerBitOf: aRegister.
	label := self newLabel.
	self shortJumpIfNotZeroTo: label.
	^label
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledNonIntegerBitTestOfR [
	^self labeledNonIntegerBitTestOf: self regR8
]

{ #category : #loading }
JITAssemblerAMD64 >> load: register withLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self
		assemble: 'mov'
		withReg: register
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithAindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regA index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithBoolean: aBoolean [
	aBoolean ifTrue: [self loadAwithTrue]
	ifFalse: [self loadAwithFalse]

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithEindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regE index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFPindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regFP index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFalse [
	self assemble: 'mov' with: self regA with: self regFalse
]

{ #category : #private }
JITAssemblerAMD64 >> loadAwithGindex: index [
	self
		assemble: 'mov'
		withReg: self regA
		withReg: self regG
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadAwithGindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regA withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithKnown: anObject [
	self breakpoint
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadAwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regA
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithNil [
	self assemble: 'mov' with: self regA with: self regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithR [
	self assemble: 'mov' with: self regA with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithRindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regR index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithRoffsetAtA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regA with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithS [
	self assemble: 'mov' with: self regA with: self regS
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithSindex: index [
	self assemble: 'mov' withReg: self regA withReg: self regS index: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadAwithSmallInteger: anInteger [
	self loadAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithT [
	self assemble: 'mov' with: self regA with: self regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithTrue [
	self assemble: 'mov' with: self regA with: self regTrue
]

{ #category : #integers }
JITAssemblerAMD64 >> loadEwithAddressOfRatA [
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
JITAssemblerAMD64 >> loadEwithFPindex: index [
	self assemble: 'mov' withReg: self regE withReg: self regFP index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regE withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithNil [
	self assemble: 'mov' with: self regE with: self regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithR [
	self assemble: 'mov' with: self regE with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFPwithR [
	self assemble: 'mov' with: self regFP with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFPwithSP [
	self assemble: 'mov' with: self regFP with: self regSP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFalseWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadFalseWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFalseWithMindex: index [
	self assemble: 'mov' withReg: self regFalse withReg: self regM index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithMindex: index [
	self assemble: 'mov' withReg: self regG withReg: self regM index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLargeX0withRindirect [
	pointer reset; length: 64; base: self regR.
	self assemble: 'movq' with: xmm0 with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLargeX1withAindirect [
	pointer reset; length: 64; base: self regA.
	self assemble: 'movq' with: xmm1 with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongMwithIPoffset: anInteger [
	| instsize |
	#dontOptimize.
	instsize := 6.
	pointer
		reset;
		length: 32;
		base: self regIP;
		displacement: anInteger - instsize.
	self assemble: 'mov' with: self regM e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongRWithRAtOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongRwithRatOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongSwithRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 32;
		base: self regR;
		displacement: index - 1 * 4.
	self assemble: 'mov' with: self regS e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMXCSRfromA [
	pointer reset; length: 32; base: self regA.
	self assemble: 'ldmxcsr' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> loadMwithA [
	self assemble: 'mov' with: self regM with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithFPindex: index [
	self
		assemble: 'mov'
		withReg: self regM
		withReg: self regFP
		index: index
]

{ #category : #private }
JITAssemblerAMD64 >> loadMwithGindex: index [
	self assemble: 'mov' withReg: self regM withReg: self regG index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadMwithGindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regM withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadMwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regM
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithRIPoffset: imm [
	pointer
		reset;
		length: self addressLength;
		base: rip;
		displacement: imm.

	self assemble: 'lea' with: self regM with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithRindex: index [
	self
		assemble: 'mov'
		withReg: self regM
		withReg: self regR
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithTindex: index [
	self assemble: 'mov' withReg: self regM withReg: self regT index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithMindex: index [
	self assemble: 'mov' withReg: self regNil withReg: self regM index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRConvertingDoubleRindirect [
	pointer reset; length: 64; base: self regR.
	self assemble: 'cvttsd2si' with: self regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRconvertingDoublePointedByR [
	pointer reset; length: 64; base: self regR.
	self assemble: 'cvttsd2si' with: self regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithA [
	self assemble: 'mov' with: self regR with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithArgPointer [
	pointer
		reset;
		length: self addressLength;
		base: self regFP;
		displacement: wordSize * 2.
	self assemble: 'lea' with: self regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self loadRwithTrue ]
		ifFalse: [ self loadRwithFalse ]
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithE [
	self assemble: 'mov' with: self regR with: self regE
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithEindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regE index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFP [
	self assemble: 'mov' with: self regR with: self regFP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFPindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regFP index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFalse [
	self assemble: 'mov' with: self regR with: self regFalse
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regR withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadRwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithM [
	self assemble: 'mov' with: self regR with: self regM
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regR
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithNil [
	self assemble: 'mov' with: self regR with: self regNil
]

{ #category : #integers }
JITAssemblerAMD64 >> loadRwithRatA [
	self load: self regR from: self regR atIndexAt: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRbyte: index [
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
JITAssemblerAMD64 >> loadRwithRindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regR index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRwordAt: index [
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
JITAssemblerAMD64 >> loadRwithS [
	self assemble: 'mov' with: self regR with: self regS
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSP [
	self assemble: 'mov' with: self regR with: self regSP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSPindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regSP index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSbyte: index [
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
JITAssemblerAMD64 >> loadRwithSindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regS index: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadRwithSmallInteger: anInteger [
	self loadRwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSwordAt: index [
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
JITAssemblerAMD64 >> loadRwithT [
	self assemble: 'mov' with: self regR with: self regT
]

{ #category : #storing }
JITAssemblerAMD64 >> loadRwithTIBatIndexR [
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
JITAssemblerAMD64 >> loadRwithThreadVariableAtIndexR [
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
JITAssemblerAMD64 >> loadRwithTindex: index [
	self assemble: 'mov' withReg: self regR withReg: self regT index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithTos [
	pointer reset; length: self addressLength; base: self regSP.
	self assemble: 'mov' with: self regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithTrue [
	self assemble: 'mov' with: self regR with: self regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithX0 [
	| mov |
	mov := wordSize = 8 ifTrue: ['movq'] ifFalse: ['movd'].
	self assemble: mov with: self regR with: xmm0
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSPwithFP [
	self assemble: 'mov' with: self regSP with: self regFP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSPwithT [
	self assemble: 'mov' with: self regSP with: self regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSWithRIndex: index [
	self load: self regS from: self regR atIndex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithA [
	self assemble: 'mov' with: self regS with: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadSwithAddressOfSatA [
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
JITAssemblerAMD64 >> loadSwithFPindex: index [
	self assemble: 'mov' withReg: self regS withReg: self regFP index: index
]

{ #category : #private }
JITAssemblerAMD64 >> loadSwithGindex: index [
	self assemble: 'mov' withReg: self regS withReg: self regG index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadSwithGindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regS withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithNil [
	self assemble: 'mov' with: self regS with: self regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithRindex: index [
	self assemble: 'mov' withReg: self regS withReg: self regR index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithT [
	self assemble: 'mov' with: self regS with: self regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithMindex: index [
	self assemble: 'mov' withReg: self regTrue withReg: self regM index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithA [
	self assemble: 'mov' with: self regT with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithAindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regA index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithEindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regE index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithFPindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regFP index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regT withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithMindex: index [
	self
		assemble: 'mov'
		withReg: self regT
		withReg: self regM
		index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithR [
	self assemble: 'mov' with: self regT with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithTindex: index [
	self assemble: 'mov' withReg: self regT withReg: self regT index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadVwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: self regV withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithFalse: register [
	self assemble: 'mov' with: register with: self regFalse
]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithNil: register [
	self
		assemble: 'mov'
		with: register
		with: self regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithTrue: register [
	self assemble: 'mov' with: register with: self regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX0withRasDouble [
	self assemble: 'cvtsi2sd' with: xmm0 with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX1roundingX0 [
	self assemble: 'roundsd' with: xmm1 with: xmm0 with: 3
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: self regR from: self regR atIndexAt: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: self regR from: self regR atIndex: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: self regR from: self regSP atIndexAt: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: self regT from: self regA atIndex: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendLongRwithRatA [
	self load: self regR e from: self regR atIndexAt: self regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendLongRwithRindex: index [
	#dontOptimize.
	self load: self regR e from: self regR atIndex: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendShortRwithRoffset: offset [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: offset.
	self assemble: 'movzx' with: self regR with: pointer
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> lock [
	self assembleByte: 16rF0
]

{ #category : #jumps }
JITAssemblerAMD64 >> loop: aBlock times: anInteger [
	| loop |
	loop := self newLabel.
	self loadTwithImmediate: anInteger; @ loop.
	aBlock value.
	self dec: self regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
JITAssemblerAMD64 >> loopTo: label [
	self
		assemble: 'dec' with: self regT;
		jumpIfNotZeroTo: label
]

{ #category : #jumps }
JITAssemblerAMD64 >> loopTtimes: aBlock [
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
JITAssemblerAMD64 >> moveTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['movsq'] ifFalse: ['movsd'].
	self assembleByte: rep; assemble: mnemonic
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyDoubleX0byX1 [
	self assemble: 'mulsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyRbyA [
	self ASSERT: (self regR r == rax and: [self regA r == rdx]).
	self assemble: 'imul' with: self regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyRbyConstant: imm [
	self assemble: 'imul' with: self regR with: self regR with: imm
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> nativeCode [
	^(NativeCode withAll: literals) code: memory bytes
]

{ #category : #logic }
JITAssemblerAMD64 >> orRwithA [
	self assemble: 'or' with: self regR with: self regA
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popA [
	self assemble: 'pop' with: self regA
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popB [
	self assemble: 'pop' with: self regB
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popE [
	self assemble: 'pop' with: self regE
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popFP [
	self assemble: 'pop' with: self regFP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popFalse [
	self assemble: 'pop' with: self regFalse
]

{ #category : #private }
JITAssemblerAMD64 >> popG [
	self assemble: 'pop' with: self regG
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popM [
	self assemble: 'pop' with: self regM
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popNil [
	self assemble: 'pop' with: self regNil
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popR [
	self assemble: 'pop' with: self regR
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popS [
	self assemble: 'pop' with: self regS
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSP [
	self assemble: 'pop' with: self regSP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSPindirect [
	pointer reset; length: self addressLength; base: self regSP.
	self assemble: 'pop' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popT [
	self assemble: 'pop' with: self regT
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popTrue [
	self assemble: 'pop' with: self regTrue
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushA [
	self assemble: 'push' with: self regA
]

{ #category : #loading }
JITAssemblerAMD64 >> pushAOnFPUStack [
	pointer reset; length: 64; base: self regA.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushAatToffset: offset [
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
JITAssemblerAMD64 >> pushB [
	self assemble: 'push' with: self regB
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushE [
	self assemble: 'push' with: self regE
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushEindex: index [
	self assemble: 'push' withReg: self regE index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFP [
	self assemble: 'push' with: self regFP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFPindex: index [
	self assemble: 'push' withReg: self regFP index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFalse [
	self assemble: 'push' with: self regFalse
]

{ #category : #private }
JITAssemblerAMD64 >> pushG [
	self assemble: 'push' with: self regG
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'push' withImm: imm
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushIndirectR [
	pointer reset; length: self addressLength; base: self regR.
	self assemble: 'push' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushM [
	self assemble: 'push' with: self regM
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushNil [
	self assemble: 'push' with: self regNil
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushR [
	self assemble: 'push' with: self regR
]

{ #category : #loading }
JITAssemblerAMD64 >> pushROnFPUStack [
	pointer reset; length: 64; base: self regR.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushRbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushRwordAt: index [
	pointer
		halt;
		reset;
		length: self addressLength;
		base: self regR;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushS [
	self assemble: 'push' with: self regS
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSP [
	self assemble: 'push' with: self regSP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSindex: index [
	self assemble: 'push' withReg: self regS index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSmallInteger: integer [
	self pushImmediate: (integer bitShift: 1) + 1
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSwordAt: index [
	pointer
		reset;
		length: self addressLength;
		base: self regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushT [
	self assemble: 'push' with: self regT
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushTindex: index [
	self assemble: 'push' withReg: self regT index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushTrue [
	self assemble: 'push' with: self regTrue
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushVindex: index [
	self assemble: 'push' withReg: self regV index: index
]

{ #category : #services }
JITAssemblerAMD64 >> readFPUStatusOnA [
	pointer reset; length: 16; base: self regA.
	self assemble: 'fstsw' with: pointer
]

{ #category : #private }
JITAssemblerAMD64 >> regA [
	^wordSize = 8 ifTrue: [rdx] ifFalse: [edx]
]

{ #category : #private }
JITAssemblerAMD64 >> regA8 [
	^dl
]

{ #category : #private }
JITAssemblerAMD64 >> regB [
	^wordSize = 8 ifTrue: [rbx] ifFalse: [ebx]
]

{ #category : #private }
JITAssemblerAMD64 >> regC [
	^wordSize = 8 ifTrue: [rbx] ifFalse: [ebx]
]

{ #category : #private }
JITAssemblerAMD64 >> regE [
	^wordSize = 8 ifTrue: [rdi] ifFalse: [edi]
]

{ #category : #private }
JITAssemblerAMD64 >> regFP [
	^wordSize = 8 ifTrue: [rbp] ifFalse: [ebp]
]

{ #category : #private }
JITAssemblerAMD64 >> regFalse [
	^ r14
]

{ #category : #private }
JITAssemblerAMD64 >> regG [
	^r15
]

{ #category : #private }
JITAssemblerAMD64 >> regIP [
	^ rip
]

{ #category : #private }
JITAssemblerAMD64 >> regM [
	^rbx
]

{ #category : #private }
JITAssemblerAMD64 >> regNil [
	^ r12
]

{ #category : #private }
JITAssemblerAMD64 >> regR [
	^wordSize = 8 ifTrue: [rax] ifFalse: [eax]
]

{ #category : #private }
JITAssemblerAMD64 >> regR8 [
	^al
]

{ #category : #private }
JITAssemblerAMD64 >> regS [
	^wordSize = 8 ifTrue: [rsi] ifFalse: [esi]
]

{ #category : #private }
JITAssemblerAMD64 >> regSP [
	^wordSize = 8 ifTrue: [rsp] ifFalse: [esp]
]

{ #category : #private }
JITAssemblerAMD64 >> regT [
	^wordSize = 8 ifTrue: [rcx] ifFalse: [ecx]
]

{ #category : #private }
JITAssemblerAMD64 >> regT8 [
	^ cl
]

{ #category : #private }
JITAssemblerAMD64 >> regTrue [
	^ r13
]

{ #category : #private }
JITAssemblerAMD64 >> reserveStackSlots: amount [
	self subtract: amount * self addressSize from: self regSP
]

{ #category : #comparing }
JITAssemblerAMD64 >> reset [
	super reset.
	literals := OrderedCollection new
]

{ #category : #epilogue }
JITAssemblerAMD64 >> restoreCallerEnvironment [
	self loadEwithFPindex: -2
]

{ #category : #epilogue }
JITAssemblerAMD64 >> restoreCallerFrame [
	self
		move: self regFP to: self regSP;
		pop: self regFP
]

{ #category : #epilogue }
JITAssemblerAMD64 >> restoreCallerM [
	self loadMwithFPindex: -1
]

{ #category : #epilogue }
JITAssemblerAMD64 >> restoreCallerSelf [
	self loadSwithFPindex: 0
]

{ #category : #integers }
JITAssemblerAMD64 >> restoreRSmallInteger [
	self assemble: 'rcl' with: self regR with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> restoreRsmallInteger [
	self assemble: 'rcl' with: self regR with: 1
]

{ #category : #services }
JITAssemblerAMD64 >> returnFromCallback: argCount [
	wordSize = 4 ifTrue: [self return: argCount] ifFalse: [self return]
]

{ #category : #loading }
JITAssemblerAMD64 >> saveCallerFrame [
	self pushFP; loadFPwithSP
]

{ #category : #loading }
JITAssemblerAMD64 >> scaleFloatOnRWithA [
	self pushAOnFPUStack; pushROnFPUStack; assemble: 'fscale'.
	pointer reset; length: 64; base: self regR.
	self assemble: 'fstp' with: pointer; dropTopOfFPU
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftLeftRwithT [
	self ASSERT: self regT r == rcx.
	self assemble: 'sal' with: self regR with: self regT b
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftLogicalRright: count [
	self ASSERT: count < 32.
	self assemble: 'shr' with: self regR with: count
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRightRwithT [
	self ASSERT: self regT r == rcx.
	self assemble: 'sar' with: self regR with: self regT b
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRleft: count [
	self ASSERT: count < 32.
	self assemble: 'sal' with: self regR with: count
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRright: count [
	self ASSERT: count < (wordSize * 8).
	self assemble: 'sar' with: self regR with: count
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftTleft: count [
	self ASSERT: count < 32.
	self assemble: 'sal' with: self regT with: count
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftTright: count [
	self ASSERT: count < 32.
	self assemble: 'sar' with: self regT with: count
]

{ #category : #comparing }
JITAssemblerAMD64 >> smallInteger: anInteger [
	^(anInteger bitShift: 1) + 1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> sqrtDoubleX0 [
	self assemble: 'sqrtsd' with: xmm0 with: xmm0
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinRindex: index [
	self store: self regA in: self regR index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinSPatT [
	self store: self regA in: self regSP indexAt: self regT
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinThreadVariableAtIndexR [
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
JITAssemblerAMD64 >> storeAinTindex: index [
	self store: self regA in: self regT index: index
]

{ #category : #integers }
JITAssemblerAMD64 >> storeArgumentsInStack [
	self
		store: rcx in: rbp index: 3;
		store: rdx in: rbp index: 4;
		store: r8 in: rbp index: 5;
		store: r9 in: rbp index: 6
]

{ #category : #storing }
JITAssemblerAMD64 >> storeByteAinRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 8;
		base: self regR;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: self regA b
]

{ #category : #storing }
JITAssemblerAMD64 >> storeByteTinRatA [
	pointer
		reset;
		length: 8;
		base: self regR;
		index: self regA;
		displacement: -1.
	self assemble: 'mov' with: pointer with: self regT b
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> storeDoubleResultInRindirect [
	pointer reset; length: 64; base: self regR.
	wordSize = 8
		ifTrue: [self assemble: 'movq' with: pointer with: xmm0]
		ifFalse: [self assemble: 'fstp' with: pointer]
]

{ #category : #storing }
JITAssemblerAMD64 >> storeEinAindex: index [
	self store: self regE in: self regA index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeEinRindex: index [
	self store: self regE in: self regR index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inA [
	pointer reset; length: 64; base: self regA.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inR [
	pointer reset; length: 64; base: self regR.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inT [
	pointer reset; length: 64; base: self regT.
	self assemble: 'movq' with: pointer with: xmm0
]

{ #category : #storing }
JITAssemblerAMD64 >> storeLongTInRAtA [
	self store: self regT e in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeLongTinRatA [
	self store: self regT e in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeLongTinRatOffsetA [
	pointer
		reset;
		length: 32;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT e
]

{ #category : #loading }
JITAssemblerAMD64 >> storeMXCSRintoA [
	pointer reset; length: 32; base: self regA.
	self assemble: 'stmxcsr' with: pointer
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinAindex: index [
	self store: self regR in: self regA index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinEindex: index [
	self store: self regR in: self regE index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinFPindex: index [
	self store: self regR in: self regFP index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinSbyte: index [
	pointer
		reset;
		length: 8;
		base: self regS;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: self regR b
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinSindex: index [
	backend store: backend regR in: backend regS index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> storeRinSwordAt: index [
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
JITAssemblerAMD64 >> storeRinTindex: index [
	self store: self regR in: self regT index: index
]

{ #category : #integers }
JITAssemblerAMD64 >> storeShortAinRoffset: offset [
	pointer
		reset;
		length: 16;
		base: self regR;
		displacement: offset.
	self assemble: 'mov' with: pointer with: self regA w
]

{ #category : #storing }
JITAssemblerAMD64 >> storeShortTinRatOffsetA [
	pointer
		reset;
		length: 16;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT w
]

{ #category : #storing }
JITAssemblerAMD64 >> storeSinAindex: index [
	self store: self regS in: self regA index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeSinRindex: index [
	self store: self regS in: self regR index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTIBwithAatIndexR [
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
JITAssemblerAMD64 >> storeTInRAtA [
	self store: self regT in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinAindex: index [
	self store: self regT in: self regA index: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRatA [
	self store: self regT in: self regR indexAt: self regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: self regR;
		index: self regA.
	self assemble: 'mov' with: pointer with: self regT
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRindex: index [
	self store: self regT in: self regR index: index
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subAfromR [
	self assemble: 'sub' with: self regR with: self regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subAfromT [
	self assemble: 'sub' with: self regT with: self regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subDoubleX1fromX0 [
	self assemble: 'subsd' with: xmm0 with: xmm1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subFromRconstant: imm [
	self assemble: 'sub' with: self regR withImm: imm
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subTfromR [
	self assemble: 'sub' with: self regR with: self regT
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subTslotsToSP [
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
JITAssemblerAMD64 >> testAintegerBit [
	self assemble: 'test' with: self regA8 with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testIntegerBitOf: aRegister [
	self assemble: 'test' with: aRegister byte with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testRintegerBit [
	self assemble: 'test' with: self regR8 with: 1
]

{ #category : #loading }
JITAssemblerAMD64 >> testRwithR [
	self assemble: 'test' with: self regR with: self regR
]

{ #category : #integers }
JITAssemblerAMD64 >> testTIntegerBit [
	self assemble: 'test' with: self regT byte with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testTintegerBit [
	self assemble: 'test' with: self regT byte with: 1
]

{ #category : #services }
JITAssemblerAMD64 >> wordSize [
	^wordSize
]

{ #category : #'opcodes - integer related' }
JITAssemblerAMD64 >> writeTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['stosq'] ifFalse: ['stosd'].
	self assembleByte: rep; assemble: mnemonic
]

{ #category : #logic }
JITAssemblerAMD64 >> xorAwithR [
	self assemble: 'xor' with: self regA with: self regR
]

{ #category : #logic }
JITAssemblerAMD64 >> xorFPwithFP [
	self assemble: 'xor' with: self regFP with: self regFP
]

{ #category : #logic }
JITAssemblerAMD64 >> xorRwithA [
	self assemble: 'xor' with: self regR with: self regA
]
