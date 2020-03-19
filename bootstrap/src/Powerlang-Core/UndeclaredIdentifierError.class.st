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

{ #category : #testing }
UndeclaredIdentifierError >> identifier [
	^ identifier
]

{ #category : #testing }
UndeclaredIdentifierError >> isUndeclaredAccess [
	^assigned not
]

{ #category : #testing }
UndeclaredIdentifierError >> isUndeclaredAssignment [
	^assigned
]

{ #category : #testing }
UndeclaredIdentifierError >> stretch: aStretch [
	super stretch: aStretch.
	identifier := self source
]
