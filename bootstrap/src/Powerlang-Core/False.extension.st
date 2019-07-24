Extension { #name : #False }

{ #category : #'*Powerlang-Core' }
False >> andNot: aBlock [
	^self
]

{ #category : #'*Powerlang-Core' }
False >> or: aBlock or: anotherBlock [
	^aBlock value or: [anotherBlock value]
]
