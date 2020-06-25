"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OBlockClosure,
	#superclass : #OInstruction,
	#instVars : [
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OBlockClosure class >> containing: initialBlock [
	^self new firstBlock: initialBlock
]

{ #category : #unclassified }
OBlockClosure >> firstBlock [
	^firstBlock
]

{ #category : #unclassified }
OBlockClosure >> firstBlock: basicBlock [
	firstBlock := basicBlock
]

{ #category : #unclassified }
OBlockClosure >> lastBlock [
	^firstBlock lastBlock
]

{ #category : #unclassified }
OBlockClosure >> lastValue [
	^firstBlock lastBlock lastValue
]

{ #category : #private }
OBlockClosure >> operandsDo: aBlock [
	
]
