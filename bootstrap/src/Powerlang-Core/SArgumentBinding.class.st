Class {
	#name : #SArgumentBinding,
	#superclass : #SLocalBinding,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SArgumentBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeArgument
]

{ #category : #testing }
SArgumentBinding >> isArgument [
	^true
]
