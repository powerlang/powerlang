Class {
	#name : #AssociationMirror,
	#superclass : #ObjectMirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #'as yet unclassified' }
AssociationMirror >> key [
	^self getInstVarNamed: #key
]

{ #category : #private }
AssociationMirror >> structureType [
	^#Association
]

{ #category : #'as yet unclassified' }
AssociationMirror >> value [
	^self getInstVarNamed: #value
]
