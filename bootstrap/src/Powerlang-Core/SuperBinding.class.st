Class {
	#name : #SuperBinding,
	#superclass : #SelfBinding,
	#category : #'Powerlang-Core-SCompiler'
}

{ #category : #testing }
SuperBinding >> isSelf [
	^false
]

{ #category : #testing }
SuperBinding >> isSuper [
	^true
]
