Class {
	#name : #JITAssembler,
	#superclass : #Object,
	#instVars : [
		'wordSize',
		'backend'
	],
	#category : #'Powerlang-Core-Assembler'
}

{ #category : #storing }
JITAssembler >> add: source1 to: source2andDest [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> addImm: imm to: dest [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> and: source1andDest with: source2 [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> and: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> andIndirect: source1andDest withImm: imm [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> lea: dest base: base index: index scale: scale [
	self subclassResponsibility
]

{ #category : #storing }
JITAssembler >> store: reg1 in: reg2 index: index [
	self subclassResponsibility
]
