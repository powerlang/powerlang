Class {
	#name : #SOpLoadRfromFrame,
	#superclass : #SInlinerOperation,
	#instVars : [
		'index'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SOpLoadRfromFrame >> acceptVisitor: visitor [
	^ visitor visitOpLoadRfromFrame: self
]

{ #category : #accessing }
SOpLoadRfromFrame >> index [
^	index
]

{ #category : #accessing }
SOpLoadRfromFrame >> index: anInteger [
	index := anInteger
]
