Class {
	#name : #ImageSegmentWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'objects',
		'offsets',
		'nextHash',
		'size',
		'baseAddress',
		'toc'
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
ImageSegmentWriter >> baseAddress [
	"Return preferred base address for this segment."
	^ baseAddress
]

{ #category : #accessing }
ImageSegmentWriter >> baseAddress: anInteger [
	"Set the preferred base address for this segment. 
	 This is a hint only, loaders may load segment at
	 different address but then loader must relocate.
	"
	baseAddress := anInteger
]

{ #category : #accessing }
ImageSegmentWriter >> contents [
	^stream contents
]

{ #category : #accessing }
ImageSegmentWriter >> encodedReferenceTo: anObject [
	anObject isImmediate
		ifTrue: [ ^ anObject value * 2 + 1 ].
	^ baseAddress + (offsets at: anObject)
]

{ #category : #accessing }
ImageSegmentWriter >> image [
	^stream contents
]

{ #category : #accessing }
ImageSegmentWriter >> initialize [
	offsets := IdentityDictionary new.
	nextHash := 1.
  baseAddress := 0.
	toc := nil.
]

{ #category : #accessing }
ImageSegmentWriter >> layoutObjects [	
	size := 32"Size of segment header".
	objects
		do: [ :obj | 
			size := size + obj headerSizeInBytes.
			offsets at: obj put: size.
			size := size + obj bodySizeInBytes.
			size := size alignedTo: WordSize ].
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
ImageSegmentWriter >> toc [
	^ toc
]

{ #category : #accessing }
ImageSegmentWriter >> toc: anObject [
	toc := anObject 
]

{ #category : #accessing }
ImageSegmentWriter >> write [
	self
		layoutObjects;
		writeSignature;
		writeHeader;		
		writeObjects.
		
		
]

{ #category : #accessing }
ImageSegmentWriter >> writeHeader [
	"See segment.h for structure of a segment header"
	stream uint64le: baseAddress. "Assumed Base Address"
	stream uint64le: size. "Size of an segment"	
	self writeReferenceTo: toc. "segment (module) TOC"	
	self assert: stream position == 32
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectBody: obj [
	obj isBytes ifTrue: [ self writeObjectBytes: obj ] ifFalse: [ self writeObjectSlots: obj ]
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
		nextPut: obj smallHeaderSize;
		nextPut: obj smallHeaderFlags;
		uint32le: (behavior bitAnd:16rFFFFFFFF).
	self assert: stream position == (self offsetOf: obj)
]

{ #category : #accessing }
ImageSegmentWriter >> writeObjectSlots: obj [
	obj slots do: [ :slot | self writeReferenceTo: slot ].

]

{ #category : #accessing }
ImageSegmentWriter >> writeObjects [
	objects
		withIndexDo: [ :obj :idx | 
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
