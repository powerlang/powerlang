Class {
	#name : #SCascadeMessage,
	#superclass : #SExpression,
	#instVars : [
		'selector',
		'arguments'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SCascadeMessage class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeCascadeMessage
]

{ #category : #accessing }
SCascadeMessage >> arguments [
	^arguments
]

{ #category : #accessing }
SCascadeMessage >> arguments: aCollection [
	arguments := aCollection
]

{ #category : #accessing }
SCascadeMessage >> isCascadeMessage [
	^true
]

{ #category : #accessing }
SCascadeMessage >> selector [
	^selector
]

{ #category : #accessing }
SCascadeMessage >> selector: aSymbol [
	selector := aSymbol
]
