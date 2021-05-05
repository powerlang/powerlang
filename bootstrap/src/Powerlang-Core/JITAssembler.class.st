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

{ #category : #services }
JITAssembler >> move: srcReg to: dstReg [
	^ self subclassResponsibility

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

{ #category : #storing }
JITAssembler >> store: reg1 in: reg2 index: index [
	self subclassResponsibility
]
