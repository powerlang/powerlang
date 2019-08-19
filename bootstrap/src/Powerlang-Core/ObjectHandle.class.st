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
	^runtime objectFormat bytesOf: oid
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
ObjectHandle >> getBehavior [
	| behavior |
	behavior := runtime objectFormat behaviorOf: oid.
	^self handleOn: behavior
]

{ #category : #'meta accessing' }
ObjectHandle >> getClass [
	^runtime objectFormat classOf: self.

]

{ #category : #comparing }
ObjectHandle >> hash [
	^oid hash
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

{ #category : #comparing }
ObjectHandle >> isInteger [
	^runtime objectFormat isInteger: oid
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
ObjectHandle >> printOn: aStream [
	| format size bytes |
	format := runtime objectFormat.
	format print: oid on: aStream.
	self isBytes
		ifFalse: [ ^ self ].
	size := self size min: 128.
	size < 30
		ifTrue: [ aStream nextPutAll: ': ' ]
		ifFalse: [ aStream cr ].
	bytes := format bytesOf: oid count: size.
	aStream print: bytes
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
