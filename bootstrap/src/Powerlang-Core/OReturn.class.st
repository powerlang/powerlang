"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OReturn,
	#superclass : #OInstruction,
	#instVars : [
		'source',
		'frame',
		'argumentsCount'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OReturn >> argumentsCount [
	^argumentsCount
]

{ #category : #unclassified }
OReturn >> argumentsCount: anInteger [
	argumentsCount := anInteger
]

{ #category : #unclassified }
OReturn >> atOperand: name [
	^name == #source ifTrue: [source] ifFalse: [frame]
]

{ #category : #unclassified }
OReturn >> atOperand: name put: instruction [
	^name == #source
		ifTrue: [source := instruction]
		ifFalse: [frame := instruction]
]

{ #category : #unclassified }
OReturn >> basicAcceptVisitor: aVisitor [
	^aVisitor visitReturn: self
]

{ #category : #unclassified }
OReturn >> basicPrintString [
	^'[ret ' , source primitivePrintString , ']'
]

{ #category : #unclassified }
OReturn >> frame: anInstruction [
	frame := anInstruction
]

{ #category : #unclassified }
OReturn >> isReturn [
	^true
]

{ #category : #unclassified }
OReturn >> operandsDo: aBlock [
	aBlock value: source.
	aBlock value: frame
]

{ #category : #unclassified }
OReturn >> primitivePrintString [
	^'{ret}'
]

{ #category : #unclassified }
OReturn >> printStringUsing: names [
	^'ret ' , (names at: source ifAbsent: 'missing') , ''
]

{ #category : #unclassified }
OReturn >> source [
	^source
]

{ #category : #unclassified }
OReturn >> source: anInstruction [
	source := anInstruction
]

{ #category : #unclassified }
OReturn >> usesResultOf: anInstruction [
	^source == anInstruction or: [frame == anInstruction]
]
