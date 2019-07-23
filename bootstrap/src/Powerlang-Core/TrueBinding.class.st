Class {
	#name : #TrueBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
TrueBinding >> printOn: aStream [
	aStream nextPutAll: 'TrueId'
]

{ #category : #evaluating }
TrueBinding >> value [
	^true
]
