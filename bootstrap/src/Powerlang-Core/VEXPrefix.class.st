"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #VEXPrefix,
	#superclass : #InstructionPrefix,
	#instVars : [
		'signature'
	],
	#classVars : [
		'Signatures'
	],
	#pools : [
		'CharacterConstants'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #accessing }
VEXPrefix class >> b [
	^16r20
]

{ #category : #'instance creation' }
VEXPrefix class >> fromStream: aStream [
	^self withSignature: (aStream upTo: Space)
]

{ #category : #initialization }
VEXPrefix class >> initialize [
	self initializeSignatures.
	InstructionSpec initializeSpecs
]

{ #category : #initialization }
VEXPrefix class >> initializeSignatures [
	Signatures isNil ifTrue: [Signatures := Dictionary new].
	'VEX.128.0F.WIG
	VEX.128.66.0F.W0
	VEX.128.66.0F.W1
	VEX.128.66.0F.WIG
	VEX.128.66.0F38.W0
	VEX.128.66.0F38.WIG
	VEX.128.66.0F3A.W0
	VEX.128.66.0F3A.W1
	VEX.128.66.0F3A.WIG
	VEX.128.F2.0F.WIG
	VEX.128.F3.0F.WIG
	VEX.256.0F.WIG
	VEX.256.66.0F.WIG
	VEX.256.66.0F38.W0
	VEX.256.66.0F38.WIG
	VEX.256.66.0F3A.W0
	VEX.256.66.0F3A.W1
	VEX.256.66.0F3A.WIG
	VEX.256.F2.0F.WIG
	VEX.256.F3.0F.WIG
	VEX.DDS.128.66.0F38.W0
	VEX.DDS.128.66.0F38.W1
	VEX.DDS.256.66.0F38.0
	VEX.DDS.256.66.0F38.W0
	VEX.DDS.256.66.0F38.W1
	VEX.DDS.LIG.128.66.0F38.W0
	VEX.DDS.LIG.128.66.0F38.W1
	VEX.LIG.0F.WIG
	VEX.LIG.66.0F.WIG
	VEX.LIG.F2.0F.W0
	VEX.LIG.F2.0F.W1
	VEX.LIG.F2.0F.WIG
	VEX.LIG.F3.0F.W0
	VEX.LIG.F3.0F.W1
	VEX.LIG.F3.0F.WIG
	VEX.LZ.0F.WIG
	VEX.LZ.F2.0F3A.W0
	VEX.LZ.F2.0F3A.W1
	VEX.NDD.128.66.0F.WIG
	VEX.NDD.256.66.0F.WIG
	VEX.NDD.LZ.0F38.W0
	VEX.NDD.LZ.0F38.W1
	VEX.NDD.LZ.F2.0F38.W0
	VEX.NDD.LZ.F2.0F38.W1
	VEX.NDS.128.0F.WIG
	VEX.NDS.128.66.0F.W0
	VEX.NDS.128.66.0F.WIG
	VEX.NDS.128.66.0F38.W0
	VEX.NDS.128.66.0F38.W1
	VEX.NDS.128.66.0F38.WIG
	VEX.NDS.128.66.0F3A.W0
	VEX.NDS.128.66.0F3A.W1
	VEX.NDS.128.66.0F3A.WIG
	VEX.NDS.128.F2.0F.WIG
	VEX.NDS.256.0F.WIG
	VEX.NDS.256.66.0F.WIG
	VEX.NDS.256.66.0F38.W0
	VEX.NDS.256.66.0F38.W1
	VEX.NDS.256.66.0F38.WIG
	VEX.NDS.256.66.0F3A.W0
	VEX.NDS.256.66.0F3A.WIG
	VEX.NDS.256.F2.0F.WIG
	VEX.NDS.LIG.66.0F3A.WIG
	VEX.NDS.LIG.F2.0F.W0
	VEX.NDS.LIG.F2.0F.W1
	VEX.NDS.LIG.F2.0F.WIG
	VEX.NDS.LIG.F3.0F.W0
	VEX.NDS.LIG.F3.0F.W1
	VEX.NDS.LIG.F3.0F.WIG
	VEX.NDS.LZ.0F38.W0
	VEX.NDS.LZ.0F38.W1
	VEX.NDS.LZ.66.0F38.W0
	VEX.NDS.LZ.66.0F38.W1
	VEX.NDS.LZ.F2.0F38.W0
	VEX.NDS.LZ.F2.0F38.W1
	VEX.NDS.LZ.F3.0F38.W0
	VEX.NDS.LZ.F3.0F38.W1
	VEX128.66.0F.WIG' lines do: [:s | | vex |
		vex := self new signature: ($. split: s).
		Signatures at: s put: vex]
]

{ #category : #accessing }
VEXPrefix class >> l [
	^2r100
]

{ #category : #private }
VEXPrefix class >> operandSizeOverrideBits [
	^1
]

{ #category : #services }
VEXPrefix class >> peekFrom: aStream [
	aStream peek = 16rC4 ifTrue: [^aStream next: 3].
	aStream peek = 16rC5 ifTrue: [^aStream next: 2].
	^nil
]

{ #category : #printing }
VEXPrefix class >> print: byte on: stream [
	stream nextPutAll: byte hex
]

{ #category : #accessing }
VEXPrefix class >> r [
	^16r80
]

{ #category : #accessing }
VEXPrefix class >> w [
	^16r80
]

{ #category : #'instance creation' }
VEXPrefix class >> withSignature: aString [
	^Signatures at: aString
]

{ #category : #accessing }
VEXPrefix class >> x [
	^16r40
]

{ #category : #input }
VEXPrefix >> fromStream: aStream [
	| stream |
	stream := (aStream upTo: Space) readStream.
	signature := Array streamContents: [:strm | 
		[stream atEnd] whileFalse: [| part |
			part := stream upTo: $..
			strm nextPut: part]]
]

{ #category : #initialization }
VEXPrefix >> initialize [
	super initialize.
	name = 'VEX'
]

{ #category : #testing }
VEXPrefix >> isVex [
	^true
]

{ #category : #accessing }
VEXPrefix >> length [
	signature first = 16rC5 ifTrue: [^16].
	^24
]

{ #category : #testing }
VEXPrefix >> matches: aByteArray [
	| size last mmmmm |
	(self mayMatchSize: aByteArray) ifFalse: [^false].
	size := aByteArray size.
	last := aByteArray at: size.
	(signature includes: 'LIG')
		ifFalse: [(signature includes: '256') = (last isOnBit: self class l)
			ifFalse: [^false]].
	(signature includes: '66') = (last isOnBit: 2r1) ifFalse: [^false].
	(signature includes: 'F2') = (last isOnBit: 2r10) ifFalse: [^false].
	(signature includes: 'F3') = (last isOnBit: 2r11) ifFalse: [^false].
	(signature includes: 'WIG')
		ifFalse: [(signature includes: 'W1') = (last isOnBit: self class w)
			ifFalse: [^false]].
	size = 3 ifTrue: [
		mmmmm := (aByteArray at: 2) bitAnd: 2r11111.
		(signature includes: '0F') = (mmmmm = 1) ifFalse: [^false].
		(signature includes: '0F38') = (mmmmm = 2r10) ifFalse: [^false].
		(signature includes: '0F3A') = (mmmmm = 2r11) ifFalse: [^false]].
	^true
]

{ #category : #testing }
VEXPrefix >> mayMatchSize: aByteArray [
	| n |
	n := aByteArray first = 16rC4 ifTrue: [3] ifFalse: [2].
	((signature includes: 'WIG') or: [signature includes: 'W0']) ifFalse: [^n
		= 3].
	(signature includes: 'W1') ifTrue: [^n = 3].
	(signature includes: '0F3A') ifTrue: [^n = 3].
	(signature includes: '0F38') ifTrue: [^n = 3].
	^true
]

{ #category : #private }
VEXPrefix >> operandSize [
	(signature includes: '128') ifTrue: [^128].
	(signature includes: '256') ifTrue: [^256].
	^nil
]

{ #category : #testing }
VEXPrefix >> overridesOperandSize [
	^signature includes: '66'
]

{ #category : #printing }
VEXPrefix >> printOn: aStream [
	signature isNil ifTrue: [^super printOn: aStream].
	signature
		do: [:s | aStream nextPutAll: s]
		separatedBy: [aStream nextPut: $.]
]

{ #category : #accessing }
VEXPrefix >> signature [
	^signature
]

{ #category : #accessing }
VEXPrefix >> signature: anArray [
	signature := anArray
]

{ #category : #isEvaluating }
VEXPrefix >> sizeFor: instruction [
	| encoding |
	((signature includes: 'WIG') or: [signature includes: 'W0']) ifFalse: [^3].
	(signature includes: 'W1') ifTrue: [^3].
	(signature includes: '0F3A') ifTrue: [^3].
	(signature includes: '0F38') ifTrue: [^3].
	instruction hasSib ifTrue: [^3].
	encoding := instruction spec operandEncoding.
	instruction operands withIndexDo: [:op :i | 
		op isMemory
			ifTrue: [(op baseExtension = 0 or: [op indexExtension = 0]) ifTrue: [^3]]
			ifFalse: [
				(op isRegister and: [op index > 7] andNot: [encoding isVvvvOperand: i])
					ifTrue: [^3]]].
	^2
]

{ #category : #isEvaluating }
VEXPrefix >> valueFor: instruction [
	| size bytes last |
	size := self sizeFor: instruction.
	bytes := ByteArray new: size.
	size = 2 ifTrue: [bytes at: 1 put: 16rC5] ifFalse: [bytes at: 1 put: 16rC4].
	last := 0.
	(signature includes: '256')
		ifTrue: [bytes at: size put: (bytes last bitOr: self class l)].
	(signature includes: '66')
		ifTrue: [last := bytes at: size put: (last bitOr: 2r1)].
	(signature includes: 'F2')
		ifTrue: [last := bytes at: size put: (last bitOr: 2r10)].
	(signature includes: 'F3')
		ifTrue: [last := bytes at: size put: (last bitOr: 2r11)].
	(signature includes: 'W1')
		ifTrue: [last := bytes at: size put: (last bitOr: self class w)].
	(size = 3 and: [signature includes: '0F']) ifTrue: [bytes at: 2 put: 1].
	(signature includes: '0F38') ifTrue: [bytes at: 2 put: 2r10].
	(signature includes: '0F3A') ifTrue: [bytes at: 2 put: 2r11].
	^bytes
]

{ #category : #writing }
VEXPrefix >> writeOn: instruction [
	| value |
	value := self valueFor: instruction.
	instruction writeVexPrefix: value
]
