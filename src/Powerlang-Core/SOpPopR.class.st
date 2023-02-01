Class {
	#name : #SOpPopR,
	#superclass : #SInlinerOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpPopR >> acceptVisitor: visitor [
	^ visitor visitOpPopR: self
]
