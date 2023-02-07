Class {
	#name : #SPragma,
	#superclass : #SExpression,
	#instVars : [
		'name'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SPragma >> name [
	^ name
]

{ #category : #accessing }
SPragma >> name: aString [
	name := aString
]
