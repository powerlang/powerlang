Class {
	#name : #LoadRwithInstVar,
	#superclass : #LoadROpcode,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadRwithInstVar class >> decodeUsing: anAstcodeDecoder [
	^self new index: anAstcodeDecoder nextInteger
]

{ #category : #accessing }
LoadRwithInstVar >> nativizeUsing: anAssembler [
	anAssembler loadRwithSindex: index
]
