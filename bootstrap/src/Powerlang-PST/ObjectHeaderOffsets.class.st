Class {
	#name : #ObjectHeaderOffsets,
	#superclass : #SharedPool,
	#classVars : [
		'BehaviorOffset',
		'FlagsOffset',
		'HashOffset',
		'LargeSizeOffset',
		'SizeOffset'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #'class initialization' }
ObjectHeaderOffsets class >> initialize [
	BehaviorOffset := -4.
	FlagsOffset := -5.
	SizeOffset := -6.
	HashOffset := -8.
	LargeSizeOffset := -16
]
