Class {
	#name : #SpeciesMirror,
	#superclass : #ObjectMirror,
	#classVars : [
		'Flags'
	],
	#pools : [
		'SpeciesFormatMasks'
	],
	#category : #'Powerlang-PST-Mirrors'
}

{ #category : #'behavior protocol' }
SpeciesMirror >> allInstVarNames [
	^(self withAllSuperclasses reversed gather: [:class | class instVarNames]) asArray
	

]

{ #category : #private }
SpeciesMirror >> allSuperclasses [
	| superclasses |
	superclasses := OrderedCollection new.
	self allSuperclassesDo: [:s | superclasses add: s].
	^superclasses
]

{ #category : #private }
SpeciesMirror >> allSuperclassesDo: aBlock [
	| superclass |
	superclass := self superclass.
	superclass reflectsNil ifTrue: [^self].
	aBlock value: superclass.
	superclass allSuperclassesDo: aBlock	

]

{ #category : #nativizing }
SpeciesMirror >> compiledMethodFor: selector [
	^self instBehavior compiledMethodFor: selector
]

{ #category : #'behavior protocol' }
SpeciesMirror >> indexOfSlot: name [
	| instVars |
	instVars := self allInstVarNames.
	^instVars indexOf: name ifAbsent: 0
]

{ #category : #private }
SpeciesMirror >> instBehavior [
	| name |
	name := self getInstVarNamed: #instanceBehavior.
	^name asBehaviorMirror
]

{ #category : #'behavior protocol' }
SpeciesMirror >> instSize [
	"optimize: 
	self isPointers
		ifTrue: [	(self getInstVarNamed: #format) asLocalInteger & InstSize ]
		ifFalse: [ 0 ]"
	| vars s parents |
	vars := self getInstVarNamed: #instanceVariables.
	s := self superclass.
	parents := s reflectsNil ifTrue: [ 0 ] ifFalse: [ s instSize ].
	^parents + vars basicSize 
	
]

{ #category : #'behavior protocol' }
SpeciesMirror >> instVarNames [
	| instVars |
	instVars := self getInstVarNamed: #instanceVariables.
	instVars reflectsNil ifTrue: [^#()].
	^instVars reflectsBytesObject
		ifTrue: [instVars asLocalString substrings]
		ifFalse: [instVars asLocalArray collect: #asLocalString]
]

{ #category : #'behavior protocol' }
SpeciesMirror >> isPointers [
	^ (self getInstVarNamed: #format) asLocalInteger anyMask: self pointersFlag
]

{ #category : #private }
SpeciesMirror >> localName [
	^self subclassResponsibility 
]

{ #category : #private }
SpeciesMirror >> printOn: aStream [
	| name | 
	super printOn: aStream.
	name := [self localName] on: Error do: ['Broken'].
	aStream nextPutAll: '[' , name , ']'
]

{ #category : #private }
SpeciesMirror >> project [
	^nil
]

{ #category : #accessing }
SpeciesMirror >> reflectsMetaclass [
	| metasize |
	metasize := 6.
	^handle size = metasize
]

{ #category : #private }
SpeciesMirror >> structureType [
	^#Species
]

{ #category : #private }
SpeciesMirror >> superclass [
	| name |
	name := self getInstVarNamed: #superclass.
	^name asSpeciesMirror
]

{ #category : #private }
SpeciesMirror >> withAllSuperclasses [
	^ OrderedCollection new
		add: self;
		addAll: self allSuperclasses; yourself
]
