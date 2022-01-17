Class {
	#name : #LoadRwithDynamicVar,
	#superclass : #LoadROpcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
LoadRwithDynamicVar class >> decodeUsing: anAstcodeDecoder [
	^ anAstcodeDecoder decodeDynamicVar
]
