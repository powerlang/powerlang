"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAInstruction,
	#superclass : #Object,
	#instVars : [
		'prefix',
		'mnemonic',
		'operands',
		'template'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'instance creation' }
ISAInstruction class >> db: byte [
	^self new db: byte
]

{ #category : #comparing }
ISAInstruction >> = instruction [
	self class == instruction class ifFalse: [^false].
	prefix = instruction prefix ifFalse: [^false].
	mnemonic = instruction mnemonic ifFalse: [^false].
	(self hasOperands or: [instruction hasOperands]) ifFalse: [^true].
	operands isNil ifTrue: [^false].
	operands size = instruction arity ifFalse: [^false].
	operands
		with: instruction operands
		do: [:op1 :op2 | op1 = op2 ifFalse: [^false]].
	^true
]

{ #category : #accessing }
ISAInstruction >> arity [
	^operands size
]

{ #category : #accessing }
ISAInstruction >> beTemplate [
	1 to: operands size do: [:i | | op |
		op := operands at: i.
		operands at: i put: op template]
]

{ #category : #private }
ISAInstruction >> db: byte [
	| imm |
	mnemonic := '.db'.
	imm := ISAImmediate new value: byte.
	operands := {imm}
]

{ #category : #encoding }
ISAInstruction >> encoder [
	^InstructionEncoder new instruction: self
]

{ #category : #encoding }
ISAInstruction >> encoding [
	^ByteArray streamContents: [:strm | self writeEncodingOn: strm]
]

{ #category : #encoding }
ISAInstruction >> encoding32 [
	^ByteArray streamContents: [:strm | self writeEncoding32On: strm]
]

{ #category : #encoding }
ISAInstruction >> encoding64 [
	^ByteArray streamContents: [:strm | self writeEncoding64On: strm]
]

{ #category : #testing }
ISAInstruction >> hasDirectMemoryReference [
	^operands anySatisfy: [:op | op isDirectMemoryReference]
]

{ #category : #testing }
ISAInstruction >> hasDisplacement [
	operands isNil ifTrue: [^false].
	^operands anySatisfy: [:op | op isMemory and: [op hasDisplacement]]
]

{ #category : #comparing }
ISAInstruction >> hasOperands [
	^operands size > 0
]

{ #category : #testing }
ISAInstruction >> hasSib [
	operands isNil ifTrue: [^false].
	^operands anySatisfy: [:op | op isMemory and: [op hasSib]]
]

{ #category : #comparing }
ISAInstruction >> hash [
	^prefix hashWith: mnemonic with: self operand1 with: self operand2
]

{ #category : #testing }
ISAInstruction >> isCall [
	^mnemonic = 'call'
]

{ #category : #testing }
ISAInstruction >> isJump [
	^mnemonic first = $j or: [mnemonic beginsWith: 'loop']
]

{ #category : #testing }
ISAInstruction >> isLike: anISAInstruction [
	self class = anISAInstruction class ifFalse: [^false].
	mnemonic = anISAInstruction mnemonic ifTrue: [^self = anISAInstruction].
	operands = anISAInstruction operands ifFalse: [^false].
	^self spec isLike: anISAInstruction spec
]

{ #category : #testing }
ISAInstruction >> isPushFP [
	| operand |
	^(mnemonic beginsWith: 'push')
		and: [
			operand := operands at: 1.
			operand isRegister]
		and: [operand index = rbp index]
]

{ #category : #testing }
ISAInstruction >> isReturn [
	^mnemonic = 'ret'
]

{ #category : #testing }
ISAInstruction >> isTemplate [
	1
		to: operands size
		do: [:i | (operands at: i) isTemplate ifFalse: [^false]].
	^true
]

{ #category : #testing }
ISAInstruction >> isTestAL1 [
	mnemonic = 'test' ifFalse: [^false].
	operands first = al ifFalse: [^false].
	operands second isImmediate ifFalse: [^false].
	^operands second value = 1
]

{ #category : #accessing }
ISAInstruction >> jumpOffset [
	self
		ASSERT: ((self isJump or: [self isCall]) and: [operands anyone isImmediate]).
	^operands first value + self sizeInBytes
]

{ #category : #accessing }
ISAInstruction >> mnemonic [
	^mnemonic
]

{ #category : #accessing }
ISAInstruction >> mnemonic: aString [
	mnemonic := aString asLowercase.
	template notNil ifTrue: [template mnemonic: aString]
]

{ #category : #encoding }
ISAInstruction >> mod [
	(operands conform: [:op | op isRegister or: [op isImmediate]])
		ifTrue: [^2r11].
	operands do: [:op | op isMemory ifTrue: [^op mod]]
]

{ #category : #accessing }
ISAInstruction >> operand1 [
	^operands notNil ifTrue: [operands at: 1 ifAbsent: nil]
]

{ #category : #accessing }
ISAInstruction >> operand2 [
	^operands notNil ifTrue: [operands at: 2 ifAbsent: nil]
]

{ #category : #accessing }
ISAInstruction >> operand3 [
	^operands at: 3
]

{ #category : #accessing }
ISAInstruction >> operand4 [
	^operands at: 4
]

{ #category : #private }
ISAInstruction >> operandFrom: anObject [
	anObject isInteger ifTrue: [^ISAImmediate new value: anObject].
	anObject isString ifTrue: [
		^anObject first = $@
			ifTrue: [anObject]
			ifFalse: [MemoryOperand fromString: anObject]].
	^anObject
]

{ #category : #accessing }
ISAInstruction >> operands [
	^operands ifNil: #()
]

{ #category : #accessing }
ISAInstruction >> operands: aCollection [
	operands := aCollection collect: [:op | self operandFrom: op].
	template notNil
		ifTrue: [template operands: (operands collect: [:op | op template])]
]

{ #category : #testing }
ISAInstruction >> overridesAddressSize: anInteger [
	| length |
	operands isNil ifTrue: [^false].
	length := anInteger bitShift: 3.
	^operands
		anySatisfy: [:op | op isMemory
			and: [op base notNil]
			and: [op pointerLength != length]]
]

{ #category : #accessing }
ISAInstruction >> prefix [
	^prefix
]

{ #category : #accessing }
ISAInstruction >> prefix: aLegacyPrefix [
	prefix := aLegacyPrefix.
	template notNil ifTrue: [template prefix: aLegacyPrefix]
]

{ #category : #printing }
ISAInstruction >> printOn: aStream [
	aStream nextPutAll: mnemonic.
	operands isNil ifTrue: [^self].
	operands
		do: [:op | aStream space; nextPutAll: op asString]
		separatedBy: [aStream nextPut: $,]
]

{ #category : #accessing }
ISAInstruction >> sizeInBytes [
	| stream |
	stream := #[] writeStream.
	self writeEncodingOn: stream.
	^stream size
]

{ #category : #accessing }
ISAInstruction >> spec [
	^self encoder spec
]

{ #category : #services }
ISAInstruction >> template [
	^template
]

{ #category : #updating }
ISAInstruction >> updateTemplate: anISAInstruction [
	| arity array |
	arity := operands size.
	array := Array new: arity.
	1 to: arity do: [:i | array at: i put: (operands at: i) template].
	anISAInstruction
		prefix: prefix;
		mnemonic: mnemonic;
		operands: array
]

{ #category : #services }
ISAInstruction >> useTemplate [
	template := self shallowCopy.
	mnemonic isNil ifTrue: [^self].
	template mnemonic: mnemonic; prefix: prefix.
	operands notNil
		ifTrue: [template operands: (operands collect: [:op | op template])]
]

{ #category : #encoding }
ISAInstruction >> writeEncoding32On: aStream [
	^self encoder wordSize: 4; writeEncodingOn: aStream
]

{ #category : #encoding }
ISAInstruction >> writeEncoding64On: aStream [
	^self encoder wordSize: 8; writeEncodingOn: aStream
]

{ #category : #encoding }
ISAInstruction >> writeEncodingOn: aStream [
	^self encoder wordSize: WordSize; writeEncodingOn: aStream
]
