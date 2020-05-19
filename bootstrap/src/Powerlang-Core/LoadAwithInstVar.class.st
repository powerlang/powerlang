Class {
	#name : #LoadAwithInstVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithInstVar class >> decodeUsing: anAstcodeDecoder [
	^self new index: anAstcodeDecoder nextInteger
]

{ #category : #accessing }
LoadAwithInstVar >> index: anInteger [
	index := anInteger
]

{ #category : #accessing }
LoadAwithInstVar >> nativizeUsing: anAssembler [
	anAssembler loadAwithSindex: index
]
