Class {
	#name : #ModuleSpec,
	#superclass : #Object,
	#instVars : [
		'name',
		'classes',
		'extendedClasses',
		'module'
	],
	#category : #'Powerlang-Core-Specification'
}

{ #category : #'instance creation' }
ModuleSpec class >> new [
	^super new initialize
]

{ #category : #accessing }
ModuleSpec >> addClass: aClass [
	| spec |
	spec := ClassSpec from: aClass in: self.
	classes at: aClass name put: spec.
	spec loadMethodsFrom: aClass
]

{ #category : #accessing }
ModuleSpec >> addClassExtension: aClass [
	| spec |
	spec := ClassSpec from: aClass in: self.
	^extendedClasses at: aClass name put: spec
]

{ #category : #accessing }
ModuleSpec >> addClasses: aCollection [
	aCollection do: [:c | self addClass: c]
]

{ #category : #accessing }
ModuleSpec >> addEmptyClass: aClass [
	| spec |
	spec := ClassSpec from: aClass in: self.
	classes at: aClass name put: spec
]

{ #category : #accessing }
ModuleSpec >> addMethod: aCompiledMethod [
	| spec original class |
	original := aCompiledMethod classBinding.
	class := self resolveClass: original name.
	class ifNil: [class := self addClassExtension: original].
	spec := MethodSpec from: aCompiledMethod in: self.
	^class addMethod: spec
]

{ #category : #accessing }
ModuleSpec >> addMethods: aCollection [
	aCollection do: [:m | self addMethod: m]
]

{ #category : #accessing }
ModuleSpec >> addSelectors: aCollection from: aSpecies [
	aCollection do: [:selector | self addMethod: aSpecies >> selector]
]

{ #category : #accessing }
ModuleSpec >> allClasses [
	^classes values, extendedClasses values
]

{ #category : #accessing }
ModuleSpec >> allMethodsDo: aBlock [
	self allClasses do: [:c | c methods do: aBlock]
]

{ #category : #accessing }
ModuleSpec >> at: aString [
	^classes at: aString
]

{ #category : #accessing }
ModuleSpec >> classes [
	^classes values
]

{ #category : #accessing }
ModuleSpec >> extendedClasses [
	^extendedClasses values
]

{ #category : #accessing }
ModuleSpec >> initialize [
	classes := OrderedDictionary new.
	extendedClasses := OrderedDictionary new.
	module := Smalltalk
]

{ #category : #accessing }
ModuleSpec >> module [
	^module
]

{ #category : #accessing }
ModuleSpec >> module: aSmalltalkSystem [
	module := aSmalltalkSystem
]

{ #category : #accessing }
ModuleSpec >> name [
	^name
]

{ #category : #accessing }
ModuleSpec >> name: aString [
	name := aString
]

{ #category : #accessing }
ModuleSpec >> resolveClass: aString [
	| classname |
	aString ifNil: [ ^nil ].
	(aString endsWith: ' class') ifTrue: [
		classname := aString copyTo: aString size - 6.
		^(self resolveClass: classname) metaclass].
	classes at: aString ifPresent: [:c | ^c].
	^extendedClasses at: aString ifAbsent: nil
]

{ #category : #accessing }
ModuleSpec >> resolveClass: aString ifAbsent: aBlock [
	^(self resolveClass: aString) ifNil: aBlock
]

{ #category : #accessing }
ModuleSpec >> withAllSubclasses: aClassSpec [
	^self allClasses select: [:c | c withAllSuperclasses includes: aClassSpec]
]
