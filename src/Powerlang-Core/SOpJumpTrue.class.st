Class {
	#name : #SOpJumpTrue,
	#superclass : #SOpJump,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpJumpTrue >> acceptVisitor: visitor [
	^ visitor visitOpJumpTrue: self
]
