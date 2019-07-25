Extension { #name : #Stream }

{ #category : #'*Powerlang-Core' }
Stream >> sizeToEnd [
	^self size - self position
]

{ #category : #'*Powerlang-Core' }
Stream >> skip [
	self skip: 1
]
