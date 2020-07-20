Class {
	#name : #StringNode,
	#superclass : #LiteralNode,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
StringNode >> acceptVisitor: visitor [
	^visitor visitString: self
]
