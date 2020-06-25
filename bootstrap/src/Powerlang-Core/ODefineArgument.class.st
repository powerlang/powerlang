"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ODefineArgument,
	#superclass : #OInstruction,
	#instVars : [
		'name'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
ODefineArgument class >> named: aSymbol [
	^self new name: aSymbol
]

{ #category : #unclassified }
ODefineArgument >> basicAcceptVisitor: aVisitor [
	^aVisitor visitDefineArgument: self
]

{ #category : #unclassified }
ODefineArgument >> basicPrintString [
	^'[define arg ' , name , ']'
]

{ #category : #unclassified }
ODefineArgument >> isDefineArgument [
	^true
]

{ #category : #unclassified }
ODefineArgument >> name [
	^name
]

{ #category : #unclassified }
ODefineArgument >> name: aSymbol [
	name := aSymbol
]

{ #category : #unclassified }
ODefineArgument >> operandsDo: aBlock [
	
]

{ #category : #unclassified }
ODefineArgument >> primitivePrintString [
	^'{' , name , '}'
]

{ #category : #unclassified }
ODefineArgument >> printStringUsing: names [
	^'define arg ' , name
]
