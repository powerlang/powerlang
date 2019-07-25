Class {
	#name : #CascadeMessageNode,
	#superclass : #MessageNode,
	#instVars : [
		'cascade'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
CascadeMessageNode >> cascade: aCascadeNode [
	cascade := aCascadeNode.
	receiver := cascade receiver
]

{ #category : #private }
CascadeMessageNode >> from: aMessageNode [
	arguments := aMessageNode arguments.
	receiver := aMessageNode receiver.
	selector := aMessageNode selector.
	stretch := aMessageNode stretch.
	comments := aMessageNode comments
]

{ #category : #testing }
CascadeMessageNode >> isCascadeMessageNode [
	^true
]

{ #category : #enumerating }
CascadeMessageNode >> nodesDo: aBlock includingDeclarations: aBoolean [
	aBlock evaluateWith: self.
	arguments do: [:arg | arg nodesDo: aBlock includingDeclarations: aBoolean]
]
