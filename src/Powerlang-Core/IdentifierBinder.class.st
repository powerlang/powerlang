Class {
	#name : #IdentifierBinder,
	#superclass : #Object,
	#instVars : [
		'contents'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'instance creation' }
IdentifierBinder class >> new [
	^super new initialize
]

{ #category : #accessing }
IdentifierBinder >> contents [
	^contents
]

{ #category : #private }
IdentifierBinder >> keyFor: aString [
	^self subclassResponsibility
]

{ #category : #printing }
IdentifierBinder >> printOn: aStream [
	self printOn: aStream indent: 0
]

{ #category : #printing }
IdentifierBinder >> printOn: aStream indent: anInteger [
	self subclassResponsibility
]
