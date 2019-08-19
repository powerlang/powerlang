Class {
	#name : #True,
	#superclass : #Boolean,
	#category : #Kernel
}


{ #category : #'flow control' }
True >> ifTrue: aBlock ifFalse: anotherBlock [
	^aBlock value
]

