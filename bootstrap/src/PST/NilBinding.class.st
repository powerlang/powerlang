Class {
	#name : #NilBinding,
	#superclass : #LiteralBinding,
	#category : #'PST-Compiling'
}

{ #category : #printing }
NilBinding >> printOn: aStream [
	aStream nextPutAll: 'NilId'
]

{ #category : #evaluating }
NilBinding >> value [
	^nil
]
