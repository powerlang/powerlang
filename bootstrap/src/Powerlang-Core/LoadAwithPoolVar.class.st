Class {
	#name : #LoadAwithPoolVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'association'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithPoolVar >> association: anAssociation [
	association := anAssociation
]

{ #category : #accessing }
LoadAwithPoolVar >> nativizeUsing: anAssembler [
	anAssembler
		loadAwithPointer: association;
		loadAwithAindex: 1
]
