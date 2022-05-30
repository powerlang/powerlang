Class {
	#name : #SOpPushR,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpPushR >> acceptVisitor: visitor [
	^ visitor visitOpPushR: self
]
