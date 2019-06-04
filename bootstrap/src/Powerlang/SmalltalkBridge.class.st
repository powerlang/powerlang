Class {
	#name : #SmalltalkBridge,
	#superclass : #Bridge,
	#instVars : [
		'nilObj',
		'trueObj',
		'falseObj'
	],
	#category : #'Powerlang-Metaphysics'
}

{ #category : #'instance creation' }
SmalltalkBridge class >> new [
	^self basicNew initialize
]

{ #category : #initialization }
SmalltalkBridge >> false [
	^falseObj
]

{ #category : #initialization }
SmalltalkBridge >> findRootClasses [
	self subclassResponsibility

]

{ #category : #initialization }
SmalltalkBridge >> findRootObjects [
	self subclassResponsibility

]

{ #category : #initialization }
SmalltalkBridge >> findSmalltalk [
	self subclassResponsibility

]

{ #category : #initialization }
SmalltalkBridge >> nil [
	^nilObj
]

{ #category : #initialization }
SmalltalkBridge >> smalltalk [
	^self
		globalNamed: #Smalltalk
		ifAbsent: [self update; globalNamed: #Smalltalk]
]

{ #category : #initialization }
SmalltalkBridge >> true [
	^trueObj
]

{ #category : #initialization }
SmalltalkBridge >> update [
	self findRootObjects; findRootClasses; findSmalltalk
]
