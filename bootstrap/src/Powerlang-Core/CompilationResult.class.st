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
