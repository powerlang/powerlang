Class {
	#name : #ArgumentBinding,
	#superclass : #LocalBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
ArgumentBinding >> assign: aValue within: anInterpreter [
	^ self error: 'arguments cannot be assigned'
]

{ #category : #testing }
ArgumentBinding >> isArgument [
	^true

]
