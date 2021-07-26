"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #ISAInstructionReader,
	#superclass : #Object,
	#instVars : [
		'prefixes',
		'opcode',
		'modrm',
		'sib',
		'displacement',
		'immediate'
	],
	#category : #'Powerlang-Core-Assembler-Intel-Tools'
}

{ #category : #private }
ISAInstructionReader >> displacementFrom: aStream [
	
]

{ #category : #private }
ISAInstructionReader >> from: aStream [
	self
		prefixesFrom: aStream;
		opcodeFrom: aStream;
		modrmFrom: aStream;
		sibFrom: aStream;
		displacementFrom: aStream;
		immediateFrom: aStream
]

{ #category : #testing }
ISAInstructionReader >> hasSib [
	^modrm notNil and: [modrm mod = 0]
]

{ #category : #private }
ISAInstructionReader >> immediateFrom: aStream [
	immediate := aStream upToEnd
]

{ #category : #private }
ISAInstructionReader >> modrmFrom: aStream [
	modrm := ISAModRMReader new from: aStream; contents
]

{ #category : #private }
ISAInstructionReader >> opcodeFrom: aStream [
	opcode := ISAOpcodeReader new from: aStream; asString
]

{ #category : #private }
ISAInstructionReader >> prefixesFrom: aStream [
	prefixes := ISAPrefixReader new from: aStream; asString
]

{ #category : #printing }
ISAInstructionReader >> printOn: aStream [
	aStream nextPutAll: prefixes.
	prefixes size > 0 ifTrue: [aStream nextPutAll: '| '].
	aStream nextPutAll: opcode.
	aStream nextPutAll: ' | '.
	modrm notNil ifTrue: [modrm printOn: aStream].
	sib notNil ifTrue: [
		aStream nextPutAll: ' | '.
		sib printOn: aStream].
	displacement notNil ifTrue: [
		aStream nextPutAll: ' |'.
		displacement do: [:byte | | hex |
			hex := byte hex.
			hex size = 1 ifTrue: [hex := '0' , hex].
			aStream space; nextPutAll: hex]].
	immediate notNil ifTrue: [
		aStream nextPutAll: ' |'.
		immediate do: [:byte | | hex |
			hex := byte hex.
			hex size = 1 ifTrue: [hex := '0' , hex].
			aStream space; nextPutAll: hex]]
]

{ #category : #private }
ISAInstructionReader >> sibFrom: aStream [
	self hasSib ifFalse: [^self].
	aStream atEnd ifTrue: [^self].
	sib := ISASibReader new from: aStream; contents
]
