Class {
	#name : #BlockCode,
	#superclass : #ScriptCode,
	#category : #'PST-Compiling'
}

{ #category : #'as yet unclassified' }
BlockCode class >> decodeUsing: anAstcodeDecoder [
	^anAstcodeDecoder decodeBlock
]

{ #category : #printing }
BlockCode >> printOn: aStream [
	aStream nextPutAll: '{BlockId. '.
	super printOn: aStream.
	aStream nextPutAll: '}'
]
