Class {
	#name : #FalseBinding,
	#superclass : #LiteralBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #printing }
FalseBinding >> printOn: aStream [
	aStream nextPutAll: 'FalseId'
]

{ #category : #evaluating }
FalseBinding >> value [
	^false
]
