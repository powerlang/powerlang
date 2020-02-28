Extension { #name : #Collection }

{ #category : #'*Powerlang-Core' }
Collection >> anyone [
	^self anyOne
]

{ #category : #'*Powerlang-Core' }
Collection >> conform: evaluable [
	^self allSatisfy: evaluable
]

{ #category : #'*Powerlang-Core' }
Collection class >> with: anObject withAll: aCollection [
	^self new add: anObject; addAll: aCollection; yourself
]
