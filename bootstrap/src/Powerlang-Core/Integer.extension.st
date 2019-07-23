Extension { #name : #Integer }

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
