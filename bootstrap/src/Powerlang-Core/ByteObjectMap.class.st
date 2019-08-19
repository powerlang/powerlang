Class {
	#name : #ByteObjectMap,
	#superclass : #ObjectMap,
	#instVars : [
		'contents'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
ByteObjectMap >> asString [
	^contents asString
]

{ #category : #accessing }
ByteObjectMap >> contents [
	^contents
]

{ #category : #accessing }
ByteObjectMap >> contents: aByteObject [
	contents := aByteObject
]

{ #category : #'as yet unclassified' }
ByteObjectMap >> flagsField [
	| bytes variable small |
	bytes := 1.
	variable := 2.
	small := self isSmall ifTrue: [ 16r80 ] ifFalse: [ 0 ].
	^ bytes | variable | small
]

{ #category : #printing }
ByteObjectMap >> isBytes [
	^true
]

{ #category : #printing }
ByteObjectMap >> printOn: aStream [
	aStream nextPutAll: '['.
	behavior ifNil: [ aStream nextPutAll: 'no-behavior! ' ].
	aStream print: contents; nextPutAll: ']'
]

{ #category : #accessing }
ByteObjectMap >> size [
	^ contents size
]

{ #category : #accessing }
ByteObjectMap >> slotByteSize [
	^ contents size alignedTo: WordSize 
]
