Class {
	#name : #MetaclassMap,
	#superclass : #SpeciesMap,
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> allInstVarNames [
	^ (spec environment at: #Metaclass) allInstVarNames
		, spec allInstVarNames
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> class: aClassMap [
	self slotNamed: #class put: aClassMap
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> classVariables [
	^ self instanceSide classVariables
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> computeAllSlotNames [
	| c |
	c := spec environment at: #Metaclass.
	^slotNames := c allInstVarNames
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> createClassAssociationsWith: aVirtualImage [
	
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> instanceSide [
	^ self slotNamed: #class
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> localPools [
	^ self instanceSide localPools
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> module [
	^ self instanceSide module
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> name [
	^ self instanceSide name asString , ' class'
]
