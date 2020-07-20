Class {
	#name : #SPragmaNode,
	#superclass : #SToken,
	#instVars : [
		'type',
		'name',
		'info'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #'as yet unclassified' }
SPragmaNode >> acceptVisitor: aVisitor [
	self isFFI ifTrue: [^aVisitor visitFFIPragma: self].
	self isPrimitive ifTrue: [^aVisitor visitPrimitivePragma: self].
	self isSymbolic ifTrue: [^aVisitor visitSymbolicPragma: self]
]

{ #category : #'as yet unclassified' }
SPragmaNode >> isUsed [
	^type notNil
]

{ #category : #'as yet unclassified' }
SPragmaNode >> name [
	^name
]

{ #category : #'as yet unclassified' }
SPragmaNode >> primitive: anInteger name: aString [
	type := #primitive.
	name := aString.
	info := anInteger
]
