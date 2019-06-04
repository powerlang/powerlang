Class {
	#name : #LiteralBinding,
	#superclass : #Binding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
LiteralBinding class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #testing }
LiteralBinding >> isLiteral [
	^true
]
