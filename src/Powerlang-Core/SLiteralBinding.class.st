Class {
	#name : #SLiteralBinding,
	#superclass : #SBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SLiteralBinding class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #testing }
SLiteralBinding >> isLiteral [
	^true
]
