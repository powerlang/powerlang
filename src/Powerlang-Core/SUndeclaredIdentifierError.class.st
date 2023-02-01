Class {
	#name : #SUndeclaredIdentifierError,
	#superclass : #SCompilationError,
	#instVars : [
		'identifier',
		'assigned'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'accessing-token' }
SUndeclaredIdentifierError >> assignment: aBoolean [
	assigned := aBoolean
]

{ #category : #testing }
SUndeclaredIdentifierError >> identifier [
	^ identifier
]

{ #category : #testing }
SUndeclaredIdentifierError >> isUndeclaredAccess [
	^assigned not
]

{ #category : #testing }
SUndeclaredIdentifierError >> isUndeclaredAssignment [
	^assigned
]

{ #category : #testing }
SUndeclaredIdentifierError >> stretch: aStretch [
	super stretch: aStretch.
	identifier := self source
]
