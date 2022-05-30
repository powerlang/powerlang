Class {
	#name : #SArgumentBinding,
	#superclass : #SLocalBinding,
	#instVars : [
		'inlined'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SArgumentBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeArgument
]

{ #category : #testing }
SArgumentBinding >> assign: value within: anEvaluationContext [
	self halt
]

{ #category : #testing }
SArgumentBinding >> isArgument [
	^true
]

{ #category : #testing }
SArgumentBinding >> isInlined [
	^ environment = -1
]

{ #category : #testing }
SArgumentBinding >> printOn: aStream [
	aStream
		nextPutAll: 'SArgument ';
		print: position;
		nextPutAll: ' @ env ';
		print: environment
]

{ #category : #testing }
SArgumentBinding >> valueWithin: anEvaluationContext [
	^ anEvaluationContext argumentAt: position in: environment
]
