"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OUnaryOperation,
	#superclass : #OPrimitiveOperation,
	#instVars : [
		'receiver'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OUnaryOperation class >> receiver: receiver name: aString [
	^self new name: aString; receiver: receiver
]

{ #category : #unclassified }
OUnaryOperation >> atOperand: operandName [
	^receiver
]

{ #category : #unclassified }
OUnaryOperation >> atOperand: operandName put: instruction [
	receiver := instruction
]

{ #category : #unclassified }
OUnaryOperation >> basicAcceptVisitor: aVisitor [
	^aVisitor visitUnary: self
]

{ #category : #unclassified }
OUnaryOperation >> basicPrintString [
	^'['
		, (receiver isInstruction
			ifTrue: [receiver primitivePrintString]
			ifFalse: [receiver printString]) , ' ' , name , ']'
]

{ #category : #unclassified }
OUnaryOperation >> isUnaryOperation [
	^true
]

{ #category : #unclassified }
OUnaryOperation >> operandsDo: aBlock [
	aBlock value: receiver
]

{ #category : #unclassified }
OUnaryOperation >> printStringUsing: names [
	^(receiver isInstruction
		ifTrue: [names at: receiver ifAbsent: ['{missing ', receiver printString, '}']]
		ifFalse: [receiver printString]) , ' ' , name
]

{ #category : #unclassified }
OUnaryOperation >> receiver [
	^receiver
]

{ #category : #unclassified }
OUnaryOperation >> receiver: operation [
	receiver := operation
]

{ #category : #unclassified }
OUnaryOperation >> usesResultOf: anInstruction [
	^receiver == anInstruction
]
