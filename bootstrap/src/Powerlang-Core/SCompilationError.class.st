Class {
	#name : #SCompilationError,
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
SCompilationError >> beFatal [
	resumable := retryable := false
]

{ #category : #accessing }
SCompilationError >> beResumable [
	resumable := true
]

{ #category : #accessing }
SCompilationError >> beWarning [
	resumable := true
]

{ #category : #accessing }
SCompilationError >> compiler [
	^compiler
]

{ #category : #accessing }
SCompilationError >> compiler: aCompiler [
	compiler := aCompiler.
	compiler result error: self
]

{ #category : #accessing }
SCompilationError >> description: aString [
	messageText := aString
]

{ #category : #accessing }
SCompilationError >> isResumable [
	^resumable

]

{ #category : #testing }
SCompilationError >> isUndeclaredAccess [
	^false
]

{ #category : #testing }
SCompilationError >> isUndeclaredAssignment [
	^ false
]

{ #category : #accessing }
SCompilationError >> proceed [
	retryable := false.
	compiler result beSuccessful.
	self isResumable ifTrue: [ self resume ] ifFalse: [ self return ]
]

{ #category : #accessing }
SCompilationError >> source [
	^compiler sourceCode copyFrom: stretch start to: stretch end
]

{ #category : #accessing }
SCompilationError >> stretch [
	^stretch
]

{ #category : #accessing }
SCompilationError >> stretch: aStretch [
	stretch := aStretch
]
