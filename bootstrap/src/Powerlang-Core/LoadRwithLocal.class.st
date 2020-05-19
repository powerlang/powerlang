Class {
	#name : #LoadRwithLocal,
	#superclass : #LoadROpcode,
	#instVars : [
		'index',
		'environment'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadRwithLocal class >> decodeUsing: anAstcodeDecoder [
	^self new
		index: anAstcodeDecoder nextInteger;
		environment: anAstcodeDecoder nextInteger
]

{ #category : #accessing }
LoadRwithLocal >> environment: anInteger [
	environment := anInteger
]

{ #category : #accessing }
LoadRwithLocal >> index: anInteger [
	index := anInteger
]
