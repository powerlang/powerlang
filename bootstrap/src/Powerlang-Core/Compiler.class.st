Class {
	#name : #Compiler,
	#superclass : #Object,
	#instVars : [
		'errorHandler',
		'result',
		'class',
		'pools'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
Compiler class >> forClass: aClass [
	^self new forClass: aClass
]

{ #category : #services }
Compiler class >> parse: aString in: aClass [
	| compiler |
	compiler := self forClass: aClass.
	^compiler parse: aString
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
	class := aSpecies.
	aSpecies instanceSide configureCompiler: self
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
Compiler >> initialize [
	super initialize.
	class := UndefinedObject.
	pools := OrderedCollection new.
]

{ #category : #initialization }
Compiler >> newScope [
	class isNil ifTrue: [class := UndefinedObject].
	^MethodScope new species: class; addPoolBinders: pools
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
