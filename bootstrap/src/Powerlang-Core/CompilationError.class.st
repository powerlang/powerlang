Class {
	#name : #CompilationError,
	#superclass : #Error,
	#instVars : [
		'compiler',
		'resumable',
		'retryable',
		'stretch'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
CompilationError >> beFatal [
	resumable := retryable := false
]

{ #category : #accessing }
CompilationError >> beResumable [
	resumable := true
]

{ #category : #accessing }
CompilationError >> compiler [
	^compiler
]

{ #category : #accessing }
CompilationError >> compiler: aCompiler [
	compiler := aCompiler.
	compiler result error: self
]

{ #category : #accessing }
CompilationError >> description: aString [
	messageText := aString
]

{ #category : #accessing }
CompilationError >> stretch [
	^stretch
]

{ #category : #accessing }
CompilationError >> stretch: aStretch [
	stretch := aStretch
]
