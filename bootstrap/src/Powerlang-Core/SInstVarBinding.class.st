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
