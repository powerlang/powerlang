Extension { #name : #WriteStream }

{ #category : #'*Powerlang-Core' }
WriteStream >> nextBytePut: aCollection [
	^ self nextPut: aCollection
]

{ #category : #'*Powerlang-Core' }
WriteStream >> nextBytesPut: aCollection [
	^self nextBytesPutAll: aCollection
]

{ #category : #'*Powerlang-Core' }
WriteStream >> nextLongPut: anInteger [
	| unsigned |
	unsigned := anInteger < 0 ifTrue: [ anInteger + (1 << 32) ] ifFalse: [ anInteger  ]
.self nextULongPut: unsigned.
]

{ #category : #'*Powerlang-Core' }
WriteStream >> nextULongPut: anInteger [
	1 to: 4 do: [ :i | 
		| bi |
		bi := anInteger byteAt: i.
		self nextPut: bi ]

]

{ #category : #'*Powerlang-Core' }
WriteStream >> peek [
	^self atEnd ifFalse: [collection at: position + 1]
]
