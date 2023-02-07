Class {
	#name : #SEndToken,
	#superclass : #SToken,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
SEndToken >> isEnd [
	^true
]

{ #category : #accessing }
SEndToken >> position: aNumber [
	super position: aNumber - 1
]

{ #category : #accessing }
SEndToken >> prevPosition [
	^stretch start
]

{ #category : #evaluating }
SEndToken >> value: aString [
	''
]
