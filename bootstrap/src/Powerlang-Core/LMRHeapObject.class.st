Class {
	#name : #LMRHeapObject,
	#superclass : #LMRObject,
	#instVars : [
		'header'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRHeapObject >> behavior [
	^header behavior
]

{ #category : #accessing }
LMRHeapObject >> behavior: anLMRHeapObject [
	header behavior: anLMRHeapObject
]

{ #category : #accessing }
LMRHeapObject >> header: anInteger [
	header := anInteger
]

{ #category : #accessing }
LMRHeapObject >> headerFlags [
	^header flags
]

{ #category : #accessing }
LMRHeapObject >> isSmall [
	^ header isSmall
]

{ #category : #accessing }
LMRHeapObject >> printOn: aStream [
	self behavior printInstance: self on: aStream
]

{ #category : #accessing }
LMRHeapObject >> size [
	^header size
]
