Class {
	#name : #AssemblerBackend,
	#superclass : #Object,
	#instVars : [
		'wordSize',
		'memory'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #basic }
AssemblerBackend >> add: source1 to: source2andDest [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> addImm: imm to: dest [
	self subclassResponsibility
]

{ #category : #accessing }
AssemblerBackend >> addressBitSize [
	^self addressSize * 8

]

{ #category : #accessing }
AssemblerBackend >> addressLength [
	^wordSize * 8
]

{ #category : #accessing }
AssemblerBackend >> addressSize [
	"Return the size of address in bytes, e.g, 4 for 32bit archs
	 and 8 for 64bit archs"

	^wordSize
]

{ #category : #alignment }
AssemblerBackend >> alignTo: aNumber [
	| current count |
	current := memory position.
	count := (current alignedTo: aNumber) - current.
	self nop: count
]

{ #category : #basic }
AssemblerBackend >> and: source1andDest with: source2 [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> and: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> assembleByte: byte [
	memory nextBytePut: byte
]

{ #category : #basic }
AssemblerBackend >> assembleBytes: aByteArray [
	memory nextBytesPut: aByteArray
]

{ #category : #basic }
AssemblerBackend >> assembleBytes: value count: count [
	self ASSERT: value isInteger.
	self ASSERT:(count == 4 or:[ count == 8 ]).

	count == 4 ifTrue: [
		memory nextLongPut: value
	] ifFalse: [ 
		memory nextLargePut: value
	].

]

{ #category : #relocation }
AssemblerBackend >> baseAddress [
	^memory baseAddress
]

{ #category : #private }
AssemblerBackend >> bitLengthOf: anInteger [
	(anInteger between: -16r80 and: 16r7F) ifTrue: [^8].
	(anInteger between: -16r8000 and: 16r7FFF) ifTrue: [^16].
	(anInteger between: -16r80000000 and: 16r7FFFFFFF) ifTrue: [^32].
	(anInteger between: -16r8000000000000000 and: 16r7FFFFFFFFFFFFFFF)
		ifTrue: [^64].
	(anInteger
		between: -16r80000000000000000000000000000000
		and: 16r7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
		ifTrue: [^128].
	^nil
]

{ #category : #accessing }
AssemblerBackend >> bytes [
	^memory bytes
]

{ #category : #accessing }
AssemblerBackend >> codeSize [
	^memory codeSize
]

{ #category : #labels }
AssemblerBackend >> currentAddress [
	^memory currentAddress
]

{ #category : #basic }
AssemblerBackend >> initialize [
	memory := RelocatableBuffer new.
]

{ #category : #private }
AssemblerBackend >> jumpTo: label [
	self subclassResponsibility
]

{ #category : #memory }
AssemblerBackend >> load: dstReg fromMem: srcMemRef [
	"Load `dstReg` from memory location `srcMemRef`. 

	 The size of data loaded is specified in `srcMemRef`"

	^ self subclassResponsibility

]

{ #category : #'private - jumps' }
AssemblerBackend >> memRef [
	self subclassResponsibility
]

{ #category : #memory }
AssemblerBackend >> memRef16 [
	"Return clean instance of memory reference."

	^ self memRef length: 16; yourself

]

{ #category : #memory }
AssemblerBackend >> memRef32 [
	"Return clean instance of memory reference."

	^ self memRef length: 32; yourself

]

{ #category : #memory }
AssemblerBackend >> memRef32: baseReg index: indexReg [
	^ self memRef32 
		base: baseReg; 
		displacement: -4;
		index: indexReg;
		scale: 4;
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRef32: baseReg indexImm: indexImm [
	^ self memRef32 
		base: baseReg; 
		displacement: (indexImm - 1) * 4;
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRef64 [
	"Return clean instance of memory reference."

	^ self memRef length: 64; yourself

]

{ #category : #memory }
AssemblerBackend >> memRef8 [
	"Return clean instance of memory reference."

	^ self memRef length: 8; yourself

]

{ #category : #memory }
AssemblerBackend >> memRef8: baseReg index: indexReg [
	^ self memRef8 
		base: baseReg; 
		displacement: -1;
		index: indexReg;
		scale: 1;
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRef8: baseReg indexImm: indexImm [
	^ self memRef8
		base: baseReg; 
		displacement: (indexImm - 1);
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRef: baseReg index: indexRef [
	^ self memRef 
		base: baseReg; 
		displacement: self addressSize negated;
		index: indexRef;
		scale: self addressSize;
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRef: baseReg indexImm: indexImm [
	^ self memRef 
		base: baseReg; 
		displacement: (indexImm - 1) * self addressSize;
		yourself

]

{ #category : #memory }
AssemblerBackend >> memRefAatT [
^self memRef: self regA index: self regT
]

{ #category : #memory }
AssemblerBackend >> memRefSPatT [
	^ self memRef: self regSP index: self regT
]

{ #category : #memory }
AssemblerBackend >> memory [
	^memory
]

{ #category : #alignment }
AssemblerBackend >> moveImm: imm to: dstReg [
	"Load constant to register `dstImm`"

	self subclassResponsibility

]

{ #category : #'private - jumps' }
AssemblerBackend >> nativeCode [
	^ NativeCode new code: memory bytes
]

{ #category : #basic }
AssemblerBackend >> or: src1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regA [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regB [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regBP [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regC [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regE [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regFalse [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regIP [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regM [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regNil [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regR [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regS [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regSP [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regT [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regTrue [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> regV [
	^self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> reset [
	memory reset
]

{ #category : #basic }
AssemblerBackend >> shiftLeft: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> shiftRightArithmetic: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> shiftRightArithmetic: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #basic }
AssemblerBackend >> store: srcReg intoMem: dstMemRef [
	^self subclassResponsibility
]

{ #category : #initialization }
AssemblerBackend >> stream [
	^memory stream
]

{ #category : #services }
AssemblerBackend >> wordSize [
	^wordSize
]