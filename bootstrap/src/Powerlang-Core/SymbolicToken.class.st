Class {
	#name : #SymbolicToken,
	#superclass : #Token,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler'
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
