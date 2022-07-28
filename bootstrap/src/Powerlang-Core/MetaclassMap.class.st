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
MetaclassMap >> module [
	^ self instanceSide module
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> namespaces [
	^ self instanceSide namespaces
]

{ #category : #'accessing - parallel hierarchy' }
MetaclassMap >> printOn: aStream [
	aStream
		nextPutAll: '<<';
		nextPutAll: self instanceSide name asString;
		nextPutAll: ' class>>'
]
