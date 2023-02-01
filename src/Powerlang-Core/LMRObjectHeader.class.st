Class {
	#name : #LMRObjectHeader,
	#superclass : #Object,
	#instVars : [
		'behavior',
		'flags',
		'size',
		'hash'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRObjectHeader >> behavior [
	^behavior
]

{ #category : #accessing }
LMRObjectHeader >> behavior: anLMRHeapObject [
	behavior := anLMRHeapObject
]

{ #category : #accessing }
LMRObjectHeader >> bytes: bytes arrayed: arrayed named: named [
	| b a n |
	b := bytes
		ifTrue: [ 1 ]
		ifFalse: [ 0 ].
	a := arrayed
		ifTrue: [ 2 ]
		ifFalse: [ 0 ].
	n := named	ifTrue: [ 4 ]
		ifFalse: [ 0 ].
	flags := b | a | n 
]

{ #category : #accessing }
LMRObjectHeader >> flags [
	^flags
]

{ #category : #accessing }
LMRObjectHeader >> hash [
	^hash
]

{ #category : #accessing }
LMRObjectHeader >> hash: anInteger [
	hash := anInteger
]

{ #category : #accessing }
LMRObjectHeader >> isSmall [
	^ self size < 256
]

{ #category : #accessing }
LMRObjectHeader >> size [
	^size 
]

{ #category : #accessing }
LMRObjectHeader >> size: anInteger [
	size := anInteger.
	self isSmall ifTrue: [ flags := flags | 16r80]
]
