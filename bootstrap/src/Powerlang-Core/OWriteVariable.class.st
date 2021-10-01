"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OWriteVariable,
	#superclass : #OUseVariable,
	#instVars : [
		'source'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OWriteVariable class >> binding: aBinding valued: operation [
	^self new binding: aBinding; source: operation
]

{ #category : #unclassified }
OWriteVariable >> atOperand: name put: instruction [
	source := instruction
]

{ #category : #unclassified }
OWriteVariable >> basicAcceptVisitor: aVisitor [
	^aVisitor visitWriteVariable: self
]

{ #category : #unclassified }
OWriteVariable >> basicPrintString [
	| sourceString |
	sourceString := source isInstruction
		ifTrue: [source primitivePrintString]
		ifFalse: [self halt].
	^'[write ' , self name printString , ' with ' , sourceString , ' ]'
]

{ #category : #unclassified }
OWriteVariable >> isStoreVariable [
	^true
]

{ #category : #unclassified }
OWriteVariable >> name [
	^binding name
]

{ #category : #unclassified }
OWriteVariable >> operandsDo: aBlock [
	aBlock value: source
]

{ #category : #unclassified }
OWriteVariable >> primitivePrintString [
	^'{write ' , self name printString , ' }'
]

{ #category : #unclassified }
OWriteVariable >> printStringUsing: names [
	| sourceString |
	sourceString := source isInstruction
		ifTrue: [names at: source]
		ifFalse: [self halt].
	^'write ' , self name printString , ' with ' , sourceString
]

{ #category : #unclassified }
OWriteVariable >> source [
	^source
]

{ #category : #unclassified }
OWriteVariable >> source: operation [
	source := operation
]

{ #category : #unclassified }
OWriteVariable >> usesResultOf: anOperand [
	^source == anOperand
]
