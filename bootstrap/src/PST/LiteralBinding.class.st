Class {
	#name : #LiteralBinding,
	#superclass : #Binding,
	#category : #'PST-Compiling'
}

{ #category : #'as yet unclassified' }
LiteralBinding class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #testing }
LiteralBinding >> isLiteral [
	^true
]
