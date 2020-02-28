"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAInstructionPartReader,
	#superclass : #Object,
	#instVars : [
		'contents'
	],
	#category : #'Powerlang-Core-Assembler-Tools'
}

{ #category : #accessing }
ISAInstructionPartReader >> contents [
	^contents contents
]

{ #category : #private }
ISAInstructionPartReader >> from: aStream [
	contents := #[] writeStream
]
