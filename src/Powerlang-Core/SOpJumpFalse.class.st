Class {
	#name : #SOpJumpFalse,
	#superclass : #SOpJump,
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #visiting }
SOpJumpFalse >> acceptVisitor: visitor [
	^ visitor visitOpJumpFalse: self
]
