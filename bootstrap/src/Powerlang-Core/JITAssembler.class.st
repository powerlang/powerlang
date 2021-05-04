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
JITAssembler >> add: source1 with: source2andDest [
	self subclassResponsibility

]

{ #category : #storing }
JITAssembler >> store: reg1 in: reg2 index: index [
	self subclassResponsibility
]
