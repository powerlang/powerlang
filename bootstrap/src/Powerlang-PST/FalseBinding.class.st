Class {
	#name : #FalseBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #printing }
FalseBinding >> printOn: aStream [
	aStream nextPutAll: 'FalseId'
]

{ #category : #evaluating }
FalseBinding >> value [
	^false
]
