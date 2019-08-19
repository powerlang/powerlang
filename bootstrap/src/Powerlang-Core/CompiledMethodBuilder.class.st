Class {
	#name : #CompiledMethodBuilder,
	#superclass : #Object,
	#instVars : [
		'ast',
		'literals'
	],
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #accessing }
CompiledMethodBuilder >> addLiteral: anObject [
	literals addIfNotPresent: anObject
]

{ #category : #accessing }
CompiledMethodBuilder >> ast [
	^ ast
]

{ #category : #accessing }
CompiledMethodBuilder >> ast: aMethodNode [
	ast := aMethodNode
]

{ #category : #accessing }
CompiledMethodBuilder >> initialize [
	literals := OrderedCollection new
]

{ #category : #accessing }
CompiledMethodBuilder >> literals [
	^ literals
]
