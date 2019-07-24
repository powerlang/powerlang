Class {
	#name : #Compiler,
	#superclass : #Object,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
Compiler >> canBeInIdentifier: aCharacter [
	^aCharacter isLetter or: [aCharacter isDigit] or: [aCharacter = $_]
]

{ #category : #testing }
Compiler >> canStartIdentifier: aCharacter [
	^aCharacter isLetter or: [aCharacter = $_]
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

{ #category : #services }
Compiler >> smalltalkCompiler [
	^ SmalltalkCompiler new frontend: self
]
