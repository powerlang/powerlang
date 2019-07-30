Class {
	#name : #NumberNode,
	#superclass : #LiteralNode,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #visiting }
NumberNode >> acceptVisitor: visitor [
	^visitor visitNumberNode: self
]

{ #category : #testing }
NumberNode >> isNumberNode [
	^true
]

{ #category : #accessing }
NumberNode >> negate [
	value := value negated
]
