"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #Assembly,
	#superclass : #Object,
	#instVars : [
		'labels',
		'instructions',
		'source',
		'parser'
	],
	#category : #'Powerlang-Core-Assembly-Intel-Parser'
}

{ #category : #'instance creation' }
Assembly class >> new [
	^super new initialize
]

{ #category : #'instance creation' }
Assembly class >> on: aString [
	^self new source: aString
]

{ #category : #initialization }
Assembly >> initialize [
	super initialize.
	labels := Dictionary new.
	instructions := OrderedCollection new.
	parser := AssemblerParser new
]

{ #category : #accessing }
Assembly >> parse [
	| everything |
	everything := parser parse: source.
	everything do: [:token | 
		token isString
			ifTrue: [labels at: token allButLast put: instructions size]
			ifFalse: [instructions add: token]]
]

{ #category : #accessing }
Assembly >> parser: anAssemblerParser [
	parser := anAssemblerParser
]

{ #category : #accessing }
Assembly >> source: aString [
	source := aString
]
