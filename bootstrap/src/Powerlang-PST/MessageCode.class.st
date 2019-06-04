Class {
	#name : #MessageCode,
	#superclass : #Astcode,
	#instVars : [
		'selectorIndex',
		'receiver',
		'arguments'
	],
	#category : #'Powerlang-PST-Compiling'
}

{ #category : #'as yet unclassified' }
MessageCode class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeMessage
]

{ #category : #testing }
MessageCode >> isMessage [
	^true
]

{ #category : #printing }
MessageCode >> printOn: aStream [
	aStream nextPutAll: '{MessageId. '.
	receiver printOn: aStream.
	aStream nextPutAll: '. '.
	arguments
		do: [ :statement | statement printOn: aStream ]
		separatedBy: [ aStream nextPutAll: '. ' ].
	aStream nextPutAll: '}'
]
