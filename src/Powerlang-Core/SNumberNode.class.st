Class {
	#name : #SNumberNode,
	#superclass : #SLiteralNode,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SNumberNode >> acceptVisitor: visitor [
	^visitor visitNumberNode: self
]

{ #category : #testing }
SNumberNode >> isNumberNode [
	^true
]

{ #category : #accessing }
SNumberNode >> negate [
	value := value negated
]
