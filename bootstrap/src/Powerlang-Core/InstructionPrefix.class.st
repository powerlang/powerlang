"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #InstructionPrefix,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#pools : [
		'Prefixes'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #private }
InstructionPrefix class >> classFor: aString [
	(aString beginsWith: 'REX') ifTrue: [^REXPrefix].
	(aString beginsWith: 'VEX') ifTrue: [^VEXPrefix].
	^LegacyPrefix
]

{ #category : #'instance creation' }
InstructionPrefix class >> fromString: aString [
	| reader prefixes rex |
	reader := aString readStream.
	prefixes := Prefixes
		select: [:p | reader peekForAll: p value hex]
		in: OrderedCollection new.
	(reader peek: 'REX' size) = 'REX' ifTrue: [
		rex := REXPrefix fromStream: reader.
		prefixes add: rex].
	(reader peek: 'VEX' size) = 'VEX' ifTrue: [
		rex := VEXPrefix fromStream: reader.
		prefixes add: rex].
	^prefixes
]

{ #category : #initialization }
InstructionPrefix class >> initializePrefixes [
	self == InstructionPrefix
		ifTrue: [ self allSubclasses do: #initializePrefixes ].
	self compileAll.
	self class compileAll
]

{ #category : #services }
InstructionPrefix class >> peekFrom: aStream [
	(aStream peekFor: LOCK value) ifTrue: [^LOCK].
	(aStream peekFor: REPNE value) ifTrue: [^REPNE].
	(aStream peekFor: REP value) ifTrue: [^REP].
	(aStream peekFor: OperandSize_Override value)
		ifTrue: [^OperandSize_Override].
	(aStream peekFor: AddressSize_Override value)
		ifTrue: [^AddressSize_Override].
	^nil
]

{ #category : #services }
InstructionPrefix class >> prefixes [
	^Prefixes
]

{ #category : #testing }
InstructionPrefix >> isLegacy [
	^false
]

{ #category : #testing }
InstructionPrefix >> isRex [
	^false
]

{ #category : #testing }
InstructionPrefix >> isSegment [
	^false
]

{ #category : #testing }
InstructionPrefix >> isVex [
	^false
]

{ #category : #accessing }
InstructionPrefix >> name [
	^name
]

{ #category : #accessing }
InstructionPrefix >> name: aString [
	name := aString
]

{ #category : #printing }
InstructionPrefix >> printOn: aStream [
	(name includes: Character space)
		ifTrue: [
			aStream
				nextPut: ${;
				nextPutAll: name;
				nextPut: $}]
		ifFalse: [aStream nextPutAll: name]
]

{ #category : #writing }
InstructionPrefix >> writeOn: anInstruction [
	self subclassResponsibility
]
