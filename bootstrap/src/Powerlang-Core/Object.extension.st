Extension { #name : #Object }

{ #category : #'*Powerlang-Core' }
Object >> != anObject [
		^ self ~= anObject
]

{ #category : #'*Powerlang-Core' }
Object >> ASSERT: aBoolean [
	self assert: aBoolean
]

{ #category : #'*Powerlang-Core' }
Object >> isSmallInteger [
	^false
]
