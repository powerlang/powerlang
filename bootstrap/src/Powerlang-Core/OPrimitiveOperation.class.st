"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OPrimitiveOperation,
	#superclass : #OInstruction,
	#instVars : [
		'name'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OPrimitiveOperation >> basicPrintString [
	^self primitivePrintString
]

{ #category : #testing }
OPrimitiveOperation >> isPrimitiveOperation [
	^true
]

{ #category : #unclassified }
OPrimitiveOperation >> name [
	^name
]

{ #category : #unclassified }
OPrimitiveOperation >> name: selector [
	name := selector
]

{ #category : #unclassified }
OPrimitiveOperation >> primitivePrintString [
	^'{#' , name , '}'
]

{ #category : #unclassified }
OPrimitiveOperation >> printStringUsing: names [
	^self primitivePrintString
]
