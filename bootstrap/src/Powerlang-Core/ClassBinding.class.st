Class {
	#name : #ClassBinding,
	#superclass : #GlobalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
ClassBinding >> printOn: aStream [
	aStream nextPutAll: 'ClassBindingId'
]
