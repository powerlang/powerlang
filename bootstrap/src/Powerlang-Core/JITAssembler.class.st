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

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest with: source2 [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> and: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #'operations - logical' }
JITAssembler >> andIndirect: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> lea: dest base: base index: index scale: scale [
	self subclassResponsibility
]

{ #category : #loading }
JITAssembler >> load: dstReg fromBase: baseReg index: indexReg [
	self load: dstReg fromBase: baseReg offsetImm: 0 - wordSize index: indexReg scaleImm: wordSize

]

{ #category : #loading }
JITAssembler >> load: dstReg fromBase: baseReg indexImm: index [ 
	self load: dstReg fromBase: baseReg offsetImm: (index - 1) * wordSize

]

{ #category : #loading }
JITAssembler >> load: dstReg fromBase: baseReg offsetImm: offsetInBytes [
	"Load pointer into `dstReg` from memory. The effective address is computed as:

		EA := baseReg + offsetInBytes
	"    
	^ self subclassResponsibility

]

{ #category : #loading }
JITAssembler >> load: dstReg fromBase: baseReg offsetImm: offsetInBytes index: indexReg scaleImm: scaleInBytes [
	"Load pointer into `dstReg` from memory. The effective address is computed as:

		EA := baseReg + offsetInBytes + ((indexReg - 1) * scaleInBytes)
	"    
	^ self subclassResponsibility

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

{ #category : #storing }
JITAssembler >> store: srcReg intoBase: baseReg index: indexReg [
	self store: srcReg intoBase: baseReg offsetImm: 0 - wordSize index: indexReg scaleImm: wordSize

]

{ #category : #storing }
JITAssembler >> store: srcReg intoBase: baseReg indexImm: index [ 
	self store: srcReg intoBase: baseReg offsetImm: (index - 1) * wordSize

]

{ #category : #storing }
JITAssembler >> store: srcReg intoBase: baseReg offsetImm: offsetInBytes [
	"Store pointer from `dstReg` into memory. The effective address is computed as:

		EA := baseReg + offsetInBytes
	"    
	^ self subclassResponsibility

]

{ #category : #storing }
JITAssembler >> store: srcReg intoBase: baseReg offsetImm: offsetInBytes index: indexReg scaleImm: scaleInBytes [
	"Store pointer from `dstReg` into memory. The effective address is computed as:

		EA := baseReg + offsetInBytes + ((indexReg - 1) * scaleInBytes)
	"    
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
