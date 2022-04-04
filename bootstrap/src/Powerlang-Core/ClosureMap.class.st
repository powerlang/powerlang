Class {
	#name : #ClosureMap,
	#superclass : #SlotObjectMap,
	#instVars : [
		'block',
		'builder',
		'astcodes'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'instance creation' }
ClosureMap class >> classFor: anRGBehavior [
	^ self
]

{ #category : #accessing }
ClosureMap >> astcodes [ ^
	astcodes
]

{ #category : #accessing }
ClosureMap >> astcodes: anSBlock [

	astcodes := anSBlock
]

{ #category : #accessing }
ClosureMap >> block [
	^block
]

{ #category : #accessing }
ClosureMap >> block: anSCompiledBlock [
	block := anSCompiledBlock
]

{ #category : #accessing }
ClosureMap >> builder [
	^ builder
]

{ #category : #accessing }
ClosureMap >> builder: aMethodEvaluator [
	builder := aMethodEvaluator
]

{ #category : #accessing }
ClosureMap >> printOn: aStream [
	aStream
		nextPutAll: '<< ['.
	self slots do: [ :slot | aStream print: slot ] separatedBy: [ aStream nextPutAll: ', ' ].
aStream
		nextPutAll: '] >>'
]
