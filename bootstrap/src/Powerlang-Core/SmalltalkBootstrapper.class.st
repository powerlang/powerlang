Class {
	#name : #SmalltalkBootstrapper,
	#superclass : #Object,
	#instVars : [
		'target',
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

{ #category : #accessing }
SmalltalkBootstrapper >> target [
	^ target
]

{ #category : #initialization }
SmalltalkBootstrapper >> target:aNativizationTarget [
	self ASSERT: target isNil.
	self ASSERT: aNativizationTarget notNil.

	target := aNativizationTarget.
]
