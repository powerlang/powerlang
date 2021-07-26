Class {
	#name : #RISCAssemblerBackend,
	#superclass : #AssemblerBackend,
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #jumps }
RISCAssemblerBackend >> dec: srcAndDstReg [
	self addImm: -1 to: srcAndDstReg

]

{ #category : #jumps }
RISCAssemblerBackend >> inc: srcAndDstReg [
	self addImm: 1 to: srcAndDstReg

]

{ #category : #jumps }
RISCAssemblerBackend >> pop: srcReg [
	| memref |
	memref := self memRef base: self regSP.
	self
		load: srcReg fromMem: memref;
		addImm: wordSize to: self regSP 
]

{ #category : #jumps }
RISCAssemblerBackend >> push: srcReg [
	| memref |
	memref := self memRef base: self regSP; displacement: -8.
	self
		store: srcReg intoMem: memref;
		subImm: wordSize from: self regSP 
]

{ #category : #jumps }
RISCAssemblerBackend >> subImm: anInteger from: srcAndDstReg [
	self addImm: anInteger negated to: srcAndDstReg

]
