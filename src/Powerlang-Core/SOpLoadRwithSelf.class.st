Class {
	#name : #SOpLoadRwithSelf,
	#superclass : #SOperation,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpLoadRwithSelf >> acceptVisitor: visitor [
	^ visitor visitOpLoadRwithSelf: self
]
