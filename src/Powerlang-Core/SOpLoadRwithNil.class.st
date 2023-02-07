Class {
	#name : #SOpLoadRwithNil,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpLoadRwithNil >> acceptVisitor: visitor [
	^ visitor visitOpLoadRwithNil: self
]
