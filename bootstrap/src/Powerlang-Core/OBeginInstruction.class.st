"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OBeginInstruction,
	#superclass : #OInstruction,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OBeginInstruction >> basicAcceptVisitor: aVisitor [
	
]

{ #category : #unclassified }
OBeginInstruction >> do: aBlock [
	next do: aBlock
]

{ #category : #unclassified }
OBeginInstruction >> hasPrev [
	^false
]

{ #category : #unclassified }
OBeginInstruction >> printBackwardOn: aStream [
	
]

{ #category : #printing }
OBeginInstruction >> printOn: aStream [
	aStream nextPutAll: '[' , self hash printString , '] '.
	next printForwardOn: aStream
]

{ #category : #printing }
OBeginInstruction >> printOn: aStream using: names [
	aStream nextPutAll: '[' , self basicHash printString , '] '.
	next printForwardOn: aStream using: names
]

{ #category : #printing }
OBeginInstruction >> printStringUsing: names [
	| stream |
	stream := '' writeStream.
	next printForwardOn: stream using: names.
	^stream contents
]

{ #category : #enumerating }
OBeginInstruction >> realReverseDo: aBlock [
	
]

{ #category : #enumerating }
OBeginInstruction >> reverseDo: aBlock [
	
]

{ #category : #unclassified }
OBeginInstruction >> usesResultOf: anInstruction [
	^false
]
