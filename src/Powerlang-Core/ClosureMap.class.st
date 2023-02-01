Class {
	#name : #ClosureMap,
	#superclass : #SlotObjectMap,
	#instVars : [
		'block'
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
ClosureMap >> executionTree [
	^ block optimizedCode
]

{ #category : #accessing }
ClosureMap >> home [
	block capturesHome ifFalse: [ self error: 'closure has no home' ].
	^block capturesSelf ifTrue: [ self at: 2 ] ifFalse: [ self at: 1 ]
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
