"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #RelocatableBuffer,
	#superclass : #Object,
	#instVars : [
		'stream',
		'address',
		'fixups'
	],
	#category : #'Powerlang-Core-Assembler-JIT'
}

{ #category : #'instance creation' }
RelocatableBuffer class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #fixups }
RelocatableBuffer >> addAbsoluteFixup: label [
	| fixup |
	fixup := RelocationFixup absoluteFrom: self currentAddress to: label.
	fixups add: fixup
]

{ #category : #fixups }
RelocatableBuffer >> addRelativeFixup: label size: n [
	| fixup |
	fixup := RelocationFixup relativeFrom: self currentAddress to: label.
	fixup size: n.
	fixups add: fixup
]

{ #category : #fixups }
RelocatableBuffer >> applyFixupsWith: solver [
	fixups do: [:fixup | fixup patch: self with: solver]
]

{ #category : #accessing }
RelocatableBuffer >> baseAddress [
	^address
]

{ #category : #accessing }
RelocatableBuffer >> bytes [
	^stream contents
]

{ #category : #accessing }
RelocatableBuffer >> codeSize [
	^stream size
]

{ #category : #accessing }
RelocatableBuffer >> currentAddress [
	^address + stream position
]

{ #category : #initialization }
RelocatableBuffer >> initialize [
	super initialize.
	fixups := OrderedCollection new.
	address := 0.
	stream := #[] writeStream
]

{ #category : #writing }
RelocatableBuffer >> nextBytePut: byte [
	| value |
	value := byte < 0 ifTrue: [ byte + 256 ] ifFalse: byte.
	stream nextBytePut: value
]

{ #category : #writing }
RelocatableBuffer >> nextBytesPut: aByteArray [
	stream nextBytesPut: aByteArray
]

{ #category : #writing }
RelocatableBuffer >> nextPut: byte [
	stream nextPut: byte
]

{ #category : #writing }
RelocatableBuffer >> nextPutAll: aByteArray [
	stream nextPutAll: aByteArray
]

{ #category : #writing }
RelocatableBuffer >> nextULargePut: long [
	stream nextULargePut: long
]

{ #category : #writing }
RelocatableBuffer >> nextULongPut: long [
	stream nextULongPut: long
]

{ #category : #accessing }
RelocatableBuffer >> peek [
	^stream peek
]

{ #category : #accessing }
RelocatableBuffer >> peek: n [
	^stream peek: n
]

{ #category : #accessing }
RelocatableBuffer >> position [
	^stream position
]

{ #category : #accessing }
RelocatableBuffer >> position: anInteger [
	stream position: anInteger
]

{ #category : #relocation }
RelocatableBuffer >> relocateTo: location with: solver [
	| delta |
	delta := location - address.
	address := location.
	fixups do: [:fixup | fixup relocateBy: delta].
	self applyFixupsWith: solver
]

{ #category : #initialization }
RelocatableBuffer >> reset [
	fixups := OrderedCollection new.
	stream reset
]

{ #category : #accessing }
RelocatableBuffer >> size [
	^stream size
]

{ #category : #accessing }
RelocatableBuffer >> skip: anInteger [
	stream skip: anInteger
]

{ #category : #writing }
RelocatableBuffer >> stream [
	^stream
]

{ #category : #private }
RelocatableBuffer >> stream: aStream [
	stream := aStream
]

{ #category : #writing }
RelocatableBuffer >> writeByte: byte at: location [
	| previous value |
	previous := stream position.
	value := byte < 0 ifTrue: [ byte + 256 ] ifFalse: [ byte ].
	stream
		position: location - address;
		nextBytePut: value;
		position: previous
]

{ #category : #writing }
RelocatableBuffer >> writeLong: long at: location [
	| previous |
	previous := stream position.
	stream
		position: location - address;
		nextLongPut: long;
		position: previous
]
