Class {
	#name : #BaseCodeGenerator,
	#superclass : #CodeGenerator,
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #jumps }
BaseCodeGenerator >> clearHigh32: srcAndDstReg [
	self
		shiftLeft: srcAndDstReg byImm: 32;
		shiftRight: srcAndDstReg byImm: 32
]

{ #category : #jumps }
BaseCodeGenerator >> dec: srcAndDstReg [
	self addImm: -1 to: srcAndDstReg

]

{ #category : #jumps }
BaseCodeGenerator >> decMem: aMemRef [
	self addImm: -1 toMem: aMemRef

]

{ #category : #jumps }
BaseCodeGenerator >> inc: srcAndDstReg [
	self addImm: 1 to: srcAndDstReg

]

{ #category : #jumps }
BaseCodeGenerator >> pop: srcReg [
	| memref |
	memref := self memRef base: self regSP.
	self
		load: srcReg fromMem: memref;
		addImm: wordSize to: self regSP 
]

{ #category : #jumps }
BaseCodeGenerator >> push: srcReg [
	| memref |
	memref := self memRef base: self regSP; displacement: -8.
	self
		store: srcReg intoMem: memref;
		subImm: wordSize from: self regSP 
]

{ #category : #jumps }
BaseCodeGenerator >> pushImm: imm [
	| memref |
	memref := self memRef base: self regSP; displacement: -8.
	self moveImm: imm to: self regV;
		store: self regV intoMem: memref;
		subImm: wordSize from: self regSP 
]

{ #category : #jumps }
BaseCodeGenerator >> subImm: anInteger from: srcAndDstReg [
	self addImm: anInteger negated to: srcAndDstReg

]
