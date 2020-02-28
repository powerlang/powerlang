Extension { #name : #PositionableStream }

{ #category : #'*Powerlang-Core' }
PositionableStream >> peekForAll: aCollection [
	| n |
	n := aCollection size.
	^((self peek: n) hasEqualElements: aCollection)
		ifTrue: [self skip: n];
		yourself
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint16le [
	"Answer the next unsigned, 16-bit integer from this (binary) stream."

	^ self next + (self next bitShift: 8)
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint16le: anInteger [
	"Store the given unsigned, 32-bit integer as little endian 
	 on this (binary) stream."

	(anInteger < 0 or: [ anInteger >= 16r10000 ])
		ifTrue: [ self error: 'outside unsigned 16-bit integer range' ].
	self nextPut: (anInteger byteAt: 1).
	self nextPut: (anInteger byteAt: 2)
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint32le [
	"Answer the next unsigned, 32-bit integer from this (binary) stream."

	^self next + (self next bitShift: 8) + (self next bitShift: 16) + (self next bitShift: 24)
	
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint32le: anInteger [
	"Store the given unsigned, 32-bit integer as little endian 
	 on this (binary) stream."

	(anInteger < 0 or: [ anInteger >= 16r100000000 ])
		ifTrue: [ self error: 'outside unsigned 32-bit integer range' ].
	self nextPut: (anInteger byteAt: 1).
	self nextPut: (anInteger byteAt: 2).
	self nextPut: (anInteger byteAt: 3).
	self nextPut: (anInteger byteAt: 4)
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint64le [
	"Answer the next unsigned, 64-bit integer from this (binary) stream."

	^ self next + (self next bitShift: 8) + (self next bitShift: 16)
		+ (self next bitShift: 24) + (self next bitShift: 32)
		+ (self next bitShift: 40) + (self next bitShift: 48)
		+ (self next bitShift: 56)
]

{ #category : #'*Powerlang-Core' }
PositionableStream >> uint64le: anInteger [
	"Store the given unsigned, 64-bit integer as little endian 
	 on this (binary) stream."

	self nextPut: (anInteger byteAt: 1).
	self nextPut: (anInteger byteAt: 2).
	self nextPut: (anInteger byteAt: 3).
	self nextPut: (anInteger byteAt: 4).
	self nextPut: (anInteger byteAt: 5).
	self nextPut: (anInteger byteAt: 6).
	self nextPut: (anInteger byteAt: 7).
	self nextPut: (anInteger byteAt: 8)
]
