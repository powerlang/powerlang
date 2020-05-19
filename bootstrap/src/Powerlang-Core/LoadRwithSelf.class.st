Class {
	#name : #LoadRwithSelf,
	#superclass : #LoadROpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadRwithSelf class >> decodeUsing: anAstcodeDecoder [
	^self new
]

{ #category : #accessing }
LoadRwithSelf >> nativizeUsing: anAssembler [
	anAssembler loadRwithS
]
