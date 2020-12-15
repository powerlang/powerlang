Extension { #name : #Collection }

{ #category : #'*Powerlang-Compatibility-Pharo' }
Collection >> anyone [
	^self anyOne
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Collection >> conform: evaluable [
	^self allSatisfy: evaluable
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
Collection class >> with: anObject withAll: aCollection [
	^self new add: anObject; addAll: aCollection; yourself
]
