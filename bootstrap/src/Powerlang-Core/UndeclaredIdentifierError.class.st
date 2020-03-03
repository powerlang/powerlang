Class {
	#name : #UndeclaredIdentifierError,
	#superclass : #CompilationError,
	#instVars : [
		'identifier',
		'assigned'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'accessing-token' }
UndeclaredIdentifierError >> assignment: aBoolean [
	assigned := aBoolean
]
