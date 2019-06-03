Extension { #name : #PositionableStream }

{ #category : #'*PST' }
PositionableStream >> uint16le: anInteger [
	"Store the given unsigned, 32-bit integer as little endian 
	 on this (binary) stream."

	(anInteger < 0 or: [ anInteger >= 16r10000 ])
		ifTrue: [ self error: 'outside unsigned 16-bit integer range' ].
	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).

]

{ #category : #'*PST' }
PositionableStream >> uint32le: anInteger [
	"Store the given unsigned, 32-bit integer as little endian 
	 on this (binary) stream."

	(anInteger < 0 or: [ anInteger >= 16r100000000 ])
		ifTrue: [ self error: 'outside unsigned 32-bit integer range' ].
	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 4)
]

{ #category : #'*PST' }
PositionableStream >> uint64le: anInteger [
	"Store the given unsigned, 64-bit integer as little endian 
	 on this (binary) stream."

	self nextPut: (anInteger digitAt: 1).
	self nextPut: (anInteger digitAt: 2).
	self nextPut: (anInteger digitAt: 3).
	self nextPut: (anInteger digitAt: 4).
	self nextPut: (anInteger digitAt: 5).
	self nextPut: (anInteger digitAt: 6).
	self nextPut: (anInteger digitAt: 7).
	self nextPut: (anInteger digitAt: 8)
]
