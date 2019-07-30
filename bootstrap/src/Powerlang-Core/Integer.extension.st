Extension { #name : #Integer }

{ #category : #'*Powerlang-Core' }
Integer >> bitShiftRight: anInteger [
	^self bitShift: 0 - anInteger
]

{ #category : #'*Powerlang-Core' }
Integer >> bitsAt: aStretch [
	"
	(2r001101010 bitField: (3 thru: 6)) bin = '1010'
	(-16r40000000 bitField: (29 thru: 31)) bin = '100'
	"
	| shifted mask |
	shifted := self bitShiftRight: aStretch start - 1.
	mask := 1 bitShift: aStretch length.
	^shifted bitAnd: mask - 1
]

{ #category : #'*Powerlang-Core' }
Integer >> bitsAt: aStretch put: anInteger [
	"
	((2r001101100 bitsAt: (3 thru: 6) put: 2r1101) bitField: (3 thru: 6)) bin = '1101'
	((2r100 bitsAt: (29 thru: 31) put: 2r101) bitField: (29 thru: 31)) bin = '101'
	((2r100 bitsAt: (29 thru: 31) put: 2r101) bitField: (1 thru: 3)) bin = '100'
	"
	| shifted max |
	shifted := anInteger bitShift: aStretch start - 1.
	max := 1 bitShift: aStretch length.
	anInteger < max ifFalse: [self error: 'invalid argument'].
	^(self bitsClear: aStretch) bitOr: shifted
]

{ #category : #'*Powerlang-Core' }
Integer >> bitsClear: aStretch [
	"
	(2r111100110 bitsClear: (3 thru: 6)) = 2r111000010
	"
	| mask |
	mask := (1 bitShift: aStretch end) - (1 bitShift: aStretch start - 1).
	^self bitAnd: mask bitInvert
]

{ #category : #'*Powerlang-Core' }
Integer >> linearFeedbackShiftRandom: key [
	"
	LFSR implementation (avoids 0 by definition).
	More keys at: https://users.ece.cmu.edu/~koopman/lfsr/index.html
	"

	| shifted |
	shifted := self bitShift: -1.
	^ (self bitAnd: 1) = 0
		ifTrue: [ shifted ]
		ifFalse: [ shifted bitXor: key ]
]

{ #category : #'*Powerlang-Core' }
Integer >> thru: anInteger [
	^Stretch from: self thru: anInteger
]
