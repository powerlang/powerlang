Class {
	#name : #SDynamicBinding,
	#superclass : #SBinding,
	#instVars : [
		'name'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SDynamicBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeDynamicVar
]

{ #category : #accessing }
SDynamicBinding >> assign: value within: evaluator [
	^ evaluator storeNamed: name asString with: value
]

{ #category : #accessing }
SDynamicBinding >> isDynamic [
	^true
]

{ #category : #accessing }
SDynamicBinding >> name [ ^
	name
]

{ #category : #accessing }
SDynamicBinding >> name: aSymbol [
	name := aSymbol
]

{ #category : #accessing }
SDynamicBinding >> printOn: aStream [
	aStream
		nextPutAll: 'DinamicVarId. ';
		nextPutAll: name printString
]

{ #category : #accessing }
SDynamicBinding >> valueWithin: evaluator [
	^evaluator loadNamed: name asString


]
