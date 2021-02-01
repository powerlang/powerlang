Extension { #name : #Block }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Block >> evaluate [
	^self value

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Block >> evaluateWith: anObject [
	^self value: anObject

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
Block >> evaluateWithArguments: anArray [
	^self valueWithArguments: anArray  

]
