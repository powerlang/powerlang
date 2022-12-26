Class {
	#name : #CharacterConstants,
	#superclass : #PSharedPool,
	#classVars : [
		'Cr',
		'Lf',
		'Space',
		'Tab'
	],
	#category : #'Powerlang-Compatibility-SmalltalkX'
}

{ #category : #'class initialization' }
CharacterConstants class >> initialize [
	Cr := Character cr.
	Lf := Character lf.
	Tab := Character tab.
	Space := Character space.
]
