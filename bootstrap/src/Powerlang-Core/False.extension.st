Extension { #name : #False }

{ #category : #'*Powerlang-Core' }
False >> andNot: aBlock [
	^self
]

{ #category : #'*Powerlang-Core' }
False >> or: aBlock or: anotherBlock [
	^aBlock value or: [anotherBlock value]
]

{ #category : #'*Powerlang-Core' }
False >> or: aBlock or: aBlock2 or: aBlock3 [
	aBlock value ifTrue: [^true].
	aBlock2 value ifTrue: [^true].
	aBlock3 value ifTrue: [^true].
	^self
]

{ #category : #'*Powerlang-Core' }
False >> orNot: aBlock [
	^aBlock value not
]
