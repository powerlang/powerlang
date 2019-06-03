Class {
	#name : #SelfBinding,
	#superclass : #Binding,
	#category : #'PST-Compiling'
}

{ #category : #'as yet unclassified' }
SelfBinding class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #testing }
SelfBinding >> isSelf [
	^true
]
