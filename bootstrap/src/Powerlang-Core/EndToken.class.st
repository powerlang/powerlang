Class {
	#name : #EndToken,
	#superclass : #Token,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
EndToken >> isEnd [
	^true
]

{ #category : #accessing }
EndToken >> position: aNumber [
	super position: aNumber - 1
]

{ #category : #evaluating }
EndToken >> value: aString [
	''
]
