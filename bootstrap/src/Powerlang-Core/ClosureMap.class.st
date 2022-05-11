Class {
	#name : #ClosureMap,
	#superclass : #SlotObjectMap,
	#instVars : [
		'block',
		'builder'
	],
	#category : #'Powerlang-Core-Execution-Ring'
}

{ #category : #'instance creation' }
ClosureMap class >> classFor: anRGBehavior [
	^ self
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
ClosureMap >> executionTree [
	^ block optimizedCode
]

{ #category : #accessing }
ClosureMap >> isClosure [ 
	^true
]

{ #category : #accessing }
ClosureMap >> printOn: aStream [
	aStream
		nextPutAll: '<< ['.
	self slots do: [ :slot | aStream print: slot ] separatedBy: [ aStream nextPutAll: ', ' ].
aStream
		nextPutAll: '] >>'
]
