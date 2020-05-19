Class {
	#name : #LoadAwithLiteral,
	#superclass : #LoadAOpcode,
	#instVars : [
		'value'
	],
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithLiteral class >> decodeUsing: anAstcodeDecoder [
	| index value |
	index := anAstcodeDecoder nextInteger.
	value := index = 0
		ifTrue: [anAstcodeDecoder next]
		ifFalse: [anAstcodeDecoder literalAt: index].
	^self new value: value
]

{ #category : #'as yet unclassified' }
LoadAwithLiteral >> nativizeUsing: anAssembler for: messageNativizer [
	anAssembler loadAwithPointer: value
]

{ #category : #'as yet unclassified' }
LoadAwithLiteral >> value: anObject [
	value := anObject
]
