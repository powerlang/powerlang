Class {
	#name : #SOpNonLocalReturn,
	#superclass : #SOpReturn,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpNonLocalReturn >> acceptVisitor: visitor [
	^ visitor visitOpNonLocalReturn: self
]
