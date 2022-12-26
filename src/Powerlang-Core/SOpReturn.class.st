Class {
	#name : #SOpReturn,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpReturn >> acceptVisitor: visitor [
	^ visitor visitOpReturn: self
]
