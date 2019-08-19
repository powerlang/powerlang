Class {
	#name : #PharoObjectFormat,
	#superclass : #ObjectFormat,
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #public }
PharoObjectFormat >> behaviorOf: oid [
	^self ASSERT: false
]

{ #category : #public }
PharoObjectFormat >> bytesOf: oid count: size [
	^oid copyFrom: 1 to: size
]

{ #category : #public }
PharoObjectFormat >> classOf: anObjectHandle [
	^anObjectHandle oid class
]

{ #category : #public }
PharoObjectFormat >> integerOf: oid [
	self ASSERT: oid isInteger.
	^ oid
]

{ #category : #public }
PharoObjectFormat >> isBytes: oid [
	^oid isBytes
]

{ #category : #public }
PharoObjectFormat >> isInteger: oid [
	^oid isInteger
]

{ #category : #public }
PharoObjectFormat >> labelFor: oid [
	^(storage nameOf: oid) ifNil: [ 'unknown' ]
]

{ #category : #public }
PharoObjectFormat >> print: oid on: aStream [
	| label |
	label := self labelFor: oid.
	aStream
		nextPut: $@;
		nextPutAll: label;
		nextPutAll: ' [size: 0x';
		nextPutAll: (self sizeOf: oid) printStringHex;
		nextPut: $].

]

{ #category : #public }
PharoObjectFormat >> sizeOf: oid [
	^oid basicSize + oid class instSize
]

{ #category : #public }
PharoObjectFormat >> slotOf: oid at: index [
	^ oid instVarAt: index
]

{ #category : #public }
PharoObjectFormat >> stringOf: oid count: size [
	^(oid copyFrom: 1 to: size) asString
]
