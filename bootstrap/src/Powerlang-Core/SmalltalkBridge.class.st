Class {
	#name : #SmalltalkBridge,
	#superclass : #Bridge,
	#instVars : [
		'nilObj',
		'trueObj',
		'falseObj'
	],
	#category : #'Powerlang-Core-Metaphysics'
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
SmalltalkBridge >> findRootObjects [
	self subclassResponsibility

]

{ #category : #initialization }
SmalltalkBridge >> kernel [
	^ self
		objectNamed: #kernel
		ifAbsent: [ self
				update;
				objectNamed: #kernel ]
]

{ #category : #initialization }
SmalltalkBridge >> nil [
	^nilObj
]

{ #category : #initialization }
SmalltalkBridge >> true [
	^trueObj
]

{ #category : #initialization }
SmalltalkBridge >> update [
	self
		findRootObjects
]
