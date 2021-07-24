Extension { #name : #WriteStream }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextBytePut: aCollection [
	^ self nextPut: aCollection
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextBytesPut: aCollection [
	^self nextPutAll: aCollection

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextLargePut: anInteger [
	self nextPutInt64: anInteger MSB: false.

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextLongPut: anInteger [
	self nextPutInt32: anInteger MSB: false.

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextULongPut: anInteger [
	|hh hl lh ll|

	self ASSERT: anInteger >= 0.

	ll := anInteger bitAnd: 16rFF.
	lh := (anInteger bitShift: -8 ) bitAnd: 16rFF.
	hl := (anInteger bitShift: -16) bitAnd: 16rFF.
	hh := (anInteger bitShift: -24) bitAnd: 16rFF.

	"low bytes first"
	self nextPutByte:ll.
	self nextPutByte:lh.
	self nextPutByte:hl.
	self nextPutByte:hh.       

]
