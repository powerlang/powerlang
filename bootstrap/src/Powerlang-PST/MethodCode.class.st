Class {
	#name : #MethodCode,
	#superclass : #ScriptCode,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #testing }
MethodCode >> isMethod [
	^true
]

{ #category : #testing }
MethodCode >> printOn: aStream [
	aStream nextPutAll: '{MethodId. '.
	super printOn: aStream.
	aStream nextPutAll: '}'
]
