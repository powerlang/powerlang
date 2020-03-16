Class {
	#name : #False,
	#superclass : #Boolean,
	#category : #Kernel
}


{ #category : #'flow control' }
False >> ifTrue: aBlock ifFalse: anotherBlock [
	^anotherBlock value
]

