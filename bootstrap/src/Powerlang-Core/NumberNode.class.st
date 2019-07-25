Class {
	#name : #NumberNode,
	#superclass : #LiteralNode,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
NumberNode >> isNumberNode [
	^true
]

{ #category : #accessing }
NumberNode >> negate [
	value := value negated
]
