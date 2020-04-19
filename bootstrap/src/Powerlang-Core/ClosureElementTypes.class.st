Class {
	#name : #ClosureElementTypes,
	#superclass : #PSharedPool,
	#classVars : [
		'Environment',
		'EnvironmentValue',
		'LocalArgument',
		'Self'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'class initialization' }
ClosureElementTypes class >> initialize [
	Self := 0.
	LocalArgument := 1.
	Environment := 2.
	EnvironmentValue := 3
]
