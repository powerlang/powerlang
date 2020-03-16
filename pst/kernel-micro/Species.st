Class {
	#name : #Species,
	#superclass : #Object,
	#instVars : [
		'superclass',
		'instanceBehavior',
		'format',
		'instanceVariables',
		'organization'
	],
	#classVars : [
		'Flags'
	],
	#category : #Kernel
}

{ #category : #'pool initialization' }
Species class >> initializeSpeciesFormatMasks [
	Flags := PoolDictionary new.
	Flags
		at: 'Variable' put: 16r100;
		at: 'Pointers' put: 16r200
]


{ #category : #'instance creation' }
Species >> new [
	self instancesAreArrayed
		ifTrue: [self primitiveNew: 0]
		ifFalse: [self primitiveNew]
]


{ #category : #'testing' }
Species >> instancesAreArrayed [
	^format & Variable = Variable
]

{ #category : #'instance creation' }
Species >> primitiveNew [
	<primitive: New>
]

{ #category : #'instance creation' }
Species >> primitiveNew [
	<primitive: NewSized>
]
