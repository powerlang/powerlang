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
	self 
		assemble: 'addsd'
		with: backend regF0
		with: backend regF1

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
		push: backend regFP;
		move: backend regSP to: backend regFP
]

{ #category : #private }
JITAssemblerAMD64 >> callA [
	self assemble: 'call' with: backend regA
]

{ #category : #private }
JITAssemblerAMD64 >> callIndirectA [
	pointer reset; length: self addressLength; base: backend regA.
	self assemble: 'call' with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> callIndirectM [
	pointer reset; length: self addressLength; base: backend regM.
	self assemble: 'call' with: pointer
]

{ #category : #private }
JITAssemblerAMD64 >> callR [
	self assemble: 'call' with: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> clearAintegerBit [
	self assemble: 'dec' with: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> clearFPUFlags [
	self assemble: 'fnclex'
]

{ #category : #integers }
JITAssemblerAMD64 >> clearRhighHalf [
	self assemble: 'mov' with: backend regR e with: backend regR e

]

{ #category : #integers }
JITAssemblerAMD64 >> clearRintegerBit [
	self assemble: 'dec' with: backend regR
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
		withReg: backend regM
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
	self assemble: 'cmp' with: backend regA with: backend regFalse
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: backend regA withImm: imm
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithSmallInteger: anInteger [
	self compareAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareAwithTrue [
	self assemble: 'cmp' with: backend regA with: backend regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> compareEqualLargeX0withAindirect [
	pointer
		reset;
		length: 64;
		base: backend regA.
	self 
		assemble: 'cmpsd'
		with: backend regF0
		with: pointer
		with: 0
]

{ #category : #loading }
JITAssemblerAMD64 >> compareLessThanLargeX0withAindirect [
	pointer
		reset;
		length: 64;
		base: backend regA.
	self 
		assemble: 'cmpsd'
		with: backend regF0
		with: pointer
		with: 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithA [
	self assemble: 'cmp' with: backend regR with: backend regA
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self compareRwithTrue ]
		ifFalse: [ self compareRwithFalse ]
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithEindex: index [
	self assemble: 'cmp' withReg: backend regR withReg: backend regE index: index
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithFPindex: index [
	self assemble: 'cmp' withReg: backend regR withReg: backend regFP index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithFalse [
	self assemble: 'cmp' with: backend regR with: backend regFalse
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: backend regR withImm: imm
]

{ #category : #storing }
JITAssemblerAMD64 >> compareRwithIndirect: reg1 andExchange: reg2 [
	pointer reset; length: self addressLength; base: reg1.
	self assemble: 'cmpxchg' with: pointer with: reg2
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithNil [
	self assemble: 'cmp' with: backend regR with: backend regNil
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithS [
	self assemble: 'cmp' with: backend regR with: backend regS
]

{ #category : #loading }
JITAssemblerAMD64 >> compareRwithSindex: index [
	self assemble: 'cmp' withReg: backend regR withReg: backend regS index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithSmallInteger: anInteger [
	self compareRwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithTrue [
	self assemble: 'cmp' with: backend regR with: backend regTrue
]

{ #category : #loading }
JITAssemblerAMD64 >> compareSwithTindex: index [
	self assemble: 'cmp' withReg: backend regS withReg: backend regT index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareTwithA [
	self assemble: 'cmp' with: backend regT with: backend regA
]

{ #category : #comparing }
JITAssemblerAMD64 >> compareTwithImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'cmp' with: backend regT withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithFalse: register [
	self assemble: 'cmp' with: register with: backend regFalse
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithNil: register [
	self assemble: 'cmp' with: register with: backend regNil
]

{ #category : #loading }
JITAssemblerAMD64 >> compareWithTrue: register [
	self assemble: 'cmp' with: register with: backend regTrue
]

{ #category : #integers }
JITAssemblerAMD64 >> convertAtoNativeInteger [
	self convertToNativeInteger: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> convertAtoSmallInteger [
	self convertToSmallInteger: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> convertRtoNativeInteger [
	self convertToNativeInteger: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertRtoSmallInteger [
	self convertToSmallInteger: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTToNativeInteger [
	self convertToNativeInteger: backend regT
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTosToSmallInteger [
	pointer reset; length: self addressLength; base: backend regSP.
	self
		assemble: 'shl' with: pointer with: 1;
		assemble: 'inc' with: pointer
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTtoNativeInteger [
	self convertToNativeInteger: backend regT
]

{ #category : #jumps }
JITAssemblerAMD64 >> dec: srcAndDstReg [
	backend addImm: -1 to: srcAndDstReg

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> decR [
	self dec: backend regR
]

{ #category : #private }
JITAssemblerAMD64 >> decRindirect [
	pointer reset; length: self addressLength; base: backend regR.
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
	self 
		assemble: 'divsd'
		with: backend regF0
		with: backend regF1

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> divideRbyT [
	| conversion |
	self ASSERT: (backend regR r == rax and: [backend regA r == rdx]).
	conversion := wordSize = 8 ifTrue: ['cqo'] ifFalse: ['cdq'].
	self
		assemble: conversion;
		assemble: 'idiv' with: backend regT
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
	backend addImm: (count * self addressSize) to: backend regSP

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
	pointer reset; length: self addressLength; base: backend regR.
	self assemble: 'xchg' with: pointer with: backend regT
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> incA [
	backend addImm: 1 to: backend regA

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> incC [
	backend addImm: 1 to: backend regC

]

{ #category : #private }
JITAssemblerAMD64 >> initialize [
	super initialize.
	literals := OrderedCollection new.
	backend := self
]

{ #category : #private }
JITAssemblerAMD64 >> initializeS [
	backend move: backend regR to: backend regS
]

{ #category : #private }
JITAssemblerAMD64 >> jumpIndirectA [
	pointer reset; length: self addressLength; base: backend regA.
	self assemble: 'jmp' with: pointer
]

{ #category : #comparing }
JITAssemblerAMD64 >> jumpToA [
	self assemble: 'jmp' with: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> jumpToMindex: index [
	self assemble: 'jmp' withReg: backend regM index: index
]

{ #category : #comparing }
JITAssemblerAMD64 >> jumpToS [
	self assemble: 'jmp' with: backend regS
]

{ #category : #loading }
JITAssemblerAMD64 >> jumpToTindex: index [
	self assemble: 'jmp' withReg: backend regT index: index
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
	^self labeledIntegerBitTestOf: backend regA8
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOfR [
	^self labeledIntegerBitTestOf: backend regR8
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerBitTestOfT [
	^self labeledIntegerBitTestOf: backend regT byte
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
	^self labeledIntegerNativizationOf: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOfR [
	^self labeledIntegerNativizationOf: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> labeledIntegerNativizationOfT [
	^self labeledIntegerNativizationOf: backend regT
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
	^self labeledNonIntegerBitTestOf: backend regR8
]

{ #category : #loading }
JITAssemblerAMD64 >> load: register withLiteral: anObject [ 
	| index |

	index := self addLiteral: anObject.
	backend 
		  load: register
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithAindex: index [ 
	backend 
		  load: backend regA
		  fromBase: backend regA
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithBoolean: aBoolean [
	aBoolean ifTrue: [self loadAwithTrue]
	ifFalse: [self loadAwithFalse]

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithEindex: index [ 
	backend 
		  load: backend regA
		  fromBase: backend regE
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFPindex: index [ 
	backend 
		  load: backend regA
		  fromBase: backend regFP
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFalse [
	backend move: backend regFalse to: backend regA
]

{ #category : #private }
JITAssemblerAMD64 >> loadAwithGindex: index [ 
	backend 
		load: backend regA
		fromBase: backend regG
		indexImm: index

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
	self assemble: 'mov' with: backend regA withImm: imm
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
	backend 
		  load: backend regA
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithNil [
	backend move: backend regNil to: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithR [
	backend move: backend regR to: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithRindex: index [ 
	backend 
		  load: backend regA
		  fromBase: backend regR
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithRoffsetAtA [
	backend load: backend regA fromBase: backend regR offsetImm: 0 index: backend regA scaleImm: 1.

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithS [
	backend move: backend regS to: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithSindex: index [ 
	backend 
		  load: backend regA
		  fromBase: backend regS
		  indexImm: index

]

{ #category : #integers }
JITAssemblerAMD64 >> loadAwithSmallInteger: anInteger [
	self loadAwithImmediate: (anInteger bitShift: 1) + 1
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithT [
	backend move: backend regT to: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithTrue [
	backend move: backend regTrue to: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadEwithAddressOfRatA [
	pointer
		reset;
		length: self addressLength;
		base: backend regR;
		index: backend regA;
		scale: backend regE sizeInBytes;
		displacement: 0 - backend regE sizeInBytes.
	self assemble: 'lea' with: backend regE with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithFPindex: index [ 
	backend 
		  load: backend regE
		  fromBase: backend regFP
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: backend regE withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithNil [
	backend move: backend regNil to: backend regE
]

{ #category : #loading }
JITAssemblerAMD64 >> loadEwithR [
	backend move: backend regR to: backend regE
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFPwithR [
	backend move: backend regR to: backend regFP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFPwithSP [
	backend move: backend regSP to: backend regFP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFalseWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadFalseWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadFalseWithMindex: index [ 
	backend 
		  load: backend regFalse
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithMindex: index [ 
	backend 
		  load: backend regG
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadLargeX0withRindirect [
	pointer
		reset;
		length: 64;
		base: backend regR.
	self 
		assemble: 'movq'
		with: backend regF0
		with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLargeX1withAindirect [
	pointer
		reset;
		length: 64;
		base: backend regA.
	self 
		assemble: 'movq'
		with: backend regF1
		with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongMwithIPoffset: anInteger [
	| instsize |
	#dontOptimize.
	instsize := 6.
	pointer
		reset;
		length: 32;
		base: backend regIP;
		displacement: anInteger - instsize.
	self assemble: 'mov' with: backend regM e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongRWithRAtOffsetA [
	pointer
		reset;
		length: 32;
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: backend regR e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongRwithRatOffsetA [
	pointer
		reset;
		length: 32;
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: backend regR e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLongSwithRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 32;
		base: backend regR;
		displacement: index - 1 * 4.
	self assemble: 'mov' with: backend regS e with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMXCSRfromA [
	pointer reset; length: 32; base: backend regA.
	self assemble: 'ldmxcsr' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> loadMwithA [
	backend move: backend regA to: backend regM
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithFPindex: index [ 
	backend 
		load: backend regM
		fromBase: backend regFP
		indexImm: index

]

{ #category : #private }
JITAssemblerAMD64 >> loadMwithGindex: index [ 
	backend 
		  load: backend regM
		  fromBase: backend regG
		  indexImm: index

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
	self assemble: 'mov' with: backend regM withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadMwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithMindex: index [ 
	backend 
		  load: backend regM
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithRIPoffset: imm [
	pointer
		reset;
		length: self addressLength;
		base: rip;
		displacement: imm.

	self assemble: 'lea' with: backend regM with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithRindex: index [ 
	backend 
		load: backend regM
		fromBase: backend regR
		indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithTindex: index [ 
	backend 
		  load: backend regM
		  fromBase: backend regT
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithMindex: index [ 
	backend 
		  load: backend regNil
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRConvertingDoubleRindirect [
	pointer reset; length: 64; base: backend regR.
	self assemble: 'cvttsd2si' with: backend regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRconvertingDoublePointedByR [
	pointer reset; length: 64; base: backend regR.
	self assemble: 'cvttsd2si' with: backend regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithA [
	backend move: backend regA to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithArgPointer [
	pointer
		reset;
		length: self addressLength;
		base: backend regFP;
		displacement: wordSize * 2.
	self assemble: 'lea' with: backend regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithBoolean: aBoolean [
	aBoolean
		ifTrue: [ self loadRwithTrue ]
		ifFalse: [ self loadRwithFalse ]
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithE [
	backend move: backend regE to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithEindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regE
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFP [
	backend move: backend regFP to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFPindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regFP
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFalse [
	backend move: backend regFalse to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: backend regR withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadRwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithM [
	backend move: backend regM to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithMindex: index [ 
	backend 
		load: backend regR
		fromBase: backend regM
		indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithNil [
	backend move: backend regNil to: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> loadRwithRatA [
	self load: backend regR fromBase: backend regR index: backend regA

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRatOffsetA [
	backend load: backend regR fromBase: backend regR offsetImm: 0 index: backend regA scaleImm: 1.

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRbyte: index [
	pointer
		reset;
		length: 8;
		base: backend regR;
		displacement: index - 1.
	self
		assemble: 'mov' with: backend regR b with: pointer;
		andRwithImmediate: 16rFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regR
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRwordAt: index [
	pointer
		reset;
		length: 16;
		base: backend regR;
		displacement: index - 1.
	self
		assemble: 'mov' with: backend regR with: pointer;
		andRwithImmediate: 16rFFFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithS [
	backend move: backend regS to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSP [
	backend move: backend regSP to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSPindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regSP
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSbyte: index [
	pointer
		reset;
		length: 8;
		base: backend regS;
		displacement: index - 1.
	self
		assemble: 'mov' with: backend regR b with: pointer;
		andRwithImmediate: 16rFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regS
		  indexImm: index

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
		base: backend regS;
		displacement: index - 1.
	self
		assemble: 'mov' with: backend regR w with: pointer;
		andRwithImmediate: 16rFFFF;
		convertRtoSmallInteger
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithT [
	backend move: backend regT to: backend regR
]

{ #category : #storing }
JITAssemblerAMD64 >> loadRwithTIBatIndexR [
	| seg |
	seg := wordSize = 8 ifTrue: [gs] ifFalse: [fs].
	pointer
		reset;
		length: self addressLength;
		index: backend regR;
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: backend regR with: pointer
]

{ #category : #storing }
JITAssemblerAMD64 >> loadRwithThreadVariableAtIndexR [
	pointer
		reset;
		length: self addressLength;
		index: backend regR;
		scale: wordSize.
	wordSize = 8
		ifTrue: [pointer segment: gs; displacement: 16r1480]
		ifFalse: [pointer segment: fs; displacement: 16rE10].
	self assemble: 'mov' with: backend regR with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithTindex: index [ 
	backend 
		  load: backend regR
		  fromBase: backend regT
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithTos [
	backend load: backend regR fromBase: backend regSP offsetImm: 0

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithTrue [
	backend move: backend regTrue to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithX0 [
	| mov |

	mov := wordSize = 8 ifTrue: [
			'movq'
		] ifFalse: [ 'movd' ].
	self 
		assemble: mov
		with: backend regR
		with: backend regF0
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSPwithFP [
	backend move: backend regFP to: backend regSP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSPwithT [
	backend move: backend regT to: backend regSP
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSWithRIndex: index [
	self 
		  load: backend regS
		  fromBase: backend regR
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithA [
	backend move: backend regA to: backend regS
]

{ #category : #integers }
JITAssemblerAMD64 >> loadSwithAddressOfSatA [
	pointer
		reset;
		length: self addressLength;
		base: backend regS;
		index: backend regA;
		scale: backend regS sizeInBytes;
		displacement: 0 - backend regS sizeInBytes.
	self assemble: 'lea' with: backend regS with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithFPindex: index [ 
	backend 
		  load: backend regS
		  fromBase: backend regFP
		  indexImm: index

]

{ #category : #private }
JITAssemblerAMD64 >> loadSwithGindex: index [ 
	backend 
		  load: backend regS
		  fromBase: backend regG
		  indexImm: index

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
	self assemble: 'mov' with: backend regS withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithNil [
	backend move: backend regNil to: backend regS
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithRindex: index [ 
	backend 
		  load: backend regS
		  fromBase: backend regR
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithT [
	backend move: backend regT to: backend regS
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithMindex: index [ 
	backend 
		  load: backend regTrue
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithA [
	backend move: backend regA to: backend regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithAindex: index [ 
	backend 
		  load: backend regT
		  fromBase: backend regA
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithEindex: index [ 
	backend 
		  load: backend regT
		  fromBase: backend regE
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithFPindex: index [ 
	backend 
		  load: backend regT
		  fromBase: backend regFP
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithImmediate: imm [
	#imm32.
	self assemble: 'mov' with: backend regT withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithMindex: index [ 
	backend 
		  load: backend regT
		  fromBase: backend regM
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithR [
	backend move: backend regR to: backend regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithTindex: index [ 
	backend 
		  load: backend regT
		  fromBase: backend regT
		  indexImm: index

]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithFalse: register [ 
	backend move: backend regFalse to: register
]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithNil: register [ 
	backend move: backend regNil to: register
]

{ #category : #loading }
JITAssemblerAMD64 >> loadWithTrue: register [ 
	backend move: backend regTrue to: register
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX0withRasDouble [
	self 
		assemble: 'cvtsi2sd'
		with: backend regF0
		with: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX1roundingX0 [
	self 
		assemble: 'roundsd'
		with: backend regF1
		with: backend regF0
		with: 3

]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithRatA [
	self loadZeroExtendByte: backend regR from: backend regR atIndexAt: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithRindex: index [
	#dontOptimize.
	self loadZeroExtendByte: backend regR from: backend regR atIndex: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteRwithSPatA [
	self loadZeroExtendByte: backend regR from: backend regSP atIndexAt: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendByteTwithAindex: index [
	#dontOptimize.
	self loadZeroExtendByte: backend regT from: backend regA atIndex: index
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendLongRwithRatA [
	self load: backend regR e from: backend regR atIndexAt: backend regA
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendLongRwithRindex: index [
	#dontOptimize.
	self 
		  load: backend regR e
		  fromBase: backend regR
		  indexImm: index

]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendShortRwithRoffset: offset [
	pointer
		reset;
		length: 16;
		base: backend regR;
		displacement: offset.
	self assemble: 'movzx' with: backend regR with: pointer
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
	self dec: backend regT; shortJumpIfNotZeroTo: loop
]

{ #category : #jumps }
JITAssemblerAMD64 >> loopTo: label [
	self
		dec: backend regT;
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
		dec: backend regT;
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
	self 
		assemble: 'mulsd'
		with: backend regF0
		with: backend regF1

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyRbyA [
	self ASSERT: (backend regR r == rax and: [backend regA r == rdx]).
	self assemble: 'imul' with: backend regA
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyRbyConstant: imm [
	self assemble: 'imul' with: backend regR with: backend regR with: imm
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> nativeCode [
	^(NativeCode withAll: literals) code: memory bytes
]

{ #category : #logic }
JITAssemblerAMD64 >> orRwithA [
	backend or: backend regR with: backend regA

]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popA [
	backend pop: backend regA
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popB [
	backend pop: backend regB
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popE [
	backend pop: backend regE
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popFP [
	backend pop: backend regFP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popFalse [
	backend pop: backend regFalse
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popG [
	backend pop: backend regG
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popM [
	backend pop: backend regM
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popNil [
	backend pop: backend regNil
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popR [
	backend pop: backend regR
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popS [
	backend pop: backend regS
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSP [
	backend pop: backend regSP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSPindirect [
	pointer reset; length: self addressLength; base: backend regSP.
	self assemble: 'pop' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popT [
	backend pop: backend regT
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popTrue [
	backend pop: backend regTrue
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushA [
	backend push: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> pushAOnFPUStack [
	pointer reset; length: 64; base: backend regA.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushAatToffset: offset [
	pointer
		reset;
		length: self addressLength;
		base: backend regA;
		index: backend regT;
		scale: backend regSP sizeInBytes;
		displacement: offset.
	self assemble: 'push' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushB [
	backend push: backend regB
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushE [
	backend push: backend regE
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushEindex: index [
	self assemble: 'push' withReg: backend regE index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFP [
	backend push: backend regFP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFPindex: index [
	self assemble: 'push' withReg: backend regFP index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFalse [
	backend push: backend regFalse
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushG [
	backend push: backend regG
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushImmediate: imm [
	#imm8.
	#imm32.
	self assemble: 'push' withImm: imm
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushIndirectR [
	pointer reset; length: self addressLength; base: backend regR.
	self assemble: 'push' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushM [
	backend push: backend regM
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushNil [
	backend push: backend regNil
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushR [
	backend push: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> pushROnFPUStack [
	pointer reset; length: 64; base: backend regR.
	self assemble: 'fld' with: pointer
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushRbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: backend regR;
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
		base: backend regR;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushS [
	backend push: backend regS
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSP [
	backend push: backend regSP
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSbyte: index [
	pointer
		reset;
		length: self addressLength;
		base: backend regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSindex: index [
	self assemble: 'push' withReg: backend regS index: index
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
		base: backend regS;
		displacement: index - 1.
	self
		assemble: 'push' with: pointer;
		andSPindirectWithImmediate: 16rFFFF;
		convertTosToSmallInteger
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushT [
	backend push: backend regT
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushTindex: index [
	self assemble: 'push' withReg: backend regT index: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushTrue [
	backend push: backend regTrue
]

{ #category : #services }
JITAssemblerAMD64 >> readFPUStatusOnA [
	pointer reset; length: 16; base: backend regA.
	self assemble: 'fstsw' with: pointer
]

{ #category : #private }
JITAssemblerAMD64 >> reserveStackSlots: amount [
	self subtract: amount * self addressSize from: backend regSP
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
		move: backend regFP to: backend regSP;
		pop: backend regFP
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
	self assemble: 'rcl' with: backend regR with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> restoreRsmallInteger [
	self assemble: 'rcl' with: backend regR with: 1
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
	pointer reset; length: 64; base: backend regR.
	self assemble: 'fstp' with: pointer; dropTopOfFPU
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftLeftRwithT [
	backend shiftLeft: backend regR by: backend regT

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftLogicalRright: count [
	backend shiftRight: backend regR byImm: count

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRightRwithT [
	backend shiftRightArithmetic: backend regR by: backend regT

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRleft: count [
	 backend shiftLeft: backend regR byImm: count

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftRright: count [
	backend shiftRightArithmetic: backend regR byImm: count

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftTleft: count [
	backend shiftLeft: backend regT byImm: count

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> shiftTright: count [
	backend shiftRightArithmetic: backend regT byImm: count

]

{ #category : #comparing }
JITAssemblerAMD64 >> smallInteger: anInteger [
	^(anInteger bitShift: 1) + 1
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> sqrtDoubleX0 [
	self 
		assemble: 'sqrtsd'
		with: backend regF0
		with: backend regF0
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinRindex: index [
	self 
		  store: backend regA
		  intoBase: backend regR
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinSPatT [
	self 
		  store: backend regA
		  intoBase: backend regSP
		  index: backend regT
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinThreadVariableAtIndexR [
	pointer
		reset;
		length: self addressLength;
		index: backend regR;
		scale: wordSize.
	wordSize = 8
		ifTrue: [pointer segment: gs; displacement: 16r1480]
		ifFalse: [pointer segment: fs; displacement: 16rE10].
	self assemble: 'mov' with: pointer with: backend regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeAinTindex: index [
	self 
		  store: backend regA
		  intoBase: backend regT
		  indexImm: index
]

{ #category : #integers }
JITAssemblerAMD64 >> storeArgumentsInStack [
	self
		store: rcx intoBase: rbp indexImm: 3;
		store: rdx intoBase: rbp indexImm: 4;
		store: r8 intoBase: rbp indexImm: 5;
		store: r9 intoBase: rbp indexImm: 6

]

{ #category : #storing }
JITAssemblerAMD64 >> storeByteAinRindex: index [
	#dontOptimize.
	pointer
		reset;
		length: 8;
		base: backend regR;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: backend regA b
]

{ #category : #storing }
JITAssemblerAMD64 >> storeByteTinRatA [
	pointer
		reset;
		length: 8;
		base: backend regR;
		index: backend regA;
		displacement: -1.
	self assemble: 'mov' with: pointer with: backend regT b
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> storeDoubleResultInRindirect [
	pointer
		reset;
		length: 64;
		base: backend regR.
	wordSize = 8 ifTrue: [
		self 
			assemble: 'movq'
			with: pointer
			with: backend regF0
	] ifFalse: [
		self assemble: 'fstp' with: pointer
	]
]

{ #category : #storing }
JITAssemblerAMD64 >> storeEinAindex: index [
	self 
		  store: backend regE
		  intoBase: backend regA
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeEinRindex: index [
	self 
		  store: backend regE
		  intoBase: backend regR
		  indexImm: index
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inA [
	pointer
		reset;
		length: 64;
		base: backend regA.
	self 
		assemble: 'movq'
		with: pointer
		with: backend regF0
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inR [
	pointer
		reset;
		length: 64;
		base: backend regR.
	self 
		assemble: 'movq'
		with: pointer
		with: backend regF0
]

{ #category : #loading }
JITAssemblerAMD64 >> storeLargeX0inT [
	pointer
		reset;
		length: 64;
		base: backend regT.
	self 
		assemble: 'movq'
		with: pointer
		with: backend regF0
]

{ #category : #storing }
JITAssemblerAMD64 >> storeLongTInRAtA [
	self store: backend regT e in: backend regR indexAt: backend regA

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
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: pointer with: backend regT e
]

{ #category : #loading }
JITAssemblerAMD64 >> storeMXCSRintoA [
	pointer reset; length: 32; base: backend regA.
	self assemble: 'stmxcsr' with: pointer
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinAindex: index [
	self 
		  store: backend regR
		  intoBase: backend regA
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinEindex: index [
	self 
		  store: backend regR
		  intoBase: backend regE
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinFPindex: index [
	self 
		  store: backend regR
		  intoBase: backend regFP
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinSbyte: index [
	pointer
		reset;
		length: 8;
		base: backend regS;
		displacement: index - 1.
	self assemble: 'mov' with: pointer with: backend regR b
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinSindex: index [
	backend 
		  store: backend regR
		  intoBase: backend regS
		  indexImm: index
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> storeRinSwordAt: index [
	pointer
		reset;
		length: 16;
		base: backend regS;
		displacement: index - 1.
	self
		convertRtoNativeInteger;
		assemble: 'mov' with: pointer with: backend regR w;
		convertRtoSmallInteger
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinTindex: index [
	self 
		  store: backend regR
		  intoBase: backend regT
		  indexImm: index
]

{ #category : #integers }
JITAssemblerAMD64 >> storeShortAinRoffset: offset [
	pointer
		reset;
		length: 16;
		base: backend regR;
		displacement: offset.
	self assemble: 'mov' with: pointer with: backend regA w
]

{ #category : #storing }
JITAssemblerAMD64 >> storeShortTinRatOffsetA [
	pointer
		reset;
		length: 16;
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: pointer with: backend regT w
]

{ #category : #storing }
JITAssemblerAMD64 >> storeSinAindex: index [
	self 
		  store: backend regS
		  intoBase: backend regA
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeSinRindex: index [
	self 
		  store: backend regS
		  intoBase: backend regR
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTIBwithAatIndexR [
	| seg |
	seg := wordSize = 8 ifTrue: [gs] ifFalse: [fs].
	pointer
		reset;
		length: self addressLength;
		index: backend regR;
		scale: wordSize;
		segment: seg.
	self assemble: 'mov' with: pointer with: backend regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTInRAtA [
	self 
		  store: backend regT
		  intoBase: backend regR
		  index: backend regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinAindex: index [
	self 
		  store: backend regT
		  intoBase: backend regA
		  indexImm: index
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRatA [
	self 
		  store: backend regT
		  intoBase: backend regR
		  index: backend regA
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: pointer with: backend regT
]

{ #category : #storing }
JITAssemblerAMD64 >> storeTinRindex: index [
	self 
		  store: backend regT
		  intoBase: backend regR
		  indexImm: index
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subAfromR [
	backend sub: backend regA from: backend regR

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subAfromT [
	backend sub: backend regA from: backend regT    

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subDoubleX1fromX0 [
	self 
		assemble: 'subsd'
		with: backend regF0
		with: backend regF1

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subFromRconstant: imm [
	backend subImm: imm from: backend regR

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subTfromR [
	backend sub: backend regT from: backend regR

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subTslotsToSP [
	self assemble: 'neg' with: backend regT.
	pointer
		reset;
		length: self addressLength;
		base: backend regSP;
		index: backend regT;
		scale: backend regSP sizeInBytes.
	self
		assemble: 'lea' with: backend regSP with: pointer;
		assemble: 'neg' with: backend regT
]

{ #category : #integers }
JITAssemblerAMD64 >> testAintegerBit [
	self assemble: 'test' with: backend regA8 with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testIntegerBitOf: aRegister [
	self assemble: 'test' with: aRegister byte with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testRintegerBit [
	self assemble: 'test' with: backend regR8 with: 1
]

{ #category : #loading }
JITAssemblerAMD64 >> testRwithR [
	self assemble: 'test' with: backend regR with: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> testTIntegerBit [
	self assemble: 'test' with: backend regT byte with: 1
]

{ #category : #integers }
JITAssemblerAMD64 >> testTintegerBit [
	self assemble: 'test' with: backend regT byte with: 1
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
	backend xor: backend regA with: backend regR

]

{ #category : #logic }
JITAssemblerAMD64 >> xorFPwithFP [
	backend xor: backend regFP with: backend regFP

]

{ #category : #logic }
JITAssemblerAMD64 >> xorRwithA [
	backend xor: backend regR with: backend regA

]
