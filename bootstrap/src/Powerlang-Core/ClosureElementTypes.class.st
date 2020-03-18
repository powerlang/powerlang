Class {
	#name : #ClosureElementTypes,
	#superclass : #SharedPool,
	#classVars : [
		'Argument',
		'Environment',
		'EnvironmentValue',
		'Self'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #'class initialization' }
ClosureElementTypes class >> initialize [
	Self := 0.
	Argument := 1.
	Environment := 2.
	EnvironmentValue := 3
]
