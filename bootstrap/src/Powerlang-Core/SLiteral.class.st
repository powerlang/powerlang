Class {
	#name : #SLiteral,
	#superclass : #SExpression,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
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
SLiteral >> nativizeUsing: anAssembler for: messageNativizer [
	anAssembler loadRwithPointer: value _oop; holdReferenceTo: value
]

{ #category : #printing }
SLiteral >> printOn: aStream indent: anInteger [
	aStream
		tab: anInteger;
		nextPutAll: 'Literal ';
		print: value
]

{ #category : #evaluating }
SLiteral >> value [
	^value
]

{ #category : #evaluating }
SLiteral >> value: anObject [
	value := anObject
]
