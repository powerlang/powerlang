"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OVariable,
	#superclass : #Object,
	#instVars : [
		'binding'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OVariable class >> source: aParseNode [
	^self new binding: aParseNode binding
]

{ #category : #unclassified }
OVariable >> assureBoundBy: aVariableBinder [
	binding isPoolVariableBinding
		ifTrue: [^aVariableBinder bindPoolVariable: self with: binding].
	binding isTemporary
		ifTrue: [^aVariableBinder bindTemporary: self with: binding].
	(binding isLiteral or: [binding isPseudo])
		ifTrue: [^aVariableBinder bindSpecial: self with: binding].
	self halt
]

{ #category : #unclassified }
OVariable >> binding: aBinding [
	binding := aBinding
]

{ #category : #unclassified }
OVariable >> isConstant [
	^false
]
