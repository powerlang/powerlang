Class {
	#name : #StringNode,
	#superclass : #LiteralNode,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
StringNode >> acceptVisitor: visitor [
	^visitor visitString: self
]
