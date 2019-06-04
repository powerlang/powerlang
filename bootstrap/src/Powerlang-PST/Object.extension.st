Extension { #name : #Object }

{ #category : #'*Powerlang-PST' }
Object >> != anObject [
		^ self ~= anObject
]

{ #category : #'*Powerlang-PST' }
Object >> ASSERT: aBoolean [
	self assert: aBoolean
]

{ #category : #'*Powerlang-PST' }
Object >> isSmallInteger [
	^false
]
