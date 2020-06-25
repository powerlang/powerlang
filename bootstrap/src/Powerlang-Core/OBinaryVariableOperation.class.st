"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OBinaryVariableOperation,
	#superclass : #OBinaryOperation,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OBinaryVariableOperation >> basicAcceptVisitor: aVisitor [
	^aVisitor visitBinaryWithVariable: self
]

{ #category : #unclassified }
OBinaryVariableOperation >> basicPrintString [
	^'[' , left primitivePrintString , ' ' , name , ' '
		, right primitivePrintString
		, ']'
]

{ #category : #unclassified }
OBinaryVariableOperation >> isBinaryVariableOperation [
	^true
]

{ #category : #unclassified }
OBinaryVariableOperation >> operandsDo: aBlock [
	aBlock value: left.
	aBlock value: right
]

{ #category : #unclassified }
OBinaryVariableOperation >> printStringUsing: names [
	^(names at: left ifAbsent: 'missing') , ' ' , name , ' ' , (names at: right)
]
