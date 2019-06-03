Class {
	#name : #SuperBinding,
	#superclass : #SelfBinding,
	#category : #'PST-Compiling'
}

{ #category : #testing }
SuperBinding >> isSelf [
	^false
]

{ #category : #testing }
SuperBinding >> isSuper [
	^true
]
