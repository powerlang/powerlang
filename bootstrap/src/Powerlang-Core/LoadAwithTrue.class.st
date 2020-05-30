Class {
	#name : #LoadAwithTrue,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithTrue class >> decodeUsing: anAstcodeDecoder [
	^ self new
]

{ #category : #accessing }
LoadAwithTrue >> nativizeUsing: anAssembler [
	anAssembler loadAwithTrue
]
