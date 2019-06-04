Class {
	#name : #ClassBinding,
	#superclass : #GlobalBinding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #printing }
ClassBinding >> printOn: aStream [
	aStream nextPutAll: 'ClassBindingId'
]
