"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OBinaryConstantOperation,
	#superclass : #OBinaryOperation,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OBinaryConstantOperation >> basicAcceptVisitor: aVisitor [
	^aVisitor visitBinaryWithConstant: self
]

{ #category : #unclassified }
OBinaryConstantOperation >> basicPrintString [
	^'[' , left primitivePrintString , ' ' , name , ' '
		, right primitivePrintString
		, ']'
]

{ #category : #unclassified }
OBinaryConstantOperation >> isBinaryConstantOperation [
	^true
]

{ #category : #unclassified }
OBinaryConstantOperation >> operandsDo: aBlock [
	aBlock value: left
]

{ #category : #unclassified }
OBinaryConstantOperation >> printStringUsing: names [
	^(names at: left ifAbsent: 'missing') , ' ' , name , ' ' , right printString
]
