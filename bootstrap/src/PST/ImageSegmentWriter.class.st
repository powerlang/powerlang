Class {
	#name : #ImageSegmentWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'objects',
		'offsets',
		'nextHash'
	],
	#classVars : [
		'WordSize'
	],
	#category : #'PST-Building'
}

{ #category : #'class initialization' }
ImageSegmentWriter class >> initialize [
	WordSize := 8
]

{ #category : #accessing }
ImageSegmentWriter >> encodedReferenceTo: anObject [
	anObject isImmediate
		ifTrue: [ ^ anObject value * 2 + 1 ].
	^ offsets at: anObject
]

{ #category : #accessing }
ImageSegmentWriter >> initialize [
	offsets := IdentityDictionary new.
	nextHash := 1
]

{ #category : #accessing }
ImageSegmentWriter >> layoutObjects [
	| offset |
	offset := stream position.
	objects
		do: [ :obj | 
			offset := offset + obj headerByteSize.
			offsets at: obj put: offset.
			offset := offset + obj slotByteSize ]
]

{ #category : #accessing }
ImageSegmentWriter >> nextHash [
	|  result |
	result := nextHash.
	nextHash := nextHash linearFeedbackShiftRandom: 16rB9C8.
	^result
]

{ #category : #initialization }
ImageSegmentWriter >> objects [
	^ objects
]

{ #category : #initialization }
ImageSegmentWriter >> objects: aCollection [
	objects := aCollection
]

{ #category : #accessing }
ImageSegmentWriter >> offsetOf: anObjectMap [
	^ offsets at: anObjectMap
]

{ #category : #accessing }
ImageSegmentWriter >> stream: aWriteStream [
	stream := aWriteStream
]

{ #category : #accessing }
ImageSegmentWriter >> write [
	self
		writeSignature;
		writeHeader;
		layoutObjects;
		writeObjects
]

{ #category : #accessing }
ImageSegmentWriter >> writeHeader [
	"TODO: write info about the contents"
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectBody: obj [
	obj isBytes ifTrue: [ self writeObjectBytes: obj ] ifFalse: [ self writeObjectSlots: obj ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectBytes: obj [
	| current aligned |
	stream nextBytesPutAll: obj contents.
	current := stream position.
	aligned := current alignedTo: WordSize.
	aligned - current timesRepeat: [ stream nextPut: 0 ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectHeader: obj [
	| behavior |
	obj isSmall
		ifFalse: [ stream
				uint32le: obj size;
				uint32le: 0 ].
	behavior := self encodedReferenceTo: obj behavior.
	stream
		uint16le: self nextHash;
		nextPut: obj smallSizeField;
		nextPut: obj flagsField;
		uint32le: behavior.
	stream position != (self offsetOf: obj) ifTrue: [ self halt ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectSlots: obj [
	| arrayed |
	obj slots do: [ :slot | self writeReferenceTo: slot ].
	arrayed := obj arrayed ifNil: [ ^self ].
	arrayed do: [ :slot | self writeReferenceTo: slot ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjects [
	objects
		do: [ :obj | 
			self
				writeObjectHeader: obj;
				writeObjectBody: obj ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeReferenceTo: slot [
	| encoded |
	encoded := self encodedReferenceTo: slot.
	WordSize = 8
		ifFalse: [ self assert: false].
	stream uint64le: encoded
]

{ #category : #accessing }
ImageSegmentWriter >> writeSignature [
	stream
		nextBytesPutAll: 'P_IM_S';
		nextPut: Character lf asInteger;
		nextPut: 0
]
