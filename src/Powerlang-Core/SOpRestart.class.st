Class {
	#name : #SOpRestart,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpRestart >> acceptVisitor: visitor [
	^ visitor visitOpRestart: self
]
