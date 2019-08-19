Class {
	#name : #Subject,
	#superclass : #ProtoObject,
	#instVars : [
		'gate'
	],
	#classVars : [
		'Counts'
	],
	#category : #'Powerlang-Core-Metaphysics'
}

{ #category : #initialization }
Subject class >> initialize [
	Counts := IdentityDictionary new
]

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
	| send |
	send := MessageSend message: aMessage to: self.
			^ gate dispatch: send
]

{ #category : #private }
Subject >> perform: aSymbol withArguments: anArray [
	| message |
	message := Message
		selector: #perform:withArguments:
		arguments: (Array with: aSymbol with: anArray).
	^ self doesNotUnderstand: message
]

{ #category : #private }
Subject >> printOn: aStream [
	aStream nextPutAll: '{'; print: gate; nextPutAll: '}'

]

{ #category : #private }
Subject >> printString [
	^String streamContents: [ :s | self printOn: s ]
]

{ #category : #private }
Subject >> printString2 [
	| message |
	message := MessageSend
		receiver: self
		selector: #printString
		arguments: #().
	^ self doesNotUnderstand: message
]
