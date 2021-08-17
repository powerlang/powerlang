"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAOperand,
	#superclass : #Object,
	#instVars : [
		'length'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #'instance creation' }
ISAOperand class >> new [
	^super new initialize
]

{ #category : #accessing }
ISAOperand >> , anISAOperand [
	^{self. anISAOperand}
]

{ #category : #accessing }
ISAOperand >> baseExtension [
	^0
]

{ #category : #accessing }
ISAOperand >> indexExtension [
	^0
]

{ #category : #testing }
ISAOperand >> isDirectMemoryReference [
	^false
]

{ #category : #testing }
ISAOperand >> isImmediate [
	^false
]

{ #category : #testing }
ISAOperand >> isMemory [
	^false
]

{ #category : #testing }
ISAOperand >> isRegister [
	^false
]

{ #category : #testing }
ISAOperand >> isTemplate [
	^false
]

{ #category : #accessing }
ISAOperand >> length [
	^length
]

{ #category : #accessing }
ISAOperand >> length: anInteger [
	length := anInteger
]

{ #category : #accessing }
ISAOperand >> memoryLength [
	^length
]

{ #category : #testing }
ISAOperand >> needsExtraBit [
	^false
]

{ #category : #accessing }
ISAOperand >> offsetOfIndex: index [
	length = 64 ifTrue: [^index - 1 bitShift: 3].
	length = 32 ifTrue: [^index - 1 bitShift: 2].
	length = 8 ifTrue: [^index - 1].
	self error: 'invalid operand'
]

{ #category : #accessing }
ISAOperand >> operand1 [
	^self
]

{ #category : #accessing }
ISAOperand >> operand2 [
	^self
]

{ #category : #testing }
ISAOperand >> prefers: anOperandType to: anotherOperandType [
	^false
]

{ #category : #accessing }
ISAOperand >> regExtension [
	^0
]

{ #category : #accessing }
ISAOperand >> sizeInBits [
	^self length

]

{ #category : #accessing }
ISAOperand >> sizeInBytes [
	^length // 8
]

{ #category : #services }
ISAOperand >> template [
	^self
]
