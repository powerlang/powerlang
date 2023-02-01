Class {
	#name : #ObjectHeaderMasks,
	#superclass : #PSharedPool,
	#classVars : [
		'IsArrayed',
		'IsBytes',
		'IsNamed',
		'IsSmall'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
ObjectHeaderMasks class >> initialize [
		IsBytes := 16r1.
		IsArrayed := 16r2.
		IsNamed := 16r4.
		IsSmall := 16r80

]
