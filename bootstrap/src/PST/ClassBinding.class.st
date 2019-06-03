Class {
	#name : #ClassBinding,
	#superclass : #GlobalBinding,
	#category : #'PST-Compiling'
}

{ #category : #printing }
ClassBinding >> printOn: aStream [
	aStream nextPutAll: 'ClassBindingId'
]
