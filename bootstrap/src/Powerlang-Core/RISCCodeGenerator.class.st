Class {
	#name : #RISCCodeGenerator,
	#superclass : #CodeGenerator,
	#category : #'Powerlang-Core-Assembly'
}

{ #category : #jumps }
RISCCodeGenerator >> clearHigh32: srcAndDstReg [
	self
		shiftLeft: srcAndDstReg byImm: 32;
		shiftRight: srcAndDstReg byImm: 32
]

{ #category : #jumps }
RISCCodeGenerator >> dec: srcAndDstReg [
	self addImm: -1 to: srcAndDstReg

]

{ #category : #jumps }
RISCCodeGenerator >> decMem: aMemRef [
	self addImm: -1 toMem: aMemRef

]

{ #category : #jumps }
RISCCodeGenerator >> inc: srcAndDstReg [
	self addImm: 1 to: srcAndDstReg

]

{ #category : #jumps }
RISCCodeGenerator >> pop: srcReg [
	| memref |
	memref := self memRef base: self regSP.
	self
		load: srcReg fromMem: memref;
		addImm: wordSize to: self regSP 
]

{ #category : #jumps }
RISCCodeGenerator >> push: srcReg [
	| memref |
	memref := self memRef base: self regSP; displacement: -8.
	self
		store: srcReg intoMem: memref;
		subImm: wordSize from: self regSP 
]

{ #category : #jumps }
RISCCodeGenerator >> pushImm: imm [
	| memref |
	memref := self memRef base: self regSP; displacement: -8.
	self moveImm: imm to: self regV;
		store: self regV intoMem: memref;
		subImm: wordSize from: self regSP 
]

{ #category : #jumps }
RISCCodeGenerator >> subImm: anInteger from: srcAndDstReg [
	self addImm: anInteger negated to: srcAndDstReg

]
