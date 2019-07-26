Class {
	#name : #STrueBinding,
	#superclass : #SLiteralBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #printing }
STrueBinding >> printOn: aStream [
	aStream nextPutAll: 'TrueId'
]

{ #category : #printing }
STrueBinding >> value [
	^true
]
