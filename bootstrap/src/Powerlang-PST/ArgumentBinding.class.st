Class {
	#name : #ArgumentBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #testing }
ArgumentBinding >> assign: aValue within: anInterpreter [
	^ self error: 'arguments cannot be assigned'
]

{ #category : #testing }
ArgumentBinding >> isArgument [
	^true

]
