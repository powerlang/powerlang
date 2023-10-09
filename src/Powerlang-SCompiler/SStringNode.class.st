Class {
	#name : #SStringNode,
	#superclass : #SLiteralNode,
	#category : #'Powerlang-SCompiler-Parser'
}

{ #category : #visiting }
SStringNode >> acceptVisitor: visitor [
	^visitor visitString: self
]
