Class {
	#name : #SOpStoreRintoFrame,
	#superclass : #SInlinerOperation,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SOpStoreRintoFrame >> acceptVisitor: visitor [
	^ visitor visitOpStoreRintoFrame: self
]

{ #category : #accessing }
SOpStoreRintoFrame >> index [
	^ index
]

{ #category : #accessing }
SOpStoreRintoFrame >> index: anInteger [
	index := anInteger
]
