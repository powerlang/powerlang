Class {
	#name : #StackOpcode,
	#superclass : #Opcode,
	#category : #'Powerlang-Core-Nativization'
}

{ #category : #unclassified }
StackOpcode class >> decodeUsing: anAstcodeDecoder [
	^ self new
]
