Class {
	#name : #SAssociationBinding,
	#superclass : #SBinding,
	#instVars : [
		'association'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SAssociationBinding >> association [
	^association
]

{ #category : #accessing }
SAssociationBinding >> association: anAssociation [
	association := anAssociation
]

{ #category : #testing }
SAssociationBinding >> isAssociation [
	^true
]
