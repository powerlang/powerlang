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
PharoObjectFormat >> isBytes: anObject [
	^anObject class isBytes
]

{ #category : #public }
PharoObjectFormat >> isInteger: oid [
	^oid isInteger
]

{ #category : #public }
PharoObjectFormat >> labelFor: oid [
	| label |
	label := storage ifNotNil: [storage nameOf: oid].
	^label ifNil: [ 'unknown' ]
]

{ #category : #public }
PharoObjectFormat >> print: oid on: aStream [
	aStream
		nextPutAll: '@local {';
		print: oid;
		nextPut: $}
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
