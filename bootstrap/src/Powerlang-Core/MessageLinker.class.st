Class {
	#name : #MessageLinker,
	#superclass : #Object,
	#instVars : [
		'filter'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #testing }
MessageLinker >> canInline: aSymbol [
	filter ifNil: [ ^true ].
	filter == aSymbol ifTrue: [ ^true ].
	^(filter includes: aSymbol)
]

{ #category : #testing }
MessageLinker >> filter: anObject [
	filter := anObject
]
