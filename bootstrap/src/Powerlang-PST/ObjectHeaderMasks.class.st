Class {
	#name : #ObjectHeaderMasks,
	#superclass : #SharedPool,
	#classVars : [
		'IsArrayed',
		'IsBytes',
		'IsNamed',
		'IsSmall'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #'class initialization' }
ObjectHeaderMasks class >> initialize [
		IsBytes := 16r1.
		IsArrayed := 16r2.
		IsNamed := 16r4.
		IsSmall := 16r80

]
