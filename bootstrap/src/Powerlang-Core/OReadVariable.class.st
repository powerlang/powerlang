"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OReadVariable,
	#superclass : #OUseVariable,
	#instVars : [
		'source'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OReadVariable class >> binding: binding [
	^self new binding: binding
]

{ #category : #unclassified }
OReadVariable class >> source: identifier [
	^self new source: identifier
]

{ #category : #unclassified }
OReadVariable >> atOperand: name put: instruction [
	source := instruction
]

{ #category : #unclassified }
OReadVariable >> basicAcceptVisitor: aVisitor [
	^aVisitor visitReadVariable: self
]

{ #category : #unclassified }
OReadVariable >> basicPrintString [
	^ '[read var #'
		, (binding ifNil: [ '#error' ] ifNotNil: [ binding printString ]) , ']'
]

{ #category : #unclassified }
OReadVariable >> operandsDo: aBlock [
	source ifNotNil: [aBlock value: source]
]

{ #category : #unclassified }
OReadVariable >> primitivePrintString [
	^'{#' , (binding ifNil: ['#error'] ifNotNil: [binding printString]) , ' read}'
]

{ #category : #printing }
OReadVariable >> printStringUsing: names [
	^self basicPrintString
]

{ #category : #unclassified }
OReadVariable >> source [
	^source
]

{ #category : #unclassified }
OReadVariable >> source: anInstruction [
	source := anInstruction
]
