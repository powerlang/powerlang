Class {
	#name : #CharacterConstants,
	#superclass : #PSharedPool,
	#classVars : [
		'Cr',
		'Lf',
		'Space',
		'Tab'
	],
	#category : #'Powerlang-Core-Compatibility'
}

{ #category : #'class initialization' }
CharacterConstants class >> initialize [
	Cr := Character cr.
	Lf := Character lf.
	Tab := Character tab.
	Space := Character space.
]
