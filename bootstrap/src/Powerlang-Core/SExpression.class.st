"
I am a Smalltalk expression, the minimal unit of Smalltalk semantics, expressed as a tree
"
Class {
	#name : #SExpression,
	#superclass : #Object,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
SExpression >> acceptVisitor: visitor [
	^self subclassResponsibility
]

{ #category : #visiting }
SExpression >> printOn: aStream [
	self printOn: aStream indent: 0

]

{ #category : #visiting }
SExpression >> printOn: aStream indent: anInteger [
	super printOn: aStream
]
