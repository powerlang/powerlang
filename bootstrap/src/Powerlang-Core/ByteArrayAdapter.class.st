Class {
	#name : #ByteArrayAdapter,
	#superclass : #Object,
	#instVars : [
		'bytes'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
ByteArrayAdapter class >> on: aByteArray [
	^self new bytes: aByteArray
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> bytes: aByteArray [
	bytes := aByteArray
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> bytesAt: base sized: size [
	^ bytes copyFrom: base + 1 to: base + size
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> slotOf: base at: index [
	^ self uint64atOffset: base + (8 * (index - 1))
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> slotOf: base at: index put: value [
	^ self uint64atOffset: base + ((index - 1) * 8) put: value
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> stringAt: base sized: size [
	^ (self bytesAt: base sized: size) asString
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint16atOffset: anInteger [
	^ bytes unsignedShortAt: anInteger + 1
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint16atOffset: anInteger put: value [
	^ bytes unsignedShortAt: anInteger + 1 put: value
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint16of: base atOffset: offset [
	^ self uint16atOffset: base + offset
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint32atOffset: anInteger [
	^ bytes unsignedLongAt: anInteger + 1
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint32atOffset: anInteger put: value [
	^ bytes unsignedLongAt: anInteger + 1 put: value
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint32of: base atOffset: offset [
	^ self uint32atOffset: base + offset
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint64atOffset: anInteger [
	^ bytes unsignedLongLongAt: anInteger + 1
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint64atOffset: anInteger put: value [
	^ bytes unsignedLongLongAt: anInteger + 1 put: value
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint8atOffset: anInteger [
	^ bytes unsignedByteAt: anInteger + 1
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint8atOffset: anInteger put: value [
	^ bytes unsignedByteAt: anInteger + 1 put: value
]

{ #category : #'as yet unclassified' }
ByteArrayAdapter >> uint8of: base atOffset: offset [
	^ self uint8atOffset: base + offset
]

{ #category : #accessing }
ByteArrayAdapter >> wordSize [
	^8
]
