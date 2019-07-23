Class {
	#name : #ObjectHandle,
	#superclass : #Handle,
	#instVars : [
		'oid'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'as yet unclassified' }
ObjectHandle class >> on: oid within: runtime [
	^self new oid: oid; runtime: runtime
]

{ #category : #comparing }
ObjectHandle >> = anObject [
	^anObject class = ObjectHandle and: [oid = anObject oid]
]

{ #category : #'meta accessing' }
ObjectHandle >> asLocalBytes [
	^runtime bytesOf: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> asLocalCollection [
	^self isBytes ifTrue: [runtime stringOf: oid] ifFalse: [self ASSERT: false]
]

{ #category : #'meta accessing' }
ObjectHandle >> asLocalInteger [
	^runtime integerOf: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> asLocalString [
	^runtime stringOf: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> basicFlags [
	^runtime objectFormat flagsOf: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> basicSize [
	^runtime objectFormat smallSizeOf: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> getBehavior [
	| behavior |
	behavior := runtime objectFormat behaviorOf: oid.
	^self handleOn: behavior
]

{ #category : #'as yet unclassified' }
ObjectHandle >> indexOf: varname for: aMirror [
	| type |
	type := self structureOf: aMirror structureType.
	^type indexOf: varname
]

{ #category : #'as yet unclassified' }
ObjectHandle >> indexOf: varname inStructureOf: type [
	^runtime indexOf: varname inStructureOf: type
]

{ #category : #'meta accessing' }
ObjectHandle >> isArrayed [
	^runtime objectFormat isArrayed: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> isBytes [
	^runtime objectFormat isBytes: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> isFixed [
	^self isArrayed not
]

{ #category : #'meta accessing' }
ObjectHandle >> isLarge [
	^self isSmall not
]

{ #category : #'meta accessing' }
ObjectHandle >> isSmall [
	^runtime objectFormat isSmall: oid
]

{ #category : #'meta accessing' }
ObjectHandle >> largeSize [
	^runtime objectFormat largeSizeOf: oid
]

{ #category : #converting }
ObjectHandle >> maneuverer [
	^DirectGate subjectOn: self
]

{ #category : #converting }
ObjectHandle >> mirage [
	^MirageGate subjectOn: self
]

{ #category : #accessing }
ObjectHandle >> mirror [
	^ObjectMirror on: self
]

{ #category : #private }
ObjectHandle >> nilObject [
	^runtime nil
]

{ #category : #comparing }
ObjectHandle >> oid [
	^oid
]

{ #category : #accessing }
ObjectHandle >> oid: objectId [
	oid := objectId
]

{ #category : #'meta accessing' }
ObjectHandle >> printFlagsOn: aStream [
	| char |
	aStream nextPut: $(.
	char := self isSmall
		ifTrue: [ $S ]
		ifFalse: [ $L ].
	aStream
		nextPut: char;
		space.
	char := self isBytes
		ifTrue: [ $B ]
		ifFalse: [ $P ].
	aStream
		nextPut: char;
		space.
	char := self isFixed
		ifTrue: [ $F ]
		ifFalse: [ $A ].
	aStream
		nextPut: char;
		nextPut: $)
]

{ #category : #'meta accessing' }
ObjectHandle >> printOn: aStream [
	| size |
	aStream
		nextPut: $@;
		nextPutAll: oid hex;
		nextPutAll: '[flags: 0x';
		nextPutAll: self basicFlags printStringHex.
	self printFlagsOn: aStream.
aStream		nextPutAll: ', size: 0x';
		nextPutAll: self size printStringHex;
		nextPut: $].
	self isBytes
		ifFalse: [ ^ self ].
	aStream cr.
	size := self basicSize min: 128.
	runtime bytesOf: oid count: size.
	self asLocalBytes hexDumpOn: aStream max: 128
]

{ #category : #'meta accessing' }
ObjectHandle >> size [
	^runtime objectFormat sizeOf: oid
]

{ #category : #services }
ObjectHandle >> slotAt: index [
	| slot |
	slot := runtime slotOf: oid at: index.
	^self handleOn: slot
]

{ #category : #services }
ObjectHandle >> slotAt: index put: anOid [
	^runtime slotOf: oid at: index put: anOid
]

{ #category : #'as yet unclassified' }
ObjectHandle >> structureOf: type [
	^runtime structureOf: type
]
