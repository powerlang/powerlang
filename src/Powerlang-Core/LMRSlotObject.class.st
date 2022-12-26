Class {
	#name : #LMRSlotObject,
	#superclass : #LMRHeapObject,
	#instVars : [
		'slots'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRSlotObject >> at: index [
	^ slots at: header behavior classInstSize + index
]

{ #category : #accessing }
LMRSlotObject >> at: index put: anLMRObject [	
	^ slots at: header behavior classInstSize + index put: anLMRObject
]

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
LMRSlotObject >> nilSlots: nilObj [
	slots atAllPut: nilObj
]

{ #category : #accessing }
LMRSlotObject >> pointersSize [
	^ header size
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

{ #category : #accessing }
LMRSlotObject >> slots [
	^ slots
]
