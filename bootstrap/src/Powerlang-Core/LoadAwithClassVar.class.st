Class {
	#name : #LoadAwithClassVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'association'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithClassVar class >> decodeUsing: anAstcodeDecoder [
	| association |
	association := anAstcodeDecoder
		classVarAt: anAstcodeDecoder nextInteger.
	^ self new association: association
]

{ #category : #accessing }
LoadAwithClassVar >> association: anAssociation [
	association := anAssociation 
]

{ #category : #accessing }
LoadAwithClassVar >> nativizeUsing: anAssembler [
	anAssembler
		loadAwithPointer: association;
		loadAwithAindex: 2
]
