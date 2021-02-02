Class {
	#name : #EmulationLookup,
	#superclass : #MethodLookup,
	#instVars : [
		'spec',
		'globals',
		'cache'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
EmulationLookup class >> new [
	"return an initialized instance"

	^ self basicNew initialize.

]

{ #category : #accessing }
EmulationLookup >> compile: anRGMethod [
	| compiler method |
	compiler := SCompiler namespace: globals.
	method := compiler
		forClass: anRGMethod parent;
		compile: anRGMethod sourceCode.
	^ method
]

{ #category : #accessing }
EmulationLookup >> compiledMethodFor: anRGMethod [
	| method |
	cache at: anRGMethod ifPresent: [ :cm | ^ cm ].
	method := self compile: anRGMethod.
	^ cache at: anRGMethod put: method
]

{ #category : #accessing }
EmulationLookup >> globals: aPoolDictionary [
	globals := aPoolDictionary
]

{ #category : #accessing }
EmulationLookup >> initialize [
	cache := Dictionary new
]

{ #category : #accessing }
EmulationLookup >> lookup: aSymbol on: aSubject [
	| behavior classname |
	classname := aSubject _gate handle oid classname.
	behavior := spec at: classname.
	^ self lookup: aSymbol startingAt: behavior
]

{ #category : #accessing }
EmulationLookup >> lookup: aSymbol startingAt: aBehavior [
	| next m c |
	next := aBehavior.
	[ m := next methodNamed: aSymbol.
	m ifNotNil: [ ^ self compiledMethodFor: m ].
	next := next superclass.
	next notNil ] whileTrue.
	^ aBehavior isMeta
		ifTrue: [ c := aBehavior environment at: #Class.
			self lookup: aSymbol startingAt: c ]
]

{ #category : #accessing }
EmulationLookup >> lookupSuper: aSymbol on: aSubject from: classname [
	| behavior |
	cache at: classname -> aSymbol ifPresent: [ :cached | ^ cached ].
	behavior := spec at: classname.
	^ self lookup: aSymbol startingAt: behavior
]

{ #category : #accessing }
EmulationLookup >> spec [
	^spec
]

{ #category : #accessing }
EmulationLookup >> spec: anRGEnvironment [
	spec := anRGEnvironment
]
