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
CompilationResult >> ast [
	^ast
]

{ #category : #accessing }
CompilationResult >> ast: aParseNode [
	ast := aParseNode
]

{ #category : #errors }
CompilationResult >> beSuccessful [
	error := nil
]

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

{ #category : #accessing }
CompilationResult >> method [
	^method
]

{ #category : #accessing }
CompilationResult >> method: aCompiledMethod [
	method := aCompiledMethod
]
