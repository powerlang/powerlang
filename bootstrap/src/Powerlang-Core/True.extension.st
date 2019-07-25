Extension { #name : #True }

{ #category : #'*Powerlang-Core' }
True >> andNot: aBlock [
	^aBlock value not
]

{ #category : #'*Powerlang-Core' }
True >> or: aBlock or: aBlock2 [
	^self
]

{ #category : #'*Powerlang-Core' }
True >> or: aBlock or: aBlock2 or: aBlock3 [
	^self
]

{ #category : #'*Powerlang-Core' }
True >> orNot: aBlock [
	^self
]
