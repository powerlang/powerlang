Extension { #name : #ClassDescription }

{ #category : #'*Powerlang-Core' }
ClassDescription >> allSharedPoolsUsing: globals [
	^self allSharedPools 
]

{ #category : #'*Powerlang-Core' }
ClassDescription >> localPools [
	^#()
]
