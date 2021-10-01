"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OOperand,
	#superclass : #Object,
	#instVars : [
		'instruction',
		'name',
		'nextUse'
	],
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OOperand class >> at: anInstruction named: operandName [
	^self new instruction: anInstruction; name: operandName
]

{ #category : #unclassified }
OOperand class >> valued: anInstruction [
	^self new value: anInstruction
]

{ #category : #unclassified }
OOperand class >> valued: anInstruction in: containingInstruction [
	^self new value: anInstruction; instruction: containingInstruction
]

{ #category : #unclassified }
OOperand >> addUse: anOperand [
	self DENY: self == anOperand.
	nextUse ifNil: [nextUse := anOperand] ifNotNil: [nextUse addUse: anOperand]
]

{ #category : #unclassified }
OOperand >> asOperand [
	self halt
]

{ #category : #unclassified }
OOperand >> definition [
	^instruction atOperand: name
]

{ #category : #unclassified }
OOperand >> disolveReplacingWith: otherInstruction [
	self definition removeUse: instruction.
	instruction atOperand: name put: otherInstruction.
	otherInstruction addUse: instruction at: name
]

{ #category : #unclassified }
OOperand >> instruction [
	^instruction
]

{ #category : #unclassified }
OOperand >> instruction: anInstruction [
	instruction := anInstruction
]

{ #category : #unclassified }
OOperand >> name [
	^name
]

{ #category : #unclassified }
OOperand >> name: operandName [
	name := operandName
]

{ #category : #unclassified }
OOperand >> nextUse [
	^nextUse
]

{ #category : #unclassified }
OOperand >> printOn: aStream [
	aStream
		nextPutAll: '[op #' , name printString , '@' , instruction printString
			, ']'
]

{ #category : #unclassified }
OOperand >> removeUse: anInstruction [
	nextUse instruction == anInstruction
		ifTrue: [nextUse := nextUse nextUse]
		ifFalse: [nextUse removeUse: anInstruction]
]

{ #category : #unclassified }
OOperand >> removeUse: anInstruction at: aName [
	(nextUse instruction == anInstruction and: [nextUse name = aName])
		ifTrue: [nextUse := nextUse nextUse]
		ifFalse: [nextUse removeUse: anInstruction at: aName]
]

{ #category : #unclassified }
OOperand >> replaceAllUsesWith: otherInstruction [
	self replaceUseWith: otherInstruction.
	nextUse ifNotNil: [nextUse replaceAllUsesWith: otherInstruction]
]

{ #category : #unclassified }
OOperand >> replaceUseWith: otherInstruction [
	self DENY: otherInstruction class == OOperand.
	instruction atOperand: name put: otherInstruction
]

{ #category : #unclassified }
OOperand >> user [
	^instruction
]

{ #category : #unclassified }
OOperand >> usesDo: aBlock [
	aBlock value: self.
	nextUse ifNotNil: [nextUse usesDo: aBlock]
]
