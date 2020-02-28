"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #REXPrefix,
	#superclass : #InstructionPrefix,
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
REXPrefix class >> b [
	^1
]

{ #category : #'instance creation' }
REXPrefix class >> fromStream: aStream [
	| s |
	s := aStream upTo: $+.
	^self fromString: s
]

{ #category : #'instance creation' }
REXPrefix class >> fromString: aString [
	(aString endsWith: 'REX.W') ifTrue: [^self w].
	(aString endsWith: 'REX.R') ifTrue: [^self r].
	(aString endsWith: 'REX') ifTrue: [^self rex].
	^nil
]

{ #category : #initialization }
REXPrefix class >> initialize [
	self initializePrefixes; compileAll.
	self class compileAll.
	InstructionSpec initializeSpecs.
	Smalltalk at: #Decoder64 ifPresent: [:d | d initializeSpecs]
]

{ #category : #initialization }
REXPrefix class >> initializePrefixes [
	#('REX' 'REX_W' 'REX_R') do: [:s | | rex |
		rex := self new name: s.
		Prefixes at: s put: rex].
	super initializePrefixes
]

{ #category : #'instance creation' }
REXPrefix class >> new [
	^super new initialize
]

{ #category : #services }
REXPrefix class >> peekFrom: aStream [
	^(aStream peek bitAnd: 16rF0) = 16r40 ifTrue: [aStream next]
]

{ #category : #printing }
REXPrefix class >> print: byte on: aStream [
	self ASSERT: (byte isOnBit: REX value).
	aStream nextPutAll: '0100'.
	(byte isOnBit: self w value) ifTrue: [aStream nextPut: $w].
	(byte isOnBit: self r) ifTrue: [aStream nextPut: $r].
	(byte isOnBit: self x) ifTrue: [aStream nextPut: $x].
	(byte isOnBit: self b) ifTrue: [aStream nextPut: $b]
]

{ #category : #accessing }
REXPrefix class >> r [
	^REX_R
]

{ #category : #accessing }
REXPrefix class >> rex [
	^REX
]

{ #category : #accessing }
REXPrefix class >> w [
	^REX_W
]

{ #category : #accessing }
REXPrefix class >> x [
	^2
]

{ #category : #testing }
REXPrefix >> isRex [
	^true
]

{ #category : #testing }
REXPrefix >> matches: anInteger [
	^anInteger isOnBit: self value
]

{ #category : #evaluating }
REXPrefix >> value [
	self == REX_W ifTrue: [^16r48].
	self == REX_R ifTrue: [^16r44].
	self == REX ifTrue: [^16r40].
	self ASSERT: false.
	^nil
]

{ #category : #writing }
REXPrefix >> writeOn: instruction [
	instruction writeRexPrefix: self value
]
