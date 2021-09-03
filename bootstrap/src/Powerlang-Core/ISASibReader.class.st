"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISASibReader,
	#superclass : #ISAInstructionPartReader,
	#category : #'Powerlang-Core-Assembler-Intel-Tools'
}

{ #category : #accessing }
ISASibReader >> contents [
	^contents
]

{ #category : #private }
ISASibReader >> from: aStream [
	contents := SIB new on: aStream next
]
