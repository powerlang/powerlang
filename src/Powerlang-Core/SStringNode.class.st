Class {
	#name : #SStringNode,
	#superclass : #SLiteralNode,
	#category : #'Powerlang-Core-SCompiler-Smalltalk-Parser'
}

{ #category : #visiting }
SStringNode >> acceptVisitor: visitor [
	^visitor visitString: self
]
