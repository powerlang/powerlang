Class {
	#name : #ImageSegmentWriter,
	#superclass : #Object,
	#instVars : [
		'stream',
		'objects',
		'space',
		'nextHash',
		'offsets',
		'size',
		'base',
		'module',
		'wordSize',
		'roots',
		'index'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
ImageSegmentWriter class >> behaviorOffset [
	"
		The offset at which the behavior is from the oop (negated)
	"

	^ -4
]

{ #category : #'instance creation' }
ImageSegmentWriter class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

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
	^40
]

{ #category : #initialization }
ImageSegmentWriter >> addClosure [
	| remaining obj b |
	remaining := OrderedCollection withAll: roots.
	remaining do: [ :s | offsets at: s put: nil ].
	[ remaining isEmpty ]
		whileFalse: [ obj := remaining removeFirst.
			objects add: obj.
			b := obj behavior.
			(offsets includesKey: b)
				ifFalse: [ offsets at: b put: nil. remaining add: b ].
			obj
				slotsDo: [ :s | 
					(s isImmediate or: [ offsets includesKey: s ])
						ifFalse: [ offsets at: s put: nil.
							remaining add: s ] ] ]
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
ImageSegmentWriter >> configureSpace [
	| basemap free limit |
	basemap := SmallintObjectMap new value: base // 2.
	free := SmallintObjectMap new value: (base + size) // 2.
	limit := SmallintObjectMap new value: (base + size + 16r20000 // 2).
	space
		base: basemap;
		nextFree: free;
		softLimit: limit;
		commitedLimit: limit;
		reservedLimit: limit
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
	objects := OrderedCollection new.
	stream := ByteArray new writeStream.
	nextHash := 1.
	base := 0

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
	size := offset
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

{ #category : #accessing }
ImageSegmentWriter >> objectsOffset [
	^self class objectsOffset
]

{ #category : #accessing }
ImageSegmentWriter >> offsetOf: anObjectMap [
	^ offsets at: anObjectMap
]

{ #category : #initialization }
ImageSegmentWriter >> roots: aCollection [
	roots := aCollection
]

{ #category : #initialization }
ImageSegmentWriter >> space: aGCSpace [
	space := aGCSpace
]

{ #category : #accessing }
ImageSegmentWriter >> stream: aWriteStream [
	stream := aWriteStream
]

{ #category : #accessing }
ImageSegmentWriter >> wordSize: anInteger [
	wordSize := anInteger
]

{ #category : #accessing }
ImageSegmentWriter >> write [
	self
		addClosure;
		layoutObjects;
		configureSpace;
		writeSignature;
		writeHeader;
		writeObjects
]

{ #category : #'own services' }
ImageSegmentWriter >> writeHeader [
	"See ImageSegment.h for structure of a segment header"
	| reserved |
	reserved := (space reservedLimit value - space base value) * 2.
	stream uint64le: base; uint64le: size; uint64le: reserved.
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
	stream nextPutAll: obj bytes.
	current := stream position.
	aligned := current alignedTo: wordSize.
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
		uint16le: obj headerHash;
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
	wordSize = 8
		ifFalse: [ self assert: false ].
	stream uint64le: encoded
]

{ #category : #accessing }
ImageSegmentWriter >> writeSignature [
	stream
		nextPutAll: 'P_IM_S' asByteArray;
		nextPut: Character lf asInteger;
		nextPut: 0

]

{ #category : #writing }
ImageSegmentWriter >> writeTo: aStream [
	self stream: aStream.
	self write.

]

{ #category : #writing }
ImageSegmentWriter >> writeToFile: filename [
	filename asFileReference binaryWriteStreamDo: [ :fileStream |
		| bytes |
		
		"Bit stupid - we write into internal ByteArray backed stream and
	  then write it to real file. That's because WriteStream and ZnWriteStream
	  are not polymorphic. Sigh"
		bytes := ByteArray streamContents:[:byteStream | self writeTo: byteStream ].
		fileStream nextPutAll: bytes.
	]

]
