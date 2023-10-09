Class {
	#name : #SNumberNode,
	#superclass : #SLiteralNode,
	#category : #'Powerlang-SCompiler-Parser'
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
