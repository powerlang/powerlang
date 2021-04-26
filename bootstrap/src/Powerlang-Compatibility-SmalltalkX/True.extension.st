Extension { #name : #True }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
True >> and: block1 andNot: block2 [
	^block1 value andNot: [block2 value]
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
True >> andNot: aBlock [
	^aBlock value not
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
True >> orNot: aBlock [
	^self
]
