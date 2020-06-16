Class {
	#name : #LoadAwithLiteral,
	#superclass : #LoadAwithLiteralVar,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithLiteral class >> decodeUsing: anAstcodeDecoder [
	| instance index  |
	instance := super decodeUsing: anAstcodeDecoder.
	index := instance index.
	index = 0
		ifTrue: [ instance value: anAstcodeDecoder next ].
	^ instance
]

{ #category : #'as yet unclassified' }
LoadAwithLiteral >> nativizeUsing: anAssembler for: messageNativizer [
	| i |
	value notNil
		ifTrue: [ anAssembler loadAwithSmallInteger: value ]
		ifFalse: [ 	i := messageNativizer methodLiteralIndexFrom: index.
	anAssembler loadAwithMindex: i]
]

{ #category : #'as yet unclassified' }
LoadAwithLiteral >> value: anObject [
	value := anObject
]
