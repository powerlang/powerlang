Class {
	#name : #LoadAwithLocal,
	#superclass : #LoadAOpcode,
	#instVars : [
		'index',
		'environment'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithLocal class >> decodeUsing: anAstcodeDecoder [
	^self new
		index: anAstcodeDecoder nextInteger;
		environment: anAstcodeDecoder nextInteger
]

{ #category : #accessing }
LoadAwithLocal >> environment: anInteger [
	environment := anInteger
]

{ #category : #accessing }
LoadAwithLocal >> index: anInteger [
	index := anInteger
]
