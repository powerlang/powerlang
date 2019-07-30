Class {
	#name : #AssociationBinding,
	#superclass : #Binding,
	#instVars : [
		'association'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
AssociationBinding class >> on: anAssociation [
	^self new association: anAssociation
]

{ #category : #testing }
AssociationBinding class >> usesSymbols [
	^false
]

{ #category : #accessing }
AssociationBinding >> association [
	^association
]

{ #category : #accessing }
AssociationBinding >> association: anAssociation [
	association := anAssociation.
	name := anAssociation key
]

{ #category : #accessing }
AssociationBinding >> literal [
	^association
]
