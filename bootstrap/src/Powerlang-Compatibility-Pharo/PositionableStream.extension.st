Extension { #name : #PositionableStream }

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> int64 [
	"Answer the next signed, 64-bit integer from this (binary) stream."

	"Details: As a fast check for negative number, check the high bit of the first digit"

	| n firstDigit |
	n := firstDigit := self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	n := (n bitShift: 8) + self next.
	firstDigit >= 128
		ifTrue: [ n := -16r10000000000000000 + n ].	"decode negative 64-bit integer"
	^ n
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> int64: anInteger [
	"Store the given signed, 64-bit integer on this (binary) stream."

	| n |
	(anInteger < -16r8000000000000000 or: [ anInteger >= 16r8000000000000000 ])
		ifTrue: [ self error: 'outside 32-bit integer range' ].
	n := anInteger < 0
		ifTrue: [ 16r10000000000000000 + anInteger ]
		ifFalse: [ anInteger ].
	self nextPut: (n byteAt: 8).
	self nextPut: (n byteAt: 7).
	self nextPut: (n byteAt: 6).
	self nextPut: (n byteAt: 5).
	self nextPut: (n byteAt: 4).
	self nextPut: (n byteAt: 3).
	self nextPut: (n byteAt: 2).
	self nextPut: (n byteAt: 1)
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> peekForAll: aCollection [
	| n |
	n := aCollection size.
	^((self peek: n) hasEqualElements: aCollection)
		ifTrue: [self skip: n];
		yourself
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> uint16le [
	"Answer the next unsigned, 16-bit integer from this (binary) stream."

	^ self next + (self next bitShift: 8)
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> uint16le: anInteger [
	"Store the given unsigned, 32-bit integer as little endian 
	 on this (binary) stream."

	(anInteger < 0 or: [ anInteger >= 16r10000 ])
		ifTrue: [ self error: 'outside unsigned 16-bit integer range' ].
	self nextPut: (anInteger byteAt: 1).
	self nextPut: (anInteger byteAt: 2)
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> uint32le [
	"Answer the next unsigned, 32-bit integer from this (binary) stream."

	^self next + (self next bitShift: 8) + (self next bitShift: 16) + (self next bitShift: 24)
	
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
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

{ #category : #'*Powerlang-Compatibility-Pharo' }
PositionableStream >> uint64le [
	"Answer the next unsigned, 64-bit integer from this (binary) stream."

	^ self next + (self next bitShift: 8) + (self next bitShift: 16)
		+ (self next bitShift: 24) + (self next bitShift: 32)
		+ (self next bitShift: 40) + (self next bitShift: 48)
		+ (self next bitShift: 56)
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
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
