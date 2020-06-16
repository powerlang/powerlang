Class {
	#name : #LoadAwithLiteralVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithLiteralVar class >> decodeUsing: anAstcodeDecoder [
	 
	^ self new index: anAstcodeDecoder nextInteger
]

{ #category : #accessing }
LoadAwithLiteralVar >> index [
	^index
]

{ #category : #accessing }
LoadAwithLiteralVar >> index: anInteger [
	index := anInteger
]
