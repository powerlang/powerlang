Class {
	#name : #ObjectShape,
	#superclass : #Object,
	#instVars : [
		'name',
		'fields'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
ObjectShape class >> new [
	^self basicNew initialize
]

{ #category : #initialization }
ObjectShape >> indexOf: ivarName [
	^fields at: ivarName asString
]

{ #category : #initialization }
ObjectShape >> indexOf: ivarName be: i [
	fields at: ivarName put: i
]

{ #category : #initialization }
ObjectShape >> initialize [
	fields := Dictionary new
]

{ #category : #initialization }
ObjectShape >> loadFrom: aClassDefinition [
	name := aClassDefinition name asSymbol.
	aClassDefinition allInstVarNames
		withIndexDo: [:ivarName :i | self indexOf: ivarName be: i]
]

{ #category : #initialization }
ObjectShape >> name [
	^name
]

{ #category : #initialization }
ObjectShape >> printOn: aStream [
	aStream nextPutAll: 'Shape of '; nextPutAll: name
]
