Class {
	#name : #IdentifierNode,
	#superclass : #ParseNode,
	#instVars : [
		'name',
		'binding'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
IdentifierNode >> binding [
	^binding
]

{ #category : #accessing }
IdentifierNode >> binding: aBinding [
	binding := aBinding
]

{ #category : #testing }
IdentifierNode >> isIdentifier [
	^true
]

{ #category : #testing }
IdentifierNode >> isImmediate [
	^true
]

{ #category : #accessing }
IdentifierNode >> name [
	^name
]

{ #category : #evaluating }
IdentifierNode >> name: aString [
	name := aString reduced
]
