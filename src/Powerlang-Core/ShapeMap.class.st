"
I represent the shape of objects as used by mirrors. Mirrors
access instance variables by name, asking the runtime the for
the offsets of the instVars.
"
Class {
	#name : #ShapeMap,
	#superclass : #Object,
	#instVars : [
		'shapes'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
ShapeMap class >> new [
	^self basicNew initialize
]

{ #category : #adding }
ShapeMap >> add: structure [
	shapes at: structure name put: structure
]

{ #category : #adding }
ShapeMap >> at: type [
	^shapes at: type
]

{ #category : #adding }
ShapeMap >> indexInCurrentOf: varname at: type [
	| species slot |
	species := Smalltalk at: type asSymbol.
	slot := species slotNamed: varname.
	slot isNil
		ifTrue: [ self error: 'inst var ' , varname , ' not found' ].
	^ slot index
]

{ #category : #adding }
ShapeMap >> indexOf: varname at: type [
	| shape |
	shape := shapes at: type ifAbsent: [
		^self indexInCurrentOf: varname at: type].
	^shape indexOf: varname
]

{ #category : #adding }
ShapeMap >> initialize [
	shapes := Dictionary new
]

{ #category : #adding }
ShapeMap >> load: aClassDefinition [
	| shape |
	shape := ObjectShape new loadFrom: aClassDefinition.
	self add: shape
]
