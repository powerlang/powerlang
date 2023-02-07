Class {
	#name : #SCascadeMessageNode,
	#superclass : #SMessageNode,
	#instVars : [
		'cascade'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SCascadeMessageNode >> acceptVisitor: visitor [
	^visitor visitCascadeMessage: self
]

{ #category : #accessing }
SCascadeMessageNode >> cascade: aCascadeNode [
	cascade := aCascadeNode.
	receiver := cascade receiver
]

{ #category : #private }
SCascadeMessageNode >> from: aMessageNode [
	arguments := aMessageNode arguments.
	receiver := aMessageNode receiver.
	selector := aMessageNode selector.
	inlined := aMessageNode isInlined.
	stretch := aMessageNode stretch.
	comments := aMessageNode comments
]

{ #category : #testing }
SCascadeMessageNode >> isCascadeMessage [
	^true
]

{ #category : #enumerating }
SCascadeMessageNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	aBlock value: self.
	arguments do: [:arg | arg nodesDo: aBlock includingDeclarations: aBoolean]
]
