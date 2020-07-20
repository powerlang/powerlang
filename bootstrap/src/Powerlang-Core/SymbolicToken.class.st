Class {
	#name : #SymbolicToken,
	#superclass : #Token,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
SymbolicToken >> is: anObject [
	^value == anObject
]

{ #category : #accessing }
SymbolicToken >> value [
	^value
]

{ #category : #accessing }
SymbolicToken >> value: anObject [
	value := anObject
]
