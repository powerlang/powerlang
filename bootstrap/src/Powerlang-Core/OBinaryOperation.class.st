"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #OBinaryOperation,
	#superclass : #OPrimitiveOperation,
	#instVars : [
		'left',
		'right'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OBinaryOperation class >> left: left right: right name: selector [
	^self new
		left: left;
		right: right;
		name: selector
]

{ #category : #unclassified }
OBinaryOperation >> atOperand: named [
	^named == #left ifTrue: [left] ifFalse: [right]
]

{ #category : #unclassified }
OBinaryOperation >> atOperand: operandName put: instruction [
	operandName = #left
		ifTrue: [left := instruction]
		ifFalse: [right := instruction]
]

{ #category : #unclassified }
OBinaryOperation >> canHaveSideEffects [
	^false
]

{ #category : #unclassified }
OBinaryOperation >> invertOperation [
	name == #'<' ifTrue: [^name := #'>'].
	name == #'<=' ifTrue: [^name := #'>='].
	name == #'>' ifTrue: [^name := #'<'].
	name == #'>=' ifTrue: [^name := #'<='].
	name == #'==' ifTrue: [^name].
	self halt
]

{ #category : #unclassified }
OBinaryOperation >> left [
	^left
]

{ #category : #unclassified }
OBinaryOperation >> left: anInstruction [
	left := anInstruction
]

{ #category : #unclassified }
OBinaryOperation >> negateOperation [
	name == #'<' ifTrue: [^name := #'>='].
	name == #'<=' ifTrue: [^name := #'>'].
	name == #'>' ifTrue: [^name := #'<='].
	name == #'>=' ifTrue: [name := #'<']
]

{ #category : #unclassified }
OBinaryOperation >> right [
	^right
]

{ #category : #unclassified }
OBinaryOperation >> right: anInstruction [
	right := anInstruction
]

{ #category : #unclassified }
OBinaryOperation >> swapOperands [
	| temp |
	left removeUse: self.
	right removeUse: self.
	temp := left.
	left := right.
	right := temp.
	left addUse: self at: #left.
	right addUse: self at: #right
]

{ #category : #unclassified }
OBinaryOperation >> usesResultOf: anInstruction [
	^left == anInstruction or: [right == anInstruction]
]
