Class {
	#name : #LiteralNode,
	#superclass : #ParseNode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #private }
LiteralNode >> beSymbol [
	value := value asSymbol
]

{ #category : #testing }
LiteralNode >> hasSymbol [
	^value isSymbol
]

{ #category : #testing }
LiteralNode >> isLiteral [
	^true
]

{ #category : #evaluating }
LiteralNode >> value [
	^value
]

{ #category : #evaluating }
LiteralNode >> value: anObject [
	value := anObject
]
