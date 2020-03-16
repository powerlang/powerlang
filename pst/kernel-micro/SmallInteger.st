Class {
	#name : #SmallInteger,
	#superclass : #Integer,
	#classVars : [
		'Maximum',
		'Minimum'
	],
	#category : #Kernel
}


{ #category : #'bits' }
SmallInteger >> & anInteger [
	<primitive: SmallIntegerBitAnd>
]

{ #category : #'comparing' }
SmallInteger >> = aNumber [
	<primitive: SmallIntegerEqual>
]

{ #category : #'comparing' }
SmallInteger >> != aNumber [
	<primitive: SmallIntegerNotEqual>
]
