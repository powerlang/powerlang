Class {
	#name : #EmulationLookup,
	#superclass : #Lookup,
	#instVars : [
		'spec',
		'globals',
		'cache'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #accessing }
EmulationLookup >> compile: anRGMethod [
	| compiler method |
	compiler := Compiler namespace: globals.
	method := compiler
		forClass: anRGMethod parent;
		compile: anRGMethod sourceCode.
	cache at: anRGMethod class -> anRGMethod selector put: method.
	^ method
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
	cache at: classname->aSymbol ifPresent: [ :cached | ^cached ].
	behavior := spec at: classname.
	^self lookup: aSymbol startingAt: behavior
]

{ #category : #accessing }
EmulationLookup >> lookup: aSymbol startingAt: aBehavior [
	| next m c |
	next := aBehavior.
	[ m := next methodNamed: aSymbol.
	m ifNotNil: [ ^ self compile: m ].
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
