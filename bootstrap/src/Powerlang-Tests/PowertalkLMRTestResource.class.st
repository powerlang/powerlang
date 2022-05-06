Class {
	#name : #PowertalkLMRTestResource,
	#superclass : #TestResource,
	#instVars : [
		'runtime'
	],
	#category : #'Powerlang-Tests-Bootstrap'
}

{ #category : #running }
PowertalkLMRTestResource >> runtime [ ^
	runtime 
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
