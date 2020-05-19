Class {
	#name : #LoadRvisitingReceiver,
	#superclass : #LoadROpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadRvisitingReceiver class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #'as yet unclassified' }
LoadRvisitingReceiver >> nativizeUsing: anAssembler for: messageNativizer [
	messageNativizer loadRvisitingReceiver
]
