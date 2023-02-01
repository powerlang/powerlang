Class {
	#name : #ClassMirror,
	#superclass : #SpeciesMirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #accessing }
ClassMirror >> classVariables [
	| classVariables |
	classVariables := self getInstVarNamed: #classVariables.
	classVariables reflectsNil ifTrue: [^Dictionary new].
	^classVariables
]

{ #category : #accessing }
ClassMirror >> instanceClass [
	^self
]

{ #category : #'as yet unclassified' }
ClassMirror >> localEquivalent [
	^handle runtime objectModel at: self localName asSymbol
]

{ #category : #accessing }
ClassMirror >> localName [
	^self name asLocalString
]

{ #category : #accessing }
ClassMirror >> name [
	| name |
	name := self getInstVarNamed: #name.
	^name asStringMirror
]

{ #category : #private }
ClassMirror >> structureType [
	^#Class
]

{ #category : #accessing }
ClassMirror >> subclasses [
	| subclasses |
	subclasses := self getInstVarNamed: #subclasses.
	^subclasses reflectsNil ifTrue: [Array new] ifFalse: [subclasses]
]
