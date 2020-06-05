Class {
	#name : #Compiler,
	#superclass : #Object,
	#instVars : [
		'errorHandler',
		'result',
		'class',
		'pools',
		'namespace'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #services }
Compiler class >> compile: aString in: aClass [
	| compiler |
	compiler := self forClass: aClass.
	^compiler compile: aString
]

{ #category : #'instance creation' }
Compiler class >> forClass: aClass [
	^self new forClass: aClass
]

{ #category : #services }
Compiler class >> namespace: aDictionary [
	^self basicNew initialize: aDictionary
]

{ #category : #'instance creation' }
Compiler class >> new [
	^self namespace: Smalltalk globals
]

{ #category : #services }
Compiler class >> parse: aString in: aClass [
	| compiler |
	compiler := self forClass: aClass.
	^compiler parse: aString
]

{ #category : #initialization }
Compiler >> addPool: aPoolDictionary [
	| dict |
	dict := DynamicBinder on: aPoolDictionary.
	pools add: dict

]

{ #category : #initialization }
Compiler >> addPool: aDictionary of: type [
	| dict |
	dict := DynamicBinder on: aDictionary of: type.
	pools add: dict
]

{ #category : #testing }
Compiler >> canBeInIdentifier: aCharacter [
	^aCharacter isLetter or: [aCharacter isDigit] or: [aCharacter = $_]
]

{ #category : #testing }
Compiler >> canStartIdentifier: aCharacter [
	^aCharacter isLetter or: [aCharacter = $_]
]

{ #category : #initialization }
Compiler >> classBinding: aSpecies [
	| instance |
	class := aSpecies.
	instance := aSpecies instanceSide.
	(instance respondsTo: #configureCompiler)
		ifTrue: [instance configureCompiler: self]
]

{ #category : #services }
Compiler >> compile: aString [
	result := self smalltalkCompiler compileMethod: aString.
	^result method
]

{ #category : #private }
Compiler >> forClass: aClass [
	| c |
	c := aClass ifNil: [UndefinedObject].
	self classBinding: c
]

{ #category : #initialization }
Compiler >> initialize: aDictionary [
	super initialize.
	namespace := aDictionary.
	class := aDictionary at: #UndefinedObject ifAbsent: nil.
	pools := OrderedCollection new.
]

{ #category : #initialization }
Compiler >> namespace: aDictionary [
	namespace := aDictionary
]

{ #category : #initialization }
Compiler >> newScope [
	^MethodScope new
		namespace: namespace;
		species: class;
		addPoolBinders: pools

]

{ #category : #services }
Compiler >> parse: aString [
	result := self smalltalkCompiler parseMethod: aString.
	^result ast
]

{ #category : #testing }
Compiler >> peekForIdentifier: aStream [
	| char next |
	char := aStream peek.
	(self canBeInIdentifier: char) ifTrue: [
		aStream skip: 1.
		^true].
	char = $. ifFalse: [^false].
	aStream prev isLetter ifFalse: [
		aStream skip: 1.
		^false].
	next := aStream skip: 2; peek.
	next isNil ifTrue: [
		aStream skip: -1.
		^false].
	^next isLetter ifFalse: [aStream skip: -1]; yourself
]

{ #category : #testing }
Compiler >> protect: aBlock [
	^aBlock value
]

{ #category : #services }
Compiler >> smalltalkCompiler [
	^ SmalltalkCompiler new frontend: self
]

{ #category : #services }
Compiler >> smalltalkParser [
	^ self smalltalkCompiler parser
]

{ #category : #services }
Compiler >> smalltalkScanner [
	^ self smalltalkCompiler scanner
]
