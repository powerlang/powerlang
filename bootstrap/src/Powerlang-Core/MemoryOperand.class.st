"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #MemoryOperand,
	#superclass : #ISAOperand,
	#instVars : [
		'base',
		'index',
		'scale',
		'displacement',
		'segment'
	],
	#pools : [
		'Registers'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'instance creation' }
MemoryOperand class >> fromStream: aStream [
	| memory |
	memory := AssemblerParser new memory parse: aStream.
	memory isPetitFailure
		ifTrue: [self error: 'invalid operand: ' , memory message].
	^memory
]

{ #category : #'instance creation' }
MemoryOperand class >> fromString: aString [
	"
	MemoryOperand fromString: 'qword ptr [rbx]'
	"
	^self fromStream: aString readStream
]

{ #category : #comparing }
MemoryOperand >> = operand [
	self class == operand class ifFalse: [^false].
	length = operand length ifFalse: [^false].
	base = operand base ifFalse: [^false].
	index = operand index ifFalse: [^false].
	self scale = operand scale ifFalse: [^false].
	displacement = operand displacement ifFalse: [^false].
	^segment = operand segment
]

{ #category : #accessing }
MemoryOperand >> base [
	^base
]

{ #category : #accessing }
MemoryOperand >> base: aRegister [
	base := aRegister
]

{ #category : #accessing }
MemoryOperand >> baseExtension [
	^base notNil ifTrue: [base extensionBit] ifFalse: [0]
]

{ #category : #accessing }
MemoryOperand >> displacement [
	^displacement ifNil: 0
]

{ #category : #accessing }
MemoryOperand >> displacement: anInteger [
	displacement := anInteger ifNil: 0
]

{ #category : #encoding }
MemoryOperand >> displacementBytes [
	| bytes displ n |
	n := (base notNil and: [displacement between: -128 and: 127])
		ifTrue: [1]
		ifFalse: [4].
	base == rip ifTrue: [n := 4].
	bytes := ByteArray new: n.
	displ := displacement.
	1 to: bytes size do: [:i | 
		bytes at: i put: (displ bitAnd: 16rFF).
		displ := displ bitShift: -8].
	^bytes
]

{ #category : #encoding }
MemoryOperand >> displacementLength [
	displacement = 0 ifTrue: [^0].
	^(base notNil and: [displacement between: -128 and: 127])
		ifTrue: [1]
		ifFalse: [4]
]

{ #category : #printing }
MemoryOperand >> displacementValue [
	| value |
	displacement isNumber ifTrue: [^displacement].
	displacement size = 4 ifTrue: [^displacement longAtOffset: 0].
	displacement size = 2 ifTrue: [^displacement shortAtOffset: 0].
	value := displacement at: 1.
	(value isOnBit: 16r80) ifTrue: [^value - (1 bitShift: displacement size * 8)].
	^value
]

{ #category : #encoding }
MemoryOperand >> encodeSib: aSIB [
	| s i b |
	s := scale ifNil: 1.
	i := index isNil ifTrue: [rsp index] ifFalse: [index index \\ 8].
	b := base isNil ifTrue: [rbp index] ifFalse: [base index \\ 8].
	aSIB
		scaleFactor: s;
		index: i;
		base: b
]

{ #category : #testing }
MemoryOperand >> hasDisplacement [
	^self hasExplicitDisplacement
		or: [base isNil]
		or: [self requiresSpecialCaseDisplacement]
]

{ #category : #testing }
MemoryOperand >> hasExplicitDisplacement [
	^displacement != 0
]

{ #category : #testing }
MemoryOperand >> hasOnlyDisplacement [
	^index isNil and: [base isNil]
]

{ #category : #testing }
MemoryOperand >> hasSib [
	^index notNil or: [self requiresSpecialCaseSib]
]

{ #category : #comparing }
MemoryOperand >> hash [
	^length
		hashWith: base
		with: index
		with: scale
		with: displacement
		with: segment
]

{ #category : #accessing }
MemoryOperand >> index [
	^index
]

{ #category : #accessing }
MemoryOperand >> index: aRegister [
	index := aRegister
]

{ #category : #accessing }
MemoryOperand >> indexExtension [
	^index notNil ifTrue: [index extensionBit] ifFalse: [0]
]

{ #category : #initialization }
MemoryOperand >> initialize [
	super initialize.
	displacement := 0.
	scale := 1
]

{ #category : #testing }
MemoryOperand >> isCompatibleWith: anOperandType [
	^anOperandType isMemory
		and: [length = anOperandType memoryLength
			or: [anOperandType memoryLength isNil]]
]

{ #category : #testing }
MemoryOperand >> isDirectMemoryReference [
	^self hasOnlyDisplacement
]

{ #category : #testing }
MemoryOperand >> isMemory [
	^true
]

{ #category : #testing }
MemoryOperand >> isTemplate [
	^displacement = 0
]

{ #category : #accessing }
MemoryOperand >> length: anInteger [
	length := anInteger
]

{ #category : #printing }
MemoryOperand >> lengthString [
	length = 256 ifTrue: [^'ymmword ptr'].
	length = 128 ifTrue: [^'xmmword ptr'].
	(length isNil or: [length = 64]) ifTrue: [^'qword ptr'].
	length = 32 ifTrue: [^'dword ptr'].
	length = 16 ifTrue: [^'word ptr'].
	length = 8 ifTrue: [^'byte ptr'].
	self ASSERT: false.
	^''
]

{ #category : #accessing }
MemoryOperand >> memoryLength [
	^length
]

{ #category : #encoding }
MemoryOperand >> mod [
	base == rip ifTrue: [^2r0].
	base isNil ifTrue: [^0].
	self hasDisplacement ifFalse: [^0].
	(displacement between: -128 and: 127) ifTrue: [^2r1] ifFalse: [^2r10]
]

{ #category : #testing }
MemoryOperand >> needsExtraBit [
	(base notNil and: [base needsExtraBit]) ifTrue: [^true].
	^index notNil and: [index needsExtraBit]
]

{ #category : #accessing }
MemoryOperand >> pointerLength [
	base notNil ifTrue: [^base length].
	^self displacementLength
]

{ #category : #printing }
MemoryOperand >> printOn: aStream [
	| sign displ |
	aStream nextPutAll: self lengthString; nextPutAll: ' ['.
	segment notNil ifTrue: [
		segment printOn: aStream.
		aStream nextPut: $:].
	base notNil ifTrue: [base printOn: aStream].
	index notNil ifTrue: [
		base notNil ifTrue: [aStream nextPutAll: ' + '].
		index printOn: aStream.
		scale isNil
			ifFalse: [aStream nextPutAll: ' * '; nextPutAll: scale asString]].
	displ := self displacementValue.
	displ != 0 ifTrue: [
		(base notNil or: [index notNil]) ifTrue: [
			sign := displ > 0 ifTrue: [' + '] ifFalse: [' - '].
			aStream nextPutAll: sign].
		aStream nextPutAll: '0x'; nextPutAll: displ abs hex].
	aStream nextPut: $]
]

{ #category : #testing }
MemoryOperand >> requiresSpecialCaseDisplacement [
	^base notNil and: [base == r13 or: [base r == rbp]]
]

{ #category : #testing }
MemoryOperand >> requiresSpecialCaseSib [
	base ifNil: [^true].
	^base == r12 or: [base r == rsp]
]

{ #category : #private }
MemoryOperand >> reset [
	base := index := segment := length := nil.
	displacement := 0.
	scale := 1
]

{ #category : #encoding }
MemoryOperand >> rm [
	self hasSib ifTrue: [^2r100].
	^base ifNil: [2r101] ifNotNil: [base index]
]

{ #category : #accessing }
MemoryOperand >> scale [
	^scale ifNil: 0
]

{ #category : #accessing }
MemoryOperand >> scale: anInteger [
	scale := anInteger ifNil: 1
]

{ #category : #accessing }
MemoryOperand >> segment [
	^segment
]

{ #category : #accessing }
MemoryOperand >> segment: aRegister [
	segment := aRegister
]

{ #category : #encoding }
MemoryOperand >> sib [
	| factor s i b |
	factor := scale ifNil: 1.
	s := #[1 2 4 8] indexOf: factor.
	i := index isNil ifTrue: [rsp index] ifFalse: [index index bitAnd: 8r7].
	b := base isNil ifTrue: [rbp index] ifFalse: [base index bitAnd: 8r7].
	^((s - 1 bitShift: 6) bitOr: (i bitShift: 3)) bitOr: b
]

{ #category : #services }
MemoryOperand >> template [
	| template bits d |
	template := self copy.
	displacement = 0 ifTrue: [^template].
	bits := self displacementLength.
	d := bits = 1 ifTrue: [16r3F] ifFalse: [16r3FFFFFFF].
	^template displacement: d
]
