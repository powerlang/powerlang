Class {
	#name : #InstVarBinding,
	#superclass : #Binding,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
InstVarBinding class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeInstVar
]

{ #category : #testing }
InstVarBinding >> assign: aValue within: anInterpreter [
	^ anInterpreter receiver _gate setInstVarAt: index with: aValue
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
InstVarBinding >> isInstVar [
	^true
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
