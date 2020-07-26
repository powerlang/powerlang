Class {
	#name : #SCompiledBlockBuilder,
	#superclass : #Object,
	#instVars : [
		'scope',
		'node'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
SCompiledBlockBuilder >> argumentDescriptors [
	| parent |
	parent := node parent.
	^scope capturedArguments
		collect: [:arg | self descriptorForArgument: arg parent: parent]
]
