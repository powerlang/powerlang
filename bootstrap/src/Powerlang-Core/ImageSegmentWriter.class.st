Class {
	#name : #ImageSegmentWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'objects',
		'nextHash',
		'offsets',
		'size',
		'base',
		'module'
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
ImageSegmentWriter class >> nilOffset [
	^self objectsOffset + 8
]

{ #category : #accessing }
ImageSegmentWriter class >> objectsOffset [
	"
		The offset at which header terminates and objects are stored.
		See ImageSegment.h for structure of a segment header
	"
	^32
]

{ #category : #accessing }
ImageSegmentWriter >> base [
	"
		Return preferred base address for this segment
	"
	^ base
]

{ #category : #accessing }
ImageSegmentWriter >> base: anInteger [
	"
	 Set the preferred base address for this segment. 
	 This is a hint only, loaders may load a segment
	 at a different address but then they must relocate.
	"
	base := anInteger
]

{ #category : #accessing }
ImageSegmentWriter >> encodedReferenceTo: anObject [
	| offset |
	anObject isImmediate
		ifTrue: [ ^ anObject value * 2 + 1 ].
	offset := offsets at: anObject.
	^base + offset
]

{ #category : #accessing }
ImageSegmentWriter >> image [
	^stream contents
]

{ #category : #accessing }
ImageSegmentWriter >> initialize [
	offsets := IdentityDictionary new.
	stream := #[] writeStream.
	nextHash := 1.
	base := 0.
]

{ #category : #accessing }
ImageSegmentWriter >> layoutObjects [
	| offset oop |
	offset := self objectsOffset.
	objects
		do: [ :obj | 
			oop := offset + obj headerSizeInBytes.
			offsets at: obj put: oop.
			offset := oop + obj bodySizeInBytes ].
	size := offset.
]

{ #category : #initialization }
ImageSegmentWriter >> module: aSlotObjectMap [
	module := aSlotObjectMap
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
ImageSegmentWriter >> objectsOffset [
	^self class objectsOffset
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
		layoutObjects;
		writeSignature;
		writeHeader;
		writeObjects
]

{ #category : #accessing }
ImageSegmentWriter >> writeHeader [
	"See ImageSegment.h for structure of a segment header"
	stream uint64le: base; uint64le: size.
	self writeReferenceTo: module
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
	self assert: stream position == self objectsOffset.
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
