"
Copyright (c) 2020 Aucerna.
	See (MIT) license in root directory.
"
Class {
	#name : #OEndInstruction,
	#superclass : #OInstruction,
	#category : #'Powerlang-Core-OCompiler-IR'
}

{ #category : #unclassified }
OEndInstruction >> acceptVisitor: aVisitor [
	
]

{ #category : #unclassified }
OEndInstruction >> addLast: anInstruction [
	prev next: anInstruction.
	anInstruction prev: prev.
	anInstruction next: self.
	prev := anInstruction
]

{ #category : #unclassified }
OEndInstruction >> detect: aBlock ifNone: absentBlock [
	^absentBlock value
]

{ #category : #unclassified }
OEndInstruction >> do: aBlock [
	
]

{ #category : #unclassified }
OEndInstruction >> hasNext [
	^false
]

{ #category : #unclassified }
OEndInstruction >> isEnd [
	^true
]

{ #category : #unclassified }
OEndInstruction >> last [
	^prev
]

{ #category : #unclassified }
OEndInstruction >> printForwardOn: aStream [
	
]

{ #category : #unclassified }
OEndInstruction >> printForwardOn: aStream using: names [
	
]

{ #category : #unclassified }
OEndInstruction >> printOn: aStream [
	"
	prev printBackwardOn: aStream
	"
	
]

{ #category : #unclassified }
OEndInstruction >> replace: one with: other [
	
]

{ #category : #enumerating }
OEndInstruction >> reverseDo: aBlock [
	prev reverseDo: aBlock
]
