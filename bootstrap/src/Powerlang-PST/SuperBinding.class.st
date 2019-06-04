Class {
	#name : #SuperBinding,
	#superclass : #SelfBinding,
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #testing }
SuperBinding >> isSelf [
	^false
]

{ #category : #testing }
SuperBinding >> isSuper [
	^true
]
