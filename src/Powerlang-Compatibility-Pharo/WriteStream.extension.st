Extension { #name : #WriteStream }

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextBytePut: aCollection [
	^ self nextPut: aCollection
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextBytesPut: aCollection [
	^self nextBytesPutAll: aCollection
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextLargePut: anInteger [
	| unsigned |
	unsigned := anInteger < 0 ifTrue: [ anInteger + (1 << 64) ] ifFalse: [ anInteger  ]
.self nextULargePut: unsigned.
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextLongPut: anInteger [
	| unsigned |
	unsigned := anInteger < 0 ifTrue: [ anInteger + (1 << 32) ] ifFalse: [ anInteger  ]
.self nextULongPut: unsigned.
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextULargePut: anInteger [
	1 to: 8 do: [ :i | 
		| bi |
		bi := anInteger byteAt: i.
		self nextPut: bi ]

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> nextULongPut: anInteger [
	1 to: 4 do: [ :i | 
		| bi |
		bi := anInteger byteAt: i.
		self nextPut: bi ]

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
WriteStream >> peek [
	^self atEnd ifFalse: [collection at: position + 1]
]
