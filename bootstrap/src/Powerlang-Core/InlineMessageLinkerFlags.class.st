Class {
	#name : #InlineMessageLinkerFlags,
	#superclass : #PSharedPool,
	#classVars : [
		'_ExtendedSize',
		'_Flags',
		'_Hash',
		'_Reserved',
		'_SmallSize'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #'class initialization' }
InlineMessageLinkerFlags class >> initialize [
	_Flags := -5.
	_SmallSize := -6.
	_Hash := -8.
	_Reserved := -2.
	_ExtendedSize := -3.

]
