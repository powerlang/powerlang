Class {
	#name : #CompilationResult,
	#superclass : #Object,
	#instVars : [
		'compiler',
		'error',
		'ast',
		'method'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
CompilationResult >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler
]

{ #category : #errors }
CompilationResult >> error [
	^error
]

{ #category : #errors }
CompilationResult >> error: aCompilationError [
	error := aCompilationError
]
