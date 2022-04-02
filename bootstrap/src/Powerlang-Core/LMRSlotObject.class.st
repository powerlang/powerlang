Class {
	#name : #LMRSlotObject,
	#superclass : #LMRHeapObject,
	#instVars : [
		'slots'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRSlotObject >> basicAt: index put: anLMRObject [
	^ slots at: index put: anLMRObject
]

{ #category : #accessing }
LMRSlotObject >> header: anLMRObjectHeader [
	super header: anLMRObjectHeader.
	slots := Array new: header size
]

{ #category : #accessing }
LMRSlotObject >> size [
	^header size
]

{ #category : #accessing }
LMRSlotObject >> slotAt: index [
	^ slots at: index
]

{ #category : #accessing }
LMRSlotObject >> slotAt: index put: anLMRObject [
	^ slots at: index put: anLMRObject
]