Class {
	#name : #GlobalBinding,
	#superclass : #AssociationBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #private }
GlobalBinding class >> on: anAssociation [
	| class |
	class := anAssociation value isSpecies
		ifTrue: [ClassBinding]
		ifFalse: [GlobalBinding].
	^class new association: anAssociation
]

{ #category : #testing }
GlobalBinding class >> usesSymbols [
	^true
]

{ #category : #testing }
GlobalBinding >> encodeUsing: anAstcodeEncoder [
	association value isClass ifTrue:[
		anAstcodeEncoder encodeClassBinding: association.
		^self
	].
	self notYetImplemented 
]

{ #category : #testing }
GlobalBinding >> isGlobal [
	^true
]
