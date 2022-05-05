Class {
	#name : #LMRByteObject,
	#superclass : #LMRHeapObject,
	#instVars : [
		'bytes'
	],
	#category : #'Powerlang-Core-Execution-LMR'
}

{ #category : #accessing }
LMRByteObject >> asLocalString [
	^ bytes allButLast asString
]

{ #category : #accessing }
LMRByteObject >> bytes [
	^bytes
]

{ #category : #accessing }
LMRByteObject >> bytes: aByteArray [
	self ASSERT: aByteArray size = header size.
	bytes := aByteArray
]

{ #category : #accessing }
LMRByteObject >> header: anLMRObjectHeader [
	super header: anLMRObjectHeader.
	bytes := ByteArray new: header size
]
