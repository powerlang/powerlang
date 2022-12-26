Class {
	#name : #PSharedPool,
	#superclass : #SharedPool,
	#category : #'Powerlang-Compatibility-SmalltalkX'
}

{ #category : #accessing }
PSharedPool class >> asArray [
	^ Array streamContents: [:s | self do:[:e | s nextPut: e]]
]

{ #category : #accessing }
PSharedPool class >> detect: aOneArgBlock ifNone: exceptionValue [
	self do:[:each | 
		(aOneArgBlock value:each) ifTrue:[^ each].
	].
	^ exceptionValue value    
]
