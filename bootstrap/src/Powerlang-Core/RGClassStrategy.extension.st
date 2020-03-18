Extension { #name : #RGClassStrategy }

{ #category : #'*Powerlang-Core' }
RGClassStrategy >> localPools [
	^self classVariables select: [:c | c isPoolVariable]

]
