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
		identityIndexOf: anObject
		ifAbsent: [ literals
				add: anObject;
				size ].
	^ index + 2
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> addRwithImmediate: imm [
	backend addImm: imm to: backend regR 
]

{ #category : #logic }
JITAssemblerAMD64 >> addSPwithImmediate: imm [
	backend addImm: imm to: backend regSP
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

{ #category : #private }
JITAssemblerAMD64 >> buildFrame [
	self
		push: backend regFP;
		move: backend regSP to: backend regFP
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

{ #category : #comparing }
JITAssemblerAMD64 >> compareRwithNil [
	self assemble: 'cmp' with: backend regR with: backend regNil
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
JITAssemblerAMD64 >> convertRtoNativeInteger [
	self convertToNativeInteger: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertRtoSmallInteger [
	self convertToSmallInteger: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> convertTtoNativeInteger [
	self convertToNativeInteger: backend regT
]

{ #category : #jumps }
JITAssemblerAMD64 >> dec: srcAndDstReg [
	backend addImm: -1 to: srcAndDstReg

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

{ #category : #loading }
JITAssemblerAMD64 >> jumpToMindex: index [
	self assemble: 'jmp' withReg: backend regM index: index
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
JITAssemblerAMD64 >> load:dstReg withImmediate: imm [
	#imm32.
	self assemble: 'mov' with: dstReg withImm: imm
]

{ #category : #loading }
JITAssemblerAMD64 >> load: register withLiteral: anObject [ 
	| index |

	index := self addLiteral: anObject.
	backend load: register
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithAindex: index [ 
	backend load: backend regA
		fromMem: (backend memRef: backend regA indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithEindex: index [ 
	backend load: backend regA
		fromMem: (backend memRef: backend regE indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFPindex: index [ 
	backend load: backend regA
		fromMem: (backend memRef: backend regFP indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithFalse [
	backend move: backend regFalse to: backend regA
]

{ #category : #private }
JITAssemblerAMD64 >> loadAwithGindex: index [ 
	backend load: backend regA
		fromMem: (backend memRef: backend regG indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadAwithGindex: index
]

{ #category : #'as yet unclassified' }
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
	backend load: backend regA
		fromMem: (backend memRef: backend regM indexImm: index)
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
JITAssemblerAMD64 >> loadAwithRoffsetAtA [
	backend load: backend regA 
		 fromMem:(backend memRef base: backend regR; index: backend regA; scale: 1)

]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithS [
	backend move: backend regS to: backend regA
]

{ #category : #loading }
JITAssemblerAMD64 >> loadAwithSindex: index [ 
	backend load: backend regA
		fromMem: (backend memRef: backend regS indexImm: index)
]

{ #category : #integers }
JITAssemblerAMD64 >> loadAwithSmallInteger: anInteger [
	self loadAwithImmediate: (anInteger bitShift: 1) + 1
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
	backend load: backend regE
		fromMem: (backend memRef: backend regFP indexImm: index)
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
	backend load: backend regFalse
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadGwithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadGwithMindex: index [ 
	backend load: backend regG
		fromMem: (backend memRef: backend regM indexImm: index)
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
	backend load: backend regM
		fromMem: (backend memRef: backend regFP indexImm: index)
]

{ #category : #private }
JITAssemblerAMD64 >> loadMwithGindex: index [ 
	backend load: backend regM
		fromMem: (backend memRef: backend regG indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadMwithGindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithMindex: index [ 
	backend load: backend regM
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithRindex: index [ 
	backend load: backend regM
		fromMem: (backend memRef: backend regR indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadMwithTindex: index [ 
	backend load: backend regM
		fromMem: (backend memRef: backend regT indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadNilWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadNilWithMindex: index [ 
	backend load: backend regNil
		fromMem: (backend memRef: backend regM indexImm: index)
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
JITAssemblerAMD64 >> loadRwithE [
	backend move: backend regE to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithEindex: index [ 
	backend load: backend regR
		fromMem: (backend memRef: backend regE indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFP [
	backend move: backend regFP to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithFPindex: index [ 
	backend load: backend regR
		fromMem: (backend memRef: backend regFP indexImm: index)
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
	backend load: backend regR
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithNil [
	backend move: backend regNil to: backend regR
]

{ #category : #integers }
JITAssemblerAMD64 >> loadRwithRatA [
	self load: backend regR fromMem: (backend memRef: backend regR index: backend regA)

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRatOffsetA [
	backend load: backend regR 
		 fromMem:(backend memRef base: backend regR; index: backend regA; scale: 1)

]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithRindex: index [ 
	backend load: backend regR
		fromMem: (backend memRef: backend regR indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithS [
	backend move: backend regS to: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSPindex: index [ 
	backend load: backend regR
		fromMem: (backend memRef: backend regSP indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRwithSindex: index [ 
	backend load: backend regR
		fromMem: (backend memRef: backend regS indexImm: index)
]

{ #category : #integers }
JITAssemblerAMD64 >> loadRwithSmallInteger: anInteger [
	self loadRwithImmediate: (anInteger bitShift: 1) + 1
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
	backend load: backend regS
		fromMem: (backend memRef: backend regFP indexImm: index)
]

{ #category : #private }
JITAssemblerAMD64 >> loadSwithGindex: index [ 
	backend load: backend regS
		fromMem: (backend memRef: backend regG indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithGlobal: aSymbol [
	| index |
	index := NativizationEnvironment indexOfGlobal: aSymbol.
	self loadSwithGindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithNil [
	backend move: backend regNil to: backend regS
]

{ #category : #loading }
JITAssemblerAMD64 >> loadSwithRindex: index [ 
	backend load: backend regS
		fromMem: (backend memRef: backend regR indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithLiteral: anObject [
	| index |
	index := self addLiteral: anObject.
	self loadTrueWithMindex: index
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTrueWithMindex: index [ 
	backend load: backend regTrue
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithA [
	backend move: backend regA to: backend regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithAindex: index [ 
	backend load: backend regT
		fromMem: (backend memRef: backend regA indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithEindex: index [ 
	backend load: backend regT
		fromMem: (backend memRef: backend regE indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithFPindex: index [ 
	backend load: backend regT
		fromMem: (backend memRef: backend regFP indexImm: index)
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
	backend load: backend regT
		fromMem: (backend memRef: backend regM indexImm: index)
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithR [
	backend move: backend regR to: backend regT
]

{ #category : #loading }
JITAssemblerAMD64 >> loadTwithTindex: index [ 
	backend load: backend regT
		fromMem: (backend memRef: backend regT indexImm: index)
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
	backend load: backend regR fromMem: (backend memRef32: backend regR index: backend regA)

]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendLongRwithRindex: index [
	#dontOptimize.
	backend
		  load: backend regR e
		  fromMem:(backend memRef32: backend regR indexImm: index)

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
JITAssemblerAMD64 >> pushE [
	backend push: backend regE
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushFP [
	backend push: backend regFP
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
JITAssemblerAMD64 >> pushS [
	backend push: backend regS
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushSmallInteger: integer [
	self pushImmediate: (integer bitShift: 1) + 1
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> pushT [
	backend push: backend regT
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
	backend store: backend regA
		intoMem: (backend memRef: backend regT indexImm: index)
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
JITAssemblerAMD64 >> storeEinRindex: index [ 
	backend store: backend regE
		intoMem: (backend memRef: backend regR indexImm: index)
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
JITAssemblerAMD64 >> storeLongTinRatA [
	backend store: backend regT intoMem: (backend memRef32: backend regR index: backend regA)

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
	backend store: backend regR
		intoMem: (backend memRef: backend regA indexImm: index)
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinEindex: index [ 
	backend store: backend regR
		intoMem: (backend memRef: backend regE indexImm: index)
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinFPindex: index [ 
	backend store: backend regR
		intoMem: (backend memRef: backend regFP indexImm: index)
]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinSindex: index [
	backend store: backend regR
		  intoMem:(backend memRef: backend regS indexImm: index)

]

{ #category : #storing }
JITAssemblerAMD64 >> storeRinTindex: index [ 
	backend store: backend regR
		intoMem: (backend memRef: backend regT indexImm: index)
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
JITAssemblerAMD64 >> storeSinRindex: index [ 
	backend store: backend regS
		intoMem: (backend memRef: backend regR indexImm: index)
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
JITAssemblerAMD64 >> storeTinRatA [
	backend store: backend regT intoMem: (backend memRef: backend regR index: backend regA)

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
	backend store: backend regT
		intoMem: (backend memRef: backend regR indexImm: index)
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
