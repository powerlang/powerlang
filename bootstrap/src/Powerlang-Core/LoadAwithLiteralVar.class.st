Class {
	#name : #LoadAwithLiteralVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithLiteralVar >> index [
	^index
]

{ #category : #accessing }
LoadAwithLiteralVar >> index: anInteger [
	index := anInteger
]
