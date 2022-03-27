Class {
	#name : #SDynamicBinding,
	#superclass : #SBinding,
	#instVars : [
		'name',
		'cache'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #unclassified }
SDynamicBinding class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeDynamicVar
]

{ #category : #accessing }
SDynamicBinding >> assign: value within: evaluator [
	cache ifNil: [ self lookupWithin: evaluator ].
	cache assign: value within: evaluator
]

{ #category : #accessing }
SDynamicBinding >> isDynamic [
	^true
]

{ #category : #accessing }
SDynamicBinding >> lookupWithin: evaluator [
	cache := evaluator staticBindingFor: name
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
	cache ifNil: [ self lookupWithin: evaluator ].
	^ cache valueWithin: evaluator
]
