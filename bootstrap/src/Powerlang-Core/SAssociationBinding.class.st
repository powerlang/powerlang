Class {
	#name : #SAssociationBinding,
	#superclass : #SBinding,
	#instVars : [
		'index',
		'association'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #testing }
SAssociationBinding >> assign: value within: evaluator [
	^evaluator association: association put: value
]

{ #category : #accessing }
SAssociationBinding >> association [
	^association
]

{ #category : #accessing }
SAssociationBinding >> association: anAssociation [
	association := anAssociation
]

{ #category : #testing }
SAssociationBinding >> index [ 
	^ index
]

{ #category : #testing }
SAssociationBinding >> index: anInteger [
	 index := anInteger 
]

{ #category : #testing }
SAssociationBinding >> isAssociation [
	^true
]

{ #category : #testing }
SAssociationBinding >> valueWithin: evaluator [
	^evaluator literal: association value
]
