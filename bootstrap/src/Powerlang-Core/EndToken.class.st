Class {
	#name : #EndToken,
	#superclass : #Token,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
EndToken >> isEnd [
	^true
]

{ #category : #accessing }
EndToken >> position: aNumber [
	super position: aNumber - 1
]

{ #category : #accessing }
EndToken >> prevPosition [
	^stretch start
]

{ #category : #evaluating }
EndToken >> value: aString [
	''
]
