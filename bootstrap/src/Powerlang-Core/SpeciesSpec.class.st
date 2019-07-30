Class {
	#name : #SpeciesSpec,
	#superclass : #Object,
	#instVars : [
		'instanceVariables',
		'methods',
		'module'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #accessing }
SpeciesSpec >> addMethod: aMethodSpec [
	^methods add: aMethodSpec
]

{ #category : #accessing }
SpeciesSpec >> allInstVarNames [
	^(self withAllSuperclasses reversed gather: [:c | c instVarNames]) asArray
]

{ #category : #accessing }
SpeciesSpec >> allSharedPools [
	| pools |
	pools := Set new.
	self withAllSuperclasses do: [:c | pools addAll: c sharedPools].
	^pools
]

{ #category : #accessing }
SpeciesSpec >> allSuperclasses [
	| superclasses |
	superclasses := OrderedCollection new.
	self allSuperclassesDo: [:s | superclasses add: s].
	^superclasses
]

{ #category : #accessing }
SpeciesSpec >> instVarNames [
	^instanceVariables
]

{ #category : #testing }
SpeciesSpec >> isExtension [
	^module extendedClasses includes: self
]

{ #category : #accessing }
SpeciesSpec >> methods [
	^methods
]

{ #category : #accessing }
SpeciesSpec >> methods: aCollection [
	methods := aCollection
]

{ #category : #accessing }
SpeciesSpec >> module: aModuleSpec [
	module := aModuleSpec
]

{ #category : #accessing }
SpeciesSpec >> selectors [
	^methods collect: #selector
]

{ #category : #accessing }
SpeciesSpec >> subclasses [
	^module allClasses select: [:c | c supername = self name]
]

{ #category : #accessing }
SpeciesSpec >> withAllSuperclasses [
	^OrderedCollection with: self withAll: self allSuperclasses
]
