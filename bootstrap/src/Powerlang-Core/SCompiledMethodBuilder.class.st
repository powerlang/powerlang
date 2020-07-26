Class {
	#name : #SCompiledMethodBuilder,
	#superclass : #Object,
	#instVars : [
		'ast',
		'literals'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
SCompiledMethodBuilder >> addLiteral: anObject [
	literals addIfNotPresent: anObject
]

{ #category : #accessing }
SCompiledMethodBuilder >> ast [
	^ ast
]

{ #category : #accessing }
SCompiledMethodBuilder >> ast: aMethodNode [
	ast := aMethodNode
]

{ #category : #accessing }
SCompiledMethodBuilder >> initialize [
	literals := OrderedCollection new
]

{ #category : #accessing }
SCompiledMethodBuilder >> literals [
	^ literals
]
