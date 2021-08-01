"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #JITAssemblerAMD64,
	#superclass : #AssemblerAMD64,
	#instVars : [
		'backend'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #loading }
JITAssemblerAMD64 >> clearFPUFlags [
	self assemble: 'fnclex'
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
		with: backend regX0
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
		with: backend regX0
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

{ #category : #services }
JITAssemblerAMD64 >> disassembledText32 [
	^self nativeCode disassembledText32
]

{ #category : #services }
JITAssemblerAMD64 >> disassembledText64 [
	^self nativeCode disassembledText64
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> divideDoubleX0byX1 [
	self 
		assemble: 'divsd'
		with: backend regX0
		with: backend regX1

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

{ #category : #loading }
JITAssemblerAMD64 >> exchangeRindirectWithT [
	pointer reset; length: self addressLength; base: backend regR.
	self assemble: 'xchg' with: pointer with: backend regT
]

{ #category : #private }
JITAssemblerAMD64 >> initialize [
	super initialize.
	backend := self
]

{ #category : #loading }
JITAssemblerAMD64 >> loadLargeX0withRindirect [
	pointer
		reset;
		length: 64;
		base: backend regR.
	self 
		assemble: 'movq'
		with: backend regX0
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
		with: backend regX1
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
JITAssemblerAMD64 >> loadMXCSRfromA [
	pointer reset; length: 32; base: backend regA.
	self assemble: 'ldmxcsr' with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> loadRconvertingDoublePointedByR [
	pointer reset; length: 64; base: backend regR.
	self assemble: 'cvttsd2si' with: backend regR with: pointer
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
JITAssemblerAMD64 >> loadRwithX0 [
	| mov |

	mov := wordSize = 8 ifTrue: [
			'movq'
		] ifFalse: [ 'movd' ].
	self 
		assemble: mov
		with: backend regR
		with: backend regX0
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX0withRasDouble [
	self 
		assemble: 'cvtsi2sd'
		with: backend regX0
		with: backend regR
]

{ #category : #loading }
JITAssemblerAMD64 >> loadX1roundingX0 [
	self 
		assemble: 'roundsd'
		with: backend regX1
		with: backend regX0
		with: 3

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
		with: backend regX0
		with: backend regX1

]

{ #category : #arithmetic }
JITAssemblerAMD64 >> multiplyRbyA [
	self ASSERT: (backend regR r == rax and: [backend regA r == rdx]).
	self assemble: 'imul' with: backend regA
]

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSPindirect [
	pointer reset; length: self addressLength; base: backend regSP.
	self assemble: 'pop' with: pointer
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

{ #category : #loading }
JITAssemblerAMD64 >> pushROnFPUStack [
	pointer reset; length: 64; base: backend regR.
	self assemble: 'fld' with: pointer
]

{ #category : #services }
JITAssemblerAMD64 >> readFPUStatusOnA [
	pointer reset; length: 16; base: backend regA.
	self assemble: 'fstsw' with: pointer
]

{ #category : #loading }
JITAssemblerAMD64 >> scaleFloatOnRWithA [
	self pushAOnFPUStack; pushROnFPUStack; assemble: 'fscale'.
	pointer reset; length: 64; base: backend regR.
	self assemble: 'fstp' with: pointer; dropTopOfFPU
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> sqrtDoubleX0 [
	self 
		assemble: 'sqrtsd'
		with: backend regX0
		with: backend regX0
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
			with: backend regX0
	] ifFalse: [
		self assemble: 'fstp' with: pointer
	]
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
		with: backend regX0
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
		with: backend regX0
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
JITAssemblerAMD64 >> storeTinRatOffsetA [
	pointer
		reset;
		length: self addressLength;
		base: backend regR;
		index: backend regA.
	self assemble: 'mov' with: pointer with: backend regT
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subDoubleX1fromX0 [
	self 
		assemble: 'subsd'
		with: backend regX0
		with: backend regX1

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

{ #category : #'opcodes - integer related' }
JITAssemblerAMD64 >> writeTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['stosq'] ifFalse: ['stosd'].
	self assembleByte: rep; assemble: mnemonic
]
