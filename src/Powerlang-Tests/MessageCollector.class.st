Class {
	#name : #MessageCollector,
	#superclass : #Object,
	#instVars : [
		'subject'
	],
	#classVars : [
		'Messages'
	],
	#category : #'Powerlang-Tests-Collector'
}

{ #category : #'instance creation' }
MessageCollector class >> for: anObject [
	^ self new 
		subject: anObject;
		yourself

]

{ #category : #initialization }
MessageCollector class >> initialize [
	"Invoked at system start or when the class is dynamically loaded."

	"  please change as required (and remove this comment)"

	Messages := Set new

]

{ #category : #accessing }
MessageCollector class >> messages [
	^ Messages

]

{ #category : #hooks }
MessageCollector >> doesNotUnderstand: aMessage [
	(aMessage arguments allSatisfy: [:e | e isInteger ]) ifTrue: [ 
		(Messages contains: [:e | e selector = aMessage selector and:[e arguments = aMessage arguments]]) ifFalse: [ 
			Messages add: aMessage.
		].
	].
	^ aMessage sendTo: subject

]

{ #category : #accessing }
MessageCollector >> subject [
	^ subject
]

{ #category : #accessing }
MessageCollector >> subject:anObject [
	subject := anObject.

]
