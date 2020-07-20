Class {
	#name : #UnresolvedBinding,
	#superclass : #Binding,
	#classVars : [
		'Default'
	],
	#category : #'Powerlang-Core-SCompiler-Bindings'
}

{ #category : #accessing }
UnresolvedBinding class >> default [
	^Default ifNil: [Default := self new name: '<unresolved>']
]

{ #category : #testing }
UnresolvedBinding >> isUnresolved [
	^true
]
