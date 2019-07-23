Class {
	#name : #ObjectFormat,
	#superclass : #Object,
	#instVars : [
		'storage'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #'instance creation' }
ObjectFormat class >> on: storage [
	^self new storage: storage
]

{ #category : #accessing }
ObjectFormat >> storage: anObject [
	storage := anObject
]
