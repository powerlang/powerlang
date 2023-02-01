Class {
	#name : #SSymbolicToken,
	#superclass : #SToken,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #testing }
SSymbolicToken >> is: anObject [
	^value == anObject
]

{ #category : #accessing }
SSymbolicToken >> value [
	^value
]

{ #category : #accessing }
SSymbolicToken >> value: anObject [
	value := anObject
]
