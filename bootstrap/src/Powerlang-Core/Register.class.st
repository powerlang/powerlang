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
	#pools : [
		'OperandTypeFlags',
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #private }
Register class >> addRegister: aRegister [
	Registers at: aRegister name put: aRegister
]

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
Register class >> initializeFamilies [
	Registers do: [:reg | reg initializeFamily]
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
	
	"Make sure OperandTypeFlags are initialized since
	 it is required and order of initialization is not 
	 defined in Pharo and Smallltalk/X."
	OperandTypeFlags initialize.

	self
		initialize8BitRegisters;
		initialize8BitRexRegisters;
		initialize16BitRegisters;
		initialize32BitRegisters;
		initialize64BitRegisters;
		initializeRIPRegister;
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
Register class >> named: aString [
	"
	Register named: 'rax'
	"
	^Registers at: aString asLowercase ifAbsent: nil
]

{ #category : #accessing }
Register class >> segment: index [
	index = 0 ifTrue: [^cs].
	index = 1 ifTrue: [^ss].
	index = 2 ifTrue: [^ds].
	index = 3 ifTrue: [^es].
	index = 4 ifTrue: [^fs].
	index = 5 ifTrue: [^gs].
	^nil
]

{ #category : #accessing }
Register class >> withIndex: index length: length [
	^Registers detect: [:r | 
		r index = index
			and: [r length = length]
			and: [(r name beginsWith: 'mmx') not]
			and: [r isSegment not]]
]

{ #category : #accessing }
Register class >> withIndex: index length: length long: aBoolean [
	^Registers detect: [:r | 
		r index = index
			and: [r length = length]
			and: [(r name beginsWith: 'mmx') not]
			and: [r isSegment not]
			and: [r isLongModeOld8BitRegister ifTrue: [aBoolean] ifFalse: [true]]]
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
Register >> forLength: reglength [
	self ASSERT: (#(8 16 32 64) includes: reglength).

	reglength ==  8 ifTrue: [ ^ self b ].
	reglength == 16 ifTrue: [ ^ self w ].
	reglength == 32 ifTrue: [ ^ self e ].
	reglength == 64 ifTrue: [ ^ self r ].

]

{ #category : #private }
Register >> getB [
	self == rax ifTrue: [^al].
	self == rcx ifTrue: [^cl].
	self == rdx ifTrue: [^dl].
	self == rbx ifTrue: [^bl].
	self == rsi ifTrue: [^sil].
	self == rdi ifTrue: [^dil].
	self == rbp ifTrue: [^bpl].
	self == rsp ifTrue: [^spl].
	self == r8 ifTrue: [^r8b].
	self == r9 ifTrue: [^r9b].
	self == r10 ifTrue: [^r10b].
	self == r11 ifTrue: [^r11b].
	self == r12 ifTrue: [^r12b].
	self == r13 ifTrue: [^r13b].
	self == r14 ifTrue: [^r14b].
	self == r15 ifTrue: [^r15b].
	^nil
]

{ #category : #private }
Register >> getE [
	self == rax ifTrue: [^eax].
	self == rcx ifTrue: [^ecx].
	self == rdx ifTrue: [^edx].
	self == rbx ifTrue: [^ebx].
	self == rsi ifTrue: [^esi].
	self == rdi ifTrue: [^edi].
	self == rbp ifTrue: [^ebp].
	self == rsp ifTrue: [^esp].
	self == r8 ifTrue: [^r8d].
	self == r9 ifTrue: [^r9d].
	self == r10 ifTrue: [^r10d].
	self == r11 ifTrue: [^r11d].
	self == r12 ifTrue: [^r12d].
	self == r13 ifTrue: [^r13d].
	self == r14 ifTrue: [^r14d].
	self == r15 ifTrue: [^r15d].
	^nil
]

{ #category : #private }
Register >> getW [
	self == rax ifTrue: [^ax].
	self == rcx ifTrue: [^cx].
	self == rdx ifTrue: [^dx].
	self == rbx ifTrue: [^bx].
	self == rsi ifTrue: [^si].
	self == rdi ifTrue: [^di].
	self == rbp ifTrue: [^bp].
	self == rsp ifTrue: [^sp].
	self == r8 ifTrue: [^r8w].
	self == r9 ifTrue: [^r9w].
	self == r10 ifTrue: [^r10w].
	self == r11 ifTrue: [^r11w].
	self == r12 ifTrue: [^r12w].
	self == r13 ifTrue: [^r13w].
	self == r14 ifTrue: [^r14w].
	self == r15 ifTrue: [^r15w].
	^nil
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
Register >> initializeRegisterGroupFlag [
	(name includesString: 'mm') ifTrue: [^self addFlag: RegisterSIMD].
	(#('es' 'cs' 'ss' 'ds' 'fs' 'gs') includes: name)
		ifTrue: [^self addFlag: RegisterSegment].
	self addFlag: RegisterGP
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
Register >> isGeneral [
	^self registerGroup = RegisterGP
]

{ #category : #testing }
Register >> isLongModeOld8BitRegister [
	self = spl ifTrue: [^true].
	self = bpl ifTrue: [^true].
	self = sil ifTrue: [^true].
	self = dil ifTrue: [^true].
	^false
]

{ #category : #testing }
Register >> isRegister [
	^true
]

{ #category : #testing }
Register >> isSIMD [
	^self registerGroup = RegisterSIMD
]

{ #category : #testing }
Register >> isSegment [
	^self registerGroup = RegisterSegment
]

{ #category : #testing }
Register >> isTemplate [
	^true
]

{ #category : #accessing }
Register >> long [
	^ family at: 3
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

{ #category : #initialization }
Register >> registerGroup [
	^flags bitAnd: RegisterGroupMask
]

{ #category : #encoding }
Register >> rm [
	^index
]

{ #category : #accessing }
Register >> short [
	^ family at: 2
]

{ #category : #accessing }
Register >> w [
	^family at: 2
]
