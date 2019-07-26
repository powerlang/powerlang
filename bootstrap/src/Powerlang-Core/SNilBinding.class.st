Class {
	#name : #SNilBinding,
	#superclass : #SLiteralBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #evaluating }
SNilBinding >> printOn: aStream [
	aStream nextPutAll: 'NilId'
]

{ #category : #evaluating }
SNilBinding >> value [
	^nil
]
