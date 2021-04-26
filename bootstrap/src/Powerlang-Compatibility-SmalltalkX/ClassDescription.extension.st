Extension { #name : #ClassDescription }

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ClassDescription >> allSharedPoolsUsing: globals [
	^self sharedPools

]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ClassDescription >> indexOfSlot: instVarName [
	^self instVarIndexFor: instVarName
]

{ #category : #'*Powerlang-Compatibility-SmalltalkX' }
ClassDescription >> localPools [
	^#()
]
