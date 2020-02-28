"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #Register,
	#superclass : #ISAOperand,
	#instVars : [
		'name',
		'index',
		'family',
		'flags'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #initialization }
Register class >> initialize [
	self initializeRegisters; initializeFamilies
]

{ #category : #initialization }
Register class >> initialize16BitRegisters [
	#('ax' 'cx' 'dx' 'bx' 'sp' 'bp' 'si' 'di' 'r8w' 'r9w' 'r10w' 'r11w' 'r12w' 'r13w' 'r14w' 'r15w')
		withIndexDo: [:r :i | | register |
			register := self new
				name: r;
				index: i - 1;
				length: 16;
				initializeFlags.
			self addRegister: register]
]

{ #category : #initialization }
Register class >> initialize32BitRegisters [
	#('eax' 'ecx' 'edx' 'ebx' 'esp' 'ebp' 'esi' 'edi' 'r8d' 'r9d' 'r10d' 'r11d' 'r12d' 'r13d' 'r14d' 'r15d')
		withIndexDo: [:r :i | | register |
			register := self new
				name: r;
				index: i - 1;
				length: 32;
				initializeFlags.
			self addRegister: register]
]

{ #category : #initialization }
Register class >> initialize64BitRegisters [
	#('rax' 'rcx' 'rdx' 'rbx' 'rsp' 'rbp' 'rsi' 'rdi' 'r8' 'r9' 'r10' 'r11' 'r12' 'r13' 'r14' 'r15')
		withIndexDo: [:r :i | | register |
			register := self new
				name: r;
				index: i - 1;
				length: 64;
				initializeFlags.
			self addRegister: register]
]

{ #category : #initialization }
Register class >> initialize8BitRegisters [
	#('al' 'cl' 'dl' 'bl' 'ah' 'ch' 'dh' 'bh') withIndexDo: [:r :i | | register |
		register := Register new
			name: r;
			index: i - 1;
			length: 8;
			initializeFlags.
		self addRegister: register]
]

{ #category : #initialization }
Register class >> initialize8BitRexRegisters [
	#('spl' 'bpl' 'sil' 'dil' 'r8b' 'r9b' 'r10b' 'r11b' 'r12b' 'r13b' 'r14b' 'r15b')
		withIndexDo: [:r :i | | register |
			register := self new
				name: r;
				index: i + 3;
				length: 8;
				initializeFlags.
			self addRegister: register]
]

{ #category : #initialization }
Register class >> initializeMMXRegisters [
	0 to: 7 do: [:i | | mmx |
		mmx := self new
			name: 'mmx' , i asString;
			index: i;
			length: 64;
			initializeFlags.
		self addRegister: mmx]
]

{ #category : #initialization }
Register class >> initializeRIPRegister [
	| register |
	register := self new
		name: 'rip';
		index: 5;
		length: 64;
		initializeFlags.
	self addRegister: register
]

{ #category : #initialization }
Register class >> initializeRegisters [
	self
		initialize8BitRegisters;
		initialize8BitRexRegisters;
		initialize16BitRegisters;
		initialize32BitRegisters;
		initialize64BitRegisters;
		initializeMMXRegisters;
		initializeSSERegisters;
		initializeSegmentRegisters
]

{ #category : #initialization }
Register class >> initializeSSERegisters [
	0 to: 15 do: [:i | | xmm |
		xmm := self new
			name: 'xmm' , i asString;
			index: i;
			length: 128;
			initializeFlags.
		self addRegister: xmm].
	0 to: 15 do: [:i | | ymm |
		ymm := self new
			name: 'ymm' , i asString;
			index: i;
			length: 256;
			initializeFlags.
		self addRegister: ymm]
]

{ #category : #initialization }
Register class >> initializeSegmentRegisters [
	#('es' 'cs' 'ss' 'ds' 'fs' 'gs') withIndexDo: [:r :i | | register |
		register := self new
			name: r;
			index: i - 1;
			length: 16;
			initializeFlags.
		self addRegister: register]
]

{ #category : #accessing }
Register class >> xmm: i [
	^self named: 'xmm' , i asString
]

{ #category : #accessing }
Register class >> ymm: i [
	^self named: 'ymm' , i asString
]

{ #category : #initialization }
Register >> addFlag: flagBit [
	flags := flags bitOr: flagBit
]

{ #category : #accessing }
Register >> b [
	^family at: 1
]

{ #category : #encoding }
Register >> byte [
	^self b
]

{ #category : #accessing }
Register >> e [
	^family at: 3
]

{ #category : #accessing }
Register >> extensionBit [
	^self isExtended ifTrue: [1] ifFalse: [0]
]

{ #category : #private }
Register >> family: anArray [
	family := anArray
]

{ #category : #accessing }
Register >> index [
	^index
]

{ #category : #accessing }
Register >> index: anInteger [
	index := anInteger
]

{ #category : #initialization }
Register >> initializeFamily [
	(name first = $r and: [length = 64]) ifTrue: [
		family := {self getB. self getW. self getE. self}.
		family select: #notNil thenDo: [:reg | reg family: family]]
]

{ #category : #initialization }
Register >> initializeFlags [
	flags := 0.
	self initializeRegisterGroupFlag
]

{ #category : #initialization }
Register >> isCompatibleWith: anOperandType [
	anOperandType isRegister ifFalse: [^false].
	(anOperandType registerGroup = self registerGroup
		and: [length = anOperandType length or: [anOperandType length isNil]])
		ifTrue: [^true].
	^anOperandType isSpecificRegister and: [name = anOperandType name]
]

{ #category : #testing }
Register >> isExtended [
	^index > 7
]

{ #category : #testing }
Register >> isRegister [
	^true
]

{ #category : #testing }
Register >> isTemplate [
	^true
]

{ #category : #accessing }
Register >> name [
	^name
]

{ #category : #accessing }
Register >> name: aString [
	name := aString asLowercase
]

{ #category : #testing }
Register >> needsExtraBit [
	^self isExtended
]

{ #category : #initialization }
Register >> prefers: anOperandType to: anotherOperandType [
	^anOperandType name = name
]

{ #category : #printing }
Register >> printOn: aStream [
	name isNil ifTrue: [^super printOn: aStream].
	aStream nextPutAll: name
]

{ #category : #accessing }
Register >> r [
	^family at: 4
]

{ #category : #accessing }
Register >> regExtension [
	^self extensionBit
]

{ #category : #encoding }
Register >> rm [
	^index
]

{ #category : #accessing }
Register >> w [
	^family at: 2
]
