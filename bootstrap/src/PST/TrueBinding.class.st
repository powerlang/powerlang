Class {
	#name : #TrueBinding,
	#superclass : #LiteralBinding,
	#category : #'PST-Compiling'
}

{ #category : #printing }
TrueBinding >> printOn: aStream [
	aStream nextPutAll: 'TrueId'
]

{ #category : #evaluating }
TrueBinding >> value [
	^true
]
