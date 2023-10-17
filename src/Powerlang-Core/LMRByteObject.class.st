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
LMRByteObject >> at: index [

	^bytes at: index
]

{ #category : #accessing }
LMRByteObject >> at: index put: anLMRObject [
	| value |
	value := anLMRObject value.
	bytes at: index put: value.
	^ anLMRObject
]

{ #category : #accessing }
LMRByteObject >> bytes [
	^bytes
]

{ #category : #accessing }
LMRByteObject >> bytes: aByteArray [
	self ASSERT: aByteArray size = header size.
	self ASSERT: aByteArray class == ByteArray.
	bytes := aByteArray
]

{ #category : #accessing }
LMRByteObject >> header: anLMRObjectHeader [
	super header: anLMRObjectHeader.
	bytes := ByteArray new: header size
]

{ #category : #accessing }
LMRByteObject >> isBytes [
	^true
]
