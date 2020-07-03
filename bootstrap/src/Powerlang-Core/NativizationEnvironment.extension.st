Extension { #name : #NativizationEnvironment }

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> bareMetalNativizer [
	^OptimizingNativizer
]

{ #category : #'*Powerlang-Core-OCompiler' }
NativizationEnvironment >> shouldOptimize: method [
	^optimizedMethods includes: method
]
