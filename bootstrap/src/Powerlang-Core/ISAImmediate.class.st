"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #ISAImmediate,
	#superclass : #ISAOperand,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #comparing }
ISAImmediate >> = operand [
	self class == operand class ifFalse: [^false].
	value = operand value ifFalse: [^false].
	^length = operand length
]

{ #category : #accessing }
ISAImmediate >> bytes [
	| bytes v |
	bytes := ByteArray new: length // 8.
	v := value.
	v < 0 ifTrue: [v := v + (1 bitShift: length)].
	1 to: bytes size do: [:i | 
		bytes at: i put: (v bitAnd: 16rFF).
		v := v bitShift: -8].
	^bytes
]

{ #category : #accessing }
ISAImmediate >> defaultLength [
	value < -168000000000000000 ifTrue: [^128].
	value < -16r80000000 ifTrue: [^64].
	value < -16r8000 ifTrue: [^32].
	value < -16r80 ifTrue: [^16].
	value < 16r80 ifTrue: [^8].
	value < 16r8000 ifTrue: [^16].
	value < 16r80000000 ifTrue: [^32].
	value < 16r8000000000000000 ifTrue: [^64].
	^128
]

{ #category : #comparing }
ISAImmediate >> hash [
	^value hashWith: length
]

{ #category : #initialization }
ISAImmediate >> isCompatibleWith: anOperandType [
	(value = 0 and: [anOperandType name = '0']) ifTrue: [^true].
	(value = 1 and: [anOperandType name = '1']) ifTrue: [^true].
	(value = 3 and: [anOperandType name = '3']) ifTrue: [^true].
	^anOperandType isImmediate
		and: [anOperandType hasImmediateFlag]
		and: [length <= anOperandType length]
]

{ #category : #testing }
ISAImmediate >> isImmediate [
	^true
]

{ #category : #testing }
ISAImmediate >> looksLikeAddress [
	^value > 65536 and: [value even]
]

{ #category : #accessing }
ISAImmediate >> memoryLength [
	^nil
]

{ #category : #initialization }
ISAImmediate >> prefers: anOperandType to: otherOperandType [
	anOperandType length < otherOperandType length ifTrue: [^true].
	(value = 0 and: [anOperandType name = '0']) ifTrue: [^true].
	(value = 1 and: [anOperandType name = '1']) ifTrue: [^true].
	(value = 3 and: [anOperandType name = '3']) ifTrue: [^true].
	^false
]

{ #category : #printing }
ISAImmediate >> printOn: aStream [
	| v |
	v := value isNil ifTrue: ['???'] ifFalse: [value hex].
	aStream nextPutAll: v
]

{ #category : #services }
ISAImmediate >> template [
	(0 <= value and: [value < 4]) ifTrue: [^self copy].
	^self class new value: length; length: length
]

{ #category : #accessing }
ISAImmediate >> value [
	^value
]

{ #category : #accessing }
ISAImmediate >> value: anInteger [
	value := anInteger.
	length := self defaultLength
]
