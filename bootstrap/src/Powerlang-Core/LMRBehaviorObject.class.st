Class {
	#name : #LMRBehaviorObject,
	#superclass : #LMRSlotObject,
	#instVars : [
		'runtime'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRBehaviorObject >> classInstSize [
	| class |
	class := runtime behaviorClass: self.
	^runtime speciesInstanceSize: class
]

{ #category : #accessing }
LMRBehaviorObject >> localClassName [
	| class |
	class := runtime behaviorClass: self.
	^ runtime speciesLocalName: class
]

{ #category : #accessing }
LMRBehaviorObject >> printInstance: anLMRObject on: aStream [
	runtime print: anLMRObject on: aStream
]

{ #category : #accessing }
LMRBehaviorObject >> printOn: aStream [
	runtime printBehavior: self on: aStream
]

{ #category : #accessing }
LMRBehaviorObject >> runtime: aPowertalkLMR [
	runtime := aPowertalkLMR
]
