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

{ #category : #services }
JITAssemblerAMD64 >> disassembledText32 [
	^self nativeCode disassembledText32
]

{ #category : #services }
JITAssemblerAMD64 >> disassembledText64 [
	^self nativeCode disassembledText64
]

{ #category : #private }
JITAssemblerAMD64 >> initialize [
	super initialize.
	backend := self
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

{ #category : #'push/pop' }
JITAssemblerAMD64 >> popSPindirect [
	pointer reset; length: self addressLength; base: backend regSP.
	self assemble: 'pop' with: pointer
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
