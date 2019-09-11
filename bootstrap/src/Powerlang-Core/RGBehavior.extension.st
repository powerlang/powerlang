Extension { #name : #RGBehavior }

{ #category : #'*Powerlang-Core' }
RGBehavior >> allSharedPools [
	"Answer an ordered collection of the pools the receiver shares, including those defined  in the superclasses of the receiver."
	
	^self superclass
		ifNil: [self sharedPools copy]
		ifNotNil: [| aSet |
			aSet :=  self hasResolvedSuperclass 
							ifTrue:[self superclass allSharedPools] 
							ifFalse:[Set new].
			aSet addAll: self sharedPools; yourself]
]

{ #category : #'*Powerlang-Core' }
RGBehavior >> configureCompiler: aCompiler [
	
	
]

{ #category : #'*Powerlang-Core' }
RGBehavior >> localPools [
	^#()
]
