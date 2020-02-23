"
I represent the format of objects in the DMR. Ask me questions about
the header of an object.
"
Class {
	#name : #DmrObjectFormat,
	#superclass : #ObjectFormat,
	#pools : [
		'ObjectHeaderMasks',
		'ObjectHeaderOffsets'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #services }
DmrObjectFormat >> behaviorOf: oid [
	^ storage uint32of: oid atOffset: BehaviorOffset
]

{ #category : #sizes }
DmrObjectFormat >> bytesOf: oid count: size [
	^ storage bytesAt: oid sized: size
]

{ #category : #services }
DmrObjectFormat >> classOf: anObjectHandle [
	| oid class behavior handle |
	oid := anObjectHandle oid.
	oid odd ifTrue: [ class := storage classNamed: 'SmallInteger'.
			^ (anObjectHandle runtime handleOn: class) mirror asClassMirror ].
	behavior := self behaviorOf: oid.
	handle := anObjectHandle runtime handleOn: behavior.
	^ handle mirror asBehaviorMirror instanceClass
]

{ #category : #services }
DmrObjectFormat >> flagsOf: anObject [
	^ storage uint8of: anObject atOffset: FlagsOffset
]

{ #category : #services }
DmrObjectFormat >> integerOf: oid [
	| shifted complement |
	self ASSERT: oid odd.
	shifted := oid bitShift: -1. 
	complement := 1 bitShift: storage wordSize * 8 - 1.
	^ oid >= complement
		ifTrue: [ shifted - complement ]
		ifFalse: [ shifted ]
]

{ #category : #services }
DmrObjectFormat >> isArrayed: anObject [
	^ (self flagsOf: anObject) anyMask: IsArrayed
]

{ #category : #services }
DmrObjectFormat >> isBytes: anObject [
	^ ((self flagsOf: anObject) anyMask: IsBytes)
]

{ #category : #services }
DmrObjectFormat >> isInteger: oid [
	^oid odd
]

{ #category : #services }
DmrObjectFormat >> isLarge: anObject [
	^(self isSmall: anObject) not
]

{ #category : #services }
DmrObjectFormat >> isNamed: anObject [
	^ (self flagsOf: anObject) anyMask: IsNamed
]

{ #category : #services }
DmrObjectFormat >> isSmall: oid [
	^ (self flagsOf: oid) anyMask: IsSmall
]

{ #category : #sizes }
DmrObjectFormat >> labelFor: oid [
	^oid hex
]

{ #category : #sizes }
DmrObjectFormat >> largeSizeOf: oid [
	^ storage uint32of: oid atOffset: LargeSizeOffset
]

{ #category : #sizes }
DmrObjectFormat >> print: oid on: aStream [
	| size |
	aStream
		nextPut: $@;
		nextPutAll: oid hex;
		nextPutAll: '[flags: 0x';
		nextPutAll: (self flagsOf: oid) printStringHex.
	self printFlagsOf: oid on: aStream.
	size := self sizeOf: oid.
	aStream
		nextPutAll: ', size: 0x';
		nextPutAll: size printStringHex;
		nextPut: $].


]

{ #category : #sizes }
DmrObjectFormat >> printFlagsOf: oid on: aStream [
	| char |
	aStream nextPut: $(.
	char := (self isSmall: oid)
		ifTrue: [ $S ]
		ifFalse: [ $L ].
	aStream
		nextPut: char;
		space.
	char := (self isBytes: oid)
		ifTrue: [ $B ]
		ifFalse: [ $P ].
	aStream
		nextPut: char;
		space.
	char := (self isArrayed: oid)
		ifTrue: [ $A ]
		ifFalse: [ $F ].
	aStream
		nextPut: char;
		nextPut: $)
]

{ #category : #sizes }
DmrObjectFormat >> sizeOf: oid [
	^ (self isSmall: oid)
		ifTrue: [ self smallSizeOf: oid ]
		ifFalse: [ self largeSizeOf: oid ]
]

{ #category : #services }
DmrObjectFormat >> slotOf: base at: index [
	^ storage uint64atOffset: base + (8 * (index - 1))
]

{ #category : #sizes }
DmrObjectFormat >> smallSizeOf: oid [
	^ storage uint8of: oid atOffset: SizeOffset
]

{ #category : #sizes }
DmrObjectFormat >> stringOf: oid count: anInteger [
	^storage stringAt: oid sized: anInteger
]
