Class {
	#name : #PragmaNode,
	#superclass : #ParseNode,
	#instVars : [
		'type',
		'name',
		'info'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
PragmaNode >> acceptVisitor: aVisitor [
	self isFFI ifTrue: [^aVisitor visitFFIPragma: self].
	self isPrimitive ifTrue: [^aVisitor visitPrimitivePragma: self].
	self isSymbolic ifTrue: [^aVisitor visitSymbolicPragma: self]
]

{ #category : #'as yet unclassified' }
PragmaNode >> isPrimitive [
	^type = #primitive
]

{ #category : #'as yet unclassified' }
PragmaNode >> isUsed [
	^type notNil
]

{ #category : #'as yet unclassified' }
PragmaNode >> name [
	^name
]

{ #category : #'as yet unclassified' }
PragmaNode >> primitive: anInteger name: aString [
	type := #primitive.
	name := aString.
	info := anInteger
]
