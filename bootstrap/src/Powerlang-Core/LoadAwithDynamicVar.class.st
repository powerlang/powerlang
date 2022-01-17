Class {
	#name : #LoadAwithDynamicVar,
	#superclass : #LoadAOpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadAwithDynamicVar class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeDynamicVar
]
