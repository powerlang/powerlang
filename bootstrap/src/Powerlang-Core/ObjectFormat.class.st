Class {
	#name : #ObjectFormat,
	#superclass : #Object,
	#instVars : [
		'runtime',
		'storage'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
ObjectFormat class >> on: storage [
	^self new storage: storage
]

{ #category : #public }
ObjectFormat >> bytesOf: oid [
	| size |
	size := self sizeOf: oid.
	^self bytesOf: oid count: size
]

{ #category : #public }
ObjectFormat >> bytesOf: oid count: size [
	^self subclassResponsibility
]

{ #category : #accessing }
ObjectFormat >> runtime [
	^ runtime
]

{ #category : #accessing }
ObjectFormat >> runtime: aRuntime [
	runtime := aRuntime
]

{ #category : #public }
ObjectFormat >> sizeOf: oid [
	^self subclassResponsibility
]

{ #category : #accessing }
ObjectFormat >> storage [
	^ storage
]

{ #category : #accessing }
ObjectFormat >> storage: anObject [
	storage := anObject
]

{ #category : #public }
ObjectFormat >> stringOf: oid [
	| size |
	size := self sizeOf: oid.
	^self stringOf: oid count: size - 1
]

{ #category : #public }
ObjectFormat >> stringOf: oid count: size [
	^self subclassResponsibility
]

{ #category : #public }
ObjectFormat >> symbolOf: oid [
	| size |
	size := self sizeOf: oid.
	^self stringOf: oid count: size
]
