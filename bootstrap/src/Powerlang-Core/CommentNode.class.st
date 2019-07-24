Class {
	#name : #CommentNode,
	#superclass : #ParseNode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
CommentNode >> isComment [
	^true
]

{ #category : #accessing }
CommentNode >> value [
	^value
]

{ #category : #accessing }
CommentNode >> value: aString [
	value := aString
]
