Class {
	#name : #LocalEnvironment,
	#superclass : #Object,
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
LocalEnvironment >> isInlinedArgument [
	^false
]
