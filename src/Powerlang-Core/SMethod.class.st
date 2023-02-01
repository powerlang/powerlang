Class {
	#name : #SMethod,
	#superclass : #SScript,
	#instVars : [
		'pragma'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SMethod >> acceptVisitor: visitor [
	^visitor visitMethod: self
]

{ #category : #testing }
SMethod >> isMethod [
	^true
]

{ #category : #printing }
SMethod >> offsetOfCurrentEnvironment [
	^ 0
]

{ #category : #printing }
SMethod >> offsetOfEnvironment: anInteger [
	^0
]

{ #category : #printing }
SMethod >> pragma [
	^pragma
]

{ #category : #printing }
SMethod >> pragma: anSPragma [
	pragma := anSPragma
]

{ #category : #printing }
SMethod >> primitive [
	^pragma ifNotNil: [ pragma name ]
]

{ #category : #printing }
SMethod >> printOn: aStream indent: anInteger [
	aStream nextPutAll: '{MethodId. '; cr.
	pragma ifNotNil: [ (pragma isKindOf: SExpression) ifTrue: [ pragma printOn: aStream indent: anInteger + 1] ifFalse: [ aStream tab: anInteger + 1; print: pragma ] ].
	super printOn: aStream indent: anInteger.
	aStream nextPutAll: '}'
]
