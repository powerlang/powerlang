Class {
	#name : #SLocalBinding,
	#superclass : #SBinding,
	#instVars : [
		'position',
		'environment'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #testing }
SLocalBinding >> environment [
	^environment
]

{ #category : #testing }
SLocalBinding >> environment: anInteger [
	environment := anInteger
]

{ #category : #testing }
SLocalBinding >> index [
	^position
]

{ #category : #testing }
SLocalBinding >> index: anInteger [
	position := anInteger
]

{ #category : #testing }
SLocalBinding >> isInStack [
	self ASSERT: false.
	^ environment = 0
]
