Extension { #name : #RGBehaviorStrategyUser }

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> isSpecies [
	^self isBehavior
]

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> localPools [
	^ self behaviorStrategy localPools
]
