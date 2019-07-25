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
Object >> evaluate [
	^self
]

{ #category : #'*Powerlang-Core' }
Object >> evaluateWith: anObject [
	^self evaluateWithArguments: {anObject}
]

{ #category : #'*Powerlang-Core' }
Object >> evaluateWithArguments: anArray [
	^self evaluate
]

{ #category : #'*Powerlang-Core' }
Object >> isEmptyOrNil [
	^false
]

{ #category : #'*Powerlang-Core' }
Object >> isSmallInteger [
	^false
]
