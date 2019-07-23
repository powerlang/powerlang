Class {
	#name : #SelfBinding,
	#superclass : #Binding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #'as yet unclassified' }
SelfBinding class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #testing }
SelfBinding >> isSelf [
	^true
]
