"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OptimizingMethodInliner,
	#superclass : #Object,
	#instVars : [
		'environment',
		'firstBlock'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #unclassified }
OptimizingMethodInliner >> bindVariablesOf: initialBlock with: aMessageSend [
	| values |
	values := OrderedCollection
		with: aMessageSend receiver
		withAll: aMessageSend arguments.
	initialBlock instructionsDo: [:instruction | 
		instruction isDefineArgument ifFalse: [^self].
		instruction name == #activationRecord ifFalse: [
			instruction replaceAllUsesWith: values first.
			values removeFirst].
		instruction dissolve]
]

{ #category : #unclassified }
OptimizingMethodInliner >> environment: aNativizationEnvironment [
	environment:= aNativizationEnvironment
]

{ #category : #unclassified }
OptimizingMethodInliner >> firstBlock: aBasicBlock [
	firstBlock := aBasicBlock
]

{ #category : #unclassified }
OptimizingMethodInliner >> inlineAllMessages [
	firstBlock withSuccessorsPostOrder do: [:block | | current |
		current := block.
		block instructionsAsCollection do: [:instruction | 
			(self shouldInline: instruction)
				ifTrue: [current := self inlineMethod: instruction in: current]]]
]

{ #category : #unclassified }
OptimizingMethodInliner >> inlineMethod: aMessageSend in: block [
	| method nativizer initialBlock |
	method := self inlinedMethodFor: aMessageSend.
	nativizer := OptimizingNativizer new environment: environment; method: method.
	initialBlock := nativizer
		decompose;
		firstBlock.
	self bindVariablesOf: initialBlock with: aMessageSend.
	^ block inline: initialBlock replacing: aMessageSend
]

{ #category : #unclassified }
OptimizingMethodInliner >> inlinedMethodFor: aMessageSend [
	^environment inlinedMethods detect: [ :m | m selector == aMessageSend selector ]
]

{ #category : #unclassified }
OptimizingMethodInliner >> shouldInline: instruction [
	^ instruction isMessageSend
		and: [ environment shouldInline: instruction selector ]
]
