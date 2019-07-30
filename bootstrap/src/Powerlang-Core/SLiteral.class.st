Class {
	#name : #SLiteral,
	#superclass : #SExpression,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #initialization }
SLiteral class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeLiteral
]

{ #category : #visiting }
SLiteral >> acceptVisitor: visitor [
	^visitor visitLiteral: self
]

{ #category : #printing }
SLiteral >> encodeOn: aStream using: encoder [
	| index |
	index := encoder indexOf: value.
	aStream
		nextPutAll: '{LiteralId. ';
		print: index;
		nextPutAll: '}'
]

{ #category : #testing }
SLiteral >> isLiteral [
	^true
]

{ #category : #visiting }
SLiteral >> value [
	^value
]

{ #category : #visiting }
SLiteral >> value: anObject [
	value := anObject
]
