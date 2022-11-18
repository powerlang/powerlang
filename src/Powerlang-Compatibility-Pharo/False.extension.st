Extension { #name : #False }

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> and: block1 and: block2 [
	^ self
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> and: block1 and: block2 and: block3 [
	^self

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> and: block1 andNot: block2 [
	^self
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> andNot: aBlock [
	^self
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> or: aBlock or: anotherBlock [
	^aBlock value or: [anotherBlock value]
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> or: aBlock or: aBlock2 or: aBlock3 [
	aBlock value ifTrue: [^true].
	aBlock2 value ifTrue: [^true].
	aBlock3 value ifTrue: [^true].
	^self
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
False >> orNot: aBlock [
	^aBlock value not
]
