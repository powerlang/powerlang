Extension { #name : #Object }

{ #category : #'*PST' }
Object >> != anObject [
		^ self ~= anObject
]

{ #category : #'*PST' }
Object >> isSmallInteger [
	^false
]
