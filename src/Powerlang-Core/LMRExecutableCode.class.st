Class {
	#name : #LMRExecutableCode,
	#superclass : #LMRHeapObject,
	#instVars : [
		'code'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRExecutableCode >> code [
	^code
]

{ #category : #accessing }
LMRExecutableCode >> code: anObject [
	code := anObject
]
