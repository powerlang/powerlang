Class {
	#name : #LMRBehaviorObject,
	#superclass : #LMRSlotObject,
	#instVars : [
		'runtime'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRBehaviorObject >> printInstance: anLMRObject on: aStream [
	runtime print: anLMRObject on: aStream
]

{ #category : #accessing }
LMRBehaviorObject >> runtime: aPowertalkLMR [
	runtime := aPowertalkLMR
]
