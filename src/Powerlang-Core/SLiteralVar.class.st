Class {
	#name : #SLiteralVar,
	#superclass : #SExpression,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SLiteralVar >> index [
	^index
]

{ #category : #accessing }
SLiteralVar >> index: anInteger [
	index := anInteger
]
