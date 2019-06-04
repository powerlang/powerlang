Class {
	#name : #SelfBinding,
	#superclass : #Binding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
SelfBinding class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #testing }
SelfBinding >> isSelf [
	^true
]
