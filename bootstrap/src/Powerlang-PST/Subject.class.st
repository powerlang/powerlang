Class {
	#name : #Subject,
	#superclass : #ProtoObject,
	#instVars : [
		'gate'
	],
	#category : #'Powerlang-PST-Metaphysics'
}

{ #category : #'as yet unclassified' }
Subject >> _gate [
	^gate
]

{ #category : #'as yet unclassified' }
Subject >> _gate: aMirageGate [
	gate := aMirageGate
]

{ #category : #system }
Subject >> doesNotUnderstand: aMessage [
	^gate dispatch: aMessage
]

{ #category : #private }
Subject >> perform: aSymbol withArguments: anArray [
	| message |
	message := Message
		receiver: self
		selector: #perform:withArguments:
		arguments: (Array with: aSymbol with: anArray).
	^self doesNotUnderstand: message
]

{ #category : #private }
Subject >> printString [
	| message |
	message := MessageSend receiver: self selector: #printString arguments: #().
	^self doesNotUnderstand: message
]
