Class {
	#name : #LiteralBinding,
	#superclass : #Binding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
LiteralBinding class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #testing }
LiteralBinding >> isLiteral [
	^true
]
