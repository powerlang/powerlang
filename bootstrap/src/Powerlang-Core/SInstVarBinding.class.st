Class {
	#name : #SInstVarBinding,
	#superclass : #SBinding,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SInstVarBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeInstVar
]

{ #category : #testing }
SInstVarBinding >> assign: value within: evaluator [
	evaluator instVarAt: index put: value
]

{ #category : #accessing }
SInstVarBinding >> index [
	^index
]

{ #category : #accessing }
SInstVarBinding >> index: anInteger [
	index := anInteger
]

{ #category : #testing }
SInstVarBinding >> isInstVar [
	^true
]

{ #category : #testing }
SInstVarBinding >> printOn: aStream [
	aStream nextPutAll: 'InstVarId. '; nextPutAll: index printString
]

{ #category : #accessing }
SInstVarBinding >> valueWithin: evaluator [
	^evaluator instVarAt: index
]
