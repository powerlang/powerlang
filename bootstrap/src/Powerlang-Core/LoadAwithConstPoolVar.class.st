Class {
	#name : #LoadAwithConstPoolVar,
	#superclass : #LoadAOpcode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #accessing }
LoadAwithConstPoolVar >> nativizeUsing: anAssembler [
	anAssembler
		loadAwithPointer: value
]

{ #category : #accessing }
LoadAwithConstPoolVar >> value: anObject [
	value := anObject
]
