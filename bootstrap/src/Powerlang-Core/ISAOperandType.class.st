"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAOperandType,
	#superclass : #Object,
	#instVars : [
		'type',
		'length',
		'memoryLength',
		'flags'
	],
	#classVars : [
		'Types'
	],
	#pools : [
		'OperandTypeFlags',
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #services }
ISAOperandType class >> imm16 [
	^self named: 'imm16'
]

{ #category : #services }
ISAOperandType class >> imm32 [
	^self named: 'imm32'
]

{ #category : #services }
ISAOperandType class >> imm8 [
	^self named: 'imm8'
]

{ #category : #services }
ISAOperandType class >> immediateTypes [
	^Types select: [:t | t isImmediate]
]

{ #category : #initialization }
ISAOperandType class >> initialize [
	self
		initializeTypes
]

{ #category : #initialization }
ISAOperandType class >> initializeFlags [
	"
	self initializeFlags
	"
	OperandTypeFlags := PoolDictionary new.
	OperandTypeFlags
		at: #ImmediateType put: 1;
		at: #ConstantType put: 2;
		at: #MemoryType put: 4;
		at: #RegisterType put: 8;
		at: #RegisterGroupMask put: 16rF00;
		at: #RegisterGP put: 16r0;
		at: #RegisterSIMD put: 16r100;
		at: #RegisterSegment put: 16r200;
		at: #RegisterSpecific put: 16r300
]

{ #category : #initialization }
ISAOperandType class >> initializeTypes [
	| dictionary |
	dictionary := Dictionary new.
	self typeNames lines collect: [:s | | pair type |
		pair := s substrings.
		type := self new type: pair first; length: pair second.
		dictionary at: type name put: type].
	Types := dictionary
]

{ #category : #services }
ISAOperandType class >> memoryTypes [
	^Types select: [:t | t isMemory] in: OrderedCollection new
]

{ #category : #'instance creation' }
ISAOperandType class >> named: aString [
	^Types at: aString
]

{ #category : #services }
ISAOperandType class >> r32 [
	^self named: 'r32'
]

{ #category : #services }
ISAOperandType class >> r64 [
	^self named: 'r64'
]

{ #category : #accessing }
ISAOperandType class >> typeNames [
	^'<xmm0> 128
		0 8
		1 8
		3 0
		al 8
		dx 16
		ax 16
		cl 8
		cr0-cr7 ?
		cr8 ?
		cs 16
		dr0-dr7 ?
		ds 16
		dx 16
		eax 32
		dx 16
		es 16
		far 0
		fs 16
		gs 16
		imm16 16
		imm32 32
		imm64 64
		imm8 8
		m ?
		m108byte ?
		m128 128
		m16 16
		m16&16 16
		m16&32 ?
		m16&64 ?
		m16:16 16
		m16:32 48
		m16:64 80
		m16int 16
		m256 256
		m28byte 7
		m2byte 16
		m32 32
		m32&32 32
		m32fp 32
		m32int 32
		m512byte 512
		m64 64
		m64fp 64
		m64int 64
		m8 8
		m80bcd 80
		m80fp 80
		mem ?
		mm 64
		mm1 64
		mm2 64
		mm/m32 64
		mm/m64 64
		mm2/m64 64
		moffs16 16
		moffs32 32
		moffs64 64
		moffs8 8
		p66 0
		ptr16:16 16
		ptr16:32 16
		pw 0
		r/m16 16
		r/m32 32
		r/m64 64
		r/m8 8
		r/m8 8
		r8 8
		r16 16
		r16/m16 16
		r32 32
		r32/m16 32
		r32/m32 32
		r32/m8 32
		r32a 32
		r32b 32
		r64 64
		r64/m16 64
		r64/m64 64
		r64a 64
		r64b 64
		rax 64
		reg ?
		reg/m16 16
		reg/m32 32
		reg/m8 8
		rel16 16
		rel32 32
		rel8 8
		sreg 16
		ss 16
		st ?
		st(0) ?
		st(i) ?
		vm32x 32
		vm32y 32
		vm64x 64
		vm64y 64
		xmm 128
		xmm/m128 128
		xmm/m32 128
		xmm/m64 128
		xmm0 128
		xmm1 128
		xmm1/m128 128
		xmm1/m32 128
		xmm1/m64 128
		xmm2 128
		xmm2/m128 128
		xmm2/m16 128
		xmm2/m32 128
		xmm2/m64 128
		xmm2/m8 128
		xmm3 128
		xmm3/m128 128
		xmm3/m32 128
		xmm3/m64 128
		xmm4 128
		ymm0 256
		ymm1 256
		ymm2 256
		ymm2/m256 256
		ymm3/m256 256
		ymm4 256'
]

{ #category : #services }
ISAOperandType class >> typeOfSpecialRegister: aRegister [
	aRegister = rax ifTrue: [^self named: 'rax'].
	aRegister = eax ifTrue: [^self named: 'eax'].
	aRegister = ax ifTrue: [^self named: 'ax'].
	aRegister = al ifTrue: [^self named: 'al'].
	aRegister = cl ifTrue: [^self named: 'cl'].
	aRegister = dx ifTrue: [^self named: 'dx']
]

{ #category : #services }
ISAOperandType class >> typesOfGeneralRegister: aRegister [
	| bits associations |
	bits := aRegister length asString.
	associations := OrderedCollection new: 4.
	Types do: [:type | | n |
		n := type name.
		n = ('r' , bits) ifTrue: [associations add: 1 -> type].
		n = 'reg' ifTrue: [associations add: 2 -> type].
		n = ('r/m' , bits) ifTrue: [associations add: 3 -> type].
		n = ('r' , bits , '/m' , bits) ifTrue: [associations add: 4 -> type]].
	^(associations sortBy: #key) collect: #value
]

{ #category : #services }
ISAOperandType class >> typesOfSIMDRegister: aRegister [
	| s |
	s := aRegister name.
	^Types select: [:type | | n |
		(#('0' '1' '3') includes: type name) not
			and: [
				n := type name upTo: $/.
				n size >= 3]
			and: [n first != $m]
			and: [s includesString: n]]
]

{ #category : #services }
ISAOperandType class >> typesOfSegmentRegister: aRegister [
	| type sreg |
	type := self named: aRegister name.
	sreg := self named: 'sreg'.
	^{type. sreg}
]

{ #category : #accessing }
ISAOperandType >> addFlag: flagBit [
	flags := flags bitOr: flagBit
]

{ #category : #services }
ISAOperandType >> constant [
	| i |
	i := #('0' '1' '3') indexOf: type.
	^i > 0 ifTrue: [#[0 1 3] at: i]
]

{ #category : #accessing }
ISAOperandType >> getMemoryLength [
	(type includesString: '/m8') ifTrue: [^8].
	(type includesString: '/m16') ifTrue: [^16].
	(type includesString: '/m32') ifTrue: [^32].
	(type includesString: '/m64') ifTrue: [^64].
	(type includesString: '/m128') ifTrue: [^128].
	(type includesString: ':16') ifTrue: [^0].
	(type includesString: ':32') ifTrue: [^0].
	(type includesString: ':64') ifTrue: [^0].
	^length
]

{ #category : #accessing }
ISAOperandType >> hasFlag: flagBit [
	^flags isOnBit: flagBit
]

{ #category : #testing }
ISAOperandType >> hasImmediateFlag [
	^self hasFlag: ImmediateType
]

{ #category : #initialization }
ISAOperandType >> initializeConstantFlag [
	type anyone isDigit ifTrue: [self addFlag: ConstantType]
]

{ #category : #initialization }
ISAOperandType >> initializeImmediateFlag [
	((type includesString: 'imm') or: [type includesString: 'rel'])
		ifTrue: [self addFlag: ImmediateType]
]

{ #category : #initialization }
ISAOperandType >> initializeMemoryFlag [
	self isImmediate ifTrue: [^self].
	(#('m8' 'm16' 'm32' 'm64' 'm128' 'm256' 'm512')
		anySatisfy: [:s | type includesString: s])
		ifTrue: [^self addFlag: MemoryType].
	((type includes: $m)
		and: [(type includesString: 'mm') not]
		and: [(type includesString: 'vm') not]
		and: [(type includesString: 'offs') not])
		ifTrue: [self addFlag: MemoryType]
]

{ #category : #accessing }
ISAOperandType >> initializeMemoryLength [
	memoryLength := self getMemoryLength
]

{ #category : #initialization }
ISAOperandType >> initializeRegisterFlag [
	self isImmediate ifTrue: [^self].
	(type includesString: 'r/m') ifTrue: [^self addFlag: RegisterType].
	(#('r8' 'r16' 'r32' 'r64' 'reg') anySatisfy: [:s | type includesString: s])
		ifTrue: [^self addFlag: RegisterType].
	(type includesString: 'mm') ifTrue: [^self addFlag: RegisterType].
	(self specificRegisterNames includes: type)
		ifTrue: [self addFlag: RegisterType]
]

{ #category : #initialization }
ISAOperandType >> initializeRegisterGroupFlag [
	self isImmediate ifTrue: [^self].
	(type includesString: 'r/m') ifTrue: [^self addFlag: RegisterGP].
	(#('r8' 'r16' 'r32' 'r64' 'reg') anySatisfy: [:s | type includesString: s])
		ifTrue: [^self addFlag: RegisterGP].
	(type includesString: 'mm') ifTrue: [^self addFlag: RegisterSIMD].
	(self specificRegisterNames includes: type)
		ifTrue: [^self addFlag: RegisterSpecific].
	type = 'sreg' ifTrue: [^self addFlag: RegisterSegment]
]

{ #category : #initialization }
ISAOperandType >> initializeSegmentFlag [
	^type = 'sreg' ifTrue: [self addFlag: RegisterSegment]
]

{ #category : #testing }
ISAOperandType >> isConstant [
	^self hasFlag: ConstantType
]

{ #category : #testing }
ISAOperandType >> isImmediate [
	^self hasFlag: ImmediateType
]

{ #category : #testing }
ISAOperandType >> isMemory [
	^self hasFlag: MemoryType
]

{ #category : #testing }
ISAOperandType >> isMoff [
	^type beginsWith: 'moff'
]

{ #category : #testing }
ISAOperandType >> isRegister [
	^self hasFlag: RegisterType
]

{ #category : #testing }
ISAOperandType >> isSegment [
	^self hasFlag: RegisterSegment
]

{ #category : #testing }
ISAOperandType >> isSpecificRegister [
	^self registerGroup = RegisterSpecific
]

{ #category : #accessing }
ISAOperandType >> length [
	^length
]

{ #category : #accessing }
ISAOperandType >> length: aString [
	length := aString = '?' ifFalse: [aString asInteger]
]

{ #category : #accessing }
ISAOperandType >> lengthForBits: n [
	^(type beginsWith: 'moff') ifTrue: [n] ifFalse: [length]
]

{ #category : #accessing }
ISAOperandType >> memoryLength [
	^memoryLength
]

{ #category : #accessing }
ISAOperandType >> name [
	^type
]

{ #category : #services }
ISAOperandType >> normalized [
	type first = $r ifFalse: [^self].
	type = 'rel8' ifTrue: [^self class imm8].
	type = 'rel16' ifTrue: [^self class imm16].
	type = 'rel32' ifTrue: [^self class imm32].
	type = 'r32a' ifTrue: [^self class r32].
	type = 'r32b' ifTrue: [^self class r32].
	type = 'r64a' ifTrue: [^self class r64].
	type = 'r64b' ifTrue: [^self class r64]
]

{ #category : #private }
ISAOperandType >> operandFrom: anInteger [
	self ASSERT: self isMoff.
	^MemoryOperand new displacement: anInteger; length: memoryLength
]

{ #category : #printing }
ISAOperandType >> printOn: aStream [
	aStream nextPutAll: type
]

{ #category : #services }
ISAOperandType >> register [
	type = '<xmm0>' ifTrue: [^xmm0].
	type = 'r8' ifTrue: [^nil].
	^Register named: type
]

{ #category : #testing }
ISAOperandType >> registerGroup [
	^flags bitAnd: RegisterGroupMask
]

{ #category : #testing }
ISAOperandType >> specificRegisterNames [
	^#('rax' 'eax' 'ax' 'al' 'cl' 'dx' 'es' 'cs' 'ss' 'ds' 'fs' 'gs')
]

{ #category : #accessing }
ISAOperandType >> type: aString [
	type := aString.
	flags := 0.
	self
		initializeMemoryLength;
		initializeConstantFlag;
		initializeImmediateFlag;
		initializeMemoryFlag;
		initializeRegisterFlag;
		initializeSegmentFlag;
		initializeRegisterGroupFlag
]
