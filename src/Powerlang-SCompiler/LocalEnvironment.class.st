Class {
	#name : #LocalEnvironment,
	#superclass : #Object,
	#pools : [
		'ClosureElementTypes'
	],
	#category : #'Powerlang-SCompiler-Bindings'
}

{ #category : #testing }
LocalEnvironment >> isInlinedArgument [
	^false
]
