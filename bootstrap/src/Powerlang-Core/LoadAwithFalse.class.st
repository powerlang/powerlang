Class {
	#name : #LoadAwithFalse,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithFalse class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #accessing }
LoadAwithFalse >> nativizeUsing: anAssembler [
	anAssembler loadAwithFalse
]
