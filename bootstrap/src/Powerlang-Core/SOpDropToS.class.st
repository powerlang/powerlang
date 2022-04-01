Class {
	#name : #SOpDropToS,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpDropToS >> acceptVisitor: visitor [
	^ visitor visitOpDropToS: self
]
