Class {
	#name : #MetaclassSpec,
	#superclass : #SpeciesSpec,
	#instVars : [
		'class'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'instance creation' }
MetaclassSpec class >> new [
	^super new initialize
]

{ #category : #accessing }
MetaclassSpec >> allSuperclassesDo: aBlock [
	| s c |
	class supername isNil ifTrue: [
		c := module resolveClass: 'Class'.
		c ifNil: [c := Class].
		c allSuperclassesDo: aBlock].
	s := self superclass.
	aBlock value: s.
	s allSuperclassesDo: aBlock
]

{ #category : #accessing }
MetaclassSpec >> classBinding: aClassSpec [
	class := aClassSpec
]

{ #category : #accessing }
MetaclassSpec >> classVarNames [
	^class classVarNames
]

{ #category : #accessing }
MetaclassSpec >> configureCompiler: aCompiler [
	
]

{ #category : #initialization }
MetaclassSpec >> initialize [
	methods := OrderedCollection new
]

{ #category : #accessing }
MetaclassSpec >> instanceSide [
	^class
]

{ #category : #accessing }
MetaclassSpec >> name [
	^class name , ' class'
]

{ #category : #accessing }
MetaclassSpec >> sharedPools [
	^class sharedPools
]

{ #category : #accessing }
MetaclassSpec >> superclass [
	^class superclass ifNotNil: [:c | c metaclass]
]
