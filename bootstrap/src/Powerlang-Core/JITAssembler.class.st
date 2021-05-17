Class {
	#name : #JITAssembler,
	#superclass : #Object,
	#instVars : [
		'wordSize',
		'backend'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #'operations - arithmetic' }
JITAssembler >> add: source1 to: source2andDest [
	self subclassResponsibility
]

{ #category : #'operations - arithmetic' }
JITAssembler >> addImm: imm to: dest [
	self subclassResponsibility
]

{ #category : #accessing }
JITAssembler >> addressSize [
	"Return the size of address in bytes, e.g, 4 for 32bit archs
	 and 8 for 64bit archs"

	^ self subclassResponsibility

]

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest with: source2 [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #'memory - load / store' }
JITAssembler >> load: dstReg fromMem: srcMemRef [
	"Load `dstReg` from memory location `srcMemRef`. 

	 The size of data loaded is specified in `srcMemRef`"

	^ self subclassResponsibility

]

{ #category : #memory }
JITAssembler >> memRef [
	"Return clean instance of pointer-sized memory reference"

	^ self subclassResponsibility

]

{ #category : #memory }
JITAssembler >> memRef16 [
	"Return clean instance of memory reference."

	^ self memRef length: 16; yourself

]

{ #category : #memory }
JITAssembler >> memRef32 [
	"Return clean instance of memory reference."

	^ self memRef length: 32; yourself

]

{ #category : #memory }
JITAssembler >> memRef32: baseReg index: indexReg [
	^ self memRef32 
		base: baseReg; 
		displacement: -4;
		index: indexReg;
		scale: 4;
		yourself

]

{ #category : #memory }
JITAssembler >> memRef32: baseReg indexImm: indexImm [
	^ self memRef32 
		base: baseReg; 
		displacement: (indexImm - 1) * 4;
		yourself

]

{ #category : #memory }
JITAssembler >> memRef64 [
	"Return clean instance of memory reference."

	^ self memRef length: 64; yourself

]

{ #category : #memory }
JITAssembler >> memRef8 [
	"Return clean instance of memory reference."

	^ self memRef length: 8; yourself

]

{ #category : #memory }
JITAssembler >> memRef8: baseReg index: indexReg [
	^ self memRef8 
		base: baseReg; 
		displacement: -1;
		index: indexReg;
		scale: 1;
		yourself

]

{ #category : #memory }
JITAssembler >> memRef8: baseReg indexImm: indexImm [
	^ self memRef8
		base: baseReg; 
		displacement: (indexImm - 1);
		yourself

]

{ #category : #memory }
JITAssembler >> memRef: baseReg index: indexRef [
	^ self memRef 
		base: baseReg; 
		displacement: self addressSize negated;
		index: indexRef;
		scale: self addressSize;
		yourself

]

{ #category : #memory }
JITAssembler >> memRef: baseReg indexImm: indexImm [
	^ self memRef 
		base: baseReg; 
		displacement: (indexImm - 1) * self addressSize;
		yourself

]

{ #category : #memory }
JITAssembler >> memRefAatT [
^self memRef: self regA index: self regT
]

{ #category : #memory }
JITAssembler >> memRefSPatT [
	^ self memRef: self regSP index: self regT
]

{ #category : #services }
JITAssembler >> move: srcReg to: dstReg [
	^ self subclassResponsibility

]

{ #category : #'operations - logical' }
JITAssembler >> or: src1AndDst with: src2 [
	^ self subclassResponsibility

]

{ #category : #private }
JITAssembler >> pop: dstReg [
	"This can be implemented like:

	 self add: self regSP i: wordSize
	 self load: dstReg with: self regSP offset: 0

	 Architectures with specialized push/pop may override
	 this.

	 TODO.
	"
	self error: 'Unfinished, see comment above'

]

{ #category : #private }
JITAssembler >> push: srcReg [
	"This can be implemented like:

	 self store: srcReg with: self regSP offset: 0
	 self sub: self regSP i: wordSize


	 Architectures with specialized push/pop may override
	 this.

	 TODO.
	"
	self error: 'Unfinished, see comment above'

]

{ #category : #'registers - IR' }
JITAssembler >> regA [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regA8 [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regB [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regC [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regE [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regF0 [
	"IEEE 754 double register"
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regF1 [
	"IEEE 754 double register"
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regFP [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regFalse [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regG [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regIP [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regM [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regNil [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regR [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regR8 [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regS [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regSP [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regT [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regT8 [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regTrue [
	^ self subclassResponsibility

]

{ #category : #'registers - IR' }
JITAssembler >> regV [
	^ self subclassResponsibility

]

{ #category : #'operations - logical' }
JITAssembler >> shiftLeft: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftLeft: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRight: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRight: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRightArithmetic: srcAndDst by: countReg [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> shiftRightArithmetic: srcAndDst byImm: count [
	self subclassResponsibility
]

{ #category : #'memory - load / store' }
JITAssembler >> store: srcReg intoMem: dstMemRef [
	"Store `srcReg` into memory location `srcMemRef`. 

	 The size of data loaded is specified in `srcMemRef`"

	^ self subclassResponsibility

]

{ #category : #'operations - arithmetic' }
JITAssembler >> sub: src2 from: src1AndDst [
	self subclassResponsibility

]

{ #category : #'operations - arithmetic' }
JITAssembler >> subImm: imm from: src2AndDst [
	self addImm: imm negated to: src2AndDst

]

{ #category : #'operations - logical' }
JITAssembler >> xor: src1AndDst with: src2 [
	^ self subclassResponsibility

]
