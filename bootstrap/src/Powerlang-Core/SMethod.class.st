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
	pragma ifNotNil: [ pragma printOn: aStream indent: anInteger + 1 ].
	super printOn: aStream indent: anInteger.
	aStream nextPutAll: '}'
]
