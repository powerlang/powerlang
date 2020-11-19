Class {
	#name : #SmalltalkBootstrapper,
	#superclass : #Object,
	#instVars : [
		'builder'
	],
	#category : #'Powerlang-Core-Building'
}

{ #category : #accessing }
SmalltalkBootstrapper >> builder: anImageSegmentBuilder [
	builder := anImageSegmentBuilder
]

{ #category : #services }
SmalltalkBootstrapper >> compile: anRGMethod [ 
	^builder compile: anRGMethod
]

{ #category : #accessing }
SmalltalkBootstrapper >> spec [
	^builder image kernel
]
