Extension { #name : #ClassDescription }

{ #category : #'*Powerlang-Compatibility-Pharo' }
ClassDescription >> allSharedPoolsUsing: globals [
	^self allSharedPools 
]

{ #category : #'*Powerlang-Compatibility-Pharo' }
ClassDescription >> indexOfSlot: instVarName [
	^self instVarIndexFor: instVarName

]

{ #category : #'*Powerlang-Compatibility-Pharo' }
ClassDescription >> localPools [
	^#()
]
