Extension { #name : #BlockClosure }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
BlockClosure >> evaluate [
	^self value

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
BlockClosure >> evaluateWith: anObject [
	^self value: anObject

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
BlockClosure >> evaluateWithArguments: anArray [
	^self valueWithArguments: anArray  

]
