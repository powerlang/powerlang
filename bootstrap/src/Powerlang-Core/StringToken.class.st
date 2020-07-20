Class {
	#name : #StringToken,
	#superclass : #SymbolicToken,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #converting }
StringToken >> asIdentifierNode [
	^compiler identifierNode
		name: value;
		stretch: stretch;
		comments: comments
]

{ #category : #converting }
StringToken >> asSelectorNode [
	^compiler selectorNode symbol: value; stretch: stretch
]

{ #category : #testing }
StringToken >> hasSymbol [
	^value isSymbol
]

{ #category : #testing }
StringToken >> isBinary [
	^value isSymbol
]

{ #category : #testing }
StringToken >> isDelimitedIdentifier [
	^value first = ${
]

{ #category : #testing }
StringToken >> isKeyword [
	^value last = $:
]

{ #category : #testing }
StringToken >> isNameToken [
	^(self isKeyword or: [self isBinary]) not
]

{ #category : #converting }
StringToken >> isStringToken [
	^true
]
