Class {
	#name : #SStringToken,
	#superclass : #SSymbolicToken,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #converting }
SStringToken >> asIdentifierNode [
	^compiler identifierNode
		name: value;
		stretch: stretch;
		comments: comments
]

{ #category : #converting }
SStringToken >> asSelectorNode [
	^compiler selectorNode symbol: value; stretch: stretch
]

{ #category : #testing }
SStringToken >> hasSymbol [
	^value isSymbol
]

{ #category : #testing }
SStringToken >> isBinary [
	^value isSymbol
]

{ #category : #testing }
SStringToken >> isDelimitedIdentifier [
	^value first = ${
]

{ #category : #testing }
SStringToken >> isKeyword [
	^value last = $:
]

{ #category : #testing }
SStringToken >> isNameToken [
	^(self isKeyword or: [self isBinary]) not
]

{ #category : #converting }
SStringToken >> isStringToken [
	^true
]
