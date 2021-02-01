Extension { #name : #False }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
False >> and: block1 andNot: block2 [
	^self
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
False >> andNot: aBlock [
	^self
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
False >> orNot: aBlock [
	^aBlock value not
]
