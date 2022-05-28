Class {
	#name : #PowertalkLMRTestResource,
	#superclass : #TestResource,
	#instVars : [
		'image',
		'bootstrapper'
	],
	#category : #'Powerlang-Tests-Bootstrap'
}

{ #category : #running }
PowertalkLMRTestResource >> bootstrapper [
	^bootstrapper ifNil: [ bootstrapper := image generateLMR ]

]

{ #category : #running }
PowertalkLMRTestResource >> runtime [
	^ self bootstrapper result
]

{ #category : #running }
PowertalkLMRTestResource >> setUp [
	super setUp.
	runtime := PowertalkRingImage fromSpec
		wordSize: 8;
		genesis;
		bootstrap;
		fillClasses;
		fillSymbols;
		generateLMR
]
