Class {
	#name : #SClassBinding,
	#superclass : #SGlobalBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SClassBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeClassBinding
]
