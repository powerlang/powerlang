"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OLoadImplicit,
	#superclass : #OInstruction,
	#instVars : [
		'name',
		'source'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OLoadImplicit class >> named: aSymbol [
	^self new name: aSymbol
]

{ #category : #unclassified }
OLoadImplicit class >> self [
	^self new name: #self
]

{ #category : #unclassified }
OLoadImplicit >> atOperand: operandName put: instruction [
	source := instruction
]

{ #category : #unclassified }
OLoadImplicit >> basicAcceptVisitor: aVisitor [
	^aVisitor visitLoadImplicit: self
]

{ #category : #unclassified }
OLoadImplicit >> basicPrintString [
	^'[load implicit #' , name printString , ']'
]

{ #category : #unclassified }
OLoadImplicit >> isLoadImplicit [
	^true
]

{ #category : #unclassified }
OLoadImplicit >> name [
	^name
]

{ #category : #unclassified }
OLoadImplicit >> name: aSymbol [
	name := aSymbol
]

{ #category : #unclassified }
OLoadImplicit >> operandsDo: aBlock [
	source isInstruction ifTrue: [aBlock value: source]
]

{ #category : #unclassified }
OLoadImplicit >> primitivePrintString [
	"
	^'<#' , source value printString , '>'
	"
	^'{#' , name printString , '}'
]

{ #category : #unclassified }
OLoadImplicit >> printStringUsing: names [
	^'#' , name printString
]

{ #category : #unclassified }
OLoadImplicit >> source [
	^source
]

{ #category : #unclassified }
OLoadImplicit >> source: operand [
	source := operand
]

{ #category : #unclassified }
OLoadImplicit >> usesResultOf: anInstruction [
	^false
]
