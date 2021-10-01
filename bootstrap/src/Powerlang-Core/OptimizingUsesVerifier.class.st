"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingUsesVerifier,
	#superclass : #Object,
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingUsesVerifier >> verify: definition usedBy: user [
	definition isInteger ifTrue: [^self].
	definition usesDo: [:use | use instruction == user ifTrue: [^self]].
	self error: 'Corrupted instruction usage'
]

{ #category : #unclassified }
OptimizingUsesVerifier >> verifyFrom: firstBlock [
	firstBlock
		instructionsWithSuccessorsDo: [:instruction | instruction
			acceptVisitor: self]
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitBinaryWithConstant: instruction [
	self verify: instruction left usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitBinaryWithVariable: instruction [
	self
		verify: instruction left usedBy: instruction;
		verify: instruction right usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitJump: instruction [
	
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitJumpFalse: instruction [
	self verify: instruction variable usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitJumpTrue: instruction [
	self verify: instruction variable usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitLoadConstant: instruction [
	
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitLoadImplicit: instruction [
	
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitMessageSend: instruction [
	self verify: instruction receiver usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitNullary: instruction [
	
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitPhi: instruction [
	instruction variables
		do: [:operation | self verify: operation usedBy: instruction]
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitReturn: instruction [
	self verify: instruction source usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitTernary: instruction [
	self
		verify: instruction receiver usedBy: instruction;
		verify: instruction left usedBy: instruction;
		verify: instruction right usedBy: instruction
]

{ #category : #unclassified }
OptimizingUsesVerifier >> visitUnary: instruction [
	self verify: instruction receiver usedBy: instruction
]
