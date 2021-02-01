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
WriteStream >> nextLongPut: anInteger [
	| unsigned |
	unsigned := anInteger < 0 ifTrue: [ anInteger + (1 << 32) ] ifFalse: [ anInteger  ]
.self nextULongPut: unsigned.
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
WriteStream >> nextULongPut: anInteger [
	1 to: 4 do: [ :i | 
		| bi |
		bi := anInteger byteAt: i.
		self nextPut: bi ]
]
