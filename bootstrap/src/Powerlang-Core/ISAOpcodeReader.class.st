"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAOpcodeReader,
	#superclass : #ISAInstructionPartReader,
	#category : #'Powerlang-Core-Assembler-Tools'
}

{ #category : #private }
ISAOpcodeReader >> from: aStream [
	| byte octets |
	super from: aStream.
	byte := aStream next.
	contents nextPut: byte.
	byte = 16rF ifTrue: [
		octets := (#[16r66 16rF2 16rF3] includes: contents contents first)
			ifTrue: [aStream next: 2]
			ifFalse: [{aStream next}].
		contents nextPutAll: octets]
]

{ #category : #printing }
ISAOpcodeReader >> printOn: aStream [
	contents contents
		do: [:byte | aStream nextPutAll: byte hex]
		separatedBy: [aStream nextPut: $.]
]
