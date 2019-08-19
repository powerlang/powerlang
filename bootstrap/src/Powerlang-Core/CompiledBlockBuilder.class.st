Class {
	#name : #CompiledBlockBuilder,
	#superclass : #Object,
	#instVars : [
		'scope',
		'node'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
CompiledBlockBuilder >> argumentDescriptors [
	| parent |
	parent := node parent.
	^scope capturedArguments
		collect: [:arg | self descriptorForArgument: arg parent: parent]
]
