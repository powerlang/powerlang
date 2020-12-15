Extension { #name : #Stream }

{ #category : #'*Powerlang-Compatibility-Pharo' }
Stream >> sizeToEnd [
	^self size - self position
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Stream >> skip [
	self skip: 1
]
