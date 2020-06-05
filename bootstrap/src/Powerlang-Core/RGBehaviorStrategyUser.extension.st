Extension { #name : #RGBehaviorStrategyUser }

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> allSharedPoolsUsing: globals [
	"
	in a pure, spec-based compilation, trying to access 
	state (a shared pool) is considered an error
	"

	^ Dictionary new
]

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> classVarNamed: aString [
	^ self classVariables
		detect: [ :v | v name = aString asSymbol ]
		ifNone: [ nil ]
]

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> isSpecies [
	^self isBehavior
]

{ #category : #'*Powerlang-Core' }
RGBehaviorStrategyUser >> localPools [
	^ self behaviorStrategy localPools
]
