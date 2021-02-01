Extension { #name : #Stream }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Stream >> sizeToEnd [
	^self size - self position
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Stream >> skip [
	self skip: 1
]
