Extension { #name : #Collection }

{ #category : #'*Powerlang-Core' }
Collection class >> with: anObject withAll: aCollection [
	^self new add: anObject; addAll: aCollection; yourself
]
