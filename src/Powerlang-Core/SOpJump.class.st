Class {
	#name : #SOpJump,
	#superclass : #SInlinerOperation,
	#instVars : [
		'target'
	],
	#category : #'Powerlang-Core-SExpressions'
}

{ #category : #accessing }
SOpJump >> acceptVisitor: visitor [
	^ visitor visitOpJump: self
]

{ #category : #accessing }
SOpJump >> printOn: aStream [
	aStream nextPutAll: self class name withArticle; nextPutAll: ' after '; print: target
]

{ #category : #accessing }
SOpJump >> target [ 
	^target
]

{ #category : #accessing }
SOpJump >> target: anInteger [
	 target := anInteger
]
