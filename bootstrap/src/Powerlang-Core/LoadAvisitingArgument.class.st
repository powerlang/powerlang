Class {
	#name : #LoadAvisitingArgument,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAvisitingArgument class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #'as yet unclassified' }
LoadAvisitingArgument >> nativizeUsing: anAssembler for: messageNativizer [
	messageNativizer loadRvisitingArgument.
	anAssembler loadAwithR
]
