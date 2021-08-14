"
Copyright (c) 2020 Aucerna.
    See (MIT) license in root directory.
"
Class {
	#name : #JITAssemblerAMD64,
	#superclass : #AssemblerAMD64,
	#instVars : [
		'backend'
	],
	#category : #'Powerlang-Core-Assembler-Intel'
}

{ #category : #private }
JITAssemblerAMD64 >> initialize [
	super initialize.
	backend := self
]

{ #category : #integers }
JITAssemblerAMD64 >> loadZeroExtendShortRwithRoffset: offset [
	pointer
		reset;
		length: 16;
		base: backend regR;
		displacement: offset.
	self assemble: 'movzx' with: backend regR with: pointer
]

{ #category : #'opcodes - integer related' }
JITAssemblerAMD64 >> moveTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['movsq'] ifFalse: ['movsd'].
	self assembleByte: rep; assemble: mnemonic
]

{ #category : #arithmetic }
JITAssemblerAMD64 >> subTslotsToSP [
	self assemble: 'neg' with: backend regT.
	pointer
		reset;
		length: self addressLength;
		base: backend regSP;
		index: backend regT;
		scale: backend regSP sizeInBytes.
	self
		assemble: 'lea' with: backend regSP with: pointer;
		assemble: 'neg' with: backend regT
]

{ #category : #'opcodes - integer related' }
JITAssemblerAMD64 >> writeTslots [
	| rep mnemonic |
	rep := 16rF3.
	mnemonic := wordSize = 8 ifTrue: ['stosq'] ifFalse: ['stosd'].
	self assembleByte: rep; assemble: mnemonic
]
