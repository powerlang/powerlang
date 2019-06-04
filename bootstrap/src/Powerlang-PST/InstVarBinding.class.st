Class {
	#name : #InstVarBinding,
	#superclass : #Binding,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
InstVarBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeInstVar
]

{ #category : #accessing }
InstVarBinding >> index [
	^ index
]

{ #category : #accessing }
InstVarBinding >> index: anInteger [
	index := anInteger
]

{ #category : #testing }
InstVarBinding >> isInstanceVariable [
	^true
]

{ #category : #testing }
InstVarBinding >> printOn: aStream [
	aStream
		nextPutAll: 'InstVarId. ';
		nextPutAll: index printString
]
