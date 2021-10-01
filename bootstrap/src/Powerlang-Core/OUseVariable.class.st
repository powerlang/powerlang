"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OUseVariable,
	#superclass : #OInstruction,
	#instVars : [
		'binding'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OUseVariable >> binding [
	^binding
]

{ #category : #unclassified }
OUseVariable >> binding: aBinding [
	binding := aBinding
]
