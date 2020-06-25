"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OTiling,
	#superclass : #Object,
	#instVars : [
		'action',
		'cost',
		'used',
		'instruction'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OTiling class >> for: instruction [
	^self new instruction: instruction
]

{ #category : #unclassified }
OTiling class >> new [
	^self basicNew initialize
]

{ #category : #unclassified }
OTiling >> beUsed [
	used := true
]

{ #category : #unclassified }
OTiling >> initialize [
	used := false
]

{ #category : #unclassified }
OTiling >> instruction [
	^instruction
]

{ #category : #unclassified }
OTiling >> instruction: anInstruction [
	instruction := anInstruction
]

{ #category : #unclassified }
OTiling >> isUsed [
	^used = true
]

{ #category : #unclassified }
OTiling >> printOn: aStream [
	aStream nextPutAll: self printString
]

{ #category : #unclassified }
OTiling >> printString [
	^'<tiling of ' , instruction printString , ' >'
]
