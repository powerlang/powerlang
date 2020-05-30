Class {
	#name : #LoadAwithNil,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithNil class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #accessing }
LoadAwithNil >> nativizeUsing: anAssembler [
	anAssembler loadAwithNil
]
