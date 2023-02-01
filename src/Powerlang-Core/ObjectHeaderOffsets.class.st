Class {
	#name : #ObjectHeaderOffsets,
	#superclass : #PSharedPool,
	#classVars : [
		'BehaviorOffset',
		'FlagsOffset',
		'HashOffset',
		'LargeSizeOffset',
		'SizeOffset'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'class initialization' }
ObjectHeaderOffsets class >> initialize [
	BehaviorOffset := -4.
	FlagsOffset := -5.
	SizeOffset := -6.
	HashOffset := -8.
	LargeSizeOffset := -16
]
