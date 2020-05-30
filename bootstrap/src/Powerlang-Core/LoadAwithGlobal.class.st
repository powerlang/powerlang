Class {
	#name : #LoadAwithGlobal,
	#superclass : #LoadAOpcode,
	#instVars : [
		'association'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithGlobal class >> decodeUsing: anAstcodeDecoder [
	| association |
	association := anAstcodeDecoder
		literalAt: anAstcodeDecoder nextInteger.
	^ self new association: association
]

{ #category : #accessing }
LoadAwithGlobal >> association: anAssociation [
	association := anAssociation 
]

{ #category : #accessing }
LoadAwithGlobal >> nativizeUsing: anAssembler [
	anAssembler
		loadAwithPointer: association;
		loadAwithAindex: 1
]
