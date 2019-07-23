Class {
	#name : #NilBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
NilBinding >> printOn: aStream [
	aStream nextPutAll: 'NilId'
]

{ #category : #evaluating }
NilBinding >> value [
	^nil
]
