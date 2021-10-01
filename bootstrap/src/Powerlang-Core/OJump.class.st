"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OJump,
	#superclass : #OInstruction,
	#instVars : [
		'target'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OJump class >> to: aDestination [
	^self new target: aDestination
]

{ #category : #unclassified }
OJump >> basicAcceptVisitor: aVisitor [
	^aVisitor visitJump: self
]

{ #category : #unclassified }
OJump >> basicPrintString [
	^'[jump to ' , target name , ']'
]

{ #category : #unclassified }
OJump >> isJump [
	^true
]

{ #category : #private }
OJump >> operandsDo: aBlock [
	
]

{ #category : #unclassified }
OJump >> primitivePrintString [
	^'{jump}'
]

{ #category : #unclassified }
OJump >> printStringUsing: names [
	^'jump to ' , (names at: target)
]

{ #category : #unclassified }
OJump >> retargetFrom: aBasicBlock to: otherBasicBlock [
	target := otherBasicBlock
]

{ #category : #unclassified }
OJump >> target [
	^target
]

{ #category : #unclassified }
OJump >> target: aBasicBlock [
	target := aBasicBlock
]

{ #category : #unclassified }
OJump >> targets [
	^OrderedCollection with: target
]

{ #category : #unclassified }
OJump >> usesResultOf: anInstruction [
	^false
]
