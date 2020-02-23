Class {
	#name : #ImageSegmentWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'objects',
		'nextHash',
		'oops'
	],
	#classVars : [
		'WordSize'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #'class initialization' }
ImageSegmentWriter class >> initialize [
	WordSize := 8
]

{ #category : #accessing }
ImageSegmentWriter >> encodedReferenceTo: anObject [
	anObject isImmediate
		ifTrue: [ ^ anObject value * 2 + 1 ].
	^ oops at: anObject
]

{ #category : #accessing }
ImageSegmentWriter >> image [
	^stream contents
]

{ #category : #accessing }
ImageSegmentWriter >> initialize [
	oops := IdentityDictionary new.
	nextHash := 1
]

{ #category : #accessing }
ImageSegmentWriter >> layoutObjects [
	| offset oop |
	offset := stream position.
	objects
		do: [ :obj | 
			oop := offset + obj headerSizeInBytes.
			oops at: obj put: oop.
			offset := oop + obj bodySizeInBytes ]
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
	^ oops at: anObjectMap
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
	obj isBytes
		ifTrue: [ self writeObjectBytes: obj ]
		ifFalse: [ self writeObjectSlots: obj ]
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectBytes: obj [
	| current aligned |
	stream nextBytesPutAll: obj bytes.
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
		nextPut: obj headerSmallSize;
		nextPut: obj headerFlags;
		uint32le: behavior.
	self assert: stream position == (self offsetOf: obj)
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectSlots: obj [
	obj slots do: [ :slot | self writeReferenceTo: slot ].

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
