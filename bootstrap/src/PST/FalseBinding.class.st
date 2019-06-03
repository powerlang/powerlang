Class {
	#name : #FalseBinding,
	#superclass : #LiteralBinding,
	#category : #'PST-Compiling'
}

{ #category : #printing }
FalseBinding >> printOn: aStream [
	aStream nextPutAll: 'FalseId'
]

{ #category : #evaluating }
FalseBinding >> value [
	^false
]
