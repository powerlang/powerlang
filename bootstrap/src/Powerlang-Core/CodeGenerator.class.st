Class {
	#name : #CodeGenerator,
	#superclass : #Object,
	#instVars : [
		'wordSize',
		'memory'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #basic }
CodeGenerator >> add: source1 to: source2andDest [
	self subclassResponsibility
]

{ #category : #'operations - arithmetic' }
CodeGenerator >> addDouble: source1 to: source2andDest [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> addImm: imm to: dest [
	self subclassResponsibility
]

{ #category : #accessing }
CodeGenerator >> addressBitSize [
	^self addressSize * 8

]

{ #category : #accessing }
CodeGenerator >> addressLength [
	^wordSize * 8
]

{ #category : #accessing }
CodeGenerator >> addressSize [
	"Return the size of address in bytes, e.g, 4 for 32bit archs
	 and 8 for 64bit archs"

	^wordSize
]

{ #category : #alignment }
CodeGenerator >> alignTo: aNumber [
	| current count |
	current := memory position.
	count := (current alignedTo: aNumber) - current.
	self nop: count
]

{ #category : #basic }
CodeGenerator >> and: source1andDest with: source2 [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> and: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #relocation }
CodeGenerator >> baseAddress [
	^memory baseAddress
]

{ #category : #private }
CodeGenerator >> bitLengthOf: anInteger [
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

{ #category : #basic }
CodeGenerator >> breakpoint [
	self subclassResponsibility
]

{ #category : #accessing }
CodeGenerator >> bytes [
	^memory bytes
]

{ #category : #basic }
CodeGenerator >> call: srcReg [ 
	self subclassResponsibility
]

{ #category : #accessing }
CodeGenerator >> callIndirect: aMemRef [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> clearHigh32: srcAndDstReg [
	self subclassResponsibility
]

{ #category : #accessing }
CodeGenerator >> codeSize [
	^memory codeSize
]

{ #category : #basic }
CodeGenerator >> compare: reg1 with: reg2 [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> compare: reg1 withImm: imm [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> compare: reg1 withMem: aMemRef [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> convert: src toDouble: dst [
	self subclassResponsibility
]

{ #category : #labels }
CodeGenerator >> currentAddress [
	^memory currentAddress
]

{ #category : #basic }
CodeGenerator >> dec: srcAndDstReg [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> decMem: aMemRef [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> divDouble: src1andDstReg by: src2reg [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> divide: srcAndDstReg extendingTo: extReg by: divisorReg [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> exchange: srcAndDstReg withMem: aMemRef [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> inc: srcAndDstReg [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> initialize [
	memory := RelocatableBuffer new.
]

{ #category : #basic }
CodeGenerator >> jumpTo: label [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> jumpToMem: aMemRef [
	self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> lea: dstReg withMem: srcMemRef [
	^self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> load: dstReg convertingDoubleToIntegerFromMem: srcMemRef [
	self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> load: dstReg fromMem: srcMemRef [
	"Load `dstReg` from memory location `srcMemRef`.
	 The size of data loaded is specified in `srcMemRef`.

	 When loading 32bits into 64bit register, high 32bits must be
	 cleared (in other words, 32bit value is *zero* extended to
	 64bits and stored in `dstReg`.

	 However, when loading 16bits or 8bits, high 48 or 56 bits
	 are *left intact*.

	 This somewhat weird behavior is heritage of x86.
	"

	^ self subclassResponsibility

]

{ #category : #basic }
CodeGenerator >> load: dstReg withTIBat: indexReg [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> load: dstReg withThreadVariableAt: indexReg [
	self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> loadDouble: dstReg fromMem: srcMemRef [ 
	"Load 64-bit floating point `dstReg` from memory location `srcMemRef`"
	
	^ self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> memRef [
	self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> memRef16 [
	"Return clean instance of memory reference."

	^ self memRef length: 16; yourself

]

{ #category : #memory }
CodeGenerator >> memRef16: baseReg offset: offsetReg [
	^ self memRef16
		base: baseReg;
		index: offsetReg;
		scale: 1;
		yourself
]

{ #category : #memory }
CodeGenerator >> memRef16: baseReg offsetImm: offsetImm [
	^ self memRef16
		base: baseReg;
		displacement: offsetImm;
		yourself
]

{ #category : #memory }
CodeGenerator >> memRef32 [
	"Return clean instance of memory reference."

	^ self memRef length: 32; yourself

]

{ #category : #memory }
CodeGenerator >> memRef32: baseReg index: indexReg [
	^ self memRef32 
		base: baseReg; 
		displacement: -4;
		index: indexReg;
		scale: 4;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef32: baseReg indexImm: indexImm [
	^ self memRef32 
		base: baseReg; 
		displacement: (indexImm - 1) * 4;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef32: baseReg offset: offsetReg [
	^ self memRef32
		base: baseReg;
		index: offsetReg;
		scale: 1;
		yourself
]

{ #category : #memory }
CodeGenerator >> memRef64 [
	"Return clean instance of memory reference."

	^ self memRef length: 64; yourself

]

{ #category : #memory }
CodeGenerator >> memRef64: baseReg indexImm: indexImm [
	^ self memRef64
		base: baseReg;
		displacement: (indexImm - 1) * 8;
		yourself
]

{ #category : #memory }
CodeGenerator >> memRef8 [
	"Return clean instance of memory reference."

	^ self memRef length: 8; yourself

]

{ #category : #memory }
CodeGenerator >> memRef8: baseReg index: indexReg [
	^ self memRef8 
		base: baseReg; 
		displacement: -1;
		index: indexReg;
		scale: 1;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef8: baseReg indexImm: indexImm [
	^ self memRef8
		base: baseReg; 
		displacement: (indexImm - 1);
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef: baseReg index: indexRef [
	^ self memRef 
		base: baseReg; 
		displacement: self addressSize negated;
		index: indexRef;
		scale: self addressSize;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef: baseReg index: indexRef offsetImm: anInteger [
	^ self memRef 
		base: baseReg; 
		displacement: anInteger;
		index: indexRef;
		scale: self addressSize;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef: baseReg indexImm: indexImm [
	^ self memRef 
		base: baseReg; 
		displacement: (indexImm - 1) * self addressSize;
		yourself

]

{ #category : #memory }
CodeGenerator >> memRef: baseReg offset: indexReg [
	^ self memRef
		base: baseReg;
		index: indexReg;
		scale: 1;
		yourself
]

{ #category : #memory }
CodeGenerator >> memRefAatT [
^self memRef: self regA index: self regT
]

{ #category : #memory }
CodeGenerator >> memRefSPatT [
	^ self memRef: self regSP index: self regT
]

{ #category : #memory }
CodeGenerator >> memory [
	^memory
]

{ #category : #services }
CodeGenerator >> move: srcReg to: dstReg [
	^ self subclassResponsibility

]

{ #category : #basic }
CodeGenerator >> moveDouble: srcReg into: dstReg [ 
	"move from X-type register srcReg into general purpose dstReg"
	
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> moveImm: imm to: dstReg [
	"Load constant to register `dstImm`"

	self subclassResponsibility

]

{ #category : #basic }
CodeGenerator >> mulDouble: src1andDstReg by: src2reg [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> multiply: src1AndDstLoReg by: src2reg wideningTo: dstHiReg [
	self subclassResponsibility
]

{ #category : #accessing }
CodeGenerator >> nativeCode [
	^ NativeCode new code: memory bytes
]

{ #category : #basic }
CodeGenerator >> or: src1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #'push/pop' }
CodeGenerator >> pop: dstReg [
	^ self subclassResponsibility

]

{ #category : #'push/pop' }
CodeGenerator >> popIntoMem: dstMemRef [
	self subclassResponsibility
]

{ #category : #'push/pop' }
CodeGenerator >> push: srcReg [
	self subclassResponsibility
]

{ #category : #'push/pop' }
CodeGenerator >> pushAOnFPUStack [
	^ self subclassResponsibility

]

{ #category : #'push/pop' }
CodeGenerator >> pushImm: imm [
	self subclassResponsibility
]

{ #category : #'push/pop' }
CodeGenerator >> pushMem: aMemRef [
	self subclassResponsibility
]

{ #category : #'push/pop' }
CodeGenerator >> pushROnFPUStack [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
CodeGenerator >> regA [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regB [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regC [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regE [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regFP [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
CodeGenerator >> regFalse [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regG [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
CodeGenerator >> regIP [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regM [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regNil [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regR [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regS [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regSP [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regT [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regTrue [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regV [
	^self subclassResponsibility
]

{ #category : #'registers - IR' }
CodeGenerator >> regX0 [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
CodeGenerator >> regX1 [
	^ self subclassResponsibility

]

{ #category : #basic }
CodeGenerator >> reset [
	memory reset
]

{ #category : #memory }
CodeGenerator >> roundDouble: srcReg into: dstReg [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> shiftLeft: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> shiftRight: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> shiftRightArithmetic: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> shiftRightArithmetic: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> sqrtDouble: srcReg into: dstReg [
	self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> store: srcReg intoMem: dstMemRef [
	^self subclassResponsibility
]

{ #category : #memory }
CodeGenerator >> storeDouble: srcReg intoMem: dstMemRef [ 
	^ self subclassResponsibility
]

{ #category : #initialization }
CodeGenerator >> stream [
	^memory stream
]

{ #category : #basic }
CodeGenerator >> sub: src1 from: src2AndDst [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> subDouble: src1 from: src2AndDst [ 
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> subImm: imm from: srcAndDst [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> test: src1Reg with: src2Reg [
	self subclassResponsibility
]

{ #category : #basic }
CodeGenerator >> test: srcReg withImm: imm [
	self subclassResponsibility
]

{ #category : #services }
CodeGenerator >> wordSize [
	^wordSize
]
