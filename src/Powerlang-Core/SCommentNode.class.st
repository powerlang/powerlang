Class {
	#name : #SCommentNode,
	#superclass : #SParseNode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
SCommentNode >> isComment [
	^true
]

{ #category : #accessing }
SCommentNode >> value [
	^value
]

{ #category : #accessing }
SCommentNode >> value: aString [
	value := aString
]
