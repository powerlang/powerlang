Class {
	#name : #ClosureMirror,
	#superclass : #ObjectMirror,
	#category : #'Powerlang-Core-Mirrors'
}

{ #category : #accessing }
ClosureMirror >> block [
	| block |
	block := self getInstVarNamed: #block.
	^ block asBlockMirror
]

{ #category : #accessing }
ClosureMirror >> structureType [
	^ #Closure
]
