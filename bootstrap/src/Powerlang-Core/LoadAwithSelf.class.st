Class {
	#name : #LoadAwithSelf,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithSelf class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #accessing }
LoadAwithSelf >> nativizeUsing: anAssembler [
	anAssembler loadAwithS
]
