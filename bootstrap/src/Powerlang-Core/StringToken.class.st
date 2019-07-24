Class {
	#name : #StringToken,
	#superclass : #SymbolicToken,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
StringToken >> hasSymbol [
	^value isSymbol
]

{ #category : #testing }
StringToken >> isBinary [
	^value isSymbol
]

{ #category : #testing }
StringToken >> isKeyword [
	^value last = $:
]

{ #category : #testing }
StringToken >> isNameToken [
	^(self isKeyword or: [self isBinary]) not
]
