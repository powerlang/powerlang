Class {
	#name : #SLiteralNode,
	#superclass : #SParseNode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
SLiteralNode >> acceptVisitor: visitor [
	^visitor visitLiteral: self
]

{ #category : #private }
SLiteralNode >> beSymbol [
	value := value asSymbol
]

{ #category : #testing }
SLiteralNode >> hasSymbol [
	^value isSymbol
]

{ #category : #testing }
SLiteralNode >> isEvaluable [
	^true
]

{ #category : #testing }
SLiteralNode >> isImmediate [
	^true
]

{ #category : #testing }
SLiteralNode >> isLiteral [
	^true
]

{ #category : #evaluating }
SLiteralNode >> value [
	^value
]

{ #category : #evaluating }
SLiteralNode >> value: anObject [
	value := anObject
]
