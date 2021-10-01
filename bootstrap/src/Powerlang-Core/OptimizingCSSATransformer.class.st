"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OptimizingCSSATransformer,
	#superclass : #Object,
	#instVars : [
		'firstBlock',
		'liveness'
	],
	#category : #'Powerlang-Core-OCompiler'
}

{ #category : #accessing }
OptimizingCSSATransformer >> applyTransformation [
	self splitPhis; coalescePhis
]

{ #category : #accessing }
OptimizingCSSATransformer >> coalescePhis [
	"
	to do
	"
	
]

{ #category : #accessing }
OptimizingCSSATransformer >> firstBlock: block [
	firstBlock := block
]

{ #category : #accessing }
OptimizingCSSATransformer >> liftPhisIn: block [
	block phisDo: [:phi | 
		phi variablesWithBlocksDo: [:var :pred | | copy |
			copy := var insertCopyBefore: pred lastInstruction.
			phi atOperand: pred put: copy.
			var removeUse: phi at: pred; dissolveIfUnused.
			copy addUse: phi at: pred]]
]

{ #category : #accessing }
OptimizingCSSATransformer >> splitPhis [
	firstBlock withSuccessorsPostOrder do: [:block | self liftPhisIn: block]
]
