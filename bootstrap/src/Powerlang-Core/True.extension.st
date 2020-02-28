Extension { #name : #True }

{ #category : #'*Powerlang-Core' }
True >> and: block1 and: block2 [
	^ block1 value and: [ block2 value ]
]

{ #category : #'*Powerlang-Core' }
True >> and: block1 and: block2 and: block3 [
	^block1 value and: [block2 value] and: [block3 value]
]

{ #category : #'*Powerlang-Core' }
True >> and: block1 andNot: block2 [
	^block1 value andNot: [block2 value]
]

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
