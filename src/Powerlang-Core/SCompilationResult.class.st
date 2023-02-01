Class {
	#name : #SCompilationResult,
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
SCompilationResult >> ast [
	^ast
]

{ #category : #accessing }
SCompilationResult >> ast: aParseNode [
	ast := aParseNode
]

{ #category : #errors }
SCompilationResult >> beSuccessful [
	error := nil
]

{ #category : #accessing }
SCompilationResult >> compiler: aSmalltalkCompiler [
	compiler := aSmalltalkCompiler
]

{ #category : #errors }
SCompilationResult >> error [
	^error
]

{ #category : #errors }
SCompilationResult >> error: aCompilationError [
	error := aCompilationError
]

{ #category : #accessing }
SCompilationResult >> method [
	^method
]

{ #category : #accessing }
SCompilationResult >> method: aCompiledMethod [
	method := aCompiledMethod
]
